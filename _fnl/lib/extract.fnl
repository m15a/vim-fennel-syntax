(local unpack (or table.unpack _G.unpack))
(local https (require :ssl.https))
(local gumbo (require :gumbo))
(local {: dirname : exists? : read-all} (require :bunko.file))

(fn cache [path thunk]
  "Use cache if it exists. Otherwise, call thunk, generate data, and store it."
  (let [err io.stderr]
    (if (exists? path)
        (read-all path)
        (do
          (err:write "Cache not found. Try to fetch it.\n")
          (let [data (thunk)]
            (case (let [dir (dirname path)]
                     (err:write (.. "Create directory: " dir "\n"))
                     (os.execute (.. "mkdir -p " dir)))
              any (with-open [out (io.open path :w)]
                    (out:write data)
                    (err:write (.. "Cached data: " path "\n")))
              (_ msg code) (error msg))
            data)))))

(macro assert-lua-version [string]
  `(do (assert (string.match ,string "^5%.[1-4]$")
               (string.format "Invalid Lua version: %s\n" ,string))
       ,string))

(fn %fetch-lua-manual [version]
  (let [err io.stderr]
    (err:write (string.format "Fetching Lua %s manual\n" version))
    (match (https.request (.. "https://www.lua.org/manual/" version "/"))
      (body 200) (do (err:write (string.format "Fetched Lua %s manual\n" version))
                     body)
      _ (error (string.format "Failed to fetch Lua %s manual\n" version)))))

(fn fetch-lua-manual [version]
  "Fetch Lua manual html of the version from <www.lua.org>."
  (let [version (assert-lua-version version)
        path (.. ".cache/www.lua.org/manual/" version "/manual.html")]
    (cache path #(%fetch-lua-manual version))))

(fn extract-lua-keywords [lua-manual]
  "Extract keywords from Lua manual html body."
  (let [parsed (gumbo.parse lua-manual)]
    (icollect [_ item (ipairs (parsed:getElementsByTagName :a))]
      (when (and
              (. item :attributes :href)
              (string.find (. item :attributes :href :value) "#pdf-")
              (not (string.find item.innerHTML "^LUAL?_"))
              (not (string.find item.innerHTML "^__"))
              (not (string.find item.innerHTML "^%w+:"))
              (not (string.find item.innerHTML "^luaopen_")))
        item.innerHTML))))

{: fetch-lua-manual
 : extract-lua-keywords}
