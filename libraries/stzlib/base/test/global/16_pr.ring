# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #16.

load "../../stzBase.ring"


@ForEach( [ :name, :age ], :in = [ [ "Teebah", 12], ["Haneen", 8], ["Hussein", 2] ] ) {

	X([ [1, 3], '
		? v(:name) + TAB + v(:age)
	'])
	#--> teebah	12
	#    haneen	8
	#    hussein	2

	? ""
	Xn( 3, '
		? v(:name) + TAB + v(:age)
	')
	#--> Hussein	2

	? ""
	Xn( [1, 3], '
		? v(:name) + TAB + v(:age)
	')
	#--> Teebah	12
	#    Hussein	2

}

pf()
# Executed in 0.05 second(s)
