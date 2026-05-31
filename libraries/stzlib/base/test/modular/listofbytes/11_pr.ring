# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #11.

load "../../../stzBase.ring"


nCode = 65	# The character "A"

? nCode
#--> 65

? Q( nCode ).ToBinary()
#--> 0b1000001

? Q( nCode ).ToHex()
#--> 0x41

? Q( nCode ).ToOctal()
#--> 0o101

pf()
#--> Executed in 0.03 second(s) in Ring 1.21
#--> Executed in 0.17 second(s) in Ring 1.18
