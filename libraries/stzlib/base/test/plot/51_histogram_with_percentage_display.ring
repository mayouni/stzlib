# Narrative
# --------
# Histogram with percentage display
#
# Extracted from stzPlotTest.ring, block #51.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

aSalaries = [
	45000, 52000, 48000, 67000, 55000,
	49000, 58000, 62000, 51000, 46000,
	59000, 53000, 47000, 61000, 56000,
	50000, 54000, 48000, 60000, 57000
]

oPlot = new stzHistogram(aSalaries)
oPlot {
    SetClassCount(6) # Or SetBinCount(6)
    AddPercent()

    SetBarChar("▓")
    Show()
Shows(oPlot, '
▲
│
│ 25.0%
│  ▓▓    20.0%         20.0%
│  ▓▓     ▓▓    15.0%   ▓▓    15.0%
│  ▓▓     ▓▓     ▓▓     ▓▓     ▓▓
│  ▓▓     ▓▓     ▓▓     ▓▓     ▓▓    5.0%
│  ▓▓     ▓▓     ▓▓     ▓▓     ▓▓     ▓▓
╰─────────────────────────────────────────►
   45K   48.7K  52.3K   56K   59.7K  63.3K
  48.7K  52.3K   56K   59.7K  63.3K   67K
')
}
# Note how Softanza transforms thousands to Ks for better radability

pf()
# Executed in 0.67 second(s) in Ring 1.23
# Executed in 0.95 second(s) in Ring 1.22
