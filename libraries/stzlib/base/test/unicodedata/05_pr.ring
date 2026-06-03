# Narrative
# --------
# pr()
#
# Extracted from stzunicodedatatest.ring, block #5.

load "../../stzBase.ring"


? ShowShortXTNL( UnicodeBlocks(), 5 )

#-->
'
[
	"Basic Latin", 
	"Latin-1 Supplement", 
	"Latin Extended-A", 
	"Latin Extended-B", 
	"IPA Extensions", 
	"...", 
	"CJK Unified Ideographs Extension G", 
	"Tags", 
	"Variation Selectors Supplement", 
	"Supplementary Private Use Area-A", 
	"Supplementary Private Use Area-B"
]
'

? ShowShortNL( UnicodeBlocksAndTheirRanges() )
#-->
'
[
	[ "Basic Latin", [ 0, 127 ] ], 
	[ "Latin-1 Supplement", [ 128, 255 ] ], 
	[ "Latin Extended-A", [ 256, 383 ] ], 
	"...", 
	[ "Variation Selectors Supplement", [ 917760, 917999 ] ], 
	[ "Supplementary Private Use Area-A", [ 983040, 1048575 ] ], 
	[ "Supplementary Private Use Area-B", [ 1048576, 1114111 ] ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
