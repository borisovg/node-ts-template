BIN := ./node_modules/.bin
TS_FILES := $(shell find src/ -name '*.ts')

all: dist

.PHONY: clean
clean:
	rm -rf coverage dist node_modules package-lock.json

dist: node_modules $(TS_FILES) tsconfig.json
	rm -rf dist
	$(BIN)/tsc -p tsconfig-build.json || rm -rf dist

node_modules: package-lock.json
	npm install || (rm -rf node_modules; exit 1)
	test -d $@ && touch $@ || true

.PHONY: test
ifdef FILE
test: dist
	$(BIN)/c8 --reporter=none $(BIN)/ts-mocha --bail --type-check $(FILE)
else
test: dist
	$(BIN)/c8 --reporter=none $(BIN)/ts-mocha --bail --type-check 'src/**/*.test.ts' \
		&& $(BIN)/c8 report --all --clean -n src -x 'src/**/*.test.ts' -x 'src/types.*' --reporter=text
endif

package-lock.json:
	npm install
