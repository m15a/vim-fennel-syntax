(local unpack (or table.unpack _G.unpack))
(import-macros {: immutably} :bunko.macros)
(local {: keys} (require :bunko.table))
(local {: union! : difference! : intersection!} (require :bunko.set))
(local {: fetch-lua-manual : extract-lua-keywords} (require :lib.extract))
(local lua-versions (require :lib.lua-versions))

(fn keywords-of-version [version]
  "Return a table, as a set, of keywords that belong to the Lua version."
  (-> (fetch-lua-manual version)
      (extract-lua-keywords)
      (#(collect [_ k (ipairs $)] k true))))

(fn all-keywords-of-versions [versions]
  "Return the union of keywords contained in the given set of Lua versions."
  (let [vs (icollect [v _ (pairs versions)]
             (keywords-of-version v))]
    (case (length vs)
      0 {}
      1 (. vs 1)
      _ (let [v (. vs 1)
              vs (doto vs (table.remove 1))]
          (doto v (union! (unpack vs)))))))

(fn common-keywords-of-versions [versions]
  "Return the intersection of keywords contained in the given set of Lua versions."
  (let [vs (icollect [v _ (pairs versions)]
             (keywords-of-version v))]
    (case (length vs)
      0 {}
      1 (. vs 1)
      _ (let [v (. vs 1)
              vs (doto vs (table.remove 1))]
          (doto v (intersection! (unpack vs)))))))

(fn exclusive-lua-keywords-of-versions [versions]
  "Return the intersection of keywords exclusively for the given set of Lua versions."
  (let [common-keywords (common-keywords-of-versions versions)
        other-versions (immutably difference! lua-versions versions)
        other-keywords (all-keywords-of-versions other-versions)]
    (immutably difference! common-keywords other-keywords)))

(fn regex-of-lua-versions [versions]
  "Create a regex string that matches the given set of Lua versions."
  (let [versions (doto (keys versions) table.sort)
        minors (accumulate [acc "" _ v (ipairs versions)]
                 (.. acc (string.sub v 3 3)))]
    (match (length versions)
      0 (error "missing versions for creating regex")
      1 (.. "^5\\." minors "$")
      n (.. "^5\\.[" minors "]$"))))

{: exclusive-lua-keywords-of-versions
 : regex-of-lua-versions}
