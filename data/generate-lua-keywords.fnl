#!/usr/bin/env fennel

(local http (require :socket.http))
(local gumbo (require :gumbo))
(local string (require :string))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utilities

(local sets {})

(fn to_map [tbl]
  (collect [_ item (ipairs tbl)]
    (values item true)))

(fn sets.intersection [first ...]
  "Returns the intersection of the given sets."
  (let [intersection (to_map first)]
    (each [_ one (ipairs [...])]
      (let [one (to_map one)]
        (each [item _ (pairs intersection)]
          (when (= (. one item) nil)
            (tset intersection item nil)))))
    (icollect [item _ (pairs intersection)]
      item)))

(fn sets.difference [first ...]
  "Returns the difference of the given first set and the rest."
  (let [diff (to_map first)]
    (each [_ one (ipairs [...])]
      (each [_ item (ipairs one)]
        (tset diff item nil)))
    (icollect [item _ (pairs diff)]
      item)))

(local utils {})

(fn utils.exists? [file]
  "Does the file exists?"
  (match (io.open file)
    any (do (any:close) true)
    _ false))

(fn utils.slurp [file]
  "Read all contents of the file."
  (with-open [in (io.open file)]
    (in:read :*a)))

(fn utils.clone [tbl]
  (collect [k v (pairs tbl)] (values k v)))

(fn utils.values [tbl]
  (icollect [_ v (pairs tbl)] v))

(fn utils.sorted [tbl]
  (let [cloned (utils.clone tbl)]
    (table.sort cloned)
    cloned))

(fn utils.map [seq f]
  (icollect [_ x (ipairs seq)] (f x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Library

(fn fetch-lua-manual [version]
  "Fetch Lua manual html of given version from www.lua.org."
  (if (not (string.match version "^5%.[1-4]$"))
      (do (io.stderr:write (.. "Invalid Lua version: " version) "\n")
          nil)
      (let [cache (.. ".cache/" version ".html")]
        (os.execute "mkdir -p .cache")
        (if (utils.exists? cache)
            (gumbo.parse (utils.slurp cache))
            (match (http.request (.. "https://www.lua.org/manual/" version "/"))
              (body 200) (do (with-open [out (io.open cache :w)]
                               (out:write body))
                             (gumbo.parse body))
              _          (do (io.stderr:write (.. "Failed to get Lua " version " manual\n"))
                             nil))))))

(fn extract-keywords [lua-manual]
  "Extract keywords from Lua manual html body."
  (let [keywords {}]
    (each [_ item (ipairs (lua-manual:getElementsByTagName :a))]
      (when (and (. item :attributes :href)
                 (string.find (. item :attributes :href :value) "#pdf-")
                 (not (string.find item.innerHTML "^LUAL?_"))
                 (not (string.find item.innerHTML "^__"))
                 (not (string.find item.innerHTML "^luaopen_")))
        (table.insert keywords item.innerHTML)))
    keywords))

(local *keywords* (collect [_ v (ipairs [5.1 5.2 5.3 5.4])]
                    (values v (extract-keywords (fetch-lua-manual v)))))

(fn keywords-for [...]
  (let [versions [...]
        others (sets.difference [5.1 5.2 5.3 5.4] versions)]
    (sets.difference (sets.intersection (unpack (utils.map versions #(. *keywords* $))))
                     (unpack (utils.map others #(. *keywords* $))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Main

(fn main []
  (let [cache ".cache/lua_keywords.vim"]
    (os.execute "mkdir -p .cache")
    (with-open [out (io.open cache :w)]

      (let [keywords (keywords-for 5.1 5.2 5.3 5.4)]
        (each [_ keyword (ipairs (utils.sorted keywords))]
          (out:write (.. "syn keyword fennelLuaKeyword " keyword "\n"))))

      (let [keywords (keywords-for 5.1 5.2 5.3)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[123]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1 5.2 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[124]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1 5.3 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[134]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.2 5.3 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[234]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1 5.2)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[12]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1 5.3)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[13]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[14]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.2 5.3)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[23]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.2 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[24]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.3 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.[34]$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.1)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.1$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.2)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.2$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.3)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.3$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n")))

      (let [keywords (keywords-for 5.4)]
        (when (> (length keywords) 0)
          (out:write "if match(s:lua_version, '^5\\.4$') > -1\n")
          (each [_ keyword (ipairs (utils.sorted keywords))]
            (out:write (.. "  syn keyword fennelLuaKeyword " keyword "\n")))
          (out:write "endif\n"))))))

(main)
