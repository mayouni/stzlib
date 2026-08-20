# SCHEMA -> GBNF -- ACCEPTANCE
#
# stzOutputSchema declares a structure and CHECKS what a model already
# said. This is the other half: the same declaration compiled into a
# GRAMMAR, which is what a sampler needs to make a violating token
# unemittable rather than caught.
#
# WHY IT EXISTS, AS A NUMBER AND NOT A BELIEF. Against the model this
# repository ships (smollm2-135m-instruct-q8_0), ten structured prompts --
# base/test/neural/_measure_structured.ring, run it yourself:
#
#     first attempt valid          2 / 10
#     valid within four attempts   6 / 10
#     attempts per valid answer    5.0
#     never valid at all           4 / 10
#
# TWO THINGS THIS GUARD IS CAREFUL NOT TO CLAIM.
#
#   1. A GRAMMAR CONSTRAINS SHAPE, NEVER VALUE. No context-free rule says
#      "this number is between 0 and 130", so every :must clause is dropped
#      from the emitted grammar -- and listed, one line each, rather than
#      dropped in silence. The Ring court does not retire when constrained
#      decoding lands; it is the half that checks what a grammar cannot.
#
#   2. NOTHING HERE CONSTRAINS DECODING. This build compiles a grammar and
#      stops. IsDecodingConstrained() answers 0 and says why, so a compiled
#      grammar can never be mistaken for a constrained sampler.
#
# Model-FREE: compiling a grammar needs no model, which is most of why it
# is worth having as a separate rung.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oS = StzOutputSchemaQ([
	[ :field = "city",    :type = :string ],
	[ :field = "founded", :type = :number, :must = [ [ ">=", 0 ], [ "<=", 3000 ] ] ],
	[ :field = "mood",    :type = :oneof,  :choices = [ "calm", "busy" ] ],
	[ :field = "tags",    :type = :list,   :of = :string, :optional = 1 ]
])
cG = oS.ToGBNF()

#=====================================================================#
? "-- Scene 1: a declaration becomes a grammar --"
#=====================================================================#

chk("the root sequences one rule per field",
	len(StzFind("root ::= city-line founded-line mood-line", cG)) > 0)
chk("a string field takes free text up to the newline",
	len(StzFind('city-line ::= "city: " text', cG)) > 0)
chk("a number field takes the number terminal",
	len(StzFind('founded-line ::= "founded: " number', cG)) > 0)
chk("the terminals are defined, not assumed",
	len(StzFind('number ::= "-"? [0-9]+', cG)) > 0)

? ""
#=====================================================================#
? "-- Scene 2: a CLOSED enumeration becomes a closed alternation --"
#=====================================================================#
# This is the one place a grammar is strictly stronger than the court:
# the court refuses 'meh' after the model said it; a grammar makes 'meh'
# unsayable.

chk("the choices become an alternation, and only those choices",
	len(StzFind('("calm" | "busy")', cG)) > 0)

? ""
#=====================================================================#
? "-- Scene 3: optional fields and lists keep their arity --"
#=====================================================================#

chk("an optional field is optional in the root", len(StzFind("tags-line?", cG)) > 0)
chk("an optional list may be empty (zero or more)",
	len(StzFind('("  - " text "\n")*', cG)) > 0)

oReq = StzOutputSchemaQ([ [ :field = "tags", :type = :list, :of = :string ] ])
chk("a REQUIRED list must hold at least one element (one or more)",
	len(StzFind('("  - " text "\n")+', oReq.ToGBNF())) > 0)

chk("every emitted line is a whole rule -- no terminal carries a raw newline",
	EveryLineIsARule(cG))

? ""
#=====================================================================#
? "-- Scene 4: what the grammar CANNOT carry, said out loud --"
#=====================================================================#
# The most important behaviour in this file. Silently dropping the band
# would let the layer above report 'constrained' while 0..3000 went
# unenforced.

cU = oS.UnenforcedByGrammar()
chk("the dropped constraints are reported", len(cU) > 0)
chk("...by field", len(StzFind("founded", cU)) > 0)
chk("...and by operator", len(StzFind("greaterequal", cU)) > 0 and
	len(StzFind("lessequal", cU)) > 0)
chk("...saying WHY a grammar cannot carry them",
	len(StzFind("never value", cU)) > 0)
chk("...and that the court still does", len(StzFind("Ring court still checks", cU)) > 0)

# the negative sibling: a schema with no value constraints reports nothing
oPlain = StzOutputSchemaQ([ [ :field = "city", :type = :string ] ])
chk("a schema with no :must constraints reports NOTHING unenforced",
	oPlain.UnenforcedByGrammar() = "")

# and the band the grammar dropped is still enforced where it lives
chk("the COURT still refuses what the grammar could not express",
	oS.ParseOutput("city: Ur" + char(10) + "founded: 99999" + char(10) +
		"mood: calm")[:ok] = 0)

? ""
#=====================================================================#
? "-- Scene 5: what cannot be expressed is REFUSED, never flattened --"
#=====================================================================#
# A grammar that quietly dropped a nested field would ACCEPT text the
# schema refuses, and the two layers would disagree about what is legal.

oNest = StzOutputSchemaQ([
	[ :field = "title",  :type = :string ],
	[ :field = "author", :type = :structure, :fields = [ [ "name", :string ] ] ]
])
chk("a nested structure is not expressible as a flat grammar",
	oNest.IsExpressibleAsGrammar() = 0)

b = 0
cWhy = ""
try
	oNest.ToGBNF()
catch
	b = 1
	cWhy = cCatchError
done
chk("...so ToGBNF() refuses rather than emitting something else", b = 1)
chk("...with a NAMED code", len(StzFind("GBNF-F5", cWhy)) > 0)
chk("...naming the field", len(StzFind("author", cWhy)) > 0)
chk("...and saying what the refusal protects",
	len(StzFind("accept what the schema rejects", cWhy)) > 0)
chk("the same schema is still perfectly valid for the COURT, which is the point",
	oNest.ParseOutput('{ "title":"T", "author":{"name":"Ada"} }')[:ok] = 1)

? ""
#=====================================================================#
? "-- Scene 6: the compiled grammar now HAS a sampler that enforces it --"
#=====================================================================#
# THIS SCENE USED TO ASSERT THE OPPOSITE, and that was right at the time.
# Compiling a grammar and constraining decoding are two rungs; until the
# second one existed, IsDecodingConstrained() answered 0 and this guard
# held it to that. The second rung landed (engine/src/gbnf_machine.zig),
# so the honest answer changed -- and the guard changed with it, in the
# same commit, which is the only way an anti-stub stays trustworthy.

chk("decoding IS constrained in this build", oS.IsDecodingConstrained() = 1)
cSt = oS.DecodingStatus()
chk("...and the status says so in its first word",
	len(StzFind("CONSTRAINED", cSt)) > 0)
chk("...says a violating token is UNEMITTABLE, not caught afterwards",
	len(StzFind("unemittable", cSt)) > 0)
chk("...names the prefix case a stack machine has to get right",
	len(StzFind("valid PREFIX and an invalid completion", cSt)) > 0)
chk("...and states the coverage in the same breath as the claim",
	len(StzFind("never VALUE and never TRUTH", cSt)) > 0)
chk("...pointing at the court that still checks what a grammar cannot",
	len(StzFind("UnenforcedByGrammar", cSt)) > 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

# Every non-blank line of a grammar must be a complete rule. A raw newline
# inside a quoted terminal splits a rule across two lines and leaves one
# that is not -- the defect the first emitter shipped.
func EveryLineIsARule(cGrammar)
	_ac_ = StzSplit(cGrammar, char(10))
	_n_ = len(_ac_)
	for _i_ = 1 to _n_
		if ring_trim(_ac_[_i_]) = ""  loop  ok
		if len(StzFind("::=", _ac_[_i_])) = 0
			return 0
		ok
	next
	return 1

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
