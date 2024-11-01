MOCHA_OPTS := --bail --type-check
NPM := pnpm
NPM_LOCK := pnpm-lock.yaml
TS_FILES := $(shell find src/ -name '*.ts')

all: dist

## help:		show this help
.PHONY: help
help:
	@sed -n 's/^##//p' Makefile | sort

## clean: 	delete generated files
.PHONY: clean
clean:
	rm -rf coverage dist node_modules $(NPM_LOCK)

## ci: 		run tests and remove dev dependencies
.PHONY: ci
ci: test dist
	$(NPM) install --omit=dev

dist: node_modules $(TS_FILES) tsconfig.json Makefile
	rm -rf $@
	pnpm tsc -p tsconfig-build.json

## lint:		run linter checks
.PHONY: lint
lint: node_modules
	pnpm prettier --check 'src/**/*.{js,ts,json,md,yml}'
	pnpm eslint src/ --max-warnings 0

node_modules: package.json $(NPM_LOCK)
	$(NPM) install || (rm -rf $@; exit 1)
	test -d $@ && touch $@ || true

## start-dev:	start application in development mode
.PHONY: start-dev
start-dev: node_modules
	while true; do LOG_LEVEL=debug pnpm nodemon -w ./src ./src/index.ts; sleep 1; done

## test:		run unit tests (set FILE env variable to run test for that file only)
.PHONY: test
ifdef FILE
test: node_modules
	pnpm c8 --reporter=none ts-mocha $(MOCHA_OPTS) $(FILE)
else
test: node_modules
	pnpm c8 --reporter=none ts-mocha $(MOCHA_OPTS) 'src/**/*.spec.ts' \
		&& pnpm c8 report --all --clean -n src -x 'src/**/*.spec.ts' -x 'src/types.*' --reporter=text
endif

$(NPM_LOCK):
	$(NPM) install && touch $@
