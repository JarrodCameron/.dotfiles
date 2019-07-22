#!/usr/bin/env python3
# Author: Jarrod Cameron (z5210220)
# Date:   13/07/19 15:28

import sys
import gdb

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

def Handler():
    region = None

    # Initialise breakpoint handler
    def init_breakpoint(reg):
        if reg == None or self.reg != None:
            Help.watch()
            return
        gdb.event.stop.connect(Handler.breakpoint_event)
        region = reg
        region.watch_points = []
        region.spotters = []
        region.num_spotted = 0
        for addr in region.addrs:
            wp = Breakpoint(
                'watch *' + hex(addr),
                type = gdb.BP_HARDWARE_WATCHPOINT,
                internal = True,
                temporary = False
            )
            region.watch_points.append(wp)

    # Stop the breakpoint handler
    def kill_breakpoint():
        if region == None:
            Help.watch()
            return
        gdb.events.stop.disconnect(Handler.breakpoint_event)
        for wp in region.watch_points:
            wp.delete()
        region = None

    def breakpoint_event(event):
        one_of_ours = False
        if isinstance(event, gdb.BreakpointEvent):
            for b in event.breakpoints:
                # TODO: Check if breakpoint is in the list
                # and if it is then do some book keeping
                print(b)
        if one_of_ours = True:
            gdb.execute('continue')

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
            Handler.init_breakpoint(self)
        elif state == 'stop':
            Handler.kill_breakpoint()
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
            if len(argv) == 2 and argv[1].lower() in ['start', 'stop']:
                self.region.watch(argv[1].lower())
            else:
                Help.watch()
        elif argv[0] in ['test']:
            # TODO: This should be used to do entry point stuff
            print('We are in test')
            try:
                gdb.execute('continue')
            except gdb.error as e:
                print('a' * 10000)
                print(str(e))
        else:
            Help.full()
Scan()
