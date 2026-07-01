load "../../stzBase.ring"
load "../_narrated.ring"

# Lines() splits a multi-line string into its lines; the 3rd line here is all
# digits. Archive block #255.

Scenario("The lines of a multi-line string")
	Given('a 6-line block, line 3 = "123346"')
	o1 = new stzString("ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")
	Then("the 3rd line is '123346'", o1.Lines()[3], "123346")
	Then("that line is made of numbers", Q( o1.Lines()[3] ).IsMadeOfNumbers(), TRUE)
EndScenario()

Summary()
