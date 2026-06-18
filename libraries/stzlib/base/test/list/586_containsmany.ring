# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #586.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"medianet", "st2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"isie", "hnec", "haica", "kalidia", "triciti", "avionav",
	"maxeam", "nextav", "ring"
])

? o1.ContainsMany([ "medianet", "st2i" ])
#--> TRUE

? o1.ContainsEach([ "ifes", "haica"])
 #--> TRUE

? o1.ContainsBoth("ifes", "haica")
#--> TRUE

pf()
# Executed in almost 0 second(s).
