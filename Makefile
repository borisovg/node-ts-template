TS_FILES := $(shell find src/ -name '*.ts')

all: dist

clean:
	rm -rf coverage dist node_modules yarn.lock

dist: node_modules $(TS_FILES) tsconfig.json
	rm -rf dist
	yarn run tsc || rm -rf dist

node_modules: yarn.lock
	yarn || (rm -rf node_modules; exit 1)
	test -d $@ && touch $@ || true

test: dist
	yarn run c8 --reporter=none ts-mocha -b 'src/**/*.test.ts' \
		&& yarn run c8 report --all --clean -n src -x 'src/**/*.test.ts' -x 'src/types.*' --reporter=text

yarn.lock:
	yarn
