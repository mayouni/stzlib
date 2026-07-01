load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyCSQ([aliases], :By = " @i ", :CS = FALSE) replaces each listed alias
# by " @i ". Here none of the aliases occur in the string, so it is unchanged.
# Archive block #262.

Scenario("Replace-many-CS with no matching alias")
	Given('" isNumber( 0+  @item  ) "')
	o1 = new stzString(" isNumber( 0+  @item  ) ")
	cResult = o1.ReplaceManyCSQ([
		" @position ", " @CurrentPosition ",
		" @Current@i ", " @CurrentI ",
		" @EachPosition ", " @EachI " ],
		:By = " @i ", :CS = FALSE).Content()
	Then("no alias matches, so the string is unchanged", cResult, " isNumber( 0+  @item  ) ")
EndScenario()

Summary()
