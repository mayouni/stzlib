# THE STRUCTURED-OUTPUT RUNG -- ACCEPTANCE
#
# stzLLMFunction could already declare that a call returns a number, a
# boolean, or one of three words. This is the rung above that: DECLARED
# STRUCTURE, VALIDATED WHOLES -- and the refusals that make the promise
# worth anything.
#
# Model-FREE by construction. Every scene here runs with no GGUF loaded:
# the parse-and-refuse court is exercised directly, and the retry and
# refusal paths run through UseResponder(), the door that puts a NAMED
# FAKE where the model stands. That is deliberate -- the paths that
# matter most are the ones a seeded cache can never reach.
#
# STRUCTURE KILLS MALFORMEDNESS, NOT FALSEHOOD. Scene 10 proves it by
# letting a lie through, on purpose.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

#=====================================================================#
? "-- Scene 1: the declaration is judged when it is DECLARED --"
#=====================================================================#
# A schema whose defect surfaces at CALL time is a schema that cost a
# model call to discover a typo. Every one of these raises before any
# model exists. (The precedent is stzGraphRule, which raises on an
# unknown operator for exactly this reason.)

b = 0
try
	StzOutputSchemaQ([ [ :field = "x", :type = :colour ] ])
catch
	b = 1
done
chk("an unknown TYPE raises at declaration time", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "x", :type = :string, :requird = 0 ] ])
catch
	b = 1
done
chk("a typo'd KEY raises -- ':requird' cannot silently leave a field required", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "mood", :type = :oneof ] ])
catch
	b = 1
done
chk("a :oneof with no :choices raises (an empty enumeration is unsatisfiable)", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "tags", :type = :list ] ])
catch
	b = 1
done
chk("a :list that does not say :of what raises", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "a", :type = :string ], [ :field = "A", :type = :number ] ])
catch
	b = 1
done
chk("the same field declared twice raises (Ring folds keys -- they are ONE field)", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "n", :type = :number, :must = [ [ "biggerish", 3 ] ] ] ])
catch
	b = 1
done
chk("an unknown :must OPERATOR raises -- the graph-rule vocabulary is reused, so is its refusal", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "s", :type = :string, :must = [ [ ">=", 3 ] ] ] ])
catch
	b = 1
done
chk("an operator that cannot apply to the type raises ('>=' on a string)", b = 1)

b = 0
try
	StzOutputSchemaQ([ [ :field = "s", :type = :string, :must = [ [ "exists", 1 ] ] ] ])
catch
	b = 1
done
chk("'exists' in :must raises -- that is what :required already says", b = 1)

oOK = StzOutputSchemaQ([
	[ :field = "name", :type = :string ],
	[ :field = "age",  :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ],
	[ :field = "mood", :type = :oneof,  :choices = [ "positive", "negative" ] ],
	[ :field = "tags", :type = :list,   :of = :string, :optional = 1 ]
])
chk("a sound declaration compiles, and knows its own shape", oOK.NumberOfFields() = 4)
chk("...names its required fields", len(oOK.RequiredFieldNames()) = 3)
chk("...and the compact form declares the same thing",
	StzOutputSchemaQ([ [ "name", :string ], [ "tags", :list, :string, "optional" ] ]).NumberOfFields() = 2)

? ""
#=====================================================================#
? "-- Scene 2: two shapes are read, and nothing else is guessed at --"
#=====================================================================#
# A model wraps its answer in prose, or a fence, or writes the project's
# own memo shape. All three are the same answer.

aV = oOK.ParseOutput('Sure, here you go:' + char(10) + '```json' + char(10) +
	'{ "mood": "POSITIVE", "age": "36", "name": "Ada", "tags": ["x","y"] }' + char(10) + '```')
chk("JSON inside a fence inside prose is read", aV[:ok] = 1 and aV[:shape] = "json")

cMemo = "name: Ada" + char(10) + "age: 36" + char(10) +
	"mood: negative" + char(10) + "tags:" + char(10) +
	"  - alpha" + char(10) + "  - beta"
aM = oOK.ParseOutput(cMemo)
chk("the yaml-like MEMO shape is read too", aM[:ok] = 1 and aM[:shape] = "memo")
chk("...with its list intact", len(aM[:value][:tags]) = 2 and aM[:value][:tags][2] = "beta")

aBad = oOK.ParseOutput("I would rather not say.")
chk("prose that is not a structure is REFUSED, not scavenged", aBad[:ok] = 0)
chk("...and the refusal names the rule 'parse'", aBad[:findings][1][:rule] = "parse")

? ""
#=====================================================================#
? "-- Scene 3: what comes back is the DECLARED shape --"
#=====================================================================#

chk("a representable scalar is COERCED: the string '36' arrives as the number 36",
	aV[:value][:age] + 1 = 37)
chk("...and it really is a number, not a string that adds", isNumber(aV[:value][:age]))
chk("a closed enumeration folds case", aV[:value][:mood] = "positive")
chk("fields come back in DECLARED order, not the order the model wrote them",
	aV[:value][1][1] = "name" and aV[:value][3][1] = "mood")

aX = oOK.ParseOutput('{ "name":"Ada", "age":36, "mood":"positive", "colour":"blue" }')
chk("a field nobody declared does NOT refuse the answer by default", aX[:ok] = 1)
chk("...but it is reported", aX[:findings][1][:rule] = "unknown-field")
chk("...as a WARNING, not an error", aX[:findings][1][:severity] = "warning")
chk("...and it is dropped from the whole", HasKey(aX[:value], "colour") = 0)

oClosed = StzOutputSchemaQ([ [ "name", :string ] ])
oClosed.RefuseUnknownFields()
chk("RefuseUnknownFields() closes the language: the same extra field now refuses",
	oClosed.Accepts('{ "name":"Ada", "colour":"blue" }') = 0)

? ""
#=====================================================================#
? "-- Scene 4: partial credit is forbidden --"
#=====================================================================#
# One missing required field refuses the WHOLE structure. There is no
# "mostly valid" return, because a caller cannot be trusted to check.

aR = oOK.ParseOutput('{ "name":"Ada", "age":36 }')
chk("one missing required field refuses the whole answer", aR[:ok] = 0)
chk("...naming the rule", aR[:findings][1][:rule] = "required")
chk("...and the field", aR[:findings][1][:where] = "mood")
chk("nothing partial escapes as a value", len(aR[:value]) = 0)

aE = oOK.ParseOutput('{ "name":"", "age":36, "mood":"positive" }')
chk("a required field PRESENT BUT EMPTY is missing -- the model did not answer it",
	aE[:ok] = 0)

aT = oOK.ParseOutput('{ "name":"Ada", "age":"old", "mood":"positive" }')
chk("a type mismatch refuses", aT[:ok] = 0)
chk("...naming the rule 'type'", aT[:findings][1][:rule] = "type")

aC = oOK.ParseOutput('{ "name":"Ada", "age":36, "mood":"meh" }')
chk("a CLOSED enumeration is closed -- 'meh' is not near enough", aC[:ok] = 0)
chk("...naming the rule 'oneof'", aC[:findings][1][:rule] = "oneof")

aB = oOK.ParseOutput('{ "name":"Ada", "age":900000, "mood":"positive" }')
chk("a :must band refuses what falls outside it", aB[:ok] = 0)
chk("...naming the OPERATOR as the rule", aB[:findings][1][:rule] = "lessequal")
chk("...and citing it in words a reader can act on",
	len(StzFind("at most", oOK.CiteFindings(aB[:findings]))) > 0)

? ""
#=====================================================================#
? "-- Scene 5: nesting -- structures inside structures, lists of them --"
#=====================================================================#

oNest = StzOutputSchemaQ([
	[ :field = "title",  :type = :string ],
	[ :field = "author", :type = :structure, :fields = [
		[ :field = "name",  :type = :string ],
		[ :field = "email", :type = :string, :optional = 1 ]
	] ],
	[ :field = "steps", :type = :list, :of = :structure, :fields = [
		[ :field = "at",   :type = :number ],
		[ :field = "what", :type = :string ]
	], :must = [ [ ">=", 2 ] ] ]
])

aN = oNest.ParseOutput('{ "title":"Recipe", "author":{"name":"Ada"},' +
	' "steps":[ {"at":1,"what":"boil"}, {"at":2,"what":"wait"} ] }')
chk("a nested structure validates", aN[:ok] = 1)
chk("...and reads back", aN[:value][:author][:name] = "Ada")
chk("a list OF structures validates element by element", len(aN[:value][:steps]) = 2)
chk("...each element coerced", aN[:value][:steps][2][:at] = 2)

aN2 = oNest.ParseOutput('{ "title":"Recipe", "author":{"email":"a@b.c"},' +
	' "steps":[ {"at":1,"what":"boil"}, {"at":2,"what":"wait"} ] }')
chk("a field missing DEEP inside refuses the whole", aN2[:ok] = 0)
chk("...and the path says where: 'author.name'",
	aN2[:findings][1][:where] = "author.name")

aN3 = oNest.ParseOutput('{ "title":"R", "author":{"name":"Ada"},' +
	' "steps":[ {"at":1,"what":"boil"} ] }')
chk("a comparison on a LIST speaks about its element count", aN3[:ok] = 0)
chk("...and says so in the message",
	len(StzFind("element", oNest.CiteFindings(aN3[:findings]))) > 0)

aN4 = oNest.ParseOutput('{ "title":"R", "author":{"name":"Ada"},' +
	' "steps":[ {"at":1,"what":"boil"}, {"what":"wait"} ] }')
chk("a defective element is located by index: 'steps[2].at'",
	aN4[:findings][1][:where] = "steps[2].at")

? ""
#=====================================================================#
? "-- Scene 6: the verdict joins the house CI gate --"
#=====================================================================#
# The findings are not a private shape. They are the family's unified
# [ :rule, :subject, :where, :severity, :message ], so a schema refusal
# stands in the same report as the code, agent and security rules.

aF = aR[:findings][1]
chk("a finding carries :rule", HasKey(aF, :rule))
chk("...:subject", aF[:subject] = "structured-output")
chk("...:where", HasKey(aF, :where))
chk("...:severity", HasKey(aF, :severity))
chk("...:message", HasKey(aF, :message))

oRep = new stzRuleReport("structured-output-gate")
oRep.Ingest(aR[:findings])
chk("stzRuleReport ingests it without an adapter", len(oRep.Findings()) = 1)
chk("...and the gate reads UNSOUND", oRep.IsSound() = 0)

? ""
#=====================================================================#
? "-- Scene 7: retry inside the SAME budget, then refusal --"
#=====================================================================#
# UseResponder() is a NAMED FAKE standing where the model stands. It
# spends budget like a real call, so the retry arithmetic is the real
# arithmetic.

oT = new stzLLMFunction("read-ticket")
oT.SetPrompt("Read this ticket: {input}")
oT.ReturnsStructure([
	[ :field = "summary",  :type = :string ],
	[ :field = "severity", :type = :oneof, :choices = [ "low", "high" ] ],
	[ :field = "hours",    :type = :number, :must = [ [ ">=", 0 ] ] ]
])
oT.Budget(6)
oT.SetRetries(3)
oT.UseResponder(func cPrompt, nTry {
	if nTry < 3
		return "Honestly it's pretty bad."
	ok
	return "summary: printer on fire" + char(10) +
	       "severity: high" + char(10) + "hours: 2"
})

chk("the prompt CARRIES the shape -- the model is asked, not hoped at",
	len(StzFind("severity: <one of: low | high>", oT.EffectivePrompt("x"))) > 0)

aTk = oT.Call_("printer is on fire")
chk("two malformed answers are retried and the third validates", isList(aTk))
chk("...and the retries were paid for out of Budget(n)", oT.CallsMade() = 3)
chk("...the value is the declared whole", aTk[:severity] = "high" and aTk[:hours] = 2)
chk("...and Why() says a FAKE answered, so nothing reads as live",
	len(StzFind("FAKE", oT.Why())) > 0)

oN = new stzLLMFunction("never-complies")
oN.SetPrompt("x {input}")
oN.ReturnsStructure([ [ "name", :string ], [ "age", :number ] ])
oN.Budget(4)
oN.SetRetries(1)
oN.UseResponder(func cP, nT { return "name: Ada" })
b = 0
cWhy = ""
try
	oN.Call_("q")
catch
	b = 1
	cWhy = cCatchError
done
chk("a model that never complies REFUSES on exhaustion (LAW 3)", b = 1)
chk("...and the refusal cites the field that failed",
	len(StzFind("age", cWhy)) > 0)
chk("...and names the rule", len(StzFind("required", cWhy)) > 0)
chk("...and the findings are readable afterwards, in the unified shape",
	len(oN.LastFindings()) = 1)

oB = new stzLLMFunction("thin-budget")
oB.SetPrompt("x {input}")
oB.ReturnsStructure([ [ "name", :string ] ])
oB.Budget(2)
oB.SetRetries(9)
oB.UseResponder(func cP, nT { return "nothing useful here" })
b = 0
cWhy = ""
try
	oB.Call_("q")
catch
	b = 1
	cWhy = cCatchError
done
chk("Budget(n) still bounds the retries -- it is not a suggestion", b = 1)
chk("...and the refusal says the budget was what stopped it",
	len(StzFind("Budget exhausted", cWhy)) > 0)
chk("...having spent exactly the budget, no more", oB.CallsMade() = 2)

? ""
#=====================================================================#
? "-- Scene 8: a seed is judged like a generated answer --"
#=====================================================================#
# The offline door is for testing, not for smuggling. A seed that
# escaped unchecked would be garbage arriving through the side entrance.

oS = new stzLLMFunction("seeded")
oS.SetPrompt("x {input}")
oS.ReturnsStructure([ [ "name", :string ], [ "age", :number ] ])
oS.Budget(2)
oS.SeedAnswer("q", [ :name = "Ada", :age = 36 ])
aSd = oS.Call_("q")
chk("a valid seed answers, memoized and free", aSd[:name] = "Ada" and oS.CallsMade() = 0)

b = 0
try
	oS.SeedAnswer("z", [ :name = "Ada" ])
catch
	b = 1
done
chk("an INVALID seed is refused at the door, not stored", b = 1)

oS2 = new stzLLMFunction("seeded-raw")
oS2.SetPrompt("x {input}")
oS2.ReturnsStructure([ [ "name", :string ], [ "age", :number ] ])
oS2.Budget(2)
oS2.SeedAnswer("q", "name: Ada" + char(10) + "age: 36")
chk("a seed given as RAW TEXT is parsed and validated like any answer",
	oS2.Call_("q")[:age] = 36)

? ""
#=====================================================================#
? "-- Scene 9: goldens hold structures --"
#=====================================================================#
# Two defects had to go for this: Ring's own `=` answers 0 for two
# IDENTICAL lists, so a structured golden could never have passed; and a
# failure reporting only expected/got is unreadable at three fields.

oG = new stzLLMFunction("golden-struct")
oG.SetPrompt("x {input}")
oG.ReturnsStructure([ [ "name", :string ], [ "age", :number ] ])
oG.Budget(4)
oG.SeedAnswer("a", [ :name = "Ada", :age = 36 ])
oG.SeedAnswer("b", [ :name = "Bob", :age = 41 ])
oG.AddGolden("a", [ :name = "Ada", :age = 36 ])
aG = oG.RunGoldens()
chk("a structured golden PASSES when it agrees", aG[:passed] = 1 and aG[:total] = 1)

oG.AddGolden("b", [ :name = "Bob", :age = 40 ])
aG2 = oG.RunGoldens()
chk("...and fails when it does not", aG2[:passed] = 1 and len(aG2[:failed]) = 1)
chk("...naming the FIELD that moved, not just the record",
	aG2[:failed][1][:findings][1][:where] = "age")

? ""
#=====================================================================#
? "-- Scene 10: STRUCTURE KILLS MALFORMEDNESS, NOT FALSEHOOD --"
#=====================================================================#
# The amendment that rides on this contract's face, demonstrated rather
# than asserted. Every rule above holds; the answer is still a lie.

oP = StzOutputSchemaQ([
	[ :field = "person", :type = :string ],
	[ :field = "age",    :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ]
])
aLie = oP.ParseOutput('{ "person":"Ada Lovelace", "age":9 }')
chk("a schema-valid LIE validates -- Ada Lovelace was not nine", aLie[:ok] = 1)
chk("...and the court has no complaint to make about it", len(aLie[:findings]) = 0)
? "  (so what is promised is INTEGRITY -- the shape asked for, whole, or"
? "   nothing. Truth needs reversibility, audit and judgement, none of"
? "   which live in a validator.)"

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
