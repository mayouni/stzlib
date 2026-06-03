# Narrative
# --------
# TODO: FUTURE
#
# Extracted from stzStringTest.ring, block #526.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.SplitXT(
	:Using = "and",

	[ 
	TRUE,
	:SkipEmptyParts = TRUE,

	:IncludeLeadingSep = TRUE,
	:IncludeTrailingSep = TRUE,

	:ExcludeLeadingSubstrings_FromSplittedParts = [ "_", "**" ],
	
	:ExcludeTrailingSubstrings_FromSplittedParts = [ "_", "**", "/>" ],

	:ExcludeLeadingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, "<" ],
	:ExcludeTrailingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, ">" ]
	]
)

pf()
