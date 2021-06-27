#!/usr/bin/env fennel

(local http (require :socket.http))
(local gumbo (require :gumbo))

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

(fn utils.wrap [seq tw sep]
  "Concatinate strings in the given sequential table with max length tw."
  (let [wrapped {}
        sep (or sep " ")]
    (var buf "")
    (each [_ s (ipairs seq)]
      (if (> (+ (string.len buf)
                (string.len sep)
                (string.len s))
             tw)
          (do (table.insert wrapped buf)
              (set buf s))
          (set buf (.. buf (if (= buf "") "" sep) s))))
    (when (not= buf "")
      (table.insert wrapped buf))
    wrapped))

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
              (body 200) (do (io.stderr:write (.. "Fetched Lua " version " manual\n"))
                             (with-open [out (io.open cache :w)]
                               (out:write body))
                             (gumbo.parse body))
              _          (do (io.stderr:write (.. "Failed to fetch Lua " version " manual\n"))
                             nil))))))

(fn extract-keywords [lua-manual]
  "Extract keywords from Lua manual html body."
  (let [keywords {}]
    (each [_ item (ipairs (lua-manual:getElementsByTagName :a))]
      (when (and (. item :attributes :href)
                 (string.find (. item :attributes :href :value) "#pdf-")
                 (not (string.find item.innerHTML "^LUAL?_"))
                 (not (string.find item.innerHTML "^__"))
                 (not (string.find item.innerHTML "^%w+:"))
                 (not (string.find item.innerHTML "^luaopen_")))
        (table.insert keywords item.innerHTML)))
    keywords))

(local *versions* [5.1 5.2 5.3 5.4])

(local *keywords* (collect [_ v (ipairs *versions*)]
                    (values v (extract-keywords (fetch-lua-manual v)))))

(fn keywords-for [...]
  "Select Lua keywords exclusively available for the given Lua versions."
  (let [versions [...]
        others (sets.difference *versions* versions)]
    (sets.difference (sets.intersection (unpack (utils.map versions #(. *keywords* $))))
                     (unpack (utils.map others #(. *keywords* $))))))

(fn version-regex [versions]
  "Create Lua version regex for the given versions."
  (let [ss (table.concat (utils.map versions #(string.sub $ 3 3)))]
    (match (length versions)
      0 (do (io.stderr:write "Missing versions for creating regex.")
            nil)
      1 (.. "^5\\." ss "$")
      n (.. "^5\\.[" ss "]$"))))

(fn write-keywords [out versions]
  "Write keywords for the given Lua versions to the given output port."
  (let [keywords (keywords-for (unpack versions))]
    (when (> (length keywords) 0)
      (let [conditional? (> (length (sets.difference *versions* versions))
                            0)]
        (when conditional?
          (out:write (.. "if match(s:lua_version, '" (version-regex versions) "') > -1\n")))
        (each [_ chunk (ipairs (utils.wrap (utils.sorted keywords)
                                           (if conditional? 68 70)))]
          (out:write (.. (if conditional? "  " "")
                         "syn keyword fennelLuaKeyword "
                         chunk
                         "\n")))
        (when conditional?
          (out:write "endif\n"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Main

(fn main []
  (local target "syntax/fennel-lua.vim")
  (with-open [out (io.open target :w)]
    (out:write (.. "\" Vim syntax file
\z      \" Language: Fennel
\z      \" Last Change: " (os.date "%Y-%m-%d") "
\z      \" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
\z      \" URL: https://github.com/mnacamura/vim-fennel-syntax
\z      \" License: MIT
\z      \" NOTE: Automatically generated by tools/build-lua-keywords.fnl. DO NOT EDIT!

\z      if !exists('b:did_fennel_syntax')
  \z      finish
\z      endif

\z      let s:lua_version = fennel#GetOption('lua_version', fennel#GetLuaVersion())

\z      "))
    (write-keywords out [5.1 5.2 5.3 5.4])
    (write-keywords out [5.1 5.2 5.3])
    (write-keywords out [5.1 5.2 5.4])
    (write-keywords out [5.1 5.3 5.4])
    (write-keywords out [5.2 5.3 5.4])
    (write-keywords out [5.1 5.2])
    (write-keywords out [5.1 5.3])
    (write-keywords out [5.1 5.4])
    (write-keywords out [5.2 5.3])
    (write-keywords out [5.2 5.4])
    (write-keywords out [5.3 5.4])
    (write-keywords out [5.1])
    (write-keywords out [5.2])
    (write-keywords out [5.3])
    (write-keywords out [5.4]))
  (io.stderr:write (.. "Generated " target "\n")))

(main)
