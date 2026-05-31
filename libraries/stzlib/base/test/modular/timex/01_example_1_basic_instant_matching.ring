# Narrative
# --------
# Example 1: Basic Instant Matching
#
# Extracted from stztimextest.ring, block #1.

load "../../../stzBase.ring"

pr()

# Match single timestamp

Tmx = Tmx("{@Instant}")
? Tmx.Match(StzDateTimeQ("2025-10-22 14:30:00"))
#--> TRUE (exact match)

? Tmx.MatchPartial(StzDateTimeQ("2025-10-22 14:30:00"))
#--> TRUE (partial also works for single item)

pf()
