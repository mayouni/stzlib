# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- a future-feature wishlist
# (RemoveRepeatedLeadingCharsW with cChar/oChar/nNumberOfLeadingChars
# context vars); the archive block is a self-declared TODO, never
# implemented. Revisit with the W-context-vars design.
# TODO (future)
#
# Extracted from stzStringTest.ring, block #775.

load "../../stzBase.ring"


pr()

StzStringQ("eeebxeTuniseee") {
	RemoveRepeatedLeadingCharsW('{
		cChar = "e"
	}')

	RemoveRepeatedLeadingCharsW('{ oChar.IsSpecialChar() }')
	RemoveRepeatedLeadingCharsW('{ oChar.IsPunctuation() }')

	RemoveRepeatedLeadingCharsW('{ nNumberOfLeadingChars = 5 }')
	RemoveRepeatedLeadingCharsW('{ cLeadingSubstring = "<<<" }')
	RemoveRepeatedLeadingCharsW('{ oLeadingSubstring.IsANumber() }')
	
	? Content()
}

pf()
