#!/usr/bin/env fennel

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

(fn lint []
  "Lint Vim scripts."
  (let [out io.stderr
        cmd "vint **/*.vim"] 
    (out:write "Run " cmd "\n")
    (os.execute cmd)))

(fn main []
  (let [command (. arg 1)]
    (match command
      :lint (lint)
      _ (usage "<command> [<arg> ...]"
               "Commands:"
               "    lint\tLint Vim scripts."))))

(main)
