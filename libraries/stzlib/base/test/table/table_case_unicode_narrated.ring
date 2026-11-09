# Finding a cell with case ignored, in every script.
#
# stzTable.FindCellCS(text, 0) asks the engine (table.zig find_cell_cs),
# which compared cells through value.zig's eqlCS -- and that folded ASCII
# letters only: "ΑΘΉΝΑ" did not find the cell "Αθήνα" with case ignored,
# while stzString called the two equal (STZLIB-LISTCI-UNICODE-01). The
# engine now reads one fold, engine/src/casefold.zig, everywhere.
#
# Column names are found in Ring (FindColByName lowercases both sides with
# StzLower), which already handled every script; the last scenario keeps
# that true.
#
# Expectations from CaseFolding.txt, written by hand:  Ή -> ή,  ß -> ss.
# Ends on Summary() then shutdown($_zst_fail).

load "../../stzBase.ring"
load "../_narrated.ring"

oTcu = new stzTable([ [ :NAME, :CITY, "πόλη" ], [ "Ali", "Αθήνα", "x" ], [ "Dania", "straße", "y" ], [ "Omar", "Tunis", "z" ] ])

Scenario("FindCellCS with case ignored")
	Then("ΑΘΉΝΑ finds the cell Αθήνα", @@(oTcu.FindCellCS("ΑΘΉΝΑ", 0)), "[ [ 2, 1 ] ]")
	Then("but not when case counts", @@(oTcu.FindCellCS("ΑΘΉΝΑ", 1)), "[ ]")
	Then("STRASSE finds the cell straße: ß folds to ss", @@(oTcu.FindCellCS("STRASSE", 0)), "[ [ 2, 2 ] ]")
	Then("ASCII as before: TUNIS finds Tunis", @@(oTcu.FindCellCS("TUNIS", 0)), "[ [ 2, 3 ] ]")
	Then("and a text that is in no cell finds nothing", @@(oTcu.FindCellCS("ΡΏΜΗ", 0)), "[ ]")
EndScenario()

Scenario("Column names in another case, found in Ring")
	Then("ΠΌΛΗ finds the column πόλη", oTcu.FindCol("ΠΌΛΗ"), 3)
	Then("CITY finds the column city", oTcu.FindCol("CITY"), 2)
EndScenario()

Summary()
shutdown($_zst_fail)
