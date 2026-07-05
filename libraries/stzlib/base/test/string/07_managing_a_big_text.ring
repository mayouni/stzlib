load "../../stzBase.ring"
load "../_narrated.ring"

# A 6.6-million-char text: counting its chars, lines and bytes, and
# finding a word inside it. Archive block #07.

Scenario("Managing a big text")
	cBigText = read("../_data/bigtext.txt")
	oBig = new stzString(cBigText)
	Then("six-plus million chars", oBig.NumberOfChars(), 6617121)
	Then("128,457 lines", oBig.NumberOfLines(), 128457)
	Then("its byte size", oBig.SizeInBytes(), 6617121)
	Then("madrid appears eight times",
		len( oBig.FindCS("madrid", FALSE) ), 8)
EndScenario()

Summary()
