load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzJson defects fixed on fix/gscl (wave-4 notes, stzJson):
# ToString, ToStringXT, Show, Print and Copy raised "aList must be a
# well-formatted JSON list" for every non-empty ARRAY, because ListToJson
# accepts lists of pairs only; and an empty object wrote as [].

Scenario("An array writes back to text")
	o = new stzJson('[1, 2, "x"]')
	Then("an array of numbers and text", o.ToString(), '[1,2,"x"]')
	o = new stzJson('[{"a": 1}, {"b": [2, 3]}]')
	Then("an array of objects keeps each object", o.ToString(), '[{"a":1},{"b":[2,3]}]')
	o = new stzJson('[[1, 2], [3]]')
	Then("an array of arrays", o.ToString(), '[[1,2],[3]]')
	o = new stzJson([ "a", "b" ])
	Then("a Ring list of items is an array too", o.ToString(), '["a","b"]')
	Then("the indented form has one item per line",
		o.ToStringXT(), "[" + char(10) + char(9) + '"a",' + char(10) + char(9) + '"b"' + char(10) + "]")
EndScenario()

Scenario("Copy, Show and Print run on an array")
	o = new stzJson('[1, 2, "x"]')
	o2 = o.Copy()
	Then("the copy writes the same text", o2.ToString(), '[1,2,"x"]')
	Then("the copy is an array", o2.IsArray(), 1)
	o2.Clear()
	Then("clearing the copy leaves the original alone", o.Size(), 3)
	Then("Show raises nothing", Raises(o, "o.Show()"), "")
	Then("Print raises nothing", Raises(o, "o.Print()"), "")
EndScenario()

Scenario("Objects still write as before, and an empty one writes as {}")
	o = new stzJson('{"k": [1, 2], "n": "v"}')
	Then("an object holding an array", o.ToString(), '{"k":[1,2],"n":"v"}')
	o = new stzJson('{}')
	Then("an empty object", o.ToString(), "{}")
	Then("its indented form", o.ToStringXT(), "{}")
	o = new stzJson('[]')
	Then("an empty array", o.ToString(), "[]")
	o = new stzJson('{"a": 1}')
	o.Clear()
	Then("a cleared object", o.ToString(), "{}")
EndScenario()

Summary()

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
