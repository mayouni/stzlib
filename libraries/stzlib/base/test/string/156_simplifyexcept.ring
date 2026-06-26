# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #156.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): SimplifyExcept(sections) should
# collapse runs of spaces everywhere EXCEPT inside the given (quoted) sections,
# but it only simplifies the FIRST gap -- "txt2  =  " keeps its double spaces and
# the trailing space survives. Likely downstream of the single-bound
# FindAnyBoundedByAsSections('"') (block 124). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString(' this code:   txt1  =   "    withspaces    " and txt2  =  "nospaces"  ')
o1.SimplifyExcept( o1.FindAnyBoundedByAsSections('"') )
? o1.Content()
#--> expected 'this code: txt1 = "    withspaces    " and txt2 = "nospaces"'
#    (currently leaves "txt2  =  " double-spaced + a trailing space)

pf()
