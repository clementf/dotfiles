# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/clement/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git env z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
export PATH="$HOME/.rbenv/bin:$PATH"
alias vs="open -a /Applications/Visual\ Studio\ Code.app"
alias vimrc="vim ~/.vimrc"
PATH=/usr/local/share/python:$PATH
PATH=$PATH:/usr/local/sbin
alias v="foreman run vim ."
alias rc="vim ~/.zshrc"
# global
alias c="cd ~/code"
alias dot="cd ~/code/dotfiles"

#specific
alias 5dp="cd ~/5miles/data_processor"
alias 5="cd ~/5miles/app"
alias 5c="cd ~/5miles/corporate-website-5miles"
alias 5mm="5miles morning"
alias p2s="5miles prod2stag"

# fuga
alias f="cd ~/code/fuga"
alias rake="noglob rake"
alias gcmx="git checkout master-x"

alias grh="git reset --hard"
alias so="source ~/.zshrc"
alias gb="git checkout -b"
alias fs="foreman s"
alias ta="foreman run bundle exec rspec"
alias tf="foreman run bundle exec rspec spec/features"
alias tnf="foreman run bundle exec rspec  --exclude-pattern \"spec/features/**/*_spec.rb\""
alias con="foreman run rails c"
alias ml="cd ~/code/coursera/ml"

alias dev="brew services run mongodb && brew services run postgresql && brew services run redis && brew services run rabbitmq"
alias stopdev="brew services stop mongodb && brew services stop postgresql && brew services stop redis && brew services stop rabbitmq"

alias bigfiles="sudo find / -type f -size +100000k -exec ls -lh {} \; | awk '{ print $9  $5 }' "

# tools
eval "$(thefuck --alias)"
eval "$(rbenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# ignore files when searching using fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
alias F="fzf"

export EDITOR=vim
