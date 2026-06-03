# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #101.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? Box("SOFTANZA") + NL
#-->
'
┌──────────┐
│ SOFTANZA │
└──────────┘
'

? Box(Box("SOFTANZA")) + NL
#-->
'
┌──────────────┐
│ ┌──────────┐ │
│ │ SOFTANZA │ │
│ └──────────┘ │
└──────────────┘
'

? BoxRound(BoxRound(Box("SOFTANZA")))
#-->
'
╭──────────────────╮
│ ╭──────────────╮ │
│ │ ┌──────────┐ │ │
│ │ │ SOFTANZA │ │ │
│ │ └──────────┘ │ │
│ ╰──────────────╯ │
╰──────────────────╯
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
