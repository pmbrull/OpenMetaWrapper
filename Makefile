TEST_DIR ?= tests
PROJECT_DIR ?= OpenMetaWrapper
SOURCES_DIR ?= ${PROJECT_DIR}/sources
GENERATED_DIR ?= ${PROJECT_DIR}/generated
SOURCES_ROOT ?= "catalog-rest-service/src/main/resources/json"

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

get_sources:
	@echo "Fetching source JSON Schema model from OpenMetadata standards..."
	mkdir ${SOURCES_DIR}; \
	cd ${SOURCES_DIR}; \
	git init; \
	git remote add sources git@github.com:open-metadata/OpenMetadata.git; \
	git config core.sparsecheckout true; \
	echo ${SOURCES_ROOT} >> .git/info/sparse-checkout; \
	git pull sources main --depth 1

generate:
	@echo "Generating pydantic sources from OpenMetadata standards..."
	datamodel-codegen --input "${SOURCES_DIR}/${SOURCES_ROOT}" --output ${GENERATED_DIR}  --input-file-type jsonschema

clean_sources:
	@echo "Cleaning JSON sources..."
	rm -rf ${SOURCES_DIR}

generate_all: get_sources generate clean_sources

test_all: install black_check lint unit
