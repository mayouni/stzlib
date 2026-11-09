load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-MODELDATA-01 (stzlib-security, 2026-11-05), built by the intelligence plane 2026-11-08.
#
# A model file comes from outside -- a converted release, a copy somebody shared -- and a model copy's chat template
# has already been the way in elsewhere: a backdoored chat_template.jinja escaped Jinja's sandbox when a server
# rendered it. The rule here is that a model file is DATA: nothing in it is run as code, and a file that lies about
# itself is refused by a status, never by the process ending.
#
#   (a) nothing reads tokenizer.chat_template, nothing names Jinja, the engine sources that read model metadata start
#       no process and load no library, and the library code that receives metadata text evaluates none of it --
#       then the same rule shown at run time, on files whose metadata carries code;
#   (b) the GGUF reader and the loaders behind it, fed files that lie: wrong types, out-of-range numbers, ids outside
#       their tables, a missing tensor, a shape that does not agree, counts and lengths no file could hold, and cuts.
#       Each case below is one CLASS the discovery fuzzer found ending the process on 2026-11-08 (149 of 714 mutants
#       of MiniLM did; after the fix, 0). The fuzzer itself is base/test/security/gguf_fuzz.py: it drives the
#       exported text path in a child process per mutant and is the deep sweep; this guard is the gate.
#   (c) the OCR and vision models (SECURITY-MODELDATA-01c): they carry a PROGRAM the engine runs, a line per
#       operation, and every operation now checks what ggml would assert and Zig would panic on before it calls
#       ggml; a text tower's token ids are checked against its table; a picture projector loads only when its
#       weights agree with its sizes. The fuzzer reaches them through stz_graph_probe and stz_vlm_probe.
#
# A mutant is the real model with one part rewritten. Rewriting a value moves everything after the metadata, so a
# padding key (stz.pad) keeps the move a multiple of the file's 32-byte alignment and every tensor stays where its
# offset says. Each mutant is trusted for this process only (StzExpectModelDigest), as a user trusts a file they
# chose: the digest gate is not what is tested here, the reader behind it is.

cMini = StzModelsDir() + "/all-MiniLM-L6-v2.Q8_0.gguf"
cSmol = StzModelsDir() + "/smollm2-135m-instruct-q8_0.gguf"
cOcrDir = StzOcrModelDir()
cPng = "../ocr/_data/facts/facts_s1.png"
cTmp = sysget("TEMP") + "/stz_modeldata"
StzMakeDir(cTmp)
cText = "a model file is data"
cSentinel = cTmp + "/payload_ran.txt"
if fexists(cSentinel)  remove(cSentinel)  ok
cMDRan = "no"

cSeed = read(cMini)

#----------------------------------------------------------------------------------------------------- (a) static

Scenario("A1. nothing in the engine or the library reads a chat template or names Jinja")
	aZig = _FilesIn("../../../engine/src", ".zig", "")
	aRing = _FilesIn("../..", ".ring", "test")
	Then("the scan reads the engine's sources (more than 100 .zig files)", len(aZig) > 100, 1)
	Then("...and the library's (more than 1000 .ring files outside the tests)", len(aRing) > 1000, 1)
	Then("the scan finds what IS read: tokenizer.ggml.tokens, in 2 or more engine sources",
		len(_Naming(aZig, "tokenizer.ggml.tokens")) >= 2, 1)
	Then("no engine source names chat_template", _Show(_Naming(aZig, "chat_template")), "")
	Then("...or Jinja", _Show(_Naming(aZig, "jinja")), "")
	Then("no library file names chat_template", _Show(_Naming(aRing, "chat_template")), "")
	Then("...or Jinja", _Show(_Naming(aRing, "jinja")), "")
EndScenario()

Scenario("A2. the engine sources that read model metadata start no process and load no library")
	aMeta = []
	for cF in aZig
		cC = read(cF)
		if _Has(cC, "gguf_read.zig") or _Has(cC, "gguf_get_") or _Has(cC, "gguf_find_key")
			aMeta + cF
		ok
	next
	Then("they are found by what they call, not by a list: 8 or more", len(aMeta) >= 8, 1)
	Then("...the metadata door among them", _Show(_Naming(aMeta, "fn arrStr(")) != "", 1)
	for cWord in [ "std.process.Child", "CreateProcess", "ShellExecute", "LoadLibrary", "dlopen", "popen(", "system(" ]
		Then("none calls " + cWord, _Show(_Naming(aMeta, cWord)), "")
	next
EndScenario()

Scenario("A3. the library code that receives metadata text evaluates none of it")
	aRecv = []
	for cF in aRing
		cC = read(cF)
		for cFn in [ "StzEngineNeuralModelArch", "StzEngineNeuralVocabToken", "StzEngineNeuralModelKey",
		             "StzEngineNeuralModelTensorName", "StzEngineNeuralGgufInspectArch", "StzEngineNeuralTensorNames" ]
			if _Has(cC, cFn + "(")
				aRecv + cF
				exit
			ok
		next
	next
	Then("the receivers are found by the calls they make (the model class among them)",
		_Show(_Naming(aRecv, "class stzNeuralModel")) != "", 1)
	Then("none of them calls eval()", _Show(_Naming(aRecv, "eval(")), "")
	Then("...or runs a system command", _Show(_Naming(aRecv, "system(")), "")
EndScenario()

#----------------------------------------------------------------------------------------------------- (a) at run time

Scenario("A4. an architecture name that is Ring code is returned, shown and recorded as text")
	cCode = 'cMDRan = "arch" write("' + cSentinel + '", "ran")'
	cM = _Mutant(cTmp, "arch_code", _SetKv(cSeed, "general.architecture", _TStr(cCode)))
	oM = StzNeuralModelQ(cM)
	Then("the file loads: a name is only a name", oM.IsLoaded(), 1)
	Then("Arch() returns the code as text, byte for byte", oM.Arch(), cCode)
	Then("Content() carries it as a value", oM.Content()[1][2], cCode)
	Then("with no known architecture there are no sizes, so no embedding", len(oM.EmbeddingOf(cText)), 0)
	Then("the code never ran: the variable it sets is untouched", cMDRan, "no")
	Then("...and the file it writes does not exist", fexists(cSentinel), 0)
EndScenario()

Scenario("A5. a chat template carrying code is never read -- the generator still answers")
	if fexists(cSmol)
		cTpl = '{{ raise_exception("ran") }}{% for m in messages %}' + 'cMDRan = "template" write("' + cSentinel + '", "ran"){% endfor %}'
		cG = _Mutant(cTmp, "template_code", _SetKv(read(cSmol), "tokenizer.chat_template", _TStr(cTpl)))
		Then("the generator loads with the template in it", StzEngineNeuralModelLoad(cG), 1)
		Then("...and is a generator", StzHasGenerativeModel(), 1)
		cP = StzChatPrompt("", "Say yes.")
		Then("the chat prompt is built from the vocabulary: the template's text is nowhere in it", _Has(cP, "raise_exception"), 0)
		cOut = StzEngineNeuralGenerate(cP, 3)
		Then("the model generates", isString(cOut), 1)
		Then("the code never ran: the variable is untouched", cMDRan, "no")
		Then("...and the file does not exist", fexists(cSentinel), 0)
		StzEngineNeuralModelFree()
	else
		? "  NOT RUN: A5 -- no " + cSmol + " on this machine"
	ok
EndScenario()

#----------------------------------------------------------------------------------------------------- (b) the reader

Scenario("B0. the rewriter is faithful: the seed, padded, still loads and embeds")
	cM = _Mutant(cTmp, "same", _SetKv(cSeed, "general.name", _TStr("all-MiniLM-L6-v2, rewritten")))
	Then("the rewritten file loads", StzEngineNeuralModelLoad(cM), 1)
	Then("...and embeds (384 numbers): every later refusal is the reader's, not the rewriter's", StzEngineNeuralEmbed(cText), 384)
EndScenario()

Scenario("B1. a value of the wrong type is no value (the process used to end at load)")
	_Case(cTmp, "arch_u32", _SetKv(cSeed, "general.architecture", _LE(4, 4) + _LE(7, 4)), "load", 1, "architecture a number: the file loads, unnamed")
	Then("...its architecture reads empty", StzEngineNeuralModelArch(), "")
	Then("...and it embeds nothing", StzEngineNeuralEmbed(cText), 0)
	_Case(cTmp, "arch_arr", _SetKv(cSeed, "general.architecture", _LE(9, 4) + _LE(4, 4) + _LE(3, 8) + _LE(1, 4) + _LE(2, 4) + _LE(3, 4)), "embed", 0, "architecture an array of numbers")
	_Case(cTmp, "tokens_u32", _SetKv(cSeed, "tokenizer.ggml.tokens", _LE(9, 4) + _LE(4, 4) + _LE(3, 8) + _LE(1, 4) + _LE(2, 4) + _LE(3, 4)), "tokenize", 0, "vocabulary an array of numbers: nothing tokenizes")
	_Case(cTmp, "eps_str", _SetKv(cSeed, "bert.attention.layer_norm_epsilon", _TStr("1e-12")), "embed", 384, "epsilon a string: the default is used, and the model still runs")
	cI = _Mutant(cTmp, "arch_u32", _SetKv(cSeed, "general.architecture", _LE(4, 4) + _LE(7, 4)))
	StzExpectModelDigest(cI, StzModelDigest(cI))
	Then("the inspector reads the same file: its 101 tensors", StzEngineNeuralGgufInspect(cI), 101)
	Then("...and no architecture", StzEngineNeuralGgufInspectArch(), "")
EndScenario()

Scenario("B2. numbers out of range are not sizes (a panic in a cast, or a negative count)")
	_Case(cTmp, "embd_u64max", _SetKv(cSeed, "bert.embedding_length", _LE(10, 4) + copy(char(255), 8)), "embed", 0, "embedding length 2^64-1")
	_Case(cTmp, "layers_neg", _SetKv(cSeed, "bert.block_count", _LE(5, 4) + _LE(-1, 4)), "embed", 0, "block count -1")
	_Case(cTmp, "heads_i64min", _SetKv(cSeed, "bert.attention.head_count", _LE(11, 4) + copy(char(0), 7) + char(128)), "embed", 0, "head count -2^63")
EndScenario()

Scenario("B3. every id the graph looks up is a row of its table")
	_Case(cTmp, "cls_neg", _SetKv(cSeed, "tokenizer.ggml.cls_token_id", _LE(5, 4) + _LE(-1, 4)), "embed", 0, "cls id -1 (read before the table's first row)")
	_Case(cTmp, "sep_past", _SetKv(cSeed, "tokenizer.ggml.seperator_token_id", _LE(4, 4) + _LE(1000000, 4)), "embed", 0, "sep id 1000000 (past the table's last row)")
EndScenario()

Scenario("B4. a missing tensor, and a shape that does not agree with the model's own sizes")
	_Case(cTmp, "tensor_missing", _Rename(cSeed, "blk.3.attn_q.weight", "blk.3.attn_Q.weight"), "embed", 0, "blk.3.attn_q.weight renamed away (a null the graph took with .?)")
	_Case(cTmp, "tensor_transposed", _Transpose(cSeed, "blk.2.ffn_down.weight"), "embed", 0, "blk.2.ffn_down.weight transposed (a GGML_ASSERT in mul_mat)")
	_Case(cTmp, "no_tensors", left(cSeed, 8) + _LE(0, 8) + substr(cSeed, 17, len(cSeed) - 16), "embed", 0, "header says 0 tensors")
EndScenario()

Scenario("B5. counts, lengths and cuts no file could hold are refused at load, by status")
	_Case(cTmp, "nkv_huge", left(cSeed, 16) + copy(char(255), 7) + char(127) + substr(cSeed, 25, len(cSeed) - 24), "load", 0, "2^63-1 keys")
	_Case(cTmp, "keylen_huge", left(cSeed, 24) + copy(char(255), 8) + substr(cSeed, 33, len(cSeed) - 32), "load", 0, "first key 2^64-1 bytes long")
	_Case(cTmp, "cut_meta", left(cSeed, 300000), "load", 0, "cut inside the vocabulary")
	_Case(cTmp, "cut_data", left(cSeed, len(cSeed) - 1), "load", 0, "one byte short of the last tensor")
	Then("a refused load says why: the file cannot be read (-1)", StzModelLoadStatus(), -1)
EndScenario()

Scenario("B6. the OCR recogniser: its dictionary and its graph program are data too")
	if fexists(cOcrDir + "/ppocr_rec.gguf") and fexists(cOcrDir + "/ppocr_det.gguf")
		cD = cTmp + "/ocr"
		StzMakeDir(cD)
		for cF in [ "ppocr_det.gguf", "ppocr_cls.gguf" ]
			write(cD + "/" + cF, read(cOcrDir + "/" + cF))
			StzExpectModelDigest(cD + "/" + cF, StzModelDigest(cD + "/" + cF))
		next
		cRec = read(cOcrDir + "/ppocr_rec.gguf")
		_Ocr(cD, "rec_same.gguf", _SetKv(cRec, "general.name", _TStr("rewritten")))
		Then("the faithful rewrite reads the page", len(StzEngineNeuralOcrReadWith(cD, "rec_same.gguf", cPng, 2)) > 0, 1)
		_Ocr(cD, "rec_dict_u32.gguf", _SetKv(cRec, "stz.ocr.character", _LE(9, 4) + _LE(4, 4) + _LE(1, 8) + _LE(7, 4)))
		Then("a dictionary of numbers reads nothing", len(StzEngineNeuralOcrReadWith(cD, "rec_dict_u32.gguf", cPng, 2)), 0)
		# a program line names an operation of a closed set the engine implements, on tensors it holds: a line that
		# names anything else is refused, and so is text that is not a line at all
		_Ocr(cD, "rec_program.gguf", _SetKv(cRec, "stz.ocr.program", _LE(9, 4) + _LE(8, 4) + _LE(1, 8) + _Str("y=system(x;cmd=calc.exe;r=4)")))
		Then("a well-formed line naming an operation the graph does not have reads nothing", len(StzEngineNeuralOcrReadWith(cD, "rec_program.gguf", cPng, 2)), 0)
		Then("...and says the runner does not know it", _Has(StzEngineNeuralOcrGraphError(), "op system is not one the runner knows"), 1)
		_Ocr(cD, "rec_notaline.gguf", _SetKv(cRec, "stz.ocr.program", _LE(9, 4) + _LE(8, 4) + _LE(1, 8) + _Str("system calc.exe")))
		Then("text that is not a program line reads nothing", len(StzEngineNeuralOcrReadWith(cD, "rec_notaline.gguf", cPng, 2)), 0)
		Then("...and says the line is bad", _Has(StzEngineNeuralOcrGraphError(), "BadLine"), 1)
		_Ocr(cD, "rec_dir_u32.gguf", _SetKv(cRec, "stz.ocr.direction", _LE(4, 4) + _LE(1, 4)))
		Then("a direction that is a number is no direction: the page still reads", len(StzEngineNeuralOcrReadWith(cD, "rec_dir_u32.gguf", cPng, 2)) > 0, 1)
	else
		? "  NOT RUN: B6 -- no OCR models in " + cOcrDir
	ok
EndScenario()

Scenario("B8. the generator: sizes that disagree with its own tensors are refused")
	if fexists(cSmol)
		# a head_count_kv of the wrong type falls back to head_count (9 where the K and V tensors hold 3): a reshape
		# asserted inside ggml and the process ended
		cG = _Mutant(cTmp, "gen_kvheads_str", _SetKv(read(cSmol), "llama.attention.head_count_kv", _TStr("3")))
		Then("the file loads, and is a generator", StzEngineNeuralModelLoad(cG) + StzHasGenerativeModel(), 2)
		Then("...and generates nothing", StzEngineNeuralGenerate("Say yes.", 3), "")
		StzEngineNeuralModelFree()
	else
		? "  NOT RUN: B8 -- no " + cSmol + " on this machine"
	ok
EndScenario()

#----------------------------------------------------------------------------------------------------- (c) the graphs

# SECURITY-MODELDATA-01c. The OCR and vision models carry a PROGRAM the engine runs, a line per operation, and the
# shapes it runs on come from the file (the weights) and from the caller (the picture). Every operation now states
# what ggml would assert and what Zig would panic on, before it calls ggml: a line that lies is refused with a
# message naming what is wrong. Each case below ended the process on the previous engine.

Scenario("C1. a program line that lies is refused, saying what is wrong")
	if fexists(cOcrDir + "/ppocr_rec.gguf") and fexists(cOcrDir + "/ppocr_det.gguf")
		# a folder of its own: the pipeline keeps at most 8 recognisers per folder in one process, and B6 used 4
		cD = cTmp + "/ocr_c1"
		StzMakeDir(cD)
		for cF in [ "ppocr_det.gguf", "ppocr_cls.gguf" ]
			write(cD + "/" + cF, read(cOcrDir + "/" + cF))
			StzExpectModelDigest(cD + "/" + cF, StzModelDigest(cD + "/" + cF))
		next
		cRec = read(cOcrDir + "/ppocr_rec.gguf")
		aProg = _ProgramLines(cRec)
		Then("the recogniser's program is read: its first line is a convolution", left(aProg[1], 8), "t1=conv(")
		aCases = [
			[ 1, "t1=conv(x,c0;s=0,2;p=1,1;dw=0;r=4)", "attribute s[0] = 0", "a stride of 0 (a division by zero)" ],
			[ 1, "t1=conv(x,c0;s=2,2;p=2147483647,1;dw=0;r=4)", "attribute p[0] = 2147483647", "a padding of 2^31-1 (an overflow)" ],
			[ 2, "t2=add(t1,c0;r=4)", "does not broadcast", "an add of two shapes that do not broadcast" ],
			[ 3, "t3=slice(t2;d=0;o=5;n=999999;r=4)", "slice:", "a slice past the end" ],
			[ 3, "t3=permute(t2;p=0,0,1,2;r=4)", "permute: axis", "a permutation that repeats an axis" ]
		]
		nC = len(aCases)
		for i = 1 to nC
			aP = aProg
			aP[aCases[i][1]] = aCases[i][2]
			cName = "rec_lie" + i + ".gguf"
			_Ocr(cD, cName, _SetKv(cRec, "stz.ocr.program", _Lines(aP)))
			Then(aCases[i][4] + ": nothing is read", len(StzEngineNeuralOcrReadWith(cD, cName, cPng, 2)), 0)
			Then("...and the refusal says why", _Has(StzEngineNeuralOcrGraphError(), aCases[i][3]), 1)
		next
		Then("the real recogniser still reads the page", len(StzEngineNeuralOcrReadWith(cOcrDir, "", cPng, 2)) > 0, 1)
	else
		? "  NOT RUN: C1 -- no OCR models in " + cOcrDir
	ok
EndScenario()

Scenario("C2. a text tower's token id outside its table is refused at the lookup")
	# a text tower made here from nothing: a 10-row table and a tokenizer of four letters whose end-of-text id is
	# the file's to state. ggml checks a lookup's range only while computing, and that check ends the process
	cT = _TextTower(cTmp, "tower_eos_ok", 3)
	Then("with its end-of-text id inside the table the tower runs (4 tokens x 4 numbers)", len(StzEngineNeuralVisionEmbedText(cT, "abc", 2)), 16)
	cT = _TextTower(cTmp, "tower_eos_999", 999)
	Then("with an end-of-text id of 999 it reads nothing", len(StzEngineNeuralVisionEmbedText(cT, "abc", 2)), 0)
	Then("...and says the id is not a row of the table", _Has(StzEngineNeuralOcrGraphError(), "id 999 is not a row of the 10-row table"), 1)
	cT = _TextTower(cTmp, "tower_eos_huge", 4000000000)
	Then("an end-of-text id past the i32 range reads (the default id is used), it does not end the process", len(StzEngineNeuralVisionEmbedText(cT, "abc", 2)), 16)
EndScenario()

Scenario("C3. a picture projector whose weights disagree with its sizes does not load")
	cPj = StzModelsDir() + "/vision/smolvlm_256m_mmproj.gguf"
	if fexists(cPj)
		cPx = copy(char(128), 4 * 4 * 3)
		cSeedP = read(cPj)
		cOk = _Mutant(cTmp, "proj_same", _SetKv(cSeedP, "general.name", _TStr("rewritten")))
		Then("the faithful rewrite encodes a picture", len(StzEngineNeuralVlmEmbed(cOk, cPx, 4, 4, 3, 2)) > 0, 1)
		cBad = _Mutant(cTmp, "proj_pos_transposed", _Transpose(cSeedP, "v.position_embd.weight"))
		Then("with its position table transposed it encodes nothing", len(StzEngineNeuralVlmEmbed(cBad, cPx, 4, 4, 3, 2)), 0)
		Then("...and says a weight disagrees with its sizes", _Has(StzEngineNeuralOcrGraphError(), "disagrees with its sizes"), 1)
		cSeedP = ""
	else
		? "  NOT RUN: C3 -- no " + cPj + " on this machine"
	ok
EndScenario()

Scenario("B7. after every refusal the process is whole: the real model loads and embeds")
	Then("MiniLM loads", StzEngineNeuralModelLoad(cMini), 1)
	Then("...and embeds", StzEngineNeuralEmbed(cText), 384)
	StzEngineNeuralModelFree()
EndScenario()

Summary()
shutdown($_zst_fail)

#----------------------------------------------------------------------------------------------------- helpers

# one mutant: written, trusted for this process, then one step run on it and its answer compared
func _Case(pcTmp, pcName, pcBytes, pcStep, pnWant, pcSay)
	_cP_ = _Mutant(pcTmp, pcName, pcBytes)
	StzExpectModelDigest(_cP_, StzModelDigest(_cP_))
	_nL_ = StzEngineNeuralModelLoad(_cP_)
	if pcStep = "load"
		Then(pcSay + " -> load " + pnWant, _nL_, pnWant)
		return
	ok
	_n_ = 0
	if _nL_ = 1
		if pcStep = "embed"
			_n_ = StzEngineNeuralEmbed("a model file is data")
		but pcStep = "tokenize"
			_n_ = StzEngineNeuralTokenize("a model file is data")
		ok
	ok
	Then(pcSay + " -> " + pcStep + " " + pnWant, _n_, pnWant)

func _Ocr(pcDir, pcName, pcBytes)
	write(pcDir + "/" + pcName, pcBytes)
	StzExpectModelDigest(pcDir + "/" + pcName, StzModelDigest(pcDir + "/" + pcName))

func _Mutant(pcTmp, pcName, pcBytes)
	_cP_ = pcTmp + "/" + pcName + ".gguf"
	write(_cP_, pcBytes)
	StzExpectModelDigest(_cP_, StzModelDigest(_cP_))
	return _cP_

# little-endian, nBytes long; a negative number in two's complement (nBytes up to 4)
func _LE(n, nBytes)
	_n_ = n
	if _n_ < 0
		_n_ = _n_ + pow(2, 8 * nBytes)
	ok
	_c_ = ""
	for _k_ = 1 to nBytes
		_c_ += char(_n_ % 256)
		_n_ = floor(_n_ / 256)
	next
	return _c_

# the unsigned number at byte nAt (1-based), nBytes long
func _U(pcS, nAt, nBytes)
	_n_ = 0
	for _k_ = nBytes to 1 step -1
		_n_ = _n_ * 256 + ascii(pcS[nAt + _k_ - 1])
	next
	return _n_

# a string key's type and value, as _SetKv takes them
func _TStr(pcText)
	return _LE(8, 4) + _Str(pcText)

# a GGUF string value: its length, then its bytes
func _Str(pcText)
	return _LE(len(pcText), 8) + pcText

func _Scalar(nType)
	_a_ = [ 1, 1, 2, 2, 4, 4, 4, 1, 0, 0, 8, 8, 8 ]
	return _a_[nType + 1]

func _SkipVal(pcS, nAt, nType)
	if nType = 8
		return nAt + 8 + _U(pcS, nAt, 8)
	but nType = 9
		_nEt_ = _U(pcS, nAt, 4)
		_nN_ = _U(pcS, nAt + 4, 8)
		_p_ = nAt + 12
		if _nEt_ = 8
			for _i_ = 1 to _nN_
				_p_ = _p_ + 8 + _U(pcS, _p_, 8)
			next
			return _p_
		ok
		return _p_ + _nN_ * _Scalar(_nEt_)
	ok
	return nAt + _Scalar(nType)

# the key/value rows: [ key, type, where the key starts, where the value starts, where the next key starts ]
func _Kvs(pcS)
	_nKv_ = _U(pcS, 17, 8)
	_p_ = 25
	_a_ = []
	for _i_ = 1 to _nKv_
		_nL_ = _U(pcS, _p_, 8)
		_cK_ = ""
		for _j_ = 1 to _nL_
			_cK_ += pcS[_p_ + 7 + _j_]
		next
		_nT_ = _U(pcS, _p_ + 8 + _nL_, 4)
		_nV_ = _p_ + 12 + _nL_
		_nE_ = _SkipVal(pcS, _nV_, _nT_)
		_a_ + [ _cK_, _nT_, _p_, _nV_, _nE_ ]
		_p_ = _nE_
	next
	return _a_

# the file with key pcKey's type-and-value replaced by pcTV (or the key added), and a stz.pad key that keeps the
# metadata's change of length a multiple of 32, so every tensor's offset still holds
func _SetKv(pcS, pcKey, pcTV)
	_aK_ = _Kvs(pcS)
	_nN_ = len(_aK_)
	_nEnd_ = _aK_[_nN_][5]
	_cB_ = ""
	_bFound_ = 0
	for _i_ = 1 to _nN_
		if _aK_[_i_][1] = pcKey
			_cB_ += _Str(pcKey) + pcTV
			_bFound_ = 1
		else
			_cB_ += substr(pcS, _aK_[_i_][3], _aK_[_i_][5] - _aK_[_i_][3])
		ok
	next
	if _bFound_ = 0
		_cB_ += _Str(pcKey) + pcTV
	ok
	_nDelta_ = len(_cB_) + 8 + 7 + 4 + 8 - (_nEnd_ - 25)
	_nPad_ = ((32 - (_nDelta_ % 32)) % 32 + 32) % 32
	_cB_ += _Str("stz.pad") + _LE(8, 4) + _Str(copy(" ", _nPad_))
	_nKv_ = _nN_ + 1
	if _bFound_ = 0  _nKv_ = _nKv_ + 1  ok
	return left(pcS, 16) + _LE(_nKv_, 8) + _cB_ + substr(pcS, _nEnd_, len(pcS) - _nEnd_ + 1)

# where tensor pcName's info starts: the byte of its name's length (the infos follow the metadata)
func _TensorAt(pcS, pcName)
	_aK_ = _Kvs(pcS)
	_p_ = _aK_[len(_aK_)][5]
	_nT_ = _U(pcS, 9, 8)
	for _i_ = 1 to _nT_
		_nL_ = _U(pcS, _p_, 8)
		_cN_ = ""
		for _j_ = 1 to _nL_
			_cN_ += pcS[_p_ + 7 + _j_]
		next
		if _cN_ = pcName  return _p_  ok
		_nD_ = _U(pcS, _p_ + 8 + _nL_, 4)
		_p_ = _p_ + 8 + _nL_ + 4 + 8 * _nD_ + 4 + 8
	next
	return 0

# a tensor renamed to a name of the same length: nothing moves
func _Rename(pcS, pcFrom, pcTo)
	_n_ = _TensorAt(pcS, pcFrom)
	return left(pcS, _n_ + 7) + pcTo + substr(pcS, _n_ + 8 + len(pcFrom), len(pcS) - _n_ - 7 - len(pcFrom))

# a 2-D tensor's two sizes swapped: same bytes, wrong shape
func _Transpose(pcS, pcName)
	_n_ = _TensorAt(pcS, pcName)
	_d_ = _n_ + 8 + len(pcName) + 4
	return left(pcS, _d_ - 1) + substr(pcS, _d_ + 8, 8) + substr(pcS, _d_, 8) + substr(pcS, _d_ + 16, len(pcS) - _d_ - 15)

# the lines of a graph model's program (stz.ocr.program, an array of strings)
func _ProgramLines(pcS)
	_aK_ = _Kvs(pcS)
	_n_ = len(_aK_)
	for _i_ = 1 to _n_
		if _aK_[_i_][1] = "stz.ocr.program"
			_p_ = _aK_[_i_][4]
			_nL_ = _U(pcS, _p_ + 4, 8)
			_p_ = _p_ + 12
			_a_ = []
			for _j_ = 1 to _nL_
				_nB_ = _U(pcS, _p_, 8)
				_a_ + substr(pcS, _p_ + 8, _nB_)
				_p_ = _p_ + 8 + _nB_
			next
			return _a_
		ok
	next
	return []

# an array of strings, as _SetKv takes it
func _Lines(paLines)
	_c_ = _LE(9, 4) + _LE(8, 4) + _LE(len(paLines), 8)
	for _x_ in paLines
		_c_ += _Str(_x_)
	next
	return _c_

# a text tower made from nothing: the program looks the ids up in a 10 x 4 table (zeros), the tokenizer knows four
# letters and no merges, a text is 4 ids long, and the end-of-text id is pnEos. Written, then trusted for this process.
func _TextTower(pcTmp, pcName, pnEos)
	_aV_ = [ "a", "b", "c", "d" ]
	_cKv_ = _Str("general.architecture") + _LE(8, 4) + _Str("stz-ocr-graph")
	_cKv_ += _Str("stz.ocr.kind") + _LE(8, 4) + _Str("text")
	_cKv_ += _Str("stz.ocr.output") + _LE(8, 4) + _Str("y")
	_cKv_ += _Str("stz.ocr.program") + _Lines([ "y=embed(c0,x;r=3)" ])
	_cKv_ += _Str("stz.tok.vocab") + _Lines(_aV_)
	_cKv_ += _Str("stz.tok.merge_a") + _Lines([])
	_cKv_ += _Str("stz.tok.merge_b") + _Lines([])
	if pnEos > 2147483647
		_cKv_ += _Str("stz.tok.eos") + _LE(10, 4) + _LE(pnEos, 8)
	else
		_cKv_ += _Str("stz.tok.eos") + _LE(4, 4) + _LE(pnEos, 4)
	ok
	_cKv_ += _Str("stz.tok.pad") + _LE(4, 4) + _LE(0, 4)
	_cKv_ += _Str("stz.graph.seq") + _LE(4, 4) + _LE(4, 4)
	_cInfo_ = _Str("c0") + _LE(2, 4) + _LE(4, 8) + _LE(10, 8) + _LE(0, 4) + _LE(0, 8)
	_cHead_ = "GGUF" + _LE(3, 4) + _LE(1, 8) + _LE(10, 8) + _cKv_ + _cInfo_
	_nPad_ = (32 - (len(_cHead_) % 32)) % 32
	return _Mutant(pcTmp, pcName, _cHead_ + copy(char(0), _nPad_) + copy(char(0), 4 * 10 * 4))

func _Has(pcText, pcNeedle)
	return len(StzFindCS(pcNeedle, pcText, 0)) > 0

# the files, of the paths given, whose text names pcNeedle (any case)
func _Naming(paFiles, pcNeedle)
	_a_ = []
	for _cF_ in paFiles
		if _Has(read(_cF_), pcNeedle)
			_a_ + _cF_
		ok
	next
	return _a_

func _Show(paList)
	_c_ = ""
	for _x_ in paList
		_c_ += _x_ + " "
	next
	return _c_

# every file under pcDir ending in pcExt, skipping a folder named pcSkip
func _FilesIn(pcDir, pcExt, pcSkip)
	_aOut_ = []
	_aTodo_ = [ pcDir ]
	while len(_aTodo_) > 0
		_cD_ = _aTodo_[1]
		del(_aTodo_, 1)
		_aL_ = dir(_cD_)
		for _r_ in _aL_
			if _r_[2] = 1
				if _r_[1] != pcSkip and left(_r_[1], 1) != "."
					_aTodo_ + (_cD_ + "/" + _r_[1])
				ok
			but right(_r_[1], len(pcExt)) = pcExt
				_aOut_ + (_cD_ + "/" + _r_[1])
			ok
		next
	end
	return _aOut_
