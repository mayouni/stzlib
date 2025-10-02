
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
func Ordinal(n)
	_oOrd_ = new stzOrdinal(n)
    return _oOrd_.Content()

// Set global language
func SetOrdinalLanguage(lang)
    if find(["en", "fr", "ar"], lang)
        $aOrdinalConfig[:current_lang] = lang
        return true
    ok
    return false

class stzOrdinal from stzObject
    @nNumber
    @cLanguge
    
    def init(n)
        @nNumber = n
        @cLanguge = $aOrdinalConfig[:current_lang]
    
    def SetLanguage(lang)
        if find(["en", "fr", "ar"], lang)
            @cLanguge = lang
        ok
    
    def Language()
        return @cLanguge
    
    def ToString()
        aConfig = $aOrdinalConfig[:languages][@cLanguge]
        
        switch @cLanguge
            on "en"
                return This.ToEnglish(aConfig)

            on "fr"
                return This.ToFrench(aConfig)

            on "ar"
                return This.ToArabic(aConfig)
        off
        
        return string(@nNumber)

    def Content()
        return This.ToString()

	def Value()
		return @nNumber

		def Number()
			return @nNumber

    private
    
    def ToEnglish(aConfig)
        n = @nNumber
        if n <= 0
            return string(n) + aConfig[:suffixes][1]
        ok
        
        nLastDigit = n % 10
        nLastTwoDigits = n % 100
        
        if find(aConfig[:special_cases], nLastTwoDigits)
            return string(n) + aConfig[:suffixes][1]
        ok
        
        switch nLastDigit
            on 1
                cSuffix = aConfig[:suffixes][2]
            on 2
                cSuffix = aConfig[:suffixes][3]
            on 3
                cSuffix = aConfig[:suffixes][4]
            other
                cSuffix = aConfig[:suffixes][1]
        off
        
        return string(n) + cSuffix
    
    def ToFrench(aConfig)
        n = @nNumber
        if n <= 0
            return string(n) + aConfig[:suffixes][1]
        ok
        
        if n = 1
            return "1er"
        ok
        
        if n <= 9
            return string(n) + aConfig[:suffixes][4]
        ok
        
        return string(n) + aConfig[:suffixes][1]
    
    def ToArabic(aConfig)
        n = @nNumber
        if n >= 1 and n <= 5
            return aConfig[:suffixes][n + 1]
        ok
        
        return "ال" + string(n)
