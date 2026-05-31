# Narrative
# --------
# ok
#
# Extracted from stzTtexttest.ring, block #35.

load "../../../stzBase.ring"


StzTextQ( "Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl !" ) {
	? OnlyArabic()
	#--> Returns: "حنين جميلة وعمرها 7 سنوات !"

	? OnlyLatin()
	#--> Returns: "Hanine is a nice 7 years-old girl!"
}
