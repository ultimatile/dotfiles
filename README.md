# dotfiles

## Atuin

```sh:
ln -s $HOME/{dotfiles,.config}/atuin/config.toml
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

## WezTerm

````sh:

```sh:
ln -s  $HOME/{dotfiles,.config}/wezterm
````
