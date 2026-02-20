# dotfiles

ln -s $HOME/{dotfiles,.config}/fish/completions
![](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)
![](https://img.shields.io/badge/Shell-Fish-34C534)

## Aerospace

```sh:
ln -s $HOME/dotfiles,.config}/aerospace/aerospace.toml
```

## Atuin

```sh:
ln -s $HOME/{dotfiles,.config}/atuin/config.toml
```

## Claude

```sh:
ln -s $HOME/{dotfiles/,}.claude/commands
ln -s $HOME/{dotfiles/,}.claude/CLAUDE.md
ln -s $HOME/{dotfiles/,}.claude/settings.json
```

## Direnv

```sh:
ln -s $HOME/{dotfiles,.config}/direnv/direnvrc
```

## Fancy-cat

```sh:
ln -s $HOME/{dotfiles,.config}/fancy-cat/config.json
```

## Fish

```sh:
ln -s $HOME/{dotfiles,.config}/fish/config.fish
ln -s $HOME/{dotfiles,.config}/fish/functions
ln -s $HOME/{dotfiles,.config}/fish/completions
```

## Ghostty

```sh:
ln -s $HOME/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
cp $HOME/dotfiles/ghostty/machine-specific ~/Library/Application\ Support/com.mitchellh.ghostty/
```

## Git

Add the following to your `.gitconfig` file:

```ini:
[include]
  path = /path/to/dotfiles/git/.gitconfig
```

## Glow

```sh:
ln -s $HOME/{dotfiles/,Library/Preferences/glow/}glow.yml
```

## Gnuplot

```sh:
ln -s $HOME/{dotfiles/,}.gnuplot
```

## Gwq

```sh:
ln -s $HOME/{dotfiles,.config}/gwq/config.toml
```

## Hammerspoon

requirement: swpunc

```sh:
ln -s $HOME/{dotfiles/,.}hammerspoon/init.lua
```

## Home Manager

```sh
ln -sfn $HOME/{dotfiles,.config}/home-manager
cp -n $HOME/dotfiles/home-manager/machine-specific{.example,}.nix
```

```sh
nix run github:nix-community/home-manager -- switch --flake "path:$HOME/dotfiles/home-manager#ultimatile"
```

```sh
$HOME/dotfiles/home-manager/bin/hm-switch
```

## HPC (Personal Project)

```sh:
ln -s $HOME/{dotfiles,.config}/hpc/config.toml
```

## JuliaPkgTemplatesCLI (Personal Project)

```sh:
ln -s $HOME/{dotfiles,.config}/jtc/config.toml
```

## Karabiner-Elements

```sh
ln -s $HOME/{dotfiles/karabiner/complex_modifications,.config/karabiner/assets}
```

## Lazygit

```sh:
ln -s $HOME/{dotfiles,Library/Application\ Support}/lazygit/config.yml
```

## Lazygit Anywhere

```sh:
chmod +x $HOME/dotfiles/lazygit-anywhere/lazygit-{anywhere,lru}
ln -s $HOME/{dotfiles/lazygit-anywhere,.local/bin}/lazygit-anywhere
ln -s $HOME/{dotfiles/lazygit-anywhere,.local/bin}/lazygit-lru
```

## Matplotlib

```sh:
ln -s $HOME/{dotfiles/,.}matplotlib/matplotlibrc
```

## Modulefiles

```sh:
ln -s $HOME/{dotfiles/,}modulefiles
```

## Neovim

```sh:
ln -s $HOME/{dotfiles,.config}/nvim
```

## Neovim nightly build

```sh:
cd ./nvim-nightly
nix build
nix profile install
```

## Nushell

```sh:
ln -s $HOME/{dotfiles,Library/Application\ Support}/nushell/config.nu
ln -s $HOME/{dotfiles,Library/Application\ Support}/nushell/env.nu
```

## Starship

```sh:
ln -s $HOME/{dotfiles,.config}/starship.toml
```

## swpunc (punctuation switcher)

```sh:
chmod +x $HOME/dotfiles/swpunc
ln -s $HOME/{dotfiles,.local/bin}/swpunc
```

## sw-nvim-cmp-blink

requirement: gsed

```sh:
chmod +x $HOME/dotfiles/sw-nvim-cmp-blink
ln -s $HOME/{dotfiles,.local/bin}/sw-nvim-cmp-blink
```

## Typos

```sh:
ln -s $HOME/{dotfiles/typos/,}.typos.toml
```

## Vim

```sh:
ln -s $HOME/{dotfiles/vim/,}.vimrc
```

## WezTerm

```sh:
ln -s $HOME/{dotfiles,.config}/wezterm
```
