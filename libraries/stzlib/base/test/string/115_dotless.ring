load "../../stzBase.ring"
load "../_narrated.ring"

# Dotless() on full Arabic phrases: every dotted letter drops to its
# rasm skeleton, diacritics (shadda) are kept, and noon takes its
# positional form -- medial ٮ, final/isolated ں. Archive block #115.

Scenario("Six phrases in their dotless skeleton")
	Then("falastin al-abiyya",
		Dotless("فلسطين الأبيّة"), "ٯلسطٮں الأٮٮّه")
	Then("aashat al-muqawama",
		Dotless("عاشت المقاومة"), "عاسٮ المٯاومه")
	Then("tunis maak ya ghazza",
		Dotless("تونس معك يا غزّة"), "ٮوٮس معک ٮا عرّه")
	Then("jamiyat al-khayrat",
		Dotless("جمعية الخيرات"), "حمعٮه الحٮراٮ")
	Then("afdik bi-ruhi ya quds",
		Dotless("أفديك بروحي يا قدس"), "أٯدٮک ٮروحٮ ٮا ٯدس")
	Then("mishmish wa-khukh wa-zaytun",
		Dotless("مشمش وخوخ وزيتون"), "مسمس وحوح ورٮٮوں")
EndScenario()

Summary()
