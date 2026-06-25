load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharsW with the :Where / :With named-param form -- replace each matching
# char. Engine-backed, no eval() (the { } block is normalized away). Migrated
# from the retired ReplaceCharsWXT.

Scenario("ReplaceCharsW replaces a specific letter")
	Given('the string "Text processing with Ring"')
	Then('replacing { @char = "i" } with "*"',
		Q("Text processing with Ring").ReplaceCharsWQ(:Where = '{ @char = "i" }', :With = "*").Content(),
		"Text process*ng w*th R*ng")
EndScenario()

Summary()
