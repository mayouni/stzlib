load "../../stzBase.ring"
load "../_narrated.ring"

# SPLITTING AT: the separators are dropped. By substring (with case
# control), position(s), substring list, section(s), and by condition --
# the W (string DSL) and WF (anonymous function) forms.
# Archive block #358.

Scenario("Splitting at substrings")
	Given('"__a__A__"')
	o1 = new stzString("__a__A__")
	Then("case-insensitive", ListEq( o1.SplitCS("a", :CS = FALSE), [ "__", "__", "__" ] ), TRUE)
	Then("case-sensitive default", ListEq( o1.Split("a"), [ "__", "__A__" ] ), TRUE)
EndScenario()

Scenario("Splitting at positions, substr lists and sections")
	o1 = new stzString("...♥...")
	Then(":At = position", ListEq( o1.Split( :At = 4 ), [ "...", "..." ] ), TRUE)
	o2 = new stzString("...♥...♥...")
	Then(":At = positions", ListEq( o2.Split( :At = [ 4, 8 ] ), [ "...", "...", "..." ] ), TRUE)
	o3 = new stzString("...♥...★...")
	Then(":At = substrings", ListEq( o3.Split( :At = [ "♥", "★" ] ), [ "...", "...", "..." ] ), TRUE)
	o4 = new stzString("...♥♥♥...")
	Then("SplitAt(:Section)", ListEq( o4.SplitAt( :Section = [ 4, 6 ] ), [ "...", "..." ] ), TRUE)
	Then("Split(:AtSection)", ListEq( o4.Split( :AtSection = [ 4, 6 ] ), [ "...", "..." ] ), TRUE)
	o5 = new stzString("...♥♥♥...♥♥...")
	Then("Split(:AtSections)",
		ListEq( o5.Split( :AtSections = [ [ 4, 6 ], [10, 11] ] ), [ "...", "...", "..." ] ), TRUE)
EndScenario()

Scenario("Splitting at by condition")
	o1 = new stzString("...♥...♥...")
	Then("the char W form",
		ListEq( o1.SplitAtCharsW('@char = "♥"'), [ "...", "...", "..." ] ), TRUE)
	o2 = new stzString("...♥♥...♥♥...")
	Then("the substring W form",
		ListEq( o2.SplitAtSubStringsW('{ @SubString = "♥♥" }'), [ "...", "...", "..." ] ), TRUE)
	o3 = new stzString("...ONE...TWO...ONE")
	Then("an OR condition",
		ListEq( o3.SplitAtSubStringsW('{ @SubString = "ONE" or @SubString = "TWO" }'),
			[ "...", "...", "..." ] ), TRUE)
	Then("the WF anonymous-function form",
		ListEq( o3.SplitAtSubStringsWF( func s { return Q(s).IsOneOfThese([ "ONE", "TWO" ]) } ),
			[ "...", "...", "..." ] ), TRUE)
	Then("... with IsEither",
		ListEq( o3.SplitAtSubStringsWF( func s { return Q(s).IsEither( "ONE", :Or = "TWO") } ),
			[ "...", "...", "..." ] ), TRUE)
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
