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

    cWord = lower(trim(str))
    aSortedRules = SortPluralRulesByPriority(PluralRules)
    for rule in aSortedRules
        if rule[3] = "exact"
            oRule1 = new stzString(rule[1])
            cPattern = oRule1.Section(2, len(rule[1])-1)
            if cWord = cPattern
                return rule[2]
            ok
        but rule[3] = "regex"
            rx = new stzRegex(rule[1])
            if rx.Match(cWord)
                aCaptured = rx.CapturedValues()
                nLen = len(aCaptured)
                if nLen > 0
                    cResult = rule[2]
                    for j = 1 to nLen
                        cPlaceholder = "\\" + j
                        cResult = substr(cResult, cPlaceholder, aCaptured[j])
                    next
                    return cResult
                else
                    return rule[2]
                ok
            ok
        but rule[3] = "default"
            return cWord + rule[2]
        ok
    next
    return cWord + "s"  // Fallback, though it should never reach here due to default rule

	func PluralOf(str)
		return Plural(str)

	func Pluralize(str)
		return Plural(str)

	func Pluralise(str)
		return Plural(str)

func SortPluralRulesByPriority(rules)
    n = len(rules)
    for i = 1 to n-1
        for j = 1 to n-i
            if rules[j][4] > rules[j+1][4]
                temp = rules[j]
                rules[j] = rules[j+1]
                rules[j+1] = temp
            ok
        next
    next
    return rules

// Helper functions
func AddPluralRule(pattern, replacement, type, priority, category)
    PluralRules + [pattern, replacement, type, priority, category]

func GetPluralRulesByCategory(category)
    result = []
    for rule in PluralRules
        if rule[5] = category
            result + rule
        ok
    next
    return result
