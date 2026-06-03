# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #830.

load "../../stzBase.ring"


o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
"Où bien tu n'aimes pas que ce soit Foulèna?")

o1.ReplaceAll("Foulèna", "Tiba")
? o1.Content()

#--> "Mon prénom c'est Tiba. J'ai bien dit Tiba! Où bien tu n'aimes pas que ce soit Tiba?"

pf()
# Executed in 0.01 second(s).
