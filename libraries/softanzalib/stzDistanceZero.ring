
# In memory of the palestinian people and their fight
# for Freedom, justice and dignity.

# NOTE : This is a personal opinion of the author.
# It shouldn't be considered as a technical part
# of the library. I respect all views, including
# those who do not share mine. I just want them
# to do the same. My respect to all.

func DistanceZeroQ()
	return new stzDistanceZero()

	func stzDistanceZeroQ()
		return DistanceZeroQ()

class stzDistanceZero from stzObject
	@cContent = "🔻"

	@acDescription = [
		:English  = "A reversed red triangle",
		:Arabic = "مثلّث أحمر مقلوب"
	]

	@acCountry = [
		:English  = "Palestine",
		:Arabic = "فلسطين"
	]

	@acRegion = [
		:English  = "Gaza",
		:Arabic = "غزّة"
	]

	@acDateOfBirth = [
		:English  = "October, 7th. 2023.",
		:Arabic = "السّابع من أكتوبر 2023."
	]

	@acMeaning = [
		:English  = "Resistance, power, freedom!",
		:Arabic = "مقاومة، قوّة، حرّيّة !"
	]


	@cLanguage = :English

	def init()
		# Do nothing

	def Content()
		return @cContent
	
	def Show()
		? This.Content()

	def ShowXT()
		? "Content	= " + This.Content()
		? "Description	= " + This.Description()
		? "Country	= " + This.Country()
		? "Region	= " + This.Region()
		? "DateOfBirth	= " + This.DateOfBirth()
		? "Meaning	= " + This.Meaning()

	def Description()
		return @acDescription[@cLanguage]

	def Country()
		return @acCountry[@cLanguage]

	def Region()
		return @acRegion[@cLanguage]

	def DateOfBirth()
		return @acDateOfBirth[@cLanguage]

	def Meaning()
		return @acMeaning[@cLanguage]

	def SayItIn(cLang)
		if CheckParams()
			if NOT isString(cLang)
				StzRaise("Incorrect param type! cLang must be a string")
			ok
		ok

		if cLang = :Arabic
			@cLanguage = :Arabic
		else
			@cLanguage = :English
		ok

	def SayItInEnglish()
		@cLanguage = :English

	def SayItInArabic()
		@cLanguage = :Arabic
