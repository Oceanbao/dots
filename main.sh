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

PROGNAME="${0##*/}"
VERSION="0.1.1"
LIBS= # Insert pathnames of any required external shell libraries

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
    "${error_message:-"Unknown Error"}" >&2
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
  printf "%s\n" "       ${PROGRAMME} {post}"
}

help_message() {
  cat <<- _EOF_
$PROGNAME ver. $VERSION
Ghostinshell - Initialising Shell for ghost Ocean.

$(usage)

  Options:
  -h, --help    Display this help message and exit.
  init          Create user and install basics.
  brew          Install Linuxbrew.
  dotup         Install dots.
  post          Install node, nvim plugins, go

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
  read NEW

  if [[ "$NEW" == "Y" ]]; then
    printf "ENTER <USER>: \n"
    read USER
  elif [[ "$NEW" == "N" ]]; then
    printf "ENTER <USER>: \n"
    read USER
  fi

  OS_TYPE="$(cat /etc/issue)"

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
  pacman -Syu && yes | pacman -S sudo curl wget tmux exa git zsh ripgrep man-db man-pages || true
  # Install python3
  yes | pacman -S python python-pip python-setuptools || true
  if [[ "$NEW" == "Y" ]]; then
    useradd -m -s "$(command -v zsh)" -g wheel "$USER"
    passwd "$USER"
    sed -i -e 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
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

  # Install Rust
  curl https://sh.rustup.rs -sSf | sh
}

install_dots() {
  sudo -i -u "$USER" bash <<'EOF'
set -eo pipefail

# Fix up pip and venv
rm -rf ~/envPY
python -m venv ~/envPY
source ~/envPY/bin/activate
pip install -Uq pip
pip install -q pynvim

rm -rf ~/dots
git clone https://github.com/Oceanbao/dots.git

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

# neovim
sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
ln -sfn ~/dots/init.vim ~/.config/nvim/init.vim
ln -sfn ~/dots/plug.vim ~/.config/nvim/plug.vim
ln -sfn ~/dots/maps.vim ~/.config/nvim/maps.vim

rm -rf ~/.config/nvim/after
mkdir -p ~/.config/nvim/after/plugin
ln -sfn ~/dots/after/plugin/lexima.rc.vim ~/.config/nvim/after/plugin/lexima.rc.vim
ln -sfn ~/dots/after/plugin/lsp-colors.rc.vim ~/.config/nvim/after/plugin/lsp-colors.rc.vim
ln -sfn ~/dots/after/plugin/fugitive.rc.vim ~/.config/nvim/after/plugin/fugitive.rc.vim
ln -sfn ~/dots/after/plugin/web-devicons.rc.vim ~/.config/nvim/after/plugin/web-devicons.rc.vim
ln -sfn ~/dots/after/plugin/lspsaga.rc.vim ~/.config/nvim/after/plugin/lspsaga.rc.vim
ln -sfn ~/dots/after/plugin/completion.rc.vim ~/.config/nvim/after/plugin/completion.rc.vim
ln -sfn ~/dots/after/plugin/telescope.rc.vim ~/.config/nvim/after/plugin/telescope.rc.vim
ln -sfn ~/dots/after/plugin/treesitter.rc.vim ~/.config/nvim/after/plugin/treesitter.rc.vim
ln -sfn ~/dots/after/plugin/lualine.rc.lua ~/.config/nvim/after/plugin/lualine.rc.lua
ln -sfn ~/dots/after/plugin/tabline.rc.vim ~/.config/nvim/after/plugin/tabline.rc.vim
ln -sfn ~/dots/after/plugin/defx.rc.vim ~/.config/nvim/after/plugin/defx.rc.vim
ln -sfn ~/dots/after/plugin/lspconfig.rc.vim ~/.config/nvim/after/plugin/lspconfig.rc.vim

# custom lua scripts
cp -r ~/dots/lua ~/.config/nvim/.

mkdir ~/.config/nvim/themes
ln -sfn ~/dots/onedark.vim ~/.config/nvim/themes/onedark.vim
ln -sfn ~/dots/jellybeans.vim ~/.config/nvim/themes/jellybeans.vim
ln -sfn ~/dots/molokai.vim ~/.config/nvim/themes/molokai.vim

ln -sfn ~/dots/vimrc.lightline ~/.vimrc.lightline

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
}

install_python_brew() {
  sudo -i -u "$USER" bash <<'EOF'
# Assume zsh installed and run as main user
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install python@3.9
sudo ln -sfn $(command -v python3) /usr/bin/python
sudo ln -sfn $(command -v pip3) /usr/bin/pip
EOF
}

install_neovim() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NEOVIM..." "$(printf "%0.1s" ={1..20})"
brew install neovim
EOF
}

install_python_apt() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing OMZ..." "$(printf "%0.1s" ={1..20})"

if [[ ! $(command -v python3.8) || ! $(command -v python3) ]]; then
  # Case: No python3.8 nor python3 found
  apt install -y software-properties-common python3-pip
  EXIT_CODE=0
  add-apt-repository ppa:deadsnakes/ppa
  apt install -y python3.8 python3.8-venv || EXIT_CODE=$!
  if (( $EXIT_CODE != 0 )); then
    EXIT_CODE=0
    apt install -y python3 python3-pip python3-venv libssl-dev libffi-dev python3-dev || EXIT_CODE=$!
    if (( $EXIT_CODE != 0 )); then
      exit 1
    fi
  fi
  ln -sfn $(command -v python3.8) /usr/bin/python || ln -sfn $(command -v python3) /usr/bin/python
fi
EOF
}

install_node() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NVM/NODE..." "$(printf "%0.1s" ={1..20})"

brew install nvm
nvm install --lts
EOF
}

install_go() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing GO..." "$(printf "%0.1s" ={1..20})"

  wget https://go.dev/dl/go1.18.linux-amd64.tar.gz -O go118.tar.gz
  sudo rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go118.tar.gz
  rm -rf go118.tar.gz
}

install_nvim_plugins() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Install NVIM PLUGINS..." "$(printf "%0.1s" ={1..20})"

  # neovim
  npm install -g neovim

  # LSP Install
  npm install -g pyright
  npm install -g bash-language-server
  npm install -g typescript typescript-language-server
  npm install -g diagnostic-languageserver
  npm install -g eslint_d prettier
  npm install -g tree-sitter-cli
  [[ -d ~/.local/bin ]] || mkdir ~/.local/bin
  curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
  chmod +x ~/.local/bin/rust-analyzer

  # Finally, nvim INIT
  #nvim '+PlugInstall | qa'
}

install_cli() {
  sudo -i -u "$USER" bash <<'EOF'
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NVM/NODE..." "$(printf "%0.1s" ={1..20})"

brew install exa
brew install ripgrep
brew install duf
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
      printf "ENTER <USER>: \n"
      read USER
      install_python_brew
      install_neovim
      install_dots
      ;;
    post)
      install_node
      install_nvim_plugins
      install_go
      install_cli
      ;;
    *)
      error_exit "Unknown option $1";
      ;;
  esac
  shift
done
