# !/bin/bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
    IS_MAC_OS=true
fi

#init environment variables
if [[ "$(uname -s)" == "Linux" ]]; then BREW_TYPE="linuxbrew"; else BREW_TYPE="homebrew"; fi
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/${BREW_TYPE}-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/${BREW_TYPE}-bottles"

install_homebrew () {
  # wiki -> https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
  # can support linuxbrew and homebrew
  if test ! $(which brew)
  then
    echo "Installing Homebrew for you..."
    # install from tsinghua mirror
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
    /bin/bash brew-install/install.sh
    rm -rf brew-install

    # install from GitHub
    #/bin/bash -c "$(curl -fsSL https://github.com/Homebrew/install/raw/master/install.sh)"
  else 
    git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    if [[ "$IS_MAC_OS" == true ]]; then
      #homebrew
      BREW_TAPS="$(BREW_TAPS="$(brew tap 2>/dev/null)"; echo -n "${BREW_TAPS//$'\n'/:}")"
      for tap in core cask{,-fonts,-drivers,-versions} command-not-found; do
          if [[ ":${BREW_TAPS}:" == *":homebrew/${tap}:"* ]]; then
              # 将已有 tap 的上游设置为本镜像并设置 auto update
              # 注：原 auto update 只针对托管在 GitHub 上的上游有效
              git -C "$(brew --repo homebrew/${tap})" remote set-url origin "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git"
              git -C "$(brew --repo homebrew/${tap})" config homebrew.forceautoupdate true
          else   # 在 tap 缺失时自动安装（如不需要请删除此行和下面一行）
              brew tap --force-auto-update "homebrew/${tap}" "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git"
          fi
      done
    else
      #linuxbrew
      git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/linuxbrew-core.git
      git -C "$(brew --repo homebrew/command-not-found)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-command-not-found.git
    fi

    # Install GCM Core using Homebrew
    # see more : https://docs.github.com/en/get-started/getting-started-with-git/caching-your-github-credentials-in-git
    brew tap microsoft/git

    brew update-reset
  fi
}

echo "installing homebrew"
install_homebrew
echo "install homebrew done"

# Binaries
binaries=(
  ack
  autojump
  autossh
  ctags
  dos2unix
  fzf
  graphviz
  htop
  jenv
  jq
  mackup
  maven
  mysql
  node
  openjdk
  pyenv
  reattach-to-user-namespace
  ssh-copy-id
  the_silver_searcher
  thrift
  tldr
  tmux
  tree
  vim
  webp
  watch
  wget
  # graphviz
  # z
  # trash
  # nginx
  # node
  # mongodb
  # boot2docker
  # docker
  # grc
  # hub
  # legit
  # nvm
  # task
)

# Apps
apps=(
  adoptopenjdk8
  postman
  sublime-text
  git-credential-manager-core
  keycastr
  karabiner-elements
  # java
  # google-chrome
  # qq
  # macdown  # markdown编辑器
  # iterm2 # 加强版终端
  # iina
  # the-unarchiver  # 免费的解压软件
  # xtrafinder  # 加强finder
  # scroll-reverser  # 可以分别鼠标和触控板滚动方向
  # goagentx  # FQ
  # slate  # 开源免费的桌面窗口控制调整工具
  # qlcolorcode
  # qlmarkdown
  # qlstephen
  # beyond-compare  # 优秀的文件比较软件
  # sequel-pro  # mysql客户端
  # clipmenu  # 粘贴版扩展 0.4.3
  # sourcetree  # git 管理
  # movist  # 播放器
  # lingon-x # 启动项管理
  # appzapper  # app卸载器
  # mou
  # alfred
  # dash
  # evernote
  # flux
  # keka
  # kitematic
  # obs
  # recordit
  # slack
  # steam
  # sublime-text3
  # todoist
  # virtualbox
  # vlc
)

# Fonts
# fonts=(
#   font-roboto
#   font-source-code-pro
# )

echo "Update Homebrew..."
# Update homebrew recipes
# brew update

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils
# Install Bash 4
#brew install bash
# Install Homebrew Cask
# brew tap caskroom/fonts
# brew tap caskroom/versions
# brew install caskroom/cask/brew-cask
# brew upgrade brew-cask

echo "Installing binaries..."
brew install ${binaries[@]}

# echo "Installing fonts..."
# brew cask install ${fonts[@]}

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "Installing apps..."
brew install --cask --appdir="/Applications" ${apps[@]}

# clean things up
brew cleanup

exit 0
