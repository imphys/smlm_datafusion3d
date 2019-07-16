"""
    setup script for py3Dalltoall
"""

from setuptools import setup, find_packages
import os
from io import open # to have encoding as parameter of open on Python >=2.6
import py3Dalltoall.version as vs

if os.name == 'nt':
	lib_ext = '.dll' # library name extension on Windows
elif os.name == 'posix':
	lib_ext = '.so'  # library name extensions on Unix
else:
	raise RuntimeError('OS {} not supported'.format(os.name))

HERE = os.path.abspath(os.path.dirname(__file__))

CLASSIFIERS = ['Development Status :: 5 - Production/Stable',
               'Intended Audience :: End Users/Desktop',
               'Operating System :: Microsoft :: Windows',
               'Topic :: Scientific/Engineering',
               'Topic :: Software Development :: Libraries']

def get_long_description():
    """
    Get the long description from the README file.
    """
    with open(os.path.join(HERE, 'README.txt'), encoding='utf-8') as f:
        return f.read()

if __name__ == "__main__":
    setup(name='py3Dalltoall',
        version=vs.__version__,
        description='Sofware for particle fusion',
        long_description=get_long_description(),
        url='https://github.com/berndrieger/3Dalltoall',
        author='xyz',
        author_email='a@b.c',
        license='xyz',
        classifiers=[],
        keywords='xyz',
        packages=find_packages(where=HERE),
        package_data={'py3Dalltoall': ['*{}'.format(lib_ext)]},
        zip_safe=False)