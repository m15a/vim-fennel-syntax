#!/usr/bin/env fennel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utilities

(macro accumulate [iter-tbl accum-expr ...]
  "Accumulate values of the given iterator.
Example:
  (let [tbl {:a 1 :b 2 :c 3}]
    (accumulate [n 0 _ _ (pairs tbl)]
      (+ n 1))) ;=> 3"
  (assert (and (sequence? iter-tbl) (>= (length iter-tbl) 4))
          "expected iterator binding table")
  (assert (not= nil accum-expr) "expected accumulating expression")
  (assert (= nil ...)
          "expected exactly one body expression. Wrap multiple expressions with do")
  (let [acc (table.remove iter-tbl 1)]
    `(do (var ,acc ,(table.remove iter-tbl 1))
         (each ,iter-tbl
           (match ,accum-expr
             v# (set ,acc v#)))
         ,acc)))

(local utils {})

(fn utils.cloned [tbl]
  "Return a clone of the table."
  (setmetatable (collect [k v (pairs tbl)]
                  (values k v))
                (getmetatable tbl)))

(fn utils.modified [tbl key value]
  "Returns a clone of the table, having key modified to the value."
  (let [cloned (utils.cloned tbl)]
    (tset cloned key value)
    cloned))

(set utils.set (let [class {}]
                 (tset class :__index class)
                 class))

(fn utils.set.new [...]
  "Create a new set filled with items in `...`."
  (let [self (collect [_ item (ipairs [...])]
               (values item true))]
    (setmetatable self utils.set)))

(fn utils.set.cardinality [self]
  "Return the cardinality of the set."
  (accumulate [n 0 _ _ (pairs self)]
    (+ n 1)))

(fn utils.set.intersection [self ...]
  "Return the intersection of the sets."
  (fn intersection_ [left right]
    (accumulate [items left
                 item _ (pairs left)]
      (when (= (. right item) nil)
        (utils.modified items item nil))))
  (accumulate [items self
               _ one (ipairs [...])]
    (intersection_ items one)))

(tset utils.set :__mul utils.set.intersection)

(fn utils.set.difference [self ...]
  "Return the difference between the first set and the rest sets."
  (fn difference_ [left right]
    (accumulate [items left
                 item _ (pairs right)]
      (utils.modified items item nil)))
  (accumulate [items self
               _ one (ipairs [...])]
    (difference_ items one)))

(tset utils.set :__sub utils.set.difference)

(fn utils.exists? [file]
  "Does the file exists?"
  (match (io.open file)
    any (do (any:close) true)
    _ false))

(fn utils.slurp [file]
  "Read all contents of the file."
  (with-open [in (io.open file)]
    (in:read :*all)))

(fn utils.keys [tbl]
  "Return all keys in the table."
  (icollect [k _ (pairs tbl)] k))

(fn utils.sorted [tbl]
  "Return a sorted clone of the sequencial table."
  (let [cloned (utils.cloned tbl)]
    (table.sort cloned)
    cloned))

(fn utils.imap [seq f]
  "Map a function to the sequencial table."
  (icollect [_ x (ipairs seq)] (f x)))

(fn utils.map [tbl f]
  "Map a function to the non-sequencial table."
  (icollect [k v (pairs tbl)] (f k v)))

(fn utils.insert [seq item]
  "Insert an item to the sequencial table and return the table."
  (do (table.insert seq item)
      seq))

(fn utils.wrap-lines [seq width sep]
  "Return a table of strings concatinated with the sep, each line wrapped by the given width."
  (let [sep (or sep " ")
        out (accumulate [state {:lines {} :buf ""}
                         _ s (ipairs seq)]
              (if (> (+ (string.len state.buf) (string.len sep) (string.len s))
                     width)
                  (-> state
                      (utils.modified :lines (utils.insert state.lines state.buf))
                      (utils.modified :buf s))
                  (-> state
                      (utils.modified :buf (.. state.buf
                                               (if (= state.buf "") "" sep)
                                               s)))))]
    (when (not= out.buf "")
      (table.insert out.lines out.buf))
    out.lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Library

(local http (require :socket.http))
(local gumbo (require :gumbo))

(fn fetch-lua-manual [version]
  "Fetch Lua manual html of the given version from www.lua.org."
  (if (not (string.match version "^5%.[1-4]$"))
      (do (io.stderr:write (string.format "Invalid Lua version: %s\n" version))
          nil)
      (let [cache (.. ".cache/" version ".html")]
        (os.execute "mkdir -p .cache")
        (if (utils.exists? cache)
            (gumbo.parse (utils.slurp cache))
            (match (http.request (.. "https://www.lua.org/manual/" version "/"))
              (body 200) (do (io.stderr:write
                               (string.format "Fetched Lua %s manual\n" version))
                             (with-open [out (io.open cache :w)]
                               (out:write body))
                             (gumbo.parse body))
              _          (do (io.stderr:write
                               (string.format "Failed to fetch Lua %s manual\n" version))
                             nil))))))

(fn extract-keywords [lua-manual]
  "Extract keywords from Lua manual html body."
  (icollect [_ item (ipairs (lua-manual:getElementsByTagName :a))]
    (when (and (. item :attributes :href)
               (string.find (. item :attributes :href :value) "#pdf-")
               (not (string.find item.innerHTML "^LUAL?_"))
               (not (string.find item.innerHTML "^__"))
               (not (string.find item.innerHTML "^%w+:"))
               (not (string.find item.innerHTML "^luaopen_")))
      item.innerHTML)))

(local *versions* [5.1 5.2 5.3 5.4])

(local *keywords* (collect [_ v (ipairs *versions*)]
                    (values v (utils.set.new (unpack (extract-keywords (fetch-lua-manual v)))))))

(fn keywords-for [...]
  "Select Lua keywords exclusively available for the given Lua versions."
  (let [*versions* (utils.set.new (unpack *versions*))
        versions (utils.set.new ...)
        other-versions (- *versions* versions)]
    (utils.set.difference (utils.set.intersection (unpack (utils.map versions #(. *keywords* $1))))
                     (unpack (utils.map other-versions #(. *keywords* $1))))))

(fn version-regex [versions]
  "Create Lua version regex for the given versions."
  (let [ss (table.concat (utils.imap versions #(string.sub $ 3 3)))]
    (match (length versions)
      0 (do (io.stderr:write "Missing versions for creating regex.")
            nil)
      1 (.. "^5\\." ss "$")
      n (.. "^5\\.[" ss "]$"))))

(fn write-keywords [out versions]
  "Write keywords for the given Lua versions to the output port."
  (let [keywords (keywords-for (unpack versions))]
    (when (> (keywords:cardinality) 0)
      (let [conditional? (> (utils.set.cardinality (- (utils.set.new (unpack *versions*))
                                                      (utils.set.new (unpack versions))))
                            0)]
        (when conditional?
          (out:write (.. "if match(s:lua_version, '" (version-regex versions) "') > -1\n")))
        (each [_ chunk (ipairs (utils.wrap-lines (utils.sorted (utils.keys keywords))
                                                 (if conditional? 68 70)))]
          (out:write (.. (if conditional? "  " "")
                         "syn keyword fennelLuaKeyword "
                         chunk
                         "\n")))
        (when conditional?
          (out:write "endif\n"))))))

(fn usage [synopsis description ...]
  "Print usage information."
  (let [script-name (. arg 0)
        out io.stderr]
    (-> (table.concat [(string.format "Usage: %s %s" script-name synopsis)
                       description
                       ...]
                      "\n")
        (out:write))
    (out:write "\n"))
  (os.exit 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Commands

(fn build-lua-keywords []
  "Build syntax/fennel-lua.vim by scraping Lua reference manuals."
  (let [target "syntax/fennel-lua.vim"]
    (with-open [out (io.open target :w)]
      (out:write (.. "\" Vim syntax file
\z      \" Language: Fennel
\z      \" Last Change: " (os.date "%Y-%m-%d") "
\z      \" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
\z      \" URL: https://github.com/mnacamura/vim-fennel-syntax
\z      \" License: MIT
\z      \" NOTE: Automatically generated by build.fnl. DO NOT EDIT!

\z      if !exists('b:did_fennel_syntax')
  \z      finish
\z      endif

\z      let s:lua_version = fennel#GetOption('lua_version', fennel#GetLuaVersion())

\z      "))
      (each [_ versions (ipairs [[5.1 5.2 5.3 5.4]
                                 [5.1 5.2 5.3]
                                 [5.1 5.2 5.4]
                                 [5.1 5.3 5.4]
                                 [5.2 5.3 5.4]
                                 [5.1 5.2]
                                 [5.1 5.3]
                                 [5.1 5.4]
                                 [5.2 5.3]
                                 [5.2 5.4]
                                 [5.3 5.4]
                                 [5.1]
                                 [5.2]
                                 [5.3]
                                 [5.4]])]
        (write-keywords out versions)))
    (io.stderr:write (string.format "Generated %s\n" target))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Main

(fn main []
  (let [command (. arg 1)]
    (match command
      :lua-keywords (build-lua-keywords)
      _ (usage "<command> [<arg> ...]"
               "Commands:"
               "    lua-keywords\tBuild syntax/fennel-lua.vim by scraping Lua reference manuals."))))

(main)
