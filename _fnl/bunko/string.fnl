;;;; =========================================================================
;;;; Utilities for string manipulation.
;;;; =========================================================================
;;;; 
;;;; URL: https://github.com/m15a/fennel-bunko
;;;; License: Unlicense
;;;; 
;;;; This is free and unencumbered software released into the public domain.
;;;; 
;;;; Anyone is free to copy, modify, publish, use, compile, sell, or
;;;; distribute this software, either in source code form or as a compiled
;;;; binary, for any purpose, commercial or non-commercial, and by any
;;;; means.
;;;; 
;;;; In jurisdictions that recognize copyright laws, the author or authors
;;;; of this software dedicate any and all copyright interest in the
;;;; software to the public domain. We make this dedication for the benefit
;;;; of the public at large and to the detriment of our heirs and
;;;; successors. We intend this dedication to be an overt act of
;;;; relinquishment in perpetuity of all present and future rights to this
;;;; software under copyright law.
;;;; 
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;;;; IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
;;;; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;;;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;;; OTHER DEALINGS IN THE SOFTWARE.
;;;; 
;;;; For more information, please refer to <https://unlicense.org>

(import-macros {: assert-type} :bunko.macros)

(fn escape-regex [str]
  "Escape magic characters of Lua regex pattern in the `string`.

Return the escaped string.
The magic characters are namely `^$()%.[]*+-?`.
See the [Lua manual][1] for more detail.

[1]: https://www.lua.org/manual/5.4/manual.html#6.4.1

# Examples

```fennel :skip-test
(escape-regex \"%\") ;=> \"%%\"
```"
  {:fnl/arglist [string]}
  (pick-values 1 (: (assert-type :string str) :gsub
                    "([%^%$%(%)%%%.%[%]%*%+%-%?])" "%%%1")))

{: escape-regex}
