load "stzlib.ring"

# TODO: Review this class on the light of the changes made in stzLocale,
# stzLanguage, stzScript, and stzCountry classes

o1 = new stzMultiString([ :en = "house", :fr = "maison", :ar = "منزل" ])

? o1.tr(:ar) 	#--> "منزل"

? o1.tr(:fr)	#--> maison

? o1.ar_fr() 	#--> [ "منزل", "maison" ]

? o1.fr_en() 	#--> [ "maison", "house" ]

? o1.ar() + NL	#--> "منزل"

? o1.show()
#-->
# 'en': "house"
# 'fr': "maison"
# 'ar': "منزل"
