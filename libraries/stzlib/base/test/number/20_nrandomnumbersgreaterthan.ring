# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #20.
#ERR TIMEOUT (>25s)

load "../../stzBase.ring"

pr()

? NRandomNumbersGreaterThan(3, 150_000)
#--> [
#	999_999_999_977_566.00,
#	999_999_999_975_123.00,
#	999_999_999_969_942.00
# ]

pf()
