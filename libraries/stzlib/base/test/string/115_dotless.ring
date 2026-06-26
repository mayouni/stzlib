# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #115.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Dotless"): Dotless() is a NO-OP on
# Arabic -- it returns the input unchanged instead of the dotless rendering the
# archive shows. The source carries a #TODO ("implementation needs
# enhancements"). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Dotless("فلسطين الأبيّة") 		#--> expected "ٯلسطٮں الأٮٮّه" (currently unchanged)
? Dotless("عاشت المقاومة") 		#--> expected "عاسٮ المٯاومه"
? Dotless("تونس معك يا غزّة")		#--> expected "ٮوٮس معک ٮا عرّه"
? Dotless("جمعية الخيرات")		#--> expected "حمعٮه الحٮراٮ"
? Dotless("أفديك بروحي يا قدس") 	#--> expected "أٯدٮک ٮروحٮ ٮا ٯدس"
? Dotless("مشمش وخوخ وزيتون")		#--> expected "مسمس وحوح ورٮٮوٮ"

pf()
