#!/usr/bin/env python3
# Author: Jarrod Cameron (z5210220)
# Date:   07/28/2022  6:55

import tempfile
import subprocess
from jinja2 import Template

TEMPLATE = '''
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)

SECTIONS
{
    .kallsyms 0x00:
    {
    {% for symbol in symbols %}
        {{ symbol["name"] }} = 0x{{ symbol["offset"] }};
    {% endfor %}
    }
}
'''

import gdb

class ImportKallSyms(gdb.Command):
    def __init__(self):
        super(ImportKallSyms, self).__init__(
            "kallsyms",
            gdb.COMMAND_BREAKPOINTS
        )


    def invoke(self, arg, from_tty):
        ksyms_file = arg

        ksyms = self.__parse_kallsyms(ksyms_file)

        temp_dir = tempfile.TemporaryDirectory()
        linker_script_path = f'{temp_dir.name}/temp.ld'
        binary_file_path = f'{temp_dir.name}/temp'

        self.__create_ld_script(ksyms, linker_script_path)
        self.__compile_binary(linker_script_path, binary_file_path)
        self.__import_ksyms(binary_file_path)

        temp_dir.cleanup()


    def __import_ksyms(self, binary_file_path):
        gdb.execute(f'add-symbol-file {binary_file_path}')


    def __compile_binary(self, linker_script_path, binary_file_path):
        cmd = ['ld', '-o', binary_file_path, linker_script_path]
        subprocess.run(cmd, stderr=subprocess.DEVNULL)


    def __create_ld_script(self, ksyms, linker_script_path):
        with open(linker_script_path, 'w') as f:
            ret = Template(TEMPLATE).render(symbols=ksyms)
            f.write(ret)


    def __parse_kallsyms(self, ksyms_file):
        '''
        Returns a list of symbols (each with their "offset" and "name")
        '''
        li = []
        with open(ksyms_file, 'r') as f:
            for line in f:
                d = {
                    'offset': line.strip().split()[0],
                    'name': line.strip().split()[2],
                }
                li.append(d)
        return li

ImportKallSyms()
