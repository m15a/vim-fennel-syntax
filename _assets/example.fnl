#!/usr/bin/env fennel
;;;
;;; Showcase of Fennel syntax elements

(local lua-string-literals "
* Bell, backspace, etc.: \a, \b, \f, \n, \r, \t, \v, \\, \", and \'
\z    * `\\z` skips the following whitespaces including linebreaks (Lua 5.2-)
* Characters speficied by number: e.g., \013 (Lua 5.1-) and \xAB (Lua 5.2-)
* Unicode characters speficied by number: e.g., \u{1F600} (Lua 5.3-)
")

(local lua-numeric-literals
       {:lua5_1 [3 3.0 3.1416 314.16e-2 0.31416E1 0xff 0x56]
        :lua5_2 [0x0.1E 0xA23p-4 0X1.921FB54442D18P+1]})

(fn function []
  "Docstring"
  (each [lua_ver numbers (pairs lua-numeric-literals)]
    (each [_ number (ipairs numbers)]
      (match (values (string.sub lua_ver 4 4)
                     (string.sub lua_ver 6 6))
        (where (major minor) (= minor "1"))
        (print (.. "Lua " major "." minor " can understand " number))
        (where (major minor) (= minor "2"))
        (#(print (.. "Lua " $1 "." $2 " can understand " $3)) major minor number)))))
