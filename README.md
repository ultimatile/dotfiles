# dotfiles

## Neovim

```sh:
ln -s $HOME/{dotfiles,.config}/nvim
```

## Modulefiles

```sh:
ln -s $HOME/{dotfiles/,}modulefiles
```

## Git

Add the following to your `.gitconfig` file:

```ini:
[include]
  path =  /path/to/dotfiles/git/.gitconfig
```
