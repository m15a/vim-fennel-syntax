;;;; ==========================================================================
;;;; Set algebra on Lua table, where each table is regarded as a set of keys.
;;;; ==========================================================================
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

(import-macros {: assert-type : unless : immutably} :bunko.macros)
(local {: copy : merge! : append!} (require :bunko.table))

(fn subset? [left right]
  "Return `true` if the `left` table, regarded as a set, is subset of the `right`.

Return `false` otherwise."
  (assert-type :table left right)
  (accumulate [yes true key _ (pairs left) &until (not yes)]
    (if (. right key) yes false)))

(fn union! [...]
  "Modify the `table` to be the union of all the `table` and `tables`.

Each table is regarded as a set of keys, and its values just indicate that
the elements (i.e., keys) exist in the set.
`union!` is actually equivalent to `bunko.table.merge!`.

# Examples 

```fennel :skip-test
(doto {:a :a} (union! {:a 1} {:b :b})) ;=> {:a 1 :b :b}
```"
  {:fnl/arglist [table & tables]}
  (merge! ...))

(fn intersection! [tbl ...]
  "Modify the `table` to be the intersection of all the `table` and `tables`.

Each table is regarded as a set of keys, and its values just indicate that
the elements (i.e., keys) exist in the set.

# Examples 

```fennel :skip-test
(doto {:a :a :b :b} (intersection! {:a 1})) ;=> {:a :a}
```"
  {:fnl/arglist [table & tables]}
  (let [to (assert-type :table tbl)]
    (each [_ from (ipairs [(assert-type :table ...)])]
      (each [key _ (pairs to)]
        (unless (. from key) (tset to key nil))))))

(fn difference! [tbl ...]
  "Modify the `table` to be the difference between the `table` and the `tables`.

Each table is regarded as a set of keys, and its values just indicate that
the elements (i.e., keys) exist in the set.

# Examples 

```fennel :skip-test
(doto {:a :a :b :b} (difference! {:a 1} {:c :c})) ;=> {:b :b}
```"
  {:fnl/arglist [table & tables]}
  (let [to (assert-type :table tbl)]
    (each [_ from (ipairs [(assert-type :table ...)])]
      (each [key _ (pairs from)]
        (tset to key nil)))))

(fn powerset [tbl]
  "Return, as a sequential table, the power set of the `table`.

Each table is regarded as a set of keys, and its values just indicate that
the elements (i.e., keys) exist in the set.

# Examples

```fennel :skip-test
(powerset {:a 1 :b :b})
;=> [{} {:a 1} {:b :b} {:a 1 :b :b}]
; CAVEAT: The order could be different from the above example.
```"
  {:fnl/arglist [table]}
  (accumulate [sets [{}] key value (pairs (assert-type :table tbl))]
    (doto sets
      (append! (icollect [_ s (ipairs sets)]
                 (doto (copy s) (tset key value)))))))

{: subset? : union! : intersection! : difference! : powerset}
