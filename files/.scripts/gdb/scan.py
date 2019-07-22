#!/usr/bin/env python3
# Author: Jarrod Cameron (z5210220)
# Date:   13/07/19 15:28

import sys
import os
import gdb
import shutil
from elftools.elf.elffile import ELFFile

#dump to file
# https://stackoverflow.com/questions/16095948/dump-memory-save-formatted-output-into-a-file
#get mappings
# https://stackoverflow.com/questions/5691193/gdb-listing-all-mapped-memory-regions-for-a-crashed-process

### Code to get the offset into the elf file ###
#from elftools.elf.elffile import ELFFile
#
#def get_entry(file_name):
#    with open(file_name, 'rb') as f:
#        entry = ELFFile(f).header['e_entry']
#        print(hex(entry))
#
#get_entry('test')


# TODO
# - Support values of base 10, 16, 8, 2
# - Use a dictionary for the regions (not a tuple)
# - Add colors to help
# - Add colors to errors
# - Does the watch points work with non 32 bit vals?
# - When the watch is done we should list offset into elf file
# - Why does the breakpoint get triggered when the program finishes?

ASM_NOP = b'\x90'

class Colors():
    __red = '\x1B[31m'
    __green = '\x1B[32m'
    __yellow = '\x1B[33m'
    __blue = '\x1B[34m'
    __reset = '\x1B[0m'
    __bold = '\x1B[1m'

    def red(s):
        return Colors.__red    + str(s) + Colors.__reset
    def green(s):
        return Colors.__green  + str(s) + Colors.__reset
    def yellow(s):
        return Colors.__yellow + str(s) + Colors.__reset
    def blue(s):
        return Colors.__blue   + str(s) + Colors.__reset
    def bold(s):
        return Colors.__bold   + str(s) + Colors.__reset

class Util():
    def str_to_args(arg):
        li = []
        for a in arg.split():
            li.append(a)
        return li

class Help():
    def full():
        Help.init()
        print('[*]')
        Help.do()
        print('[*]')
        Help.ls()
        print('[*]')
        Help.watch()
        print('[*]')
        Help.offend()

    def init():
        print('[*] Usage: scan init <size>')
        print('[*] size -> Size of the value in bits: b(8), h(16), w(32), or g(64)')
    def do():
        print('[*] Usage: scan do <value>')
        print('[*] value -> The value to look for in the address space')
        print('[*]          Thie size was given from `scan init\'')
        print('[*] The first time, all RW and RWX pages are scanned.')
        print('[*] Sequential calls only check values from the previous `scan do\'')
    def ls():
        print('[*] Usage: scan ls [length]')
        print('[*] Print all the addresses from the last `scan do\'')
        print('[*] length -> Print the number of matches')
    def watch():
        print('[*] Usage: scan watch')
        print('[*] Set a watch point for all the selected addresses')
    def offend():
        print('[*] Usage: scan offend <ls|elf|patch>')
        print('[*] An "offending" address is one that changes the specified values')
        print('[*] ls -> List all the instructions in the virtual address space')
        print('[*] elf -> List all the offsets within the elf file')
        print('[*] patch -> Patch instructions with nop\'s')


class ScanWatchpoint(gdb.Breakpoint):

    def __init__(self, region, loc, bp_type=gdb.BP_WATCHPOINT, internal=True, temp=False):
        super(ScanWatchpoint, self).__init__(
            loc,                # The location of out watchpoint
            type=bp_type,       # The type of breakpoint
            internal=internal,  # Hide the breakpoint from the user
            temporary=temp,     # Should/shouldn't stop after the first hit
        )
        self.region = region

        # The unique address that modify our `loc'
        # These will all be `store' type instructions
        self.offenders = []

        # The number of time the breakpoint has been `hit'
        self.hits = 0

    def stop(self):
        dump = gdb.execute('x/128i $rip-128', to_string=True)
        for index, line in enumerate(dump.splitlines()):
            if len(line) > 2 and '=>' == line[0:2]:
                # Location of the `store' instruction in memory
                offender = int(dump.splitlines()[index-1].split()[0], 16)
                self.hits += 1
                if offender not in self.offenders:
                    self.offenders.append(offender)
                    break

        # Continue execution
        return False

class Handler():

    def __init__(self, reg):
        self.region = reg
        self.region.wp = []
        for addr in self.region.addrs:
            self.region.wp.append(
                ScanWatchpoint(region=reg, loc='*(int*)' + hex(addr))
            )
        print(Colors.green('[*]') + ' Initialised {} watchpoints'.format(len(self.region.wp)))

    def destroy(self):
        num_hits = 0
        offenders = []
        for wp in self.region.wp:
            num_hits += wp.hits
            offenders += wp.offenders
            wp.delete()
        # Remove duplicates
        self.region.offenders = list(set(offenders))

        print(Colors.green('[*]') + ' There were {} hits'.format(num_hits))
        print(Colors.green('[*]') + ' There were {} offending instructions'.format(len(self.region.offenders)))
        return self.region.offenders

class Regions():
    # We scan the linux process file since gdb doesn't give us the permsissions of each region
    def __init__(self, size):
        self.mem_acc = 0
        if size == 'b' or size == '8':
            self.sizeof = 8
            self.query = 'b'
        elif size == 'h' or size == '16':
            self.sizeof = 16
            self.query = 'h'
        elif size == 'w' or size == '32':
            self.sizeof = 32
            self.query = 'w'
        elif size == 'g' or size == '64':
            self.sizeof = 64
            self.query = 'g'
        else:
            print('[*] ERROR: Unknown size \'{}\''.format(size))
            Help.init()
            return None

        self.handler = None
        self.addrs = []
        self.write_regions = []
        self.pid = gdb.execute('info proc mappings', to_string=True).split()[1]

        with open('/proc/' + str(self.pid) + '/maps') as maps:
            for line in maps:
                if self.__writeable(line) == False:
                    continue
                base = int(line.replace('-', ' ').split()[0], 16)
                length = int(line.replace('-', ' ').split()[1], 16) - base
                self.write_regions.append((base, length))

        print('[*] PID: {}'.format(self.pid))
        print('[*] Found {} writeable regions'.format(len(self.write_regions)))
        print('[*] Size of regions is {} bytes'.format(hex(self.__region_size())))

    def list(self, length=False):
        if length == True:
            print(len(self.addrs))
        else:
            for a in self.addrs:
                print(hex(a))

    def watch(self, state):

        if len(self.addrs) == 0:
            print(f'{Colors.green("[*]")} There are no addresses to watch.')
            return
        if state == 'start':
            #Handler.init_breakpoint(self)
            self.handler = Handler(self)
        elif state == 'stop':
            self.handler.destroy()
        else:
            print("Shouldn't get here")
            assert(0)

    def __writeable(self, line):
        perms = [' rw-p ', ' rw-s ', ' rwxp ', ' rwxs ']
        for p in perms:
            if p in line:
                return True
        return False

    def __region_size(self):
        t = 0
        for r in self.write_regions:
            t += r[1]
        return t

    def scan(self, value):

        try:
            value = int(value)
        except ValueError:
            print('[*] ERROR: Invalid value \'{}\''.format(value))
            Help.do()
            return -1

        li = []
        if len(self.addrs) == 0:
            # This is the first time the function is being called
            # so we query the address space
            for r in self.write_regions:
                cmd = 'find /'          # Start of GDB command
                cmd += self.query       # The size of the value we are looking for
                cmd += str(r[1])        # The maximium number of hit (we want all of them)
                cmd += ' '              # Seperator
                cmd += str(r[0])        # Start address (base of region)
                cmd += ', +'            # Seperator
                cmd += str(r[1])        # The number of bytes to scan (we want to check all of them)
                cmd += ', '             # Seperator
                cmd += str(value)       # The actual value we are looking for

                string = gdb.execute(cmd, to_string=True)
                for s in string.splitlines():
                    addr = s.split()[0]
                    if addr[0:2] == '0x':
                        li.append(int(addr, 16))
            print('[*] Found: {}'.format(len(li)))
        else:
            # This is atleast the second time the function is being called
            for addr in self.addrs:
                cmd = 'x/' + self.query + ' ' + hex(addr)
                try:
                    new_val = gdb.execute(cmd, to_string=True).split()[1]
                    if new_val.isnumeric() and int(new_val) == value:
                        li.append(addr)
                except:
                    # This address in memory is longer mapped in
                    pass

            print('[*] Found: {} -> {}'.format(len(self.addrs), len(li)))

        # Remove any duplicates
        self.addrs = list(sorted(set(li)))

    def __elf_offenders(self):
        elf_offenders = []
        ventry = int(gdb.execute('info file', to_string=True).splitlines()[6].split()[2], 16)
        file_name = gdb.execute('info file', to_string=True).splitlines()[0][14:-2]
        with open(file_name, 'rb') as f:
            # The physical entry in the ELF file
            pentry = ELFFile(f).header['e_entry']

        # We exploit the fact ALSR is disabled by default
        for o in self.offenders:
            elf_offenders.append(pentry + o - ventry)
        return elf_offenders

    # Return the length of the instruction at the virtual
    # location `vins'
    def __ins_len(self, vins):
        addr1 = int(gdb.execute('x/2i ' + str(vins), to_string=True).splitlines()[0].split()[0], 16)
        line2 = gdb.execute('x/2i ' + str(vins), to_string=True).splitlines()[1].split()
        if line2[0] == '=>':
            addr2 = int(line2[1], 16)
        else:
            addr2 = int(line2[0], 16)
        return abs(addr2 - addr1)

    def offend(self, arg):
        if arg == 'ls':
            for o in self.offenders:
                print(gdb.execute('x/i ' + hex(o), to_string=True).split()[0])
        elif arg == 'elf':
            self.elf_offenders = self.__elf_offenders()

            for o in self.elf_offenders:
                print(hex(o))

        elif arg == 'patch':

            file_name = gdb.execute('info file', to_string=True).splitlines()[0][14:-2]

            file_name_pat = file_name + '_pat'
            shutil.copy(file_name, file_name_pat)
            print(Colors.green('[*]') + ' Created new file:')
            print(Colors.green('[*]') + '     {}'.format(file_name_pat))

            # We use raw syscalls since python prints may have
            #   unknwon side effects
            fd = os.open(file_name_pat, os.O_WRONLY)

            # Get the offsets in the elf file
            self.elf_offenders = self.__elf_offenders()

            for i in range(len(self.elf_offenders)):
                ins_len = self.__ins_len(self.offenders[i])
                eo = self.elf_offenders[i]

                os.lseek(fd, eo, os.SEEK_SET)
                os.write(fd, ASM_NOP * ins_len)

                print(Colors.green('[*]') + ' @ {}'.format(eo))

            os.close(fd)

            print(Colors.green('[*]') + ' {} instructions nop\'d out'.format(len(self.elf_offenders)))


class Scan(gdb.Command):
    def __init__(self):
        self.region = None
        super(Scan, self).__init__("scan", gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = Util.str_to_args(arg)
        if argv == []:
            Help.full()
        elif argv[0] in ['i', 'init']:
            if len(argv) != 2:
                Help.init()
                return
            self.region = Regions(argv[1])
        elif argv[0] in ['do', 'd']:
            if len(argv) != 2:
                Help.do()
                return
            if self.region == None:
                print('[*] Did you forget to init?')
                return
            self.region.scan(argv[1])
        elif argv[0] in ['ls']:
            if self.region == None:
                Help.ls()
            elif len(argv) == 2 and argv[1].lower() in ['len', 'length']:
                self.region.list(length=True)
            elif len(argv) == 1:
                self.region.list(length=False)
            else:
                Help.ls()
                return
        elif argv[0] in ['watch']:
            if self.region == None:
                Help.watch()
            elif len(argv) == 2 and argv[1].lower() in ['start', 'stop']:
                self.region.watch(argv[1].lower())
            else:
                Help.watch()
        elif argv[0] in ['offend', 'o']:
            if self.region.offenders == []:
                print(Colors.red('[*]') + ' Have you run `scan watch start/stop`?')
                Help.offend()
            elif argv[1].lower() in ['ls', 'elf', 'patch']:
                # TODO ls
                # TODO elf
                # TODO patch
                self.region.offend(argv[1].lower())
            else:
                Help.offend()
        elif argv[0] in ['test']:
            # The entry point from where the program is running from
            ventry = int(gdb.execute('info file', to_string=True).splitlines()[6].split()[2], 16)
            file_name = gdb.execute('info file', to_string=True).splitlines()[0][14:-2]
            with open(file_name, 'rb') as f:
                # The physical entry in the ELF file
                pentry = ELFFile(f).header['e_entry']
            # Next we need to x/i minus the ventry to get the offset
            # The offset into the elf file is the `pentry + offset` (which was was just calculatored)

        else:
            Help.full()
Scan()
