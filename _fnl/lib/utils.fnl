(local unpack (or table.unpack _G.unpack))
(local {: update!} (require :bunko.table))

(fn unkeys [seq]
  "Create a table as a set from the given sequential table."
  (collect [_ k (ipairs seq)] k true))

(fn wrapped-lines [seq width sep]
  "Return a table of strings concatinated with the sep, each line wrapped by the width."
  (let [sep (or sep " ")
        {: lines : buf}
        (accumulate [state {:lines {} :buf ""}
                     _ s (ipairs seq)]
          (if (< width (+ (string.len state.buf) (string.len sep) (string.len s)))
              (doto state
                (update! :lines #(doto $ (table.insert state.buf)))
                (tset :buf s))
              (doto state
                (tset :buf (.. state.buf (if (= state.buf "") "" sep) s)))))]
    (when (not= buf "")
      (table.insert lines buf))
    lines))

{: unkeys : wrapped-lines}
