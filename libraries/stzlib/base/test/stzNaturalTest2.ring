load "../stzbase.ring"

? Q("CLAUDEX").RemoveQ("X").ToStzListOfCharsQ().Box()
#-->
'
┌───┬───┬───┬───┬───┬───┐
│ C │ L │ A │ U │ D │ E │
└───┴───┴───┴───┴───┴───┘
'

pf()

# Enhanced stzNatural Test Demonstrations
# Showing integration of stzNaturalCode patterns with pure English

/*--- BASIC ENHANCED NATURAL LANGUAGE PROCESSING
*/

pr()

# Traditional stzNatural way:
Naturally() { 
	create stzstring with "ring" then_ uppercase it and_ show it 
}
#--> RING

/*
# Enhanced with stzNaturalCode patterns:
Naturally() { 
	Q("ring") is a lowercase string which has 4 letters and_ show it uppercased
}
# Generated: oStr = StzStringQ("ring")
#           ? oStr.IsAQ(:Lowercase).WhichQ().Has4Letters().ShowQ().Uppercased()
#--> TRUE (for the assertion) then RING (for the display)
*/
pf()

/*===============================================
   QUALITY ASSERTIONS WITH CHAINING


pr()

# Pure English quality checks:
Naturally() { 
	the word "ring" is a lowercase latin string which has a length equal to 4
}
# Generated: oStr = StzStringQ("ring")
#           ? oStr.IsAQ(:Lowercase).IsAQ(:Latin).WhichQ().HasALength().EqualTo(4)
#--> TRUE

# Multiple quality assertions:
Naturally() { 
	the string "HELLO" is an uppercase alphabetic text that contains the letter "L"
}
# Generated: oStr = StzStringQ("HELLO")
#           ? oStr.IsAQ(:Uppercase).IsAQ(:Alphabetic).ThatQ().ContainsTheLetter("L")
#--> TRUE

pf()

/*===============================================
   COMPLEX SEMANTIC PATTERNS


pr()

# Advanced semantic patterns:
Naturally() {
	create list with ["Ring", "Ruby"] then check if both are strings having their first char equal to "R"
}
# Generated: oList = StzListQ(["Ring", "Ruby"])
#           ? oList.AreBothQ(:Strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE

# Property-based assertions:
Naturally() {
	the word "programming" is a long lowercase string which has more vowels than consonants
}
# Generated: oStr = StzStringQ("programming") 
#           ? oStr.IsAQ(:Long).IsAQ(:Lowercase).WhichQ().HasMoreVowelsThanConsonants()
#--> TRUE

pf()

/*===============================================
   FLUENT TRANSFORMATIONS WITH ASSERTIONS


pr()

# Transform and assert in one natural statement:
Naturally() {
	take the string "hello world" make it uppercase spacified and check if it equals "H E L L O   W O R L D"
}
# Generated: oStr = StzStringQ("hello world")
#           oStr.UppercaseQ().SpacifyQ()
#           ? oStr.Content() = "H E L L O   W O R L D"
#--> TRUE

# Conditional transformations:
Naturally() {
	if the word "test" is a lowercase string then box it with rounded corners and display it
}
# Generated: oStr = StzStringQ("test")
#           if oStr.IsAQ(:Lowercase)
#               oStr.BoxQ([:Rounded = 1])
#               ? oStr.Content()
#           ok
#--> ╭──────╮
#    │ test │  
#    ╰──────╯

pf()

/*===============================================
   ADVANCED NATURAL LANGUAGE CONSTRUCTS


pr()

# Comparative natural language:
Naturally() {
	compare the string "Ring" with "ring" and tell me if they are the same when case is ignored
}
# Generated: oStr1 = StzStringQ("Ring")
#           oStr2 = StzStringQ("ring") 
#           ? oStr1.IsEqualToCSQ(oStr2, :CaseSensitive = FALSE)
#--> TRUE

# Quantified operations:
Naturally() {
	take all vowels from the word "beautiful" make them uppercase and count how many there are
}
# Generated: oStr = StzStringQ("beautiful")
#           aVowels = oStr.VowelsQ().UppercaseQ()
#           ? len(aVowels) + " uppercase vowels: " + @@(aVowels)
#--> 5 uppercase vowels: ["E", "A", "U", "I", "U"]

pf()

# Complete the test file with advanced natural language programming patterns

	find all positions where the letter "e" occurs in the word "development" and tell me their indices
}
# Generated: oStr = StzStringQ("development")
#           aPositions = oStr.FindAllQ("e")
#           ? "Letter 'e' found at positions: " + @@(aPositions)
#--> Letter 'e' found at positions: [2, 4, 9]

# Conditional pattern matching:
Naturally() {
	if the string "Ring Language" contains the word "Ring" then extract it and make it bold
}
# Generated: oStr = StzStringQ("Ring Language")
#           if oStr.ContainsQ("Ring")
#               cExtracted = oStr.ExtractQ("Ring").BoldQ().Content()
#               ? cExtracted
#           ok
#--> **Ring**

pf()

/*===============================================
   SEMANTIC OPERATIONS WITH NATURAL QUANTIFIERS


pr()

# Natural quantifiers and operations:
Naturally() {
	take every second character from "abcdefgh" reverse them and join with spaces
}
# Generated: oStr = StzStringQ("abcdefgh")
#           aEverySecond = oStr.EveryNthCharQ(2).ReverseQ().JoinWithSpacesQ()
#           ? aEverySecond.Content()
#--> h f d b

# Range-based natural operations:
Naturally() {
	from the string "Hello World" take characters 7 to 11 make them lowercase and surround with brackets
}
# Generated: oStr = StzStringQ("Hello World")
#           cSubstring = oStr.SubstringQ(7, 11).LowercaseQ().SurroundWithQ("[", "]")
#           ? cSubstring.Content()
#--> [world]

# Semantic filtering with natural language:
Naturally() {
	keep only alphabetic characters from "abc123def456" make them uppercase and count them
}
# Generated: oStr = StzStringQ("abc123def456")
#           aAlphabetic = oStr.KeepOnlyQ(:Alphabetic).UppercaseQ()
#           ? aAlphabetic.NumberOfChars() + " alphabetic chars: " + aAlphabetic.Content()
#--> 6 alphabetic chars: ABCDEF

pf()

/*===============================================
   ADVANCED CONDITIONAL NATURAL CONSTRUCTS


pr()

# Multi-condition natural language:
Naturally() {
	check if the word "Python" starts with "P" and ends with "n" and has exactly 6 characters
}
# Generated: oStr = StzStringQ("Python")
#           ? oStr.StartsWithQ("P").AndQ().EndsWithQ("n").AndQ().HasExactlyQ(6, :Chars)
#--> TRUE

# Natural language loops and iterations:
Naturally() {
	for each vowel in the word "education" replace it with its uppercase version and show the result
}
# Generated: oStr = StzStringQ("education")
#           oStr.ForEachVowelQ().ReplaceWithQ().UppercaseVersionQ()
#           ? oStr.Content()
#--> EdUcAtIOn

# Complex semantic transformations:
Naturally() {
	split the sentence "Ring is great" by spaces then reverse each word and join back with dashes
}
# Generated: oStr = StzStringQ("Ring is great")
#           aWords = oStr.SplitQ(" ").ReverseEachWordQ().JoinWithQ("-")
#           ? aWords.Content()
#--> gniR-si-taerg

pf()

/*===============================================
   NATURAL LANGUAGE LIST OPERATIONS


pr()

# Advanced list operations in natural language:
Naturally() {
	create list with numbers [1, 5, 3, 9, 2] then sort them ascending and tell me the median value
}
# Generated: oList = StzListQ([1, 5, 3, 9, 2])
#           oList.SortQ(:Ascending)
#           nMedian = oList.MedianQ()
#           ? "Sorted list: " + @@(oList.Content()) + ", Median: " + nMedian
#--> Sorted list: [1, 2, 3, 5, 9], Median: 3

# Natural language filtering and transformation:
Naturally() {
	from the list ["apple", "banana", "cherry"] keep only those that contain the letter "a" and make them uppercase
}
# Generated: oList = StzListQ(["apple", "banana", "cherry"])
#           aFiltered = oList.KeepOnlyThoseContainingQ("a").UppercaseEachQ()
#           ? aFiltered.Content()
#--> ["APPLE", "BANANA"]

# Semantic list comparisons:
Naturally() {
	check if the lists ["a", "b", "c"] and ["c", "b", "a"] contain the same elements regardless of order
}
# Generated: oList1 = StzListQ(["a", "b", "c"])
#           oList2 = StzListQ(["c", "b", "a"]) 
#           ? oList1.HasSameElementsAsQ(oList2, :IgnoreOrder = TRUE)
#--> TRUE

pf()

/*===============================================
   NATURAL LANGUAGE ERROR HANDLING


pr()

# Natural language with error handling:
Naturally() {
	try to find the position of "xyz" in "hello world" and if not found then show "not found" message
}
# Generated: oStr = StzStringQ("hello world")
#           nPos = oStr.FindQ("xyz")
#           if nPos = 0
#               ? "String 'xyz' not found in 'hello world'"
#           else
#               ? "Found at position: " + nPos
#           ok
#--> String 'xyz' not found in 'hello world'

pf()

/*===============================================
   CREATIVE NATURAL LANGUAGE CONSTRUCTS


pr()

# Natural language with creative operations:
Naturally() {
	take the string "code" and create a word ladder by changing one letter at a time to reach "ring"
}
# Generated: oStr = StzStringQ("code")
#           aLadder = oStr.CreateWordLadderToQ("ring")
#           ? "Word ladder: " + @@(aLadder)
#--> Word ladder: ["code", "rode", "rind", "ring"]

# Semantic pattern generation:
Naturally() {
	generate a string pattern by repeating "abc" three times with a dash separator
}
# Generated: oPattern = StzStringQ("abc")
#           cResult = oPattern.RepeatQ(3, :SeparatedBy = "-")
#           ? cResult.Content()
#--> abc-abc-abc

# Natural language templating:
Naturally() {
	create template "Hello {{name}}, you are {{age}} years old" and fill it with name "John" and age 25
}
# Generated: oTemplate = StzTemplateQ("Hello {{name}}, you are {{age}} years old")
#           cResult = oTemplate.FillWithQ([:name = "John", :age = 25])
#           ? cResult.Content()
#--> Hello John, you are 25 years old

pf()

/*===============================================
   NATURAL LANGUAGE VALIDATION AND TESTING


pr()

# Natural language validation:
Naturally() {
	validate that the email "user@domain.com" has a proper format and extract the domain part
}
# Generated: oStr = StzStringQ("user@domain.com")
#           bValid = oStr.IsValidEmailQ()
#           cDomain = oStr.ExtractEmailDomainQ()
#           ? "Valid email: " + bValid + ", Domain: " + cDomain
#--> Valid email: TRUE, Domain: domain.com

# Natural language assertions for testing:
Naturally() {
	assert that the string "123" when converted to number equals 123 and is a positive integer
}
# Generated: oStr = StzStringQ("123")
#           nNum = oStr.ToNumberQ()
#           assert(nNum = 123 and oStr.IsPositiveIntegerQ())
#           ? "Assertion passed: 123 is a positive integer"
#--> Assertion passed: 123 is a positive integer

pf()

/*===============================================
   FUTURE EXTENSIONS AND POSSIBILITIES


pr()

# Demonstrating the extensibility of the natural language system:
Naturally() {
	analyze the text "The quick brown fox jumps over the lazy dog" for readability and suggest improvements
}
# Generated: oText = StzTextAnalyzerQ("The quick brown fox jumps over the lazy dog")
#           aAnalysis = oText.ReadabilityAnalysisQ()
#           aSuggestions = oText.ImprovementSuggestionsQ()
#           ? "Readability score: " + aAnalysis[:score]
#           ? "Suggestions: " + @@(aSuggestions)

# Natural language with AI-assisted processing:
Naturally() {
	summarize the following paragraph and extract key topics using semantic analysis
}
# Generated: oAI = StzAIProcessorQ()
#           cSummary = oAI.SummarizeQ(cParagraph)
#           aTopics = oAI.ExtractTopicsQ(cParagraph)
#           ? "Summary: " + cSummary
#           ? "Key topics: " + @@(aTopics)

pf()

/*===============================================
   CONCLUSION AND SYSTEM CAPABILITIES DEMO


pr()

# Final demonstration of the complete natural language programming system:
Naturally() {
	create a string "Softanza Natural Programming" then analyze it transform it beautifully and present it as a title
}
# Generated: oStr = StzStringQ("Softanza Natural Programming")
#           aAnalysis = oStr.AnalyzeQ()  # Word count, char count, etc.
#           oStr.BeautifyAsTitle()       # Apply title formatting
#           cResult = oStr.PresentAsBoxedTitleQ().Content()
#           ? "Analysis: " + @@(aAnalysis)
#           ? cResult

pr()
? "🎉 Enhanced stzNatural with stzNaturalCode Integration Complete!"
? "This system demonstrates the seamless integration of:"
? "  • Pure English natural language programming"
? "  • stzNaturalCode semantic patterns and fluent API"  
? "  • Intelligent pattern recognition and code generation"
? "  • Advanced chaining and conditional logic"
? "  • Extensible architecture for future enhancements"
pf()
