load "../../stzBase.ring"
load "../_narrated.ring"

# ASK-PROBE -- the natural-language QUALITY guardrail (info-tagging strategy S.6).
# Fixed intent -> expected-method pairs, asserted against the ZERO-SETUP lexical
# path (no neural model loaded). This makes NL retrieval quality a regression-
# guarded number: any change to the harvester tags, the #@ InfoTags, or the
# lexical scorer that breaks a known intent fails here. Each intent phrases the
# task in USER words -- often avoiding the method name on purpose, so the pairs
# exercise section tags + intent lines + #@ aka, not just camel-split matching.
# A neural model only sharpens these, so passing under lexical is the hard floor.

o = new stzSelfDoc("stzText")
oStr = new stzSelfDoc("stzString")

Scenario("Sentiment intents (mood/tone/emotion -- name is 'Sentiment')")
	Then("'what is the mood of this'",
		TopHitIsOneOf(o, "what is the mood of this", ["Sentiment"]), TRUE)
	Then("'the emotion expressed here'",
		TopHitIsOneOf(o, "the emotion expressed here", ["Sentiment"]), TRUE)
	Then("'how positive or negative is the tone'",
		TopHitIsOneOf(o, "how positive or negative is the tone", ["Sentiment","IsPositive","IsNegative","SentimentScore"]), TRUE)
EndScenario()

Scenario("Entity intents (who/where -- name is 'NamedEntities'/'PersonNames')")
	Then("'who is mentioned in this'",
		TopHitIsOneOf(o, "who is mentioned in this", ["PersonNames","NamedEntities","Entities","Organizations","Locations","EntitiesOfType"]), TRUE)
	Then("'find people and places'",
		TopHitIsOneOf(o, "find people and places", ["NamedEntities","PersonNames","Locations","Entities","Organizations","EntitiesOfType"]), TRUE)
EndScenario()

Scenario("Word-normalization intents (base/root form)")
	Then("'reduce words to base form'",
		TopHitIsOneOf(o, "reduce words to base form", ["Lemmatized","Lemma","LemmatizedWords","WordsLemmatized"]), TRUE)
	Then("'root form of each word'",
		TopHitIsOneOf(o, "root form of each word", ["Stemmed","Stem","StemmedWords","Lemmatized","Lemma"]), TRUE)
EndScenario()

Scenario("Topic + keyword + summary intents")
	Then("'what are the main topics'",
		TopHitIsOneOf(o, "what are the main topics", ["KeyPhrases","TopKeyPhrase","KeyPhrasesXT"]), TRUE)
	Then("'summarize briefly'",
		TopHitIsOneOf(o, "summarize briefly", ["SummarizedIn","Summary","SummarySentences"]), TRUE)
	Then("'words with similar meaning'",
		TopHitIsOneOf(o, "words with similar meaning", ["Synonyms","SynonymsQ","SynonymsQQ"]), TRUE)
EndScenario()

Scenario("Part-of-speech + readability + language intents")
	Then("'nouns and verbs in the text'",
		TopHitIsOneOf(o, "nouns and verbs in the text", ["Nouns","NounsQ","ProperNouns","Verbs","VerbsQ","Adjectives","WordsThatAre"]), TRUE)
	Then("'how hard is this to read'",
		TopHitIsOneOf(o, "how hard is this to read", ["ReadabilityGrade","ReadingEase","FleschKincaidGrade","FleschReadingEase"]), TRUE)
	Then("'which language is this written in'",
		TopHitIsOneOf(o, "which language is this written in", ["Language","DetectedLanguage"]), TRUE)
EndScenario()

# stzString flagship intents (grind-complete module; L1 intent + L2 aka tagged).
# User words that avoid the method name: capitals->Uppercased, reverse->Reversed.
Scenario("stzString flagship intents resolve to the canonical method")
	Then("'convert to capitals' -> Uppercased",
		TopHitIsOneOf(oStr, "convert to capitals", ["Uppercase","Uppercased"]), TRUE)
	Then("'make it lower case' -> active Lowercase (imperative)",
		TopHitIsOneOf(oStr, "make it lower case", ["Lowercase"]), TRUE)
	Then("'reverse the characters' -> active Reverse (imperative)",
		TopHitIsOneOf(oStr, "reverse the characters", ["Reverse"]), TRUE)
	Then("'split on a delimiter' -> Split",
		TopHitIsOneOf(oStr, "split on a delimiter", ["Split"]), TRUE)
	Then("'remove surrounding spaces' -> active Trim (imperative; aka via sibling)",
		TopHitIsOneOf(oStr, "remove surrounding spaces", ["Trim"]), TRUE)
	Then("'does it contain a word' -> Contains",
		TopHitIsOneOf(oStr, "does it contain a word", ["Contains"]), TRUE)
EndScenario()

# FUNCTION-FORM awareness (Softanza's active/passive/fluent distinction, read off
# the method NAME by design): a bare intent defaults to the non-destructive PASSIVE
# form; a mutate cue routes to the ACTIVE form; a chain cue routes to the FLUENT (Q)
# form. Same operation, three forms, routed by intent.
Scenario("Function-form awareness routes intent to the right form")
	Then("'reverse the string' -> active Reverse (imperative default)",
		TopHitIsOneOf(oStr, "reverse the string", ["Reverse"]), TRUE)
	Then("'return a reversed copy of the string' -> passive Reversed (asked for)",
		TopHitIsOneOf(oStr, "return a reversed copy of the string", ["Reversed"]), TRUE)
	Then("'an uppercase copy of the text' -> passive Uppercased",
		TopHitIsOneOf(oStr, "an uppercase copy of the text", ["Uppercased"]), TRUE)
	Then("Explain teaches the passive form",
		substr(oStr.ExplainMethod("Reversed"), "passive form") > 0, TRUE)
EndScenario()

# Conversational layer: "how do I X" intents should surface an intent RECIPE (a
# runnable snippet), not just a method name -- across the stzLibDoc union index.
oLib = StzLibDoc([ "stzText", "stzListOfTexts" ])

Scenario("Conversational intents surface a runnable recipe")
	Then("recipes are loaded into the union index",
		oLib.NumberOfRecipes() >= 19, TRUE)
	Then("class count excludes recipes (stays at owners)",
		oLib.NumberOfClasses(), 4)
	Then("'how do I detect the mood of a paragraph' -> recipe",
		LibTopIsRecipe(oLib, "how do I detect the mood of a paragraph"), TRUE)
	Then("'get the people and places from text' -> recipe",
		LibTopIsRecipe(oLib, "get the people and places from text"), TRUE)
	Then("'shorten a long text' -> recipe",
		LibTopIsRecipe(oLib, "shorten a long text"), TRUE)
EndScenario()

Scenario("Cross-domain recipes (string / list / number) are retrievable")
	Then("'make text uppercase' -> recipe",
		LibTopIsRecipe(oLib, "make text uppercase"), TRUE)
	Then("'remove duplicate items from a list' -> recipe",
		LibTopIsRecipe(oLib, "remove duplicate items from a list"), TRUE)
	Then("'sort these numbers' -> recipe",
		LibTopIsRecipe(oLib, "sort these numbers"), TRUE)
	Then("'check if a number is prime' -> recipe",
		LibTopIsRecipe(oLib, "check if a number is prime"), TRUE)
	Then("'split a string on commas' -> recipe",
		LibTopIsRecipe(oLib, "split a string on commas"), TRUE)
	Then("'find all divisors of a number' -> recipe",
		LibTopIsRecipe(oLib, "find all divisors of a number"), TRUE)
EndScenario()

# TRUE if Ask's top-1 method for cQuery is one of the acceptable answers (a
# capability often has an alias/Q-variant family, all correct).
func TopHitIsOneOf(oDoc, cQuery, aAcceptable)
	aR = oDoc.AskFor(cQuery, 1)
	if len(aR) = 0 return FALSE ok
	return ring_find(aAcceptable, aR[1][1]) > 0

# TRUE if the stzLibDoc top-1 for cQuery is an intent recipe (kind "(recipe)").
func LibTopIsRecipe(oLib, cQuery)
	aR = oLib.AskFor(cQuery, 1)
	if len(aR) = 0 return FALSE ok
	return aR[1][1] = "(recipe)"
