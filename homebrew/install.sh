# !/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Binaries
binaries=(
  dos2unix
  wget
  python
  ctags
  grc
  git-flow
  ssh-copy-id
  watch
  task
  mackup
  autojump
  autossh
  tmux
  reattach-to-user-namespace
  htop
  # tree
  # z
  # trash
  # mysql
  # nginx
  # node
  # mongodb
  # boot2docker
  # docker
  # grc
  # hub
  # legit
  # nvm

)

# Apps
apps=(
  # java
  google-chrome
  qq
  macdown  # markdown编辑器
  iterm2 # 加强版终端
  the-unarchiver  # 免费的解压软件
  xtrafinder  # 加强finder
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
brew install caskroom/cask/brew-cask
brew upgrade brew-cask

echo "Installing binaries..."
brew install ${binaries[@]}

# echo "Installing fonts..."
# brew cask install ${fonts[@]}

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "Installing apps..."
sudo brew cask install --appdir="/Applications" ${apps[@]}

# clean things up
brew cleanup
brew cask cleanup

exit 0
