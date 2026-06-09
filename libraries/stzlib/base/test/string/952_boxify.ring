# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #952.
#ERR Error (R14) : Calling Method without definition: boxify

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars( @Chars("..STZ..StZ..stz") )

? o1.Boxify() # Or simply Box()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ . │ . │ S │ T │ Z │ . │ . │ S │ t │ Z │ . │ . │ s │ t │ z │
# └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

? o1.BoxDash()
#-->
# ┌╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┐
# ┊ . ┊ . ┊ S ┊ T ┊ Z ┊ . ┊ . ┊ S ┊ t ┊ Z ┊ . ┊ . ┊ s ┊ t ┊ z ┊
# └╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┘

pf()
# Executed in 0.06 second(s) in Ring 1.24
