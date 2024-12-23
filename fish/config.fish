# fish
source /opt/homebrew/opt/modules/init/fish
# should be before Homebrew initialization
# this overrides aarch64 brew with x86_64 brew because fish_add_path prepends fish_user_paths to PATH
fish_add_path $HOME/.cargo-local/bin
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
# modulefiles
module use /Users/$USER/modulefiles

# Rust
source $HOME/.cargo/env.fish
## Local Rust binaries
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
if status is-interactive
    # Commands to run in interactive sessions can go here

    # quiet greeting  
    set -g fish_greeting
    # aliases
    abbr -a sfc source $HOME/.config/fish/config.fish

    # git
    #abbr -a g "git"
    abbr -a g git
    abbr -a ga git add
    abbr -a gac git add .
    abbr -a gpom git push origin main
    abbr -a gpod git push origin develop
    abbr -a gclnt git clone ultimatile:ultimatile/LaTeXNoteTemplate.git
    abbr -a gcltt git clone ultimatile:ultimatile/LaTeXTikZTemplate.git
    abbr -a gpl git pull
    abbr -a gst git status
    abbr -a gsw git switch
    abbr -a gswc git switch -c
    abbr -a gcm git commit -m
    abbr -a gcam git commit -am
    abbr -a gamm git commit --amend -m

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

    abbr -a treee eza -T
    alias sed="gsed"
    alias head="ghead"
    abbr -a pbpc pbpaste | sed -e 's/\([.?!]\) /\1\n/g' -e 's/-\ //g' | pbcopy
    abbr -a ccat pygmentize -g
    abbr -a ff fastfetch
    abbr -a ffgd ff | grep Disk
    abbr -a gp gnuplot
    alias cd="z"

    # Rosetta terminal
    abbr -a zintel env /usr/bin/arch -x86_64 /bin/zsh --login
    abbr -a zarm env /usr/bin/arch -arm64 /bin/zsh --login
end
