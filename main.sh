#!/bin/bash

set -eo pipefail

PROGNAME="./shell_up.sh"
VERSION="0.1.0"

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

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  local error_message="$1"
  printf "%s: %s\n" \
    "${error_message:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit() {
  echo -e "\n\n**** ${COLOR_CYAN}BASH DONE!${COLOR_END} ****\n"
  clean_up
  exit
}

usage() {
  printf "%s\n%s\n" \
    "Usage: ${PROGNAME} [-h|--help ]" \
    "       ${PROGNAME} init_user" \
    "       ${PROGNAME} init_shell"
}

help_message() {
  cat <<- _EOF_
${PROGNAME} ${VERSION}
Python script generator.

$(usage)

  Options:

  -h, --help    Display this help message and exit.
  init          init all steps

_EOF_
}

center() {
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

# ====== Main ======


init() {
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

  [[ -f /etc/issue ]] && OS_TYPE="$(cat /etc/issue)" || OS_TYPE=$(uname)

  if [[ "$OS_TYPE" == *"Debian"* ]] || [[ "$OS_TYPE" == *"Ubuntu"* ]]; then
    init_user_ubun
  elif [[ "$OS_TYPE" == *"Arch"* ]]; then
    init_user_arch
  elif [[ "$OS_TYPE" == *"Darwin"* ]]; then
    init_user_mac
  else
    init_user_ubun
  fi

  center "INIT dotfiles"

  cd /home/"$USER" && \
    dotup && \
    install_node && \
    install_go

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
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "INIT USER -- UBUNTU LINUX" "$(printf "%0.1s" ={1..20})"
  apt update && apt install -y sudo curl zip wget tmux git zsh manpages-dev build-essential
  # Install ripgrep
  TEMP_DEB="$(mktemp)" && \
    wget -O "$TEMP_DEB" 'https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb' && \
    dpkg -i "$TEMP_DEB" && \
    rm -f "$TEMP_DEB"
  # Install exa
  curl https://sh.rustup.rs -sSf | sh
  wget -c https://github.com/ogham/exa/releases/download/v0.8.0/exa-linux-x86_64-0.8.0.zip
  unzip exa-linux-x86_64-0.8.0.zip
  mv exa-linux-x86_64 /usr/local/bin/exa
  # Install python
  if [[ ! $(command -v python3.8) || ! $(command -v python3) ]]; then
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
  # Set user shell
  if [[ "$NEW" == "Y" ]]; then
    useradd -m -s "$(command -v zsh)" -g sudo "$USER"
    passwd "$USER"
  else
    usermod -s "$(command -v zsh)" -aG sudo "$USER"
  fi
}

init_user_mac() {
  printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "INIT USER -- MAC DARWIN" "$(printf "%0.1s" ={1..20})"
  # ripgrep
  # exa
  # python
  # zsh shell
}

dotup() {
  sudo -i -u "$USER" bash << EOF
set -eo pipefail

git clone https://github.com/Oceanbao/dots.git

# Fix up pip and venv
python -m pip install pip || true
python -m venv ~/envPY
source ~/envPY/bin/activate
pip install -U pip
pip install pynvim

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
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NEOVIM..." "$(printf "%0.1s" ={1..20})"

curl -LO https://github.com/neovim/neovim/releases/download/v0.5.1/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo rm -rf /squashfs-root
sudo rm -rf /usr/bin/nvim
sudo mv squashfs-root / && sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

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


dotup_base() {
  sudo -i -u "$USER" bash << EOF
set -eo pipefail

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
ln -sfn ~/dots/zshrc ~/.zshrc

# git
ln -sfn ~/dots/gitconfig ~/.gitconfig

# tmux
ln -sfn ~/dots/tmux.conf ~/.tmux.conf

# fzf
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

EOF
}


install_node() {
  sudo -i -u "$USER" bash << EOF
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing NVM/NODE..." "$(printf "%0.1s" ={1..20})"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR=~/.nvm
. ~/.nvm/nvm.sh
nvm install v14.16.1

EOF
}

install_go() {
  sudo -i -u "$USER" bash << EOF
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Installing GO..." "$(printf "%0.1s" ={1..20})"

wget https://go.dev/dl/go1.17.3.linux-amd64.tar.gz -O go1173.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1173.tar.gz
rm -rf go1173.tar.gz

EOF
}


post() {
printf "%s\n%s\n%s\n" "$(printf "%0.1s" ={1..20})" "Post INIT Setup..." "$(printf "%0.1s" ={1..20})"

# neovim
npm install -g neovim

# LSP Install
npm install -g pyright
npm install -g bash-language-server
npm install -g typescript typescript-language-server
npm install -g diagnostic-languageserver
npm install -g eslint_d prettier
npm install -g tree-sitter-cli
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
chmod +x ~/.local/bin/rust-analyzer

# Finally, nvim INIT
#nvim '+PlugInstall | qa'

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
      ;;
    init)
      init
      ;;
    post)
      post
      ;;
    *)
      error_exit "Unknown option $1";
      ;;
  esac
  graceful_exit;
  # shift
done
