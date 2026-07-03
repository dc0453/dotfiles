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
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"

install_homebrew () {
  # wiki -> https://mirrors.ustc.edu.cn/help/brew.git.html
  if ! command -v brew >/dev/null; then
    echo "Installing Homebrew for you..."
    # install from USTC mirror
    /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)"
    # install from GitHub
    #/bin/bash -c "$(curl -fsSL https://github.com/Homebrew/install/raw/master/install.sh)"
  else
    echo "Homebrew already installed, updating mirrors..."
  fi

  # 无论是否新装，均同步镜像源配置
  git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git
  # 仅处理 homebrew/core（cask 及其他 tap 已废弃，现代 Homebrew 通过 JSON API 管理）
  if brew tap 2>/dev/null | grep -q "^homebrew/core$"; then
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
  fi

  brew update-reset
}

declare -a not_installed_apps
filter_already_installed_apps() {
    for app in ${apps[@]}
    do
        appName=$(brew info $app --json=v2 | jq '.casks[].name[0]' -r)
        if ls /Applications | grep "$appName"
        then
            echo "$app has installed\n"
        else
            not_installed_apps+="$app "
        fi
    done
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
  #jenv
  jq
  mackup
  maven
  mysql
  node
  npm
  openjdk
  pyenv
  pyenv-virtualenv
  pipenv
  reattach-to-user-namespace
  ssh-copy-id
  the_silver_searcher
  thrift
  tlrc
  tmux
  tree
  vim
  webp
  watch
  wget
  tabiew
  snapx
  # sdkman 通过 sdkman/install.sh 单独安装，非 brew 公式
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
  postman
  sublime-text
  keycastr
  karabiner-elements
  # java
  # google-chrome
  # qq
  # macdown  # markdown编辑器
  iterm2 # 加强版终端
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

echo "Installing binaries..."
# snapx 来自第三方 tap，需要先 trust
brew trust brycensranch/repo 2>/dev/null || true
failed_binaries=()
for pkg in "${binaries[@]}"; do
  brew install "$pkg" || { echo "⚠️  failed to install binary: $pkg"; failed_binaries+=("$pkg"); }
done

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "Installing apps..."
filter_already_installed_apps
failed_apps=()
for app in ${not_installed_apps[@]}; do
  brew install --cask --appdir="/Applications" "$app" || { echo "⚠️  failed to install app: $app"; failed_apps+=("$app"); }
done

# 汇总失败项
if [[ ${#failed_binaries[@]} -gt 0 ]]; then
  echo "❌ Failed binaries: ${failed_binaries[*]}"
fi
if [[ ${#failed_apps[@]} -gt 0 ]]; then
  echo "❌ Failed apps: ${failed_apps[*]}"
fi

# clean things up
brew cleanup

exit 0
