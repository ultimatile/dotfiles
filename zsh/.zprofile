# Keep the interactive tool environment available to login-shell consumers such as Codex.
typeset -U path PATH
path=(
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/Applications/Obsidian.app/Contents/MacOS"
  "$HOME/.julia/bin"
  "$HOME/.lmstudio/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo-local/bin"
  "$HOME/.nix-profile/bin"
  "/nix/var/nix/profiles/default/bin"
  "/opt/homebrew/opt/mise/bin"
  $path
)
export PATH

# Use Homebrew's stable entry point so module upgrades do not pin a Cellar version here.
source /opt/homebrew/opt/modules/init/zsh
module use /Users/$USER/modulefiles
icloud="/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs"
