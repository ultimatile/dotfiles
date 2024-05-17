if status is-interactive
    # Commands to run in interactive sessions can go here

    # Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    # Rye
    set -Ua fish_user_paths "$HOME/.rye/shims"
    
    # Python
    source ~/RyePython/.venv/bin/activate.fish

    # alias
    alias gpomn="git push origin main"
    alias gclnt="git clone ultimatile:ultimatile/LaTeXNoteTemplate.git"
    alias nv="nvim"
end

source /opt/homebrew/opt/modules/init/fish
module use /Users/$USER/modulefiles
set icloud "/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs"
source "$HOME/.cargo/env.fish"

#HOGE=fugaとしていました。これがset HOGE fugaに変わります。
#export HOGEはset -x HOGE $ HOGEとなります．
