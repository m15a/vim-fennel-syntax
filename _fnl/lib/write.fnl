(local unpack (or table.unpack _G.unpack))
(import-macros {: immutably} :bunko.macros)
(local {: keys} (require :bunko.table))
(local {: difference!} (require :bunko.set))
(local {: regex-of-lua-versions : wrapped-lines} (require :lib.utils))
(local {: exclusive-lua-keywords-of-versions} (require :lib.transform))
(local lua-versions (require :lib.lua-versions))

(fn write-lua-keywords-of-versions [out versions]
  "Write keywords for the given set of Lua versions to the output file handle."
  (let [keywords (exclusive-lua-keywords-of-versions versions)]
    (when (next keywords)
      (let [conditional? (let [diff (immutably difference! lua-versions versions)]
                           (< 0 (length (keys diff))))]
        (when conditional?
          (out:write (.. "if match(s:lua_version, '"
                         (regex-of-lua-versions versions)
                         "') > -1\n")))
        (each [_ chunk (ipairs (wrapped-lines (doto (keys keywords) (table.sort))
                                              (if conditional? 68 70)))]
          (out:write (.. (if conditional? "  " "")
                         "syn keyword fennelLuaKeyword "
                         chunk
                         "\n")))
        (when conditional?
          (out:write "endif\n"))))))

{: write-lua-keywords-of-versions}
