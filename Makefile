default: tests

.PHONY: manual tests

PYTHON=python3
PIP=pip3

# Install using pip
install:
	${PIP} install . --upgrade --user

# Source distribution
sdist:
	${PYTHON} setup.py sdist

# Pure Python Wheel
wheel:
	${PYTHON} setup.py bdist_wheel

# Create the manual
manual:
	cd manual; \
		cat chapters | xargs pandoc -o gfapy-manual.pdf

# Run unit tests
tests:
	${PYTHON} -m unittest discover

# Remove distribution files
cleanup:
	rm -rf dist/ build/ gfapy.egg-info/

upload:
	twine register dist/*
	twine upload dist/*
