BIN := ./node_modules/.bin
MOCHA_OPTS := --bail --type-check
TS_FILES := $(shell find src/ -name '*.ts')

all: dist

.PHONY: clean
clean:
	rm -rf coverage dist node_modules package-lock.json

dist: node_modules $(TS_FILES) tsconfig.json Makefile
	rm -rf $@
	$(BIN)/tsc -p tsconfig-build.json

node_modules: package.json package-lock.json
	npm install || (rm -rf $@; exit 1)
	test -d $@ && touch $@ || true

.PHONY: test
ifdef FILE
test: dist
	$(BIN)/c8 --reporter=none $(BIN)/ts-mocha $(MOCHA_OPTS) $(FILE)
else
test: dist
	$(BIN)/c8 --reporter=none $(BIN)/ts-mocha $(MOCHA_OPTS) 'src/**/*.test.ts' \
		&& $(BIN)/c8 report --all --clean -n src -x 'src/**/*.test.ts' -x 'src/types.*' --reporter=text
endif

package-lock.json:
	npm install
