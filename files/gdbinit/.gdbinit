source /usr/share/pwndbg/gdbinit.py

# Don't save .gdb_history
set history save off

define syscall
    if $argc != 1
        printf "Usage: syscall <name>\n"
    else
        shell python3 ~/.scripts/syscall $arg0
    end
end

define gdbinit
    shell vim gdbinit
end

define clear
    shell clear
end

alias -a di = disassemble

# /---------------------------------------|-------------------\
# | Description                           | Command           |
# |---------------------------------------|-------------------|
# | List all inferiors                    | info inferiors    |
# | Switch process                        | inferior <pid>    |
# | Detach process (allowing it continue) | detach inferiors  |
# | Kill inferiors                        | kill inferiors    |
# \---------------------------------------|-------------------/
# NOTE: gdb calls the non-current processes "inferior" processes.

# Usually when a process forks gdb will detach from a particular process
# and continue to follow the next process (specified follow-fork-mode).
# To preven gdb from detaching from other other process we use the following
# command.
#
# However, the process that is NOT following will be halted and will need to
# be manually "continued".
set detach-on-fork off

# Don't follow child when created (usefull for system/fork calls).
set follow-fork-mode parent

# For os161
set auto-load safe-path /

# Execute commands after breakpoint is hit
#break *0x080485bd
#    commands
#    printf "*pargv = %p", $eax
#    continue
#end
