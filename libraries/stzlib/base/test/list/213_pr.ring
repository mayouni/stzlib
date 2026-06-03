# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #213.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? o1.FindW(' NOT isNumber(This[@i + 1]) ')
#--> [2, 6]
# Executed in 0.13 second(s)

? o1.FindWXT(' Q(@NextItem).IsNotANumber() ')
#--> [2, 6]

pf()
# Executed in 0.14 second(s) in Ring 1.22
# Executed in 0.15 second(s) in Ring 1.21
# Executed in 0.59 second(s) in Ring 1.20
# Executed in 0.70 second(s) in Ring 1.17
