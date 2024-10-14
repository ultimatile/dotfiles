if status is-interactive
    # Commands to run in interactive sessions can go here

    # quiet greeting  
    set -g fish_greeting
    # alias
    alias sfc="source $HOME/.config/fish/config.fish"

    # git
    alias g="git"
    alias gpomn="git push origin main"
    alias gclnt="git clone ultimatile:ultimatile/LaTeXNoteTemplate.git"
    alias gcltt="git clone ultimatile:ultimatile/LaTeXTikZTemplate.git"

    # nvim
    alias nv="nvim"
    alias view="nvim -R"
    alias nvfc="nv $HOME/dotfiles/fish/config.fish"

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

# Rye
# set -ga fish_user_paths "$HOME/.rye/shims"
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
# Python
#source $HOME/defaultpy/.venv/bin/activate.fish
source /opt/homebrew/opt/modules/init/fish
module use /Users/$USER/modulefiles
set icloud "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs"
set LOGSEQ_PAGES_ROOT "/Users/$USER/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/main/pages"
set AQC "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/AQC"
source "$HOME/.cargo/env.fish"
# mcfly init fish | source
atuin init --disable-up-arrow fish | source
# atuin init fish | source
zoxide init fish | source
# for glow
set -gx EDITOR nvim
#fzf --fish | source
#HOGE=fugaとしていました。これがset HOGE fugaに変わります。
#export HOGEはset -x HOGE $ HOGEとなります．
