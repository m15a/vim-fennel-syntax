(local unpack (or table.unpack _G.unpack))
(local {: keys : update!} (require :bunko.table))
(local {: exists? : dirname : read-all} (require :bunko.file))

(fn lua-version? [x]
  (if (and (= :string (type x))
           (string.match x "^5%.[1-4]$"))
      true
      false))

(fn cache [path thunk ?debug]
  "Return data from a cache specified by the path; otherwise call thunk.

Once the thunk is called, its returned value will be stored in the cache.
If ?debug is truthy, output verbose messages to STDERR."
  (let [err io.stderr]
    (if (exists? path)
        (do (when ?debug
              (err:write (.. "Cache found: " path "\n")))
            (read-all path))
        (do (when ?debug
              (err:write (.. "Cache not found: " path "\n")))
            (let [data (thunk)]
              (case (let [dir (dirname path)]
                       (when ?debug
                         (err:write (.. "Create directory: " dir "\n")))
                       (os.execute (.. "mkdir -p " dir)))
                any (with-open [out (io.open path :w)]
                      (out:write data)
                      (when ?debug
                        (err:write (.. "Cached data: " path "\n"))))
                (_ msg code) (error msg))
              data)))))

(fn unkeys [seq ?generator]
  "Create a table from the given sequential table.

Its default values are all `true`. If `?generator` is given, optionally,
each value is computed by calling `?generator` with each corresponding key.

# Examples

```fennel :skip-test
(unkeys [:a :b :c]) ;=> {:a true :b true :c true}
(unkeys [:a :b] #(.. \"key is \" $)) ;=> {:a \"key is a\" :b \"key is b\"}
```"
  (collect [_ key (ipairs seq)]
    (values key ((or ?generator #true) key))))

(fn regex-of-lua-versions [versions]
  "Create a regex string that matches the given set of Lua versions."
  (let [versions (doto (keys versions) table.sort)
        minors (accumulate [acc "" _ v (ipairs versions)]
                 (.. acc (string.sub v 3 3)))]
    (match (length versions)
      0 (error "missing versions for creating regex")
      1 (.. "^5\\." minors "$")
      n (.. "^5\\.[" minors "]$"))))

(fn wrapped-lines [seq width sep]
  "Return a table of strings concatenated with the sep, each line wrapped by the width."
  (let [sep (or sep " ")
        {: lines : buf}
        (accumulate [state {:lines {} :buf ""}
                     _ s (ipairs seq)]
          (if (< width (+ (string.len state.buf) (string.len sep) (string.len s)))
              (doto state
                (update! :lines #(doto $ (table.insert state.buf)))
                (tset :buf s))
              (doto state
                (tset :buf (.. state.buf (if (= state.buf "") "" sep) s)))))]
    (when (not= buf "")
      (table.insert lines buf))
    lines))

{: lua-version?
 : cache
 : unkeys
 : regex-of-lua-versions
 : wrapped-lines}
