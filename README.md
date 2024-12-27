# dotfiles

## Atuin

```sh:
ln -s $HOME/{dotfiles,.config}/atuin/config.toml
```

## Ghostty

```sh:
ln -s  $HOME/{dotfiles/,Library/Application\ Support/com.mitchellh.}ghostty/config
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

````sh:
## WezTerm

```sh:
ln -s  $HOME/{dotfiles,.config}/wezterm
````
