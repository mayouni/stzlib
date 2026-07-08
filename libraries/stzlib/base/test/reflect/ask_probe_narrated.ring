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
		TopHitIsOneOf(o, "who is mentioned in this", ["PersonNames","NamedEntities","Entities"]), TRUE)
	Then("'find people and places'",
		TopHitIsOneOf(o, "find people and places", ["NamedEntities","PersonNames","Locations","Entities"]), TRUE)
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
		TopHitIsOneOf(o, "nouns and verbs in the text", ["Nouns","NounsQ","Verbs","VerbsQ","WordsThatAre"]), TRUE)
	Then("'how hard is this to read'",
		TopHitIsOneOf(o, "how hard is this to read", ["ReadabilityGrade","ReadingEase","FleschKincaidGrade","FleschReadingEase"]), TRUE)
	Then("'which language is this written in'",
		TopHitIsOneOf(o, "which language is this written in", ["Language","DetectedLanguage"]), TRUE)
EndScenario()

# TRUE if Ask's top-1 method for cQuery is one of the acceptable answers (a
# capability often has an alias/Q-variant family, all correct).
func TopHitIsOneOf(oDoc, cQuery, aAcceptable)
	aR = oDoc.AskFor(cQuery, 1)
	if len(aR) = 0 return FALSE ok
	return ring_find(aAcceptable, aR[1][1]) > 0
