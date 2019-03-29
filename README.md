# .dotfiles

These are my .dotfiles (files often used for configuring other programs).
Also two scripts are used `backup.sh` and `restore.sh` which are used to
automate the backing up process

Dot files for:
- `.bashrc`
- `i3`
- `i3blocks`
- `.scripts` (scripts used for automating various tasks)
- `.tmux.conf`
- `.vim`
- `.Xresources`

## Usage

All that is needed to the clone the repository:
```{sh}
git clone https://github.com/z5210220/.dotfiles ~/.dotfiles
```

### `backup.sh` Usage

`backup.sh` is used to copy configuration files from the user.
This can be used by running the following commands:
```{sh}
cd ~/.dotfiles
bash backup.sh
```

To back up more files add the following line to the end of `backup.sh`:
```{sh}
back_up /path/to/file
```

### `restore.sh` Usage

`restore.sh` is used to create symbolic links
from files around the system to the backed up files.
This can be used by running the following commands:
```{sh}
cd ~/.dotfiles
bash restore.sh
```

To add another file to restore add the following line to the end of `restore.sh`:
```{sh}
restore name_of_file /path/to/file
```

#### Hacking

Currently `backup.sh` and `restore.sh` accesses all files from
`DOTFILES_SRC` which is defined in both files.
NOTE: moving `.dotfiles` requires `DOTFILES_SRC` to up updated.
