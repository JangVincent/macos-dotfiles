# Install homebrew
echo "📦 Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Cask
echo "📦 Installing Fomulars and Casks Using homebrew"
brew 
brew install git gnupg bat fzf fd fnm eza go fastfetch uv ripgrep tree zoxide zsh-autosuggestions zsh-syntax-highlighting starship oven-sh/bun/bun neovim git-delta gemini-cli hashicorp/tap/terraform direnv tree-sitter-cli awscli
brew install --cask font-fira-code-nerd-font orbstack google-chrome raycast slack notion kitty beekeeper-studio karabiner-elements visual-studio-code yaak claude-code

# Set hushlogin
echo "📦 Setting hushlogin for terminal environment"
touch ~/.hushlogin

# Set Fnm and yarn before .zsh setting
echo "📦 Install NodeJS LTS and Yarn"
eval "$(fnm env --use-on-cd)"
fnm install lts/latest
npm install --global yarn pnpm

# Set .zshrc
echo "📦 Setting .zshrc"
touch ~/.zshrc

ZSH_CONTENT=$(cat << 'EOF'
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnm
eval "$(fnm env --use-on-cd)"

# Yarn
export PATH="$PATH:$(yarn global bin)"

# Pnpm
alias pn=pnpm

# open JDK
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# Go install path
export PATH="$HOME/go/bin:$PATH"

# Direnv
eval "$(direnv hook zsh)"


# =================custom alias====================
alias cat="bat"

alias ls="eza -al --icons=always --group-directories-first --color=always"
alias ld="eza -lD --icons=always --color=always"
alias lf="eza -lf --color=always --icons=always | grep -v /"
alias lh="eza -dl .* --icons=always --group-directories-first --color=always"
alias lS="eza -al --icons=always --sort=size --group-directories-first --color=always"
alias lt="eza -al --icons=always --sort=modified --group-directories-first --color=always"
alias ll="eza -al --icons=always --group-directories-first --color=always"
alias l="ll"

alias diff="delta"

eval "$(zoxide init zsh)"
alias cd="z"

# ===================fzf setting=======================
# git branch selection with fzf → checkout
fbr() {
  local branch
  branch=$(git branch --all | sed 's/^[* ]*//' | fzf --prompt="  " --height=40% --border) || return
  git checkout "$(echo "$branch" | sed 's#remotes/[^/]*/##')"
}

# git branch selection with fzf → detail preview
fshow() {
  git log --oneline --decorate |
    fzf --preview 'git show --color=always $(echo {} | cut -d" " -f1)' \
        --preview-window=down:60%:wrap
}

alias gitbranch=fbr
alias gitlog=fshow

# fzf + ripgrep + bat + nvim Integration Search
frg() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
  rg --line-number --no-heading --color=always "" "$root" |
    fzf --ansi \
        --delimiter : \
        --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
        --bind 'enter:execute(nvim +{2} {1}),ctrl-j:preview-down,ctrl-k:preview-up' \
        --preview-window=down:60%:wrap
}
# Ctrl+G = execute frg (zle wiget)
function frg-widget() {
  zle -I                # clear
  frg                   # execute function
  zle redisplay         # start draw prompt 
}
zle -N frg-widget
bindkey '^G' frg-widget

# Ctrl+P = find file with file name
ffile() {
  find . -type f \( ! -path '*/.git/*' \) |
    fzf --ansi \
        --preview 'bat --color=always --style=header,grid --line-range=:200 {}' \
        --bind "enter:execute(nvim '{}'),ctrl-j:preview-down,ctrl-k:preview-up" \
        --preview-window=down:60%:wrap
}

function ffile-widget() {
  zle -I
  ffile
  zle redisplay
}
zle -N ffile-widget
bindkey '^P' ffile-widget
# =========================================================


# OrbStack command-line tools
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# FZF
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"

fastfetch
EOF
)

echo "$ZSH_CONTENT" >> ~/.zshrc
source ~/.zshrc
echo "📦 Setting .zshrc Complete"

# ApplePressAndHoldEnabled for VSCode, Cursor
echo "📦 Setting VIM mode for vscode and cursor"
defaults write "$(osascript -e 'id of app "Cursor"')" ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false 

echo "📦 For Develop flutter, visit https://docs.flutter.dev/get-started/install/macos/mobile-ios"

echo "💫TIPS💫"
echo "↳ git log => gitlog"
echo "↳ git branch => gitbranch"
echo "↳ Ctrl + r => Find terminal history"
echo "↳ Ctrl + g => Find file with content of file"
echo "↳ Ctrl + p => Find file with file name"
echo "↳ Ctrl + t => Find file with file name"
echo "↳ In FZF : ctrl+j/k => preview scroll" 
echo "↳ In FZF : ctrl+n/p => preview search list" 
echo "✅ All cli setting is done. Let's hack!"
