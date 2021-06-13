.PHONY: lint clean lua-keywords

lint:
	@vint **/*.vim

clean:
	@rm -rf .cache

lua-keywords: .cache/lua_keywords.vim

.cache/lua_keywords.vim:
	@./data/generate-lua-keywords.fnl
