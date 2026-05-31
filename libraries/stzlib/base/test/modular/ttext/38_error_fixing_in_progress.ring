# Narrative
# --------
# ERROR: FIXING IN PROGRESS
#
# Extracted from stzTtexttest.ring, block #38.

load "../../../stzBase.ring"


o1 = new stzText("Ring 17")
? o1.IsWord() #--> TRUE

o1 = new stzText("Ring_17")
? o1.IsWord() #--> TRUE

o1 = new stzText("حُسَيْــــنْ")
? o1.IsArabicWord()

? StringIsWord("حُسَيْــــنْ")
