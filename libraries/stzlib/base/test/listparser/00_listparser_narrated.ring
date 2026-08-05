load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListParser -- walks a list with a
# (start, end, step) parse plan, tracking the current position. Built
# outside any brace-block so Then() stays in file scope. Deterministic.

Scenario("Default parser state over A..L")
    Given("a parser over the 12-item list A..L")
    o = new stzListParser("A":"L")
    Then("List has 12 items", len(o.List()), 12)
    Then("StartPosition is 1", o.StartPosition(), 1)
    Then("EndPosition is 12", o.EndPosition(), 12)
    Then("NumberOfSteps is 1", o.NumberOfSteps(), 1)
    Then("CurrentPosition starts at 1", o.CurrentPosition(), 1)
EndScenario()

Scenario("Parse a strided range")
    Given("Parse(From=3, To=9, Step=3)")
    o = new stzListParser("A":"L")
    o.Parse( :From = 3, :To = 9, :Step = 3 )
    Then("ParsedPositions are [3,6,9]", ListEq(o.ParsedPositions(), [ 3, 6, 9 ]), TRUE)
    Then("ParsedItems are [C,F,I]", ListEq(o.ParsedItems(), [ "C", "F", "I" ]), TRUE)
    Then("CurrentItem is C (first parsed)", o.CurrentItem(), "C")
EndScenario()

Scenario("Step the cursor forward")
    Given("a parsed strided range starting at C")
    o = new stzListParser("A":"L")
    o.Parse( :From = 3, :To = 9, :Step = 3 )
    Then("NextItem advances to F", o.NextItem(), "F")
    Then("CurrentPosition is now 6", o.CurrentPosition(), 6)
EndScenario()

Scenario("Resetting the cursor lands where the parse actually is")

	# -- WHY THIS SCENE EXISTS --
	#
	# ResetCurrentPosition() hardcoded 1. Two things followed from that.
	#
	# It ignored SetDefaultCurrentPosition() outright, so the class had a public
	# default that one of its two "go back to the default" paths honoured
	# (SetCurrentPosition(:Default)) and the other did not.
	#
	# Worse, position 1 is not necessarily IN the parse. Parse(3, 8, 2) yields
	# [3, 5, 7]; a reset then sat the cursor on 1 -- a position the parser's own
	# SetCurrentPosition() refuses -- and CurrentItem() went on reading outside
	# the parsed range as if nothing were wrong. Reset() calls this, so it
	# inherited both.

	Given("a parser over eight items with a declared default of 5")
	oP = new stzListParser([ 10, 20, 30, 40, 50, 60, 70, 80 ])
	oP.SetDefaultCurrentPosition(5)
	oP.SetCurrentPosition(3)

	Then("the cursor moved where it was told", oP.CurrentPosition(), 3)

	When("the cursor is reset")
	oP.ResetCurrentPosition()
	Then("it goes to the DECLARED default, not to 1", oP.CurrentPosition(), 5)
	Then("...which is what :Default has always meant", DefaultOf(oP), 5)

	# THE NEGATIVE SIBLING. The check above would also pass if reset simply went
	# to 5 by some other route, so here the default is left alone at 1 -- and the
	# cursor must come back to 1, not to 5.
	Given("a second parser with the default untouched")
	oQ = new stzListParser([ 10, 20, 30, 40, 50, 60, 70, 80 ])
	oQ.SetCurrentPosition(4)
	oQ.ResetCurrentPosition()
	Then("it resets to its own default of 1", oQ.CurrentPosition(), 1)

	Given("a parse that does not contain position 1")
	oCut = new stzListParser([ 10, 20, 30, 40, 50, 60, 70, 80 ])
	oCut.Parse(3, 8, 2)
	aRPos = oCut.ParsedPositions()
	Then("the parsed positions start at 3", aRPos[1], 3)

	When("that cursor is reset")
	oCut.ResetCurrentPosition()
	Then("it lands INSIDE the parse", oCut.CurrentPosition(), 3)
	Then("...on a position the parser would accept", IsParsed(oCut), TRUE)
	Then("...and the item read is the one at that position", oCut.CurrentItem(), 30)

	# The steps setter wrote a second attribute one letter from the live one --
	# @nSteps beside @nStep -- that nothing ever read. Removing it must leave the
	# setter working exactly as before.
	Given("a parser stepping by three")
	oS = new stzListParser([ 1, 2, 3, 4, 5, 6, 7, 8 ])
	oS.SetNumberOfSteps(3)
	Then("the step is reported back", oS.NumberOfSteps(), 3)
	Then("...and the positions honour it", ListEq(oS.ParsedPositions(), [ 1, 4, 7 ]), TRUE)
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

# what SetCurrentPosition(:Default) settles on, without disturbing the caller
func DefaultOf(poParser)
	poParser.SetCurrentPosition(:Default)
	return poParser.CurrentPosition()

func IsParsed(poParser)
	return StzFindFirst(poParser.CurrentPosition(), poParser.ParsedPositions()) > 0
