# Narrative
# --------
# The VizFind* wrap width is a global default, read/changed with these globals:
#   DefaultVizWidth()  -- the current width (50 out of the box)
#   SetVizWidth(n)     -- change it (n < 1 falls back to 50)
#   ResetVizWidth()    -- restore 50
# Every VizFind / VizFindXT / VizFindMany / VizDeepFind form honours it.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A","B","A","C","A","D","E","A","B","F","A","C","A","G","A" ])

? DefaultVizWidth()
#--> 50

# At the default 50, this list is too wide and wraps into two blocks
? o1.VizFindXT("A")
#-->       [ "A", "B", "A", "C", "A", "D", "E", "A", "B", "F"
#    "A" :  --^---------^---------^--------------^-----------
#
#           , "A", "C", "A", "G", "A" ]
#    "A" : ---^---------^---------^--- (7)

? ""

# Widen to 80 -- now it fits on a single line
? SetVizWidth(80)
#--> 80

? DefaultVizWidth()
#--> 80

? o1.VizFindXT("A")
#-->       [ "A", "B", "A", "C", "A", "D", "E", "A", "B", "F", "A", "C", "A", "G", "A" ]
#    "A" :  --^---------^---------^--------------^--------------^---------^---------^--- (7)

? ""

# Narrow to 30 -- now it wraps into three blocks
SetVizWidth(30)
? o1.VizFindXT("A")
#-->       [ "A", "B", "A", "C", "A", "D"
#    "A" :  --^---------^---------^------
#
#           , "E", "A", "B", "F", "A", "C"
#    "A" : --------^--------------^------
#
#           , "A", "G", "A" ]
#    "A" : ---^---------^--- (7)

# Restore the default so later tests are unaffected
? ResetVizWidth()
#--> 50

pf()
# Executed in 0.01 second(s).
