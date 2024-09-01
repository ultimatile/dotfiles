# dotfiles

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

## Atuin

```sh:
ln -f $HOME/{dotfiles,.config}/atuin/config.toml
```
