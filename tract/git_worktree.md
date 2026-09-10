# Parallel dev instances (git worktrees) — local setup

Run several instances of TRACT at once, so agents on different branches don't block each
other and you can compare master against a branch side by side.

**Nothing here is in the repo.** Every file is untracked (see `~/.gitignore`), so this can
be trialled without anything landing in review. If it proves worth sharing, the repo
version is recorded on the branch `cferey/parallel-dev-instances-repo-version`.

## The commands

```sh
bin/worktree help                     # cheatsheet
bin/worktree list
bin/worktree new NAME [--from REF] [--own-db|--shared-db]
bin/worktree promote NAME             # shared DB -> its own cluster
bin/worktree reset NAME               # throw the branch DB away, re-clone from golden
bin/worktree rm NAME
bin/worktree rebuild-golden            # after a production pull
bin/worktree adopt                     # from inside a worktree: regenerate its config
```

`adopt` is also the upgrade path. The three generated files are written once, at
provisioning time, so a worktree cut before a fix to `bin/worktree` keeps the old copies
until you re-run `adopt` inside it. Existing worktrees do not heal on their own.

Inside a worktree, prefix everything with `bin/wt` (`bin/wt bin/dev`, `bin/wt rails c`,
`bin/wt rspec`, `bin/wt psql`). Without it you talk to the primary database. In the
primary checkout `bin/wt` is a no-op.

`claude -w NAME` and `claude --bg` provision themselves — see below.

## Why the database is the hard part

Ports and cookies were never the problem. Each branch with a migration wants its own
schema, but the dev database is a ~16 GB anonymized production copy, so N instances
naively cost N × 16 GB.

The way out is that **APFS supports copy-on-write clones**. Measured on the real golden
cluster:

| Operation | Real disk consumed |
|---|---|
| `cp -Rpc` a 19 GB PGDATA | **0 bytes**, under a second |
| Full scan of 12 GB of tables on the clone | **0 bytes** |
| One migration on the clone | 0.1 MB |
| `promote` (clone + re-migrate) | 3.6 MB |
| Two worktrees, one with its own 19 GB database | 95 MB |

`du` and `pg_database_size()` keep reporting the full size for a clone — they count shared
blocks. Only `diskutil info /` tells the truth (`df` on APFS inflates it with purgeable
space).

Two things silently destroy those economics:

- **Hint bits.** The first read of an unfrozen table dirties its pages. Measured at
  **560 MB from a single `SELECT count(*)`** on a 1.9 GB table. The golden is therefore
  `VACUUM (FREEZE, ANALYZE)`d before it is ever cloned; after that the same scan costs zero.
- **Whole-table rewrites.** `VACUUM FULL` diverged a 2.9 GB table completely — the same
  mechanism as `RefreshTicketSettlementDatesWorker`, which rewrites a matview every 15
  minutes. Hence the scheduler runs in the primary only.

**Why not Docker.** Docker Desktop on macOS keeps volumes in a Linux disk image whose
filesystem has no reflink support, so a containerised Postgres loses copy-on-write — the
property this all depends on.

**Why PostgreSQL 17, not 18.** PG18 could do this within a single cluster
(`file_copy_method = clone`), which is tidier. But production runs 17, and 18's planner
adds btree skip-scan and OR→ANY rewriting, so local `EXPLAIN` output would stop matching
production. Parity wins. Revisit when production upgrades.

## Architecture

```
/opt/homebrew/var/postgresql@17   :5432   ← shared cluster, also holds other projects
/opt/homebrew/var/tract-golden    stopped ← the clone source; never runs, so never mutates
/opt/homebrew/var/tract-wt-<name> :5444+N ← per-worktree reflink clone of golden
```

Each worktree gets its own **cluster**, so databases inside keep their usual names — no
renaming, no test-database prefix scheme. The golden stays stopped, which is what makes it
safe: a stopped cluster cannot be connected to, so nothing can corrupt the anonymized data
it took 1–2 h to build. Concurrent `rspec` across worktrees also stops colliding.

Keep a real dump around (`pg_dump -Fd -j4`, ~2.8 GB, at `~/pg_golden_backup/`). A golden
that exists only as a cluster is not a backup.

## How it works with no repo changes

`bin/worktree` writes three untracked, auto-loaded files into each worktree:

| File | Replaces |
|---|---|
| `config/initializers/zzz_worktree_local.rb` | editing `config/cable.yml` and `config/sidekiq.yml` |
| `lib/tasks/zzz_worktree_local.rake` | a committed guard on `db:migrate` |
| `.env.test.local` | keeping `VITE_RUBY_PORT` out of the test environment |

All three are in `~/.gitignore`, so `git status` stays clean in every worktree.

The database port needs nothing at all: `bin/wt` exports `PGPORT`, and libpq honours it
because `config/database.yml` specifies no port for development. Verified — a worktree on
plain master connects to its own cluster on 5445.

Two traps found the hard way in that initializer:

- **`config.action_cable.cable` needs SYMBOL keys.** ActionCable reads
  `cable[:channel_prefix]`; a string-keyed hash leaves the prefix `nil` and silently
  un-isolates broadcasts while appearing to work.
- **Redis pub/sub is global across database indexes.** A different `REDIS_URL` index does
  *not* isolate ActionCable — only `channel_prefix` does. 12 files use
  `turbo_stream_from` / `broadcast_to`.
- **The cable override must skip the test environment.** `config/cable.yml` already points
  test at the `async` adapter, and `spec/rails_helper.rb` swaps Redis for `MockRedis`,
  which has no `#without_reconnect`. Forcing the redis adapter in test therefore kills
  every `js: true` feature spec the moment its page opens a cable connection — and the
  `NoMethodError` is raised on ActionCable's listener thread, so RSpec blames whichever
  example happened to be running rather than the initializer. There is nothing to isolate
  in test anyway: `async` is process-local by construction. Hence the `unless
  Rails.env.test?` around that block.

`config/puma.rb` needs no change: two instances both bind `/tmp/web_server.sock` and
neither crashes — the last one takes it over, and nothing connects to it locally.

### The Vite port must not reach the test environment

This one cost an afternoon, so it is worth stating plainly: **a running dev Vite server
silently disables JavaScript in this worktree's feature specs.**

`vite_ruby` decides whether a dev server is running by opening a TCP socket to
`host:port` (`vite_ruby.rb:86`). It does not care which environment asked. `VITE_RUBY_PORT`
in `.env` is this worktree's *dev* port, but dotenv loads `.env` in test too, so with
`bin/vite dev` up, a spec run concludes the dev server is live and does two things:

1. emits dev-server asset URLs — `/vite-test/@vite/client` and unhashed entry paths — which
   the dev server 404s, because it is serving `vite-dev`, not `vite-test`;
2. **skips the build**, because `should_build?` is `auto_build && !dev_server_running?`
   (`manifest.rb:106`), so `public/vite-test` is never created.

Every `js: true` spec then runs against a page with no JavaScript and fails in whatever way
that page happens to fail. Nothing in the output mentions Vite: Vue never mounts, so a
Capybara matcher times out, or an Enter key submits a form that JS was supposed to
intercept and the controller 500s on params that were never populated. Roughly 44 examples,
all looking like unrelated flakes.

Two overrides, because they cover different entry points:

- `.env.test.local` (generated per worktree) — dotenv loads `.env.<env>.local` first and
  never overwrites an already-set key, so this shadows `.env` for test only. Covers a plain
  `bundle exec rspec`.
- `bin/wt` re-exports it for anything that looks like a test run, since a variable exported
  into the shell outranks dotenv entirely.

The port itself is arbitrary — the point is that **nothing is listening on it** — but it
follows the same +10-per-slot scheme as the dev port (`3037 + slot * 10`) so it stays
collision-free if a test dev server is ever run. `config/vite.json` reserves 3037 for test
in the primary checkout, which is where that base comes from.

To check a worktree is healthy, with `bin/vite dev` running:

```sh
bin/wt bundle exec rspec spec/features/enter_scale_tickets_spec.rb
```

Those specs need Vue to mount, so they fail as a group if this regresses. `public/vite-test`
should appear on its own — autoBuild handles it, and needing a manual
`RAILS_ENV=test bin/vite build` is itself the symptom.

## Sharing the primary database, and the guard

`new` gives a worktree its own cluster only when the branch *already* has migrations;
otherwise it shares the primary database, which is what you want for side-by-side
comparison on identical data. Worktrees created by Claude Code always get their own.

The decision is made at provisioning time, so a migration written later would hit the
primary database. Two layers refuse it — the rake prerequisite, and the same check in
`bin/wt` (redundant on purpose: the rake file is regenerated per worktree, while `bin/wt`
is copied fresh from the primary). `bin/worktree promote NAME` is the way through.

`bin/wt` also refuses `pull_production_database`, which drops and recreates whatever
`database.yml` resolves to.

## Claude Code's own worktrees

`claude -w NAME`, `claude --bg` and subagents with `isolation: worktree` create worktrees
themselves. They are provisioned automatically, but not by the obvious route:

- **`WorktreeCreate` / `WorktreeRemove` hooks do not fire here.** They substitute for git
  only in a repo with no VCS. Verified: with both configured, `claude -w` created the
  worktree natively and neither hook ran.
- **A `SessionStart` hook running `bin/worktree adopt` is what works** — it provisions
  whatever worktree the session opens in, and is a silent no-op otherwise.
- **That hook must live in `~/.claude/settings.json`.** A Claude-created worktree is a
  fresh checkout and `.claude/settings.json` is gitignored, so a project-level hook is
  never read. `adopt` guards on the repo (it looks for `timber_app_development` in
  `config/database.yml`) and exits 0 silently everywhere else.

`adopt` gives agent worktrees their **own cluster by default**, since an agent may add a
migration mid-session. `TRACT_SHARED_DB=1` opts out. `adopt` on an already-provisioned
worktree re-syncs `.env` from the primary, preserving the slot and database choice.

## Refreshing from production

Pull production exactly as before — the rake task is untouched by any of this:

```sh
rake pull_production_database          # or [true] to include audits
```

It targets whatever `config/database.yml` resolves to, which in the primary checkout is
the database on 5432. Run it from the primary only; `bin/wt` refuses it inside a
worktree, since it drops and recreates whatever it resolves to.

Then rebuild the golden from the refreshed primary:

```sh
bin/worktree rebuild-golden                                            # dump + rebuild
bin/worktree rebuild-golden --dump ~/pg_golden_backup/timber_20260903  # reuse a dump
```

### Why that is a command and not a checklist

The ordering is load-bearing, and one step is silently destructive if skipped:

- **The old golden must be deleted before the new one is built.** It is ~18 GB with
  ~20 GB free, so the two cannot coexist. That makes the dump the *only* safety net at
  that moment, which is why `rebuild-golden` verifies it with `pg_restore -l` before
  removing anything — and never deletes it afterwards. A golden that exists only as a
  cluster is not a backup.
- **`VACUUM (FREEZE, ANALYZE)` is mandatory.** Skip it and the first read of each table
  sets hint bits and diverges the clone — measured at 560 MB from a single
  `SELECT count(*)` on a 1.9 GB table. It does not fail loudly; it quietly turns every
  "free" clone into a real copy and fills the disk.
- **Existing worktree clusters are independent copies** and keep the *old* snapshot until
  re-cloned. `rebuild-golden` lists the ones needing `bin/worktree reset NAME`.

The rake task's own `cleanup_dump_files!` deletes the dump it pulled from production, so
`rebuild-golden` takes its own dump of the refreshed primary instead of relying on it.
That dump doubles as the backup, and a local rebuild from it takes 10–20 minutes against
1–2 hours for another production pull.

## Slots

Slot 0 is the primary checkout and keeps every default.

| Variable | Slot N |
|---|---|
| `PORT` | 3000 + N |
| `VITE_RUBY_PORT` | 3036 + 10N (steps by 10; 3037 is reserved for test) |
| `TRACT_DB_PORT` | 5444 + N, or 5432 when sharing |
| `REDIS_URL` | db 2 + 2N — cache, Sidekiq queues, `LastSearch` |
| `CABLE_REDIS_URL` | db 3 + 2N |
| `CABLE_CHANNEL_PREFIX` | `tract_dev_wtN` |
| `SESSION_COOKIE_NAME` | `_timber_app_session_wtN` |
| `SIDEKIQ_SCHEDULER` | `false` except slot 0 |
| `TRACT_BASE` | the ref the worktree was cut from |
| `OVERMIND_IGNORED_PROCESSES` | `redis` |
| `OVERMIND_PORT_STEP` | `0` |

Sidekiq queues rely on the Redis database index alone: `config/sidekiq.yml` sets no
namespace and Sidekiq 7.3.9 dropped `redis-namespace`, so there is no other mechanism.
Without distinct indexes one worktree's worker drains another's queue.

`MAX_SLOTS` in `bin/worktree` caps this at 3 concurrent worktrees plus the primary. Each
own-cluster worktree is a running postgres (~200 MB RSS).

### Two overmind traps

- **`PORT` is a *base*, not the port.** Overmind adds `--port-step` (default 100) per
  process, so with `PORT=3001` the `web` entry — fifth in `Procfile.dev` — bound **3401**.
  Hence `OVERMIND_PORT_STEP=0`.
- **Overmind loads `./.env` and exports it *over* the inherited environment.** A worktree
  `.env` symlinked to the primary's therefore restored the primary's `REDIS_URL`, putting
  Sidekiq back on the shared queues — silently. So `.env` is generated as a real file:
  the primary's contents, then the overrides appended last. Re-run `adopt` after changing
  credentials in the primary.
- `Procfile.dev` is deliberately left alone. Its `redis-server` binds the wildcard
  `*:6379`, which does not conflict with a narrowly-bound Homebrew Redis, so it starts and
  serves nobody — but a *second* wildcard bind fails. Worktrees skip the process via
  `OVERMIND_IGNORED_PROCESSES` rather than changing the Procfile, so teammates without a
  Redis service keep working.

### Why `TRACT_BASE` is recorded

Teardown deletes a generated branch only when it holds no commits of its own. That check
originally compared against `origin/master`, so any worktree cut from a *feature* branch
looked like it held unmerged work — its branch was never deleted, and a later `new`
silently reused the stale branch at its old commit. The base is now recorded at creation
and used for the comparison; `new` also refuses to reuse a branch that does not contain
the ref you asked for.
