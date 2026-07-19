#TODO Make a bridge with stzLocale to let the stzPlural class be locale-sensitive

// Systematic plural transformation rules
PluralRules = [
    // Irregulars (priority 1)
    [ "^child$", "children", "exact", 1, "irregular" ],
    [ "^man$", "men", "exact", 1, "irregular" ],
    [ "^woman$", "women", "exact", 1, "irregular" ],
    [ "^mouse$", "mice", "exact", 1, "irregular" ],
    [ "^goose$", "geese", "exact", 1, "irregular" ],
    [ "^foot$", "feet", "exact", 1, "irregular" ],
    [ "^tooth$", "teeth", "exact", 1, "irregular" ],
    [ "^person$", "people", "exact", 1, "irregular" ],
    
    // Unchanged (priority 2)
    [ "^sheep$", "sheep", "exact", 2, "unchanged" ],
    [ "^deer$", "deer", "exact", 2, "unchanged" ],
    [ "^fish$", "fish", "exact", 2, "unchanged" ],
    [ "^series$", "series", "exact", 2, "unchanged" ],
    
    // Morphological patterns (priority 3)
    [ "(.+)s$", "\\1ses", "regex", 3, "morphology" ],
    [ "(.+)x$", "\\1xes", "regex", 3, "morphology" ],
    [ "(.+)z$", "\\1zes", "regex", 3, "morphology" ],
    [ "(.+)ch$", "\\1ches", "regex", 3, "morphology" ],
    [ "(.+)sh$", "\\1shes", "regex", 3, "morphology" ],
    [ "(.+[^aeiou])y$", "\\1ies", "regex", 3, "morphology" ],
    [ "(.+[aeiou])y$", "\\1ys", "regex", 3, "morphology" ],
    [ "(.+)f$", "\\1ves", "regex", 3, "morphology" ],
    [ "(.+)fe$", "\\1ves", "regex", 3, "morphology" ],
    
    // Default (priority 4)
    [ ".*", "s", "default", 4, "fallback" ]
]

func Plural(str)

    _cWord_ = StzLower(trim(str))
    _aSortedRules_ = SortPluralRulesByPriority(PluralRules)
    _nSortedRules1Len_ = len(_aSortedRules_)
    for _iLoopSortedRules1_ = 1 to _nSortedRules1Len_
    	_rule_ = _aSortedRules_[_iLoopSortedRules1_]
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
                # CapturedValues() returns [ fullMatch, group1, group2, ... ];
                # the \1 placeholder maps to the first CAPTURE GROUP, i.e.
                # aCaptured[2]. The old code mapped \1 -> aCaptured[1] (the
                # full match), so "city" + "ies" became "cityies" instead of
                # replacing the stem -> "cities".
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
        but _rule_[3] = "default"
            return _cWord_ + _rule_[2]
        ok
    next
    return _cWord_ + "s"  // Fallback, though it should never reach here due to default rule

	func PluralOf(str)
		return Plural(str)

	func Pluralize(str)
		return Plural(str)

	func Pluralise(str)
		return Plural(str)

func SortPluralRulesByPriority(rules)
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

// Helper functions
func AddPluralRule(pattern, replacement, type, priority, category)
    PluralRules + [pattern, replacement, type, priority, category]

func GetPluralRulesByCategory(category)
    _result_ = []
    _nPluralRules1Len_ = len(PluralRules)
    for _iLoopPluralRules1_ = 1 to _nPluralRules1Len_
    	_rule_ = PluralRules[_iLoopPluralRules1_]
        if _rule_[5] = category
            _result_ + _rule_
        ok
    next
    return _result_
