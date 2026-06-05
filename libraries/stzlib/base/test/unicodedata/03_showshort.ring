# Narrative
# --------
# pr()
#
# Extracted from stzunicodedatatest.ring, block #3.

load "../../stzBase.ring"

pr()

StzUnicodeDataQ() {

	? ShowShort( UnicodesOfCharsContaining("arabic") )
	#--> [ 1536, 1537, 1538, "...", 126651, 126704, 126705 ]

	? ShowShort( CharsContaining("arabic") )
	#o--> [ "؀", "؁", "؂", "...", "ﶍ", "ﶎ", "ﶏ" ]
}

pf()
# Executed in 0.04 second(s) in Ring 1.26 (Powered by StzEngine)
# Executed in 0.76 second(s)
