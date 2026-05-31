# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #318.

load "../../../stzBase.ring"


o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBoundedBy([ "<<", ">>" ])
#--> [ "word1", "word2" ]

StopProfiler()
# Executed in 0.02 second(s)
