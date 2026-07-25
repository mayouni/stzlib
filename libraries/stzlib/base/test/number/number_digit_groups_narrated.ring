load "../../stzBase.ring"
load "../_narrated.ring"

# A number's digit GROUPS -- Trillions / Billions / Millions / Thousands /
# Hundreds -- and the three digits inside each one.
#
# stzNumber documents this design with an ASCII diagram in StructureXT():
#
#     +/-    999   999   999    999    999  . 999 999 ...
#             |     |     |      |      |
#           Trill. Bill. Mill. Thous. Hund.
#
# So each name is a THREE-DIGIT GROUP, "Hundreds" is the LAST group (0-999) rather
# than the hundreds digit, and within a group Units/Dozens/Hundreds are its three
# digits. That was never in doubt -- the doc comment states it and ThousandsXT()
# decomposes a group into exactly those three. Only the implementation disagreed.
#
# THE BUG, and it is a good one: both Structure() and StructureXT() grouped with
#
#     SplitToNPartsQ(3)
#
# which splits a string into THREE PARTS OF EQUAL LENGTH -- not into parts OF
# three. "N parts" read as "parts of N". So 1234567 came apart as 123 / 45 / 67,
# every one of the six methods answered wrongly, and ApplyFormatXT's thousands
# separator landed inside the digits: 12590 formatted as 12.59.0.
#
# The grouping now lives in one helper, _StzDigitGroupsOfThree, because both
# methods had the identical broken line.

Scenario("groups of three, counted from the RIGHT")
	oSmall = new stzNumber(12590)
	Then("the thousands group", oSmall.Thousands(), "12")
	Then("...and the last group", oSmall.Hundreds(), "590")

	oMid = new stzNumber(1234567)
	Then("millions", oMid.Millions(), "1")
	Then("thousands", oMid.Thousands(), "234")
	Then("the last group", oMid.Hundreds(), "567")
	# each of those five was wrong before: 59 / 0 / 123 / 45 / 67.

	oBig = new stzNumber(1234567890123)
	Then("trillions", oBig.Trillions(), "1")
	Then("billions", oBig.Billions(), "234")
	Then("millions", oBig.Millions(), "567")
	Then("thousands", oBig.Thousands(), "890")
	Then("the last group", oBig.Hundreds(), "123")
	# 13 digits: the leftmost group is the SHORT one, which is what "from the right"
	# means and what splitting into equal parts could never produce.
EndScenario()

Scenario("a group that is not there is EMPTY, not zero")
	oTiny = new stzNumber(5)
	Then("the last group holds the number", oTiny.Hundreds(), "5")
	Then("there are no thousands", oTiny.Thousands(), "")
	Then("...nor millions", oTiny.Millions(), "")
	# this matters to ApplyFormatXT, which tests `!= ""` before emitting a group and
	# its separator. A "0" here would print a leading "0." group.

	oExact = new stzNumber(1000)
	Then("1000 has a thousands group", oExact.Thousands(), "1")
	Then("...and a last group of zeros, which is NOT empty", oExact.Hundreds(), "000")
	# 000 is a real group: dropping it would turn 1000 into 1.
EndScenario()

Scenario("the sign is not part of the analysis")
	oNeg = new stzNumber(-12590)
	Then("a negative number groups its digits the same way", oNeg.Thousands(), "12")
	Then("...with no sign leaking into a group", oNeg.Hundreds(), "590")
	Then("the sign is available separately", oNeg.Sign(), "-")
	# StructureXT() used IntegerPart(), which KEEPS the sign, while Structure() used
	# IntegerPartWithoutSign() -- so the two disagreed on a negative number and the
	# "-" was fed into the digit grouping. Both use the unsigned form now, as the
	# doc comment always said.
EndScenario()

Scenario("the three digits INSIDE a group")
	oN = new stzNumber(1234567)

	Then("the thousands group is 234", oN.Thousands(), "234")
	Then("...its hundreds digit", oN.HundredsInThousands(), "2")
	Then("...its dozens digit", oN.DozensInThousands(), "3")
	Then("...its units digit", oN.UnitsInThousands(), "4")

	Then("and for the last group, 567", oN.Hundreds(), "567")
	Then("...hundreds digit", oN.HundredsInHundreds(), "5")
	Then("...dozens digit", oN.Dozens(), "6")
	Then("...units digit", oN.Units(), "7")
	# The dozens were wrong too: GetUnitsDozensAndHundreds asked for Section(2, 1) --
	# a BACKWARDS range, which returns "23" of "234" rather than the middle digit.
	# It could not show while the groups themselves were wrong, so fixing the
	# grouping is what exposed it.
EndScenario()

Scenario("what the grouping is FOR: a thousands separator")
	Then("five digits", (new stzNumber(12590)).ApplyFormatXT([ :ThousandsSeparator = "." ]), "+12.590")
	Then("seven digits", (new stzNumber(1234567)).ApplyFormatXT([ :ThousandsSeparator = "," ]), "+1,234,567")
	Then("ten digits", (new stzNumber(1234567890)).ApplyFormatXT([ :ThousandsSeparator = " " ]), "+1 234 567 890")
	Then("a number below a thousand needs no separator",
	     (new stzNumber(590)).ApplyFormatXT([ :ThousandsSeparator = "," ]), "+590")
	# this is the visible payoff, and the reason the bug mattered: 12590 formatted as
	# 12.59.0 -- a separator inside the digits, which is not a near miss but a
	# different number to a reader.

	# HONEST LIMIT, and NOT a regression: :Width, :AlignTo and :FillBlanksWith are
	# read from the options and then never used anywhere in ApplyFormatXT, so a
	# formatted number is not padded or aligned. That is an unimplemented feature
	# rather than a wrong answer -- it has always behaved this way, and it is
	# recorded here so the next reader does not mistake it for one.
	cW = (new stzNumber(12590)).ApplyFormatXT([ :Width = 15, :AlignTo = :Center, :ThousandsSeparator = "." ])
	Then("asking for width 15 does not pad (yet)", len(cW), 7)
EndScenario()

Summary()
