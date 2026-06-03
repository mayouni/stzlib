# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #219.

load "../../stzBase.ring"

pr()

o1 = new stzString("Mansour Ayouni")
? o1.Before("Ayouni")
#--> 'Mansour '

? o1.After("Mansour")
#--> ' Ayouni'

pf()
# Executed in 0.01 second(s) in Ring 1.22

#TODO Add the same feature in stzList
