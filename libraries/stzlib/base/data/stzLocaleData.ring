// Specifies the format of the currency symbol
_aLocaleCurrencyFormats = [
	[ "0", :ISOSymbol 	], #  ISO-4217 code of the currency (in latin script)
	[ "1", :NativeSymbol 	], # Native currency symbol (in native language)
	[ "2", :NativeName 	]  # User (complete) readable name of the currency (in native language)
]

// Specifies the format for representation of data quantities
_aLocaleDataSizeFormats = [
	[ "0", :IECFormat 	  ], # format using base 1024 and IEC prefixes: KiB, MiB, GiB..
	[ "1", :TraditionalFormat ], # format using base 1024 and SI prefixes: kB, MB, GB..
	[ "2", :SIFormat 	  ]  # format using base 1000 and SI prefixes: kB, MB, GB..
]

// Describes the different formats that can be used when
// converting QDate, QTime, and QDateTime objects, as well as months
// and days, to strings specific to the locale
_aLocaleTimeFormatTypes = [
	:Long   = 0,
	:Short  = 1,
	:Narrow = 2 # A special version for use when space is very limited
]

// Defines a set of options for number-to-string and string-to-number conversions
// They can be retrieved with oLocale.numberOptions() and set with oLocale.setNumberOptions()
_aLocaleNumberOptions = [
	:Default = 0,
	:OmitGroupSeparator = 1,
	:RejectGroupSeparator = 2,
	:OmitLeadingZeroInExponent = 4,
	:RejectLeadingZeroInExponent = 8,
	:IncludeTrailingZeroesAfterDot = 16,
	:RejectTrailingZeroesAfterDot = 32
]

// Defines a set of possible styles for locale specific quotation
_aLocaleQuotationStyles = [
	[ "0", :StandardQuotation  ],
	[ "1", :AlternateQuotation ]
]

// defines which units are used for measurement
_aLocaleMeasurementSystems = [
	# Metric units, such as meters, centimeters and millimeters
	[ "0", :MetricSytem 	 ],
	# Imperial units, such as inches and miles as they are used in the United States
	[ "1", :ImperialUSSystem ],
	# Imperial units, such as inches and miles as they are used in the United Kingdom
	[ "2", :ImperialUKSystem ]

]

_aLocaleAbbreviationsXT = [
	# For each country, the supported abbreviations are provided for each
	# suppoted language and each supported script.
	# Based on: https://www.localeplanet.com/compare/country.html()

	:Afghanistan = [
		[ :persian = "fa-AF", :persian_arabic = "fa-Arab-AF" ],
		[ :pashto = "ps-AF", :pashto_arabic = "ps-Arab-AF" ],
		[ :usbek = "uz-AF", :uzbek_arabic = "uz-Arab-AF" ]
	],

	:Antigua_and_barbuda = [
		[ :english = "en-AG", :english_latin = "en-Latn-AG" ]
	],

	:Anguilla = [
		[ :english = "en-AI", :english_latin = "en-Latn-AI" ]
	],

	:Albania = [
		[ :albanian = "sq-AL", :albanian_latin = "sq-Latn-AL" ]
	],

	:Armenia = [
		[ :armenian = "hy-AM", :armenian_armenian = "hy-Armn-AM" ]
	],

	:Angola	= [
		[ :portugues = "pt-AO", :portugues_latin = "pt-Latn-AO" ],
		[ :lingala = "ln-AO", :lingala_latin = "ln-Latn-AO" ] 	
	],

	:Argentina = [
		[ :spanish = "es-AR", :spanish_latin = "es-Latn-AR" ]
	],

	:American_Samoa = [
		[ :english = "en-AS", :english_latin = "en-Latn-AS" ]
	],

	:Austria = [
		[ :german = "de-AT", :german_latin = "de-Latn-AT" ],
		[ :english = "en-AT", :english_latin = "en-Latn-AT" ]
	],

	:Australia = [
		[:english = "en-AU", :english_latin = "en-Latn-AU" ]
	],

	:Aruba = [
		:dutch = "nl-AW", :dutch_latin = "nl-Latn-AW"
	],

	:Aland_Islands = [
		[ :swedish = "sv-AX", :swedish_latin = "sv-Latn-AX" ]
	],

	:Azerbaijan = [
		[ :Azerbaijani = "az-AZ", :Azerbaijani_Cyrillic = "az-Cyrl-AZ", :Azerbaijani_Latin = "az-Latn-AZ" ]
	],

	:Bosnia_Herzegovina = [
		[ :Bosnian = "bs-BA", :Bosnian_Latin = "bs-Latn-BA", :Bosnian_Cyrillic = "bs-Cyrl-BA" ],
		[ :Croatian = "hr-BA", :Croatian_Latin = "hr-Latn-BA" ],
		[ :Serbian = "sr-BA", :Serbian_Cyrillic = "sr-Cyrl-BA", :Serbian_Latin = "sr-Latn-BA" ]
	],
	
	:Barbados = [
		[ :english = "en-BB", :english_latin = "en-Latn-BB" ]
	],

	:Bangladesh = [
		[ :bangla = "bn-BD", :bangla_bengali = "bn-Beng-BD" ],

		[ :chakma = "ccp-BD", :chakma_chakma = "ccp-Cakm-BD" ]
		# Returns C Locale in Qt!
		#--> may be a bug in Qt or in the standard itself!
		# Provide a solution based on this data :
		# https://metacpan.org/dist/DateTime-Locale/view/lib/DateTime/Locale/ccp_BD.pod
	],
	
	:Belgium = [
		[ :french = "fr-BE", :french_latin = "fr-Latn-BE" ],
		[ :dutch = "nl-BE", :dutch_latin = "nl-Latn-BE" ],
		[ :german = "de-BE", :german_latin = "de-Latn-BE" ],
		[ :English = "en-BE", :english_latin = "en-Latn-BE" ]
	],

	:Burkina = [
		[ :french = "fr-BF", :french_latin = "fr-Latn-BF" ],
		[ :fulah = "ff-BF", :fulah_latin = "ff-Latn-BF" ] # Called also Pulaar
	],

	:Bulgaria = [
		[ :bulgarian = "bg-BG", :bulgarian_latin = "bg-Latn-BG" ]
	],

	:Bahrain = [
		[ :arabic = "ar-BH", :arabic_arabic = "ar-Arab-BH" ]
	],

	:Burundi = [
		[ :english = "en-BI", :english_latin = "en-Latn-BI" ],
		[ :french = "fr-BI", :french_latin = "fr-Latn-BI" ],
		[ :rundi = "rn-BI", :rundi_latin = "rn-Latn-BI" ]
	],

	:Benin = [
		[ :french = "fr-BJ", :french_latin = "fr-Latn-BJ" ],
		[ :yoruba = "yo-BJ", :yoruba_latin = "yo-Latn-BJ" ]
	],

	:Saint_Barthelemy = [
		[ :french = "fr-BL", :french_latin = "fr-Latn-BL" ]
	],

	:Bermuda = [
		[ :english = "en-BM", :english_latin = "en-Latn-BM" ]
	],

	:Brunei	= [
		[ :malay = "ms-BN", :malay_latin = "ms-Latn-BN" ]
	],

	:Bolivia = [
		[ :spanish = "es-BO", :spanish_latin = "es-Latn-BO" ],
		[ :quechua = "qu-BO", :quechua_latin = "qu-Latn-BO" ]
	],

	:Caribbean_Netherlands = [
		[ :dutch = "nl-BQ", :dutch_latin = "nl-Latn-BQ" ]
	],

	:Brazil = [
		[ :spanish = "es-BR", :spanish_latin = "es-Latn-BR" ],
		[ :portuguese = "pt-BR", :portuguese_latin = "pt-Latn-BR" ]
	],

	:Bahamas = [
		[ :english = "en-BS", :english_latin = "en-Latn-BS" ]
	],

	:Bhutan	= [
		[ :dzongkha = "dz-BT", :dzongkha_latin = "dz-Tibt-BT" ]
	],

	:Botswana = [
		[ :english = "en-BW", :english_latin = "en-Latn-BW" ]
	],

	:Belarus = [
		[ :belarusian = "be-BY", :belarusian_cyrillic = "be-Cyrl-BY" ],
		[ :russian = "ru-BY", :russian_cyrillic = "ru-Cyrl-BY" ]
	],

	:Belize	= [
		[ :english = "en-BZ", :english_latin = "en-Latn-BZ" ],
		[ :spanish = "es-BZ", :spanish_latin = "es-Latn-BZ" ]
	],

	:Canada	= [
		[ :english = "en-CA", :english_latin = "en-Latn-CA" ],
		[ :french = "fr-CA", :french_latin = "fr-Latn-CA" ]
	],

	:Cocos_Islands = [
		[ :english = "en-CC", :english_latin = "en-Latn-CC" ]
	],

	:Congo_Kinshasa = [
		[ :french = "fr-CD", :french_latin = "fr-Latn-CD" ],
		[ :lingala = "ln-CD", :lingala_latin = "ln-Latn-CD" ],
		[ :luba_katanga = "lu-CD", :luba_katanga_latin = "lu-Latn-CD" ],
		[ :swahili = "sw-CD", :swahili_latin = "sw-Latn-CD" ]
	],

	:Central_African_Republic = [
		[ :french = "fr-CF", :french_latin = "fr-Latn-CF" ],
		[ :lingala = "ln-CF", :lingala_latin = "ln-Latn-CF" ],
		[ :sango = "sg-CF", :sango_latin = "sg-Latn-CF" ]
	],

	:Congo_Brazzaville = [
		[ :french = "fr-CG", :french_latin = "fr-Latn-CG" ],
		[ :lingala = "ln-CG", :lingala_latin = "ln-Latn-CG" ]
	],

	:Switzerland = [
		[ :german = "de-CH", :german_latin = "de-Latn-CH" ],
		[ :english = "en-CH", :english_latin = "en-Latn-CH" ],
		[ :french = "fr-CH", :french_latin = "fr-Latn-CH" ],
		[ :swiss_german = "gsw-CH", :swiss_german_latin = "gsw-Latn-CH" ],
		[ :italian = "it-CH", :italian_latin = "it-Latn-CH" ],
		[ :portuguese = "pt-CH", :portuguese_latin = "pt-Latn-CH" ],
		[ :romansh = "rm-CH", :romansh_latin = "rm-Latn-CH" ],
		[ :walser = "wae-CH", :walser_latin = "wae-Latn-CH" ]
	],

	:Cote_d_Ivoire = [
		[ :french = "fr-CI", :french_latin = "fr-Latn-CI" ]
	],

	:Cook_Islands = [
		[ :english = "en-CK", :english_latin = "en-Latn-CK" ]
	],

	:Chile = [
		[ :spanish = "es-CL", :spanish_latin = "es-Latn-CL" ]
	],

	:Cameroon = [
		[ :french = "fr-CM", :french_latin = "fr-Latn-CM" ],
		[ :aghem = "agq-CM", :aghem_latin = "agq-Latn-CM" ],
		[ :basaa = "bas-CM", :basaa_latin = "bas-Latn-CM"],
		[ :duala = "dua-CM", :duala_latin = "dua-Latn-CM" ],
		[ :english = "en-CM", :english_latin = "en-Latn-CM" ],
		[ :ewondo = "ewo-CM", :ewondo_latin = "ewo-Latn-CM" ],
		[ :fulah = "ff-CM", :fulah_latin = "ff-Latn-CM" ],
		[ :ngomba = "jgo-CM", :ngomba_latin = "jgo-Latn-CM" ],
		[ :kako = "kkj-CM", :kako_latin = "kkj-Latn-CM" ],
		[ :bafia = "ksf-CM", :bafia_latin = "ksf-Latn-CM" ],
		[ :meta = "mgo-CM", :meta_latin = "mgo-Latn-CM" ],
		[ :mundang = "mua-CM", :mundang_latin = "mua-Latn-CM" ],
		[ :kwasio = "nmg-CM", :kwasio_latin = "nmg-Latn-CM" ],
		[ :ngiemboon = "nnh-CM", :ngiemboon_latin = "nnh-Latn-CM" ],
		[ :yangben = "yav-CM",:yangben_latin = "yav-Latn-CM" ]
	],

	:China = [
		[ :chinese = "zh-CN", :chinese_simplified_han = "zh-Hans-CN" ],
		[ :tibetan = "bo-CN", :tibetan_tibetan = "bo-Tibt-CN" ],
		[ :sichuan_yi = "ii-CN", :sichuan_ui_yi = "ii-Yiii-CN" ],
		[ :uyghur = "ug-CN", :uyghur_arabic = "ug-Arab-CN" ],
		[ :cantonese = "yue-CN", :cantonese_simplified_han = "yue-Hans-CN" ]	
	],

	:Colombia = [
		[ :spanish = "es-CO", :spanish_latin = "es-Latn-CO" ]
	],

	:Costa_Rica = [
		[ :spanish = "es-CR", :spanish_latin = "es-Latn-CR" ]
	],

	:Cuba = [
		[ :spanish = "es-CU",  :spanish_latin = "es-Latn-CU" ]
	],

	:Cape_Verde = [
		[ :kabuverdianu = "kea-CV", :kabuverdianu_latn = "kea-Latn-CV" ],
		[ :portuguese = "pt-CV", :portuguese_latin = "pt-Latn-CV" ]
	],

	:Curacao = [
		[ :dutch = "nl-CW", :dutch_latin = "nl-Latn-CW" ]
	],

	:Christmas_Island = [
		[ :english = "en-CX", :english_latin = "en-Latn-CX" ]
	],

	:Cyprus = [
		[ :greek = "el-CY", :greek_greek = "el-Grek-CY" ],
		[ :english = "en-CY", :english_latin = "en-Latn-CY" ],
		[ :turkish = "tr-CY", :turkish_latin = "tr-Latn-CY" ]
	],

	:Czechia = [
		[ :czech = "cs-CZ", :czech_latin = "cs-Latn-CZ" ]
	],

	:Germany = [
		[ :german = "de-DE", :german_latin = "de-Latn-DE" ],
		[ :lower_sorbian = "dsb-DE", :lower_sorbian_latin = "dsb-Latn-DE" ],
		[ :english = "en-DE", :english_latin = "en-Latn-DE" ],
		[ :upper_sorbian = "hsb-DE", :upper_sorbian_latin = "hsb-Latn-DE" ],
		[ :colognian = "ksh-DE", :colognian_latin = "ksh-Latn-DE" ],
		[ :low_german = "nds-DE", :low_german_latin = "nds-Latn-DE" ]
	],

	:Diego_Garcia =	[
		[ :english = "en-DG", :english_latin = "en-Latn_DG" ]
	],

	:Djibouti = [
		[ :arabic = "ar-DJ", :arabic_arabic = "ar-Arab-DJ" ],
		[ :french = "fr-DJ", :french_latin = "fr-Latn-DJ" ],
		[ :somali = "so-DJ", :somali_latn = "so-Latn-DJ" ]
	],

	:Denmark = [
		[ :danish = "da-DK", :danish_latin = "da-Latn-DK" ],
		[ :english = "en-DK", :english_latin = "en-Latn-DK" ],
		[ :faroese = "fo-DK", :faroese_latin = "fo-Latn-DK" ]
	],

	:Dominica = [
		[ :english = "en-DM", :english_latin = "en-Latn-DM" ]
	],

	:Dominican_Republic = [
		[ :spanish = "es-DO", :spanish_latin = "es-Latn-DO" ]
	],

	:Algeria = [	
		[ :arabic = "ar-DZ", :arabic_arabic = "ar-Arab-DZ" ],
		[ :french = "fr-DZ", :french_latin = "fr-Latn-DZ" ],
		[ :kabyle = "kab-DZ", :kabyle_latin = "kab-Latn-DZ" ]
	],

	:Ceuta_and_Melilla = [
		[ :spanish = "es-EA", :spanish_latin = "es-Latn-EA" ]
	],

	:Ecuador = [
		[ :spanish = "es-EC", :spanish_latin = "es-Latn-EC" ],
		[ :quechua = "qu-EC", :quechua_latin = "qu-Latn-EC" ]
	],

	:Estonia = [
		[ :estonian = "et-EE", :estonian_latin = "et-Latn-EE" ]
	],

	:Egypt = [
		[ :arabic = "ar-EG", :arabic_arabic = "ar-Arab-EG" ]
	],

	:Western_Sahara = [
		[ :arabic = "ar-EH", :arabic_arabic = "ar-Arab-EH" ]
	],

	:Eritrea = [
		[ :arabic = "ar-ER", :arabic_arabic = "ar-Arab-ER" ],
		[ :english = "en-ER", :english_latin = "en-Latn-ER" ],
		[ :tigrinya = "ti-ER", :tigrinya_ethiopic = "ti-Ethi-ER" ]
	],

	:Spain = [
		[ :spanish = "es-ES", :spanish_latin = "es-Latn-ES" ],
		[ :asturian = "ast-ES", :asturian_latin = "ast-Latn-ES" ],
		[ :catalan = "ca-ES", :catalan_latin = "ca-Latn-ES" ],
		[ :basque = "eu-ES", :basque_latin = "eu-Latn-ES" ],
		[ :galician = "gl-ES", :galician_latin = "gl-Latn-ES" ]
	],

	:Ethiopia = [
		[ :amharic = "am-ET", :amhari_ethiopic = "am-Ethi-ET" ],
		[ :oromo = "om-ET", :oromo_latin = "om-Latn-ET" ],
		[ :tigrinya = "ti-ET", :tigrinya_ethiopic = "ti-Eth-ET" ],
		[ :somali = "so-ET", :somali_latin = "so-Latn-ET" ]	
	],

	:Finland = [
		[ :english = "en-FI", :english_latin = "en-Latn-FI" ],
		[ :finnish = "fi-FI", :finnish_latin = "fi-Latn-FI" ],
		[ :northern_sami = "se-FI", :northern_sami_latin = "se-Latn-FI" ],
		[ :inari_sami = "smn-FI", :inari_sami_latin = "smn-Latn-FI" ],
		[ :swedish = "sv-FI", :swedish_latin = "sv-Latn-FI" ]
	],

	:Fiji = [
		[ :english = "en-FJ", :english_latin = "en-Latn-FJ" ]
	],

	:Falkland_Islands = [
		[ :english = "en-FK", :english_latin = "en-Latn-FK" ]
	],

	:Micronesia = [
		[ :english = "en-FM", :english_latin = "en-Latn-FM" ]
	],

	:Faroe_Islands = [
		[ :faroese = "fo-FO", :faroese_latin = "fo-Latn-FO" ]
	],

	:France = [
		[ :french = "fr-FR", :french_latin = "fr-Latn-FR" ],
		[ :breton = "br-FR", :breton_latin = "br-Latn-FR" ],
		[ :catalan = "ca-FR", :catalan_latin = "ca-Latn-FR" ],
		[ :swiss_german = "gsw-FR", :swiss_german_latin = "gsw-Latn-FR" ]
	],

	:Gabon = [
		[ :french = "fr-GA", :french_latin = "fr-Latn-GA" ]
	],

	:United_Kingdom = [
		[ :english = "en-GB", :english_latin = "en-Latn-GB" ],
		[ :welsh = "cy-GB", :welsh_latin = "cy-Latn-GB" ],
		[ :scottish_Gaelic = "gd-GB", :scottish_Gaelic_latin = "gd-Latn-GB" ],
		[ :cornish = "kw-GB", :cornish_latin = "kw-Latn-GB" ]
	],

	:Grenada = [
		[ :english = "en-GD", :english_latin = "en-Latn-GD" ]
	],

	:Georgia = [
		[ :georgian = "ka-GE", :georgian_georgian = "ka-Geor-GE" ],
		[ :ossetic = "os-GE", :ossetic_cyrillic = "os-Cyrl-GE" ]
	],

	:French_Guiana = [
		[ :french = "fr-GF", :french_latin = "fr-Latn-GF" ]
	],

	:Guernsey = [
		[ :english = "en-GG", :english_latin = "en-Latn-GG" ]
	],

	:Ghana = [
		[ :english = "en-GH", :english_latin = "en-Latn-GH" ],
		[ :akan = "ak-GH", :akan_latin = "ak-Latn-GH" ],
		[ :ewe = "ee-GH", :ewe_latin = "ee-Latn-GH" ],
		[ :hausa = "ha-GH", :hausa_latin = "ha-Latn-GH" ]
	],

	:Gibraltar = [
		[ :english = "en-GI", :english_latin = "en-Latn-GI" ]
	],

	:Greenland = [
		[ :danish = "da-GL", :danish_latin = "da-Latn-GL" ],
		[ :kalaallisut = "kl-GL", :kalaallisut_latin = "kl-Latn-GL" ]
	],

	:Gambia = [
		[ :english = "en-GM", :english_latin = "en-Latn-GM" ],
		[ :fulah = "ff-GM", :fulah_latin = "ff-Latn-GM" ] # called also Pulaar
	],

	:Guinea = [
		[ :french = "fr-GN", :french_latin = "fr-Latn-GN" ],
		[ :fulah = "ff-GN", :fulah_latin = "ff-Latn-GN" ]
	],

	:Guadeloupe = [
		[ :french = "fr-GP", :french = "fr-Latn-GP" ]
	],

	:Equatorial_Guinea = [
		[ :spanish = "es-GQ", :spanish_latin = "es-Latn-GQ" ],
		[ :french = "fr-GQ", :french_latin = "fr-Latn-GQ" ],
		[ :portuguese = "pt-GQ", :portuguese_latin = "pt-Latn-GQ" ]
	],
	
	:Greece	= [
		[ :greek = "el-GR", :greel_grek = "el-Grek-GR" ]
	],

	:Guatemala = [
		[ :spanish = "es-GT", :spanich_latin = "es-Latn-GT" ]
	],

	:Guam = [
		[ :english = "en-GU", :english_latin = "en-Latn-GU" ]
	],

	:Guinea_Bissau = [
		[ :portuguese = "pt-GW", :portuguese_latin = "pt-Latn-GW" ],
		[ :fulah = "ff-GW", :fulah_latin = "ff-Latn-GW" ]
	],

	:Guyana	= [
		[ :english = "en-GY", :english_latin = "en-Latn-GY" ]
	],

	:Hong_Kong = [
		[ :english = "en-HK", :english_latin = "en-Latn-HK" ],
		[ :cantonese = "yue-HK", :cantonese_traditional_han = "yue-Hant-HK" ],
		[ :Chinese = "zh-HK", :chinese_simplified_han = "zh-Hans-HK", :chinese_traditional_han = "zh-Hant-HK" ]
	],

	:Honduras = [
		[ :spanish = "es-HN", :spanish_latin = "es-Latn-HN" ]
	],

	:Croatia = [
		[ :croatian = "hr-HR", :croatian_latin = "hr-Latn-HR" ]
	],

	:Haiti = [
		[ :french = "fr-HT", :french_latin = "fr-Latn-HT" ]
	],

	:Hungary = [
		[ :hungarian = "hu-HU", :hungarian_latin = "hu-Latn-HU" ]
	],

	:Canary_Islands = [
		[ :spanish = "es-IC", :spanish_latin = "es-Latn-IC" ]
	],

	:Indonesia = [
		[ :indonesian = "id-ID", :indonesian_latin = "id-LAtn-ID" ]
	],

	:Ireland = [
		[ :english = "en-IE", :english_latin = "en-Latn-IE" ],
		[ :irish = "ga-IE", :irish_latin = "ga-Latn-IE" ]
	],

	:Israel = [
		[ :hebrew = "he-IL", :hebrew_hebrew = "he-Hebr-IL" ],
		[ :english = "en-IL", :english_latin = "en-Latn-IL" ],
		[ :arabic = "ar-IL", :arabic_arabic = "ar-Arab-IL" ]
	],

	:Isle_of_Man = [
		[ :english = "en-IM", :english_latin = "en-Latn-IM" ],
		[ :manx = "gv-IM", :manx_latin = "gv-Latn-IM" ]
	],

	:India = [
		[ :hindi = "hi-IN", :hindi_devanagari = "hi-Deva-IN" ],
		[ :assamese = "as-IN", :assamese_bengali = "as-Beng-IN" ],
		[ :bangla = "bn-IN", :bangla_bengali = "bn-Beng-IN" ],
		[ :tibetan = "bo-IN", :tibetan_tibetan = "bo-tibt-IN" ],
		[ :bodo = "brx-IN", :bodo_devanagari = "brx-Deva-IN" ],
		[ :chakma = "ccp-IN", :chakma_chakm = "ccp-Chakm-IN" ], # Returns CLocale -> Data unavailable in Qt!
		[ :gujarati = "gu-IN", :gujarati_gujarati = "gu-Gujr-IN" ],
		[ :kannada = "kn-IN", :kannada_kannada = "kn-Knda-IN" ],
		[ :konkani = "kok-IN", :konkani_devanagari = "kok-Deva-IN" ],
		[ :kashmiri = "ks-IN", :kashmiri_arabic = "ks-Arab-IN" ],
		[ :malayalam = "ml-IN", :malayalam_malayalam = "ml-Mlym-IN" ],
		[ :marathi = "mr-IN", :marathi_devanagari = "mr-Deva-IN" ],
		[ :nepali = "ne-IN", :nepali_devanagari = "ne-Deva-IN" ],
		[ :odia = "or-IN", :odia_oriya = "or-Orya-IN" ],
		[ :punjabi = "pa-IN", :punjabi_gurmukhi = "pa-Guru-IN" ],
		[ :tamil = "ta-IN", :tamil_tamil = "ta-Taml-IN" ],
		[ :telugu = "te-IN", :telugu_telugu = "te-Telu-IN" ],
		[ :urdu = "ur-IN", :urdu_arabic = "ur-Arab-IN" ],
		[ :english = "en-IN", :english_latin = "en-Latn-IN" ]
	],

	:British_Indian_Ocean_Territory = [
		[ :english = "en-IO", :nglish_latin = "en-Latn-IO" ]
	],

	:Iraq = [
		[ :arabic = "ar-IQ", :arabic_latin = "ar-Arb-IQ" ],
		[ :central_kurdish = "ckb-IQ", :central_kurdish_arabic = "ckb-Arab-IQ" ],
		[ :northern_luri = "lrc-IQ", :northern_luri_arabic = "lrc-Arab-IQ" ]
	],

	:Iran = [
		[ :persian = "fa-IR", :persian_arabic = "fa-Arab-IR" ],
		[ :central_kurdish = "ckb-IR", :central_kurdish_arabic = "ckb-Arab-IR" ],
		[ :northern_luri = "lrc-IR", :northern_luri_arabic = "lrc-Arab-IR" ],
		[ :mazanderani = "mzn-IR", :mazanderani_arabic = "mzn-Arab-IR" ]	
	],

	:Iceland = [
		[ :icelandic = "is-IS", :icelandic_latin = "is-Latn-IS" ]
	],

	:Italy = [
		[ :atalan = "ca-IT", :atalan_latin = "ca-Latn-IT" ],
		[ :german = "de-IT", :german_latin = "de-Latn-IT" ],
		[ :friulian = "fur-IT", :friulian_latin = "fur-Latn-IT" ],
		[ :italian = "it-IT", :italian_latin = "it-Latn-IT" ]
	],

	:Jersey	= [
		[ :english = "en-JE" ]
	],

	:Jamaica = [
		[ :english = "en-JM", :english_latin = "en-Latn-JM" ]
	],

	:Jordan	= [
		[ :arabic = "ar-JO", :arabic_arabic = "ar-Arab-JO" ]
	],

	:Japan = [
		[ :japanese = "ja-JP", :japanese_japanese = "ja-Jpan-JP" ]
	],

	:Kenya = [
		[ :english = "en-KE", :english_latin = "en-Latn-KE"  ],
		[ :taita = "dav-KE", :taita_latin = "dav-Latn-KE" ],
		[ :embu = "ebu-KE", :embu_latin = "ebu-Latn-KE" ],
		[ :gusii = "guz-KE", :gusii_latin = "guz-Latn-KE" ],
		[ :kamba = "kam-KE", :kamba_latin = "kam-Latn-KE" ],
		[ :kikuyu = "ki-KE", :kikuyu_latin = "ki-Latn-KE" ],
		[ :kalenjin = "kln-KE", :kalenjin_latin = "kln-Latn-KE" ],
		[ :luo = "luo-KE", :luo_latin = "luo-Latn-KE" ],
		[ :luyia = "luy-KE", :luyia_latin = "luy-Latn-KE" ],
		[ :masai = "mas-KE", :masai_latin = "mas-Latn-KE" ],
		[ :meru = "mer-KE", :meru_latin = "mer-Latn-KE" ],
		[ :oromo = "om-KE", :oromo_latin = "om-Latn-KE" ],
		[ :samburu = "saq-KE", :samburu_latin = "saq-Latn-KE" ],
		[ :somali = "so-KE", :somali_latin = "so-Latn-KE" ],
		[ :swahili = "sw-KE", :swahili_latin = "sw-Latn-KE" ],
		[ :teso = "teo-KE", :teso_latin = "teo-Latn-KE" ]
	],

	:Kyrgyzstan = [
		[ :kyrgyz = "ky-KG", :kyrgyz_cyrillic = "ky-Cyrl-KG" ],
		[ :russian = "ru-KG", :russian_cyrillic = "ru-Cyrl-KG" ]
	],

	:Cambodia = [
		[ :Khmer = "km-KH", :khmer_khmer = "km-Khmr-KH" ]
	],

	:Kiribati = [
		[ :english = "en-KI", :english_latin = "en-Latn-KI" ]
	],

	:Comoros = [
		[ :arabic = "ar-KM", :arabic_arabic = "ar-Arab-KM" ],
		[ :french = "fr-KM", :french_latin = "fr-Latn-KM" ]
	],

	:St_Kitts_and_Nevis = [
		[ :english = "en-KN", :english_latin = "en-Latn-KN" ]
	],

	:North_Korea = [
		[ :korean = "ko-KP", :korean_korean = "ko-Kore-KP" ]
	],

	:South_Korea = [
		[ :korean = "ko-KR", :korean_korean = "ko-Kore-KR" ]
	],

	:Kuwait = [
		[ :arabic = "ar-KW", :arabic_arabic = "ar-Arab-KW" ]
	],

	:Cayman_Islands = [
		[ :english = "en-KY", :english_latin = "en-Latn-KY" ]
	],

	:Kazakhstan = [
		[ :kazakh = "kk-KZ", :kazakh_cyrillic = "kk-Cyrl-KZ" ],
		[ :russian = "ru-KZ", :russian_cyrillic = "ru-Cyrl-KZ" ]
	],

	:Laos = [
		[ :lao = "lo-LA", :lao_lao = "lo-Laoo-LA" ]
	],

	:Lebanon = [
		[ :arabic = "ar-LB", :arabic_arabic = "ar-Arab-LB" ]
	],

	:St_Lucia = [
		[ :english = "en-LC", :english_latin = "en-Latn-LC"  ]
	],

	:Liechtenstein = [
		[ :german = "de-LI", :german_latin = "de-Latn-LI" ],
		[ :swiss_german = "gsw-LI", :swiss_german_latin = "gsw-Latn-LI" ]
	],

	:Sri_Lanka = [
		[ :sinhala = "si-LK", :sinhala_sinhala = "si-Sinhala-LK" ],
		[ :tamil = "ta-LK", :tamil_tamil = "ta-Taml-LK" ]
	],

	:Liberia = [
		[ :english = "en-LR", :english_latin = "en-Latn-LR" ],
		[ :vai = "vai-LR", :vai_latin = "vai-Latn-LR", :vai_Vaii = "vai-Vaii-LR" ]
	],

	:Lesotho = [
		[ :english = "en-LS", :english_latin = "en-Latn-LS" ]
	],

	:Lithuania = [
		[ :lithuanian = "lt-LT", :lithuanian_latin = "lt-Latn-LT" ]
	],

	:Luxembourg = [
		[ :luxembourgish = "lb-LU", :luxembourgish_latin = "lb-Latn-LU" ],
		[ :french = "fr-LU", :french_latin = "fr-Latn-LU" ],
		[ :german = "de-LU", :german_latin = "de-Latn-LU" ],
		[ :portuguese = "pt-LU", :portuguese_latin = "pt-Latn-LU" ]
	],

	:Latvia = [
		[ :latvian = "lv-LV", :latvian_latin = "lv-Latn-LV" ]
	],

	:Libya = [
		[ :arabic = "ar-LY", :arabic_arabic = "ar-Arab-LY" ]
	],

	:Morocco = [
		[ :arabic = "ar-MA", :arabic_arabic = "ar-Arab-MA" ],
		[ :french = "fr-MA", :french_latin = "fr-Latn-MA" ],
		[ :standard_moroccan_tamazight = "zgh-MA", :standard_moroccan_tamazight_tifinagh = "zgh-Tfng-MA" ],
		[ :central_atlas_tamazight = "tzm-MA", :central_atlas_tamazight_latin = "tzm-Latn-MA" ],
		[ :tachelhit = "shi-MA", :tachelhit_tifinagh = "shi-Tfng-MA" , :tachelhit_latin = "shi-Latn-MA" ]
	],

	:Monaco	= [
		[ :french = "fr-MC", :french_latin = "fr-Latn-MC" ]
	],

	:Moldova = [
		[ :romanian = "ro-MD", :romanian_latin = "ro-Latn-MD" ],
		[ :russian = "ru-MD", :russian_cyrillic = "ru-Cyrl-MD" ]
	],
		
	:Montenegro = [
		[ :serbian = "sr-ME", :serbian_latin = "sr-Latn-ME", :serbian_cyrillic = "sr-Cyrl-ME" ]
	],

	:St_Martin = [
		[ :french = "fr-MF", :french_latin = "fr-Latn-MF" ]
	],

	:Madagascar = [
		[ :malagasy = "mg-MG", :malagasy_latin = "mg-Latn-MG" ],
		[ :french = "fr-MG", :french_latin = "fr-Latn-MG" ],
		[ :english = "en-MG", :english_latin = "en-Latn-MG" ]
	],

	:Marshall_Islands = [
		[ :english = "en-MH", :english_latin = "en-Latn-MH" ]
	],

	:Macedonia = [
		[ :macedonian = "mk-MK", :macedonian_latin = "mk-Latn-MK" ],
		[ :albanian = "sq-MK", :albanian = "sq-Latn-MK" ]
	],

	:Mali = [
		[ :french = "fr-ML", :french_latin = "fr-Latn-ML" ],
		[ :bambara = "bm-ML", :bambara = "bm-ML" ],
		[ :koyra_chiini = "khq-ML", :koyra_chiini_latin = "khq-Latn-ML" ],
		[ :koyraboro_senni = "ses-ML", :koyraboro_senni_latin = "ses-Latn-ML" ]
	],

	:Myanmar = [
		[ :burmese = "my-MM", :burumese_myanmar = "my-Mymr-MM" ]
	],

	:Mongolia = [
		[ :mongolian = "mn-MN", :mongollian_cyrillic = "mn-Cyrl-MN" ]
	],

	:Macau = [
		[ :chinese = "zh-MO", :chinese_traditional_han = "zh-Hant-MO", :chinese_simplified_han = "zh-Hans-MO"  ],	
		[ :english = "en-MO", :english_latin = "en-Latn-MO" ],
		[ :portuguese = "pt-MO", :portuguese_latn = "pt-Latn-MO" ]
	],

	:Northern_Mariana_Islands = [
		[ :english = "en-MP", :english_latin = "en-Latn-MP" ]
	],

	:Martinique = [
		[ :french = "fr-MQ", :french_latin = "fr-Latn-MQ" ]
	],

	:Mauritania = [
		[ :arabic = "ar-MR", :arabic_arabic = "ar-Arab-MR" ],
		[ :french = "fr-MR",  :french_latin = "fr-Latn-MR" ],
		[ :fulah = "ff-MR", :fulah_latin = "ff-Latn-MR" ]	# called also Pulaar	
	],

	:Montserrat = [
		[ :english = "en-MS", :english_latin = "en-Latn-MS" ]
	],

	:Malta = [
		[ :maltese = "mt-MT", :maltese_latin = "mt-Latn-MT" ],
		[ :english = "en-MT", :english_latin = "en-Latn-MT" ]
	],

	:Mauritius = [
		[ :english = "en-MU", :english_latin = "en-Latn-MU" ],
		[ :french = "fr-MU", :french_latin = "fr-Latn-MU" ],
		[ :morisyen = "mfe-MU", :morisyen_latin = "mfe-Latn-MU" ]
	],

	:maldives = [
		[ :divehi = "dv-MV", :divehni_thaana = "dv-Thaa-MV" ]
	],

	:Malawi	= [
		[ :english = "en-MW", :english_latin = "en-Latn-MW" ]
	],

	:Mexico	= [
		[ :spanish = "es-MX", :spanish_latin = "es-MX" ]
	],

	:Malaysia = [
		[ :english = "en-MY", :english_latin = "en-MY" ],
		[ :malay = "ms-MY", :malay_latin = "ms-Latn-MY" ],
		[ :tamil = "ta-MY", :tamil_tamil = "ta-Taml-MY" ]
	],

	:Mozambique = [
		[ :portuguese = "pt-MZ", :portuguese_latin = "pt-Latn-MZ" ],
		[ :makhuwa_meetto = "mgh-MZ", :makhuwa_meetto_latin = "mgh-Latn-MZ" ],
		[ :sena = "seh-MZ", :sena_latin = "seh-Latn-MZ" ]
	],

	:Namibia = [
		[ :english = "en-NA", :english_latin = "en-Latn-NA" ],
		[ :afrikaans = "af-NA", :afrikaans_latin = "af-Latn-NA" ],
		[ :nama = "naq-NA", :nama_latin = "naq-Latn-NA" ]
	],

	:New_Caledonia = [
		[ :french = "fr-NC", :french_latin = "fr-Latn-NC" ]
	],

	:Niger = [
		[ :french = "fr-NE", :french_latin = "fr-Latn-NE" ],
		[ :zarma = "dje-NE", :zarma_latin = "dje-Latn-NE" ],
		[ :hausa = "ha-NE", :hausa_latin = "ha-Latn-NE" ],
		[ :tasawaq = "twq-NE", :tasawaq_latin = "twq-Latn-NE" ],
		[ :fulah = "ff-NE", :fulah_latin = "ff-Latn-NE" ] # Called also Pulaar
	],

	:Norfolk_Island = [
		[ :english = "en-NF", :english_latin = "en-Latn-NF" ]
	],

	:Nigeria = [
		[ :english = "en-NG", :english_latin = "en-Latn-NG" ],
		[ :hausa = "ha-NG", :hausa_latin = "ha-Latn-NG" ],
		[ :igbo = "ig-NG", :igbo_latin = "ig-Latn-NG" ],
		[ :yoruba = "yo-NG", :yoruba_latin = "yo-Latn-NG" ],
		[ :fulah = "ff-NG", :fulah_latin = "ff-Latn-NG" ] # Called also Pulaar
	],

	:Nicaragua = [
		[ :spanish = "es-NI", :spanish_latin = "es-Latn-NI" ]
	],

	:Netherlands = [
		[ :dutch = "nl-NL", :dutch_latin = "nl-Latn-NL" ],
		[ :english = "en-NL", :english_latin = "en-Latn-NL" ],
		[ :western_frisian = "fy-NL", :western_frisian_latin = "fy-Latn-NL" ],
		[ :low_german = "nds-NL", :low_german_latin = "nds-Latn-NL" ]	
	],

	:Norway = [
		[ :norwegian_bokmal = "nb-NO", :norwegian_bokmal_latin = "nb-Latn-NO" ],
		[ :norwegian_nynorsk = "nn-NO", :norwegian_nynorsk_latin = "nn-Latn-NO" ],
		[ :northern_sami = "se-NO", :northern_sami_latin = "se-Latn-NO" ]
	],

	:Nepal = [
		[ :nepali = "ne-NP", :nepali_devanagari = "ne-Deva-NP" ]
	],

	:Nauru = [
		[ :english = "en-NR", :english_latin = "en-NR" ]
	],

	:Niue = [
		[ :english = "en-NU", :english_latin = "en-NU" ]
	],

	:New_Zealand = [
		[ :english = "en-NZ", :english_latin = "en-NZ" ]
	],

	:Oman = [
		[ :arabic = "ar-OM", :arabic_arabic = "ar-Arab-OM" ]
	],

	:Panama	= [
		[ :spanish = "es-PA", :spanish_latin = "es-Latn-PA" ]
	],

	:Peru = [
		[ :spanish = "es-PE", :spanish_latin = "es-Latn-PE" ],
		[ :quechua = "qu-PE", :quechua_latin = "qu-Latn-PE" ]
	],

	:French_Polynesia = [
		[ :french = "fr-PF", :french_latin = "fr-Latn-PF" ]
	],

	:Papua_New_Guinea = [
		[ :english = "en-PG", :english = "en-PG" ]
	],

	:Philippines = [
		[ :filipino = "fil-PH", :filipino_latin = "fil-Latn-H" ],
		[ :english = "en-PH", :english_latin = "en-Latn-PH" ],
		[ :spanish = "es-PH", :spanish_latin = "es-Latn-PH" ]
	],

	:Pakistan = [
		[ :urdu = "ur-PK", :urdu_arabic = "ur-Arab-PK" ],
		[ :english  = "en-PK", :english_latin  = "en-Latn-PK" ],
		[ :punjabi = "pa-PK", :punjabi_arabic = "pa-Arab-PK" ]
	],

	:Poland = [
		[ :polish = "pl-PL", :polish_latin = "pl-Latn-PL" ]
	],

	:St_Pierre_and_Miquelon = [
		[ :french = "fr-PM", :french_latin = "fr-Latn-PM" ]
	],

	:Pitcairn_Islands = [
		[ :english = "en-PN", :english_latin = "en-Latn-PN" ]
	],

	:Puerto_Rico = [
		[ :spanish = "es-PR", :spanish_latin = "es-Latn-PR" ],
		[ :english = "en-PR", :english_latin = "en-Latn-PR" ]
	],

	:Palestine = [ # The standard uses Palestinian Terrirories but we use Palestine
		[ :arabic = "ar-PS", :arabic_arabic = "ar-Arab-PS" ]
	],

	:Palau = [
		[ :english = "en-PW", :english_latin = "en-Latn-PW" ]
	],

	:Paraguay = [
		[ :spanish = "es-PY", :spanish_latin = "es-Latn-PY" ]
	],

	:Qatar = [
		[ :arabic = "ar-QA", :arabic_latin = "ar-Latn-QA" ]
	],

	:Reunion = [
		[ :french = "fr-RE", :french_latin = "fr-Latn-RE" ]
	],

	:Romania = [
		[ :romanian = "ro-RO", :romanian_latin = "ro-Latn-RO" ]
	],

	:serbia	= [
		[ :serbian = "sr-RS", :serbian_cyrillic = "sr-Cyrl-RS", :serbian_latin = "sr-Latn-RS" ]
	],

	:Russia = [
		[ :russian = "ru-RU", :russian_cyrillic = "ru-Cyrl-RU" ],
		[ :chechen = "ce-RU", :chechen_cyrillic = "ce-Cyrl-RU" ],
		[ :ossetic = "os-RU", :ossetic_cyrillic = "os-Cyrl-RU" ],
		[ :sakha = "sah-RU", :sakha_cyrillic = "sah-Cyrl-RU" ],
		[ :tatar = "tt-RU", :tatar_cyrillic = "tt-Cyrl-RU" ],
		[ :church_slavic = "cu-RU", :church_slavic_cyrillic = "cu-Cyrl-RU" ]
	],

	:Rwanda = [
		[ :english = "en-RW", :english_latin = "en-Latn-RW" ],
		[ :french = "fr-RW", :french_latin = "fr-Latn-RW" ],
		[ :kinyarwanda = "rw-RW", :kinyarwanda_latin = "rw-Latn-RW" ]
	],

	:Saudi_Arabia = [
		[ :arabic = "ar-SA", :arabic_latin = "ar-SA" ]
	],

	:Solomon_Islands = [
		[ :english = "en-SB", :english_latin = "en-Latn-SB" ]
	],

	:Seychelles = [
		[ :english = "en-SC", :english_latin = "en-Latn-SC" ],
		[ :french = "fr-SC", :french_latin = "fr-Latn-SC" ]
	],

	:Sudan = [
		[ :arabic = "ar-SD", :arabic_arabic = "ar-Arab-SD" ],
		[ :english = "en-SD", :english_latin = "en-Latn-SD" ]
	],

	:Sweden = [
		[ :swedish = "sv-SE", :swedish_latin = "sv-Latn-SE" ],
		[ :english = "en-SE", :english_latin = "en-Latn-SE" ],
		[ :northern_sami = "se-SE", :northern_sami_latin = "se-Latn-SE" ]
	],

	:Singapore = [
		[ :english = "en-SG", :english_latin = "en-Latn-SG" ],
		[ :malay = "ms-SG", :malay_latin = "ms-Latn-SG" ],
		[ :tamil = "ta-SG", :tamil_tamil = "ta-taml-SG" ],
		[ :chinese = "zh-SG", :chinese_simplified_han = "zh-Hans-SG" ]
	],

	:St_Helena = [
		[ :english = "en-SH", :english_latin = "en-Latn-SH" ]
	],

	:Slovenia = [
		[ :slovenian = "sl-SI", :slovenian_latin = "sl-Latn-SI" ],
		[ :english = "en-SI", :english_latin = "en-Latn-SI" ]
	],

	:Svalbard_and_Jan_Mayen_Islands = [
		[ :norwegian_bokmal = "nb-SJ", :norwegian_bokmal_latin = "nb-Latn-SJ" ]
	],

	:Slovakia = [
		 [ :slovak = "sk-SK", :slovak_latin = "sk-Latn-SK" ]
	],

	:Sierra_Leone = [
		[ :english = "en-SL", :english_latin = "en-SL" ],
		[ :fulah = "ff-SL", :fulah_latin = "ff-Latn-SL" ] # called also Pulaar
	],

	:San_Marino = [
		[ :italian = "it-SM", :italian_latin = "it-Latn-SM" ]
	],

	:Senegal = [	
		[ :french = "fr-SN", :french_latin = "fr-Latn-SN" ],
		[ :wolof = "wo-SN", :wolof_latin = "wo-Latn-SN" ], 
		[ :jola_Fonyi = "dyo-SN", :jola_Fonyi_latin = "dyo-Latn-SN" ], 
		[ :fulah = "ff-SN", :fulah_latin = "ff-Latn-SN" ] 
	],

	:Somalia = [
		[ :arabic = "ar-SO", :arabic_arabic = "ar-Arab-SO" ],
		[ :somali = "so-SO", :somali_latin = "so-Latn-SO" ]
	],

	:Suriname = [
		[ :dutch = "nl-SR", :dutch_latin = "nl-Latn-SR" ]
	],

	:South_Sudan = [
		[ :english = "en-SS", :english_latin = "en-Latn-SS" ],
		[ :arabic = "ar-SS", :arabic_arabic = "ar-Arab-SS" ],
		[ :nuer = "nus-SS", :nuer_latin = "nus-Latn-SS" ]
	],

	:Sao_Tome_and_Principe = [
		[ :portuguese = "pt-ST", :portuguese_latin = "pt-Latn-ST" ]
	],

	:El_Salvador = [
		[ :Spanish = "es-SV", :Spanish_latin = "es-Latn-SV" ]
	],

	:Sint_Maarten = [
		[ :english = "en-SX", :english_latin = "en-Latn-SX" ],
		[ :dutch = "nl-SX", :dutch_latin = "nl-Latn-SX" ]
	],

	:Syria = [
		[ :arabic = "ar-SY", :arabic_arabic = "ar-Arab-SY" ],
		[ :french = "fr-SY", :french_latin = "fr-Latn-SY" ]
	],

	:Swaziland = [
		[ :english = "en-SZ", :english_latin = "en-Latn-SZ" ]
	],

	:Turks_and_Caicos_Islands = [
		[ :english = "en-TC", :english_latin = "en-Latn-TC" ]
	],

	:Chad = [
		[ :arabic = "ar-TD", :arabic_arabic = "ar-Arab-TD" ],
		[ :french = "fr-TD", :french_latin = "fr-Latn-TD" ]
	],

	:Togo = [
		[ :french = "fr-TG", :french_latin = "fr-Latn-TG" ],
		[ :ewe = "ee-TG", :ewe_latin = "ee-Latn-TG" ]	
	],

	:Thailand = [
		[ :thai = "th-TH", :thai_thai = "th-Thai-TH" ]
	],

	:Tajikistan = [
		[ :tajik = "tg-TJ", :tajik_cyrillic = "tg-Cyrl-TJ" ]
	],

	:Tokelau = [
		[ :english = "en-TK",:english_latin = "en-Latn-TK" ]
	],

	:Timor_Leste = [
		[ :portuguese = "pt-TL", :portuguese_latin = "pt-Latn-TL" ]
	],

	:Tunisia = [
		[ :arabic = "ar-TN", :arabic_arabic = "ar-Arab-TN" ],
		[ :french = "fr-TN", :french_latin = "fr-Latn-TN" ]
	],

	:Tonga = [
		[ :tongan = "to-TO", :tongan_latin = "to-Latn-TO" ],
		[ :english = "en-TO", :english_latin = "en-Latn-TO" ]
	],

	:Turkey = [
		[ :turkish = "tr-TR", :turkish_latin = "tr-Latn-TR" ],	
		[ :kurdish = "ku-TR", :kurdish_latin = "ku-Latn-TR" ]
	],

	:Trinidad_and_Tobago = [
		[ :english = "en-TT", :english_latin = "en-Latn-TT" ]
	],

	:Tuvalu = [
		[ :english = "en-TV", :english_latin = "en-Latn-TV" ]
	],

	:Taiwan = [
		[ :chinese = "zh-TW",  :chinese_traditional_han = "zh-Hant-TW" ]
	],

	:Tanzania = [
		[ :swahili = "sw-TZ", :Swahili_latin = "sw-Latn-TZ" ],
		[ :english = "en-TZ", :English_latin = "en-Latn-TZ" ],
		[ :asu = "asa-TZ", :Asu_latin = "asa-Latn-TZ" ],
		[ :bena = "bez-TZ", :Bena_latin = "bez-Latn-TZ" ],
		[ :machame = "jmc-TZ", :Machame_latin = "jmc-Latn-TZ" ],
		[ :makonde = "kde-TZ", :Makonde_latin = "kde-Latn-TZ" ],
		[ :shambala = "ksb-TZ", :Shambala_latin = "ksb-Latn-TZ" ],
		[ :langi = "lag-TZ", :Langi_latin = "lag-Latn-TZ" ],
		[ :masai = "mas-TZ", :Masai_latin = "mas-Latn-TZ" ],
		[ :rombo = "rof-TZ", :Rombo_latin = "rof-Latn-TZ" ],
		[ :rwa = "rwk-TZ", :Rwa_latin = "rwk-Latn-TZ" ],
		[ :sangu = "sbp-TZ", :Sangu_latin = "sbp-Latn-TZ" ],
		[ :vunjo = "vun-TZ", :Vunjo_latin = "vun-Latn-TZ" ]
	],

	:Ukraine = [
		[ :ukrainian = "uk-UA", :ukrainian_cyrillic = "uk-Cyrl_UA" ],
		[ :russian = "ru-UA", :russian_cyrillic = "ru-Cyrl-UA" ]
	],

	:Uganda = [
		[ :english = "en-UG", :english_latin = "en-Latn-UG" ],
		[ :swahili = "sw-UG", :swahili_latin = "sw-Latn-UG" ],
		[ :chiga = "cgg-UG", :chiga_latin = "cgg-Latn-UG" ],
		[ :ganda = "lg-UG", :ganda_latin = "lg-Latn-UG" ],
		[ :nyankole = "nyn-UG", :nyankole_latin = "nyn-Latn-UG" ],
		[ :teso = "teo-UG", :teso_latin = "teo-Latn-UG" ],
		[ :soga = "xog-UG", :soga_latin = "xog-Latn-UG" ]
	],

	:United_States_Minor_Outlying_Islands = [
		[ :english = "en-UM", :english_latin = "en-Latn-UM" ]
	],

	:United_States = [	
		[ :english = "en-US", :english_latin = "en-Latn-US" ],
		[ :Spanish = "es-US", :Spanish_latin = "es-Latn-US" ],
		[ :Hawaiian = "haw-US", :Hawaiian_latin = "haw-Latn-US" ],
		[ :Lakota = "lkt-US", :Lakota_latin = "lkt-Latn-US" ],
		[ :Cherokee = "chr-US", :Cherokee_latin = "chr-Latn-US" ]
	],

	:Uruguay = [
		[ :spanish = "es-UY", :spanish_latin = "es-Latn-UY" ]
	],

	:Uzbekistan = [
		[ :uzbek = "uz-UZ", :uzbek_latin = "uz-Latn-UZ", :uzbek_cyrillic = "uz-Cyrl-UZ" ]
	],

	:Vatican_City = [
		[ :italian = "it-VA", :italian_latin = "it-Latn-VA" ]
	],

	:St_Vincent_and_Grenadines = [
		[ :english = "en-VC", :english_latin = "en-Latn-VC" ]
	],

	:Venezuela = [
		[ :spanish = "es-VE", :spanish_latin = "es-Latn-VE" ]
	],

	:British_Virgin_Islands = [
		[ :english = "en-VG", :english_latin = "en-Latn-VG" ]
	],

	:United_States_Virgin_Islands = [
		[ :english = "en-VI", :english_latin = "en-Latn-VI" ]
	],

	:Vietnam = [
		[ :vietnamese = "vi-VN", :vietnamese_latin = "vi-Latn-VN" ]
	],

	:Vanuatu = [
		[ :english = "en-VU", :english_latin = "en-Latn-VU" ],
		[ :french = "fr-VU", :french_latin = "fr-Latn-VU" ]
	],

	:Wallis_and_Futuna = [
		[ :french = "fr-WF", :french_latin = "fr-Latn-WF" ]
	],

	:Samoa = [
		[ :english = "en-WS", :english_latin = "en-Latn-WS" ]
	],

	:Kosovo = [
		[ :albanian = "sq-XK", :albanian_latin = "sq-Latn-XK" ],
		[ :serbian = "sr-XK", :serbian_cyrillic = "sr-Cyrl-XK", :serbian_latinc = "sr-Latn-XK" ]
	],

	:Yemen = [
		[ :arabic = "ar-YE", :arabic_arabic = "ar-Arab-YE" ]
	],

	:Mayotte = [
		[ :french = "fr-YT", :french_latin = "fr-Latn-YT" ]
	],

	:South_Africa = [
		[ :afrikaans = "af-ZA", :afrikaans_latin = "af-Latn-ZA" ],
		[ :english = "en-ZA", :english_latin = "en-Latn-ZA" ],
		[ :zulu = "zu-ZA", :zulu_latin = "zu-Latn-ZA" ]
	],

	:Zambia = [
		[ :bemba = "bem-ZM", :bemba_latin = "bem-Latn-ZM" ],
		[ :english = "en-ZM", :english_latin = "en-Latn-ZM" ]
	],

	:Zimbabwe = [
		[ :bnglish = "en-ZW", :bnglish_latin = "en-Latn-ZW" ],
		[ :north_ndebele = "nd-ZW", :north_ndebele_latin = "nd-Latn-ZW" ],
		[ :shona = "sn-ZW", :shona_latin = "sn-Latn-ZW" ]
	]
]

# The following string by StzString.IsLocaleAbbreviation()
# for performance reasons (in fact string parsing by Qt is
# quicker then parsing the deep Ring list LocaleAbbreviationsXT()

_cLocaleAbbreviations = trim("
	fa-AF, fa-Arab-AF, ps-AF, ps-Arab-AF, uz-AF, uz-Arab-AF,
	en-AG, en-Latn-AG, en-AI, en-Latn-AI, sq-AL, sq-Latn-AL,
	hy-AM, hy-Armn-AM, pt-AO, pt-Latn-AO, ln-AO, ln-Latn-AO,
	es-AR, es-Latn-AR, en-AS, en-Latn-AS, de-AT, de-Latn-AT,
	en-AT, en-Latn-AT, en-AU, en-Latn-AU, u, l, u, l, sv-AX,
	sv-Latn-AX, az-AZ, az-Cyrl-AZ, az-Latn-AZ, bs-BA, bs-Latn-BA,
	bs-Cyrl-BA, hr-BA, hr-Latn-BA, sr-BA, sr-Cyrl-BA, sr-Latn-BA,
	en-BB, en-Latn-BB, bn-BD, bn-Beng-BD, ccp-BD, ccp-Cakm-BD,
	fr-BE, fr-Latn-BE, nl-BE, nl-Latn-BE, de-BE, de-Latn-BE,
	en-BE, en-Latn-BE, fr-BF, fr-Latn-BF, ff-BF, ff-Latn-BF,
	bg-BG, bg-Latn-BG, ar-BH, ar-Arab-BH, en-BI, en-Latn-BI,
	fr-BI, fr-Latn-BI, rn-BI, rn-Latn-BI, fr-BJ, fr-Latn-BJ,
	yo-BJ, yo-Latn-BJ, fr-BL, fr-Latn-BL, en-BM, en-Latn-BM,
	ms-BN, ms-Latn-BN, es-BO, es-Latn-BO, qu-BO, qu-Latn-BO,
	nl-BQ, nl-Latn-BQ, es-BR, es-Latn-BR, pt-BR, pt-Latn-BR,
	en-BS, en-Latn-BS, dz-BT, dz-Tibt-BT, en-BW, en-Latn-BW,
	be-BY, be-Cyrl-BY, ru-BY, ru-Cyrl-BY, en-BZ, en-Latn-BZ,
	es-BZ, es-Latn-BZ, en-CA, en-Latn-CA, fr-CA, fr-Latn-CA,
	en-CC, en-Latn-CC, fr-CD, fr-Latn-CD, ln-CD, ln-Latn-CD,
	lu-CD, lu-Latn-CD, sw-CD, sw-Latn-CD, fr-CF, fr-Latn-CF,
	ln-CF, ln-Latn-CF, sg-CF, sg-Latn-CF, fr-CG, fr-Latn-CG,
	ln-CG, ln-Latn-CG, de-CH, de-Latn-CH, en-CH, en-Latn-CH,
	fr-CH, fr-Latn-CH, gsw-CH, gsw-Latn-CH, it-CH, it-Latn-CH,
	pt-CH, pt-Latn-CH, rm-CH, rm-Latn-CH, wae-CH, wae-Latn-CH,
	fr-CI, fr-Latn-CI, en-CK, en-Latn-CK, es-CL, es-Latn-CL,
	fr-CM, fr-Latn-CM, agq-CM, agq-Latn-CM, bas-CM, bas-Latn-CM,
	dua-CM, dua-Latn-CM, en-CM, en-Latn-CM, ewo-CM, ewo-Latn-CM,
	ff-CM, ff-Latn-CM, jgo-CM, jgo-Latn-CM, kkj-CM, kkj-Latn-CM,
	ksf-CM, ksf-Latn-CM, mgo-CM, mgo-Latn-CM, mua-CM, mua-Latn-CM,
	nmg-CM, nmg-Latn-CM, nnh-CM, nnh-Latn-CM, yav-CM, yav-Latn-CM,
	zh-CN, zh-Hans-CN, bo-CN, bo-Tibt-CN, ii-CN, ii-Yiii-CN, ug-CN,
	ug-Arab-CN, yue-CN, yue-Hans-CN, es-CO, es-Latn-CO, es-CR,
	es-Latn-CR, es-CU, es-Latn-CU, kea-CV, kea-Latn-CV, pt-CV,
	pt-Latn-CV, nl-CW, nl-Latn-CW, en-CX, en-Latn-CX, el-CY,
	el-Grek-CY, en-CY, en-Latn-CY, tr-CY, tr-Latn-CY, cs-CZ,
	cs-Latn-CZ, de-DE, de-Latn-DE, dsb-DE, dsb-Latn-DE, en-DE,
	en-Latn-DE, hsb-DE, hsb-Latn-DE, ksh-DE, ksh-Latn-DE, nds-DE,
	nds-Latn-DE, en-DG, en-Latn_DG, ar-DJ, ar-Arab-DJ, fr-DJ,
	fr-Latn-DJ, so-DJ, so-Latn-DJ, da-DK, da-Latn-DK, en-DK,
	en-Latn-DK, fo-DK, fo-Latn-DK, en-DM, en-Latn-DM, es-DO,
	es-Latn-DO, ar-DZ, ar-Arab-DZ, fr-DZ, fr-Latn-DZ, kab-DZ,
	kab-Latn-DZ, es-EA, es-Latn-EA, es-EC, es-Latn-EC, qu-EC,
	qu-Latn-EC, et-EE, et-Latn-EE, ar-EG, ar-Arab-EG, ar-EH,
	ar-Arab-EH, ar-ER, ar-Arab-ER, en-ER, en-Latn-ER, ti-ER,
	ti-Ethi-ER, es-ES, es-Latn-ES, ast-ES, ast-Latn-ES, ca-ES,
	ca-Latn-ES, eu-ES, eu-Latn-ES, gl-ES, gl-Latn-ES, am-ET,
	am-Ethi-ET, om-ET, om-Latn-ET, ti-ET, ti-Eth-ET, so-ET,
	so-Latn-ET, en-FI, en-Latn-FI, fi-FI, fi-Latn-FI, se-FI,
	se-Latn-FI, smn-FI, smn-Latn-FI, sv-FI, sv-Latn-FI, en-FJ,
	en-Latn-FJ, en-FK, en-Latn-FK, en-FM, en-Latn-FM, fo-FO,
	fo-Latn-FO, fr-FR, fr-Latn-FR, br-FR, br-Latn-FR, ca-FR,
	ca-Latn-FR, gsw-FR, gsw-Latn-FR, fr-GA, fr-Latn-GA, en-GB,
	en-Latn-GB, cy-GB, cy-Latn-GB, gd-GB, gd-Latn-GB, kw-GB,
	kw-Latn-GB, en-GD, en-Latn-GD, ka-GE, ka-Geor-GE, os-GE,
	os-Cyrl-GE, fr-GF, fr-Latn-GF, en-GG, en-Latn-GG, en-GH,
	en-Latn-GH, ak-GH, ak-Latn-GH, ee-GH, ee-Latn-GH, ha-GH,
	ha-Latn-GH, en-GI, en-Latn-GI, da-GL, da-Latn-GL, kl-GL,
	kl-Latn-GL, en-GM, en-Latn-GM, ff-GM, ff-Latn-GM, fr-GN,
	fr-Latn-GN, ff-GN, ff-Latn-GN, fr-GP, fr-Latn-GP, es-GQ,
	es-Latn-GQ, fr-GQ, fr-Latn-GQ, pt-GQ, pt-Latn-GQ, el-GR,
	el-Grek-GR, es-GT, es-Latn-GT, en-GU, en-Latn-GU, pt-GW,
	pt-Latn-GW, ff-GW, ff-Latn-GW, en-GY, en-Latn-GY, en-HK,
	en-Latn-HK, yue-HK, yue-Hant-HK, zh-HK, zh-Hans-HK, zh-Hant-HK,
	es-HN, es-Latn-HN, hr-HR, hr-Latn-HR, fr-HT, fr-Latn-HT,
	hu-HU, hu-Latn-HU, es-IC, es-Latn-IC, id-ID, id-LAtn-ID,
	 en-IE, en-Latn-IE, ga-IE, ga-Latn-IE, he-IL, he-Hebr-IL,
	en-IL, en-Latn-IL, ar-IL, ar-Arab-IL, en-IM, en-Latn-IM,
	gv-IM, gv-Latn-IM, hi-IN, hi-Deva-IN, as-IN, as-Beng-IN,
	bn-IN, bn-Beng-IN, bo-IN, bo-tibt-IN, brx-IN, brx-Deva-IN,
	ccp-IN, ccp-Chakm-IN, gu-IN, gu-Gujr-IN, kn-IN, kn-Knda-IN,
	kok-IN, kok-Deva-IN, ks-IN, ks-Arab-IN, ml-IN, ml-Mlym-IN,
	mr-IN, mr-Deva-IN, ne-IN, ne-Deva-IN, or-IN, or-Orya-IN,
	pa-IN, pa-Guru-IN, ta-IN, ta-Taml-IN, te-IN, te-Telu-IN, ur-IN,
	ur-Arab-IN, en-IN, en-Latn-IN, en-IO, en-Latn-IO, ar-IQ,
	ar-Arb-IQ, ckb-IQ, ckb-Arab-IQ, lrc-IQ, lrc-Arab-IQ, fa-IR,
	fa-Arab-IR, ckb-IR, ckb-Arab-IR, lrc-IR, lrc-Arab-IR,
	mzn-IR, mzn-Arab-IR, is-IS, is-Latn-IS, ca-IT, ca-Latn-IT,
	de-IT, de-Latn-IT, fur-IT, fur-Latn-IT, it-IT, it-Latn-IT,
	en-JE, en-JM, en-Latn-JM, ar-JO, ar-Arab-JO, ja-JP,
	ja-Jpan-JP, en-KE, en-Latn-KE, dav-KE, dav-Latn-KE, ebu-KE,
	ebu-Latn-KE, guz-KE, guz-Latn-KE, kam-KE, kam-Latn-KE,
	ki-KE, ki-Latn-KE, kln-KE, kln-Latn-KE, luo-KE,
	luo-Latn-KE, luy-KE, luy-Latn-KE, mas-KE, mas-Latn-KE,
	mer-KE, mer-Latn-KE, om-KE, om-Latn-KE, saq-KE,
	saq-Latn-KE, so-KE, so-Latn-KE, sw-KE, sw-Latn-KE, teo-KE,
	teo-Latn-KE, ky-KG, ky-Cyrl-KG, ru-KG, ru-Cyrl-KG, km-KH,
	km-Khmr-KH, en-KI, en-Latn-KI, ar-KM, ar-Arab-KM, fr-KM,
	fr-Latn-KM, en-KN, en-Latn-KN, ko-KP, ko-Kore-KP, ko-KR,
	ko-Kore-KR, ar-KW, ar-Arab-KW, en-KY, en-Latn-KY, kk-KZ,
	kk-Cyrl-KZ, ru-KZ, ru-Cyrl-KZ, lo-LA, lo-Laoo-LA, ar-LB,
	ar-Arab-LB, en-LC, en-Latn-LC, de-LI, de-Latn-LI, gsw-LI,
	gsw-Latn-LI, si-LK, si-Sinhala-LK, ta-LK, ta-Taml-LK,
	en-LR, en-Latn-LR, vai-LR, vai-Latn-LR, vai-Vaii-LR, en-LS,
	en-Latn-LS, lt-LT, lt-Latn-LT, lb-LU, lb-Latn-LU, fr-LU,
	fr-Latn-LU, de-LU, de-Latn-LU, pt-LU, pt-Latn-LU, lv-LV,
	lv-Latn-LV, ar-LY, ar-Arab-LY, ar-MA, ar-Arab-MA, fr-MA,
	fr-Latn-MA, zgh-MA, zgh-Tfng-MA, tzm-MA, tzm-Latn-MA,
	shi-MA, shi-Tfng-MA, shi-Latn-MA, fr-MC, fr-Latn-MC, ro-MD,
	ro-Latn-MD, ru-MD, ru-Cyrl-MD, sr-ME, sr-Latn-ME,
	sr-Cyrl-ME, fr-MF, fr-Latn-MF, mg-MG, mg-Latn-MG, fr-MG,
	fr-Latn-MG, en-MG, en-Latn-MG, en-MH, en-Latn-MH, mk-MK,
	mk-Latn-MK, sq-MK, sq-Latn-MK, fr-ML, fr-Latn-ML, bm-ML,
	bm-ML, khq-ML, khq-Latn-ML, ses-ML, ses-Latn-ML, my-MM,
	my-Mymr-MM, mn-MN, mn-Cyrl-MN, zh-MO, zh-Hant-MO,
	zh-Hans-MO, en-MO, en-Latn-MO, pt-MO, pt-Latn-MO, en-MP,
	en-Latn-MP, fr-MQ, fr-Latn-MQ, ar-MR, ar-Arab-MR, fr-MR,
	fr-Latn-MR, ff-MR, ff-Latn-MR, en-MS, en-Latn-MS, mt-MT,
	mt-Latn-MT, en-MT, en-Latn-MT, en-MU, en-Latn-MU, fr-MU,
	fr-Latn-MU, mfe-MU, mfe-Latn-MU, dv-MV, dv-Thaa-MV, en-MW,
	en-Latn-MW, es-MX, es-MX, en-MY, en-MY, ms-MY, ms-Latn-MY,
	ta-MY, ta-Taml-MY, pt-MZ, pt-Latn-MZ, mgh-MZ, mgh-Latn-MZ,
	seh-MZ, seh-Latn-MZ, en-NA, en-Latn-NA, af-NA, af-Latn-NA,
	naq-NA, naq-Latn-NA, fr-NC, fr-Latn-NC, fr-NE, fr-Latn-NE,
	dje-NE, dje-Latn-NE, ha-NE, ha-Latn-NE, twq-NE,
	twq-Latn-NE, ff-NE, ff-Latn-NE, en-NF, en-Latn-NF, en-NG,
	en-Latn-NG, ha-NG, ha-Latn-NG, ig-NG, ig-Latn-NG, yo-NG,
	yo-Latn-NG, ff-NG, ff-Latn-NG, es-NI, es-Latn-NI, nl-NL,
	nl-Latn-NL, en-NL, en-Latn-NL, fy-NL, fy-Latn-NL, nds-NL,
	nds-Latn-NL, nb-NO, nb-Latn-NO, nn-NO, nn-Latn-NO, se-NO,
	se-Latn-NO, ne-NP, ne-Deva-NP, en-NR, en-NR, en-NU, en-NU,
	en-NZ, en-NZ, ar-OM, ar-Arab-OM, es-PA, es-Latn-PA, es-PE,
	es-Latn-PE, qu-PE, qu-Latn-PE, fr-PF, fr-Latn-PF, en-PG,
	en-PG, fil-PH, fil-Latn-H, en-PH, en-Latn-PH, es-PH,
	es-Latn-PH, ur-PK, ur-Arab-PK, en-PK, en-Latn-PK, pa-PK,
	pa-Arab-PK, pl-PL, pl-Latn-PL, fr-PM, fr-Latn-PM, en-PN,
	en-Latn-PN, es-PR, es-Latn-PR, en-PR, en-Latn-PR, ar-PS,
	ar-Arab-PS, en-PW, en-Latn-PW, es-PY, es-Latn-PY, ar-QA,
	ar-Latn-QA, fr-RE, fr-Latn-RE, ro-RO, ro-Latn-RO, sr-RS,
	sr-Cyrl-RS, sr-Latn-RS, ru-RU, ru-Cyrl-RU, ce-RU,
	ce-Cyrl-RU, os-RU, os-Cyrl-RU, sah-RU, sah-Cyrl-RU, tt-RU,
	tt-Cyrl-RU, cu-RU, cu-Cyrl-RU, en-RW, en-Latn-RW, fr-RW,
	fr-Latn-RW, rw-RW, rw-Latn-RW, ar-SA, ar-SA, en-SB,
	en-Latn-SB, en-SC, en-Latn-SC, fr-SC, fr-Latn-SC, ar-SD,
	ar-Arab-SD, en-SD, en-Latn-SD, sv-SE, sv-Latn-SE, en-SE,
	en-Latn-SE, se-SE, se-Latn-SE, en-SG, en-Latn-SG, ms-SG,
	ms-Latn-SG, ta-SG, ta-taml-SG, zh-SG, zh-Hans-SG, en-SH,
	en-Latn-SH, sl-SI, sl-Latn-SI, en-SI, en-Latn-SI, nb-SJ,
	nb-Latn-SJ, sk-SK, sk-Latn-SK, en-SL, en-SL, ff-SL,
	ff-Latn-SL, it-SM, it-Latn-SM, fr-SN, fr-Latn-SN, wo-SN,
	wo-Latn-SN, dyo-SN, dyo-Latn-SN, ff-SN, ff-Latn-SN, ar-SO,
	ar-Arab-SO, so-SO, so-Latn-SO, nl-SR, nl-Latn-SR, en-SS,
	en-Latn-SS, ar-SS, ar-Arab-SS, nus-SS, nus-Latn-SS, pt-ST,
	pt-Latn-ST, es-SV, es-Latn-SV, en-SX, en-Latn-SX, nl-SX,
	nl-Latn-SX, ar-SY, ar-Arab-SY, fr-SY, fr-Latn-SY, en-SZ,
	en-Latn-SZ, en-TC, en-Latn-TC, ar-TD, ar-Arab-TD, fr-TD,
	fr-Latn-TD, fr-TG, fr-Latn-TG, ee-TG, ee-Latn-TG, th-TH,
	th-Thai-TH, tg-TJ, tg-Cyrl-TJ, en-TK, en-Latn-TK, pt-TL,
	pt-Latn-TL, ar-TN, ar-Arab-TN, fr-TN, fr-Latn-TN, to-TO,
	to-Latn-TO, en-TO, en-Latn-TO, tr-TR, tr-Latn-TR, ku-TR,
	ku-Latn-TR, en-TT, en-Latn-TT, en-TV, en-Latn-TV, zh-TW,
	zh-Hant-TW, sw-TZ, sw-Latn-TZ, en-TZ, en-Latn-TZ, asa-TZ,
	asa-Latn-TZ, bez-TZ, bez-Latn-TZ, jmc-TZ, jmc-Latn-TZ,
	kde-TZ, kde-Latn-TZ, ksb-TZ, ksb-Latn-TZ, lag-TZ,
	lag-Latn-TZ, mas-TZ, mas-Latn-TZ, rof-TZ, rof-Latn-TZ,
	rwk-TZ, rwk-Latn-TZ, sbp-TZ, sbp-Latn-TZ, vun-TZ,
	vun-Latn-TZ, uk-UA, uk-Cyrl_UA, ru-UA, ru-Cyrl-UA, en-UG,
	en-Latn-UG, sw-UG, sw-Latn-UG, cgg-UG, cgg-Latn-UG, lg-UG,
	lg-Latn-UG, nyn-UG, nyn-Latn-UG, teo-UG, teo-Latn-UG,
	xog-UG, xog-Latn-UG, en-UM, en-Latn-UM, en-US, en-Latn-US,
	es-US, es-Latn-US, haw-US, haw-Latn-US, lkt-US,
	lkt-Latn-US, chr-US, chr-Latn-US, es-UY, es-Latn-UY, uz-UZ,
	uz-Latn-UZ, uz-Cyrl-UZ, it-VA, it-Latn-VA, en-VC,
	en-Latn-VC, es-VE, es-Latn-VE, en-VG, en-Latn-VG, en-VI,
	en-Latn-VI, vi-VN, vi-Latn-VN, en-VU, en-Latn-VU, fr-VU,
	fr-Latn-VU, fr-WF, fr-Latn-WF, en-WS, en-Latn-WS, sq-XK,
	sq-Latn-XK, sr-XK, sr-Cyrl-XK, sr-Latn-XK, ar-YE,
	ar-Arab-YE, fr-YT, fr-Latn-YT, af-ZA, af-Latn-ZA, en-ZA,
	en-Latn-ZA, zu-ZA, zu-Latn-ZA, bem-ZM, bem-Latn-ZM, en-ZM,
	en-Latn-ZM, en-ZW, en-Latn-ZW, nd-ZW, nd-Latn-ZW, sn-ZW,
	sn-Latn-ZW
")

func LocaleQuotationStyles()
	return _aLocaleQuotationStyles

func LocaleNumberOptions()
	return _aLocaleNumberOptions

func LocaleDataSizeFormats()
	return _aLocaleDataSizeFormats

func LocaleCurrencyFormats()
	return _aLocaleCurrencyFormats

func LocaleTimeFormatTypes()
	return _aLocaleTimeFormatTypes

