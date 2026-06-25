load "../../stzBase.ring"
load "../_narrated.ring"

# Counting a char's leading / trailing run. LeftSide == StartSide, RightSide ==
# EndSide. Codepoint-correct, so it works on Arabic too. Archive block #28.
#
# NOTE: the archive #--> claimed 3 for the last two lines, but they count the
# WRONG side relative to where the dashes are (trailing count of a leading-dash
# string, and vice versa), so the correct answer is 0. Impl is authority here.

Scenario("Counting the leading / trailing run of a char")
	Then("'-' on the left of ---ring is 3", Q("---ring").NumberOfOccurrenceOfCharLeftSide("-"), 3)
	Then("'-' on the right of ring--- is 3", Q("ring---").HowManyOccurrenceOfCharRightSide("-"), 3)
	Then("'-' on the left of an Arabic word is 3", Q("---سلام").NumberOfOccurrenceOfCharLeftSide("-"), 3)
	Then("'-' on the right of an Arabic word is 3", Q("سلام---").NumberOfOccurrenceOfCharRightSide("-"), 3)
	Then("StartSide is the LeftSide alias", Q("---ring").NumberOfOccurrenceOfCharStartSide("-"), 3)
	Then("EndSide is the RightSide alias", Q("ring---").HowManyOccurrenceOfCharEndSide("-"), 3)
	# The dashes are LEADING, so the END side has none (archive #--> 3 was wrong):
	Then("EndSide of a leading-dash string is 0", Q("---سلام").NumberOfOccurrenceOfCharEndSide("-"), 0)
	# The dashes are TRAILING, so the START side has none:
	Then("StartSide of a trailing-dash string is 0", Q("سلام---").NumberOfOccurrenceOfCharStartSide("-"), 0)
EndScenario()

Summary()
