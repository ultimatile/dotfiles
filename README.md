# dotfiles

## Aerospace

```sh:
ln -s  $HOME/dotfiles,.config}/aerospace/aerospace.toml
```

## Atuin

```sh:
ln -s $HOME/{dotfiles,.config}/atuin/config.toml
```

## Direnv

```sh:
ln -s $HOME/{dotfiles,.config}/direnv/direnvrc
```

## Fancy-cat

```sh:
ln -s $HOME/{dotfiles,.config}/fancy-cat/config.json
```

## Ghostty

```sh:
ln -s  $HOME/{dotfiles,.config}/ghostty/config
```

## Git

Add the following to your `.gitconfig` file:

```ini:
[include]
  path =  /path/to/dotfiles/git/.gitconfig
```

## Glow

```sh:
ln -s $HOME/{dotfiles/,Library/Preferences/glow/}glow.yml
```

## Gnuplot

```sh:
ln -s $HOME/{dotfiles/,}.gnuplot
```

## Hammerspoon

requirement: swpunc

```sh:
ln -s $HOME/{dotfiles/,.}hammerspoon/init.lua
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

## Python

```sh:
ln -s $HOME/{dotfiles,defaultpy}/pyproject.toml
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
ln -s  $HOME/{dotfiles,.config}/wezterm
```
