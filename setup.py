from setuptools import setup, find_packages

def readme():
  with open('README.rst') as f:
    return f.read()

import sys
if not sys.version_info[0] == 3:
  sys.exit("Sorry, only Python 3 is supported")

setup(name='gfapy',
      version='1.2.2',
      description='Library for handling data in the GFA1 and GFA2 formats',
      long_description=readme(),
      url='https://github.com/ggonnella/gfapy',
      keywords="bioinformatics genomics sequences GFA assembly graphs",
      author='Giorgio Gonnella and others (see CONTRIBUTORS)',
      author_email='gonnella@zbh.uni-hamburg.de',
      license='ISC',
      # see https://pypi.python.org/pypi?%3Aaction=list_classifiers
      classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: ISC License (ISCL)',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 3 :: Only',
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'Topic :: Software Development :: Libraries',
      ],
      packages=find_packages(),
      scripts=['bin/gfapy-convert',
               'bin/gfapy-mergelinear',
               'bin/gfapy-renumber',
               'bin/gfapy-validate'],
      zip_safe=False,
      test_suite="nose.collector",
      include_package_data=True,
      tests_require=['nose'],
    )
