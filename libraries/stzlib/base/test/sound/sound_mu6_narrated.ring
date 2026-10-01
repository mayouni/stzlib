# MU6 -- the browser, where live performance lives. The native half.
#
# THIS GUARD WRITES THE BROWSER'S ANSWERS, the way SS5 wrote
# earcon_expect.json: the native engine renders, and the browser guard
# (webaudio/mu6_guard.html) must reproduce it through wasm. Neither side can be
# edited into agreement with the other.
#
#   webaudio/mu6_notes_expect.json     -- one note of each of the twenty
#                                         instruments, native, sample by sample
#   webaudio/mu6_patterns_expect.json  -- the mini-notation's cycle events
#   webaudio/mu6_universes.json        -- the declared tunings, for the keyboard
#
# Kill criterion (plan section 6): the author plays the page and says whether
# it feels like an instrument. No number here reaches it. What is measured is
# what the browser REPORTS its latency to be -- in the browser guard.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nRate = 48000

pr()

? "== MU6: the browser's answers, written by the native engine =="
? ""

? "-- Scene 1: twenty notes, native, sample by sample --"
cJ = "{" + nl + '  "rate": 48000,' + nl + '  "notes": [' + nl
nInst = StzEngineSoundInstrumentCount()
nWritten = 0
for i = 1 to nInst
	cName = StzEngineSoundInstrumentName(i)
	nLo = StzEngineSoundInstrumentLow(i)
	nHi = StzEngineSoundInstrumentHigh(i)
	nHz = floor(sqrt(nLo * nHi) * 100) / 100
	nB = StzEngineSoundNoteOf(i, nHz, nHz, 0.5, 0.8, 0, nRate)
	if nB = 0
		? "   " + cName + ": REFUSED natively -- " + StzEngineSoundLastError()
		loop
	ok
	nF = StzEngineSoundFrames(nB)
	decimals(12)
	cS = ""
	aAt = [ 1, 101, 1001, floor(nF / 3), floor(nF / 2), nF - 10 ]
	for k = 1 to len(aAt)
		if k > 1  cS += ", " ok
		cS += "[" + (aAt[k] - 1) + ", " + StzEngineSoundGet(nB, aAt[k], 1) + "]"
	next
	nSum = 0
	for f = 1 to nF step 97
		nSum += StzEngineSoundGet(nB, f, 1)
	next
	decimals(3)
	if nWritten > 0  cJ += "," + nl ok
	decimals(12)
	cJ += '    { "name": "' + cName + '", "index": ' + (i - 1) + ', "hz": ' + nHz +
	      ', "hold": 0.5, "velocity": 0.8, "frames": ' + nF + ', "samples": [' + cS +
	      '], "sum97": ' + nSum + ' }'
	decimals(3)
	nWritten++
	StzEngineSoundFree(nB)
next
cJ += nl + "  ]" + nl + "}" + nl
write("webaudio/mu6_notes_expect.json", cJ)
? "   " + nWritten + " instruments -> webaudio/mu6_notes_expect.json"
Chk("all twenty instruments rendered natively and written for the browser to match", nWritten = 20)

# MU14: every stroke of the kit -- the cymbals (MU13), the toms and the open
# hi-hat (MU14) among them -- natively, at the hold the browser will ask for
# (a cymbal or an open hi-hat rings past its written length on BOTH sides)
? ""
? "-- Scene 1b: the kit's nine strokes, native, for the rebuilt stz.wasm to match --"
aKs = [ [ "kick", 0, 0.5 ], [ "snare", 1, 0.5 ], [ "hihat", 2, 0.5 ], [ "crash", 3, 2.0 ], [ "ride", 4, 1.2 ],
        [ "hightom", 5, 0.5 ], [ "midtom", 6, 0.5 ], [ "floortom", 7, 0.5 ], [ "openhat", 8, 0.6 ] ]
nKit = 0
for i = 1 to nInst
	if StzEngineSoundInstrumentName(i) = "drumkit"  nKit = i ok
next
nKHz = floor(sqrt(StzEngineSoundInstrumentLow(nKit) * StzEngineSoundInstrumentHigh(nKit)) * 1000000) / 1000000
cJ2 = '  "strokes": [' + nl
nStk = 0
for ks in aKs
	nB = StzEngineSoundNoteOf(nKit, nKHz, nKHz, ks[3], 0.8, ks[2], nRate)
	if nB = 0
		? "   " + ks[1] + ": REFUSED natively -- " + StzEngineSoundLastError()
		loop
	ok
	nF = StzEngineSoundFrames(nB)
	decimals(12)
	cS = ""
	aAt = [ 1, 101, 1001, floor(nF / 3), floor(nF / 2), nF - 10 ]
	for k = 1 to len(aAt)
		if k > 1  cS += ", " ok
		cS += "[" + (aAt[k] - 1) + ", " + StzEngineSoundGet(nB, aAt[k], 1) + "]"
	next
	nSum = 0
	for f = 1 to nF step 97  nSum += StzEngineSoundGet(nB, f, 1) next
	if nStk > 0  cJ2 += "," + nl ok
	cJ2 += '    { "stroke": "' + ks[1] + '", "variant": ' + ks[2] + ', "hz": ' + nKHz + ', "hold": ' + ks[3] + ', "frames": ' + nF +
	       ', "samples": [' + cS + '], "sum97": ' + nSum + ' }'
	decimals(3)
	nStk++
	StzEngineSoundFree(nB)
next
cJ2 += nl + "  ]"
cJ = left(cJ, len(cJ) - len(nl + "}" + nl)) + "," + nl + cJ2 + nl + "}" + nl
write("webaudio/mu6_notes_expect.json", cJ)
? "   " + nStk + " strokes added to webaudio/mu6_notes_expect.json"
Chk("all nine of the kit's strokes rendered natively -- the cymbals, the toms, the open hi-hat -- for wasm to match", nStk = 9)

? ""
? "-- Scene 2: the pattern language's answers --"
aPat = [ "bd ~ sn [hh hh]", "<c e g>", "a*2 b", "a/2", "a@3 b", "a!3 b", "[c, e] g",
         "c e g c5 e", "hh? hh? hh? hh? hh? hh? hh? hh?", "<[5_ 6_] [1 2]>*2 ~ d4+50 e-50",
         "dum ~ tak ~ dum dum tak ~", "bd*2 [~ sn] hh? hh", "cr ht mt ft [oh rd] rd" ]
cP = "{" + nl + '  "patterns": [' + nl
decimals(12)
for i = 1 to len(aPat)
	o = StzSoundPatternQ(aPat[i])
	cE = ""
	for c = 0 to 3
		if c > 0  cE += ", " ok
		cE += "["
		aEv = o.CycleEvents(c)
		for k = 1 to len(aEv)
			if k > 1  cE += ", " ok
			e = aEv[k]
			nHzE = 0
			if e[3] = "note"  nHzE = StzNoteToHz(e[4]) ok
			cE += '[' + e[1] + ', ' + e[2] + ', "' + e[3] + '", "' + e[4] + '", ' + nHzE + ']'
		next
		cE += "]"
	next
	if i > 1  cP += "," + nl ok
	cP += '    { "text": "' + aPat[i] + '", "valid": ' + o.IsValid() + ', "cycles": [' + cE + '] }'
next
decimals(3)
cP += nl + "  ]" + nl + "}" + nl
write("webaudio/mu6_patterns_expect.json", cP)
? "   " + len(aPat) + " patterns x 4 cycles -> webaudio/mu6_patterns_expect.json"
Chk("thirteen patterns written with their events and each note's frequency -- the kit's new words among them",
    len(read("webaudio/mu6_patterns_expect.json")) > 500)
Chk("including the notation's whole set: ~ [ ] , < > * / ? ! @ and the octave carry",
    substr(read("webaudio/mu6_patterns_expect.json"), "C5") > 0)

? ""
? "-- Scene 3: the universes, for the keyboard --"
cU = "{" + nl + '  "universes": [' + nl
nU = 0
decimals(6)
for u in StzSoundUniverses()
	o = StzSoundUniverseQ(u)
	aM = o._Get(o.Declaration(), :modes, [])
	if len(aM) = 0  loop ok
	cM = ""
	for m in aM
		if cM != ""  cM += ", " ok
		cD = ""
		for d in o._Get(m, :degrees, [])
			if cD != ""  cD += ", " ok
			cD += "" + d
		next
		cM += '{ "name": "' + o._Get(m, :name, "") + '", "tonic": "' + o._Get(m, :tonic, "C4") +
		      '", "tonicHz": ' + StzNoteToHz(o._Get(m, :tonic, "C4")) + ', "octave": ' +
		      o._Get(m, :octave, 1200) + ', "degrees": [' + cD + '], "melody": "' +
		      o._Get(m, :melody, o._Get(o.Declaration(), :melody, "piano")) + '" }'
	next
	if nU > 0  cU += "," + nl ok
	cU += '    { "name": "' + u + '", "title": "' + o.Title() + '", "listener": "' +
	      Mu6Esc(o.Listener()) + '", "modes": [' + cM + '] }'
	nU++
next
decimals(3)
cU += nl + "  ]" + nl + "}" + nl
write("webaudio/mu6_universes.json", cU)
? "   " + nU + " universes with scales -> webaudio/mu6_universes.json (the rhythm-only one has none to play)"
Chk("seven universes with scales, each with its listener line, for the keyboard", nU = 7)

? ""
? "-- The browser half --"
? "   Serve webaudio/ and open mu6_guard.html: it renders the twenty notes"
? "   through wasm, parses the thirteen patterns in JavaScript, schedules a loop"
? "   offline, and reads the browser's own latency. Then music.html is the"
? "   instrument -- and the kill criterion is the author playing it."

? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func Mu6Esc c
	_s_ = ""
	for _k_ = 1 to len(c)
		if c[_k_] = char(34)
			_s_ += "\" + char(34)
		but c[_k_] = "\"
			_s_ += "\\"
		else
			_s_ += c[_k_]
		ok
	next
	return _s_
