// Define the aSingularRules list with inverse transformations of stzPlural
aSingularRules = [
    // Irregulars (priority 1)
    [ "^children$", "child", "exact", 1, "irregular" ],
    [ "^men$", "man", "exact", 1, "irregular" ],
    [ "^women$", "woman", "exact", 1, "irregular" ],
    [ "^mice$", "mouse", "exact", 1, "irregular" ],
    [ "^geese$", "goose", "exact", 1, "irregular" ],
    [ "^feet$", "foot", "exact", 1, "irregular" ],
    [ "^teeth$", "tooth", "exact", 1, "irregular" ],
    [ "^people$", "person", "exact", 1, "irregular" ],

    // Unchanged (priority 2)
    [ "^sheep$", "sheep", "exact", 2, "unchanged" ],
    [ "^deer$", "deer", "exact", 2, "unchanged" ],
    [ "^fish$", "fish", "exact", 2, "unchanged" ],
    [ "^series$", "series", "exact", 2, "unchanged" ],

    // Morphological patterns (priority 3)
    [ "(.+[^aeiou])ies$", "\\1y", "regex", 3, "morphology" ],    // e.g., "cities" -> "city"
    [ "(.+)ses$", "\\1s", "regex", 3, "morphology" ],           // e.g., "buses" -> "bus"
    [ "(.+)xes$", "\\1x", "regex", 3, "morphology" ],           // e.g., "boxes" -> "box"
    [ "(.+)zes$", "\\1z", "regex", 3, "morphology" ],           // e.g., "buzzes" -> "buzz"
    [ "(.+)ches$", "\\1ch", "regex", 3, "morphology" ],         // e.g., "churches" -> "church"
    [ "(.+)shes$", "\\1sh", "regex", 3, "morphology" ],         // e.g., "dishes" -> "dish"
    [ "(.+)ves$", "\\1f", "regex", 3, "morphology" ],           // e.g., "leaves" -> "leaf"
    [ "(.+)ives$", "\\1ife", "regex", 3, "morphology" ],        // e.g., "knives" -> "knife"

    // Default (priority 4)
    [ "(.+)s$", "\\1", "regex", 4, "fallback" ],                // e.g., "cats" -> "cat"
    [ ".*", "", "keep", 5, "preserve" ]                         // Keep word as is if no rules match
]

// Function to sort rules by priority
func SortSingularRulesByPriority(aRules)
    return sorton(aRules, 4)

// Function to convert a plural noun to singular
func Singular(str)
    _cWord_ = StzLower(trim(str))
    _aSortedRules_ = SortSingularRulesByPriority(aSingularRules)
	_nLen_ = len(_aSortedRules_)

	for i = 1 to _nLen_
		_rule_ = _aSortedRules_[i]
        if _rule_[3] = "exact"
            _oRule1_ = new stzString(_rule_[1])
            _cPattern_ = _oRule1_.Section(2, StzLen(_rule_[1]) - 1)
            if _cWord_ = _cPattern_
                return _rule_[2]
            ok

        but _rule_[3] = "regex"
            _rx_ = new stzRegex(_rule_[1])
            if _rx_.Match(_cWord_)
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
            return _cWord_
        ok
    next
    return _cWord_  // Fallback, should not reach here due to "keep" rule

	func SingularOf(str)
		return Singular(str)

	func Singularise(str)
		return Singular(str)

	func Singularize(str)
		return Singular(str)

// Helper function to add a new singular rule
func AddSingularRule(pattern, replacement, type, priority, category)
    aSingularRules + [pattern, replacement, type, priority, category]

// Helper function to get rules by category
func GetsingularRulesByCategory(category)
    _result_ = []
	_nLen_ = len(aSingularRules)

	for i = 1 to _nLen_
        if aSingularRules[i][5] = category
            _result_ + aSingularRules[i]
        ok
    next
    return _result_
