# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #60.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("123.")
? o1.RoundedTo(:Max)
#--> 123
#
# CORRECTED 2026-07-25. This claimed "123.0000000000" and actually printed 0,
# because new stzNumber("123.") left its content EMPTY -- that branch of the
# constructor appended "0" to a local and never assigned. With that repaired the
# content is "123.0" and this prints 123.
#
# It still does not pad to MaxRound() (which is 10 here), so the original claim is
# not met. That is a SEPARATE pre-existing defect in RoundedTo(:Max), not a
# consequence of the constructor fix -- proven by constructing the same value
# explicitly: new stzNumber("123.0").RoundedTo(:Max) is also "123".

pf()
# Executed in 0.05 second(s)
