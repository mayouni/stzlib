# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #19.
#ERR Error (R24) : Using uninitialized variable: number

load "../../stzBase.ring"

pr()

aNumbers = []

@ForEach( :number, :in = 1:100 ) { X('
	aNumbers + v(number)
')}

? ShowShort(aNumbers)
#--> [ 1, 2, 3, "...", 98, 99, 100 ]

pf()
# Executed in 0.30 second(s)
