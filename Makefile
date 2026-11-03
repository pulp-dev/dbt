SHELL := /bin/bash -eu -o pipefail
export DBT_SEND_ANONYMOUS_USAGE_STATS := false
export DBT_USE_COLORS := false
export TMPDIR := $(CURDIR)/.runtime/tmp
export PIP_CACHE_DIR := $(CURDIR)/.runtime/cache
export PRE_COMMIT_HOME := $(CURDIR)/.runtime/pre-commit
export VIRTUALENV_OVERRIDE_APP_DATA := $(CURDIR)/.runtime/virtualenv
DBT := .venv/bin/dbt
DBT_FLAGS := --project-dir dbt --profiles-dir dbt

.NOTPARALLEL:

.PHONY: install up load deps build test docs serve lint fix check down
install:
	mkdir -p .runtime/tmp .runtime/cache results
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt
up:
	docker compose up -d --wait
load:
	.venv/bin/python load_data.py $(DATA) | tee results/load.log
deps:
	$(DBT) deps $(DBT_FLAGS)
build:
	$(DBT) build $(DBT_FLAGS) | tee results/build.log
test:
	$(DBT) test $(DBT_FLAGS) --no-use-colors | tee results/dbt_test.log
docs:
	$(DBT) docs generate $(DBT_FLAGS) --static
	cp dbt/target/static_index.html results/dbt_docs.html
serve:
	$(DBT) docs serve $(DBT_FLAGS) --port 8081 --no-browser
lint:
	.venv/bin/sqlfluff lint dbt/models dbt/macros dbt/tests | tee results/sqlfluff.log
fix:
	.venv/bin/sqlfluff fix dbt/models dbt/macros dbt/tests
check: build test lint docs
down:
	docker compose down
