from setuptools import setup

def readme():
  with open('README.rst') as f:
    return f.read()

setup(name='gfapy',
      version='1.3',
      description='Python library for accessing the GFA format',
      long_description=readme(),
      url='https://github.com/ggonnella/rgfa',
      keywords="bioinformatics genomics sequences GFA assembly graphs",
      author='Giorgio Gonnella, Tim Weber',
      author_email='gonnella@zbh.uni-hamburg.de',
      license='MIT',
      packages=['gfapy'],
      scripts=['bin/pygfadiff'],
      zip_safe=False,
      test_suite="nose.collector",
      include_package_data=True,
      tests_require=['nose'],
    )
