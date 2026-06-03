# Narrative
# --------
# HTML Content Extraction - different matching behaviors:
#
# Extracted from stzregexmakertest.ring, block #49.

load "../../../stzBase.ring"


pr()

rxm() {

	AddCapturingGroup("tag", "<div>")

	# :shortest - Matches each div's content separately
	AddMatchLength(".*", :shortest)  # Gets individual div contents

	# :longest - Matches from first div to last closing tag
	AddMatchLength(".*", :longest)   # Gets everything between first and last div

	# :complete - Matches full content without backtracking
	AddMatchLength(".*", :complete)  # More efficient for large HTML docs

	? Pattern()
	#--> (?P<tag><div>).*+?.*+.*++
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
