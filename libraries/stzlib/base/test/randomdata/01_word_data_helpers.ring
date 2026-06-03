# Narrative
# --------
# 01 Word Data Helpers
#
# Extracted from stzrandomdatatest.ring (single-block file; the
# original used no `/*---` delimiters, so the whole body
# is preserved verbatim as one modular block).
#ERR Error (R14) : Calling Method without definition: filledwith

load "../../stzBase.ring"
pr()

? AWord() + NL
#--> "square"

? Five( Words() )
#--> [ "apple", "yacht", "truck", "station", "base" ]

? Three( ArabicWords() ) # Or @3(...) if you want
#o-> [ "كلمة", "كرسيّ", "شجرة" ]

? Q([]).FilledWith( Four( FrenchWords() ) )
#--> [ "question", "chien", "lampe", "chat" ]

? Q("").FilledWith( AnEnglishWord() + ' & ' + AFrenchWord() ) + NL
#--> question & soleil

pf()
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 0.20 second(s) in Ring 1.19

