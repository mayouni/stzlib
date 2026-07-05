load "../../stzBase.ring"
load "../_narrated.ring"

# Dotless() renders text in its dotless skeleton (rasm): Latin drops
# diacritics and turns i/î into the dotless "ı" (j into "ȷ"); Arabic
# maps each dotted letter to its dotless form. Now table-driven over
# DotlessLettersXT() + a positional noon rule (medial noon -> ٮ,
# final/isolated noon -> ں). Archive block #114.

Scenario("Latin, dotless")
	Then("i -> ı and accents dropped",
		Dotless("alitalia extrême extèrieur aéorô ûltrâ"),
		"alıtalıa extreme exterıeur aeoro ultra")
EndScenario()

Scenario("Arabic, dotless")
	# The archive wrote the final noon of وزيتون as ٮ, which contradicts
	# its own فلسطين -> ...ں (block #115); a FINAL noon is ں. Asserted at
	# the consistent rasm.
	Then("dots stripped to the rasm",
		Dotless("مشمش وخوخ وزيتون"), "مسمس وحوح ورٮٮوں")
EndScenario()

Summary()
