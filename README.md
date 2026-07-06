# dc0453's dotfiles

个人 Mac 开发环境配置，基于 [zoumo/dotfiles](https://github.com/zoumo/dotfiles) fork 修改。
执行一键安装脚本即可在新 Mac 上还原完整开发环境。

---

## 快速开始

### 1. 安装 Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. 克隆仓库

```bash
git clone --recurse-submodules https://github.com/dc0453/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. 执行安装

```bash
# 完整安装（推荐新电脑使用）
./script/bootstrap -a

# 只建 dotfiles 软链（.zshrc / .zprofile / .vimrc 等）
./script/bootstrap -d

# 只安装软件依赖（homebrew / tools / apps）
./script/bootstrap -b
```

---

## 安装内容

执行 `./script/bootstrap -a` 会依次完成以下步骤：

| 步骤 | 内容 |
|------|------|
| 1 | 切换默认 Shell 为 zsh |
| 2 | 建立所有 `*.symlink` 软链到 `$HOME`（.zshrc / .zprofile / .vimrc 等） |
| 3 | 安装 **Homebrew**（使用中科大镜像） |
| 4 | 安装 **binaries**（fzf / git-lfs / nvm / tmux 等） |
| 5 | 安装 **cask apps**（iTerm2 / Postman / Karabiner 等） |
| 6 | 安装 **oh-my-zsh** + 自定义主题和插件 |
| 7 | 安装 **beautify**（Powerline 字体 / Solarized 配色） |
| 8 | 安装 **Python 3**（pyenv 自动获取最新稳定版） |
| 9 | 安装 **sdkman** + **Java 8.0.482-kona** |
| 10 | 安装 **vim**（spf13-vim） |
| 11 | 安装 **tmux**（oh-my-tmux） |
| 12 | 配置 **iTerm2** 偏好目录 |
| 13 | 配置 **Karabiner** 按键映射 |
| 14 | 配置 **Hammerspoon** 自动化脚本 |
| 15 | 安装 **Java 17.0.15-amzn**（通过 sdkman） |

---

## 目录结构

```
~/.dotfiles/
├── bin/              # dot 安装编排脚本
├── script/           # bootstrap 入口脚本
├── homebrew/         # Homebrew 安装 & 镜像配置
├── zsh/              # zshrc / zprofile / oh-my-zsh 主题插件
├── beautify/         # Powerline 字体 / Solarized 配色
├── python/           # pyenv + Python 3 + pip 插件
├── sdkman/           # sdkman + Java 8.0.482-kona
├── java/             # 额外 Java 版本（17.0.15-amzn）
├── vim/              # spf13-vim 配置
├── tmux/             # oh-my-tmux 配置
├── iterm2/           # iTerm2 偏好设置
├── karabiner/        # Karabiner 按键映射
├── hammerspoon/      # Hammerspoon 自动化脚本
├── maven/            # Maven 配置（mavenrc.symlink）
├── system/           # PATH / 环境变量配置
└── osx/              # macOS 系统设置（默认关闭）
```

---

## 扩展新配置

按 topic 组织，新增一个工具只需：

1. 新建对应目录，如 `ruby/`
2. 需要安装的话，添加 `ruby/install.sh`
3. 在 `bin/dot` 里加一行 `sh $DOTFILES_ROOT/ruby/install.sh`
4. 需要软链的配置文件命名为 `*.symlink`，bootstrap 会自动处理

---

## 镜像源

Homebrew 使用 **中科大（USTC）** 镜像，适合国内网络环境：

```bash
HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
```

---

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
- [Holman's dotfiles](https://github.com/holman/dotfiles)
- [oh-my-zsh](https://ohmyz.sh/)
- [Homebrew USTC Mirror](https://mirrors.ustc.edu.cn/help/brew.git.html)
