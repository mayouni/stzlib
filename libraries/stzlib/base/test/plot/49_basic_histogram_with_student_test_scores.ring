# Narrative
# --------
# Basic histogram with student test scores
#
# Extracted from stzPlotTest.ring, block #49.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"
load "../_expect.ring"


pr()

aScores = [
	85, 92, 78, 88, 95, 82, 90,
	87, 93, 86, 79, 91, 84, 89,
	96, 83, 88, 92, 87, 85
]

oPlot = new stzHistogram(aScores)
oPlot {

	# ? @@(AggregationTypes())
	#--> [ "frequency", "sum", "average", "min", "max" ]

	# SetBinCount(5) # Or SetClassCount(5)
	# ~> Auto-calculate bin count using Sturges' rule
	# if not set

	UseFrequency()
	AddPercent()

    Show()
Shows(oPlot, '
▲
│
│                      25.0%
│               20.0%   ██    20.0%
│                ██     ██     ██    15.0%
│ 10.0%  10.0%   ██     ██     ██     ██
│  ██     ██     ██     ██     ██     ██
│  ██     ██     ██     ██     ██     ██
╰─────────────────────────────────────────►
   78     81     84     87     90     93
   81     84     87     90     93     96
')
}

#TODO #ERR See why lables are not displayed

pf()
# Executed in 0.24 second(s) in Ring 1.23
# Executed in 0.48 second(s) in Ring 1.22
