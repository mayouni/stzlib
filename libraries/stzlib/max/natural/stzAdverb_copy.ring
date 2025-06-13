# Global adverb transformation rules with priority and categories
AdverbRules = [
    # [pattern, replacement, type, priority, category]
    
    # Irregular forms (priority 1)
    ["^good$", "well", "exact", 1, "irregular"],
    ["^fast$", "fast", "exact", 1, "irregular"],
    ["^hard$", "hard", "exact", 1, "irregular"],
    
    # Domain-specific (priority 2)
    ["^finance$", "financially", "exact", 2, "domain"],
    ["^science$", "scientifically", "exact", 2, "domain"],
    ["^medicine$", "medically", "exact", 2, "domain"],
    ["^sales$", "sales-wise", "exact", 2, "domain"],
    ["^accounting$", "from an accounting perspective", "exact", 2, "domain"],
    ["^business$", "business-wise", "exact", 2, "domain"],
    ["^hr$", "from an HR perspective", "exact", 2, "domain"],
    ["^it$", "from an IT perspective", "exact", 2, "domain"],
    ["^technology$", "technologically", "exact", 2, "domain"],
    ["^administration$", "administratively", "exact", 2, "domain"],
    ["^economy$", "economically", "exact", 2, "domain"],
    ["^marketing$", "from a marketing perspective", "exact", 2, "domain"],
    ["^support$", "supportively", "exact", 2, "domain"],
    
    # Geographic/cultural (priority 3)
    ["^america$", "in an American way", "exact", 3, "geographic"],
    ["^europe$", "in a European way", "exact", 3, "geographic"],
    ["^france$", "in a French way", "exact", 3, "geographic"],
    ["^english$", "in English", "exact", 3, "language"],
    ["^spanish$", "in Spanish", "exact", 3, "language"],
	["^arab$", "in Arabic", "exact", 3, "language"],
    
    # Already adverbs (priority 4 - moved up to catch before morphology)
    ["ly$", "", "keep", 4, "preserve"],
    
    # Morphological patterns (priority 5)
    ["(.+[aeiou])y$", "\\1ily", "regex", 5, "morphology"],     # happy -> happily
    ["(.+[^aeiou])y$", "\\1ily", "regex", 5, "morphology"],   # dry -> drily
    ["le$", "ly", "suffix", 5, "morphology"],
    ["ic$", "ically", "suffix", 5, "morphology"],
    ["ful$", "fully", "suffix", 5, "morphology"],
    ["able$", "ably", "suffix", 5, "morphology"],
    ["ible$", "ibly", "suffix", 5, "morphology"],
    ["ent$", "ently", "suffix", 5, "morphology"],
    ["ant$", "antly", "suffix", 5, "morphology"],
    ["ce$", "cially", "suffix", 5, "morphology"],
    
    # Default fallback (priority 6)
    [".*", "ly", "default", 6, "fallback"]
]

func Adverb(str)
    cWord = lower(trim(str))
    
    # Sort rules by priority
    aSortedRules = SortRulesByPriority(AdverbRules)
    nLenRules = len(aSortedRules)

	for i = 1 to nLenRules

		rule = aSortedRules[i]
        
        if rule[3] = "exact"

            oRule1 = new stzString(rule[1])
            cPattern = oRule1.Section(2, len(rule[1])-1)  # remove ^ and $

            if cWord = cPattern
                return rule[2]
            ok

		but rule[3] = "regex"
            rx = new stzRegex(rule[1])
	
	            if rx.Match(cWord)
	
	                aCaptured = rx.CapturedValues()
	                nLen = len(aCaptured)
	
	                if nLen > 0
	                    # Replace capture group placeholders with actual values
	                    cResult = rule[2]
	                    for j = 1 to nLen
	                        cPlaceholder = "\\" + j
	                        cResult = substr(cResult, cPlaceholder, aCaptured[j])
	                    next
	
	                    return cResult
	
	                else
	                    return cWord + rule[2]
	                ok
	
	            ok

        but rule[3] = "suffix"
            oRule1 = new stzString(rule[1])
            cPattern = oRule1.Section(1, len(rule[1])-1)  # remove $ at end
            
            oWord = new stzString(cWord)
            
            if oWord.EndsWith(cPattern)
                cBase = oWord.Section(1, len(cWord) - len(cPattern))
                return cBase + rule[2]
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

func SortRulesByPriority(rules)
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

func LoadRulesFromFile(filename)
    # Load rules from external file for easy maintenance
    
func GetRulesByCategory(category) 
    result = []
    for rule in AdverbRules
        if rule[5] = category
            result + rule
        ok
    next
    return result
