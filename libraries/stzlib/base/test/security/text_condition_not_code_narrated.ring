load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R17-01 -- a condition given as text is judged, never run.
#
# Read against PHP2Shell (CVE-2026-109618/9) on 2026-10-22: several W methods
# built "_b_ = " + condition and handed it to eval, so a condition was Ring
# CODE -- Ring needs no separator between statements, and
# StringsW("1 StzFileWrite(...)") wrote the file, on Ring 1.27 and on Ring++.
# They now route through the engine's W evaluator (the one FindW uses),
# whose closed grammar has no calls into code. Each scenario pairs the
# injection with the method's ordinary use, so a fix that broke the method
# would fail here too.

$cMark = "_r17_ran.txt"
$cInj = "1 StzFileWrite('" + $cMark + "', 'ran')"
CleanUp()

Scenario("stzList.StringsW and ItemsWhere")
	o = new stzList([ "ab", "kiwi", 12, "xy" ])
	o.StringsW($cInj)
	Then("StringsW did not run the injected call", fexists($cMark), 0)
	o.ItemsWhere($cInj)
	Then("ItemsWhere did not run it", fexists($cMark), 0)
	Then("StringsW still filters (negative sibling)", @@(o.StringsW("len(@string) = 2")), @@([ "ab", "xy" ]))
	Then("...skipping non-strings", @@(o.StringsW("@i > 2")), @@([ "xy" ]))
	Then("ItemsWhere still filters", @@(o.ItemsWhere("@i = 2")), @@([ "kiwi" ]))
	CleanUp()
EndScenario()

Scenario("stzString.Check")
	o = new stzString("abc")
	o.Check($cInj)
	Then("Check did not run it", fexists($cMark), 0)
	Then("Check still answers TRUE when the condition holds everywhere", o.Check("@char != 'z'"), 1)
	Then("...and FALSE when it does not", o.Check("@char = 'a'"), 0)
	CleanUp()
EndScenario()

Scenario("stzStringList.StringsW, Yield and SortBy")
	o = new stzStringList([ "watch", "see", "go" ])
	o.StringsW($cInj)
	o.Yield($cInj)
	Then("StringsW and Yield did not run it", fexists($cMark), 0)
	bR = 0  try  o.SortBy($cInj)  catch  bR = 1  done
	Then("SortBy refuses a key it cannot compute -- it does not run it", bR, 1)
	Then("...and nothing ran", fexists($cMark), 0)
	Then("StringsW still filters", @@(o.StringsW('@string = "see"')), @@([ "see" ]))
	Then("Yield still answers per string", @@(o.Yield("len(@string) = 2")), @@([ 0, 0, 1 ]))
	o.SortBy("len(@string)")
	Then("SortBy still sorts by a computed key", @@(o.Content()), @@([ "go", "see", "watch" ]))
	CleanUp()
EndScenario()

Scenario("a list in a string is read as data")
	o = new stzString("[ 1, 2, StzFileWrite('" + $cMark + "', 'ran') ]")
	bR = 0  try  o.ToList()  catch  bR = 1  done
	Then("ToList refuses a literal that names a function", bR, 1)
	Then("...and nothing ran", fexists($cMark), 0)
	Then("a plain literal still converts", @@(StzStringQ("[ 1, 'a', [ 2, 3 ], TRUE ]").ToList()), @@([ 1, "a", [ 2, 3 ], 1 ]))
	CleanUp()
EndScenario()

Scenario("a query method with arguments still works -- and cannot carry a call")
	o = new stzStringList([ "WATCH", "see", "Watch", "watch" ])
	Then("Q(@string).IsEqualToCS(..., :CS = FALSE) is judged per string",
		@@(o.StringsW('Q(@string).IsEqualToCS("watch", :CS = FALSE)')), @@([ "WATCH", "Watch", "watch" ]))
	o.StringsW('Q(@string).IsEqualToCS("watch", :CS = FALSE) StzFileWrite("' + $cMark + '", "ran")')
	Then("the same shape with a call after it does not run", fexists($cMark), 0)
	o.StringsW('Q(@string).IsEqualToCS(StzFileWrite("' + $cMark + '", "ran"))')
	Then("...nor a call inside its arguments", fexists($cMark), 0)
	Then("a method that does not ASK is not admitted", StzIsQueryCondition('Q(@item).WriteToFile("x")'), 0)
	Then("...nor a method of the list itself", StzIsQueryCondition('This.Clear()'), 0)
	CleanUp()
EndScenario()

Scenario("a name pasted into a method call must be an identifier")
	Then("a plain name passes", StzIsPlainIdentifier("Uppercase"), 1)
	Then("a smuggling one does not", StzIsPlainIdentifier("X() StzFileWrite('a','b') x"), 0)
EndScenario()

CleanUp()
Summary()

# -- helpers (after the main code) ------------------------------------

func CleanUp
	if fexists($cMark)  remove($cMark)  ok
