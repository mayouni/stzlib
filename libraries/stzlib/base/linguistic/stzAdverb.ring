# Systematic adverb transformation rules
AdverbRules = [
    # [pattern, replacement, type, priority, category]
    
    # Irregulars (priority 1)
    [ "^good$", "well", "exact", 1, "irregular" ],
    [ "^fast$", "fast", "exact", 1, "irregular" ],
    [ "^hard$", "hard", "exact", 1, "irregular" ],
    [ "^late$", "late", "exact", 1, "irregular" ],
    [ "^early$", "early", "exact", 1, "irregular" ],
    
    # Already adverbs (priority 2)
    [ "ly$", '', "keep", 2, "preserve" ],
    [ "ward$", '', "keep", 2, "preserve" ],
    [ "wise$", '', "keep", 2, "preserve" ],
    
    # Domain patterns (priority 3)
    [ "^sales$", "sales-wise", "exact", 3, "domain" ],
    [ "(education|educat).*", "educationally", "regex", 3, "domain" ],
    [ "(finance|financ).*", "financially", "regex", 3, "domain" ],
    [ "(science|scient).*", "scientifically", "regex", 3, "domain" ],
    [ "(medicine|medic).*", "medically", "regex", 3, "domain" ],
    [ "(technolog).*", "technologically", "regex", 3, "domain" ],
    [ "(administrat).*", "administratively", "regex", 3, "domain" ],
    [ "(econom).*", "economically", "regex", 3, "domain" ],
    [ "(market).*", "from a marketing perspective", "regex", 3, "domain" ],
    [ "(business).*", "business-wise", "regex", 3, "domain" ],
    [ "(account).*", "from an accounting perspective", "regex", 3, "domain" ],
    
    # Language/location patterns (priority 4). Anchored to the WHOLE word
    # (^...$) so a place/language name only matches when it IS the word -- the
    # old unanchored forms matched substrings, e.g. "(asia?)" hit the "asi" in
    # "basic" and returned "asian" instead of letting morphology make
    # "basically".
    [ "^(english|britain|uk)$", "english", "regex", 4, "language" ],
    [ "^(spanish|spain)$", "spanish", "regex", 4, "language" ],
    [ "^(french|france)$", "french", "regex", 4, "language" ],
    [ "^(arabic|arab)$", "arabic", "regex", 4, "language" ],
    [ "^(american?|usa?)$", "american", "regex", 4, "geographic" ],
    [ "^(european?)$", "european", "regex", 4, "geographic" ],
	[ "^(africa?)$", "african", "regex", 4, "geographic"],
	[ "^(asia?)$", "asian", "regex", 4, "geographic"],
	[ "^(australia?)$","australian", "regex", 4, "geographic"],
	[ "^(north?)$","northern", "regex", 4, "geographic"],
    [ "^(south?)$","southern", "regex", 4, "geographic"],
	[ "^(east)$","eastern", "regex", 4, "geographic"],
	[ "^(west?)$","western", "regex", 4, "geographic"],

    # Morphological patterns (priority 5)
    [ "(.+[aeiou])y$", "\\1ily", "regex", 5, "morphology" ],
    [ "(.+[^aeiou])y$", "\\1ily", "regex", 5, "morphology" ],
    [ "(.+)le$", "\\1ly", "regex", 5, "morphology" ],
    [ "(.+)ic$", "\\1ically", "regex", 5, "morphology" ],
    [ "(.+)ful$", "\\1fully", "regex", 5, "morphology" ],
    [ "(.+)able$", "\\1ably", "regex", 5, "morphology" ],
    [ "(.+)ible$", "\\1ibly", "regex", 5, "morphology" ],
    [ "(.+)ent$", "\\1ently", "regex", 5, "morphology" ],
    [ "(.+)ant$", "\\1antly", "regex", 5, "morphology" ],
    [ "(.+)al$", "\\1ally", "regex", 5, "morphology" ],
    [ "(.+)ous$", "\\1ously", "regex", 5, "morphology" ],
    [ "(.+)ive$", "\\1ively", "regex", 5, "morphology" ],
    
    # Default (priority 6)
    [ ".*", "ly", "default", 6, "fallback" ]
]

func Adverb(str)

    _cWord_ = StzLower(trim(str))
    
    # Sort rules by priority
    _aSortedRules_ = SortAdverbRulesByPriority(AdverbRules)
    _nLenRules_ = len(_aSortedRules_)

	for i = 1 to _nLenRules_
		_rule_ = _aSortedRules_[i]
        
        if _rule_[3] = "exact"
            _oRule1_ = new stzString(_rule_[1])
            _cPattern_ = _oRule1_.Section(2, StzLen(_rule_[1])-1)
            if _cWord_ = _cPattern_
                return _rule_[2]
            ok

		but _rule_[3] = "regex"
            _rx_ = new stzRegex(_rule_[1])
            if _rx_.MatchFirst(_cWord_)
                _aCaptured_ = _rx_.CapturedValues()
                # \1 maps to the first CAPTURE GROUP (aCaptured[2]), not the
                # full match (aCaptured[1]). See stzPlural for the same fix.
                _nLen_ = len(_aCaptured_)
                if _nLen_ > 1
                    _cResult_ = _rule_[2]
                    for j = 1 to _nLen_ - 1
                        _cPlaceholder_ = "\\" + j
                        _cResult_ = StzReplace(_cResult_, _cPlaceholder_, _aCaptured_[j+1])
                    next
                    return _cResult_
                else
                    return _rule_[2]
                ok
            ok

        but _rule_[3] = "keep"
            _rx_ = new stzRegex(_rule_[1])
            if _rx_.MatchFirst(_cWord_)
                return _cWord_
            ok

        but _rule_[3] = "default"
            return _cWord_ + _rule_[2]
        ok
    next
    
    return _cWord_ + "ly"

	func AdverbOf(str)
		return Adverb(str)

func SortAdverbRulesByPriority(rules)
    # Simple bubble sort by priority (index 4)
    _n_ = len(rules)
    for i = 1 to _n_-1
        for j = 1 to _n_-i
            if rules[j][4] > rules[j+1][4]
                _temp_ = rules[j]
                rules[j] = rules[j+1]
                rules[j+1] = _temp_
            ok
        next
    next
    return rules

# Enhanced helper functions
func AddAdverbRule(pattern, replacement, type, priority, category)
    AdverbRules + [pattern, replacement, type, priority, category]

func LoadAdverbRulesFromFile(filename)
    # Load rules from external file for easy maintenance
    
func GetAdverbRulesByCategory(category) 
    _result_ = []
    _nAdverbRules1Len_ = len(AdverbRules)
    for _iLoopAdverbRules1_ = 1 to _nAdverbRules1Len_
    	_rule_ = AdverbRules[_iLoopAdverbRules1_]
        if _rule_[5] = category
            _result_ + _rule_
        ok
    next
    return _result_
