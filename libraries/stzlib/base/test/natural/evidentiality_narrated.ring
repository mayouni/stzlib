# Narrative
# --------
# EVIDENTIALITY -- the LAST row of the NNL coverage map: natural language
# marks not only WHAT is true but HOW CONFIDENTLY the speaker knows it.
# Every verdict now carries its confidence in the evidential register:
# deterministic checks answer CERTAINLY (1); the semantic verdicts
# (similarity, zero-shot, sentiment) carry their graded score -- neural
# when a model is loaded, honest lexical evidence otherwise. The adverb
# bands: >= 0.85 certainly, >= 0.60 probably, else apparently.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The evidential bands verbalize a verdict")
	Then("strong evidence", StzEvidentialVerdict(1, 0.95), "certainly yes")
	Then("good evidence", StzEvidentialVerdict(1, 0.7), "probably yes")
	Then("weak evidence", StzEvidentialVerdict(1, 0.3), "apparently yes")
	Then("strong evidence AGAINST", StzEvidentialVerdict(0, 0.9), "certainly not")
EndScenario()

Scenario("Deterministic verdicts are CERTAIN")
	IsQ().TheQ().LengthQ().Of("Ring")
	Then("a computed frame answer", Certainty(), 1)
	Then("...", Evidentially(), "certainly")
EndScenario()

Scenario("Semantic similarity carries graded evidence")
	oT = Q("cats are wonderful pets").TextQ()
	Then("a close paraphrase is PROBABLY similar",
		oT.IsSemanticallySimilarTo("dogs are wonderful pets", 0.5), TRUE)
	Then("...", Evidentially(), "probably")
	Then("...", Why(),
		'probably yes: semantically similar to "dogs are wonderful pets"')

	Then("an unrelated text is CERTAINLY not",
		Q("the stock market crashed").TextQ().IsSemanticallySimilarTo("kittens love to play", 0.5), FALSE)
	Then("...", Why(),
		'certainly not: semantically similar to "kittens love to play"')
EndScenario()

Scenario("Zero-shot labels carry their confidence -- honestly")
	c = Q("the team won the championship game").TextQ().ClassifiedAs([ "sports", "cooking", "finance" ])
	Then("lexically there is NO evidence for any label, and the register says so",
		Evidentially(), "apparently")
	Given("with a neural model loaded, the same call grades up to probably/certainly by MEANING")
EndScenario()

Scenario("Sentiment verdicts carry the strength of the tone")
	Then("an emphatic praise is CERTAINLY positive",
		Q("I absolutely love this wonderful amazing library!").TextQ().IsPositive(), TRUE)
	Then("...", Evidentially(), "certainly")
	Then("...", Why(), "certainly yes: positive in tone")

	Then("a neutral statement is only APPARENTLY not positive",
		Q("The sky is blue.").TextQ().IsPositive(), FALSE)
	Then("...", Evidentially(), "apparently")
	Then("...", Why(), "apparently not: positive in tone")
EndScenario()

Summary()
