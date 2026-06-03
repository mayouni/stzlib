# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #2.

load "../../stzBase.ring"


o1 = new stzString('[ @$2{"a";1;[1]}U ]')
o1.RemoveFirstAndLastChars()
? @@( o1.Content() )
#--> ' @$2{"a";1;[1]}U '

pf()
# Executed in almost 0 second(s) in Ring 1.22
