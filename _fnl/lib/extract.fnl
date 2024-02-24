(local unpack (or table.unpack _G.unpack))
(local https (require :ssl.https))
(local gumbo (require :gumbo))
(local {: dirname : exists? : read-all} (require :bunko.file))
(local {: lua-version? : cache} (require :lib.utils))

(fn fetch-lua-manual [version]
  (let [err io.stderr]
    (err:write (string.format "Fetching Lua %s manual\n" version))
    (match (https.request (.. "https://www.lua.org/manual/" version "/"))
      (body 200) (do (err:write (string.format "Fetched Lua %s manual\n" version))
                     body)
      _ (error (string.format "Failed to fetch Lua %s manual\n" version)))))

(fn fetch-lua-manual-with-cache [version]
  "Fetch Lua manual HTML of the version from <www.lua.org> and return as a string."
  (assert (lua-version? version)
          (.. "invalid Lua version " version))
  (let [path (.. ".cache/www.lua.org/manual/" version "/manual.html")]
    (cache path #(fetch-lua-manual version))))

(fn lua-keyword? [element]
  "Check if the HTML element contains a Lua keyword."
  (if (and
        (case (?. element :attributes :href)
          href (string.find (. href :value) "#pdf-")
          _ false)
        (case (?. element :innerHTML)
          html (and
                 (not (string.find html "^LUAL?_"))
                 (not (string.find html "^__"))
                 (not (string.find html "^%w+:"))
                 (not (string.find html "^luaopen_")))
          _ false))
      true
      false))

(fn extract-lua-keywords [lua-manual]
  "Extract keywords from Lua manual HTML string and return a sequential table."
  (let [parsed (gumbo.parse lua-manual)]
    (icollect [_ element (ipairs (parsed:getElementsByTagName :a))]
      (when (lua-keyword? element)
        (. element :innerHTML)))))

{: fetch-lua-manual
 : fetch-lua-manual-with-cache
 : extract-lua-keywords}
