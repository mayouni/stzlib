# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #9.

load "../../stzBase.ring"

pr()

CheckParamsOff()

o1 = new stzTable([

	:NAME =  [ "Bob", "Dan", "Roy" ],
	:SCORE = [ 89, 120, 100 ]

])

? o1.Show() 	// #NOTE this is a mispelled form of Show()
#-->
'
╭──────┬───────╮
│ Name │ Score │
├──────┼───────┤
│ Bob  │    89 │
│ Dan  │   120 │
│ Roy  │   100 │
╰──────┴───────╯
'

o1.SortOnDown(:SCORE) # Or SortOnInDescending()

? o1.Show()
#-->
'
╭───────┬──────╮
│ Score │ Name │
├───────┼──────┤
│    89 │ Bob  │
│   120 │ Dan  │
│   100 │ Roy  │
╰───────┴──────╯
'

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.10 second(s) in Ring 1.21
