MOCHA_OPTS := --bail --type-check
NPM := npm
NPM_BIN := ./node_modules/.bin
NPM_LOCK := package-lock.json
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

dist: node_modules $(TS_FILES) tsconfig.json Makefile
	rm -rf $@
	$(NPM_BIN)/tsc -p tsconfig-build.json

node_modules: package.json $(NPM_LOCK)
	$(NPM) install || (rm -rf $@; exit 1)
	test -d $@ && touch $@ || true

## test:		run unit tests (set FILE env variable to run test for that file only)
.PHONY: test
ifdef FILE
test: dist
	$(NPM_BIN)/c8 --reporter=none $(NPM_BIN)/ts-mocha $(MOCHA_OPTS) $(FILE)
else
test: dist
	$(NPM_BIN)/c8 --reporter=none $(NPM_BIN)/ts-mocha $(MOCHA_OPTS) 'src/**/*.test.ts' \
		&& $(NPM_BIN)/c8 report --all --clean -n src -x 'src/**/*.test.ts' -x 'src/types.*' --reporter=text
endif

$(NPM_LOCK):
	$(NPM) install && touch $@
