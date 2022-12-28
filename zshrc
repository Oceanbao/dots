# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# z.sh
. ~/dots/z.sh

# GOPATH
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# NVN
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# brew
[ -f /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

set -o vi
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

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
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='lvim'
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
ulimit -n 12000

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias dockc="docker container ls -a -s"
alias dockcrm="docker container rm"
alias dockb="DOCKER_BUILDKIT=1 docker build"
alias rm="rm -rfIv"
alias sd="sudo "
alias ddu="du -sh * | sort -hr | head -10"
alias pytest="pytest -l --tb=short"
alias vim="lvim"
alias ll="exa -alh --sort=size"
alias lt="exa -bghHliS --git -T --level=2"
alias g="git"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias openports="sudo lsof -i -P -n | grep LISTEN"
alias carr="cargo run"
alias carc="cargo check"
alias carb="cargo build --release"

# Functions
checkport() {
  sudo lsof -i:$1
}

ftext () {
	grep -iIHrn --color=always "$1" . | less -R -r
}

duplicatefind ()
{
	find . -not -empty -type f -exec -printf "%s\n" \; | sort -rn | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate
}

generateqr () {
	printf "$@" | curl -F-=\<- qrenco.de
}

rungist() {
  local gistKey=$1
  local arg1=$2
  echo "Gist keyword: ${gistKey}"

  # Required input validation
  if [[ "${gistKey}" == "" ]]; then
    echo
    echo "No gist Key provided as environment variable. Terminating..."
    echo
    return 0
  fi

  echo
  echo "---------------------------------------------------"
  echo "--- Executing script: ${gistKey}"
  echo

  bash <(gh gist view -r $(gh gist list -L 100 | grep "${gistKey}" | awk '{print $1}') | sed '/#!/,$!d') "$arg1"
  res_code=$?
  if [ ${res_code} -ne 0 ] ; then
    echo "--- [!] The script returned with an error code: ${res_code}"
    echo "---------------------------------------------------"
    return 1
  fi

  echo
  echo "--- Script returned with a success code - OK"
  echo "---------------------------------------------------"
  return 0
}

ghclone () {
  local keyword="$1"
  # Required input validation
  if [[ "${keyword}" == "" ]]; then
    echo
    echo "No repo keyword provided as environment variable. Terminating..."
    echo
    return 0
  fi

  echo
  echo "---------------------------------------------------"
  echo "--- GitHub repo: ${keyword}"
  echo
  gh repo clone $(gh repo list | grep "${keyword}" | awk '{print $1}') 
}

greptop () {
  local keyword="$1"
  htop --pid $(pgrep -d "," -f "${keyword}")
}

# export TERM=xterm-256color

# export PUPP_CHROME="/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"

# set DISPLAY variable to the IP automatically assigned to WSL2
# export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
# auto start dbus
# sudo /etc/init.d/dbus start &> /dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Wasmer
export WASMER_DIR="/home/vagrant/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
