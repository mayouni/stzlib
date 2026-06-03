# Narrative
# --------
# #narration: chars looking similar but are different!
#
# Extracted from stzGlobalTest.ring, block #52.

load "../../stzBase.ring"

pr()

# Look at theses statements and guess their results:

StartProfiler()
	
	? "۰" = "٠"	#--> FALSE
	? "۱" = "١"	#--> FALSE
	? "۲" = "٢"	#--> FALSE
	? "۳" = "٣"	#--> FALSE
	? "۸" = "٨"	#--> FALSE		
	? "۹" = "٩"	#--> FALSE

	? Unicode("۱")	#--> 1777
	? Unicode("١")	#--> 1633

	# Surprised?
	
	# The point is that Unicode assigns unique codes to Chars and
	# not to their visual glyfs. To give a clear example:
	
	# "O", "Ο", and "О" appear the same for us, and for the particular
	# font we use in our system to render them, but from a unicode
	# standpoint, they are different.

	? AreEqual([ "O", "Ο", "О" ]) 	#--> FALSE

	# In fact, they are different in uncicodes code points, scripts they
	# represent, and unicode names they have:

	? Unicodes([ "O", "Ο", "О" ]) 	#--> [ 79, 927, 1054 ]
	? Scripts([ "O", "Ο", "О" ]) 	#--> [ :Latin, :Greek, :Cyrillic ]
	? CharsNames([ "O", "Ο", "О" ])
	#--> [
	# 	"LATIN CAPITAL LETTER O",
	# 	"GREEK CAPITAL LETTER OMICRON",
	# 	"CYRILLIC CAPITAL LETTER O"
	# ]

StopProfiler()

pf()
# Executed in 0.14 second(s) on Ring 1.21
# Executed in 0.18 second(s) on Ring 1.20
