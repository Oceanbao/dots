#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Ghostinshell - Initialising Shell for ghost Ocean.

# Copyright 2022, Ocean Bao <baobaobiz@gmail.com>

# Usage: demo [-h|--help]
#        demo [-a]

# Revision history:
# 2022-03-01 Created by new_script.bash ver. 3.5.2
# ---------------------------------------------------------------------------

set -eo pipefail

PROGRAMME="${0##*/}"
VERSION="0.1.1"
LIBS= # Insert pathnames of any required external shell libraries
OS_TYPE="$(cat /etc/issue)"


# ------------- Colors -------------
 
COLOR_RED="\033[0;31m"
COLOR_RED_LIGHT="\033[1;31m"

COLOR_GREEN="\033[0;32m"
COLOR_GREEN_LIGHT="\033[1;32m"

COLOR_ORANGE="\033[0;33m"
COLOR_YELLOW="\033[1;33m"
 
COLOR_BLUE="\033[0;34m"
COLOR_BLUE_LIGHT="\033[1;34m"

COLOR_PURPLE="\033[0;35m"
COLOR_PURPLE_LIGHT="\033[1;35m"

COLOR_CYAN="\033[0;36m" 
COLOR_CYAN_LIGHT="\033[1;36m"

COLOR_GRAY="\033[1;30m"
COLOR_GRAY_LIGHT="\033[0;37m"

COLOR_BLACK="\033[0;30m"
COLOR_WHITE="\033[1;37m"

COLOR_END="\033[0m"

# ------------- Utils --------------

pretty_print() {
  echo -e "\n\n**** ${COLOR_CYAN}$1${COLOR_END} ****\n"
}

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  local error_message="$1"
  printf "%s: %s\n" \
    "${error_message}" "Unknown Error" >&2
  clean_up
  pretty_print "Error Exit"
  exit 1
}

graceful_exit() {
  pretty_print "Gracefully Exit"
  clean_up
  exit
}

usage() {
  printf "%s\n" "Usage: ${PROGRAMME} {-h|--help}"
  printf "%s\n" "       ${PROGRAMME} {init}"
  printf "%s\n" "       ${PROGRAMME} {brew}"
  printf "%s\n" "       ${PROGRAMME} {dotup}"
}

help_message() {
  cat <<- _EOF_
$PROGRAMME ver. $VERSION
Ghostinshell - Initialising Shell for ghost Ocean.

$(usage)

  Options:
  -h, --help    Display this help message and exit.
  init          Create user and install basics (as root)
  brew          Install Linuxbrew (as USER).
  dotup         Install dots (as USER).

  NOTE: superuser is required to run this script.

_EOF_
 return
}

center() {
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

# ====== Main ======


init() {
  # Main process - initialise shell with all steps.
  center "INIT user"

  printf "CREATE NEW USER? <Y/N>\n"
  read -r NEW

  if [[ "$NEW" == "Y" ]]; then
    printf "ENTER <USER>: \n"
    read -r USER
  elif [[ "$NEW" == "N" ]]; then
    printf "ENTER <USER>: \n"
    read -r USER
  fi

  # Ascertain Linux distro
  if [[ "$OS_TYPE" == *"Debian"* ]] || [[ "$OS_TYPE" == *"Ubuntu"* ]] || [[ "$OS_TYPE" == *"Pop"* ]]; then
    init_user_ubun
  elif [[ "$OS_TYPE" == *"Arch"* ]]; then
    init_user_arch
  else
    error_exit "Only [debian, ubuntu, arch] supported."
  fi

  pretty_print "Init Done"
}

init_user_arch() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "INIT USER -- ARCH LINUX" "$(printf "%0.1s" ={1..20})"
  pacman -Syu
  pacman -S --noconfirm base-devel gcc sudo curl wget tmux exa git zsh ripgrep man-db man-pages || true
  # Install python3
  pacman -S --noconfirm python python-pip python-setuptools || true
  if [[ "$NEW" == "Y" ]]; then
    useradd -m -s "$(command -v zsh)" -g wheel "$USER"
    passwd "$USER"
    sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    sed -i -e 's/# %sudo ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) ALL/' /etc/sudoers
  fi
}

init_user_ubun() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "INIT USER -- UBUNTU/DEBIAN LINUX" "$(printf "%0.1s" ={1..20})"

  # Essential OS installation
  apt update && apt install -y \
                    sudo \
                    curl \
                    zip \
                    wget \
                    tmux \
                    procps \
                    file \
                    git \
                    zsh \
                    manpages-dev \
                    build-essential

  # Create user
  if [[ "$NEW" == "Y" ]]; then
    useradd -m -s "$(command -v zsh)" -g sudo "$USER"
    passwd "$USER"
  else
    usermod -s "$(command -v zsh)" -aG sudo "$USER"
  fi

}

install_dots() {
  sudo -i -u "$USER" bash <<'EOF'
set -eo pipefail

# OMZ
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing OMZ..." "$(printf "%0.1s" ={1..20})"

rm -rf ~/.oh-my-zsh
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# powerline10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
rm -rf ~/.zshrc
ln -sfn ~/dots/zshrc ~/.zshrc

# git
rm -rf ~/.gitconfig
ln -sfn ~/dots/gitconfig ~/.gitconfig

# tmux
rm -rf ~/.tmux.conf
ln -sfn ~/dots/tmux.conf ~/.tmux.conf

# fzf
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

EOF
}

# --------------- Unit Installers ---------------

install_homebrew() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing HOMEBREW..." "$(printf "%0.1s" ={1..20})"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Assume zsh installed and run as main user
  echo "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

install_rust() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing RUST..." "$(printf "%0.1s" ={1..20})"

curl https://sh.rustup.rs -sSf | sh

EOF
}

install_python() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing PYTHON..." "$(printf "%0.1s" ={1..20})"

brew install python@3.9
sudo ln -sfn $(command -v python3) /usr/bin/python
sudo ln -sfn $(command -v pip3) /usr/bin/pip

EOF
}

install_neovim() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NEOVIM..." "$(printf "%0.1s" ={1..20})"
brew install neovim

# LunarVim
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

EOF
}

install_lunarvim_config() {
  sudo -i -u "$USER" bash <<'EOF'
sudo ln -sfn ~/dots/config.lua ~/.config/lvim/config.lua 

EOF
}

install_node() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NVM/NODE..." "$(printf "%0.1s" ={1..20})"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR=~/.nvm
. ~/.nvm/nvm.sh
nvm install --lts

EOF
}

install_go() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing GO..." "$(printf "%0.1s" ={1..20})"

local file="go1183.tar.gz"
wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz -O "$file"
sudo rm -rf /usr/local/go && \
  sudo tar -C /usr/local -xzf "$file"
rm -rf "$file"

EOF
}

install_cli() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing CLI..." "$(printf "%0.1s" ={1..20})"

brew install exa
brew install ripgrep
brew install duf
brew install bat
brew tap tgotwig/linux-dust && brew install dust

EOF
}

# ------------- Parse CLI ---------------

echo -e "\n**** ${COLOR_RED}BASH BEGIN${COLOR_END} ****\n"

# Exit upon no ARG
[[ $# -eq 0 ]] && help_message && graceful_exit

# MAIN
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message
      graceful_exit
      ;;
    init)
      init
      ;;
    brew)
      install_homebrew
      ;;
    dotup)
      [[ "$OS_TYPE" == *"Arch"* ]] || install_python
      install_dots
      install_node
      install_rust
      [[ "$OS_TYPE" == *"Arch"* ]] || install_go
      install_cli
      ;;
    vim)
      install_neovim
      install_lunarvim_config
      ;;
    *)
      error_exit "Unknown option $1";
      ;;
  esac
  shift
done
