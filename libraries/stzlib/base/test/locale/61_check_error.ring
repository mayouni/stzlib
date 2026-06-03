# Narrative
# --------
# #TODO check error
#
# Extracted from stzlocaletest.ring, block #61.

load "../../stzBase.ring"


pr()

# Testing the conversion of time to string

o1 = new stzLocale("ru_RU")
? o1.CountryName()			#--> russia
? o1.CountryNativeName()	#--> Россия
? o1.CurrencyFraction()		#--> Kopek

? o1.amText() #--> AM
? o1.MeasurementSystem() #--> metricsytem

? o1.ToTimeAsString("05:08:34", :Default) #TODO //Check why it returns an error!
#-->  Invalid time provided!

? o1.ToStzTime("05:08:34").ToStringXT(:Long) #TODO //Check why it returns nothing!
	# returns 5:08:34  Paris, Madrid (heure d’été)
	# Which is not correct because this is influenced by
	# the system locale on my machine (french) and not
	# the locale we defined ("en_US")

# "hh:mm:sss.zzz"

pf()
