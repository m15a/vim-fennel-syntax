.PHONY: lint clean build

lint:
	@vint **/*.vim

clean:
	@rm -rf .cache

build:
	@./build.fnl
