.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
export PYTHONPATH := $(shell pwd)

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

.PHONY: help
help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: clean
clean: clean-build clean-pyc clean-test  ## remove all build, test, coverage and Python artifacts

.PHONY: clean-build
clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

.PHONY: clean-pyc
clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-test
clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	find . -name '.cache' -exec rm -fr {} +
	find . -name '.pytest_cache' -exec rm -fr {} +	

.PHONY: format
format:
	yapf yorha --recursive --in-place --verbose
	yapf tests --recursive --in-place --verbose

.PHONY: lint
lint: ## check style with flake8
	pylint yorha
	flake8 yorha

.PHONY: tests
tests: ## run tests quickly with the default Python
	pytest tests

.PHONY: install
install: clean ## install the package to the active Python's site-packages
	pip install -r requirements.txt
	python setup.py install

.PHONY: develop
develop: clean ## creates .egg-link to our local development directory in the site-packages directory
	pip install -r requirements_dev.txt
	pip install -e .[dev]

.PHONY: clean-requirements
clean-requirements:
	rm -f requirements.txt requirements_dev.txt

.PHONY: compile-requirements
compile-requirements:
	pip-compile -v --no-index --output-file requirements.txt requirements.in
	pip-compile -v --no-index --output-file requirements_dev.txt requirements.in requirements_dev.in

.PHONY: sync-requirements
sync-requirements:
	pip-sync requirements_dev.txt

.PHONY: requirements
requirements: clean-requirements compile-requirements sync-requirements