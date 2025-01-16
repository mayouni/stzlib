load "../max/stzmax.ring"

# Example 1: Basic pattern with character classes and quantifiers
oParser = new stzRegexParser("[A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}")
aSequences = oParser.parse()
? "Pattern analysis:"
for sequence in aSequences
    ? sequence.getPattern()
    ? sequence.getNarration()
next
/*
# Example 2: Pattern with special character classes and groups
oParser = new stzRegexParser("(\d{3})-(\w+)\s*")
aSequences = oParser.parse()
? nl + "Pattern analysis:"
for sequence in aSequences
    ? sequence.getPattern()
    ? sequence.getNarration()
next

# Example 3: Complex pattern with alternation and nested groups
oParser = new stzRegexParser("([A-Z]+|[0-9]{2,4})?[- ](\w{3,})")
aSequences = oParser.parse()
? nl + "Pattern analysis:"
for sequence in aSequences
    ? sequence.getPattern()
    ? sequence.getNarration()
next

# Example 4: Pattern with negated character class and anchors
oParser = new stzRegexParser("^[^0-9]{1,3}[- ]\w+$")
aSequences = oParser.parse()
? nl + "Pattern analysis:"
for sequence in aSequences
    ? sequence.getPattern()
    ? sequence.getNarration()
next
