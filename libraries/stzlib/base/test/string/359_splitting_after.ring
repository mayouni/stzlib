load "../../stzBase.ring"
load "../_narrated.ring"

# SPLITTING AFTER: each occurrence CLOSES a piece (the separator is kept at
# the tail). Spellings: SplitAfterCS, SplitCS(:After), a LIST of
# substrings, :AfterPosition(s), :AfterSection(s) (after the section's
# END), and the W conditional forms. Archive block #359.

Scenario("Splitting after substrings")
	Given('"__a__A__"')
	o1 = new stzString("__a__A__")
	Then("case-insensitive SplitAfterCS",
		ListEq( o1.SplitAfterCS("a", :CS = FALSE), [ "__a", "__A", "__" ] ), TRUE)
	Then("the SplitCS(:After) spelling",
		ListEq( o1.SplitCS( :After = "a", :CS = FALSE), [ "__a", "__A", "__" ] ), TRUE)
	Then("a list of substrings",
		ListEq( o1.Split( :After = [ "a", "A" ] ), [ "__a", "__A", "__" ] ), TRUE)
EndScenario()

Scenario("Splitting after positions and sections")
	o1 = new stzString("...♥...")
	Then(":AfterPosition",
		ListEq( o1.Split( :AfterPosition = 4 ), [ "...♥", "..." ] ), TRUE)
	o2 = new stzString("...♥...♥...")
	Then(":AfterPositions",
		ListEq( o2.Split( :AfterPositions = [ 4, 8 ] ), [ "...♥", "...♥", "..." ] ), TRUE)
	Then(":AfterSection splits after its end",
		ListEq( o2.Split( :AfterSection = [ 4,  8 ] ), [ "...♥...♥", "..." ] ), TRUE)
	o3 = new stzString("...♥♥♥..♥♥..")
	Then(":AfterSections",
		ListEq( o3.Split( :AfterSections = [ [4, 6], [9, 10] ] ),
			[ "...♥♥♥", "..♥♥", ".." ] ), TRUE)
EndScenario()

Scenario("Splitting after by condition")
	o1 = new stzString("...♥...♥...")
	Then("the before-char W form for contrast",
		ListEq( o1.SplitBeforeCharsW(' @char = "♥" '), [ "...", "♥...", "♥..." ] ), TRUE)
	o2 = new stzString("...♥♥...♥♥...")
	Then("the after-substring W form",
		ListEq( o2.SplitAfterSubStringsW(' @SubString = "♥♥" '),
			[ "...♥♥", "...♥♥", "..." ] ), TRUE)
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
