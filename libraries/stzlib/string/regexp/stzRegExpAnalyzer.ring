
func StzRegExpAnalyzerQ(cPattern)
	return new stzRegExpAnalyser(cPattern)

class stzRegExpAnalyzer
	oParser = new stzRegExpParser(cPattern)
	
	# Analysis results
	aTokens = []
	aMetrics = []
	aWarnings = []
	aSuggestions = []
	
	def init(cPattern)
		# Reset state
		aTokens = []
		aMetrics = []
		aWarnings = []
		aSuggestions = []
		
		# Parse pattern
		oParser.init(cPattern)
		aTokens = oParser.tokenize()[1]
		
		# Run analysis
		analyzeStructure()
		analyzeComplexity()
		analyzeVulnerabilities()
		
	def analyzeStructure()
		# Basic component counts
		nCharClasses = 0
		nGroups = 0
		nQuantifiers = 0
		nAlternations = 0
		nAnchors = 0
		nEscapes = 0
		nLiterals = 0
		nNestedGroups = 0
		nMaxNesting = 0
		
		# Track current nesting level
		nCurrentNesting = 0
		
		for token in aTokens

			if token[1] = :charClass
				nCharClasses++
				analyzeCharClass(token[2])
			but token[1] = :group
				nGroups++
				nCurrentNesting++
				nMaxNesting = max([ nMaxNesting, nCurrentNesting ])
				if nCurrentNesting > 1
					nNestedGroups++
				ok
			but token[1] = :quantifier
				nQuantifiers++
				analyzeQuantifier(token[2])
			but token[1] = :alternation
				nAlternations++
			but token[1] = :anchor
				nAnchors++
			but token[1] = :escape
				nEscapes++
			but token[1] = :literal
					nLiterals++
			but token[1] = ")" 
				nCurrentNesting--
			ok
		next
		
		aMetrics + [
			:componentCounts = [
				:charClasses = nCharClasses,
				:groups = nGroups,
				:quantifiers = nQuantifiers,
				:alternations = nAlternations,
				:anchors = nAnchors,
				:escapes = nEscapes,
				:literals = nLiterals
			],
			:nesting = [
				:maxDepth = nMaxNesting,
				:nestedGroups = nNestedGroups
			]
		]
	
	def analyzeComplexity()
		nComplexityScore = 0
		
		# Base complexity from component counts
		nComplexityScore += aMetrics[:componentCounts][:charClasses] * 2
		nComplexityScore += aMetrics[:componentCounts][:groups] * 3
		nComplexityScore += aMetrics[:componentCounts][:quantifiers] * 2
		nComplexityScore += aMetrics[:componentCounts][:alternations] * 4
		
		# Additional complexity from nesting
		nComplexityScore += aMetrics[:nesting][:maxDepth] * 5
		
		# Analyze backtracking potential
		nBacktrackingRisk = analyzeBacktrackingRisk()
		nComplexityScore += nBacktrackingRisk * 10
		
		if nComplexityScore > 50
			aWarnings + "High complexity score (" + nComplexityScore + ") may indicate maintenance issues"
			aSuggestions + "Consider breaking the pattern into smaller, more focused expressions"
		ok
		
		aMetrics + [:complexityScore = nComplexityScore]
	
	def analyzeVulnerabilities()
		# Check for common issues
		
		# 1. Catastrophic backtracking patterns
		checkCatastrophicBacktracking()
		
		# 2. Unescaped special characters
		checkUnescapedCharacters()
		
		# 3. Redundant patterns
		checkRedundancy()
		
		# 4. Inefficient constructs
		checkInefficiencies()
		
		# 5. Security implications
		checkSecurityIssues()
	
	private
	
	def analyzeCharClass(aClass)
		cClass = aClass[1]
		bNegated = aClass[2]
		
		# Check for common character class issues
		if len(cClass) > 20
			aWarnings + "Large character class may impact performance"
			aSuggestions + "Consider using predefined classes or splitting into smaller classes"
		ok
		
		if bNegated
			aWarnings + "Negated character class found - ensure this is intentional"
			aSuggestions + "Positive character classes are often clearer and more maintainable"
		ok
	
	def analyzeQuantifier(cQuant)
		# Check for problematic quantifier patterns
		if cQuant = "+" or cQuant = "*"
			for i = 1 to len(aTokens)-1
				if aTokens[i][1] = :quantifier and (aTokens[i][2] = "+" or aTokens[i][2] = "*")
					aWarnings + "Adjacent greedy quantifiers detected - potential exponential backtracking"
					aSuggestions + "Use more specific quantification or non-greedy versions"
				ok
			next
		ok
		
		if substr(cQuant, ",") > 0
			aValues = split(cQuant, ",")
			if 0 + aValues[2] - 0 + aValues[1] > 100
				aWarnings + "Large quantifier range may cause performance issues"
				aSuggestions + "Consider reducing the range or using a different approach"
			ok
		ok
	
	def analyzeBacktrackingRisk()
		nRisk = 0
		
		# Check for nested quantifiers
		nCurrentNesting = 0
		for token in aTokens
			if token[1] = :group
				nCurrentNesting++
			but token[1] = :quantifier and nCurrentNesting > 0
				nRisk += nCurrentNesting * 2
			but token[1] = ")"
				nCurrentNesting--
			ok
		next
		
		# Check for alternation with quantifiers
		bHasAlternation = false
		bHasQuantifier = false
		for token in aTokens
			if token[1] = :alternation
				bHasAlternation = true
			but token[1] = :quantifier
				bHasQuantifier = true
			ok
		next
		
		if bHasAlternation and bHasQuantifier
			nRisk += 3
		ok
		
		return nRisk
	
	def checkCatastrophicBacktracking()
		# Pattern examples that can cause catastrophic backtracking
		aRiskyPatterns = [
			[".*.*", "Nested greedy quantifiers"],
			["([a-z]+)*", "Repeated group with greedy quantifier"],
			["(a+)+", "Nested repeated group"]
		]
		
		cPatternStr = ""
		for token in aTokens
			cPatternStr += token[2]
		next
		
		for aPattern in aRiskyPatterns
			if substr(cPatternStr, aPattern[1]) > 0
				aWarnings + "Potential catastrophic backtracking pattern detected: " + aPattern[2]
				aSuggestions + "Rewrite using atomic groups or possessive quantifiers"
			ok
		next
	
	def checkUnescapedCharacters()
		aSpecialChars = ".$^{[(|)*+?\\"
		
		for token in aTokens
			if token[1] = :literal
				if substr(aSpecialChars, token[2]) > 0
					aWarnings + "Unescaped special character found: " + token[2]
					aSuggestions + "Consider escaping special character with backslash"
				ok
			ok
		next
	
	def checkRedundancy()
		# Check for redundant character classes
		aSeenClasses = []
		for token in aTokens
			if token[1] = :charClass
				cClass = token[2][1]
				for cSeen in aSeenClasses
					if cClass = cSeen
						aWarnings + "Redundant character class detected"
						aSuggestions + "Consider combining similar character classes"
					ok
				next
				add(aSeenClasses, cClass)
			ok
		next
		
		# Check for redundant groups
		aSeenGroups = []
		for token in aTokens
			if token[1] = :group
				cGroup = token[2]
				for cSeen in aSeenGroups
					if cGroup = cSeen
						aWarnings + "Redundant group detected"
						aSuggestions + "Consider using backreferences or combining groups"
					ok
				next
				add(aSeenGroups, cGroup)
			ok
		next
	
	def checkInefficiencies()
		# Check for inefficient alternations
		nConsecutiveAlts = 0
		for token in aTokens
			if token[1] = :alternation
				nConsecutiveAlts++
				if nConsecutiveAlts > 3
					aWarnings + "Multiple consecutive alternations may be inefficient"
					aSuggestions + "Consider using character classes or reorganizing alternatives"
				ok
			else
				nConsecutiveAlts = 0
			ok
		next
		
		# Check for unnecessary groups
		for token in aTokens
			if token[1] = :group
				if len(token[2]) = 1
					aWarnings + "Unnecessary grouping of single character"
					aSuggestions + "Remove unnecessary parentheses"
				ok
			ok
		next
	
	def checkSecurityIssues()
		# Check for patterns that might be used in ReDoS attacks
		bHasNestedQuantifiers = false
		bHasLongRanges = false
		
		for token in aTokens
			if token[1] = :quantifier
				if substr(token[2], ",") > 0
					aValues = split(token[2], ",")
					if 0 + aValues[2] > 1000
						bHasLongRanges = true
					ok
				ok
			ok
		next
		
		if bHasNestedQuantifiers and bHasLongRanges
			aWarnings + "Pattern may be vulnerable to ReDoS attacks"
			aSuggestions + "Limit quantifier ranges and avoid nested quantification"
		ok
	
	def getAnalysis()
		return [
			:metrics = aMetrics,
			:warnings = aWarnings,
			:suggestions = aSuggestions
		]
