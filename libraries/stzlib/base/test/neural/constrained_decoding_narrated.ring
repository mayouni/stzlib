# CONSTRAINED DECODING -- the rung that makes a violating token UNEMITTABLE
#
# stzOutputSchema declares a structure and CHECKS what the model said.
# schema_gbnf compiles the same declaration into a grammar. This guard is
# about the third rung: engine/src/gbnf_machine.zig, a GBNF stack machine
# that judges every candidate token at the sampler, so a token whose bytes
# cannot continue the grammar is never drawn.
#
# WHY IT WAS BUILT, MEASURED rather than assumed. Against the model this
# repository ships (smollm2-135m-instruct-q8_0), ten structured prompts
# (base/test/neural/_measure_structured.ring):
#
#                              checked afterwards    constrained
#     first attempt valid          2 / 10             10 / 10
#     attempts per valid answer      5.0                 1.0
#     never valid at all           4 / 10              0 / 10
#
# WHAT THIS GUARD PROVES BY REFUSAL, NOT BY SUCCESS. Every scene that
# claims enforcement also shows the thing that CANNOT happen. Scene 6 is
# the one that matters most: it shows what a grammar does NOT constrain,
# so nobody reads "constrained" as "correct".
#
# Scenes 1-6 need NO model: the machine is the engine's, and asking it
# whether text satisfies a grammar needs no vocabulary. Scenes 7-8 need a
# generative GGUF and say so when there is none.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

#=====================================================================#
? "-- Scene 1: the build says which rung you got, and what it covers --"
#=====================================================================#
# A compiled grammar and a constrained sampler are two different things.
# This surface answered 0 for as long as only the first existed.

chk("this build enforces a grammar at the sampler",
	StzConstrainedDecodingSupported() = 1)

cSt = StzConstrainedDecodingStatus()
chk("...and says a violating token is UNEMITTABLE, not caught afterwards",
	len(StzFind("unemittable", cSt)) > 0)
chk("...names the prefix case a stack machine has to get right",
	len(StzFind("valid PREFIX and an invalid completion", cSt)) > 0)
chk("...and states the coverage in the same breath as the claim",
	len(StzFind("never VALUE and never TRUTH", cSt)) > 0)

? ""
#=====================================================================#
? "-- Scene 2: the machine walks a grammar one byte at a time --"
#=====================================================================#

cG = 'root ::= "mood: " ("positive" | "negative") "\n"'

chk("a complete sentence of the grammar is accepted",
	StzGrammarAccepts(cG, "mood: positive" + char(10)) = 1)
chk("...and so is the other branch",
	StzGrammarAccepts(cG, "mood: negative" + char(10)) = 1)
chk("a word outside the closed set is refused",
	StzGrammarAccepts(cG, "mood: delighted" + char(10)) = 0)

# A legal PREFIX is not a legal sentence, and the two questions are
# different questions -- the sampler asks the first at every token and
# the second only at the end.
chk("a legal prefix could still continue",
	StzGrammarCouldContinue(cG, "mood: pos") = 1)
chk("...but it is NOT accepted as a whole answer",
	StzGrammarAccepts(cG, "mood: pos") = 0)

? ""
#=====================================================================#
? "-- Scene 3: the case a byte-at-a-time check gets wrong --"
#=====================================================================#
# THE ONE THE PROMPT NAMES. A token is not a byte. Given `root ::= "yes"`,
# the vocabulary token `yesterday` opens with three bytes the grammar
# takes and dies on the fourth. A check that only asked about the FIRST
# byte would emit it and produce text the grammar forbids -- so the whole
# piece is fed, and the machine must survive to its last byte.

cY = 'root ::= "yes" "\n"'

chk("the prefix 'yes' is legal so far", StzGrammarCouldContinue(cY, "yes") = 1)
chk("the prefix 'ye' is legal so far", StzGrammarCouldContinue(cY, "ye") = 1)
chk("'yesterday' is REFUSED -- valid as a prefix, invalid as a completion",
	StzGrammarCouldContinue(cY, "yesterday") = 0)
chk("'yes!' is refused for the same reason",
	StzGrammarCouldContinue(cY, "yes!") = 0)
chk("and the first byte alone would have said yes to both",
	StzGrammarCouldContinue(cY, "y") = 1)

? ""
#=====================================================================#
? "-- Scene 4: the exact failure the measurement found --"
#=====================================================================#
# The schema said `founded` was a number and the model wrote `<number>`.
# Under the grammar that answer has no path: after "founded: " the only
# legal bytes are a sign or a digit.

oS = StzOutputSchemaQ([
	[ :field = "city",    :type = :string ],
	[ :field = "founded", :type = :number ]
])
cSchemaG = oS.ToGBNF()

chk("a well-formed memo satisfies the compiled grammar",
	StzGrammarAccepts(cSchemaG, "city: Paris" + char(10) + "founded: 52" + char(10)) = 1)
chk("the placeholder the model actually wrote cannot be reached",
	StzGrammarCouldContinue(cSchemaG, "city: Paris" + char(10) + "founded: <") = 0)
chk("...nor a word where a number belongs",
	StzGrammarCouldContinue(cSchemaG, "city: Paris" + char(10) + "founded: unknown") = 0)
chk("...while a negative number is fine",
	StzGrammarCouldContinue(cSchemaG, "city: Paris" + char(10) + "founded: -52") = 1)

# And the trailing prose that refused eight answers in the measurement:
# once the structure is complete, the grammar admits nothing more.
chk("prose after a complete structure has nowhere to go",
	StzGrammarCouldContinue(cSchemaG,
		"city: Paris" + char(10) + "founded: 52" + char(10) + "This structure") = 0)

? ""
#=====================================================================#
? "-- Scene 5: what the machine REFUSES to enforce, by name --"
#=====================================================================#
# A machine that quietly accepted a grammar it cannot honour would let a
# caller believe decoding was constrained when it was not. Each refusal
# names the construct.

chk("left recursion is refused, not hung on",
	len(StzFind("GBNF-M7", StzGrammarRefusal('root ::= tail' + char(10) + 'tail ::= tail "x" | "x"'))) > 0)
chk("a rule referenced and never defined is refused",
	len(StzFind("GBNF-M4", StzGrammarRefusal('root ::= greeting'))) > 0)
chk("a grammar with no 'root' is refused -- a machine needs a start",
	len(StzFind("GBNF-M9", StzGrammarRefusal('start ::= "a"'))) > 0)
chk("a rule defined twice is refused rather than guessed at",
	len(StzFind("GBNF-M8", StzGrammarRefusal('root ::= "a"' + char(10) + 'root ::= "b"'))) > 0)
# e-acute, written as its two UTF-8 bytes so the file stays ASCII
cEacute = char(195) + char(169)
chk("a character above ASCII inside a class is refused (matching is by BYTE)",
	len(StzFind("GBNF-M5", StzGrammarRefusal('root ::= [' + cEacute + ']'))) > 0)
chk("...while the SAME character in a quoted literal is fine, as its bytes",
	StzGrammarAccepts('root ::= "' + cEacute + '"', cEacute) = 1)

# the negative sibling: a grammar this build CAN enforce refuses nothing
chk("...and a grammar it can enforce reports no refusal at all",
	StzGrammarRefusal(cSchemaG) = "")

# A declaration the COMPILER cannot express is refused one layer earlier,
# and the function that would have used it says so instead of pretending.
oNest = StzOutputSchemaQ([
	[ :field = "title",  :type = :string ],
	[ :field = "author", :type = :structure, :fields = [ [ :field = "name", :type = :string ] ] ]
])
oFn = new stzLLMFunction("nested")
oFn.SetPrompt("Describe {input}.")
oFn.ReturnsStructure([
	[ :field = "title",  :type = :string ],
	[ :field = "author", :type = :structure, :fields = [ [ :field = "name", :type = :string ] ] ]
])
chk("a nested structure cannot be constrained...", oFn.IsConstrainingDecoding() = 0)
chk("...and the function says why rather than reporting success",
	len(StzFind("cannot be expressed as a grammar", oFn.WhyNotConstrained())) > 0)
chk("...while the COURT still validates it, which is the point",
	oNest.ParseOutput('{ "title":"T", "author":{"name":"Ada"} }')[:ok] = 1)

? ""
#=====================================================================#
? "-- Scene 6: STRUCTURE KILLS MALFORMEDNESS, NOT FALSEHOOD --"
#=====================================================================#
# THE MOST IMPORTANT SCENE HERE. A grammar constrains SHAPE. It cannot
# say "between 0 and 130", and it cannot say "and this is true". Both
# halves of the promise have to be visible or the claim is dishonest.

oAge = StzOutputSchemaQ([
	[ :field = "name", :type = :string ],
	[ :field = "age",  :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ]
])
cAgeG = oAge.ToGBNF()

chk("an age far outside the declared band SATISFIES the grammar",
	StzGrammarAccepts(cAgeG, "name: Ada" + char(10) + "age: 900000" + char(10)) = 1)
chk("...and the Ring court refuses it, which the grammar could not",
	oAge.ParseOutput("name: Ada" + char(10) + "age: 900000")[:ok] = 0)
chk("...and the schema lists that constraint as UNENFORCED by the grammar",
	len(StzFind("lessequal", oAge.UnenforcedByGrammar())) > 0)

# and falsehood, which neither half catches
chk("a false age of the right shape passes BOTH -- structure is not truth",
	StzGrammarAccepts(cAgeG, "name: Ada" + char(10) + "age: 41" + char(10)) = 1 and
	oAge.ParseOutput("name: Ada" + char(10) + "age: 41")[:ok] = 1)

? ""
#=====================================================================#
? "-- Scene 7: a live model, unconstrained vs constrained --"
#=====================================================================#

StzNeuralModelQ("../../../models/smollm2-135m-instruct-q8_0.gguf")

if StzHasGenerativeModel() = 0
	? "  (no generative GGUF loaded -- scenes 7 and 8 cannot be taken)"
else
	oCity = StzOutputSchemaQ([
		[ :field = "city",    :type = :string ],
		[ :field = "country", :type = :string ],
		[ :field = "founded", :type = :number ]
	])
	cCityG = oCity.ToGBNF()
	cPrompt = StzChatPrompt("", "The city is Tokyo." + char(10) + char(10) + oCity.PromptClause())

	# Tokyo is not chosen at random: it is one of the eight inputs the
	# measurement watched fail, on every one of four attempts.
	cFree = StzGenerate(cPrompt, 96)
	chk("UNCONSTRAINED, this input produces something the court refuses",
		oCity.ParseOutput(cFree)[:ok] = 0)

	cTied = StzGenerateXT(cPrompt, [ :MaxTokens = 96, :Temperature = 0, :Grammar = cCityG ])
	chk("CONSTRAINED, the same greedy decode is valid", oCity.ParseOutput(cTied)[:ok] = 1)
	chk("...and it satisfies the grammar as a whole sentence",
		StzGrammarAccepts(cCityG, cTied) = 1)

	aRun = StzLastGrammarRun()
	chk("...the grammar actually judged candidates (it was not a no-op)",
		aRun[:judged] > 0)
	chk("...and refused most of them", aRun[:masked] > 0)
	chk("...no step ran out of legal tokens", aRun[:stalled] = 0)
	chk("...and generation ended where the grammar was SATISFIED",
		aRun[:complete] = 1)

	? ""
	#=============================================================#
	? "-- Scene 8: the same, through stzLLMFunction --"
	#=============================================================#
	# Constraining is ON by default when a structure is declared and the
	# engine enforces grammars. The switch exists so the two can be
	# compared, which is exactly what this scene does.

	oF = new stzLLMFunction("city-tied")
	oF.SetPrompt("The city is {input}.")
	oF.ReturnsStructure([
		[ :field = "city",    :type = :string ],
		[ :field = "country", :type = :string ],
		[ :field = "founded", :type = :number ]
	])
	oF.SetMaxTokens(96)
	oF.Budget(1)
	oF.SetRetries(0)

	chk("a structured function constrains decoding by default",
		oF.IsConstrainingDecoding() = 1)
	chk("...with nothing to explain away", oF.WhyNotConstrained() = "")

	bOK = 1
	try
		aGot = oF.Call_("Tokyo")
		chk("...and one call, one budget, one valid answer", oF.CallsMade() = 1)
		chk("...whose city field is the city it was asked about",
			StzLower("" + aGot[:city]) = "tokyo")
	catch
		bOK = 0
	done
	chk("...the constrained call did not refuse", bOK = 1)
	chk("...and it reports that the answer WAS constrained",
		oF.WasLastAnswerConstrained() = 1)

	# the off switch, and the same input without the grammar
	oU = new stzLLMFunction("city-free")
	oU.SetPrompt("The city is {input}.")
	oU.ReturnsStructure([
		[ :field = "city",    :type = :string ],
		[ :field = "country", :type = :string ],
		[ :field = "founded", :type = :number ]
	])
	oU.SetMaxTokens(96)
	oU.Budget(1)
	oU.SetRetries(0)
	oU.ConstrainDecoding(0)
	chk("ConstrainDecoding(0) really turns it off", oU.IsConstrainingDecoding() = 0)
	chk("...and says so rather than staying silent",
		len(StzFind("ConstrainDecoding(0)", oU.WhyNotConstrained())) > 0)

	bRefused = 0
	try
		oU.Call_("Tokyo")
	catch
		bRefused = 1
	done
	chk("...and unconstrained, this input still refuses on one attempt",
		bRefused = 1)
ok

? ""
#=====================================================================#
? "-- Scene 9: the seam that is refused rather than ignored --"
#=====================================================================#
# A streaming session has no end hook, so a grammar installed for one
# would still be installed for the next, unrelated generation. Silently
# ignoring the option would be the worse answer of the two.

bRaised = 0
try
	StzStartGeneration("hello", [ :MaxTokens = 8, :Grammar = 'root ::= "a"' ])
catch
	bRaised = 1
done
chk("a grammar on a STREAMING session is refused, not quietly dropped",
	bRaised = 1)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

# THE HELPER LIVES AFTER pf(). Ring runs a file's top-level code until the
# first `func`, so a helper defined at the TOP silently kills every scene
# below it -- the file runs, prints nothing, and exits 0.
func chk(cWhat, bCond)
	if bCond = 1
		nPass++
		? "  [OK] " + cWhat
	else
		nFail++
		? "  [FAIL] " + cWhat
	ok
