# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #804.

load "../../stzBase.ring"


o1 = new stzString("<script>func return :done<script/>")
? o1.IsBoundedBy(["<script>", :And = "<script/>"])
#--> TRUE

o1.RemoveTheseBounds("<script>", "<script/>")
? o1.Content()
#--> "func return :done"

pf()
# Executed in 0.03 second(s) in Ring 1.14
# Executed in 0.14 second(s) in Ring 1.17
