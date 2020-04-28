# .dotfiles

Just some of my dotfiles. `restore.sh` is a script to create symbolic links
saving time from moving files from here to where they belong.
These dotfiles include:

- [`.tmux.conf`](https://github.com/tmux/tmux)
- [`.vim`](https://github.com/vim/vim)
- [`bash`](https://www.gnu.org/software/bash/)
- [`i3blocks`](https://github.com/vivien/i3blocks)
- [`i3wm`](https://github.com/Airblader/i3)
- [`radare2`](https://github.com/radareorg/radare2)
- [`termite`](https://github.com/thestinger/termite/)
- [`vim`](https://github.com/vim/vim)
- [`xmobar`](https://github.com/jaor/xmobar)
- [`xmonad`](https://github.com/xmonad/xmonad)
- `.Xresources`
- `.scripts` (personal scripts)
- `wallpapers`


Obligatory screenshot:

![screenshot](screenshots/screenshot.png)

## Install

Clone the repository and distribute the files using `restore.sh`:
```{sh}
git clone https://github.com/z5210220/.dotfiles ~/.dotfiles
cd ~/.dotfiles
sh restore.sh
```

## `restore.sh` usage

`restore.sh` is used to create symbolic links
from files around the system to the backed up files.
This can be used by running the following commands:

```{sh}
cd ~/.dotfiles
sh restore.sh
```

`restore.sh` will restore each file in the `dotfiles.json` file.

## `dotfiles.json`

This is a _data base_ of all files. Each file needs three fields:

- The `name` (this is the key in the dictionary).
- The `file` (the file to store)
- The `path` (directory containing this file)

Inside of `files/` is a directory for each `name` which contains the
respective `file`.

### Example

If `dotfiles.json` looked like:

```
{
    "bashrc" : {
        "file" : ".bashrc",
        "path" : "~"
    }
}
```

The file is stored in `files/bashrc/.bashrc` and the symbolic link will be
created in `~/.bashrc`.
