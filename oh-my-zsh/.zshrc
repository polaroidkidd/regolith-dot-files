# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/dle/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="spaceship"

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#

# DISABLE_MAGIC_FUNCTIONS=true

# Disable Yarn Package Manager Errors
# https://github.com/yarnpkg/yarn/issues/9015#issuecomment-1834502140
# export YARN_SKIP_COREPACK_CHECK=0
export COREPACK_ROOT=0

# Disable error message in VS Code "The terminal process "/usr/bin/zsh" terminated with exit code: 130."
# https://stackoverflow.com/questions/71519436/the-terminal-process-usr-bin-zsh-terminated-with-exit-code-14
export TMOUT=0
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  z
  git
  ssh-agent
  zsh-syntax-highlighting
  zsh-autosuggestions
  sudo
  safe-paste
  nvm
  pnpm-shell-completion
  gcloud
  
  kubectl-autocomplete
)

  autoload -Uz compinit && compinit


# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities dle@cassandra dle@github.com dle@gitlab.ti8m.ch dle.xps@pi dle.hetzner@whatsin.fyi
zstyle :omz:plugins:ssh-agent lifetime
zstyle :omz:plugins:nvm autoload true



source $ZSH/oh-my-zsh.sh

fpath=(~/.zsh/completion $fpath)
#fpath=(~/.linuxbrew/share/zsh/site-functions/ $fpath)
fpath=(~/DevTools/blackblaze/B2_Command_Line_Tool/contrib $fpath)
  fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -Uz compinit && compinit -i

zstyle -s ':completion:*:hosts' hosts _ssh_config
[[ -r ~/.ssh/config ]] && _ssh_config+=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p'))
zstyle ':completion:*:hosts' hosts $_ssh_config

#####################################################
################ BEGIN  ALIAS #######################
#####################################################

# Disable Turbo Telemetry
export TURBO_TELEMETRY_DISABLED=1
export DO_NOT_TRACK=1

# Useful Git Commands
alias gl="git log --pretty=format:'%Cred%h %Cgreen%ad %Cblue%aN %Creset%s' --date=iso --graph --branches"
alias gall="git add --all"
alias ga="git add"
alias gs="git status"
alias gb="git branch --show-current"
alias gco="git checkout"
alias gcm="git commit -m"
alias gp="git push"
alias gpa="git push --all"
alias gpt="git push --follow-tags"
alias gip="git pull --verbose"
alias gbdo="git push --delete origin"
alias cb="git branch --show-current | tr -d "\n" | xclip -sel clip"
alias gcmc=__gcmc
fuction __gcmc(){
  git commit -m "`git symbolic-ref --short HEAD | grep -o -E '[A-Z]{3}-[0-9]{0,10}'`: $1"
}
# core git editor
export GIT_EDITOR=vim

# function to commit and push all with a message in format of: gcp example text [ENTER TO SEND]
function __gcp() {
  gall
  gcm "$*"
  gp
}
alias gcp='__gcp'

# Aliases for shutting down
alias sdn="sudo shutdown -P now"
alias rbn="sudo shutdown -r now"
alias usdn="uu -y && sdn"

# cat-copy to clipboard
function __catCopyToClipboard(){
  cat "$*" | xclip -sel cip
}
alias ccp="__catCopyToClipboard"

# Alias pnpm
alias pn="pnpm"

# Alias for installing and removing
alias gimme="sudo apt-get install"
alias update="sudo apt-get update"
alias upgrade="sudo apt-get upgrade"
alias uu="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
alias rem="sudo apt autoremove -y"


function __cursor {
        /home/dle/DevTools/cursor/Cursor.AppImage --no-sandbox "$1" & 
        disown
}
alias cursor="__cursor"

alias begone="__begone && rem"
function __begone() {
  sudo apt-get purge "$1"
}

# Docker activate buildkit
# export DOCKER_BUILDKIT=1

# Docker & Docker Compose alias
alias dc="docker compose"
function __dcrm() {
  docker compose stop $*
  wait
  echo "y" | dc rm $*
}

function __dcwipe(){
  if ! [[ -z `docker compose stop | grep 'ERRPR'` ]] ; then
    echo "y" | docker compose rm
    wait
    echo "y" | docker system prune -a
  else
    echo "Nothing to Remove"
  
  fi
}

function __dvipe(){
  echo "y" | docker volume prune -f
}

function __dwipe() {
  docker stop `docker ps -aq`
  wait
  echo "y" | docker system prune -a
  wait
  echo "y" | docker volume prune
  wait
  docker volume ls | awk '{print $2}' | xargs docker volume rm
  wait
}

function __dkill() {
  docker stop `docker ps -aq`
}

function __dprune() {
  echo "y" | docker system prune -a
  wait
  echo "y" | docker volume prune
  wait
  echo "y" | docker network prune -a

}

function __persist(){
# Fail if any commands fails
set -e


  FOLDER_PATH="/home/dle/DevWork/ti8m/cic/local-images/separate"
  OVERWRITE_ALL="n"

  for IMAGE in $( docker images --format '{{.Repository}}' --filter "dangling=false" ) ; do
      IMAGE_BASE_NAME=$(echo "$IMAGE" | xargs -I{} basename {} | sed -r 's/cmb-docker-//g')
      COMPLETE_IMAGE_PATH="${FOLDER_PATH}/${IMAGE_BASE_NAME}.tar.gz"

      if [[ -f "${COMPLETE_IMAGE_PATH}" ]] ; then
        if [ ! "$OVERWRITE_ALL" == "A" ] ; then
          echo -n "The image ${IMAGE_BASE_NAME} is already saved. Overwrite? (Y/n), Overwrite All (A) "
        fi
        while true ; do
          if [ "$OVERWRITE_ALL" == "A" ] ; then
            echo "saving $IMAGE_BASE_NAME"
            docker save "$IMAGE" | gzip > "${COMPLETE_IMAGE_PATH}"
            break
          fi
          # Read a single character from the input
          read -r -n 1 key
          # Check if the pressed key is 'q'
          if [[ "$key" == "y" || "$key" ==  "" ]] ; then
            echo -e "\n saving ${IMAGE_BASE_NAME}"
            docker save "$IMAGE" | gzip > "${COMPLETE_IMAGE_PATH}"
            break
          elif [ "$key" == "A" ]; then
            OVERWRITE_ALL="A"
            echo -e "\n Overwriting all images"
            echo "saving $IMAGE_BASE_NAME"
            docker save "$IMAGE" | gzip > "${COMPLETE_IMAGE_PATH}"
          else
            echo -e "\n Skipping image $IMAGE"
            break
          fi
        done
      else
        echo "saving $IMAGE_BASE_NAME"
      fi
  done
}

alias dsave='__persist'


function __loadImages(){
  for img in $( ls /home/dle/DevWork/ti8m/cic/local-images/separate ) ; do
	  echo "loading image $img"
	  docker load < "/home/dle/DevWork/ti8m/cic/local-images/separate/$img"
  done
}

alias dload='__loadImages'

# alias dcwipe='__dcwipe'
alias dcrm='__dcrm'

alias dwipe='__dwipe'
alias dprune='__dprune'
alias dkill='__dkill'
alias dvipe='__dvipe'

# Silence warnings
export NODE_NO_WARNINGS=1
function __nodeWipeInstall(){
  RED=`tput setaf 1`
  GREEN=`tput setaf 2`
  RESET=`tput sgr0`
  BOLD=$(tput bold)
  if [[ -f "${PWD}/package-lock.json" || -f "${PWD}/yarn.lock" || -f "${PWD}/pnpm-lock.yaml" ]]; then
    echo -e "${BOLD}${GREEN}*************** DELETING NODE_MODULES *******************${RESET}"
    find . -name "node_modules" -type d -prune -print -exec rm -rf "{}" \;
    wait

    if [[ -f "${PWD}/package-lock.json" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}************** clearning global npm cache' **************${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      npm cache clean --force
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*************** installing using 'npm ci' ***************${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      npm ci
    elif [[ -f "${PWD}/yarn.lock" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}************* clearning global yarn cache' **************${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      yarn cache clean
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*** installing using 'yarn install --frozen-lockfile' ***${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      yarn install --frozen-lockfile
    elif [[ -f "${PWD}/pnpm-lock.yaml" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}************* clearning global pnpm cache' **************${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      pnpm store prune
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*** installing using 'pnpm install --frozen-lockfile' ***${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      pnpm i --frozen-lockfile
    else
      echo -e "${BOLD}${RED}***********************************************************${RESET}"
      echo -e "${BOLD}${RED}****************** no lock file found *********************${RESET}"
      echo -e "${BOLD}${RED}*********** please run pnpm/npm/yarn install **************${RESET}"
      echo -e "${BOLD}${RED}***********************************************************${RESET}"
    fi
  else
    echo -e "${BOLD}${RED}***********************************************************${RESET}"
    echo -e "${BOLD}${RED}******* no lock file found in current directory ***********${RESET}"
    echo -e "${BOLD}${RED}******** are you sure you're in a project dir? ************${RESET}"
    echo -e "${BOLD}${RED}***********************************************************${RESET}"
  fi
}



function __nodeCleanInstall(){
  RED=`tput setaf 1`
  GREEN=`tput setaf 2`
  BLUE=`tput setaf 5`
  RESET=`tput sgr0`
  BOLD=$(tput bold)
  if [[ -f "${PWD}/package-lock.json" || -f "${PWD}/yarn.lock" || -f "${PWD}/pnpm-lock.yaml" ]]; then
    echo -e "${BOLD}${GREEN}*************** DELETING NODE_MODULES *******************${RESET}"
    find . -name "node_modules" -type d -prune -print -exec rm -rf "{}" \;

    wait
    if [[ -f "${PWD}/package-lock.json" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*************** installing using 'npm ci' ***************${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      npm ci
    elif [[ -f "${PWD}/yarn.lock" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*** installing using 'yarn install --frozen-lockfile' ***${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      yarn install --frozen-lockfile
    elif [[ -f "${PWD}/pnpm-lock.yaml" ]]; then
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      echo -e "${BOLD}${GREEN}*** installing using 'pnpm install --frozen-lockfile' ***${RESET}"
      echo -e "${BOLD}${GREEN}*********************************************************${RESET}"
      pnpm i --frozen-lockfile
    else
      echo -e "${BOLD}${RED}***********************************************************${RESET}"
      echo -e "${BOLD}${RED}****************** no lock file found *********************${RESET}"
      echo -e "${BOLD}${RED}*********** please run pnpm/npm/yarn install **************${RESET}"
      echo -e "${BOLD}${RED}***********************************************************${RESET}"
    fi
  else
    echo -e "${BOLD}${RED}***********************************************************${RESET}"
    echo -e "${BOLD}${RED}******* no lock file found in current directory ***********${RESET}"
    echo -e "${BOLD}${RED}******** are you sure you're in a project dir? ************${RESET}"
    echo -e "${BOLD}${RED}***********************************************************${RESET}"
  fi
}
alias nci="__nodeCleanInstall"
alias nwi="__nodeWipeInstall"
# pnpm alias
alias pn=pnpm
# CDK
alias cdkd="cdk deploy"
function __cdkill(){
  cdk rm
  wait
  dprune
}
alias cdkill="__cdkill"

function __cdkre(){
  cdk rm
  wait
  dprune
  wait
  cdk init
}
alias cdkcre="__cdkre"
function __cdkre(){
  cdk rm
  wait
  cdk init
}

alias cdkre="__cdkre"


# ranger exit in directory
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'


function __tns(){
  tmux new-session -s ${1}
}

function __tks(){
  tmux kill-session -t ${1}
}

function __tas(){
  tmux attach-session -t ${1}
}

function __tkill(){
  tmux kill-server
}


# tmux aliases
alias tns="__tns"
alias tks="__tks"
alias tas="__tas"
alias tkill="__tkill"
alias tls="tmux ls"

# Yarn
# alias node=nodejs

# MPV Alias to watch a video with mpv but detatch the process
function __mpvq() {
  mpv --really-quiet "$1" &
  disown
}
alias mpvq='__mpvq'

function __winrec(){
  recordmydesktop --fps 60 --windowid `xwininfo | grep 'id: 0x' | grep -Eo '0x[a-z0-9]+'`
}

# Alias to record a window
alias winrec="__winrec"

# Gradle Wrapper
alias gw='./gradlew'

# copy pwd to clip board
alias cpwd='pwd | tr -d "\n" | xclip -sel clip'

# copy my ip to clipboard
alias gimmehostip="hostname -I | cut -d' ' -f1 | xclip -sel clip"
alias gimmepublicip='curl ipinfo.io/ip | xclip -sel clip' 

# ranger exit in directory
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'

#####################################################
################ BEGIN  PATHS #######################
#####################################################

# SNAP
# export PATH="$PATH:/snap/bin"

# work aliases
# source ~/.aliases/.ti8m.sh
# source "/home/dle/DevWork/ti8m/cic/local-images/save-images.sh"

# local path
PATH="/home/dle/.local/bin:$PATH"
export PATH="/home/dle/DevTools/homebrew/bin:$PATH"
#####################################################
################ BEGIN  ENVS  #######################
#####################################################
source ~/.envs/.all.sh
#  export GTK_IM_MODULE="xim"

#####################################################
################ BEGIN  PROGS #######################
#####################################################



# Use Android cli
# export PATH="/home/dle/Android/Sdk/cmdline-tools/latest/bin:$PATH"
# source <(doctl completion zsh)
# eval $(~/.linuxbrew/bin/brew shellenv)

export PATH="$(yarn global bin):$PATH"
export JAVA_HOME=/home/dle/.sdkman/candidates/java/current/bin/java
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="$(which node)":$PATH
# export PATH="$HOME/DevTools/blackblaze:$PATH"

# export PATH="$HOME/DevTools/jetbrains/idea/idea-IU-213.6777.52/bin/idea.sh:$PATH"

alias rs="/home/dle/.config/regolith3/rs.sh"

alias files="nautilus . & disonw"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

export ANDROID_HOME="/home/dle/Android/Sdk"
# Use global yarn packages from cli
export PATH="`yarn global bin`:$PATH"
# Kill Forticlient
alias startforti="/home/dle/DevTools/forticlient-sctipts/restart-forticlient.sh"
alias stopforti="/home/dle/DevTools/forticlient-sctipts/stop-forticlient.sh"

export STARSHIP_CONFIG=/home/dle/.config/starship/starship.toml

eval "$(starship init zsh)"

# # bit
# export PATH="$PATH:/home/dle/bin"
# # bit end

export NODE_OPTIONS="--max_old_space_size=16384"
export TERM=xterm-256color
export ICAROOT="/home/dle/DevTools/citrix"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/dle/.sdkman"
[[ -s "/home/dle/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dle/.sdkman/bin/sdkman-init.sh"

# pnpm
export PNPM_HOME="/home/dle/.local/share/pnpm"intel
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


export WFICA_OPTS="-span o"