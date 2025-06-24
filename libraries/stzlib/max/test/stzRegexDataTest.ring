load "../max/stzmax.ring"




/*---

pr()

Rx( pat(:numbersInQuotes) ) {

//	? Pattern()
	#--> '-?\d+(?:\.\d+)?'|"-?\d+(?:\.\d+)?\"|-?\d+(?:\.\d+)?|[‘’]-?\d+(?:\.\d+)?[‘’]|[“”]-?\d+(?:\.\d+)?[“”]

	Match("'150' and ‘90’ are quoted")
	? Matches()
	#--> [ '150', ‘90’ ] correct!
}

pf()

/*---

pr()

Rx( pat(:numbersInsideString) ) {
	//? Pattern()
	#--> (?<!\w)-?\d+(?:\.\d+)?(?!\w)

	Match("I have 150 dollars and 90 cents")
	? @@( Matches() )
	#--> [ '150', '90' ] correct!
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*==================

pr()

Rx( pat(:numbersAsValuesInHashList) ) {
	? Pattern()
	#--> =\s*(?:"([+-]?\d+(?:\.\d+)?)"|([+-]?\d+(?:\.\d+)?))

	Match('[ :name = "John", :age = 34, :salary = "64000" ]')
	? @@( Matches() )
	#--> [ "= 34", '= "64000"' ]!
}

pf()

/*---

pr()

Rx( pat(:numbersAsValuesInPairs) ) {
	? Pattern()
	#--> ,\s*(?:"([+-]?\d+(?:\.\d+)?)"|([+-]?\d+(?:\.\d+)?))

	Match('[ [ "name", "John" ], [ "age", 34 ], [ "salary", "64000" ] ]')
	? @@( Matches() )
	#--> [ ", 34", ', "64000"' ]

}

pf()

/*---

pr()

Rx( pat(:numbersAsValuesInJSON) ) {
	? Pattern()
	#--> :\s*"?([+-]?\d+(?:\.\d+)?)"?

	Match('{ "age": 34, "salary": "64000" }')

	? @@( Matches() )
	#--> [ ": 34", ': "64000"' ]
}

pf()

/*==========
*/
pr()

Rx( pat(:numbersInParentheses) ) {
	? Pattern()
	#--> \(\s*-?\d+(?:\.\d+)?\s*\)

	Match("(34) and (64000)")
	? @@( Matches() )
	#--> [ (34), (64000) ] corrrect!
}

pf()

/*---

pr()

Rx( pat(:numbersAfterEquals) ) {
	? Pattern()
	#--> =\s*-?\d+(?:\.\d+)?\b

	Match("age= 34 salary=64000")
	? @@( Matches() )
	#--> [ "= 34", "=64000" ] correct!
}

pf()

/*---

pr()

Rx( pat(:numbersInCSV) ) {
	? Pattern()
	#--> (?<=,|;|\s|^)-?\d+(?:\.\d+)?(?=,|;|\s|$)

	Match("34, 64000, 2.5, -10")
	? @@(Matches())
	#--> [ '34', '64000', '2.5', '-10' ] correct
}

Rx( pat(:numbersInCSV) ) {

	Match("34; 64000; 2.5; -10")
	? @@(Matches())
	#--> [ '34', '64000', '2.5', '-10' ] correct
}

pf()

/*---

pr()

Rx( pat(:numbersInBrackets) ) {
	? Pattern() + NL
	#--> \[\s*-?\d+(?:\.\d+)?\s*\]

	Match("[34] and [64000]")
	? @@( Matches() )
	#--> [ "[34]", "[64000]" ] correct
}

pf()

/*---

pr()

Rx( pat(:numbersAfterColon) ) {
	? Pattern()
	# :\s*-?\d+(?:\.\d+)?\b

	Match("age: 34, salary: 64000")
	? @@( Matches() )
	#--> [ ": 34", ": 64000" ] correct
}

pf()

/*---

pr()

Rx( pat(:numbersInList) ) {
	? Pattern() + NL
	#--> \[\s*[\w"',\s]*(?:^|,)\s*(")?(-?\d+(?:\.\d+)?)(")?(?:\s*,|\s*\])

	Match('[ "apple", 34, "banana", "64000" ]')
	? @@(Matches()) + nl
	#--> [ "34", "64000" ] correct
}

Rx( pat(:numbersInList) ) {
	? Pattern() + NL
	#--> \[\s*[\w"',\s]*(?:^|,)\s*(")?(-?\d+(?:\.\d+)?)(")?(?:\s*,|\s*\])

	Match("[ 'apple', 34, 'banana', '64000' ]")
	? @@(Matches())
	#--> [ "34", "64000" ] correct
}

pf()
