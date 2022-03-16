/*
Locale abbreviation takes the form  of "C" or <language>_<script>_<country>
( exp : "ar_Arab_TN"), where:

	* <language> can be short (2 chars) or long abbreviation (3 chars) :
	  "ar" or "ara"
	* <script> is the script abbreviation (always 4 chars)
	* <country> is the country abbreviation (2 or 3 chars)

	--> Maximum of 12 chars : 10 chars for the abbreviations + 2 separators ("_" or "-")
	--> Minimum of 5 chars : like in 'ar_TN' for example

	Whatever separator the user provides ("-" or "_") then "_" is used.

	Providing the two separators ("-" and "_") in the same time is not allowed.
*/

func stzLocaleAbbreviationStringQ(pcStr)
	return new stzLocaleAbbreviationString(pcStr)

class stzLocaleAbbreviationString
	@cAbbreviation

	@cLanguageAbbreviation
	@cScriptAbbreviation
	@cCountryAbbreviation

	  #----------------------------------------------------#
	 #    INITIALIZING THE OBJECT FROM PROVIDED STRING    #
	#----------------------------------------------------#

	def init(pcStr)

		oStr = new stzString(pcStr)

		# If the string is empty or contains spaces then it can not be a locale

		if oStr.IsEmpty() or oStr.ContainsSpaces()
			stzRaise("Can't create locale abbreviation object!")
		ok

		# If the string is "C" then it's correct
		if UPPER(oStr.String()) = "C"
			@cAbbreviation = "C"
			@cLanguageAbbreviation  = "en"
			@cScriptAbbreviation	= "Latin"
			@cCountryAbbreviation	= NULL
			return
		ok

		# If the string is lesser then 5 chars or longer than 12 then
		# it can't be a locale abbreviation
		if oStr.NumberOfChars() < 5 OR
		   oStr.NumberOfChars() > 12
			stzRaise("Can't create locale abbreviation object!")
		ok

		# If the string contains no separators ('_' or '-') then
		# it can't be a locale abbreviation
		if oStr.ContainsNo("_") AND oStr.ContainsNo("-")
			stzRaise("Can't create locale abbreviation object!")
		ok

		# If the string contains the two separators ('_' and '-') in
		# the same time, then it can't be a locale abbreviation
		if oStr.Contains("_") AND oStr.Contains("-")
			stzRaise("Can't create locale abbreviation object!")
		ok

		# If the string contains more then 2 separators then it
		# is not a correct locale
		if (oStr.Contains("_") and oStr.NumberOfOccurrence(:Of = "_") > 2) or
		   (oStr.Contains("-") and oStr.NumberOfOccurrence(:Of = "-") > 2)
			stzRaise("Can't create locale abbreviation object!")
		ok

		# At this level, and before we can argue that the string is
		# actually a locale abbreviation, we need to extract the
		# language, script and country parts and check if they are
		# (respectively) a language, script and country abbreviation

		cAbbr = NULL
		cLangAbbr = NULL
		cScriptAbbr = NULL
		cCountryAbbr = NULL

		acAbbr 	= []

		aSplitOptions 	= [
	 		:CaseSensitive = FALSE,
			:SkipEmptyParts = TRUE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		]

		if oStr.Contains("_")
			acAbbr = oStr.SplitXT("_", aSplitOptions)

		but oStr.Contains("-")
			acAbbr = oStr.SplitXT("-", aSplitOptions)
		ok

		# acAbbrev contains 2 or 3 items

		# If acAbbrev contains 3 items
		if len(acAbbr) = 3
			# --> 1st item is language abbreviation
			cLangAbbr  	= acAbbr[1]
			# --> 2nd item is script abbreviation
			cScriptAbbr 	= acAbbr[2]
			# --> 3rd item is country abbreviation
			cCountryAbbr 	= acAbbr[3]

			# Composing the locale abbreviation (in a standard form)

			if _( @@(cLangAbbr)   ).@.IsLanguageAbbreviation() and
			   _( @@(cScriptAbbr) ).@.IsScriptAbbreviation() and
			   _( @@(cCountryAbbr)).@.IsCountryAbbreviation()
			
				cAbbr = StzStringQ(cLangAbbr).Lowercased() + "_" +
						 StzStringQ(cScriptAbbr).Capitalised()  + "_" +
						 StzStringQ(cCountryAbbr).Uppercased()

			else
				
			ok
	
		# If acAbbrev contains 2 items
		but len(acAbbr) = 2

			# --> 3 combinations are possible
			
			oItem1 = new stzString(acAbbr[1])
			oItem2 = new stzString(acAbbr[2])

			# 1st item is a langauge abbreviation and 2nd is a script abbreviation
			if oItem1.IsLanguageAbbreviation() and oItem2.IsScriptAbbreviation()
				cLangAbbr = acAbbr[1]
				cScriptAbbr   = acAbbr[2]

				# Composing the locale abbreviation (in a standard form)

				cAbbr = StzStringQ(cLangAbbr).Lowercased() + "_" +
					StzStringQ(cScriptAbbr).Capitalised()

			# 1st item is a langauge abbreviation and 2nd is a country abbreviation
			but oItem1.IsLanguageAbbreviation() and oItem2.IsCountryAbbreviation()
				cLangAbbr = acAbbr[1]
				cCountryAbbr  = acAbbr[2]

				# Composing the locale abbreviation (in a standard form)
				cAbbr = StzStringQ(cLangAbbr).Lowercased() + "_" +
					 	StzStringQ(cCountryAbbr).Uppercased()

			# 1st item is a script abbreviation and 2nd is a country abbreviation
			but oItem1.IsScriptAbbreviation() and oItem2.IsCountryAbbreviation()
				cScriptAbbr  	= acAbbr[1]
				cCountryAbbr	= acAbbr[2]

				# Composing the locale abbreviation (in a standard form). But we
				# need to infere the default language from the script first

				cLanguageAbbr = StzScriptQ(cScriptAbbr).DefaultLanguageAbbreviation()

				cAbbr = StzStringQ(cLangAbbr).Lowercased() + "_" +
					StzStringQ(cScriptAbbr).Capitalised()  + "_" +
					StzStringQ(cCountryAbbr).Uppercased()

			ok
		ok

		try
			new Qlocale(cAbbr)
			@cAbbreviation 		= cAbbr
			@cLanguageAbbreviation 	= cLangAbbr
			@cScriptAbbreviation	= cScriptAbbr
			@cCountryAbbreviation	= cCountryAbbr

		catch
				
			stzRaise("Can't create the locale abbreviation object!")
		done
	
	  #-----------------------------#
	 #    GETTING ABBREVIATIONS    #
	#-----------------------------#

	def Abbreviation()
		return @cAbbreviation

	def LanguageAbbreviation()
		return @cLanguageAbbreviation

	def ScriptAbbreviation()
		return @cScriptAbbreviation

	def CountryAbbreviation()
		return @cCountryAbbreviation

	  #-----------------------------------------------------#
	 #    CHECKING AND TRANSFORMING LOCALE ABBREVIATION    #
	#-----------------------------------------------------#

	def IsShortAbbreviation() # TODO

	def IsLongAbbreviation() # TODO

	def ToShortAbbreviation() # TODO

	def ToLongAbbreviation() # TODO

	  #-------------------------------------------------------#
	 #    CHECKING AND TRANSFORMING LANGUAGE ABBREVIATION    #
	#-------------------------------------------------------#

	def IsShortLanguageAbbreviation() # TODO

	def IsLongLanguageAbbreviation() # TODO

	def ToShortLanguageAbbreviation() # TODO

	def ToLongLanguageAbbreviation() # TODO

	  #-----------------------------------------------------#
	 #    CHECKING AND TRANSFORMING SCRIPT ABBREVIATION    #
	#-----------------------------------------------------#

	def IsShortScriptAbbreviation() # TODO

	def IsLongScriptAbbreviation() # TODO

	def ToShortScriptAbbreviation() # TODO

	def ToLongScriptAbbreviation() # TODO

	  #------------------------------------------------------#
	 #    CHECKING AND TRANSFORMING COUNTRY ABBREVIATION    #
	#------------------------------------------------------#

	def IsShortCountrytAbbreviation() # TODO

	def IsLongCountryAbbreviation() # TODO

	def ToShortCountryAbbreviation() # TODO

	def ToLongCountryAbbreviation() # TODO
