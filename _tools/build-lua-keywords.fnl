#!/usr/bin/env fennel

(local unpack (or _G.unpack table.unpack))
(local https (require :ssl.https))
(local gumbo (require :gumbo))


(macro immutably [mutator! tbl & args]
  (let [copy `(fn [tbl#]
                (collect [k# v# (pairs tbl#)]
                  (values k# v#)))]
    `(let [clone# (,copy ,tbl)]
       (doto clone#
         (,mutator! ,(unpack args))))))


(fn update! [tbl key function default]
  (set (. tbl key) (function (or (. tbl key) default))))

(fn copy [tbl]
  (collect [k v (pairs tbl)]
    (values k v)))

(fn keys [tbl]
  (icollect [key (pairs tbl)] key))


(fn append! [seq* & seqs]
  (each [_ seq (ipairs seqs)]
    (each [_ item (ipairs seq)]
      (table.insert seq* item))))

(fn unkeys [seq ?generator]
  (collect [_ item (ipairs seq)]
    (values item ((or ?generator #true) item))))

(fn unique [seq]
  (keys (unkeys seq)))


(fn union! [x* & xs]
  (each [_ x (ipairs xs)]
    (each [k v (pairs x)]
      (set (. x* k) v))))

(fn difference! [x* & xs]
  (each [_ x (ipairs xs)]
    (each [k _ (pairs x)]
      (set (. x* k) nil))))

(fn intersection! [x* & xs]
  (each [_ x (ipairs xs)]
    (each [k _ (pairs x*)]
      (when (not (. x k))
        (set (. x* k) nil)))))

(fn powerset [tbl]
  (accumulate [sets [{}] k v (pairs tbl)]
    (doto sets
      (append! (icollect [_ s (ipairs sets)]
                 (doto (copy s)
                   (tset k v)))))))


(local log (let [mt {}]
             (set mt.__index mt)
             (set mt.severity (if (os.getenv :DEBUG) 0 1))
             (fn mt.__call [_ ...]
               (io.stderr:write ...)
               (io.stderr:write "\n"))
             (fn mt.debug [self ...]
               (when (>= 0 self.severity)
                 (self "DEBUG: " ...)))
             (fn mt.info [self ...]
               (when (>= 1 self.severity)
                 (self "INFO: " ...)))
             (fn mt.warn [self ...]
               (when (>= 2 self.severity)
                 (self "WARNING: " ...)))
             (fn mt.error [self ...]
               (when (>= 3 self.severity)
                 (self "ERROR: " ...)))
             (setmetatable {} mt)))


(local file {})

(fn file.exists? [path]
  (case (io.open path)
    any (do (any:close) true)
    _ false))

(fn file.read-all [file/path]
  (case (io.type file/path)
    any (file/path:read :*a)
    _ (case (io.open file/path)
        file (file:read :*a)
        (_ msg) (error msg))))

(fn file.normalize [path]
  (pick-values 1 (path:gsub "/+" "/")))

(fn file.dirname [path]
  (let [path (file.normalize path)]
    (if (= "/" path)
        path
        (case-try (path:match "(.-)/?$")
          path (path:match "^(.*)/")
          path path
          (catch _ ".")))))


(local lua_ (let [mt {}]
              (set mt.__index mt)
              (set mt.versions {:5.1 true
                                :5.2 true
                                :5.3 true
                                :5.4 true
                                :5.5 true})
              (fn mt.version? [self x]
                (let [x (tostring x)]
                  (or (. self.versions x) false)))
              (fn mt.complement-versions [self versions]
                (->> (unkeys versions)
                     (immutably difference! self.versions)
                     (keys)))
              (setmetatable {} mt)))


(local manual {})

(fn manual.fetch [version]
  (assert (lua_:version? version)
          (.. "Invalid Lua version " version))
  (let [name (.. "Lua " version " manual")
        url (.. "https://www.lua.org/manual/" version "/")]
    (log:info "Fetching " name)
    (case (https.request url)
      (body 200) (do 
                   (log:debug "Fetched " name)
                   body)
      _ (do
          (log:error "Failed to fetch " name)
          (os.exit 1)))))

(fn manual.fetch/cache [version]
  (fn cache [path thunk]
    (if (file.exists? path)
        (file.read-all path)
        (let [data (thunk)]
          (case (let [dir (file.dirname path)]
                   (os.execute (.. "mkdir -p " dir)))
            any (with-open [out (io.open path :w)]
                  (out:write data))
            (_ msg) (error msg))
          data)))
  (let [path (.. ".cache/www.lua.org/manual/" version "/manual.html")]
    (cache path #(manual.fetch version))))

(fn manual.extract-keywords [lua-manual]
  (fn keyword? [elem]
    (if (and
          (case (?. elem :attributes :href)
            href (string.find (. href :value) "#pdf-")
            _ false)
          (case (?. elem :innerHTML)
            html (and
                   (not (string.find html "^LUAL?_"))
                   (not (string.find html "^__"))
                   (not (string.find html "^%w+:"))
                   (not (string.find html "^luaopen_")))
            _ false))
        true
        false))
  (let [parsed (gumbo.parse lua-manual)]
    (icollect [_ elem (ipairs (parsed:getElementsByTagName :a))]
      (when (keyword? elem)
        (. elem :innerHTML)))))


(fn lua_.keywords [& versions]
  (unpack (icollect [_ version (ipairs (unique versions))]
            (-> (manual.fetch/cache version)
                (manual.extract-keywords)
                (unkeys)))))

(fn lua_.keywords/join-by [set-operation versions]
  (let [keyword-sets [(lua_.keywords (unpack versions))]]
    (case (length keyword-sets)
      0 {}
      1 (. keyword-sets 1)
      _ (let [[x & xs] keyword-sets]
          (doto x
            (set-operation (unpack xs)))))))

(fn lua_.keywords/exclusive [versions]
  (let [other-versions (lua_:complement-versions versions)
        common-keywords (lua_.keywords/join-by intersection! versions)
        other-keywords (lua_.keywords/join-by union! other-versions)]
    (immutably difference! common-keywords other-keywords)))

(fn lua_.regex [versions]
  (let [versions (doto (unique versions)
                   (table.sort))
        minors (accumulate [acc "" _ v (ipairs versions)]
                 (.. acc (string.sub v 3 3)))]
    (case (length versions)
      0 (error "missing versions for creating regex")
      1 (.. "^5\\." minors "$")
      _ (.. "^5\\.[" minors "]$"))))


(local writer {})

(fn writer.wrap-lines [seq width sep]
  (let [sep (or sep " ")
        {: lines : buf}
        (accumulate [state {:lines {} :buf ""}
                     _ s (ipairs seq)]
          (if (< width (+ (state.buf:len) (sep:len) (s:len)))
              (doto state
                (update! :lines #(doto $ (table.insert state.buf)))
                (tset :buf s))
              (doto state
                (tset :buf (.. state.buf (if (= state.buf "") "" sep) s)))))]
    (when (not= buf "")
      (table.insert lines buf))
    lines))

(fn writer.write-keywords [out versions]
  (let [keywords (lua_.keywords/exclusive versions)]
    (when (next keywords)
      (let [conditional? (< 0 (length (lua_:complement-versions versions)))]
        (when conditional?
          (out:write "if match(s:lua_version, '"
                     (lua_.regex versions)
                     "') > -1\n"))
        (each [_ chunk (ipairs (writer.wrap-lines (doto (keys keywords)
                                                    (table.sort))
                                                  (if conditional? 68 70)))]
          (out:write (if conditional? "  " "")
                     "syn keyword fennelLuaKeyword "
                     chunk
                     "\n"))
        (when conditional?
          (out:write "endif\n"))))))


(let [target "syntax/fennel-lua.vim"
      combinations-of-versions
      (doto (icollect [_ versions (ipairs (powerset lua_.versions))]
              (doto (keys versions)
                (table.sort)))
        (table.sort (fn [l r]
                      (case (values (length l) (length r))
                        (where (n m) (< m n)) true
                        (where (n m) (< n m)) false
                        _ (< (. l 1) (. r 1))))))]
  (with-open [out (assert (io.open target :w))]
    (out:write "\" Vim syntax file\n"
               "\" Language: Fennel\n"
               "\" Last Change: " (os.date "%Y-%m-%d") "\n"
               "\" Maintainer: NACAMURA Mitsuhiro <m15@m15a.dev>\n"
               "\" URL: https://github.com/m15a/vim-fennel-syntax\n"
               "\" License: MIT\n"
               "\" NOTE: Automatically generated by " (. arg 0) ". DO NOT EDIT!\n"
               "\n"
               "if !exists('b:did_fennel_syntax')\n"
               "  finish\n"
               "endif\n"
               "\n"
               "let s:lua_version = fennel#GetOption('lua_version', fennel#GetLuaVersion())\n"
               "\n")
    (each [_ versions (ipairs combinations-of-versions)]
      (writer.write-keywords out versions)))
  (log:info "Generated " target)
  (os.exit true))
