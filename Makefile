default: tests

.PHONY: manual tests

PYTHON=python3
PIP=pip3

# Install using pip
install:
	${PIP} install --upgrade --user --editable .

# Source distribution
sdist:
	${PYTHON} setup.py sdist

# Pure Python Wheel
wheel:
	${PYTHON} setup.py bdist_wheel

# Create the manual
manual:
	cd doc && make latexpdf
	mkdir -p manual
	cp doc/_build/latex/Gfapy.pdf manual/gfapy-manual.pdf


# Run unit tests
tests:
	cd doc && make doctest
	@echo
	@echo "Running unit test suite..."
	@PYTHONHASHSEED=0 ${PYTHON} -m unittest discover

# Remove distribution files
cleanup:
	rm -rf dist/ build/ gfapy.egg-info/

upload:
	twine register dist/*
	for file in dist/*; do twine upload $$file; done
