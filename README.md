# .dotfiles

Dot files for:
- Vim
- i3
- i3blocks
- Bash

and some handy scripts.

`autogen` is a tool for keeping all these files in one location
and using symbolic links to allow other programs to access them.

# Install

To install all dotfiles use the following commands:

```{sh}
git clone https://github.com/z5210220/.dotfiles ~
~/.dotfiles/autogen full
```

However, to install a single configuration (such as `.vim`), use
the following commands:

```{sh}
git clone https://github.com/z5210220/.dotfiles ~
~/.dotfiles/autogen vim
```
