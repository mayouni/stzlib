# Narrative
# --------
# Same 1..4 cycle for a million iterations, but driven through
# stzCounter. Compares the cost of going through the Softanza abstraction
# vs. the raw-Ring baseline in block 04.

load "../../../stzBase.ring"

# Softanza stzCount

pr()

# stzCounter generating complete sequence

oCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 4,
    :RestartAt = 1
])
anCounterResults = oCounter.CountTo(1000000)

pf()
# Reference timing:
# - 0.91s in Ring 1.23

# Executed in 0.01 second(s) in Ring 1.26 (Backed by StzEngine)
