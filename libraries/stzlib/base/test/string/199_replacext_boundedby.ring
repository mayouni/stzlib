# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #199.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT([], :BoundedBy='/', :With=)
# and the :BoundedByIB variant RAISE "ReplaceXT: unsupported argument shape"
# (stzString.ring ~2917) -- same as block 194. The non-XT ReplaceAnyBoundedByIB
# (block 198) is the working path. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )   # raises: unsupported argument shape
? o1.Content()
#--> expected "bla bla /bla/ and bla!"

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedByIB = '/', :With = "bla" ) # raises: unsupported argument shape
? o1.Content()
#--> expected "bla bla bla and bla!"

pf()
