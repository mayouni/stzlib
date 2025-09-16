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
    
    # Language/location patterns (priority 4)
    [ "(english|britain|uk)", "english", "regex", 4, "language" ],
    [ "(spanish|spain)", "spanish", "regex", 4, "language" ],
    [ "(french|france)", "french", "regex", 4, "language" ],
    [ "(arabic|arab)", "arabic", "regex", 4, "language" ],
    [ "(american?|usa?)", "american", "regex", 4, "geographic" ],
    [ "(european?)", "european", "regex", 4, "geographic" ],
	[ "(africa?)", "african", "regex", "4", "goegraphic"],
	[ "(asia?)", "asian", "regex", "4", "geographic"],
	[ "(australia?)","australian", "regex", "4", "geographic"],
	[ "(north?)","northern", "regex", "4", "geographic"],
    [ "(south?)","southern", "regex", "4", "geographic"],
	[ "(east)","eastern", "regex", "4", "geographic"],
	[ "(west?)","western", "regex", "4", "geographic"],

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

    cWord = lower(trim(str))
    
    # Sort rules by priority
    aSortedRules = SortAdverbRulesByPriority(AdverbRules)
    nLenRules = len(aSortedRules)

	for i = 1 to nLenRules
		rule = aSortedRules[i]
        
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

        but rule[3] = "keep"
            rx = new stzRegex(rule[1])
            if rx.Match(cWord)
                return cWord
            ok

        but rule[3] = "default"
            return cWord + rule[2]
        ok
    next
    
    return cWord + "ly"

	func AdverbOf(str)
		return Adverb(str)

func SortAdverbRulesByPriority(rules)
    # Simple bubble sort by priority (index 4)
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

# Enhanced helper functions
func AddAdverbRule(pattern, replacement, type, priority, category)
    AdverbRules + [pattern, replacement, type, priority, category]

func LoadAdverbRulesFromFile(filename)
    # Load rules from external file for easy maintenance
    
func GetAdverbRulesByCategory(category) 
    result = []
    for rule in AdverbRules
        if rule[5] = category
            result + rule
        ok
    next
    return result
