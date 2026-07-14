
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

class stzOrdinal from stzObject
    @nNumber
    @cLanguge
    
    def init(_n_)
        @nNumber = _n_
        @cLanguge = $aOrdinalConfig[:current_lang]
    
    def SetLanguage(lang)
        if find(["en", "fr", "ar"], lang)
            @cLanguge = lang
        ok
    
    def Language()
        return @cLanguge
    
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

	def Value()
		return @nNumber

		def Number()
			return @nNumber

    private
    
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
    
    def ToArabic(_aConfig_)
        _n_ = @nNumber
        if _n_ >= 1 and _n_ <= 5
            return _aConfig_[:suffixes][_n_ + 1]
        ok
        
        return "ال" + string(_n_)
