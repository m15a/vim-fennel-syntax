(local unpack (or table.unpack _G.unpack))
(import-macros {: immutably} :bunko.macros)
(local {: keys} (require :bunko.table))
(local {: union! : difference! : intersection!} (require :bunko.set))
(local lua-versions (require :lib.lua-versions))
(local {: unkeys} (require :lib.utils))
(local {: fetch-lua-manual-with-cache : extract-lua-keywords} (require :lib.extract))

(fn lua-keywords-of-version [version]
  "Return a table, as a set, of keywords that belong to the Lua version."
  (-> (fetch-lua-manual-with-cache version)
      (extract-lua-keywords)
      (unkeys)))

(fn lua-keywords-of-versions-with [set-operation versions]
  (let [vs (icollect [v _ (pairs versions)]
             (lua-keywords-of-version v))]
    (case (length vs)
      0 {}
      1 (. vs 1)
      _ (let [v (. vs 1)
              vs (doto vs (table.remove 1))]
          (doto v (set-operation (unpack vs)))))))

(fn common-lua-keywords-of-versions [versions]
  "Return the intersection of keywords contained in the given set of Lua versions."
  (lua-keywords-of-versions-with intersection! versions))

(fn all-lua-keywords-of-versions [versions]
  "Return the union of keywords contained in the given set of Lua versions."
  (lua-keywords-of-versions-with union! versions))

(fn exclusive-lua-keywords-of-versions [versions]
  "Return the intersection of keywords exclusively for the given set of Lua versions."
  (let [common-lua-keywords (common-lua-keywords-of-versions versions)
        other-lua-versions (immutably difference! lua-versions versions)
        other-lua-keywords (all-lua-keywords-of-versions other-lua-versions)]
    (immutably difference! common-lua-keywords other-lua-keywords)))

{: lua-keywords-of-version
 : common-lua-keywords-of-versions
 : all-lua-keywords-of-versions
 : exclusive-lua-keywords-of-versions}
