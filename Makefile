.PHONY: lint clean lua-keywords

lint:
	@vint **/*.vim

clean:
	@rm -rf .cache

lua-keywords:
	@./tools/build-lua-keywords.fnl
