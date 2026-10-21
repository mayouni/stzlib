# Where does the time go on a K4 prompt? ring _probe_gram_cost.ring <model-needle> <task> <n1> <n2> ...
load "../../stzBase.ring"
load "_modelpick.ring"
cNeedle = sysargv[3]
cTask = sysargv[4]
if _mpLoad(cNeedle) = 0 ? "NOLOAD" bye ok
cPrompt = read("_k4/p_" + cTask + ".txt")
cGrammar = read("_k4/ringpp.gbnf")
? "prompt tokens: " + StzTokenCount(cPrompt)
for i = 5 to len(sysargv)
	nN = 0 + sysargv[i]
	t0 = clock()
	cO = StzGenerateXT(cPrompt, [ [ :MaxTokens, nN ], [ :Temperature, 0 ], [ :Seed, 0 ] ])
	nPlain = (clock() - t0) / clockspersecond()
	t0 = clock()
	cG = StzGenerateXT(cPrompt, [ [ :MaxTokens, nN ], [ :Temperature, 0 ], [ :Seed, 0 ], [ :Grammar, cGrammar ] ])
	nGram = (clock() - t0) / clockspersecond()
	aR = StzLastGrammarRun()
	? "n=" + nN + "  plain " + nPlain + "s   grammar " + nGram + "s   steps=" + aR[:steps] + " judged=" + aR[:judged] + " masked=" + aR[:masked]
next
