#!/usr/bin/env fennel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utilities

(macro accum [iter-tbl accum-expr ...]
  "Accumulate values produced by the iterator.
Example:
  (accum [n 0 _ _ (pairs {:a 1 :b 2 :c 3})]
    (+ n 1)) ;=> 3"
  (assert (and (sequence? iter-tbl) (>= (length iter-tbl) 4))
          "expected initial value and iterator binding table")
  (assert (not= nil accum-expr)
          "expected accumulating expression")
  (assert (= nil ...)
          "expected exactly one body expression.")
  (let [acc (table.remove iter-tbl 1)]
    `(do (var ,acc ,(table.remove iter-tbl 1))
         (each ,iter-tbl
           (set ,acc ,accum-expr))
         ,acc)))

(local utils {})

(fn utils.clone [tbl]
  "Return a clone of the table."
  (let [cloned (collect [k v (pairs tbl)]
                  (values k v))]
    (setmetatable cloned (getmetatable tbl))))

(fn utils.modify [tbl key value]
  "Return a clone of the table, having key modified to the value."
  (let [cloned (utils.clone tbl)]
    (tset cloned key value)
    cloned))

(fn utils.insert [seq ...]
  "Insert an item to the sequencial table and return the table."
  (table.insert seq ...)
  seq)

(fn utils.join [...]
  "Join all the tables."
  (accum [joined []
          _ tbl (ipairs [...])]
    (accum [joined joined
            _ item (ipairs tbl)]
      (utils.insert joined item))))

(set utils.set (let [class {}]
                 (tset class :__index class)
                 class))

(fn utils.set.new [...]
  "Create a new set filled with the given items."
  (let [self (collect [_ item (ipairs [...])]
               (values item true))]
    (setmetatable self utils.set)))

(fn utils.set.unpack [seq]
  "Create a new set filled with items in the sequential table."
  (utils.set.new (unpack seq)))

(fn utils.set.pack [self]
  "Convert the set to a sequencial table."
  (icollect [item _ (pairs self)] item))

(fn utils.set.cardinality [self]
  "Return the cardinality of the set."
  (accum [n 0 _ _ (pairs self)]
    (+ n 1)))

(fn _intersection [left right]
  (accum [items left
          item _ (pairs left)]
    (if (= (. right item) nil)
        (utils.modify items item nil)
        items)))

(fn utils.set.intersection [self ...]
  "Return the intersection of the sets."
  (accum [left self
          _ right (ipairs [...])]
    (_intersection left right)))

(tset utils.set :__mul _intersection)

(fn _difference [left right]
  (accum [items left
          item _ (pairs right)]
    (utils.modify items item nil)))

(fn utils.set.difference [self ...]
  "Return the difference between the first set and the rest sets."
  (accum [left self
          _ right (ipairs [...])]
    (_difference left right)))

(tset utils.set :__sub _difference)

(fn utils.set.powerset [self]
  "Return the powerset of the set."
  (accum [powerset [(utils.set.new)]
          item _ (pairs self)]
    (utils.join powerset
                (icollect [_ one (ipairs powerset)]
                  (utils.modify one item true)))))

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

(fn utils.sort [tbl ...]
  "Return a sorted clone of the sequencial table."
  (let [cloned (utils.clone tbl)]
    (table.sort cloned ...)
    cloned))

(fn utils.imap [seq f]
  "Map a function to the sequencial table."
  (icollect [_ x (ipairs seq)]
    (f x)))

(fn utils.map [tbl f]
  "Map a function to the non-sequencial table."
  (icollect [k v (pairs tbl)]
    (f k v)))

(fn utils.ifilter [seq pred]
  "Filter out items in the sequential table by the predicate."
  (icollect [_ x (ipairs seq)]
    (when (pred x)
      x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Library

(local http (require :socket.http))
(local gumbo (require :gumbo))

(fn fetch-lua-manual [version]
  "Fetch Lua manual html of the given version from www.lua.org."
  (assert (string.match version "^5%.[1-4]$")
          (string.format "Invalid Lua version: %s\n" version))
  (let [cache-dir ".cache"
        cache (.. cache-dir "/" version ".html")]
    (os.execute (.. "mkdir -p " cache-dir))
    (if (utils.exists? cache)
        (gumbo.parse (utils.slurp cache))
        (match (http.request (.. "https://www.lua.org/manual/" version "/"))
          (body 200) (do (io.stderr:write (string.format "Fetched Lua %s manual\n" version))
                         (with-open [out (io.open cache :w)]
                           (out:write body))
                         (gumbo.parse body))
          _ (error (string.format "Failed to fetch Lua %s manual\n" version))))))

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
                    (values v (-> v
                                  (fetch-lua-manual)
                                  (extract-keywords)
                                  (utils.set.unpack)))))

(fn keywords-for [...]
  "Select Lua keywords exclusively available for the given Lua versions."
  (let [*versions* (utils.set.unpack *versions*)
        versions (utils.set.new ...)
        other-versions (- *versions* versions)]
    (utils.set.difference
      (utils.set.intersection (unpack (utils.map versions #(. *keywords* $1))))
      (unpack (utils.map other-versions #(. *keywords* $1))))))

(fn version-regex [versions]
  "Create Lua version regex for the given versions."
  (let [minors (accum [acc "" _ v (ipairs versions)]
                 (.. acc (string.sub v 3 3)))]
    (match (length versions)
      0 (error "Missing versions for creating regex.")
      1 (.. "^5\\." minors "$")
      n (.. "^5\\.[" minors "]$"))))

(fn wrapped-lines [seq width sep]
  "Return a table of strings concatinated with the sep, each line wrapped by the given width."
  (let [sep (or sep " ")
        {: lines : buf} (accum [state {:lines {} :buf ""}
                                _ s (ipairs seq)]
                          (if (> (+ (string.len state.buf) (string.len sep) (string.len s))
                                 width)
                              (-> state
                                  (utils.modify :lines (utils.insert state.lines state.buf))
                                  (utils.modify :buf s))
                              (-> state
                                  (utils.modify :buf (.. state.buf
                                                         (if (= state.buf "") "" sep)
                                                         s)))))]
    (when (not= buf "")
      (table.insert lines buf))
    lines))

(fn write-keywords [out versions]
  "Write keywords for the given Lua versions to the output port."
  (let [keywords (keywords-for (unpack versions))]
    (when (> (keywords:cardinality) 0)
      (let [conditional? (> (utils.set.cardinality (- (utils.set.unpack *versions*)
                                                      (utils.set.unpack versions)))
                            0)]
        (when conditional?
          (out:write (.. "if match(s:lua_version, '" (version-regex versions) "') > -1\n")))
        (each [_ chunk (ipairs (wrapped-lines (utils.sort (utils.keys keywords))
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
      (each [_ versions (ipairs (-> (utils.set.new 5.1 5.2 5.3 5.4)
                                    (utils.set.powerset)
                                    (utils.imap utils.set.pack)
                                    (utils.ifilter #(> (length $) 0))
                                    (utils.imap utils.sort)
                                    (utils.sort (fn [l r] (match (values (length l) (length r))
                                                            (where (n m) (> n m)) true
                                                            (where (n m) (< n m)) false
                                                            _ (match (values (. l 1) (. r 1))
                                                                (a b) (< a b)
                                                                _ (error "Unreachable!")))))))]
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
