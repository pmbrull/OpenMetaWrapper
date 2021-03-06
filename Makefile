TEST_DIR ?= tests
PROJECT_DIR ?= openmeta-wrapper

install:
	@echo "Installing requirements..."
	pip install flit
	flit install --deps develop

precommit_install:
	@echo "Installing pre-commit hooks"
	@echo "Make sure to first run `make install_test`"
	pre-commit install

isort:
	isort $(PROJECT_DIR)

lint:
	pylint --rcfile=.pylintrc $(PROJECT_DIR)

black:
	black $(PROJECT_DIR) $(TEST_DIR)

black_check:
	black --check --diff $(PROJECT_DIR)

unit:
	coverage erase
	coverage run -m pytest --doctest-modules $(TEST_FOLDER)
	coverage xml -i

test_all: install install_test black_check lint unit
