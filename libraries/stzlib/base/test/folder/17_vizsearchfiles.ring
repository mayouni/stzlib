# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #17.
#ERR Error (R14) : Calling Method without definition: vizsearchfiles

load "../../stzBase.ring"

pr()

o1 = new stzFolder("D:\GitHub\stzlib\libraries\stzlib\core\")
? o1.VizSearchFiles("*memory*")

pf()
# Executed in 0.01 second(s) in Ring 1.22

#==========================#
#  INFORMATION & DISPLAY   #
#==========================#
