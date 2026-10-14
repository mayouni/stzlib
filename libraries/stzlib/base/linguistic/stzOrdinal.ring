
// Global multilingual configuration for ordinals
$aOrdinalConfig = [
    :current_lang = "en",
    :languages = [
        :en = [
            :suffixes = ["th", "st", "nd", "rd"],
            :special_cases = [11, 12, 13]
        ],
        :fr = [
            :suffixes = ["ème", "er", "ère", "e"],
            :special_cases = [1]
        ],
        :ar = [
            :suffixes = ["", "الأوّل", "الثّاني", "الثّالث", "الرابع", "الخامس"],
            :pattern = "written"
        ]
    ]
]

// Helper function
func Ordinal(_n_)
    _oOrd_ = new stzOrdinal(_n_)
    return _oOrd_.Content()

// Set global language
func SetOrdinalLanguage(lang)
    if find(["en", "fr", "ar"], lang)
        $aOrdinalConfig[:current_lang] = lang
        return true
    ok
    return false

# Turns a whole number into its ordinal form, such as 3rd in English, 3e in French or an Arabic ordinal word.
#
# The language comes from a global setting at the moment the object is built (SetOrdinalLanguage
# changes it for objects made afterwards) and SetLanguage changes it for one object. English, French
# and Arabic are supported. The function Ordinal(n) builds the object and answers the text in one
# step. Only the three public readers (ToString, Value, Language) are meant for callers; ToEnglish,
# ToFrench and ToArabic are private helpers of ToString.
#
#   receiver   o1 = new stzOrdinal(3)
#   example    ? o1.ToString()
#              #--> 3rd
#              o1.SetLanguage("fr")
#              ? o1.ToString()
#              #--> 3e
#              o1.SetLanguage("ar")
#              ? o1.ToString()
#              #--> الثّالث
#   see        stzNumber, stzString
class stzOrdinal from stzObject
    @nNumber
    @cLanguge
    
    # Builds an ordinal from a whole number, spelled in the language the library is set to when the object is made.
    #
    #   _n_        the number to turn into an ordinal
    #   returns    nothing; the object is built
    #   warning    the language is read from the global $aOrdinalConfig at birth, so a later
    #              SetOrdinalLanguage does not reach an object already built
    #   see        SetLanguage, Ordinal
    def init(_n_)
        @nNumber = _n_
        @cLanguge = $aOrdinalConfig[:current_lang]
    
    # Switches this ordinal to English ("en"), French ("fr") or Arabic ("ar"), and ignores any other code.
    #
    #   lang       the language code, one of "en", "fr" or "ar"
    #   returns    nothing; an unknown code leaves the language as it was
    #   warning    an unknown code such as "xx" is silent: no error and no change
    #   see        Language, ToString
    def SetLanguage(lang)
        if find(["en", "fr", "ar"], lang)
            @cLanguge = lang
        ok
    
    # Returns the language code this ordinal speaks.
    #
    #   returns    a text: "en", "fr" or "ar"
    #   see        SetLanguage
    def Language()
        return @cLanguge
    
    # Returns the ordinal as text in the language set on this object, such as 3rd, 3e or the Arabic word for third.
    #
    #   returns    a text
    #   note       English reads 11, 12 and 13 as th; French gives 1er and then e up to 9 and ème
    #              from 10; Arabic spells 1 to 5 as words and writes ال before any larger number; 0
    #              and negatives get the th suffix in English and the ème suffix in French
    #   see        Value, SetLanguage, Ordinal
    def ToString()
        _aConfig_ = $aOrdinalConfig[:languages][@cLanguge]
        
        switch @cLanguge
            on "en"
                return This.ToEnglish(_aConfig_)

            on "fr"
                return This.ToFrench(_aConfig_)

            on "ar"
                return This.ToArabic(_aConfig_)
        off
        
        return string(@nNumber)

    def Content()
        return This.ToString()

	# Returns the number this ordinal was built from, unchanged.
	#
	#   returns    a number
	#   see        Number, ToString
	def Value()
		return @nNumber

		# Returns the plain number behind the ordinal, the same answer as Value.
		#
		#   returns    a number
		#   see        Value
		def Number()
			return @nNumber

    private
    
    # Builds the English spelling of the number from the suffix table of the language, such as 21st or 12th.
    #
    #   _aConfig_   the English entry of $aOrdinalConfig: its :suffixes and :special_cases
    #   returns     a text
    #   warning     private: ToString calls it, and a call from outside raises error R26
    #   see         ToString
    def ToEnglish(_aConfig_)
        _n_ = @nNumber
        if _n_ <= 0
            return string(_n_) + _aConfig_[:suffixes][1]
        ok
        
        _nLastDigit_ = _n_ % 10
        _nLastTwoDigits_ = _n_ % 100
        
        if find(_aConfig_[:special_cases], _nLastTwoDigits_)
            return string(_n_) + _aConfig_[:suffixes][1]
        ok
        
        switch _nLastDigit_
            on 1
                _cSuffix_ = _aConfig_[:suffixes][2]
            on 2
                _cSuffix_ = _aConfig_[:suffixes][3]
            on 3
                _cSuffix_ = _aConfig_[:suffixes][4]
            other
                _cSuffix_ = _aConfig_[:suffixes][1]
        off
        
        return string(_n_) + _cSuffix_
    
    # Builds the French spelling of the number from the suffix table of the language, such as 1er, 2e or 12ème.
    #
    #   _aConfig_   the French entry of $aOrdinalConfig: its :suffixes
    #   returns     a text
    #   warning     private: ToString calls it, and a call from outside raises error R26; the
    #               feminine form is never produced
    #   see         ToString
    def ToFrench(_aConfig_)
        _n_ = @nNumber
        if _n_ <= 0
            return string(_n_) + _aConfig_[:suffixes][1]
        ok
        
        if _n_ = 1
            return "1er"
        ok
        
        if _n_ <= 9
            return string(_n_) + _aConfig_[:suffixes][4]
        ok
        
        return string(_n_) + _aConfig_[:suffixes][1]
    
    # Builds the Arabic spelling of the number: the ordinal word for 1 to 5, and ال followed by the digits for any other.
    #
    #   _aConfig_   the Arabic entry of $aOrdinalConfig: its :suffixes list of ordinal words
    #   returns     a text
    #   warning     private: ToString calls it, and a call from outside raises error R26
    #   see         ToString
    def ToArabic(_aConfig_)
        _n_ = @nNumber
        if _n_ >= 1 and _n_ <= 5
            return _aConfig_[:suffixes][_n_ + 1]
        ok
        
        return "ال" + string(_n_)
