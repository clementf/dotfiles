PATH=/usr/local/share/python:$PATH
PATH=$PATH:/usr/local/sbin
export PATH="$HOME/.rbenv/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload -U compinit
compinit

if [[ ! -d "$HOME/.zgen" ]]; then
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi

source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
  zgen load mafredri/zsh-async
  zgen load sindresorhus/pure
  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-history-substring-search
  zgen oh-my-zsh plugins/z
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/rbenv
  zgen save
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there

# ===== History
export HISTFILE=~/.zsh_history
export HISTSIZE=20000
export SAVEHIST=20000
setopt append_history # Allow multiple terminal sessions to all append to one zsh command history
setopt extended_history # save timestamp of command and duration
setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
setopt HIST_EXPIRE_DUPS_FIRST # when trimming history, lose oldest duplicates first
setopt HIST_IGNORE_DUPS # Do not write events to history that are duplicates of previous events
setopt HIST_FIND_NO_DUPS # Ignore dupes that may already be in history
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt SHARE_HISTORY # imports new commands and appends typed commands to history

alias vs="open -a /Applications/Visual\ Studio\ Code.app"
alias ze="open -a /Applications/Zettlr.app"
alias ss="open -a /Applications/Sublime\ Text.app"
alias vimrc="vim ~/.vimrc"
alias v='env $(cat .env) vim .'
alias rc="vim ~/.zshrc"
alias j="z"
alias dokcer="docker"
alias dc="docker-compose"
alias bert="bundle exec rake test"
alias sp="bundle exec rspec"
alias be="bundle exec"

# global
alias c="cd ~/code"
alias dot="cd ~/code/dotfiles"

# fuga
source ~/.fugarc

# last commit
alias lc="git log --format=oneline --abbrev-commit | head -n 1 | cut -d ' ' -f1"
alias grh="git reset --hard"
alias so="source ~/.zshrc"
alias gb="git checkout -b"
alias gwip="git commit --m \"WIP\""
alias fs="foreman s"
alias ta="foreman run bundle exec rspec"
alias tf="foreman run bundle exec rspec spec/features"
alias tnf="foreman run bundle exec rspec  --exclude-pattern \"spec/features/**/*_spec.rb\""
alias con="foreman run rails c"

function git_current_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

alias preco="sh .git/hooks/pre-commit"
alias bigfiles="sudo find / -type f -size +100000k -exec ls -lh {} \; | awk '{ print $9  $5 }' "
alias churn="git log --all -M -C --name-only --format='format:' $@ | sort | grep -v '^$' | uniq -c | sort -n | awk 'BEGIN {print \"count\tfile\"} {print $1  $2}'"
alias showrt="netstat -nr -f inet" # show routing tables

alias t="tmux -u"
alias tn="tmux -u new"

alias ww="watson"
alias of="onefetch"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ignore files when searching using fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
alias ag='ag --path-to-ignore ~/.ignore'
alias F="fzf"

export EDITOR=vim
export WATSON_DIR=~/Dropbox/.watson
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/
export LESSCHARSET=UTF-8

export PATH="$HOME/.crenv/bin:$PATH"
eval "$(crenv init -)"

# needed for lucky framework
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

export LC_ALL=en_US.UTF-8
eval "$(rbenv init -)"
export ERL_AFLAGS="-kernel shell_history enabled"
export GOOGLE_APPLICATION_CREDENTIALS=~/.google_cloud_keyfile.json
