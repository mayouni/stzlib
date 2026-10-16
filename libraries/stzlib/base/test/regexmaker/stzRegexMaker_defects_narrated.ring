load "../../stzBase.ring"
load "../_narrated.ring"

# stzRegexMaker and stzRecursiveRegexMaker -- the defect register, one scenario per family.
# Run from inside test/regexmaker.
#
# Every pattern the makers build is MATCHED by the library's own engine (stzRegex, PCRE2), against
# a text that should match and one that should not, and one scenario does it with non-ASCII text.
# Fits() asks whether the pattern matches the WHOLE text, Finds() whether it occurs anywhere in it.
#
# FIXED   : NumberOfSequences and its 8 aliases, CommandXT / CommandAndFragment / CommandAndFrag /
#           CommandAndItsFragment / CommandAndItsFrag, CanContainAChar / CanContaingChar /
#           CanContainADigit / CanContaingdigit (and the text forms of the Between calls and the list
#           form of the digit Among call), MatchSameContentAs, ComposePatterns (or, sequence),
#           AddBackReference (number), the five count forwards, Sequence and RepeatSequence (the
#           sequence knows its own fragment), Pattern / SubPattern / pvtBuildPattern of the recursive
#           maker, an unknown repeat kind, repeatedAtMost's count, one piece per Add call
# STUBS   : Quantifiers, QuantifiersCommands, QuantifiersXT -- nothing states what they return, so
#           the placeholder is kept and this guard pins that it answers an empty text
# DECISION: nested levels are written INSIDE the parent's group (the retired tests 27 and 31 say so;
#           the retired tests 17, 23, 24, 26, 28, 29 and 30 expect them flat)

Scenario("Counting the sequences, and the pieces")
	o1 = new stzRegexMaker
	Then("a new maker holds no sequence", o1.NumberOfSequences(), 0)
	o1.AddCharsRange("a-f", :repeatedExactly, 2, 0)
	o1.AddLiteral("-")
	o1.AddAmongChars("xyz", :repeatedAtLeast, 1, 0)
	Then("two ranges are two sequences", o1.NumberOfSequences(), 2)
	Then("the literal is a piece and not a sequence", o1.NumberOfFragements(), 3)
	Then("HowManySequences", o1.HowManySequences(), 2)
	Then("CountSequences", o1.CountSequences(), 2)
	Then("NumberOfSeqs", o1.NumberOfSeqs(), 2)
	Then("HowManySeqs", o1.HowManySeqs(), 2)
	Then("CountSeqs", o1.CountSeqs(), 2)
	Then("NumberOfCommands", o1.NumberOfCommands(), 2)
	Then("HowManyCommands", o1.HowManyCommands(), 2)
	Then("CountCommands", o1.CountCommands(), 2)
	Then("the correctly spelled NumberOfFragments works", o1.NumberOfFragments(), 3)
	Then("the misspelt NumberOfFragements is kept", o1.NumberOfFragements(), 3)
	Then("HowManyFragments", o1.HowManyFragments(), 3)
	Then("CountFragments", o1.CountFragments(), 3)
	Then("NumberOfFrags", o1.NumberOfFrags(), 3)
	Then("HowManyFrags", o1.HowManyFrags(), 3)
	Then("CountFrags", o1.CountFrags(), 3)
	Then("the two counts are not the same number", o1.NumberOfSequences() = o1.NumberOfFragments(), 0)
	o2 = new stzRegexMaker
	o2.AddLiteral("ab")
	Then("only literals: no sequence", o2.NumberOfSequences(), 0)
	Then("...and one piece", o2.NumberOfFragments(), 1)
EndScenario()

Scenario("Every Add call makes exactly one piece")
	o1 = new stzRegexMaker
	o1.DefineGroup("w", "\w+")
	Then("a named group is one piece", o1.NumberOfFragements(), 1)
	o1.AddBackReference("w")
	Then("a back reference by name is one piece", o1.NumberOfFragements(), 2)
	o1.AddBackReference(1)
	Then("a back reference by number is one piece", o1.NumberOfFragements(), 3)
	o1.AddCapturingGroup("n", "\d+")
	o1.AddMatchLength("a", :longest)
	o1.AddVariableLength("b", :lazy)
	o1.SetCaseXT(:insensitive, "Test")
	o1.AddComment("note")
	o1.ComposePatterns([ "x", "y" ], :and)
	o1.ComposePatterns([ "x", "y" ], :or)
	o1.ComposePatterns([ "x", "y" ], :sequence)
	Then("a group, two lengths, a case, a comment and three compositions are 8 more", o1.NumberOfFragements(), 11)
	Then("the third piece is the number reference with one backslash", o1.Fragment(3), char(92) + "1")
	Then("the first piece is the whole group", o1.Fragment(1), "(?P<w>\w+)")
	Then("the case piece holds the flag and the text", o1.Fragment(7), "(?i)Test")
EndScenario()

Scenario("A sequence knows its own piece, whatever sits around it")
	o1 = new stzRegexMaker
	o1.AddLiteral("x")
	o1.AddCharsRange("a-f", :repeatedExactly, 2, 0)
	o1.AddLiteral("-")
	o1.AddAmongChars("01", :repeatedAtLeast, 1, 0)
	Then("sequence 1 is the range", o1.Sequence(1)[2], "a-f")
	Then("SequenceXT(1) pairs it with ITS piece, not with the literal x", o1.SequenceXT(1)[2], "[a-f]{2}")
	Then("SequenceXT(2) pairs the second range with its piece", o1.SequenceXT(2)[2], "[01]{1,}")
	Then("SeqXT is the same call", o1.SeqXT(2)[2], "[01]{1,}")
	Then("CommandXT(1)", o1.CommandXT(1)[2], "[a-f]{2}")
	Then("CommandAndFragment(1)", o1.CommandAndFragment(1)[2], "[a-f]{2}")
	Then("CommandAndFrag(2)", o1.CommandAndFrag(2)[2], "[01]{1,}")
	Then("CommandAndItsFragment(1)", o1.CommandAndItsFragment(1)[2], "[a-f]{2}")
	Then("CommandAndItsFrag(2)", o1.CommandAndItsFrag(2)[2], "[01]{1,}")
	Then("the sequence half of the pair is the sequence", o1.CommandXT(2)[1][2], "01")
	Then("FragmentXT(2) is the range piece with its sequence", o1.FragmentXT(2)[2][2], "a-f")
	Then("FragmentXT(1) is the literal and has no sequence", len(o1.FragmentXT(1)[2]), 0)
	Then("FragmentXT(3) is the dash and has no sequence", len(o1.FragmentXT(3)[2]), 0)
	Then("FragmentsXT gives one pair per piece", len(o1.FragmentsXT()), 4)
	Then("...the second piece carries its own sequence", o1.FragmentsXT()[2][2][2], "a-f")
	Then("...the literal in front carries none", len(o1.FragmentsXT()[1][2]), 0)
	Then("SequencesXT gives one pair per sequence", len(o1.SequencesXT()), 2)
	Then("...the second pair holds the second range and ITS piece", o1.SequencesXT()[2][2], "[01]{1,}")
	Then("a position past the last sequence raises a plain message",
		StzFindFirst("No sequence 3", ErrOf(o1, "Sequence(3)")) > 0, 1)
	Then("position 0 raises it too", StzFindFirst("No sequence 0", ErrOf(o1, "Sequence(0)")) > 0, 1)
	Then("so does SequenceXT", StzFindFirst("No sequence 9", ErrOf(o1, "SequenceXT(9)")) > 0, 1)
	Then("a text for a position raises it", StzFindFirst("No sequence", ErrOf(o1, 'Sequence("a")')) > 0, 1)
	Then("a position inside the range raises nothing", ErrOf(o1, "Sequence(2)"), "")
	o2 = new stzRegexMaker
	o2.AddLiteral("ab")
	Then("only literals: Sequence(1) raises a plain message",
		StzFindFirst("No sequence 1", ErrOf(o2, "Sequence(1)")) > 0, 1)
	Then("only literals: RepeatSequence(1) raises it and adds nothing",
		StzFindFirst("No sequence 1", ErrOf(o2, "RepeatSequence(1)")) > 0, 1)
	Then("...the pattern is as it was", o2.Pattern(), "ab")
EndScenario()

Scenario("RepeatSequence repeats the piece the sequence made")
	o1 = new stzRegexMaker
	o1.AddLiteral("x")
	o1.AddCharsRange("a-f", :repeatedExactly, 2, 0)
	o1.RepeatSequence(1)
	Then("the range is repeated, not the literal in front of it", o1.Pattern(), "x[a-f]{2}[a-f]{2}")
	Then("the copy is a sequence of its own", o1.NumberOfSequences(), 2)
	o1.RepeatSequence(2)
	Then("and it can be repeated again", o1.Pattern(), "x[a-f]{2}[a-f]{2}[a-f]{2}")
	Then("it matches four hex letters after x", Fits(o1.Pattern(), "xabcdef"), 1)
	Then("...and not two", Fits(o1.Pattern(), "xab"), 0)
	o2 = new stzRegexMaker
	o2.AddCharsRange("0-9", :repeatedExactly, 1, 0)
	o2.AddLiteral("-")
	o2.RepeatCommand(1)
	Then("RepeatCommand is the same call", o2.Pattern(), "[0-9]{1}-[0-9]{1}")
	Then("it matches 4-7", Fits(o2.Pattern(), "4-7"), 1)
	Then("...and not 4-x", Fits(o2.Pattern(), "4-x"), 0)
EndScenario()

Scenario("A French registration number, in the named-parameter style (AB-123-CD)")
	o1 = new stzRegexMaker
	o1.CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
	o1.CanContainAChar(:Among = [ "-", " " ], :RepeatedAtMost = 1Time())
	o1.CanContainADigit(:From = [ "0", :To = "9" ], :RepeatedExactly = 3Times())
	o1.RepeatSequence(2)
	o1.RepeatSequence(1)
	Then("the pattern is the one the narration promises", o1.Pattern(), "[A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}")
	Then("AB-123-CD matches", Fits(o1.Pattern(), "AB-123-CD"), 1)
	Then("AB 123 CD matches", Fits(o1.Pattern(), "AB 123 CD"), 1)
	Then("AB123CD matches (the separators are optional)", Fits(o1.Pattern(), "AB123CD"), 1)
	Then("A-123-CD does not (one letter)", Fits(o1.Pattern(), "A-123-CD"), 0)
	Then("AB-12-CD does not (two digits)", Fits(o1.Pattern(), "AB-12-CD"), 0)
	Then("ab-123-cd does not (lower case)", Fits(o1.Pattern(), "ab-123-cd"), 0)
	Then("AB_123_CD does not (wrong separator)", Fits(o1.Pattern(), "AB_123_CD"), 0)
	Then("it was made of five pieces", o1.NumberOfFragements(), 5)
	Then("and three sequences made them first", o1.Sequence(3)[2], "0-9")
EndScenario()

Scenario("The named-parameter forms, one by one")
	o1 = new stzRegexMaker
	o1.CanContainAChar(:Between = "A-Z", 3)
	Then("Between with the text A-Z", o1.Pattern(), "[A-Z]{3}")
	Then("ABC matches", Fits(o1.Pattern(), "ABC"), 1)
	Then("AB1 does not", Fits(o1.Pattern(), "AB1"), 0)

	o2 = new stzRegexMaker
	o2.CanContainAChar(:From = [ "a", :To = "c" ], :RepeatedBetween = [ 1, 2 ])
	Then("From with a to-pair and a between-count", o2.Pattern(), "[a-c]{1,2}")
	Then("ab matches", Fits(o2.Pattern(), "ab"), 1)
	Then("abc does not (three)", Fits(o2.Pattern(), "abc"), 0)
	Then("d does not", Fits(o2.Pattern(), "d"), 0)

	o3 = new stzRegexMaker
	o3.CanContaingChar(:Among = "xy", :RepeatedSeveralTimes = 0)
	Then("the misspelt CanContaingChar is the same call", o3.Pattern(), "[xy]*")
	Then("xyyx matches", Fits(o3.Pattern(), "xyyx"), 1)
	Then("xz does not", Fits(o3.Pattern(), "xz"), 0)

	o4 = new stzRegexMaker
	o4.CanContainADigit(:Between = "0-4", 2)
	Then("digit Between with the text 0-4", o4.Pattern(), "[0-4]{2}")
	Then("31 matches", Fits(o4.Pattern(), "31"), 1)
	Then("35 does not", Fits(o4.Pattern(), "35"), 0)

	o5 = new stzRegexMaker
	o5.CanContaingdigit(:Among = "135", 3)
	Then("the misspelt CanContaingdigit is the same call", o5.Pattern(), "[135]{3}")
	Then("513 matches", Fits(o5.Pattern(), "513"), 1)
	Then("512 does not", Fits(o5.Pattern(), "512"), 0)

	o6 = new stzRegexMaker
	o6.CanContainADigit(:Among = [ 1, 3 ], :RepeatedAtLeast = 1)
	Then("digit Among with numbers in a list", o6.Pattern(), "[13]{1,}")
	Then("3131 matches", Fits(o6.Pattern(), "3131"), 1)
	Then("3132 does not", Fits(o6.Pattern(), "3132"), 0)

	Then("an unknown pair name raises Unknown class kind",
		StzFindFirst("Unknown class kind", ErrOf(o1, "CanContainAChar(:Zzz = 'A-Z', 2)")) > 0, 1)
	Then("...for digits too", StzFindFirst("Unknown class kind", ErrOf(o1, "CanContainADigit(:Zzz = '0-9', 2)")) > 0, 1)
	Then("a text for the pair raises Incorrect param type",
		StzFindFirst("Incorrect param type", ErrOf(o1, "CanContainAChar('A-Z', 2)")) > 0, 1)
	Then("a pair with one item raises Unknown class kind, not an index error",
		StzFindFirst("Unknown class kind", ErrOf(o1, "CanContainAChar([ 'between' ], 2)")) > 0, 1)
	Then("an empty list raises Unknown class kind",
		StzFindFirst("Unknown class kind", ErrOf(o1, "CanContainADigit([], 2)")) > 0, 1)
EndScenario()

Scenario("The text forms and the list forms of Between and Among")
	o1 = new stzRegexMaker
	o1.CanContainACharBetween("A-Z", 2)
	o1.CanContainACharBetween([ "a", "f" ], 1)
	o1.CanContainACharBetween([ "a", [ "to", "f" ] ], 1)
	Then("the text form, the plain list and the to-list give the same class",
		o1.Pattern(), "[A-Z]{2}[a-f]{1}[a-f]{1}")
	Then("two capitals and a hex letter match", Fits("[A-Z]{2}[a-f]{1}", "ABc"), 1)
	Then("...and ABg does not", Fits("[A-Z]{2}[a-f]{1}", "ABg"), 0)

	o2 = new stzRegexMaker
	o2.CanContainADigitBetween("0-9", 3)
	o2.CanContainADigitBetween([ 1, 5 ], 2)
	o2.CanContainADigitBetween([ "2", [ "and", "6" ] ], 1)
	Then("digit Between: text, numbers and an and-pair", o2.Pattern(), "[0-9]{3}[1-5]{2}[2-6]{1}")
	Then("990452 matches", Fits(o2.Pattern(), "990452"), 1)
	Then("...and 990652 does not (6 is outside 1-5)", Fits(o2.Pattern(), "990652"), 0)

	o3 = new stzRegexMaker
	o3.CanContainADigitAmong([ "1", "3" ], 2)
	o3.CanContainADigitAmong("579", 1)
	o3.CanContainDigitAmong([ 0, 2 ], 1)
	Then("digit Among: a list of texts, a text, a list of numbers", o3.Pattern(), "[13]{2}[579]{1}[02]{1}")
	Then("1392 matches", Fits(o3.Pattern(), "1392"), 1)
	Then("...and 1382 does not (8 is not in 579)", Fits(o3.Pattern(), "1382"), 0)

	Then("a letter in the digits raises Incorrect param type",
		StzFindFirst("Incorrect param type", ErrOf(o3, "CanContainADigitAmong('12a', 1)")) > 0, 1)
	Then("a two-digit item raises it", StzFindFirst("Incorrect param type", ErrOf(o3, "CanContainADigitAmong([ 12 ], 1)")) > 0, 1)
	Then("an empty list raises it", StzFindFirst("Incorrect param type", ErrOf(o3, "CanContainADigitAmong([], 1)")) > 0, 1)
	Then("a letter as the end of a digit range raises Can't proceed",
		StzFindFirst("two digits as chars", ErrOf(o3, "CanContainADigitBetween('0-z', 1)")) > 0, 1)
	Then("a text that is not X-Y raises Can't proceed for chars",
		StzFindFirst("two chars", ErrOf(o3, "CanContainACharBetween('AZ', 1)")) > 0, 1)
	Then("an item that is not a text raises it too",
		StzFindFirst("two chars", ErrOf(o3, "CanContainACharBetween([ 'A', [ 'B', 'C' ] ], 1)")) > 0, 1)
	Then("a failed call adds no piece", o3.NumberOfFragements(), 3)
EndScenario()

Scenario("Repeat kinds: none is dropped silently")
	o1 = new stzRegexMaker
	o1.AddRange(:among, "ab", :repeatedExactly, 3, 0)
	o1.AddRange(:among, "cd", :repeatedAtLeast, 2, 0)
	o1.AddRange(:among, "ef", :repeatedBetween, 1, 2)
	o1.AddRange(:among, "gh", :repeatedSeveralTimes, 0, 0)
	o1.AddRange(:among, "ij", :repeatedSeveral, 0, 0)
	Then("the five kinds write {n} {n,} {n,m} * *", o1.Pattern(), "[ab]{3}[cd]{2,}[ef]{1,2}[gh]*[ij]*")

	o2 = new stzRegexMaker
	o2.AddRange(:among, "ab", :repeatedAtMost, 1, 0)
	Then("repeatedAtMost with 1 is the optional mark", o2.Pattern(), "[ab]?")
	Then("it matches nothing", Fits(o2.Pattern(), ""), 1)
	Then("it matches one letter", Fits(o2.Pattern(), "a"), 1)
	Then("it does not match two", Fits(o2.Pattern(), "ab"), 0)

	o3 = new stzRegexMaker
	o3.AddRange(:among, "ab", :repeatedAtMost, 3, 0)
	Then("repeatedAtMost with 3 keeps the count", o3.Pattern(), "[ab]{0,3}")
	Then("it matches three letters", Fits(o3.Pattern(), "aba"), 1)
	Then("it does not match four", Fits(o3.Pattern(), "abab"), 0)
	Then("so 3 and 1 no longer give the same pattern", o3.Pattern() = o2.Pattern(), 0)

	o4 = new stzRegexMaker
	o4.AddLiteral("k")
	Then("an unknown kind raises Unknown repeat kind",
		StzFindFirst("Unknown repeat kind", ErrOf(o4, "AddRange(:among, 'ab', :zzz, 2, 0)")) > 0, 1)
	Then("...and adds no piece", o4.NumberOfFragements(), 1)
	Then("...and no sequence", o4.NumberOfSequences(), 0)
	Then("...and the pattern is as it was", o4.Pattern(), "k")
	Then("AddAmongChars raises it too",
		StzFindFirst("Unknown repeat kind", ErrOf(o4, "AddAmongChars('ab', :zzz, 2, 0)")) > 0, 1)
	Then("a named repeat the CanContain calls do not know raises it",
		StzFindFirst("Unknown repeat kind", ErrOf(o4, "CanContainACharBetween('A-Z', [ 'RepeatedZzz', 2 ])")) > 0, 1)
	Then("the misspelt RepeatdAtMost of the old comments raises it",
		StzFindFirst("Unknown repeat kind", ErrOf(o4, "CanContainACharAmong('ab', [ 'RepeatdAtMost', 1 ])")) > 0, 1)
	Then("a between with one count raises Incorrect param type",
		StzFindFirst("Incorrect param type", ErrOf(o4, "CanContainACharAmong('ab', [ 'RepeatedBetween', 2 ])")) > 0, 1)
	Then("a repeat that is a text raises Incorrect param type",
		StzFindFirst("Incorrect param type", ErrOf(o4, "CanContainACharAmong('ab', 'twice')")) > 0, 1)
	Then("nothing was added by all of those", o4.Pattern(), "k")

	o5 = new stzRegexMaker
	o5.CanContainACharAmong("ab", [ "RepeatedAtLeast", 2 ])
	o5.CanContainACharAmong("cd", [ "RepeatedSeveral", 0 ])
	Then("the CanContain calls accept repeatedAtLeast and repeatedSeveral", o5.Pattern(), "[ab]{2,}[cd]*")
EndScenario()

Scenario("The quantifier getters are placeholders and say so")
	o1 = new stzRegexMaker
	o1.AddCharsRange("a-f", :repeatedExactly, 2, 0)
	Then("Quantifiers answers an empty text", o1.Quantifiers(), "")
	Then("...it is a text", isString(o1.Quantifiers()), 1)
	Then("QuantifiersCommands answers an empty text", o1.QuantifiersCommands(), "")
	Then("QuantifiersXT answers an empty text", o1.QuantifiersXT(), "")
	Then("the quantifier is in the sequence all the same", o1.Sequence(1)[3], "repeatedexactly")
	Then("...with its count", o1.Sequence(1)[4], 2)
EndScenario()

Scenario("Back references")
	o1 = new stzRegexMaker
	o1.AddLiteral("(\w+)")
	o1.AddLiteral("-")
	o1.AddBackReference(1)
	Then("a number writes ONE backslash", o1.Pattern(), "(\w+)-" + char(92) + "1")
	Then("so the pattern has 8 characters, not 9", len(o1.Pattern()), 8)
	Then("a repeated word matches", Fits(o1.Pattern(), "abc-abc"), 1)
	Then("a different word does not", Fits(o1.Pattern(), "abc-abd"), 0)
	Then("a repeated non-ASCII word matches", Fits(o1.Pattern(), "été-été"), 1)
	Then("a different non-ASCII word does not", Fits(o1.Pattern(), "été-ete"), 0)

	o2 = new stzRegexMaker
	o2.AddBackReference(12)
	Then("a number above 9 is written as a g-reference", o2.Pattern(), char(92) + "g{12}")

	o3 = new stzRegexMaker
	o3.DefineGroup("w", "\w+")
	o3.AddLiteral("-")
	o3.AddBackReference("w")
	Then("a name writes (?P=name)", o3.Pattern(), "(?P<w>\w+)-(?P=w)")
	Then("the same word matches", Fits(o3.Pattern(), "cat-cat"), 1)
	Then("another word does not", Fits(o3.Pattern(), "cat-dog"), 0)
EndScenario()

Scenario("MatchSameContentAs: the same text as an earlier group")
	o1 = new stzRegexMaker
	o1.AddWordBoundary(:start)
	o1.DefineGroup("word", "\w+")
	o1.AddCharacterClass(:space)
	o1.MatchSameContentAs("word")
	o1.AddWordBoundary(:end)
	Then("the pattern is the narration's", o1.Pattern(), "\b(?P<word>\w+)[\s]*(?P=word)\b")
	Then("the the matches", Fits(o1.Pattern(), "the the"), 1)
	Then("hello hello matches", Fits(o1.Pattern(), "hello hello"), 1)
	Then("the that does not", Fits(o1.Pattern(), "the that"), 0)
	Then("a non-ASCII pair matches", Fits(o1.Pattern(), "été été"), 1)
	Then("a non-ASCII non-pair does not", Fits(o1.Pattern(), "été ete"), 0)
	Then("it finds a repeated word inside a sentence", Finds(o1.Pattern(), "I saw the the cat"), 1)
	Then("it finds nothing in a sentence with no repeat", Finds(o1.Pattern(), "I saw the black cat"), 0)
	Then("an unknown group raises No group named",
		StzFindFirst("No group named", ErrOf(o1, "MatchSameContentAs('zzz')")) > 0, 1)
	Then("...and adds nothing", o1.NumberOfFragements(), 5)

	o2 = new stzRegexMaker
	o2.AddLiteral("<")
	o2.DefineGroup("tag", "[a-z]+")
	o2.AddLiteral(">.*?")
	o2.MatchOppositeTagAs("tag")
	Then("its sibling MatchOppositeTagAs still writes the closing tag", o2.Pattern(), "<(?P<tag>[a-z]+)>.*?</(?P=tag)>")
	Then("<b>x</b> matches", Fits(o2.Pattern(), "<b>x</b>"), 1)
	Then("<b>x</i> does not", Fits(o2.Pattern(), "<b>x</i>"), 0)
EndScenario()

Scenario("ComposePatterns: and, or, sequence")
	o1 = new stzRegexMaker
	o1.AddLiteral("^")
	o1.ComposePatterns([ ".*\d", ".*[A-Z]" ], :and)
	o1.AddLiteral(".+")
	Then("and writes look-aheads", o1.Pattern(), "^(?=.*\d)(?=.*[A-Z]).+")
	Then("ab3Cd has a digit and a capital", Fits(o1.Pattern(), "ab3Cd"), 1)
	Then("abcd has neither", Fits(o1.Pattern(), "abcd"), 0)
	Then("ab3d has no capital", Fits(o1.Pattern(), "ab3d"), 0)

	o2 = new stzRegexMaker
	o2.ComposePatterns([ "cat", "dog" ], :or)
	Then("or writes alternatives", o2.Pattern(), "(cat|dog)")
	Then("dog matches", Fits(o2.Pattern(), "dog"), 1)
	Then("cat matches", Fits(o2.Pattern(), "cat"), 1)
	Then("cow does not", Fits(o2.Pattern(), "cow"), 0)

	o3 = new stzRegexMaker
	o3.ComposePatterns([ "cat", "dog", "emu" ], :or)
	Then("or with three patterns", o3.Pattern(), "(cat|dog|emu)")
	Then("emu matches", Fits(o3.Pattern(), "emu"), 1)

	o4 = new stzRegexMaker
	o4.ComposePatterns([ "ab", "[0-9]+", "z" ], :sequence)
	Then("sequence writes them one after the other", o4.Pattern(), "ab[0-9]+z")
	Then("ab42z matches", Fits(o4.Pattern(), "ab42z"), 1)
	Then("abz does not", Fits(o4.Pattern(), "abz"), 0)

	o5 = new stzRegexMaker
	o5.ComposePatterns([ "é", "ü" ], :or)
	Then("an or of non-ASCII patterns", Fits(o5.Pattern(), "ü"), 1)
	Then("...does not match a letter outside it", Fits(o5.Pattern(), "u"), 0)

	o6 = new stzRegexMaker
	o6.ComposePatterns([ "a", "b" ], :zzz)
	Then("an unknown mode still adds nothing", o6.NumberOfFragements(), 0)
	Then("each composition adds one piece", o4.NumberOfFragements(), 1)
EndScenario()

Scenario("A date and an e-mail-like address, built and matched")
	o1 = new stzRegexMaker
	o1.CanContainADigit(:From = [ "0", :To = "9" ], :RepeatedExactly = NTimes(4))
	o1.AddLiteral("-")
	o1.CanContainADigit(:From = [ "0", :To = "1" ], 1)
	o1.CanContainADigit(:From = [ "0", :To = "9" ], 1)
	o1.AddLiteral("-")
	o1.AddDigitsRange("0-9", :repeatedExactly, 2, 0)
	Then("the date pattern", o1.Pattern(), "[0-9]{4}-[0-1]{1}[0-9]{1}-[0-9]{2}")
	Then("2026-10-16 matches", Fits(o1.Pattern(), "2026-10-16"), 1)
	Then("2026-1-16 does not", Fits(o1.Pattern(), "2026-1-16"), 0)
	Then("16/10/2026 does not", Fits(o1.Pattern(), "16/10/2026"), 0)
	Then("it finds a date inside a sentence", Finds(o1.Pattern(), "due on 2026-10-16 at noon"), 1)

	o2 = new stzRegexMaker
	o2.AddCharsRange("a-z", :repeatedAtLeast, 1, 0)
	o2.AddLiteral("@")
	o2.AddCharsRange("a-z", :repeatedAtLeast, 1, 0)
	o2.AddLiteral(char(92) + ".")
	o2.AddCharsRange("a-z", :repeatedBetween, 2, 4)
	Then("the e-mail-like pattern", o2.Pattern(), "[a-z]{1,}@[a-z]{1,}" + char(92) + ".[a-z]{2,4}")
	Then("bob@site.com matches", Fits(o2.Pattern(), "bob@site.com"), 1)
	Then("bob@site does not", Fits(o2.Pattern(), "bob@site"), 0)
	Then("bob@site.c does not (one letter after the dot)", Fits(o2.Pattern(), "bob@site.c"), 0)
	Then("bob@site.company does not (more than four)", Fits(o2.Pattern(), "bob@site.company"), 0)
	Then("a non-ASCII local part does not match a-z", Fits(o2.Pattern(), "bé@site.com"), 0)

	o3 = new stzRegexMaker
	o3.CanContainACharBetween("α-ω", 3)
	o3.CanContainACharAmong("éè", 1)
	Then("a Greek range and a French pair", Fits(o3.Pattern(), "αβγé"), 1)
	Then("...the other French letter", Fits(o3.Pattern(), "ωωωè"), 1)
	Then("...Latin letters do not match the Greek range", Fits(o3.Pattern(), "abcé"), 0)
	Then("...and e is not in the French pair", Fits(o3.Pattern(), "αβγe"), 0)
	Then("the Greek range has the two end letters", o3.Sequence(1)[2], "α-ω")
EndScenario()

Scenario("The recursive maker: levels joined into one pattern")
	o1 = new stzRecursiveRegexMaker()
	Then("no level gives an empty pattern", o1.Pattern(), "")
	o1.AddLevel("simple", "abc")
	Then("one level is one named group", o1.Pattern(), "(?P<simple>abc)")
	Then("it matches abc", Fits(o1.Pattern(), "abc"), 1)
	Then("it does not match abd", Fits(o1.Pattern(), "abd"), 0)
	o1.AddLevel("second", "def")
	Then("two levels are two groups side by side", o1.Pattern(), "(?P<simple>abc)(?P<second>def)")
	Then("abcdef matches", Fits(o1.Pattern(), "abcdef"), 1)
	Then("abc does not", Fits(o1.Pattern(), "abc"), 0)

	o2 = new stzRecursiveRegexMaker()
	o2.AddLevel("open", "\(")
	o2.AddChildLevel("open", "inner", "[^()]*")
	o2.AddLevel("close", "\)")
	Then("a child sits inside its parent's group and close is bare",
		o2.Pattern(), "(?P<open>\((?P<inner>[^()]*))\)")
	Then("(abc) matches", Fits(o2.Pattern(), "(abc)"), 1)
	Then("() matches (the inner part may be empty)", Fits(o2.Pattern(), "()"), 1)
	Then("(abc does not", Fits(o2.Pattern(), "(abc"), 0)
	Then("(a(b)) does not (one level only)", Fits(o2.Pattern(), "(a(b))"), 0)
	Then("SubPattern of the parent is its group", o2.SubPattern("open"), "(?P<open>\((?P<inner>[^()]*))")
	Then("SubPattern of the child is its group", o2.SubPattern("inner"), "(?P<inner>[^()]*)")
	Then("SubPattern of the close level is its bare pattern", o2.SubPattern("close"), "\)")
	Then("SubPattern of an unknown level is empty", o2.SubPattern("zzz"), "")
	o2.AddQuantifier("inner", "+")
	Then("a quantifier follows the group of its level", o2.Pattern(), "(?P<open>\((?P<inner>[^()]*)+)\)")
	Then("it still matches (abc)", Fits(o2.Pattern(), "(abc)"), 1)

	o3 = new stzRecursiveRegexMaker
	o3.AddLevel("x", "a")
	Then("named recursion is on without parentheses on new", o3.Pattern(), "(?P<x>a)")
	o3.DisableNamedRecursion()
	Then("DisableNamedRecursion writes the bare pattern", o3.Pattern(), "a")
	o3.EnableNamedRecursion()
	Then("EnableNamedRecursion writes the group again", o3.Pattern(), "(?P<x>a)")
	o3.Reset()
	o3.AddLevel("x", "a")
	Then("after Reset the recursion is off", o3.Pattern(), "a")
EndScenario()

Scenario("The recursive maker: the nested JSON-like object of the retired tests")
	o1 = new stzRecursiveRegexMaker()
	o1.EnableNamedRecursion()
	o1.AddLevel("object", "\{")
	o1.AddChildLevel("object", "key", '"[^"]+"\s*:\s*')
	o1.AddChildLevel("key", "value", '[^,}]+')
	o1.AddChildLevel("object", "comma", ",\s*")
	o1.AddLevel("close", "\}")
	o1.AddQuantifier("key", "+")
	o1.AddQuantifier("comma", "*")
	Then("the pattern is the one the retired tests 27 and 31 expect",
		o1.Pattern(), '(?P<object>\{(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+(?P<comma>,\s*)*)\}')
	Then("a single pair matches", Fits(o1.Pattern(), '{"a": 1}'), 1)
	Then("a trailing comma matches", Fits(o1.Pattern(), '{"a": 1, }'), 1)
	Then("a non-ASCII key matches", Fits(o1.Pattern(), '{"clé": 1}'), 1)
	Then("an unquoted key does not", Fits(o1.Pattern(), '{a: 1}'), 0)
	Then("a missing brace does not", Fits(o1.Pattern(), '{"a": 1'), 0)
	Then("the levels are listed in order", o1.LevelNames()[3], "value")
	Then("the object has two children", len(o1.LevelChildren("object")), 2)
	Then("the key level holds its quantifier", o1.Info()[2][:quantifier], "+")
	Then("SubPattern of the key level carries the value inside it",
		o1.SubPattern("key"), '(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+')
EndScenario()

Scenario("The recursive maker: balanced parentheses through a self-reference")
	o1 = new stzRecursiveRegexMaker()
	o1.AddLevel("expr", "\((?:[^()]|(?P>expr))*\)")
	Then("the pattern names the group the text refers to", o1.Pattern(), "(?P<expr>\((?:[^()]|(?P>expr))*\))")
	Then("(a(b)(c(d))) is balanced", Fits(o1.Pattern(), "(a(b)(c(d)))"), 1)
	Then("() is balanced", Fits(o1.Pattern(), "()"), 1)
	Then("(a(b)(c(d)) is not (one closer missing)", Fits(o1.Pattern(), "(a(b)(c(d))"), 0)
	Then("(a)) is not", Fits(o1.Pattern(), "(a))"), 0)
	Then("a non-ASCII content is balanced too", Fits(o1.Pattern(), "(é(ü)ß)"), 1)
	Then("...and a broken one is not", Fits(o1.Pattern(), "(é(ü ß)"), 0)
	Then("it finds the balanced part inside a sentence", Finds(o1.Pattern(), "call f(x, g(y)) now"), 1)
	Then("it finds nothing without parentheses", Finds(o1.Pattern(), "call f now"), 0)
EndScenario()

Summary()

func Fits(cPattern, cText)
	oRegex = new stzRegex(cPattern)
	return oRegex.Match(cText)

func Finds(cPattern, cText)
	oRegex = new stzRegex(cPattern)
	return oRegex.MatchFirst(cText)

func ErrOf(oMaker, cBody)
	try
		eval("xRes = oMaker." + cBody)
	catch
		return cCatchError
	done
	return ""
