# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #9.

load "../../../stzBase.ring"


CheckParamsOff()

o1 = new stzTable([

	:NAME =  [ "Bob", "Dan", "Roy" ],
	:SCORE = [ 89, 120, 100 ]

])

? o1.Show() 	// #NOTE this is a mispelled form of Show()
#-->
'
â•­â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â•®
â”‚ Name â”‚ Score â”‚
â”œâ”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Bob  â”‚    89 â”‚
â”‚ Dan  â”‚   120 â”‚
â”‚ Roy  â”‚   100 â”‚
â•°â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â•¯
'

o1.SortOnDown(:SCORE) # Or SortOnInDescending()

? o1.Show()
#-->
'
â•­â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â•®
â”‚ Name â”‚ Score â”‚
â”œâ”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Dan  â”‚   120 â”‚
â”‚ Roy  â”‚   100 â”‚
â”‚ Bob  â”‚    89 â”‚
â•°â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â•¯
'

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.10 second(s) in Ring 1.21
