# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #18.

load "../../../stzBase.ring"


@ForEach( [ :name, :age ], :in = [ [ "teebah", 12], ["haneen", 8], ["hussein", 2] ] ) { X('

	? v(:name) + TAB + v(:age)

') }
#--> teebah	12
#    haneen	8
#    hussein	2

pf()
# Executed in 0.05 second(s) in Ring 1.20
