# THE WHOLE PIPELINE, END TO END -- does the user's actual workload work,
# and is it actually faster?
#
# Every piece of this session's GPU work was verified in isolation: the
# backbone against numpy ground truth, the seam by route counters, the
# retrieval scan by its own guard. NONE of them answers the composite
# question: build a semantic index over a corpus, ask it a question in
# plain language, and get the right document back.
#
# And the seam created a SPECIFIC risk this guard exists to probe: indexed
# documents are long enough to cross the 32-token gate, so they are
# embedded by the GPU BACKBONE -- while a short query stays below it and is
# embedded by the CPU. A search therefore compares vectors produced by TWO
# DIFFERENT ROUTES. The routes agree at cosine 0.9999, which should be far
# more than ranking needs; "should be" is exactly the kind of assumption
# worth converting into an assertion.
#
# The negative sibling matters here too: if mixed routes DID degrade
# ranking, forcing both sides onto one route would fix it -- so the guard
# checks that the single-route answer is the SAME answer.

load "../../stzBase.ring"

nPass = 0
nFail = 0

R_GPU = 0
R_CPU = 1

pr()

decimals(6)

cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
if NOT fexists(cModel)
    ? "  no local MiniLM -- the pipeline needs a real model; skipping"
else
    StzEngineNeuralModelLoad(cModel)

    # A small corpus of REAL prose, each document long enough to cross the
    # gate (so the backbone serves it) -- the shape a documentation or
    # knowledge-base index actually has.
    aCorpus = [
        "Photosynthesis is the process by which green plants and certain " +
        "other organisms transform light energy into chemical energy, " +
        "storing it in the bonds of sugar molecules built from water and " +
        "carbon dioxide drawn from the surrounding air and soil.",

        "The migration of monarch butterflies spans thousands of kilometres " +
        "across the North American continent, with successive generations " +
        "completing different legs of a journey none of them makes alone, " +
        "navigating by the position of the sun and the earth magnetic field.",

        "A compiler translates source code written in a high level language " +
        "into machine instructions a processor can execute directly, passing " +
        "through lexical analysis, parsing, semantic checks, optimisation " +
        "and finally the emission of target code for a specific architecture.",

        "Ocean currents redistribute heat around the planet, carrying warm " +
        "water from the tropics toward the poles and cold water back again, " +
        "a circulation driven by differences in temperature and salinity " +
        "that moderates the climate of entire continents over centuries.",

        "Vaccines train the immune system by presenting it with a harmless " +
        "fragment or weakened form of a pathogen, so that memory cells can " +
        "recognise the real infection later and mount a rapid defence long " +
        "before the disease has time to establish itself in the body."
    ]

    ? "-- Scene 1: the corpus crosses the gate; the query does not --"
    nDocTok = StzEngineNeuralTokenize(aCorpus[1])
    cQuery = "how do plants make food from sunlight"
    nQryTok = StzEngineNeuralTokenize(cQuery)
    ? "  a document = " + nDocTok + " tokens ; the query = " + nQryTok + " tokens" +
      " (gate = " + StzEngineNeuralBackboneMinTokens() + ")"
    chk("documents are ABOVE the gate (they take the backbone)",
        nDocTok >= StzEngineNeuralBackboneMinTokens())
    chk("the query is BELOW it (it takes the CPU) -- the routes will MIX",
        nQryTok < StzEngineNeuralBackboneMinTokens())

    ? ""
    ? "-- Scene 2: building the index really does use both routes --"
    StzEngineNeuralBackboneRouteReset()
    oIdx = new stzSemanticIndex(aCorpus)
    chk("the index holds every document", oIdx.Count() = len(aCorpus))
    chk("...at 384 dims", oIdx.EmbeddingDim() = 384)
    nGpuUsed = StzEngineNeuralBackboneRouteCount(R_GPU)
    ? "  documents embedded by the backbone: " + nGpuUsed + " of " + len(aCorpus)
    chk("the BACKBONE embedded the documents (the mechanism, not the vibe)",
        nGpuUsed = len(aCorpus))

    ? ""
    ? "-- Scene 3: the composite question -- does search still find truth? --"
    aQueries = [
        [ "how do plants make food from sunlight", 1 ],
        [ "insects travelling huge distances each year", 2 ],
        [ "turning a program into instructions a cpu runs", 3 ],
        [ "why the sea moves heat around the world", 4 ],
        [ "how immunisation prepares the body to fight illness", 5 ]
    ]
    nHits = 0
    aRanks = []
    for q = 1 to len(aQueries)
        StzEngineNeuralBackboneRouteReset()
        _aRes_ = oIdx.SearchXT(aQueries[q][1], 1)
        _nPos_ = _aRes_[1][3]
        aRanks + _nPos_
        if _nPos_ = aQueries[q][2]
            nHits++
            ? "  [hit] '" + aQueries[q][1] + "' -> doc " + _nPos_ +
              "  (cos " + _aRes_[1][2] + ")"
        else
            ? "  [MISS] '" + aQueries[q][1] + "' -> doc " + _nPos_ +
              ", wanted " + aQueries[q][2]
        ok
    next
    chk("every plain-language query found its document ACROSS MIXED ROUTES (" +
        nHits + "/" + len(aQueries) + ")", nHits = len(aQueries))
    chk("...and the query itself went the CPU way (it is short)",
        StzEngineNeuralBackboneRouteCount(R_CPU) >= 1)

    ? ""
    ? "-- Scene 4: the negative sibling -- one route gives the SAME answer --"
    # force EVERYTHING onto the CPU and rebuild: if mixing routes had
    # degraded ranking, this is where the answers would diverge
    StzEngineNeuralBackboneSetMinTokens(1000000)
    oIdxCpu = new stzSemanticIndex(aCorpus)
    bSameRanks = TRUE
    for q = 1 to len(aQueries)
        _aRes_ = oIdxCpu.SearchXT(aQueries[q][1], 1)
        if _aRes_[1][3] != aRanks[q]
            bSameRanks = FALSE
        ok
    next
    chk("a CPU-only index ranks IDENTICALLY -- mixing routes changed nothing",
        bSameRanks)
    oIdxCpu.Close()

    ? ""
    ? "-- Scene 5: and it is faster where the work is (index building) --"
    nT0 = StzEngineWatchTimestampNs()
    _o1_ = new stzSemanticIndex(aCorpus)
    nCpuBuildMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
    _o1_.Close()
    StzEngineNeuralBackboneSetMinTokens(32)
    nT0 = StzEngineWatchTimestampNs()
    _o2_ = new stzSemanticIndex(aCorpus)
    nGpuBuildMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
    _o2_.Close()
    ? "  index build over " + len(aCorpus) + " documents: CPU " + nCpuBuildMs +
      " ms vs routed " + nGpuBuildMs + " ms  (" + (nCpuBuildMs / nGpuBuildMs) + "x)"
    chk("building the index is faster through the seam", nGpuBuildMs < nCpuBuildMs)

    oIdx.Close()
    StzEngineNeuralModelFree()
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
