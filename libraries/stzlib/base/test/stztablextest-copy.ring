load "../stzbase.ring"

/*-- Match table structure
*/
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

/*--

pr()

oTable1 = new stzTable([
    [ :NAME, :AGE, :JOB ],
    [ "Hussein", 24, "programmer" ],
    [ "Karim", 32, "artist" ],
    [ "ali", 28, "teacher" ],
    [ "Omar", 44, "farmer" ]
])

oTable2 = new stzTable([
    [ :NAME, :AGE, ],
    [ "Hussein", 24 ],
    [ "Karim", 32 ],
    [ "Salem", 28 ],
    [ "Omar", 44 ]
])

oTable3 = new stzTable([
    [ :NAME, :AGE, :JOB ],
    [ "Sarra", 24, "programmer" ],
    [ "ALI", 32, "artist" ],
    [ "Fatima", 28, "teacher" ],
    [ "Dorra", 44, "farmer" ]
])

oTx = new stzTablex("{cols(>2) & contains(Ali)}")

# Case-insensitive (default)
oTx = new stzTablex("{cols(>2) & contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 2

# Case-sensitive
oTx = new stzTablex("{cols(>2) & @cs:contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 0 (no "Ali", only "ali")

pf()

/*-- Combine patterns

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 10, "Hussein", 24 ],
	[ 20, "Karim", 32 ],
	[ 30, "Ali", 28 ],
	[ 40, "Omar", 44 ]
])

oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{unique(id)}")
oTx3 = oTx1.And_(oTx2)  # {cols(3) & unique(id)}

? oTx3.Match(oTable)
#--> TRUE

pf()
