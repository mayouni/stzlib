# MEASUREMENT, not a guard. Prompt 42 item 4: attempts-per-successful
# answer for structured output on the model this repository actually ships
# (smollm2-135m-instruct-q8_0). The number is the whole argument for
# grammar-constrained decoding, so it is taken before anything is built on
# the assumption that it is bad -- and again after each cheaper fix, so
# nobody builds the expensive rung to solve a problem a prompt line solved.
#
# Run:  ring _measure_structured.ring

load "../../stzBase.ring"

StzNeuralModelQ("../../../models/smollm2-135m-instruct-q8_0.gguf")
if NOT StzHasGenerativeModel()
	? "NO GENERATIVE MODEL -- the measurement cannot be taken."
	return
ok

oS = StzOutputSchemaQ([
	[ :field = "city",    :type = :string ],
	[ :field = "country", :type = :string ],
	[ :field = "founded", :type = :number ]
])

acInputs = [ "Paris", "Tokyo", "Cairo", "Lima", "Oslo",
             "Delhi", "Rome", "Accra", "Quito", "Sofia" ]
cClause = oS.PromptClause()
nTotal = len(acInputs)

#---------------------------------------------------------------------
? "=== PASS A: one greedy attempt each (the shipped default) ==="
#---------------------------------------------------------------------
nOK_A = 0
for i = 1 to nTotal
	cPrompt = "The city is " + acInputs[i] + "." + char(10) + char(10) + cClause
	aV = oS.ParseOutput(StzAskModel(cPrompt, 96))
	if aV[:ok] = 1
		nOK_A++
		? "  [VALID]   " + acInputs[i]
	else
		? "  [REFUSED] " + acInputs[i] + " -- " +
			StzLeft(oS.CiteFindings(aV[:findings]), 80)
	ok
next
? "  first-attempt validation rate: " + nOK_A + "/" + nTotal

#---------------------------------------------------------------------
? ""
? "=== PASS B: does a RETRY now actually differ? ==="
#---------------------------------------------------------------------
# The defect this answers: greedy decoding is deterministic, so every
# retry used to be byte-identical to the attempt that just failed --
# measured at 8 of 8 before the fix.
cP = "The city is Tokyo." + char(10) + char(10) + cClause
cGreedy1 = StzAskModel(cP, 96)
cGreedy2 = StzAskModel(cP, 96)
? "  two GREEDY attempts differ : " + (cGreedy1 != cGreedy2) + "   (expected 0 -- greedy is deterministic, and correctly so)"
cS1 = StzAskModelXT(cP, [ :MaxTokens = 96, :Temperature = 0.7, :Seed = 1001 ])
cS2 = StzAskModelXT(cP, [ :MaxTokens = 96, :Temperature = 0.7, :Seed = 1002 ])
? "  two SAMPLED attempts differ: " + (cS1 != cS2) + "   (expected 1 -- this is what makes a retry a retry)"

#---------------------------------------------------------------------
? ""
? "=== PASS C: the full rung, retries included ==="
#---------------------------------------------------------------------
# What a caller actually experiences: stzLLMFunction with a budget, its
# own prompt clause, its own retry policy.
nOK_C = 0
nCalls_C = 0
for i = 1 to nTotal
	oF = new stzLLMFunction("city-" + i)
	oF.SetPrompt("The city is {input}.")
	oF.ReturnsStructure([
		[ :field = "city",    :type = :string ],
		[ :field = "country", :type = :string ],
		[ :field = "founded", :type = :number ]
	])
	oF.SetMaxTokens(96)
	oF.Budget(4)
	oF.SetRetries(3)
	try
		oF.Call_(acInputs[i])
		nOK_C++
		? "  [VALID]   " + acInputs[i] + " on attempt " + oF.CallsMade()
	catch
		? "  [REFUSED] " + acInputs[i] + " after " + oF.CallsMade() + " attempts"
	done
	nCalls_C += oF.CallsMade()
next

? ""
? "=== THE NUMBERS ==="
? "inputs                        : " + nTotal
? "PASS A  first-attempt valid   : " + nOK_A + "/" + nTotal
? "PASS C  valid within 4 tries  : " + nOK_C + "/" + nTotal
? "PASS C  model calls spent     : " + nCalls_C
if nOK_C > 0
	? "PASS C  attempts per answer   : " + (nCalls_C / nOK_C)
else
	? "PASS C  attempts per answer   : INFINITE -- nothing validated"
ok
