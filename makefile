venv:
	python3 -m venv .venv
	@echo 'run `source .venv/bin/activate` to use virtualenv'

setup: venv
	source .venv/bin/activate && pip3 install -U black isort mypy pylint twine

dev: setup
	source .venv/bin/activate && python3 setup.py develop
	@echo 'run `source .venv/bin/activate` to develop bowler'

release: lint test clean
	python3 setup.py sdist
	python3 -m twine upload dist/*

format:
	isort --recursive --multi-line=3 --trailing-comma --force-grid-wrap=0 \
	  --combine-as --line-width=88 -y bowler setup.py
	black bowler setup.py

lint:
	@/bin/bash -c 'die() { echo "$$1"; exit 1; }; \
	  while read filename; do \
	  grep -q "Copyright (c) Facebook" "$$filename" || \
	    die "Missing copyright in $$filename"; \
	  grep -q "#!/usr/bin/env python3" "$$filename" || \
	    die "Missing #! in $$filename"; \
	  done < <( git ls-tree -r --name-only HEAD | grep ".py$$" )'
	black --check bowler setup.py
	mypy --ignore-missing-imports .

test:
	python3 -m unittest -v bowler.tests

clean:
	rm -rf build dist README MANIFEST *.egg-info

distclean: clean
	rm -rf .venv
