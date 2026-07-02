load "../../stzBase.ring"
load "../_narrated.ring"

# SPLITTING BEFORE: each occurrence starts a new piece (the separator is
# kept at the head). Spellings: SplitBeforeCS, SplitCS(:Before), a LIST of
# substrings, :BeforePosition(s), :BeforeSection(s) (before the section's
# START), and the W conditional forms. Archive block #356.

Scenario("Splitting before substrings")
	Given('"__a__A__"')
	o1 = new stzString("__a__A__")
	Then("case-insensitive SplitBeforeCS",
		ListEq( o1.SplitBeforeCS("a", :CS = FALSE), [ "__", "a__", "A__" ] ), TRUE)
	Then("the SplitCS(:Before) spelling",
		ListEq( o1.SplitCS( :Before = "a", :CS = FALSE), [ "__", "a__", "A__" ] ), TRUE)
	Then("a list of substrings",
		ListEq( o1.Split( :Before = [ "a", "A" ] ), [ "__", "a__", "A__" ] ), TRUE)
EndScenario()

Scenario("Splitting before positions and sections")
	Given('"...♥...♥..."')
	o1 = new stzString("...♥...♥...")
	Then(":BeforePosition",
		ListEq( o1.Split( :BeforePosition = 4 ), [ "...", "♥...♥..." ] ), TRUE)
	Then(":BeforePositions",
		ListEq( o1.Split( :BeforePositions = [ 4, 8 ] ), [ "...", "♥...", "♥..." ] ), TRUE)
	Then(":BeforeSection splits before its start",
		ListEq( o1.Split( :BeforeSection = [ 4,  8 ] ), [ "...", "♥...♥..." ] ), TRUE)
	o2 = new stzString("...♥♥♥..♥♥..")
	Then(":BeforeSections",
		ListEq( o2.Split( :BeforeSections = [ [4, 6], [9, 10] ] ),
			[ "...", "♥♥♥..", "♥♥.." ] ), TRUE)
EndScenario()

Scenario("Splitting before by condition")
	o1 = new stzString("...♥...♥...")
	Then("the char W form",
		ListEq( o1.SplitBeforeCharsW(' @char = "♥" '), [ "...", "♥...", "♥..." ] ), TRUE)
	o2 = new stzString("...♥♥...♥♥...")
	Then("the substring W form",
		ListEq( o2.SplitBeforeSubStringsW(' @SubString = "♥♥" '),
			[ "...", "♥♥...", "♥♥..." ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
