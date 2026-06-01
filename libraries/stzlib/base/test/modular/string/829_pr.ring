# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #829.

load "../../../stzBase.ring"


o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
o1.ReplaceAll("فلانة", "فلسطين")
? o1.Content()
o#--> اسمي هو فلسطين، قلت لك فلسطين! أوَ لم يعجبك أن يكون اسمي فلسطين؟

pf()
# Executed in 0.01 second(s).
