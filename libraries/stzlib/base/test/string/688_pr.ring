# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #688.

load "../../stzBase.ring"


o1 = new stzText("père frère mère tête")

? o1.CountScripts()
#--> 2

? o1.Scripts()
#--> [ "latin", "common" ]

? o1.Script()
#--> "latin"

? o1.DiacriticsRemoved()
#--> "pere frere mere tete"

pf()
# Executed in 0.27 second(s) in Ring 1.22
