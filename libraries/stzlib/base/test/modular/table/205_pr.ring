# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #205.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ "NATION", "LANGUAGE", "CAPITAL", "CONTINENT" ],

	[ "Tunisia", "Arabic", "Tunis", "Africa" ],
	[ "France", "French", "Paris", "Europe" ],
	[ "Egypt", "English", "Cairo", "Africa" ]
])

o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#   -------- ---------- --------- ----------
#   Tunisia     Arabic     Tunis      Africa
#    France     French     Paris      Europe
#     Egypt    English     Cairo      Africa

pf()
# Executed in 0.10 second(s)
