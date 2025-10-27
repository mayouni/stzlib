load "../stzbase.ring"

/*-- Match table structure

pr()

oTable = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Hussein", 24, "programmer" ],
	[ "Karim", 32, "artist" ],
	[ "Ali", 28, "teacher" ],
	[ "Omar", 44, "farmer" ]
])

oTx = new stzTablex("{cols(3) & rows(4)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*-- Check data quality

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE, :JOB ],
	[ 10, "Hussein", 24, "programmer" ],
	[ 20, "Karim", 32, "artist" ],
	[ 30, "Ali", 28, "teacher" ],
	[ 40, "Omar", 44, "farmer" ]
])

oTx = new stzTablex("{unique(id) & @!property(empty)}")
? oTx.Match(oTable)
#--> TRUE (ID column unique and table not empty)

pf()

/*-- Find matching tables in collection
*/
pr()

aTables = [

	new stzTable([
		[ :NAME, :AGE, :JOB ],
		[ "Hussein", 24, "programmer" ],
		[ "Karim", 32, "artist" ],
		[ "Ali", 28, "teacher" ],
		[ "Omar", 44, "farmer" ]
	]),

	new stzTable([
		[ :NAME, :AGE, ],
		[ "Hussein", 24 ],
		[ "Karim", 32 ],
		[ "Salem", 28 ],
		[ "Omar", 44 ]
	]),

	new stzTable([
		[ :NAME, :AGE, :JOB ],
		[ "Sarra", 24, "programmer" ],
		[ "Ali", 32, "artist" ],
		[ "Fatima", 28, "teacher" ],
		[ "Dorra", 44, "farmer" ]
	])

]

oTx = new stzTablex("{cols(>2) & contains(Ali)}")

? oTx.CountMatchingTablesIn(aTables)

? @@NL( oTx.MatchingTablesIn(aTables) )

pf()


pf()

/*-- Combine patterns
oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{unique(id)}")
oTx3 = oTx1.And_(oTx2)  # {cols(3) & unique(id)}
