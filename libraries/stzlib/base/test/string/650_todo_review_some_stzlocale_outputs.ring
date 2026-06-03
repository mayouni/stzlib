# Narrative
# --------
# TODO: review some stzLocale outputs...
#
# Extracted from stzStringTest.ring, block #650.

load "../../stzBase.ring"


pr()

# The standard (ISO) form of a locale is <language>_<script>_<country> where:
# 	-> <language> is an abbreviation of 2 or 3 lowercase letters
#	-> <script> is an abbreviation of 4 letters, the 1st beeing capitalised
#	-> <country> is an abbreviation of 2 or 3 uppercase letters
#
#	Example: "ar_Arab_TN" is the locale form where:
#	-> "ar" is the abbreviation of arabic language
#	-> "Arab" is the abbreviation of arabic script
#	-> "TN" is the abbreviation the country Tunisia
#
# Usually, locale is provided in <language>_<country> form like this:
#	-> "ar_TN" or "fr_FR" or "en_US" for example
#
# All these forms are supported by Softanza, but not only them!
#
# In fact, both of these standard forms return TRUE

? StzStringQ("ar_arab_tn").IsLocaleAbbreviation()
#--> TRUE

? StzStringQ("ar_TN").IsLocaleAbbreviation()
#--> TRUE
# (as a side note, Softanza doesn't care of the case, so do not feel any pressure)

# But this one also return TRUE
? StzStringQ("Arab_TN").IsLocaleAbbreviation()
#--> TRUE
# Which corresponds to the non-standard form <script>_<country>.

# And this is accepted by Softanza, because when you use it to create
# a locale object, Softanza inferes the language from the script, and
# constructs the hole standard-formed abbreviation for you:

? StzLocaleQ("Arab_TN").Abbreviation()	#--> "ar_Arab_TN"	TODO: Check it!
# (as a side note, even if you don't respect standard lettercasing,
# Softanza accepts your inputs, and returns an abbreviation that
# is wellformed regarding to the standard!)

# You may think that you would abuse this spirit of flexibility by
# trying to induce Softanza in error by providing sutch an abbreviation
# form <scrip>_<language>:

? StzStringQ("arab_ar").IsLocaleAbbreviation()
#--> FALSE

# The point is that the first abbreviation is a script ("arab" -> arabic),
# and that, conforming to the standard, the second one must be an abbreviation
# of a country ("ar" -> :Argentina). Try this:

? StzCountryQ("ar").Name()
#--> argentina

# And because :Argentina do not have arabic, neigher as a spoken language nor
# a written script, then the returned result is FALSE!

# When you do the same with a country like :Turkey or :Iran, for example,
# where arabic script is (historically) used in writtan turkish and persian
# languages, than the abbreviation is accepted to be well formed

? StzStringQ("arab_tk").IsLocaleAbbreviation()
# !--> TRUE	TODO: Check it!

# And, therefore, you can use it to create locale object:

? StzLocaleQ("arab_tk").Abbreviation()
#--> ar_Arab_TK	TODO: Check it!

? StzLocaleQ("ar_Arab_TK").CountryName()
# !--> :turkey NOT :Egypt

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17
