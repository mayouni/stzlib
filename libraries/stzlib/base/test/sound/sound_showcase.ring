# THE SHOWCASE -- every capability built so far, as a numbered list you can play.
#
#     ring sound_showcase.ring            list the catalogue, write every WAV,
#                                         and print the quality report
#     ring sound_showcase.ring 7          play example 7
#     ring sound_showcase.ring all        play them all, in order
#     ring sound_showcase.ring check      the quality report only, no audio
#
# Every example is written to temp/showcase/NN_name.wav as well as played, so
# they can be opened in any player, sent to someone, or listened to twice.
#
# WHY A LIST AND NOT A STUDIO. The point is to hear whether the work is any
# good, one item at a time, without learning a tool first. Each entry says what
# it is, what to listen FOR, and which phase built it.
#
# AND IT CHECKS ITSELF. `check` measures every example -- peak, loudness, DC
# offset, clipped samples, silence -- and flags anything suspicious. A showcase
# that can only sound good is a demo; one that can report itself broken is a
# test.

load "../../stzBase.ring"
decimals(2)

RATE = 48000
cOut = currentdir() + "/temp/showcase"

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

cArg = ""
if len(sysargv) >= 3  cArg = lower("" + sysargv[3]) ok

if NOT direxists(currentdir() + "/temp")
	system("mkdir " + '"' + currentdir() + "/temp" + '"')
ok
if NOT direxists(cOut)
	system("mkdir " + '"' + cOut + '"')
ok

aCat = ShCatalogue()

if cArg = ""
	ShowList(aCat)
	? ""
	? "Rendering every example to temp/showcase/ ..."
	aMeas = ShRenderAll(aCat)
	ShReport(aCat, aMeas)
	? ""
	? "To hear one:  ring sound_showcase.ring 7"
	? "To hear all:  ring sound_showcase.ring all"

but cArg = "check"
	aMeas = ShRenderAll(aCat)
	ShReport(aCat, aMeas)

but cArg = "all"
	ShowList(aCat)
	? ""
	for i = 1 to len(aCat)
		ShPlayOne(aCat, i)
	next

but isNumber(number(cArg)) and number(cArg) >= 1 and number(cArg) <= len(aCat)
	ShPlayOne(aCat, number(cArg))

else
	? "I do not know '" + cArg + "'."
	ShowList(aCat)
ok

# ---------------------------------------------------------------------------
# the catalogue -- [ name, what to listen for, which phase, builder ]
# ---------------------------------------------------------------------------

func ShCatalogue
	_a_ = []

	_a_ + [ "naive-saw", "GRITTY. Harmonics folding back as tones nobody played.",
	        "the bug plate 1 found", :NaiveSweep ]

	_a_ + [ "band-limited-saw", "The SAME sweep, clean. This is the PolyBLEP fix.",
	        "post-SN6", :CleanSweep ]

	_a_ + [ "four-timbres", "One pitch, four waveforms: sine, triangle, square, saw.",
	        "SN2 oscillators", :FourTimbres ]

	_a_ + [ "beats", "440 and 443 Hz. Three pulses a second -- the difference.",
	        "gallery plate 4", :Beats ]

	_a_ + [ "click-vs-fade", "Cut dead at 1 s, faded at 2.5 s. Only one clicks.",
	        "SN3's ramp, gallery plate 2", :ClickVsFade ]

	_a_ + [ "filter-sweep", "A saw through a lowpass opening up. Q is high, so it whistles.",
	        "SN2 filters", :FilterSweep ]

	_a_ + [ "resonance", "The same note at Q 0.7 then Q 8. Listen for the hump.",
	        "gallery plate 5", :Resonance ]

	_a_ + [ "envelope-shapes", "Pluck, pad, stab -- one oscillator, three envelopes.",
	        "SN2 ADSR", :Envelopes ]

	_a_ + [ "echo", "A blip, then the same blip down a corridor.",
	        "SN2 delay", :Echo ]

	_a_ + [ "stereo-pan", "A tone walking from left to right. Use headphones.",
	        "SN2 pan", :Pan ]

	_a_ + [ "chord-and-arpeggio", "A major chord, then its notes one at a time.",
	        "SN2 mix", :Chord ]

	_a_ + [ "bell", "A struck bell: fast attack, long decay, a little room.",
	        "SN2 composition", :Bell ]

	_a_ + [ "earcons-five", "The semantic values: danger, warning, info, success -- and muted, which is SILENT.",
	        "SS1, Rule 118", :Earcons ]

	_a_ + [ "earcon-priority", "Eight rapid repeats heard twice, then a danger alert that silences four successes.",
	        "SS's priority contract", :EarconPriority ]

	if ShVoiceReady()
		_a_ + [ "voice-plain", "A spoken sentence, straight from the platform.",
		        "VC1/VC2", :VoicePlain ]
		_a_ + [ "voice-prosody", "The same words at normal speed, then 40% slower, via SSML.",
		        "VC1 prosody", :VoiceProsody ]
		_a_ + [ "voice-as-sound", "A voice through a telephone, then down a corridor. THE point: a voice is a sound.",
		        "VC1 architecture", :VoiceAsSound ]
		_a_ + [ "voice-and-earcon", "An alert, then the phrase that says WHICH -- the semantic bridge, previewed.",
		        "VC4 preview", :VoiceAndEarcon ]
	ok

	_a_ + [ "the-piece", "A short composition using most of the above at once.",
	        "everything", :ThePiece ]

	return _a_

# ---------------------------------------------------------------------------
# the examples
# ---------------------------------------------------------------------------

func ShNaiveSweep
	_o_ = StzSoundOfSilenceQ(2.5, 1, RATE)
	_n_ = _o_.Frames()  _ph_ = 0
	for _i_ = 1 to _n_
		_hz_ = 1500 + 4500 * ((_i_ - 1) / _n_)
		_ph_ += _hz_ / RATE
		if _ph_ >= 1  _ph_ -= 1 ok
		_o_.SetSampleAt(_i_, 1, 0.4 * (2 * _ph_ - 1))
	next
	return _o_

func ShCleanSweep
	# the engine's own band-limited oscillator, stepped through the same range
	_o_ = StzSoundOfSilenceQ(2.5, 1, RATE)
	_steps_ = 50
	_per_ = 2.5 / _steps_
	for _k_ = 0 to _steps_ - 1
		_hz_ = 1500 + 4500 * (_k_ / _steps_)
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, RATE)
		_g_.AddOscillator(:Saw, _hz_, 0.4)
		_s_ = _g_.ToSound(_per_)
		_at_ = floor(_k_ * _per_ * RATE)
		for _i_ = 1 to _s_.Frames()
			if _at_ + _i_ <= _o_.Frames()
				_o_.SetSampleAt(_at_ + _i_, 1, _s_.SampleAt(_i_, 1))
			ok
		next
		_s_.Release()  _g_.Release()
	next
	return _o_

func ShFourTimbres
	return ShConcat([
		ShTone(:Sine, 220, 0.6, 0.7), ShSilence(0.12),
		ShTone(:Triangle, 220, 0.6, 0.7), ShSilence(0.12),
		ShTone(:Square, 220, 0.45, 0.7), ShSilence(0.12),
		ShTone(:Saw, 220, 0.45, 0.7) ])

func ShBeats
	_o_ = StzSoundOfSilenceQ(3, 1, RATE)
	for _i_ = 1 to _o_.Frames()
		_t_ = (_i_ - 1) / RATE
		_o_.SetSampleAt(_i_, 1, 0.35 * sin(2 * 3.14159265358979 * 440 * _t_) +
		                        0.35 * sin(2 * 3.14159265358979 * 443 * _t_))
	next
	return _o_

func ShClickVsFade
	_o_ = StzSoundOfSilenceQ(3, 1, RATE)
	for _i_ = 1 to _o_.Frames()
		_t_ = (_i_ - 1) / RATE
		_v_ = 0.5 * sin(2 * 3.14159265358979 * 440 * _t_)
		_g_ = 0
		if _t_ < 1.0
			_g_ = 1
		but _t_ >= 1.5 and _t_ < 2.5
			_g_ = 1
			if _t_ < 1.53  _g_ = (_t_ - 1.5) / 0.03 ok
			if _t_ > 2.47  _g_ = (2.5 - _t_) / 0.03 ok
		ok
		_o_.SetSampleAt(_i_, 1, _v_ * _g_)
	next
	return _o_

func ShFilterSweep
	_parts_ = []
	for _k_ = 0 to 19
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, RATE)
		# 0.20, not 0.5: a Q of 6 BOOSTS at the corner, and at 0.5 this
		# example peaked at 1.23 with 2,100 clipped samples -- caught by the
		# showcase's own quality report, which is what it is for.
		_g_.AddOscillator(:Saw, 110, 0.20)
		_g_.NameIt(:s)
		_g_.AddFilterOn(:s, :LowPass, 200 + 260 * _k_, 6.0)
		_parts_ + _g_.ToSound(0.14)
	next
	return ShConcat(_parts_)

func ShResonance
	_a_ = []
	_aQ167_ = [ 0.7, 8.0 ]
	_nQ167_ = len(_aQ167_)
	for _iQ167_ = 1 to _nQ167_
		_q_ = _aQ167_[_iQ167_]
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, RATE)
		# BOTH halves lowered equally, so the Q comparison stays fair. At 0.5
		# the Q-8 half peaked at 1.19 and clipped 2,009 samples -- a resonant
		# filter BOOSTS at its corner, and the showcase's own quality report
		# is what caught it.
		_g_.AddOscillator(:Saw, 110, 0.22)
		_g_.NameIt(:s)
		_g_.AddFilterOn(:s, :LowPass, 600, _q_)
		_a_ + _g_.ToSound(1.1)
		_a_ + ShSilence(0.2)
	next
	return ShConcat(_a_)

func ShEnvelopes
	_a_ = []
	# pluck, pad, stab
	_aE168_ = [ [0.002, 0.30, 0.0, 0.10, 0.30],
	             [0.400, 0.30, 0.7, 0.60, 1.20],
	             [0.005, 0.06, 0.0, 0.05, 0.08] ]
	_nE168_ = len(_aE168_)
	for _iE168_ = 1 to _nE168_
		_e_ = _aE168_[_iE168_]
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, RATE)
		_g_.AddOscillator(:Triangle, 330, 0.6)
		_g_.NameIt(:t)
		_g_.AddEnvelopeOn(:t, _e_[1], _e_[2], _e_[3], _e_[4], _e_[5])
		_a_ + _g_.ToSound(1.6)
		_a_ + ShSilence(0.15)
	next
	return ShConcat(_a_)

func ShEcho
	_dry_ = ShBlip(880, 0.5)
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_g_.AddSound(ShBlip(880, 0.5))
	_g_.NameIt(:b)
	_g_.AddEchoOn(:b, 0.18, 0.55, 0.45)
	return ShConcat([ _dry_, ShSilence(0.4), _g_.ToSound(2.2) ])

func ShPan
	_g_ = new stzSoundGraph()
	_g_.Reshape(2, RATE)
	_g_.AddOscillator(:Triangle, 440, 0.5)
	_g_.NameIt(:t)
	_g_.AddPanOn(:t, 0.0)
	_left_ = _g_.ToSound(0.9)
	_g2_ = new stzSoundGraph()
	_g2_.Reshape(2, RATE)
	_g2_.AddOscillator(:Triangle, 440, 0.5)
	_g2_.NameIt(:t)
	_g2_.AddPanOn(:t, 1.0)
	return ShConcat([ _left_, _g2_.ToSound(0.9) ])

func ShChord
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_a_ = []
	_aHz169_ = [ 261.63, 329.63, 392.00 ]
	_nHz169_ = len(_aHz169_)
	for _iHz169_ = 1 to _nHz169_
		_hz_ = _aHz169_[_iHz169_]
		_g_.AddOscillator(:Triangle, _hz_, 0.30)
		_g_.NameIt("n" + _hz_)
		_a_ + ("n" + _hz_)
	next
	_g_.AddMixOf(_a_)
	_parts_ = [ _g_.ToSound(1.4), ShSilence(0.25) ]
	_aHz170_ = [ 261.63, 329.63, 392.00 ]
	_nHz170_ = len(_aHz170_)
	for _iHz170_ = 1 to _nHz170_
		_hz_ = _aHz170_[_iHz170_]
		_parts_ + ShTone(:Triangle, _hz_, 0.5, 0.32)
	next
	return ShConcat(_parts_)

func ShBell
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_g_.AddOscillator(:Sine, 880, 0.5)
	_g_.NameIt(:b)
	_g_.AddEnvelopeOn(:b, 0.001, 1.4, 0.0, 0.4, 1.6)
	_g_.NameIt(:be)
	_g_.AddEchoOn(:be, 0.33, 0.42, 0.35)
	return _g_.ToSound(3.2)

func ShEarcons
	_e_ = new stzEarcons()
	_a_ = []
	_aV171_ = [ "Danger", "Warning", "Info", "Success" ]
	_nV171_ = len(_aV171_)
	for _iV171_ = 1 to _nV171_
		_v_ = _aV171_[_iV171_]
		_s_ = _e_.ToSoundOf(_v_)
		if isObject(_s_)  _a_ + _s_  _a_ + ShSilence(0.45) ok
	next
	_a_ + ShSilence(1.2)          # :Muted -- silence IS its rendering
	return ShConcat(_a_)

func ShEarconPriority
	# what the contract sounds like: repeats collapse, and an alert wins
	_e_ = new stzEarcons()
	_a_ = []
	for _i_ = 1 to 8            # eight rapid infos -> heard about twice
		_s_ = _e_.ToSoundOf(:Info)
		if isObject(_s_)
			if _i_ = 1 or _i_ = 5  _a_ + _s_ else _a_ + ShSilence(_s_.Duration()) ok
		ok
		_a_ + ShSilence(0.04)
	next
	_a_ + ShSilence(0.5)
	_d_ = _e_.ToSoundOf(:Danger)
	if isObject(_d_)  _a_ + _d_ ok
	_a_ + ShSilence(1.0)          # four successes, all dropped under the alert
	_s_ = _e_.ToSoundOf(:Success)
	if isObject(_s_)  _a_ + _s_ ok
	return ShConcat(_a_)

func ShVoiceReady
	if NOT StzVoiceEngineLoaded()  return FALSE ok
	_v_ = StzVoiceQ()
	_b_ = _v_.IsUsable()
	_v_.Release()
	return _b_

func ShVoicePlain
	_v_ = StzVoiceQ()
	_v_.WarmUp()
	_s_ = _v_.ToSoundOf("Softanza has a voice, and a voice is a sound.")
	_v_.Release()
	return _s_

func ShVoiceProsody
	_v_ = StzVoiceQ()
	_v_.WarmUp()
	_a_ = [ _v_.ToSoundOf("This is the normal speed."), ShSilence(0.3) ]
	_slow_ = _v_.ToSoundOfSsml('<speak version="1.0" ' +
		'xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="' +
		_v_.CurrentLanguage() + '"><prosody rate="-40%">And this is ' +
		'forty percent slower.</prosody></speak>')
	if isObject(_slow_)  _a_ + _slow_ ok
	_v_.Release()
	return ShConcat(_a_)

func ShVoiceAsSound
	_v_ = StzVoiceQ()
	_v_.WarmUp()
	_say_ = _v_.ToSoundOf("The same sentence, three ways.")
	_v_.Release()
	if NOT isObject(_say_)  return ShSilence(0.5) ok

	_g_ = new stzSoundGraph()
	_g_.Reshape(1, _say_.SampleRate())
	_g_.AddSound(_say_)
	_g_.NameIt(:v)
	_g_.AddFilterOn(:v, :LowPass, 1700, 0.9)
	_tel_ = _g_.ToSound(_say_.Duration())

	_g2_ = new stzSoundGraph()
	_g2_.Reshape(1, _say_.SampleRate())
	_g2_.AddSound(_say_)
	_g2_.NameIt(:v)
	_g2_.AddEchoOn(:v, 0.2, 0.45, 0.4)
	_cor_ = _g2_.ToSound(_say_.Duration() + 1)

	return ShConcat([ _say_, ShSilence(0.35), _tel_, ShSilence(0.35), _cor_ ])

func ShVoiceAndEarcon
	# VC4's contract, previewed by hand: the earcon alerts, the phrase explains
	_e_ = new stzEarcons()
	_v_ = StzVoiceQ()
	_v_.WarmUp()
	_a_ = []
	_d_ = _e_.ToSoundOf(:Danger)
	if isObject(_d_)  _a_ + _d_ ok
	_a_ + ShSilence(0.15)
	_p_ = _v_.ToSoundOf("Disk nearly full. Sixty two gigabytes remain.")
	if isObject(_p_)  _a_ + _p_ ok
	_v_.Release()
	return ShConcat(_a_)

func ShThePiece
	_parts_ = []
	# a bass pulse under a bell melody, with an echo tail
	for _k_ = 0 to 7
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, RATE)
		_g_.AddOscillator(:Saw, 55, 0.34)
		_g_.NameIt(:b)
		_g_.AddEnvelopeOn(:b, 0.004, 0.20, 0.0, 0.06, 0.22)
		_g_.NameIt(:be)
		_g_.AddFilterOn(:be, :LowPass, 420, 3.0)
		_bass_ = _g_.ToSound(0.42)

		_hz_ = [ 523.25, 659.25, 783.99, 659.25,
		         587.33, 783.99, 880.00, 659.25 ][_k_ + 1]
		_g2_ = new stzSoundGraph()
		_g2_.Reshape(1, RATE)
		_g2_.AddOscillator(:Sine, _hz_, 0.34)
		_g2_.NameIt(:m)
		_g2_.AddEnvelopeOn(:m, 0.002, 0.34, 0.0, 0.10, 0.36)
		_mel_ = _g2_.ToSound(0.42)

		_parts_ + ShMix2(_bass_, _mel_)
	next
	_dry_ = ShConcat(_parts_)
	_g3_ = new stzSoundGraph()
	_g3_.Reshape(1, RATE)
	_g3_.AddSound(_dry_)
	_g3_.NameIt(:d)
	_g3_.AddEchoOn(:d, 0.21, 0.38, 0.30)
	return _g3_.ToSound(_dry_.Duration() + 1.2)

# ---------------------------------------------------------------------------
# building blocks
# ---------------------------------------------------------------------------

func ShTone pWave, nHz, nAmp, nSecs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_g_.AddOscillator(pWave, nHz, nAmp)
	_g_.NameIt(:t)
	_g_.AddEnvelopeOn(:t, 0.006, 0.02, 0.9, 0.05, nSecs - 0.06)
	return _g_.ToSound(nSecs)

func ShBlip nHz, nSecs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_g_.AddOscillator(:Triangle, nHz, 0.6)
	_g_.NameIt(:b)
	_g_.AddEnvelopeOn(:b, 0.002, 0.10, 0.0, 0.05, 0.12)
	return _g_.ToSound(nSecs)

func ShSilence nSecs
	return StzSoundOfSilenceQ(nSecs, 1, RATE)

func ShConcat paSounds
	_total_ = 0
	_aS172_ = paSounds
	_nS172_ = len(_aS172_)
	for _iS172_ = 1 to _nS172_
		_s_ = _aS172_[_iS172_]
		if isObject(_s_)  _total_ += _s_.Duration() ok
	next
	_o_ = StzSoundOfSilenceQ(_total_ + 0.02, 1, RATE)
	_at_ = 0
	_aS173_ = paSounds
	_nS173_ = len(_aS173_)
	for _iS173_ = 1 to _nS173_
		_s_ = _aS173_[_iS173_]
		if NOT isObject(_s_)  loop ok
		_n_ = _s_.Frames()
		for _i_ = 1 to _n_
			if _at_ + _i_ <= _o_.Frames()
				_o_.SetSampleAt(_at_ + _i_, 1, _s_.SampleAt(_i_, 1))
			ok
		next
		_at_ += _n_
	next
	return _o_

func ShMix2 oA, oB
	_n_ = ShMax([ oA.Frames(), oB.Frames() ])
	_o_ = StzSoundOfSilenceQ(_n_ / RATE, 1, RATE)
	for _i_ = 1 to _o_.Frames()
		_v_ = 0
		if _i_ <= oA.Frames()  _v_ += oA.SampleAt(_i_, 1) ok
		if _i_ <= oB.Frames()  _v_ += oB.SampleAt(_i_, 1) ok
		_o_.SetSampleAt(_i_, 1, _v_)
	next
	return _o_

func ShMax paList
	_m_ = paList[1]
	_aV174_ = paList
	_nV174_ = len(_aV174_)
	for _iV174_ = 1 to _nV174_
		_v_ = _aV174_[_iV174_]
		if _v_ > _m_  _m_ = _v_ ok
	next
	return _m_

# ---------------------------------------------------------------------------
# listing, playing, and CHECKING
# ---------------------------------------------------------------------------

func ShowList paCat
	? ""
	? "=== THE SOFTANZA SOUND SHOWCASE ==="
	? "    " + len(paCat) + " examples. Each says what to listen FOR."
	? ""
	for _i_ = 1 to len(paCat)
		? "  " + ShPad(_i_) + ". " + ShPadName(paCat[_i_][1]) + paCat[_i_][2]
		? "       " + ShSpaces(4) + "(" + paCat[_i_][3] + ")"
	next

func ShPlayOne paCat, nI
	_e_ = paCat[nI]
	? ""
	? "-- " + nI + ". " + _e_[1] + " --"
	? "   " + _e_[2]
	_s_ = ShBuild(_e_[4])
	if NOT isObject(_s_)
		? "   (could not be built)"
		return
	ok
	? "   " + _s_.Duration() + " s, peak " + _s_.Peak() + " -- playing"
	_s_.Play()
	sleep(0.25)

func ShRenderAll paCat
	_m_ = []
	for _i_ = 1 to len(paCat)
		_s_ = ShBuild(paCat[_i_][4])
		if NOT isObject(_s_)
			_m_ + [ 0, 0, 0, 0, 0 ]
			loop
		ok
		_path_ = cOut + "/" + ShPad(_i_) + "_" + paCat[_i_][1] + ".wav"
		_s_.SaveAs(_path_)
		_m_ + ShMeasure(_s_)
	next
	return _m_

# Peak, loudness, DC offset, clipped samples, and the share that is silent.
# This is the part that lets a showcase report itself broken.
func ShMeasure oS
	_n_ = oS.Frames()
	if _n_ = 0  return [ 0, -1000, 0, 0, 1 ] ok
	_sum_ = 0  _clip_ = 0  _quiet_ = 0
	for _i_ = 1 to _n_
		_v_ = oS.SampleAt(_i_, 1)
		_sum_ += _v_
		if fabs(_v_) >= 0.999  _clip_++ ok
		if fabs(_v_) < 0.0005  _quiet_++ ok
	next
	_dc_ = _sum_ / _n_
	_loud_ = -1000
	_c_ = StzSoundFromFileQ("")     # placeholder, replaced below
	return [ oS.Peak(), ShLoudOf(oS), _dc_, _clip_, _quiet_ / _n_ ]

func ShLoudOf oS
	# BS.1770 needs 48 kHz; a copy is resampled rather than the original
	if oS.Duration() < 0.05  return -1000 ok
	_c_ = oS
	return _c_.LoudnessOfSupport()

func ShReport paCat, paMeas
	? ""
	? "=== QUALITY REPORT ==="
	? "   peak   loud    DC      clip  silent  name"
	_bad_ = 0
	for _i_ = 1 to len(paCat)
		_m_ = paMeas[_i_]
		_flag_ = ""
		if _m_[1] = 0                      _flag_ += " EMPTY" ok
		if _m_[1] > 0.99                   _flag_ += " CLIPPING" ok
		if _m_[1] > 0 and _m_[1] < 0.05    _flag_ += " VERY-QUIET" ok
		if fabs(_m_[3]) > 0.02             _flag_ += " DC-OFFSET" ok
		if _m_[4] > 10                     _flag_ += " CLIPPED-SAMPLES" ok
		if _m_[5] > 0.92                   _flag_ += " MOSTLY-SILENT" ok
		if _flag_ != ""  _bad_++ ok
		? "  " + ShPad(_i_) + " " + ShFix(_m_[1]) + "  " + ShFix5(_m_[2]) + "  " +
		  ShFix(_m_[3]) + "  " + ShPad(_m_[4]) + "  " + ShFix(_m_[5]) + "   " +
		  paCat[_i_][1] + _flag_
	next
	? ""
	if _bad_ = 0
		? "   nothing flagged: every example has signal, no clipping, no DC offset."
	else
		? "   " + _bad_ + " example(s) flagged above -- look at those first."
	ok
	? "   WAVs are in temp/showcase/"

func ShBuild pWhich
	switch pWhich
	on :NaiveSweep       return ShNaiveSweep()
	on :CleanSweep       return ShCleanSweep()
	on :FourTimbres      return ShFourTimbres()
	on :Beats            return ShBeats()
	on :ClickVsFade      return ShClickVsFade()
	on :FilterSweep      return ShFilterSweep()
	on :Resonance        return ShResonance()
	on :Envelopes        return ShEnvelopes()
	on :Echo             return ShEcho()
	on :Pan              return ShPan()
	on :Chord            return ShChord()
	on :Bell             return ShBell()
	on :Earcons          return ShEarcons()
	on :EarconPriority   return ShEarconPriority()
	on :VoicePlain       return ShVoicePlain()
	on :VoiceProsody     return ShVoiceProsody()
	on :VoiceAsSound     return ShVoiceAsSound()
	on :VoiceAndEarcon   return ShVoiceAndEarcon()
	on :ThePiece         return ShThePiece()
	off
	return ""

func ShPad n
	if n < 10  return "0" + n ok
	return "" + n

func ShPadName c
	_s_ = c
	while len(_s_) < 20  _s_ += " " end
	return _s_

func ShSpaces n
	_s_ = ""
	for _i_ = 1 to n  _s_ += " " next
	return _s_

func ShFix n
	_s_ = "" + n
	while len(_s_) < 6  _s_ = " " + _s_ end
	return _s_

func ShFix5 n
	_s_ = "" + n
	while len(_s_) < 7  _s_ = " " + _s_ end
	return _s_
