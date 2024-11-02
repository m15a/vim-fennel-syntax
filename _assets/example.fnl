#!/usr/bin/env fennel

;; String literals
"* Bell, backspace, etc.: \a, \b, \f, \n, \r, \t, \v, \\, \", and \'
\z    * `\\z` skips the following whitespaces including linebreaks (Lua 5.2-)
* Characters speficied by number: e.g., \013 (Lua 5.1-) and \xAB (Lua 5.2-)
* Unicode characters speficied by number: e.g., \u{1F600} (Lua 5.3-)"

(local numeric-literals
       {:lua_5.1 [3 3.0 3.1416 314.16e-2 0.31416E1 0xff 0x56]
        :lua_5.2 [0x0.1E 0xA23p-4 0X1.921FB54442D18P+1]})

(assert (< 10e6 .inf) "Added in Fennel 1.5.1")
(assert (not= .nan .nan) "ditto.")

(λ major-minor [version]
  "Docstring."
  (values (string.sub version 5 5)
          (tonumber (version:sub 7 7))))

(macro message [major minor number]
  `(print (.. "Lua " ,major "." ,minor " can understand " ,number)))

(fn main []
  (each [version numbers (pairs numeric-literals)]
    (each [_ number (ipairs numbers)]
      (case (major-minor version)
        (where (major minor) (= minor 1)) (message major minor number)
        (major minor) (#(message $1 $2 $3) major minor number)))))

(main)
