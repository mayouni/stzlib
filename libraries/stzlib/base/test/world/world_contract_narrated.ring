# THE WORLD CONTRACT (C1) -- the guard, narrated.
#
# Run from THIS directory: cd libraries/stzlib/base/test/world && ring world_contract_narrated.ring
#
# What it proves, in order:
#
#   1  a lawful world loads, and the two tables survive the trip
#   2  the projection StzZui's shipped verifier reads
#   3  the collapse: two reference SITES, one graph edge, both rows kept
#   4  the graph is an ordinary stzGraph from there on
#   5  every refusal, each with a negative sibling that must NOT fire

load "../../stzBase.ring"
load "../../graph/stzWorldGraph.ring"

func Main()

	? ""
	? "THE WORLD CONTRACT (C1) -- stzWorldGraph"
	? Copy("=", 74)

	Part1_ALawfulWorld()
	Part2_TheZuiProjection()
	Part3_TheCollapse()
	Part4_AnOrdinaryGraph()
	Part5_TheRefusals()

	? ""
	? Copy("=", 74)
	? "DONE."
	? ""

#---------------------------------------------------------------- 1

func Part1_ALawfulWorld()
	? ""
	? "1. A LAWFUL WORLD LOADS"
	? Copy("-", 74)

	oW = StzWorldGraphQ("tontine.world.json")

	? "world             : " + oW.World()
	? "contract          : " + oW.ContractVersion()
	? "symbols           : " + oW.SymbolCount()
	? "references        : " + oW.RefCount()
	? "kinds present     : " + JoinXT(oW.Kinds(), ", ")
	? "lawful            : " + oW.IsLawful()
	? "diagnostics       : " + len(oW.Diagnostics())

	Assert(oW.IsLawful(), "a lawful world reports lawful")
	Assert(oW.SymbolCount() = 13, "all 13 symbols survived")
	Assert(oW.RefCount() = 11, "all 11 reference SITES survived")

	# The id form is C2's cite form, reused: kind:name.
	? ""
	? "a symbol, by its id:"
	a = oW.Symbol("field:deposit.amount")
	? "  id    : " + a[:id]
	? "  kind  : " + a[:kind]
	? "  name  : " + a[:name]
	? "  type  : " + a[:type]
	? "  span  : " + a[:file] + ":" + a[:line]

	Assert(a[:type] = "currency", "a field carries its declared type")
	Assert(a[:file] = "app.zql", "span.file IS the declaring artifact")

	# Two kinds may share a name -- the id keeps them apart.
	Assert(oW.HasSymbol("entity:member"), "entity:member exists")
	Assert(oW.HasSymbol("actor:member"), "actor:member exists too")
	Assert(oW.Symbol("entity:member")[:kind] != oW.Symbol("actor:member")[:kind],
		"and they are different symbols")

#---------------------------------------------------------------- 2

func Part2_TheZuiProjection()
	? ""
	? "2. THE PROJECTION THE ZUI VERIFIER READS"
	? Copy("-", 74)
	? "   (tools/zui --symbols FILE; without it Level 3 is SKIPPED, because"
	? "    undecidable is silence, never a pass)"
	? ""

	oW = StzWorldGraphQ("tontine.world.json")
	aT = oW.ZuiSymbolTable()

	? "entities : " + JoinXT(aT[:entities], ", ")
	? "actors   : " + JoinXT(aT[:actors], ", ")
	? "state    : " + JoinXT(aT[:state], ", ")
	? "elements : " + JoinXT(aT[:elements], ", ")

	Assert(len(aT[:entities]) = 3, "three entities")
	Assert(len(aT[:actors]) = 1, "one actor")
	Assert(len(aT[:state]) = 1, "one state")
	Assert(len(aT[:elements]) = 1, "one element")

	# The verifier compares NAMES, not ids -- so the projection must strip
	# the kind prefix, or every Level-3 check would report unresolved.
	Assert(ring_find(aT[:entities], "deposit") > 0,
		"the projection carries the NAME, not the id")
	Assert(ring_find(aT[:entities], "entity:deposit") = 0,
		"and never the id -- the verifier would not match it")

#---------------------------------------------------------------- 3

func Part3_TheCollapse()
	? ""
	? "3. TWO REFERENCE SITES, ONE EDGE, BOTH ROWS KEPT"
	? Copy("-", 74)
	? "   stzGraph is a SIMPLE graph -- one edge per node pair, deliberately."
	? "   The flow enforces the norm at TWO steps, on two different lines."
	? ""

	oW = StzWorldGraphQ("tontine.world.json")

	aSites = []
	aFrom = oW.ReferencesFrom("flow:accept_deposit")
	nLen = len(aFrom)
	for i = 1 to nLen
		if aFrom[i][:to] = "norm:positive_deposit"
			aSites + aFrom[i]
		ok
	next

	? "reference SITES flow -> norm : " + len(aSites)
	for i = 1 to len(aSites)
		? "   " + aSites[i][:kind] + " at " + aSites[i][:file] + ":" + aSites[i][:line]
	next

	Assert(len(aSites) = 2, "world.json keeps BOTH sites, with both spans")
	Assert(aSites[1][:line] != aSites[2][:line], "and they are different lines")

	oG = oW.Graph()
	aEdge = oG.Edge("flow:accept_deposit", "norm:positive_deposit")
	aRows = aEdge[:properties][:refs]

	? ""
	? "graph EDGES for that pair    : 1  (label '" + aEdge[:label] + "')"
	? "rows carried on the edge     : " + len(aRows)

	Assert(len(aRows) = 2, "the collapsed edge still carries both rows")
	Assert(oG.EdgeCount() = 10, "11 reference sites became 10 edges")

	? ""
	? "   world.json is the truth; the graph is an INDEX over it. An index"
	? "   answers reachability, which is a property of the pair -- so the"
	? "   collapse loses nothing, and the rows are where detail survives."

#---------------------------------------------------------------- 4

func Part4_AnOrdinaryGraph()
	? ""
	? "4. AN ORDINARY stzGraph FROM HERE ON"
	? Copy("-", 74)

	oW = StzWorldGraphQ("tontine.world.json")
	oG = oW.Graph()

	? "nodes             : " + oG.NodeCount()
	? "edges             : " + oG.EdgeCount()
	? "who reaches the amount field:"
	aTo = oW.ReferencesTo("field:deposit.amount")
	nLen = len(aTo)
	for i = 1 to nLen
		? "   " + aTo[i][:from] + "  --" + aTo[i][:kind] + "->"
	next

	Assert(oG.NodeCount() = 13, "one node per symbol")
	Assert(len(aTo) = 2, "the amount field is reached from two places")

	# binds is the clause that makes a world ONE world: a game entity that
	# IS a declared business entity, not a copy of one.
	aBind = oW.ReferencesFrom("entity:player")
	? ""
	? "the gamification clause:"
	? "   entity:player --" + aBind[1][:kind] + "-> " + aBind[1][:to] +
	  "   (" + aBind[1][:file] + ":" + aBind[1][:line] + ")"
	Assert(aBind[1][:kind] = "binds", "a .game entity BINDS a declared entity")

#---------------------------------------------------------------- 5

func Part5_TheRefusals()
	? ""
	? "5. THE REFUSALS -- each with a sibling that must NOT fire"
	? Copy("-", 74)
	? "   Every one is a C2 v1.0 envelope with language 'world'."
	? ""

	# -- dangling reference
	cBad = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "flow", "name": "f", "span": { "file": "a.zql", "line": 3 } } ],
	  "refs": [ { "from": "flow:f", "to": "norm:nope", "kind": "enforces",
	              "span": { "file": "a.zql", "line": 7 } } ] }'
	Refuses(cBad, "DANGLING_REFERENCE", "a ref to something nothing declares")

	cOk = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "flow", "name": "f", "span": { "file": "a.zql", "line": 3 } },
	               { "kind": "norm", "name": "nope", "span": { "file": "a.zql", "line": 5 } } ],
	  "refs": [ { "from": "flow:f", "to": "norm:nope", "kind": "enforces",
	              "span": { "file": "a.zql", "line": 7 } } ] }'
	Accepts(cOk, "the same ref, once the norm is declared")

	# -- duplicate, and the CASE collision that motivates the rule
	cDup = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "entity", "name": "Deposit", "span": { "file": "a.zql", "line": 3 } },
	               { "kind": "entity", "name": "deposit", "span": { "file": "b.zql", "line": 4 } } ],
	  "refs": [] }'
	Refuses(cDup, "DUPLICATE_SYMBOL",
		"two entities differing ONLY by case -- the graph lower-cases ids")

	cKinds = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "entity", "name": "member", "span": { "file": "a.zql", "line": 3 } },
	               { "kind": "actor", "name": "member", "span": { "file": "a.zql", "line": 4 } } ],
	  "refs": [] }'
	Accepts(cKinds, "the same name under two KINDS is not a collision")

	# -- closed sets
	cKind = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "widget", "name": "w", "span": { "file": "a.zql", "line": 3 } } ],
	  "refs": [] }'
	Refuses(cKind, "UNKNOWN_SYMBOL_KIND", "a kind outside the closed ten")

	cRefKind = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "flow", "name": "f", "span": { "file": "a.zql", "line": 3 } },
	               { "kind": "norm", "name": "n", "span": { "file": "a.zql", "line": 5 } } ],
	  "refs": [ { "from": "flow:f", "to": "norm:n", "kind": "sort_of_uses",
	              "span": { "file": "a.zql", "line": 7 } } ] }'
	Refuses(cRefKind, "UNKNOWN_REFERENCE_KIND", "a relation outside the closed nine")

	# -- the node-id rule
	cName = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "entity", "name": "two words", "span": { "file": "a.zql", "line": 3 } } ],
	  "refs": [] }'
	Refuses(cName, "MALFORMED_NAME", "a name with a space, which no node id may carry")

	# -- the version gate
	cVer = '{ "world": "x", "contract": "9.9", "symbols": [], "refs": [] }'
	Refuses(cVer, "CONTRACT_MISMATCH", "a world emitted against a version we do not implement")

	# -- a warning is not an error: the world still loads
	cWarn = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "entity", "name": "e", "span": { } } ],
	  "refs": [] }'
	oW = StzWorldGraphQ(cWarn)
	? PadR("  MISSING_SPAN", 30) + "warning, and the world is still lawful : " +
	  oW.IsLawful()
	Assert(oW.IsLawful(), "a warning does not make a world unlawful")
	Assert(len(oW.Diagnostics()) = 1, "but it IS reported")

	# -- refusals are COLLECTED, not raised on the first
	cMany = '{ "world": "x", "contract": "1.0",
	  "symbols": [ { "kind": "nope", "name": "a", "span": { "file": "a.zql", "line": 1 } },
	               { "kind": "alsonope", "name": "b", "span": { "file": "a.zql", "line": 2 } } ],
	  "refs": [] }'
	oW = StzWorldGraphQ(cMany)
	? PadR("  two bad kinds", 30) + "diagnostics collected : " + len(oW.Diagnostics())
	Assert(len(oW.Diagnostics()) = 2,
		"a build wants the whole list, not the first refusal")

	# -- the envelope itself
	? ""
	? "the envelope a refusal travels in:"
	oW = StzWorldGraphQ(cBad)
	d = oW.Diagnostics()[1]
	? "   code     : " + d[:code]
	? "   severity : " + d[:severity]
	? "   span     : " + d[:span][:file] + ":" + d[:span][:line]
	? "   cites    : [] (honest -- no pinned law applies to a structural finding)"
	? "   language : " + d[:language]
	? "   message  : " + d[:message]

	Assert(d[:language] = "world", "language names the court")
	Assert(len(d[:cites]) = 0, "cites is empty, which C2 explicitly allows")

#---------------------------------------------------------------- helpers

func Refuses(pcJson, pcCode, pcWhy)
	oW = StzWorldGraphQ(pcJson)
	bFound = FALSE
	aD = oW.Diagnostics()
	nLen = len(aD)
	for i = 1 to nLen
		if aD[i][:code] = pcCode
			bFound = TRUE
		ok
	next
	? PadR("  " + pcCode, 30) + "REFUSED : " + pcWhy
	Assert(bFound, pcCode + " fired")
	Assert(NOT oW.IsLawful(), pcCode + " makes the world unlawful")

func Accepts(pcJson, pcWhy)
	oW = StzWorldGraphQ(pcJson)
	? PadR("  (sibling)", 30) + "accepted: " + pcWhy
	Assert(oW.IsLawful(), "the sibling must NOT be refused: " + pcWhy)

func Assert(bCond, cWhat)
	if NOT bCond
		? ""
		? "   *** FAILED: " + cWhat
		? ""
		raise("guard failed: " + cWhat)
	ok

func PadR(cText, nWidth)
	cOut = "" + cText
	while len(cOut) < nWidth
		cOut += " "
	end
	return cOut
