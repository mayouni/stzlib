# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #534.

load "../../stzBase.ring"


o1 = new stzString("what a <<<nice>>> day!")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = 3) )
#--> [ "<<<", ">>>" ]

o1 = new stzString("what a <nice>>> day!")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = [1, 3]) )
#--> [ "<", ">>>" ]

o1 = new stzString("what a <<nice>>> day! Really <nice>>.")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = [ 2, 3 ]) )
#--> [ "<<", ">>>", "<", ">>" ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
