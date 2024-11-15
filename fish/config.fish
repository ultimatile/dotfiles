if status is-interactive
    # Commands to run in interactive sessions can go here

    # quiet greeting  
    set -g fish_greeting
    # alias
    alias sfc="source $HOME/.config/fish/config.fish"

    # git
    alias g="git"
    alias ga="git add"
    alias gpom="git push origin main"
    alias gpod="git push origin develop"
    alias gclnt="git clone ultimatile:ultimatile/LaTeXNoteTemplate.git"
    alias gcltt="git clone ultimatile:ultimatile/LaTeXTikZTemplate.git"
    alias gpl="git pull"
    alias gst="git status"
    alias gsw="git switch"
    alias gcm="git commit -m"
    alias gcam="git commit -am"
    alias gamm="git commit --amend -m"

    # nvim
    alias nv="nvim"
    alias view="nvim -R"
    alias nvfc="nv $HOME/dotfiles/fish/config.fish"
    alias nvkey="nv $HOME/dotfiles/nvim/lua/config/keymaps.lua"
    alias nvc="nv ."

    # brew
    alias br="brew"
    alias brup="brew upgrade"
    alias brst="brew list"

    # make
    alias maek="make"
    alias meak="make"
    alias meka="make"
    alias mkae="make"
    alias mkea="make"

    # ls
    alias sl="ls"
    alias ks="ls"
    alias l="ls"
    alias ll="eza"

    alias treee="eza -T"
    alias sed="gsed"
    alias head="ghead"
    alias pbpc="pbpaste | sed -e 's/\([.?!]\) /\1\n/g' -e 's/-\ //g'|pbcopy"
    alias ccat="pygmentize -g"
    alias ff="fastfetch"
    alias ffgd="ff |grep Disk"
    alias gp="gnuplot"

    # Rosetta terminal
    alias zarm="env /usr/bin/arch -arm64 /bin/zsh --login"
    alias zintel="env /usr/bin/arch -x86_64 /bin/zsh --login"
end

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fish
source /opt/homebrew/opt/modules/init/fish

# modulefiles
module use /Users/$USER/modulefiles

# Rust
source "$HOME/.cargo/env.fish"

atuin init --disable-up-arrow fish | source
# atuin init fish | source
zoxide init fish | source
starship init fish | source
# mcfly init fish | source
#fzf --fish | source

# for glow
set -gx EDITOR nvim

# for nix --help
set -gx NIX_PAGER "less --mouse"

# paths
set icloud "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs"
set LOGSEQ_PAGES_ROOT "/Users/$USER/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/main/pages"
set AQC "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/AQC"
