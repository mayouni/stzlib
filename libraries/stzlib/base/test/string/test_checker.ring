load "test_stubs.ring"
load "../stzString.ring"
load "../stzStringChecker.ring"
load "../stzStringComparator.ring"
load "../stzStringReplacer.ring"

pr()

? "=== stzStringChecker Number Representation Tests ==="

# Test RepresentsInteger
oChk = new stzStringChecker("12345")
? "RepresentsInteger('12345'): " + oChk.RepresentsInteger()
#--> 1

oChk = new stzStringChecker("+42")
? "RepresentsInteger('+42'): " + oChk.RepresentsInteger()
#--> 1

oChk = new stzStringChecker("-7")
? "RepresentsInteger('-7'): " + oChk.RepresentsInteger()
#--> 1

oChk = new stzStringChecker("abc")
? "RepresentsInteger('abc'): " + oChk.RepresentsInteger()
#--> 0

oChk = new stzStringChecker("")
? "RepresentsInteger(''): " + oChk.RepresentsInteger()
#--> 0

# Test RepresentsSignedInteger
oChk = new stzStringChecker("+42")
? "RepresentsSignedInteger('+42'): " + oChk.RepresentsSignedInteger()
#--> 1

oChk = new stzStringChecker("42")
? "RepresentsSignedInteger('42'): " + oChk.RepresentsSignedInteger()
#--> 0

# Test RepresentsUnsignedInteger
oChk = new stzStringChecker("42")
? "RepresentsUnsignedInteger('42'): " + oChk.RepresentsUnsignedInteger()
#--> 1

oChk = new stzStringChecker("-42")
? "RepresentsUnsignedInteger('-42'): " + oChk.RepresentsUnsignedInteger()
#--> 0

# Test RepresentsNumber (integer or float)
oChk = new stzStringChecker("3.14")
? "RepresentsNumber('3.14'): " + oChk.RepresentsNumber()
#--> 1

oChk = new stzStringChecker("42")
? "RepresentsNumber('42'): " + oChk.RepresentsNumber()
#--> 1

oChk = new stzStringChecker("abc")
? "RepresentsNumber('abc'): " + oChk.RepresentsNumber()
#--> 0

# Test RepresentsDecimalNumber
oChk = new stzStringChecker("3.14")
? "RepresentsDecimalNumber('3.14'): " + oChk.RepresentsDecimalNumber()
#--> 1

oChk = new stzStringChecker("42")
? "RepresentsDecimalNumber('42'): " + oChk.RepresentsDecimalNumber()
#--> 0

# Test RepresentsBinaryNumber
oChk = new stzStringChecker("0b1010")
? "RepresentsBinaryNumber('0b1010'): " + oChk.RepresentsBinaryNumber()
#--> 1

oChk = new stzStringChecker("0B1100")
? "RepresentsBinaryNumber('0B1100'): " + oChk.RepresentsBinaryNumber()
#--> 1

oChk = new stzStringChecker("1010")
? "RepresentsBinaryNumber('1010'): " + oChk.RepresentsBinaryNumber()
#--> 0

# Test RepresentsHexNumber
oChk = new stzStringChecker("0xDEAD")
? "RepresentsHexNumber('0xDEAD'): " + oChk.RepresentsHexNumber()
#--> 1

oChk = new stzStringChecker("0xFF")
? "RepresentsHexNumber('0xFF'): " + oChk.RepresentsHexNumber()
#--> 1

oChk = new stzStringChecker("DEAD")
? "RepresentsHexNumber('DEAD'): " + oChk.RepresentsHexNumber()
#--> 0

# Test IsPalindrome (engine-backed)
oChk = new stzStringChecker("racecar")
? "IsPalindrome('racecar'): " + oChk.IsPalindrome()
#--> 1

oChk = new stzStringChecker("hello")
? "IsPalindrome('hello'): " + oChk.IsPalindrome()
#--> 0

# Test IsAnagramOf (engine-backed)
oChk = new stzStringChecker("listen")
? "IsAnagramOf('listen','silent'): " + oChk.IsAnagramOf("silent")
#--> 1

oChk = new stzStringChecker("hello")
? "IsAnagramOf('hello','world'): " + oChk.IsAnagramOf("world")
#--> 0

? ""
? "=== New Checker Predicates ==="

# IsBlank
oChk = new stzStringChecker("   ")
? "IsBlank('   '): " + oChk.IsBlank()
#--> 1

oChk = new stzStringChecker("hello")
? "IsBlank('hello'): " + oChk.IsBlank()
#--> 0

# IsTitlecase
oChk = new stzStringChecker("Hello World")
? "IsTitlecase('Hello World'): " + oChk.IsTitlecase()
#--> 1

oChk = new stzStringChecker("hello world")
? "IsTitlecase('hello world'): " + oChk.IsTitlecase()
#--> 0

# IsIdentifier
oChk = new stzStringChecker("myVar_1")
? "IsIdentifier('myVar_1'): " + oChk.IsIdentifier()
#--> 1

oChk = new stzStringChecker("1bad")
? "IsIdentifier('1bad'): " + oChk.IsIdentifier()
#--> 0

# IsPangram
oChk = new stzStringChecker("the quick brown fox jumps over the lazy dog")
? "IsPangram: " + oChk.IsPangram()
#--> 1

# IsBalanced
oChk = new stzStringChecker("(a[b{c}d]e)")
? "IsBalanced('(a[b{c}d]e)'): " + oChk.IsBalanced()
#--> 1

oChk = new stzStringChecker("(a[b}")
? "IsBalanced('(a[b}'): " + oChk.IsBalanced()
#--> 0

# IsEmailLike
oChk = new stzStringChecker("user@example.com")
? "IsEmailLike: " + oChk.IsEmailLike()
#--> 1

# IsCamelCase
oChk = new stzStringChecker("camelCase")
? "IsCamelCase: " + oChk.IsCamelCase()
#--> 1

# IsSnakeCase
oChk = new stzStringChecker("snake_case")
? "IsSnakeCase: " + oChk.IsSnakeCase()
#--> 1

# IsKebabCase
oChk = new stzStringChecker("kebab-case")
? "IsKebabCase: " + oChk.IsKebabCase()
#--> 1

# RepresentsOctalNumber
oChk = new stzStringChecker("0o755")
? "RepresentsOctalNumber('0o755'): " + oChk.RepresentsOctalNumber()
#--> 1

oChk = new stzStringChecker("755")
? "RepresentsOctalNumber('755'): " + oChk.RepresentsOctalNumber()
#--> 0

? ""
? "=== Comparator Tests ==="

# LevenshteinDistance
oCmp = new stzStringComparator("kitten")
? "LevenshteinDistance('kitten','sitting'): " + oCmp.LevenshteinDistanceWith("sitting")

# PrefixCount (counts how many times the prefix repeats at the start)
oCmp = new stzStringComparator("ababab_rest")
? "PrefixCountWith('ab'): " + oCmp.PrefixCountWith("ab")
#--> 3

# SuffixCount (counts how many times the suffix repeats at the end)
oCmp = new stzStringComparator("rest_ababab")
? "SuffixCountWith('ab'): " + oCmp.SuffixCountWith("ab")
#--> 3

# Soundex
oCmp = new stzStringComparator("Robert")
? "Soundex('Robert'): " + oCmp.Soundex()

# Metaphone
oCmp = new stzStringComparator("Robert")
? "Metaphone('Robert'): " + oCmp.Metaphone()

? ""
? "=== Replacer Tests ==="

# Surround
oRpl = new stzStringReplacer("hello")
? "Surrounded('[','}'): " + oRpl.Surrounded("[", "]")
#--> [hello]

# StripTags
oRpl = new stzStringReplacer("<b>hello</b> <i>world</i>")
? "TagsStripped: " + oRpl.TagsStripped()
#--> hello world

# RemoveWhitespace
oRpl = new stzStringReplacer("  hello   world  ")
? "WhitespaceRemoved: '" + oRpl.WhitespaceRemoved() + "'"
#--> 'helloworld'

# SqueezeChar
oRpl = new stzStringReplacer("heeelllo")
? "CharSqueezed('l'): " + oRpl.CharSqueezed("l")
#--> heello

? ""
? "=== All tests completed ==="

pf()
