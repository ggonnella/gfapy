default: tests

.PHONY: manual tests cleanup upload conda sdist wheel install

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

doctest:
	cd doc && make doctest

unittests:
	@echo
	@echo "Running unit test suite..."
	@PYTHONHASHSEED=0 ${PYTHON} -m unittest discover

tests: doctest unittests

# Remove distribution files
cleanup:
	rm -rf dist/ build/ gfapy.egg-info/

upload: tests cleanup sdist wheel
	cd dist; \
  	for file in *; do \
		  twine check $$file && \
		  twine upload $$file; \
		done

conda:
	mkdir -p conda
	cd conda; \
		conda skeleton pypi gfapy; \
		conda build gfapy
