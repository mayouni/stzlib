# Narrative
# --------
# IsChar() answers whether a value qualifies as a single character.
#
# A value passes when it is a one-codepoint string -- "A", the Arabic
# letter "م", or the heart symbol "♥" all return TRUE, confirming the
# check is Unicode-aware and counts codepoints, not bytes. Multi-character
# strings like "Hi" return FALSE. For numbers, IsChar accepts only a small
# non-negative integer in the valid single-character range (6 -> TRUE),
# while a float (12.5), a negative (-7), and an out-of-range integer (14)
# all return FALSE. This makes IsChar the single-character guard used
# before any per-character operation in Softanza's list and string APIs.
#
# Extracted from stzlisttest.ring, block #115.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("IsChar() answers whether a value qualifies as a single character.")

	Then("ischar example 1", @@( IsChar(12.5) ), @@( FALSE ))

	Then("ischar example 2", @@( IsChar(-7) ), @@( FALSE ))

	Then("ischar example 3", @@( IsChar(14) ), @@( FALSE ))

	Then("ischar example 4", @@( IsChar(6) ), @@( TRUE ))

	Then("ischar example 5", @@( IsChar("A") ), @@( TRUE ))

	Then("ischar example 6", @@( IsChar("م") ), @@( TRUE ))

	Then("ischar example 7", @@( IsChar("♥") ), @@( TRUE ))

	Then("ischar example 8", @@( IsChar("Hi") ), @@( FALSE ))
EndScenario()

Summary()
