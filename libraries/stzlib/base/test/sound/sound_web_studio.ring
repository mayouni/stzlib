# THE SOUND WEB STUDIO -- a browser front end for the sound plane.
#
# Why a web studio and not a console menu: a browser gives sliders, instant
# re-render, a waveform you can SEE, and a page that both of us can look at
# while iterating. The console studio (sound_studio.ring) is still the fastest
# way to hear one thing; this is the way to DIAL one in.
#
# Run it:
#     cd libraries/stzlib/base/test/sound
#     ring sound_web_studio.ring            -- serves on http://127.0.0.1:8730
#     ring sound_web_studio.ring 8899       -- on another port
#
# Then open http://127.0.0.1:8730 in any browser.
#
# WHAT IT DOES THAT MATTERS: every patch you dial can be copied out as READY
# RING GUARD CODE. Dial a sound until it is right, press "as guard code", paste
# it into a narrated test. That is the loop this file exists to close -- the
# studio is a test-authoring tool, not a toy.
#
# The audio is rendered by the REAL engine (stz_sound.dll), never by the
# browser. The page receives a WAV the plane produced, so what you hear in the
# browser is what the plane does. "Play on speakers" additionally drives the
# live SN3 path -- producer thread, ring buffer, device callback.

load "../../stzBase.ring"

RATE = 48000
nPort = 8730
if len(sysargv) >= 3 and isdigit(sysargv[3])
	nPort = 0 + sysargv[3]
ok

cHere = currentdir()
cTmp = cHere + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok
cHtmlPath = cHere + "/studio.html"
cWavPath = cTmp + "/studio_patch.wav"

? ""
? "  ==============================================================="
? "   THE SOFTANZA SOUND WEB STUDIO"
? "  ==============================================================="

if NOT StzSoundEngineLoaded()
	? "  stz_sound.dll did not load -- build the engine first:"
	? "      cd libraries/stzlib/engine && zig build"
	bye
ok
if NOT fexists(cHtmlPath)
	? "  studio.html is missing next to this script."
	bye
ok

bHaveDevice = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
cDeviceName = "none"
if bHaveDevice
	cDeviceName = StzEngineAudioDevName(0, StzEngineAudioDevDefaultIndex(0))
ok
? "   engine  : stz_sound.dll loaded"
? "   device  : " + cDeviceName
? ""
? "   OPEN:     http://127.0.0.1:" + nPort
? "   stop:     Ctrl+C"
? ""

oServer = new stzTcpServer()
oServer.Listen(nPort, "127.0.0.1")
if NOT oServer.IsListening()
	? "  could not listen on port " + nPort + ": " + oServer.LastError()
	? "  (is another studio already running? try: ring sound_web_studio.ring 8731)"
	bye
ok

nServed = 0
while TRUE
	oClient = oServer.AcceptOne()
	if oClient = NULL
		loop
	ok
	cReq = WsReadRequest(oClient)
	if cReq = ""
		oClient.Close()
		loop
	ok
	nServed++
	WsHandleRequest(oClient, cReq)
	oClient.Close()
end

# =========================================================================
# helpers
# =========================================================================

# Read until the end of the headers. A GET with a query string is the whole
# request, so there is no body to wait for -- which is exactly why this studio
# puts its parameters in the URL rather than in a POST body.
#
# NOTE ON THE API: stzTcpClient.Receive() returns the CLIENT (so calls chain),
# not the bytes -- the bytes are in ReceivedData(). Treating the return value
# as a string gets you "R50: Object does not support operator overloading" from
# len(), which is a puzzling way to be told you read the docs too fast.
func WsReadRequest oClient
	# AND THE OTHER HALF OF THE LESSON: accept() returns as soon as the TCP
	# handshake completes, which is BEFORE the request bytes arrive. An empty
	# read is therefore normal, not a failure -- the first version spun through
	# forty of them in microseconds, gave up, and closed the socket in the
	# client's face. Wait between empty reads; give the request up to two
	# seconds to turn up.
	_buf_ = ""
	_idle_ = 0
	while _idle_ < 200
		oClient.Receive()
		_chunk_ = oClient.ReceivedData()
		if _chunk_ != NULL and len(_chunk_) > 0
			_buf_ += _chunk_
			_idle_ = 0
			if substr(_buf_, char(13)+char(10)+char(13)+char(10)) > 0
				return _buf_
			ok
			if substr(_buf_, char(10)+char(10)) > 0
				return _buf_
			ok
		else
			_idle_++
			sleep(0.01)
		ok
	end
	return _buf_

func WsHandleRequest oClient, cReq
	_nl_ = substr(cReq, char(10))
	_line_ = cReq
	if _nl_ > 0
		_line_ = left(cReq, _nl_ - 1)
	ok
	_line_ = trim(_line_)

	# "GET /api/render?a=1 HTTP/1.1"
	_sp1_ = substr(_line_, " ")
	if _sp1_ = 0
		WsRespond(oClient, "400 Bad Request", "text/plain", "bad request line")
		return
	ok
	_rest_ = substr(_line_, _sp1_ + 1, len(_line_) - _sp1_)
	_sp2_ = substr(_rest_, " ")
	_target_ = _rest_
	if _sp2_ > 0
		_target_ = left(_rest_, _sp2_ - 1)
	ok

	_route_ = _target_
	_query_ = ""
	_qm_ = substr(_target_, "?")
	if _qm_ > 0
		_route_ = left(_target_, _qm_ - 1)
		_query_ = substr(_target_, _qm_ + 1, len(_target_) - _qm_)
	ok
	_q_ = WsParseQuery(_query_)

	? "   " + _route_

	switch _route_
	on "/"
		WsRespond(oClient, "200 OK", "text/html; charset=utf-8", read(cHtmlPath))
	on "/api/status"
		WsRespond(oClient, "200 OK", "application/json",
			'{"engine":true,"device":' + Wsiff(bHaveDevice, "true", "false") +
			',"deviceName":"' + WsJsonEscape(cDeviceName) + '","rate":' + RATE + '}')
	on "/api/render"
		WsApiRender(oClient, _q_)
	on "/api/play"
		WsApiPlay(oClient, _q_)
	on "/api/compose"
		WsApiCompose(oClient, _q_)
	on "/api/guard"
		WsRespond(oClient, "200 OK", "text/plain; charset=utf-8", WsGuardCode(_q_))
	on "/api/wav"
		if fexists(cWavPath)
			WsRespond(oClient, "200 OK", "audio/wav", read(cWavPath))
		else
			WsRespond(oClient, "404 Not Found", "text/plain", "no render yet")
		ok
	other
		WsRespond(oClient, "404 Not Found", "text/plain", "no such route: " + _route_)
	off

func WsRespond oClient, cStatus, cType, cBody
	_h_ = "HTTP/1.1 " + cStatus + char(13) + char(10) +
	      "Content-Type: " + cType + char(13) + char(10) +
	      "Content-Length: " + len(cBody) + char(13) + char(10) +
	      "Cache-Control: no-store" + char(13) + char(10) +
	      "Connection: close" + char(13) + char(10) +
	      char(13) + char(10)
	oClient.Send(_h_ + cBody)

func WsParseQuery cQ
	_out_ = []
	if cQ = ""
		return _out_
	ok
	_parts_ = split(cQ, "&")
	_n_ = len(_parts_)
	for _i_ = 1 to _n_
		_p_ = _parts_[_i_]
		_eq_ = substr(_p_, "=")
		if _eq_ > 0
			_out_ + [ left(_p_, _eq_ - 1), substr(_p_, _eq_ + 1, len(_p_) - _eq_) ]
		ok
	next
	return _out_

func WsQNum aQ, cKey, nDefault
	_n_ = len(aQ)
	for _i_ = 1 to _n_
		if aQ[_i_][1] = cKey
			return 0 + aQ[_i_][2]
		ok
	next
	return nDefault

func WsJsonEscape cS
	return StzReplace(StzReplace(cS, '\', '\\'), '"', '\"')

func Wsiff bCond, cA, cB
	if bCond
		return cA
	ok
	return cB

# -------------------------------------------------------------------------
# THE PATCH -- one voice, every stage optional. This is the shape the page's
# controls map onto, and the shape WsGuardCode() prints back out as Ring.
#
#   oscillator -> [filter] -> [envelope] -> [delay] -> pan -> gain
# -------------------------------------------------------------------------

func WsBuildPatch aQ
	_wave_ = WsQNum(aQ, "wave", 0)
	_hz_ = WsQNum(aQ, "hz", 440)
	_amp_ = WsQNum(aQ, "amp", 0.35)
	_useF_ = WsQNum(aQ, "useFilter", 0)
	_fk_ = WsQNum(aQ, "fkind", 0)
	_fc_ = WsQNum(aQ, "fcut", 8000)
	_fq_ = WsQNum(aQ, "fq", 0.707)
	_useE_ = WsQNum(aQ, "useEnv", 0)
	_a_ = WsQNum(aQ, "att", 0.01)
	_d_ = WsQNum(aQ, "dec", 0.20)
	_s_ = WsQNum(aQ, "sus", 0.60)
	_r_ = WsQNum(aQ, "rel", 0.30)
	_gate_ = WsQNum(aQ, "gate", 1.0)
	_useD_ = WsQNum(aQ, "useDelay", 0)
	_dt_ = WsQNum(aQ, "dtime", 0.25)
	_fb_ = WsQNum(aQ, "dfb", 0.40)
	_wet_ = WsQNum(aQ, "dwet", 0.40)
	_pan_ = WsQNum(aQ, "pan", 0.5)
	_secs_ = WsQNum(aQ, "secs", 2.0)

	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_n_ = StzEngineSoundGraphAddOsc(_g_, _wave_, _hz_, _amp_)
	if _useF_ = 1
		_n_ = StzEngineSoundGraphAddFilter(_g_, _n_, _fk_, _fc_, _fq_)
	ok
	if _useE_ = 1
		_n_ = StzEngineSoundGraphAddEnvelope(_g_, _n_, _a_, _d_, _s_, _r_, _gate_)
	ok
	if _useD_ = 1
		_n_ = StzEngineSoundGraphAddDelay(_g_, _n_, _dt_, _fb_, _wet_)
	ok
	_n_ = StzEngineSoundGraphAddPan(_g_, _n_, _pan_)
	_gain_ = StzEngineSoundGraphAddGain(_g_, _n_, 1.0)
	StzEngineSoundGraphSetOutput(_g_, _gain_)
	return [ _g_, _gain_, _secs_ ]

func WsApiRender oClient, aQ
	_r_ = WsBuildPatch(aQ)
	_g_ = _r_[1]
	_secs_ = _r_[3]
	if StzEngineSoundGraphPrepare(_g_) != 0
		WsRespond(oClient, "200 OK", "application/json",
			'{"ok":false,"error":"' + WsJsonEscape(StzEngineSoundGraphLastError()) + '"}')
		StzEngineSoundGraphFree(_g_)
		return
	ok
	_frames_ = floor(_secs_ * RATE)
	_t0_ = clock()
	_buf_ = StzEngineSoundGraphToBuffer(_g_, _frames_)
	_ms_ = ((clock() - _t0_) / clockspersecond()) * 1000
	if _buf_ = 0
		WsRespond(oClient, "200 OK", "application/json", '{"ok":false,"error":"render failed"}')
		StzEngineSoundGraphFree(_g_)
		return
	ok
	StzEngineSoundSaveWav(_buf_, cWavPath, 16)
	_peak_ = StzEngineSoundPeak(_buf_)
	_rms_ = StzEngineSoundRms(_buf_)
	_nodes_ = StzEngineSoundGraphNodeCount(_g_)
	StzEngineSoundFree(_buf_)
	StzEngineSoundGraphFree(_g_)
	WsRespond(oClient, "200 OK", "application/json",
		'{"ok":true,"peak":' + _peak_ + ',"rms":' + _rms_ +
		',"seconds":' + _secs_ + ',"renderMs":' + _ms_ +
		',"nodes":' + _nodes_ + ',"frames":' + _frames_ + '}')

func WsApiPlay oClient, aQ
	if NOT bHaveDevice
		WsRespond(oClient, "200 OK", "application/json", '{"ok":false,"error":"no audio device on this machine"}')
		return
	ok
	_r_ = WsBuildPatch(aQ)
	_g_ = _r_[1]
	_secs_ = _r_[3]
	if StzEngineSoundGraphPrepare(_g_) != 0
		WsRespond(oClient, "200 OK", "application/json",
			'{"ok":false,"error":"' + WsJsonEscape(StzEngineSoundGraphLastError()) + '"}')
		StzEngineSoundGraphFree(_g_)
		return
	ok
	_s_ = StzEngineSoundStreamStart(_g_, 16384)
	sleep(0.12)
	_d_ = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(_s_), 256)
	if _d_ = 0
		WsRespond(oClient, "200 OK", "application/json",
			'{"ok":false,"error":"' + WsJsonEscape(StzEngineAudioDevLastError()) + '"}')
		StzEngineSoundStreamStop(_s_)
		StzEngineSoundGraphFree(_g_)
		return
	ok
	StzEngineAudioDevPlaybackStart(_d_)
	sleep(_secs_)
	StzEngineAudioDevPlaybackStop(_d_)
	_us_ = StzEngineAudioDevPlaybackWorstUs(_d_)
	_un_ = StzEngineSoundStreamUnderruns(_s_)
	_fr_ = StzEngineAudioDevPlaybackFramesOut(_d_)
	StzEngineAudioDevPlaybackClose(_d_)
	StzEngineSoundStreamStop(_s_)
	StzEngineSoundGraphFree(_g_)
	WsRespond(oClient, "200 OK", "application/json",
		'{"ok":true,"framesOut":' + _fr_ + ',"worstUs":' + _us_ + ',"underruns":' + _un_ + '}')

func WsApiCompose oClient, aQ
	_r_ = WsBuildComposition()
	_g_ = _r_[1]
	_len_ = _r_[3]
	if StzEngineSoundGraphPrepare(_g_) != 0
		WsRespond(oClient, "200 OK", "application/json", '{"ok":false,"error":"prepare failed"}')
		StzEngineSoundGraphFree(_g_)
		return
	ok
	_t0_ = clock()
	_buf_ = StzEngineSoundGraphToBuffer(_g_, floor(_len_ * RATE))
	_ms_ = ((clock() - _t0_) / clockspersecond()) * 1000
	StzEngineSoundSaveWav(_buf_, cWavPath, 16)
	_peak_ = StzEngineSoundPeak(_buf_)
	_rms_ = StzEngineSoundRms(_buf_)
	_nodes_ = StzEngineSoundGraphNodeCount(_g_)
	StzEngineSoundFree(_buf_)
	StzEngineSoundGraphFree(_g_)
	WsRespond(oClient, "200 OK", "application/json",
		'{"ok":true,"peak":' + _peak_ + ',"rms":' + _rms_ +
		',"seconds":' + _len_ + ',"renderMs":' + _ms_ + ',"nodes":' + _nodes_ + '}')

# THE POINT OF THE WHOLE STUDIO: dial a sound, then take it away as a test.
func WsGuardCode aQ
	_wave_ = WsQNum(aQ, "wave", 0)
	_waves_ = [ "StzSoundWaveSine()", "StzSoundWaveSquare()", "StzSoundWaveSaw()", "StzSoundWaveTriangle()" ]
	_kinds_ = [ "StzSoundFilterLowPass()", "StzSoundFilterHighPass()", "StzSoundFilterBandPass()" ]
	_c_ = "# --- patch dialled in the web studio ---" + nl
	_c_ += "nG = StzEngineSoundGraphNew(2, 48000, 512)" + nl
	_c_ += "nN = StzEngineSoundGraphAddOsc(nG, " + _waves_[_wave_ + 1] + ", " +
	       WsQNum(aQ, "hz", 440) + ", " + WsQNum(aQ, "amp", 0.35) + ")" + nl
	if WsQNum(aQ, "useFilter", 0) = 1
		_c_ += "nN = StzEngineSoundGraphAddFilter(nG, nN, " + _kinds_[WsQNum(aQ, "fkind", 0) + 1] +
		       ", " + WsQNum(aQ, "fcut", 8000) + ", " + WsQNum(aQ, "fq", 0.707) + ")" + nl
	ok
	if WsQNum(aQ, "useEnv", 0) = 1
		_c_ += "nN = StzEngineSoundGraphAddEnvelope(nG, nN, " + WsQNum(aQ, "att", 0.01) + ", " +
		       WsQNum(aQ, "dec", 0.2) + ", " + WsQNum(aQ, "sus", 0.6) + ", " +
		       WsQNum(aQ, "rel", 0.3) + ", " + WsQNum(aQ, "gate", 1.0) + ")" + nl
	ok
	if WsQNum(aQ, "useDelay", 0) = 1
		_c_ += "nN = StzEngineSoundGraphAddDelay(nG, nN, " + WsQNum(aQ, "dtime", 0.25) + ", " +
		       WsQNum(aQ, "dfb", 0.4) + ", " + WsQNum(aQ, "dwet", 0.4) + ")" + nl
	ok
	_c_ += "nN = StzEngineSoundGraphAddPan(nG, nN, " + WsQNum(aQ, "pan", 0.5) + ")" + nl
	_c_ += "StzEngineSoundGraphSetOutput(nG, nN)" + nl
	_c_ += "StzEngineSoundGraphPrepare(nG)" + nl
	_c_ += "nBuf = StzEngineSoundGraphToBuffer(nG, " + floor(WsQNum(aQ, "secs", 2) * RATE) + ")" + nl
	_c_ += nl
	_c_ += "# assert what you just heard, so it stays true:" + nl
	_c_ += "Chk(""the patch renders"", nBuf != 0)" + nl
	_c_ += "Chk(""it is " + WsQNum(aQ, "secs", 2) + " seconds"", fabs(StzEngineSoundDuration(nBuf) - " +
	       WsQNum(aQ, "secs", 2) + ") < 0.01)" + nl
	_c_ += "Chk(""it is not silent"", StzEngineSoundPeak(nBuf) > 0.01)" + nl
	_c_ += "Chk(""and it does not clip"", StzEngineSoundPeak(nBuf) < 1.0)" + nl
	_c_ += nl
	_c_ += "StzEngineSoundFree(nBuf)" + nl
	_c_ += "StzEngineSoundGraphFree(nG)" + nl
	return _c_

# -------------------------------------------------------------------------
# the composition, same score as sound_studio.ring
# -------------------------------------------------------------------------

func WsAddVoice nG, nWave, nHz, nAmp, nStart, nGate, nA, nD, nSus, nR, nPan
	_o_ = StzEngineSoundGraphAddOsc(nG, nWave, nHz, nAmp)
	_e_ = StzEngineSoundGraphAddEnvelopeAt(nG, _o_, nA, nD, nSus, nR, nGate, nStart)
	return StzEngineSoundGraphAddPan(nG, _e_, nPan)

func WsMixOf nG, aVoices
	_m_ = StzEngineSoundGraphAddMix(nG)
	for _v_ in aVoices
		StzEngineSoundGraphMixAdd(nG, _m_, _v_)
	next
	return _m_

func WsAddBass nG, nHz, nStart, nGate
	_o_ = StzEngineSoundGraphAddOsc(nG, StzSoundWaveSaw(), nHz, 0.34)
	_f_ = StzEngineSoundGraphAddFilter(nG, _o_, StzSoundFilterLowPass(), 420, 1.1)
	_e_ = StzEngineSoundGraphAddEnvelopeAt(nG, _f_, 0.008, 0.22, 0.35, 0.25, nGate, nStart)
	return StzEngineSoundGraphAddPan(nG, _e_, 0.5)

func WsBuildComposition
	_beat_ = 0.6
	_barlen_ = _beat_ * 4
	_chords_ = [ [220.00, 261.63, 329.63, 110.00],
	             [174.61, 220.00, 261.63,  87.31],
	             [261.63, 329.63, 392.00, 130.81],
	             [196.00, 246.94, 293.66,  98.00] ]
	_tune_ = [ 659.25, 523.25, 587.33, 493.88, 523.25, 440.00, 493.88, 440.00 ]

	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_vPad_ = []  _vBass_ = []  _vArp1_ = []  _vArp2_ = []  _vBell_ = []

	for _bi_ = 0 to 7
		_ch_ = _chords_[(_bi_ % 4) + 1]
		_t0_ = _bi_ * _barlen_
		_sw_ = 0.55
		if _bi_ >= 4  _sw_ = 0.75 ok

		_vPad_ + WsAddVoice(_g_, StzSoundWaveTriangle(), _ch_[1], 0.13*_sw_, _t0_, _barlen_*0.9, 0.35, 0.4, 0.75, 0.7, 0.18)
		_vPad_ + WsAddVoice(_g_, StzSoundWaveTriangle(), _ch_[2], 0.11*_sw_, _t0_, _barlen_*0.9, 0.40, 0.4, 0.75, 0.7, 0.50)
		_vPad_ + WsAddVoice(_g_, StzSoundWaveTriangle(), _ch_[3], 0.11*_sw_, _t0_, _barlen_*0.9, 0.45, 0.4, 0.75, 0.7, 0.82)

		for _hit_ = 0 to 1
			_vBass_ + WsAddBass(_g_, _ch_[4], _t0_ + _hit_*_beat_*2, _beat_*0.9)
		next

		for _n_ = 0 to 3
			_hz_ = _ch_[(_n_ % 3) + 1]
			if _n_ = 3  _hz_ = _hz_ * 2 ok
			_vv_ = WsAddVoice(_g_, StzSoundWaveTriangle(), _hz_, 0.16, _t0_ + _n_*_beat_, 0.18, 0.004, 0.22, 0.0, 0.08, 0.25 + (_n_/3.0)*0.5)
			if _bi_ < 4
				_vArp1_ + _vv_
			else
				_vArp2_ + _vv_
			ok
		next

		if _bi_ >= 4
			_vBell_ + WsAddVoice(_g_, StzSoundWaveSine(), _tune_[_bi_+1], 0.26, _t0_ + _beat_, _barlen_*0.5, 0.006, 1.1, 0.0, 0.5, 0.45)
		ok
	next

	_mPad_ = WsMixOf(_g_, _vPad_)
	_mBass_ = WsMixOf(_g_, _vBass_)
	_mBell_ = WsMixOf(_g_, _vBell_)
	_bellEcho_ = StzEngineSoundGraphAddDelay(_g_, _mBell_, _beat_*0.75, 0.42, 0.42)
	_a1_ = WsMixOf(_g_, _vArp1_)
	_a2_ = WsMixOf(_g_, _vArp2_)
	_arpEcho_ = StzEngineSoundGraphAddDelay(_g_, WsMixOf(_g_, [_a1_, _a2_]), _beat_*0.5, 0.30, 0.28)
	_master_ = WsMixOf(_g_, [ _mPad_, _mBass_, _arpEcho_, _bellEcho_ ])
	_warm_ = StzEngineSoundGraphAddFilter(_g_, _master_, StzSoundFilterLowPass(), 7000, 0.7)
	_out_ = StzEngineSoundGraphAddGain(_g_, _warm_, 1.9)
	StzEngineSoundGraphSetOutput(_g_, _out_)
	return [ _g_, _out_, _barlen_ * 8 + 2.5 ]
