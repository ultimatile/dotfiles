# dotfiles

## Atuin

```sh:
ln -s $HOME/{dotfiles,.config}/atuin/config.toml
```

## Git

Add the following to your `.gitconfig` file:

```ini:
[include]
  path =  /path/to/dotfiles/git/.gitconfig
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

## Python

```sh:
ln -s $HOME/{dotfiles,defaultpy}/pyproject.toml
```

## Starship
  
```sh:
ln -s $HOME/{dotfiles,.config}/starship.toml
```
