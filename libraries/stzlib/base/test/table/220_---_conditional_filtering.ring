# Narrative
# --------
# /*--- Conditional filtering
#
# Extracted from stztabletest.ring, block #220.

load "../../stzBase.ring"


pr()

o1 = new stzTable([
    [ :Productivity, :Hours ],
    [ 10, 5 ],
    [ 7, 3 ],
    [ 9, 4 ]
])

o1.Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# │            7 │     3 │
# │            9 │     4 │
# ╰──────────────┴───────╯

o1.FilterWQ('@(:Productivity) > 8').Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# │            9 │     4 │
# ╰──────────────┴───────╯

o1.FilterWQ('@(:Productivity) > 8 and @(:Hours) >= 5').Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# ╰──────────────┴───────╯

pf()
# Executed in 0.09 second(s) in Ring 1.22
