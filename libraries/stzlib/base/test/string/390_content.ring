# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #390.
#
# NOTE (audit, 2026-07-02): DEFERRED. Replace(sub, :By@ = '<ring code>')
# evaluates a CODE STRING that references a caller-scope variable
# (acOtherLangs) -- the eval-based @-forms are retired (see the W/WF
# conditional-code policy) and Ring offers no caller-scope reflection
# for the embedded expression. Same family as the $()/Interpolate
# deferral (block #111). The block also carries no #--> to pin the
# expected output.

load "../../stzBase.ring"

pr()

acOtherLangs = [ "JS", "C#", "PHP", "Python" ]

o1 = new stzString("JS style can be used in Ring!")

o1.Replace("JS", :By@ = '
	QRT(acOtherLangs, :stzListOfStrings).
	ConcatenateXTQ([ :Using = ", ", :LastSep = ", and " ]).
	AddQ("s", :To = "style").
	Content()
')


? o1.Content()

StopProfiler()

pf()
