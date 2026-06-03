# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #390.

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
