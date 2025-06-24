# should be before Homebrew initialization
# this overrides aarch64 brew with x86_64 brew because fish_add_path prepends fish_user_paths to PATH
# Local Rust binaries
fish_add_path $HOME/.cargo-local/bin
fish_add_path $HOME/.local/bin

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# devbox
eval "$(devbox global shellenv)"

# modulefiles
source /opt/homebrew/opt/modules/init/fish
module use /Users/$USER/modulefiles

# Rust
source $HOME/.cargo/env.fish

atuin init --disable-up-arrow fish | source
# atuin init fish | source
starship init fish | source
# mcfly init fish | source
#fzf --fish | source

# paths
set icloud "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs"
set LOGSEQ_PAGES_ROOT "/Users/$USER/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/main/pages"
set AQC "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/AQC"
if status is-interactive
    # for glow
    set -gx EDITOR nvim
    # enable mouse and color support in less
    set -gx LESS --mouse -R
    # Commands to run in interactive sessions can go here

    # quiet greeting  
    set -g fish_greeting
    # aliases
    abbr -a sfc source $HOME/.config/fish/config.fish

    # git
    abbr -a g git
    abbr -a ga git add
    abbr -a gac git add .
    abbr -a gb git branch
    abbr -a gcl git clone
    abbr -a gclr git clone --recursive
    abbr -a gclnt git clone ultimatile:ultimatile/LaTeXNoteTemplate.git
    abbr -a gcltt git clone ultimatile:ultimatile/LaTeXTikZTemplate.git
    abbr -a gcltnt git clone ultimatile:ultimatile/TypstNoteTemplateJa.git
    abbr -a gcltst git clone ultimatile:ultimatile/TypstSlideTemplateJa.git
    abbr -a gcm git commit -m
    abbr -a gcam git commit -am
    abbr -a gamm git commit --amend -m
    abbr -a gd git diff
    abbr -a gdc git diff --cached
    abbr -a gdp git diff HEAD^ HEAD
    abbr -a gl git log --oneline --graph --all -n 15
    abbr -a gla git log --oneline --graph --all
    abbr -a gpl git pull
    abbr -a gps git push
    abbr -a gpod git push origin develop
    abbr -a gpom git push origin main
    abbr -a grhh git reset --hard HEAD
    abbr -a grsh git reset --soft HEAD
    abbr -a gst git status
    abbr -a gsts git status -s
    abbr -a gsw git switch
    abbr -a gswc git switch -c

    abbr -a lg lazygit

    # nvim
    abbr -a nv nvim
    abbr -a view nvim -R
    abbr -a nvcl nvim --clean
    abbr -a nvfc nvim $HOME/dotfiles/fish/config.fish
    abbr -a nvkey nvim $HOME/dotfiles/nvim/lua/config/keymaps.lua
    abbr -a nvauto nvim $HOME/dotfiles/nvim/lua/config/autocmds.lua
    abbr -a nvopt nvim $HOME/dotfiles/nvim/lua/config/options.lua
    abbr -a nvc nvim .

    # brew
    abbr -a br brew
    abbr -a brup brew upgrade
    abbr -a brst brew list

    # make
    abbr -a mk make
    abbr -a maek make
    abbr -a meak make
    abbr -a meka make
    abbr -a mkae make
    abbr -a mkea make

    # ls
    abbr -a sl ls
    abbr -a ks ls
    abbr -a l eza
    abbr -a ll eza
    abbr -a lss ls -ltrh

    abbr -a treee eza -T
    alias sed="gsed"
    alias head="ghead"
    abbr -a pbpc "pbpaste |tr -d '\n'| sed -e 's/\n/ /g' -e 's/\([.?!]\) /\1\n/g' -e 's/-\ //g' | pbcopy"
    abbr -a ff fastfetch
    abbr -a ffgd "fastfetch | grep Disk"
    abbr -a gp gnuplot
    alias cd="z"
    abbr -a zu cd ..
    abbr -a mkr makers
    abbr -a mkrm "makers --makefile \$MKFILE"
    abbr -a dac direnv allow .
    abbr -a dec direnv edit .
    abbr -a tcm typst compile main.typ

    # Rosetta terminal
    abbr -a z64 env /usr/bin/arch -x86_64 /bin/zsh --login
    abbr -a zarm env /usr/bin/arch -arm64 /bin/zsh --login

    abbr -a uvr uv run

    abbr -a rmv fd -HI .venv -td -X rm -r

    abbr -a gg ghq get git@github.com:ultimatile/
    abbr -a cggu cd ~/ghq/github.com/ultimatile

    abbr -a mkdd mkdir (date +"%Y%m%d")

    abbr -a dga devbox global add

    abbr -a ch choose --one-indexed

    abbr -a clc claude

end
zoxide init fish | source
direnv hook fish | source
