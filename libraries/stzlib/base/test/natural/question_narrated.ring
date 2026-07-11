# Narrative
# --------
# ILLOCUTIONARY FORCE (Q1 of the coverage plan, the author's stzQuestion
# design): a sentence-initial force word opens a FRAME; particles stand
# alone (TheQ -- one word, one method, never fused into TheLengthQ);
# lexicon-generated nouns fill constituent slots; and the first PLAIN-form
# word closes the frame and returns the answer as DATA -- the house
# Q-convention applied to interrogation.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("WH-questions: the answer is the missing constituent")
	Given("two grammatical orderings, two closers -- Of(...) and Is()")
	Then("'What is the first char of Ring' (closes at Of)",
		WhatIsQ().TheQ().FirstCharQ().Of("Ring"), "R")
	Then("'What the first char of Ring is' (closes at Is)",
		WhatQ().TheQ().FirstCharQ().OfQ("Ring").Is(), "R")
	Then("a WH-answer can be a LIST (data, per the Q-convention)",
		@@( WhatQ().TheQ().VowelsQ().OfQ("AnnIE").Is() ),
		'[ "A", "I", "E" ]')
EndScenario()

Scenario("HowMany: counting questions prefer the NumberOf twin")
	Then("'How many vowels of Ring'", HowManyQ().VowelsQ().Of("Ring"), 1)
	Then("'How many words of hello brave world'",
		HowManyQ().WordsQ().Of("hello brave world"), 3)
EndScenario()

Scenario("The nominal count and the locative preposition (author's addition)")
	Given("'the number of letters IN ring' -- In/InQ beside Of/OfQ, NumberOfQ as opener AND as constituent word")
	Then("NumberOfQ().LettersQ().In('ring')",
		NumberOfQ().LettersQ().In("ring"), 4)
	Then("TheNumberOfQ variant reads with its article",
		TheNumberOfQ().WordsQ().In("hello brave world"), 3)
	Then("In() closes any frame, like Of()",
		WhatIsQ().TheQ().FirstCharQ().In("Ring"), "R")
	Then("'the number of letters' as a COMPARISON constituent",
		IsQ().TheQ().NumberOfQ().LettersQ().OfQ("Ring").
			TheSameAsQ().TheQ().NumberOfQ().LettersQ().In("Ruby"), 1)
EndScenario()

Scenario("Polar comparison: two computed constituents, one verdict")
	Given("the author's canonical question, decomposed per the one-word-one-method law")
	Then("'Is the length of Ring the same as the length of Ruby?'",
		IsQ().TheQ().LengthQ().OfQ("Ring").
			TheSameAsQ().TheQ().LengthQ().Of("Ruby"), 1)
	Then("...and the answer explains itself",
		Why(), "yes: 4 is the same as 4")

	Then("'Is the length of softanza more than the length of Ring?'",
		IsQ().TheQ().LengthQ().OfQ("softanza").
			MoreThanQ().TheQ().LengthQ().Of("Ring"), 1)
	Then("'...less than...' answers no honestly",
		IsQ().TheQ().LengthQ().OfQ("softanza").
			LessThanQ().TheQ().LengthQ().Of("Ring"), 0)
	Then("...with the reason", Why(), "no: 8 is not less than 4")

	# DIFFERENT aspects on the two sides
	Then("'Is the vowel count of Ring different from the word count of hi there?'",
		IsQ().TheQ().NumberOfVowelsQ().OfQ("Ring").
			DifferentFromQ().TheQ().NumberOfWordsQ().Of("hi there"), 1)
EndScenario()

Scenario("Q3 corrected: the tag question and the antonym (author's ruling)")
	Given("English does not say 'is X is not the same as Y' -- negation lives in ANTONYM comparators (DifferentFromQ), negative FORMS, and the TAG '..., or not?' (OrNot, plain because it answers)")

	Then("'Is the length of Ring the same as the length of Ruby, or not?'",
		IsQ().TheQ().LengthQ().OfQ("Ring").
			TheSameAsQ().TheQ().LengthQ().OfQ("Ruby").OrNot(), 1)
	Then("...the tag does not negate; the answer explains",
		Why(), "yes: 4 is the same as 4")
	Then("the tag answers no when lengths differ",
		IsQ().TheQ().LengthQ().OfQ("Ring").
			TheSameAsQ().TheQ().LengthQ().OfQ("softanza").OrNot(), 0)
	Then("negation-proper IS the antonym: 'different from'",
		IsQ().TheQ().LengthQ().OfQ("Ring").
			DifferentFromQ().TheQ().LengthQ().Of("softanza"), 1)
EndScenario()

Scenario("The frame is accountable like everything else")
	bRefused = FALSE
	try
		WhatIsQ().TheQ().Of("Ring")   # no noun was named
	catch
		bRefused = TRUE
	done
	Then("a question without an aspect refuses", bRefused, TRUE)

	bRefused2 = FALSE
	try
		WhatIsQ().TheQ().VowelsQ().Of(42)   # numbers have no vowels
	catch
		bRefused2 = TRUE
	done
	Then("an aspect the host cannot answer refuses (dispatcher)",
		bRefused2, TRUE)
EndScenario()

Summary()
