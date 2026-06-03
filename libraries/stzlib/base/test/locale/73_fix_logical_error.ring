# Narrative
# --------
# #TODO fix logical error
#
# Extracted from stzlocaletest.ring, block #73.

load "../../stzBase.ring"


pr()

# Defining a locale from just a script

? DefaultLanguageForScript(:Mongolian)
#--> mongolian

o1 = new stzLocale([ :Script = "Mongolian" ])

? o1.Abbreviation()	#--> returned mn_CN but should be mn_MN
? o1.LanguageName()	#--> mongolian
? o1.CountryName()	#--> returned china but should be mongolia

# If we provide :Mongolian without specifying it is a script,
# then Softanza captures it as a language and thus returns
# more precise output like this:

o1 = new stzLocale(:Mongolian)

? o1.Abbreviation()	#--> mn_MN
? o1.LanguageName()	#--> mongolian
? o1.CountryName()	#--> mongolia

pf()
# Executed in 0.05 second(s) in Ring 1.23
