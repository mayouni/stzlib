# Narrative
# --------
# o1 = new stzNumber("12500")
#
# Extracted from stznumbertest.ring, block #67.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.ToHexForm()
? o1.ToOctalForm()

? o1.ToHexFormWithoutPrefix()
? o1.ToOctalFormWithoutPrefix()

pf()
