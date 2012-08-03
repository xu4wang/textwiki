from distutils.core import setup, Extension
aes = Extension('_aes', sources=['aes_wrap.c','aes.c','aesproxy.c'])

setup ( name = 'aes',
version = '1.0',
description = 'aes extension',
ext_modules = [aes])