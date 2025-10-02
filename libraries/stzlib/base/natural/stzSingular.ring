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
    cWord = lower(trim(str))
    aSortedRules = SortSingularRulesByPriority(aSingularRules)
	nLen = len(aSortedRules)

	for i = 1 to nLen
		rule = aSortedRules[i]
        if rule[3] = "exact"
            oRule1 = new stzString(rule[1])
            cPattern = oRule1.Section(2, len(rule[1]) - 1)
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
            return cWord
        ok
    next
    return cWord  // Fallback, should not reach here due to "keep" rule

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
    result = []
	nLen = len(aSingularRules)

	for i = 1 to nLen
        if aSingularRules[i][5] = category
            result + aSingularRules[i]
        ok
    next
    return result
