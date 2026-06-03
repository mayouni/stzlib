# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #525.

load "../../stzBase.ring"

pr()

o1 = new stzString("and **<Ring>** and _<<PHP>>_ AND <Python/> and _<<<Ruby>>>_ ANDand !!C++!! and")
? @@( o1.Split( :Using = "and" ) )
#--> [ "<Ring> ", " <<PHP>> ", " <Python/> ", " <<<Ruby>>> ", "", " !!C++!!" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
