# Narrative
# --------
# pr()
#
# Extracted from stznaturaltest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = Naturally("
    Create a string with ' hello  '
    Trim it
    Capitalize it
")

o2 = Naturally("
    Create a string with ' niamy  '
    Trim it
    Capitalize it
")

? BoxRound( o1.Result() + " " + o2.Result() )
#-->
# ╭─────────────╮
# │ Hello Niamy │
# ╰─────────────╯

? o1.Code()

pf()

# Executed in 0.02 second(s) in Ring 1.24
