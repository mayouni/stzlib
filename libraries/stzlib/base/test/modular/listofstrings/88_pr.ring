# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #88.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([
	"Medianet", "ST2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape", "avionav",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"ISIE", "HNEC", "HAICA", "kalidia", "triciti", "maxeam", "Ring" ])

? o1.ContainsEachCS([ "IFES", "HAICA" ], TRUE )
#--> FALSE (because 'ifes' is lowercase)

? o1.ContainsEach([ "Ring", "keyrus" ])
#--> TRUE

? o1.ContainsBothCS("WHITECAPE", "MEDIANET", :CS = FALSE)
#--> TRUE

? o1.ContainsBothCS( "WHITECAPE", "Medianet", :CS = FALSE )
#--> TRUE

? o1.ContainsBoth("Medianet", "ST2i")
#--> TRUE

pf()
# Executed in 0.08 second(s)
