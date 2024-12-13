load "../stzmax.ring"

/*------------------- #TODO check correctness

profon

? StzCountryQ(:Iran).Languages()
#--> [ :northern_luri, :southern_kurdish ]

? StzCountryQ(:Iran).LanguagesAbbreviations()
#--> [ "fa", "peo", "pal", "mzn", "bqi", "sdh" ]

proff()
# Executed in 0.02 second(s).

/*-------------------

? StzCountryQ("germany").Language()
#--> german

/*-------------------

profon

? @@NL( CountriesAndTheirDefaultLanguages() )
#--> [
#	[ "afghanistan", "persian" ],
#	[ "albania", "albanian" ],
#	[ "algeria", "arabic" ],
#	[ "american_samoa", "samoan" ],
#	[ "andorra", "catalan" ],
#	[ "angola", "portuguese" ],
#	[ "anguilla", "english" ],
#	[ "antarctica", "russian" ],
#	[ "antigua_and_barbuda", "???" ],
#	[ "argentina", "spanish" ],
#	[ "armenia", "armenian" ],
#	[ "aruba", "papiamento" ],
#	[ "australia", "english" ],
#	[ "austria", "german" ],
#	[ "azerbaijan", "azerbaijani" ],
#	[ "bahamas", "???" ],
#	[ "bahrain", "arabic" ],
#	[ "bangladesh", "bengali" ],
#	[ "barbados", "english" ],
#	[ "belarus", "russian" ],
#	[ "belgium", "dutch" ],
#	[ "belize", "english" ],
#	[ "benin", "french" ],
#	[ "bermuda", "english" ],
#	[ "bhutan", "dzongkha" ],
#	[ "bolivia", "spanish" ],
#	[ "bosnia_and_herzegowina", "bosnian" ],
#	[ "botswana", "english" ],
#	[ "bouvet_island", "norwegian" ],
#	[ "brazil", "portuguese" ],
#	[ "british_indian_ocean_territory", "english" ],
#	[ "brunei", "malay" ],
#	[ "bulgaria", "bulgarian" ],
#	[ "burkina_faso", "french" ],
#	[ "burundi", "rundi" ],
#	[ "cambodia", "khmer" ],
#	[ "cameroon", "english" ],
#	[ "canada", "english" ],
#	[ "cape_verde", "english" ],
#	[ "cayman_islands", "english" ],
#	[ "central_african_republic", "french" ],
#	[ "chad", "french" ],
#	[ "chile", "spanish" ],
#	[ "china", "chinese" ],
#	[ "christmas_island", "english" ],
#	[ "cocos_islands", "malay" ],
#	[ "colombia", "spanish" ],
#	[ "comoros", "arabic" ],
#	[ "congo_kinshasa", "french" ],
#	[ "congo_brazzaville", "french" ],
#	[ "cook_islands", "english" ],
#	[ "costa_rica", "spanish" ],
#	[ "cote_d_ivoire", "french" ],
#	[ "croatia", "croatian" ],
#	[ "cuba", "spanish" ],
#	[ "cyprus", "greek" ],
#	[ "czech_republic", "greek?" ],
#	[ "denmark", "danish" ],
#	[ "djibouti", "french" ],
#	[ "dominica", "english" ],
#	[ "dominican_republic", "spanish" ],
#	[ "timor_leste", "spanish" ],
#	[ "ecuador", "spanish" ],
#	[ "egypt", "arabic" ],
#	[ "el_salvador", "spanish" ],
#	[ "equatorial_guinea", "spanish" ],
#	[ "eritrea", "tigrinya" ],
#	[ "estonia", "estonia" ],
#	[ "ethiopia", "english" ],
#	[ "falkland_islands", "english" ],
#	[ "faroe_islands", "faroese" ],
#	[ "fiji", "english" ],
#	[ "finland", "finnish" ],
#	[ "france", "french" ],
#	[ "guernsey", "english" ],
#	[ "french_guiana", "french" ],
#	[ "french_polynesia", "french" ],
#	[ "french_southern_territories", "french" ],
#	[ "gabon", "french" ],
#	[ "gambia", "french" ],
#	[ "georgia", "georgian" ],
#	[ "germany", "german" ],
#	[ "ghana", "english" ],
#	[ "gibraltar", "english" ],
#	[ "greece", "greek" ],
#	[ "greenland", "greenlandic" ],
#	[ "grenada", "english" ],
#	[ "guadeloupe", "french" ],
#	[ "guam", "chamorro" ],
#	[ "guatemala", "spanish" ],
#	[ "guinea", "french" ],
#	[ "guinea_bissau", "portuguese" ],
#	[ "guyana", "english" ],
#	[ "haiti", "french" ],
#	[ "heard_and_mcdonald_islands", "english" ],
#	[ "honduras", "spanish" ],
#	[ "hong_kong", "english" ],
#	[ "hungary", "hungarian" ],
#	[ "iceland", "icelandic" ],
#	[ "india", "hindi" ],
#	[ "indonesia", "indonesian" ],
#	[ "iran", "persian" ],
#	[ "iraq", "arabic" ],
#	[ "ireland", "english" ],
#	[ "israel", "hebrew" ],
#	[ "italy", "italian" ],
#	[ "jamaica", "english" ],
#	[ "japan", "japanese" ],
#	[ "jordan", "arabic" ],
#	[ "kazakhstan", "kazakh" ],
#	[ "kenya", "english" ],
#	[ "kiribati", "english" ],
#	[ "north_korea", "korean" ],
#	[ "south_korea", "korean" ],
#	[ "kuwait", "arabic" ],
#	[ "kyrgyzstan", "russian" ],
#	[ "laos", "lao" ],
#	[ "latvia", "latvian" ],
#	[ "lebanon", "arabic" ],
#	[ "lesotho", "english" ],
#	[ "liberia", "liberia" ],
#	[ "libya", "arabic" ],
#	[ "liechtenstein", "german" ],
#	[ "lithuania", "lithuanian" ],
#	[ "luxembourg", "luxembourgish" ],
#	[ "macau", "cantonese" ],
#	[ "macedonia", "macedonian" ],
#	[ "madagascar", "french" ],
#	[ "malawi", "english" ],
#	[ "malaysia", "malay" ],
#	[ "maldives", "sinhala" ],
#	[ "mali", "french" ],
#	[ "malta", "maltese" ],
#	[ "marshall_islands", "marshallese" ],
#	[ "martinique", "french" ],
#	[ "mauritania", "arabic" ],
#	[ "mauritius", "english" ],
#	[ "mayotte", "french" ],
#	[ "mexico", "spanish" ],
#	[ "micronesia", "spanish" ],
#	[ "moldova", "romanian" ],
#	[ "monaco", "french" ],
#	[ "mongolia", "mongolian" ],
#	[ "montserrat", "english" ],
#	[ "morocco", "arabic" ],
#	[ "mozambique", "portuguese" ],
#	[ "myanmar", "portuguese" ],
#	[ "namibia", "english" ],
#	[ "nauru", "nauruan" ],
#	[ "nepal", "nepali" ],
#	[ "netherlands", "dutch" ],
#	[ "curacao", "dutch" ],
#	[ "new_caledonia", "french" ],
#	[ "new_zealand", "english" ],
#	[ "nicaragua", "spanish" ],
#	[ "niger", "french" ],
#	[ "nigeria", "english" ],
#	[ "niue", "english" ],
#	[ "norfolk_island", "english" ],
#	[ "northern_mariana_islands", "chamorro" ],
#	[ "norway", "norwegian_bokmal" ],
#	[ "oman", "arabic" ],
#	[ "pakistan", "punjabi" ],
#	[ "palau", "palauan" ],
#	[ "palestine", "arabic" ],
#	[ "panama", "spanish" ],
#	[ "papua_new_guinea", "tok_pisin" ],
#	[ "paraguay", "spanish" ],
#	[ "peru", "spanish" ],
#	[ "philippines", "filipino" ],
#	[ "pitcairn", "english" ],
#	[ "poland", "polish" ],
#	[ "portugal", "portuguese" ],
#	[ "puerto_rico", "spanish" ],
#	[ "qatar", "arabic" ],
#	[ "reunion", "french" ],
#	[ "romania", "romanian" ],
#	[ "russia", "russian" ],
#	[ "rwanda", "kinyarwanda" ],
#	[ "saint_kitts_and_nevis", "sinhala" ],
#	[ "saint_lucia", "sinhala" ],
#	[ "saint_vincent_and_the_grenadines", "sinhala" ],
#	[ "samoa", "samoan" ],
#	[ "san_marino", "italian" ],
#	[ "sao_tome_and_principe", "portugese" ],
#	[ "saudi_arabia", "arabic" ],
#	[ "senegal", "french" ],
#	[ "seychelles", "english" ],
#	[ "sierra_leone", "english" ],
#	[ "singapore", "malay" ],
#	[ "slovakia", "slovak" ],
#	[ "slovenia", "slovenian" ],
#	[ "solomon_islands", "english" ],
#	[ "somalia", "somali" ],
#	[ "south_africa", "zulu" ],
#	[ "south_georgia_and_south_sandwich_islands", "english" ],
#	[ "spain", "spanish" ],
#	[ "sri_lanka", "sinhala" ],
#	[ "saint_helena", "english" ],
#	[ "saint_pierre_and_miquelon", "french" ],
#	[ "sudan", "arabic" ],
#	[ "suriname", "dutch" ],
#	[ "svalbard_and_jan_mayen_islands", "norwegian_bokmal" ],
#	[ "eswatini", "swiss_german" ],
#	[ "sweden", "swedish" ],
#	[ "switzerland", "german" ],
#	[ "syria", "arabic" ],
#	[ "taiwan", "mandarin" ],
#	[ "tajikistan", "tajik" ],
#	[ "tanzania", "swahili" ],
#	[ "thailand", "thai" ],
#	[ "togo", "french" ],
#	[ "tokelau", "tokelauan" ],
#	[ "tonga", "tongan" ],
#	[ "trinidad_and_tobago", "english" ],
#	[ "tunisia", "arabic" ],
#	[ "turkey", "turkish" ],
#	[ "turkmenistan", "turkmen" ],
#	[ "turks_and_caicos_islands", "english" ],
#	[ "tuvalu", "tuvaluan" ],
#	[ "uganda", "english" ],
#	[ "ukraine", "ukrainian" ],
#	[ "united_arab_emirates", "arabic" ],
#	[ "united_kingdom", "english" ],
#	[ "united_states", "english" ],
#	[ "united_states_minor_outlying_islands", "english" ],
#	[ "uruguay", "spanish" ],
#	[ "uzbekistan", "uzbek" ],
#	[ "vanuatu", "bislama" ],
#	[ "vatican", "italian" ],
#	[ "venezuela", "spanish" ],
#	[ "vietnam", "vietnamese" ],
#	[ "british_virgin_islands", "english" ],
#	[ "united_states_virgin_islands", "english" ],
#	[ "wallis_and_futuna_islands", "french" ],
#	[ "western_sahara", "arabic" ],
#	[ "yemen", "arabic" ],
#	[ "canary_islands", "spanish" ],
#	[ "zambia", "bemba" ],
#	[ "zimbabwe", "shona" ],
#	[ "clipperton_island", "french" ],
#	[ "montenegro", "serbian" ],
#	[ "serbia", "serbian" ],
#	[ "saint_barthelemy", "french" ],
#	[ "saint_martin", "dutch" ],
#	[ "ascension_island", "english" ],
#	[ "aland_islands", "swedish" ],
#	[ "diego_garcia", "french" ],
#	[ "ceuta_and_melilla", "arabic" ],
#	[ "isle_of_man", "manx" ],
#	[ "jersey", "french" ],
#	[ "tristan_da_cunha", "english" ],
#	[ "south_sudan", "english" ],
#	[ "bonaire", "papiamento" ],
#	[ "sint_maarten", "french" ],
#	[ "kosovo", "albanian" ],
#	[ "outlying_oceania", "malay" ],
#	[ "scottland", "scottish_gaelic" ],
#	[ "england", "english" ],
#	[ "wales", "welsh" ],
#	[ "norther_ireland", "irish" ]
# ]

proff()
# Executed in 0.04 second(s).

/*-------------------

profon

? CountriesforWhichDefaultLanguageIs(:english)
#--> [
#	:anguilla, :australia, :barbados,
#	:belize, :bermuda, :botswana, :british_indian_ocean_territory,
#	:cameroon, :canada, :cape_verde, :cayman_islands, :christmas_island,
#	:cook_islands,, :dominica, :ethiopia, :falkland_islands, :fiji,
#	:guernsey, :ghana, :gibraltar, :grenada, :guyana, :heard_and_mcdonald_islands,
#	:hong_kong, :ireland, :jamaica, :kenya, :kiribati, :lesotho, :malawi,
#	:mauritius, :montserrat, :namibia, :new_zealand, :nigeria,
#	:niue, :norfolk_island, :pitcairn, :seychelles, :sierra_leone,
#	:solomon_islands, :south_georgia_and_south_sandwich_islands,
#	:saint_helena, :trinidad_and_tobago, :turks_and_caicos_islands,
#	:uganda, :united_kingdom, :united_states, :united_states_minor_outlying_islands,
#	:british_virgin_islands, :united_states_virgin_islands, :ascension_island,
#	:tristan_da_cunha, :south_sudan, :england ]

proff()
# Executed in 0.01 second(s).

/*-------------------

profon

# You can create a country by specifying one of these information:
# name, short or long abbreviation, phone code, or even its default language!

# All these create the country Egypt and return its name

? StzCountryQ(:Egypt).Name()
#--> :egypt

? StzCountryQ(:EGY).Name()
#--> :egypt

? StzCountryQ(:EG).Name()
#--> :egypt

? StzCountryQ("64").Name()	# 64 is the ISO country code of Egypt
#--> :egypt

? StzCountryQ("+20").Name()	# +20 is the international phone code of Egypt
#--> :egypt

? StzCountryQ(:Arabic).Name()	# Because Arabic is default language of Egypt!
#--> :egypt

proff()
# Executed in 0.03 second(s).

/*-------------------
*/
profon

# More conveniently, all the information Softanza knwows about the
# country Egypt are accessible directly like this:

StzCountryQ(:Egypt) {

	? QtNumber()
	? Country()
	? Name()
	? NativeName()
	? Content()
	
	? Abbreviation()
	? ShortAbbreviation()
	? LongAbbreviation()
	
	? PhoneCode()
	
	? DefaultLanguageQtNumber()
	? LanguageQtNumber()
	? DefaultLanguage()
	? DefaultLanguageName()
	? Language()
	? LanguageName()
	? LanguageNativeName()
	? DefaultLanguageNativeName()
				
	? Script()
	? ScriptName()
	? ScriptQtNumber()
			
	? Currency()
	? CurrencyNativeName()
 	? CurrencySymbol()
	? CurrencyAbbreviation()
	? CurrencyFractionalUnit()
	? CurrencyFraction()
	? CurrencyBase()
	? CurrencyEmojiFlag()
}

proff()
# Executed in 0.06 second(s).
