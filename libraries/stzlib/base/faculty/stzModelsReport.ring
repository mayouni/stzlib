#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZMODELSREPORT                #
#--------------------------------------------------------------#
#                                                              #
#   Description  : MP1 and MP2 of SOFTANZA_MODEL_PLACEMENT.md: #
#                  the REAL PICTURE of the models a program    #
#                  uses -- for every faculty, what can run     #
#                  here (and why not), what was measured, what #
#                  the court said, what is chosen, what is     #
#                  missing; on this machine, and as it would   #
#                  be on another operating system. It reads    #
#                  only what the registry reads, and asks the  #
#                  registry for every choice, so it cannot     #
#                  disagree with it.                           #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# The report for THIS machine: one entry per faculty (and per measured language of a faculty measured per language).
#
#   returns    a list of entries [ :faculty, :lang, :golden, :os, :chosen, :kind, :refusal, :reason, :impls ], each impl
#              [ :id, :kind, :available, :unavailable, :installed, :needle, :score, :n, :court, :chosen ]
#   example    aR = StzModelsReport()
#              ? StzModelsReportText()
#   see        StzModelsReportFor, StzModelsReportText, StzModelsReportPage, StzModelRegistryQ
func StzModelsReport()
	return StzModelsReportFor("")

# The report as it would be on another operating system ("linux", "macos", "windows"; "" = this machine). An implementation that exists
# only on another operating system is set aside, exactly as the registry would there. A probe that reads THIS machine (an OCR language
# pack) cannot know the target's: the entry then says so (:assumed).
func StzModelsReportFor(pcOS)
	# the simulated OS is set inside the try and restored on every exit; the error is raised again unchanged
	# (SECURITY-AMBIENT-02): a report that raises must not leave the registry choosing for another machine
	_cKeep_ = $cStzPlacementOS
	_cErr_ = ""
	_aOut_ = []
	try
		$cStzPlacementOS = pcOS
		_StzReportDeclareShipped()
		_aN_ = StzFacultyNames()
		for _f_ = 1 to len(_aN_)
			_cF_ = _aN_[_f_]
			_oF_ = StzFacultyQ(_cF_)
			# every declared faculty: in a program the golden ITEMS live with the tests, but the measurements ship with the library
			_aOut_ + _StzReportEntry(_cF_, "")
			# a faculty measured per language: one entry per language it has measurements in
			_aLgs_ = _StzReportLanguages(_cF_, _oF_.GoldenVersion())
			for _l_ = 1 to len(_aLgs_)
				_aOut_ + _StzReportEntry(_cF_, _aLgs_[_l_])
			next
		next
	catch
		_cErr_ = cCatchError
	done
	$cStzPlacementOS = _cKeep_
	if _cErr_ != ""
		raise(_cErr_)
	ok
	return _aOut_

# The faculties the library ships are declared in every process before a report reads them (vision is declared at load; OCR on first use)
func _StzReportDeclareShipped()
	if StzHasFaculty("ocr") = 0
		StzOcrDeclare([])
	ok

func _StzReportLanguages(pcF, pcVer)
	_aL_ = []
	_aM_ = StzMeasurements()
	for _i_ = 1 to len(_aM_)
		_g_ = _aM_[_i_][:golden]
		if _aM_[_i_][:faculty] = pcF and left(_g_, len(pcVer) + 1) = pcVer + "/"
			_c_ = right(_g_, len(_g_) - len(pcVer) - 1)
			if len(StzFind(_c_, _aL_)) = 0 _aL_ + _c_ ok
		ok
	next
	return _aL_

func _StzReportEntry(pcF, pcLang)
	_oF_ = StzFacultyQ(pcF)
	_oReq_ = StzRequirementQ(pcF)
	if pcLang != "" _oReq_ = StzRequirementQ(pcF).RequireLanguagesQ([ pcLang ]) ok
	_oP_ = StzModelRegistryQ().ResolveQ(_oReq_)
	_cGold_ = _oF_.GoldenVersion()
	if pcLang != "" _cGold_ = _cGold_ + "/" + pcLang ok
	_cInc_ = StzCourtIncumbent(pcF, _cGold_)
	_aI_ = _oF_.Implementations()
	_cFloor_ = ""
	for _i_ = 1 to len(_aI_)
		if _aI_[_i_][:kind] = "floor" _cFloor_ = _aI_[_i_][:id] ok
	next
	if _cInc_ = "" _cInc_ = _cFloor_ ok
	_aRows_ = []
	for _i_ = 1 to len(_aI_)
		_a_ = _aI_[_i_]
		_aAv_ = StzImplementationAvailable(_a_, pcLang)
		_aM_ = StzMeasurementOf(pcF, _a_[:id], _cGold_)
		_nS_ = -1
		_nN_ = 0
		if len(_aM_) > 0
			_nS_ = _aM_[:score]
			_nN_ = _aM_[:n]
		ok
		# the court line: a challenger against the incumbent, the incumbent against the floor
		_cCourt_ = ""
		_cAgainst_ = _cInc_
		if _a_[:id] = _cInc_ _cAgainst_ = _cFloor_ ok
		if _a_[:id] != _cAgainst_ and _cAgainst_ != "" and _a_[:kind] != "floor"
			_aV_ = StzCourtVerdictOf(pcF, _cGold_, _a_[:id], _cAgainst_)
			_aAvA_ = StzImplementationAvailable(_StzImplRow(pcF, _cAgainst_), pcLang)
			if _aAvA_[1] = 0
				_cCourt_ = "no comparison here: " + _cAgainst_ + " cannot run"
			but len(_aV_) > 0
				_cCourt_ = _aV_[:verdict] + " over " + _cAgainst_ + " (" + _aV_[:gains] + " better, " + _aV_[:losses] + " worse)"
			else
				_cCourt_ = "no evidence against " + _cAgainst_
			ok
		ok
		if _a_[:id] = _cInc_ and _a_[:kind] != "floor" _cCourt_ = "incumbent; " + _cCourt_ ok
		_aRows_ + [ :id = _a_[:id], :kind = _a_[:kind], :available = _aAv_[1], :unavailable = _aAv_[2],
			    :installed = StzImplementationIsInstalled(_a_), :needle = _a_[:needle], :score = _nS_, :n = _nN_,
			    :court = _cCourt_, :chosen = (_a_[:id] = _oP_.Chosen()) ]
	next
	return [ :faculty = pcF, :lang = pcLang, :golden = _cGold_, :os = StzPlacementOS(), :chosen = _oP_.Chosen(), :kind = _oP_.Kind(),
		 :refusal = _oP_.IsRefusal(), :reason = _StzReportReason(_oP_, _aRows_, _cFloor_), :impls = _aRows_, :why = _oP_.Why() ]

# one sentence: why this choice
func _StzReportReason(poPlan, paRows, pcFloor)
	if poPlan.IsRefusal() = 1 return "NOTHING can answer here" ok
	_cC_ = poPlan.Chosen()
	_bFloorAv_ = 1
	for _i_ = 1 to len(paRows)
		if paRows[_i_][:id] = pcFloor _bFloorAv_ = paRows[_i_][:available] ok
	next
	if _cC_ = pcFloor return "no model was proven better here" ok
	if _bFloorAv_ = 0 return "the floor cannot run here" ok
	for _i_ = 1 to len(paRows)
		if paRows[_i_][:id] = _cC_ and paRows[_i_][:court] != "" return paRows[_i_][:court] ok
	next
	return "measured best"

# The report as text, for a console: one block per faculty entry. pcOS as in StzModelsReportFor ("" = this machine).
func StzModelsReportText()
	return StzModelsReportTextFor("")

func StzModelsReportTextFor(pcOS)
	_aR_ = StzModelsReportFor(pcOS)
	_cOS_ = pcOS
	if _cOS_ = "" _cOS_ = StzPlacementOS() + ", this machine" ok
	_c_ = "SOFTANZA MODELS -- " + _cOS_ + char(10)
	for _i_ = 1 to len(_aR_)
		_e_ = _aR_[_i_]
		_cF_ = ":" + _e_[:faculty]
		if _e_[:lang] != "" _cF_ += " [" + _e_[:lang] + "]" ok
		_cCh_ = _e_[:chosen]
		if _e_[:refusal] = 1 _cCh_ = "(refusal)" ok
		_c_ += char(10) + _StzPad(_cF_, 22) + _StzPad(_cCh_, 24) + _e_[:reason] + char(10)
		for _k_ = 1 to len(_e_[:impls])
			_r_ = _e_[:impls][_k_]
			_cM_ = "  " + _StzPad(_r_[:id], 22) + _StzPad(_r_[:kind], 7)
			if _r_[:available] = 0
				_cM_ += "UNAVAILABLE: " + _r_[:unavailable]
			but _r_[:installed] = 0
				_cM_ += "NOT INSTALLED (needs a file matching '" + _r_[:needle] + "' in " + StzModelsDir() + ")"
			but _r_[:score] < 0
				_cM_ += "unmeasured on " + _e_[:golden]
			else
				_cM_ += _StzPad("" + _StzRound2(_r_[:score]) + " (n=" + _r_[:n] + ")", 16) + _r_[:court]
			ok
			if _r_[:chosen] _cM_ = "> " + right(_cM_, len(_cM_) - 2) ok
			_c_ += _cM_ + char(10)
		next
	next
	return _c_

func _StzPad(pcText, pnWidth)
	_c_ = "" + pcText
	while len(_c_) < pnWidth _c_ += " " end
	return _c_ + " "

func _StzRound2(pnX)
	return floor(pnX * 100 + 0.5) / 100

# The report as a page a person can look at: the matrix of what answers each faculty on this machine and on each operating system, then
# every faculty in detail. Returns the path.
func StzModelsReportPage(pcPath)
	_aHere_ = StzModelsReportFor("")
	_aOS_ = [ "windows", "linux", "macos" ]
	_aOther_ = []
	for _o_ = 1 to len(_aOS_)
		_aOther_ + StzModelsReportFor(_aOS_[_o_])
	next
	_c_ = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
	      "<title>Softanza models</title><style>" +
	      ":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--card:#f6f6f8;--ok:#1a7f37;--no:#b3261e;--warn:#9a6700;--off:#8a8a90}" +
	      "@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--card:#202024;--ok:#4cc26a;--no:#f28b82;--warn:#e3b341;--off:#8a8a90}}" +
	      "body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1150px;margin:0 auto;padding:16px}" +
	      "h1{font-size:1.5rem;margin:.3em 0}h2{font-size:1.1rem;margin:1.6em 0 .4em}p.sub{color:var(--mut)}" +
	      "table{border-collapse:collapse;width:100%;font-size:.92rem}th,td{text-align:left;padding:6px 8px;border-bottom:1px solid var(--line);vertical-align:top}" +
	      "th{color:var(--mut);font-weight:600}.wrap{overflow-x:auto}.ch{font-weight:700}.ok{color:var(--ok)}.no{color:var(--no)}.warn{color:var(--warn)}.off{color:var(--off)}" +
	      ".tag{display:inline-block;border-radius:4px;padding:0 6px;font-size:.8rem;border:1px solid var(--line);color:var(--mut)}</style></head><body><main>" +
	      "<h1>The models this program uses</h1><p class='sub'>Every faculty: what answers it on this machine (" + StzHtmlEscaped(StzPlacementOS()) + ") and as it would on each operating system, " +
	      "then what can run here, what was measured, what the court decided. Read from the registry itself: nothing on this page is decided by the page. " +
	      "Another operating system's column assumes the same model files are shipped with the program, and an OCR language pack is read from this machine.</p>" +
	      "<h2>What answers, where</h2><div class='wrap'><table><tr><th>faculty</th><th>this machine</th><th>windows</th><th>linux</th><th>macos</th><th>why, here</th></tr>"
	for _i_ = 1 to len(_aHere_)
		_e_ = _aHere_[_i_]
		_cF_ = ":" + _e_[:faculty]
		if _e_[:lang] != "" _cF_ += " [" + _e_[:lang] + "]" ok
		_c_ += "<tr><td>" + StzHtmlEscaped(_cF_) + "</td><td class='ch'>" + _StzReportCell(_e_) + "</td>"
		for _o_ = 1 to len(_aOS_)
			_c_ += "<td>" + _StzReportCell(_StzReportFind(_aOther_[_o_], _e_[:faculty], _e_[:lang])) + "</td>"
		next
		_c_ += "<td>" + StzHtmlEscaped(_e_[:reason]) + "</td></tr>"
	next
	_c_ += "</table></div>"
	# MP3: what could be installed HERE, from the catalogue and the court (Softanza fetches nothing)
	_aSP_ = StzModelSetupPlan("")
	_c_ += "<h2>What you could install here</h2><p class='sub'>From the model catalogue (models/catalog.zcat) and the court. Softanza fetches nothing: " +
	       "each step is yours to run; check every file against its sha256.</p>"
	if len(_aSP_) = 0
		_c_ += "<p>Nothing: every file the faculties need is here, and every platform implementation can run.</p>"
	else
		_c_ += "<div class='wrap'><table><tr><th>faculty</th><th>needs</th><th>how</th><th>what it changes here</th></tr>"
		for _i_ = 1 to len(_aSP_)
			_s_ = _aSP_[_i_]
			_cHow_ = StzHtmlEscaped(_s_[:steps])
			if _s_[:kind] = "file" _cHow_ = StzHtmlEscaped(_s_[:how] + " (" + _s_[:bytes] + " bytes, " + _s_[:licence] + "): " + _s_[:steps] + " -- sha256 " + _s_[:sha256]) ok
			_c_ += "<tr><td>:" + StzHtmlEscaped(_s_[:faculty]) + " / " + StzHtmlEscaped(_s_[:impl]) + "</td><td>" + StzHtmlEscaped(_s_[:what]) + "</td><td><code>" + _cHow_ + "</code></td><td>" + StzHtmlEscaped(_s_[:value]) + "</td></tr>"
		next
		_c_ += "</table></div>"
	ok
	_c_ += "<h2>Every faculty, on this machine</h2>"
	for _i_ = 1 to len(_aHere_)
		_e_ = _aHere_[_i_]
		_cF_ = ":" + _e_[:faculty]
		if _e_[:lang] != "" _cF_ += " [" + _e_[:lang] + "]" ok
		_c_ += "<h2>" + StzHtmlEscaped(_cF_) + " <span class='tag'>golden " + StzHtmlEscaped(_e_[:golden]) + "</span></h2><div class='wrap'><table><tr><th>implementation</th><th>kind</th><th>here</th><th>measured</th><th>the court</th></tr>"
		for _k_ = 1 to len(_e_[:impls])
			_r_ = _e_[:impls][_k_]
			_cHere_ = "<span class='ok'>can run</span>"
			if _r_[:available] = 0
				_cHere_ = "<span class='off'>unavailable: " + StzHtmlEscaped(_r_[:unavailable]) + "</span>"
			but _r_[:installed] = 0
				_cHere_ = "<span class='no'>not installed: needs '" + StzHtmlEscaped(_r_[:needle]) + "'</span>"
			ok
			_cMeas_ = "<span class='off'>unmeasured</span>"
			if _r_[:score] >= 0 _cMeas_ = StzHtmlEscaped(_StzRound2(_r_[:score])) + " <span class='off'>(n=" + StzHtmlEscaped(_r_[:n]) + ")</span>" ok
			_cCt_ = StzHtmlEscaped(_r_[:court])
			if len(StzFind("upheld", _r_[:court])) > 0 _cCt_ = "<span class='ok'>" + _cCt_ + "</span>" ok
			if len(StzFind("refused", _r_[:court])) > 0 _cCt_ = "<span class='warn'>" + _cCt_ + "</span>" ok
			_cId_ = StzHtmlEscaped(_r_[:id])
			if _r_[:chosen] _cId_ = "<span class='ch'>&#9656; " + _cId_ + "</span>" ok
			_c_ += "<tr><td>" + _cId_ + "</td><td>" + StzHtmlEscaped(_r_[:kind]) + "</td><td>" + _cHere_ + "</td><td>" + _cMeas_ + "</td><td>" + _cCt_ + "</td></tr>"
		next
		_c_ += "</table></div>"
	next
	_c_ += "</main></body></html>"
	write(pcPath, _c_)
	return pcPath

func _StzReportFind(paR, pcF, pcLang)
	for _i_ = 1 to len(paR)
		if paR[_i_][:faculty] = pcF and paR[_i_][:lang] = pcLang return paR[_i_] ok
	next
	return []

func _StzReportCell(paE)
	if len(paE) = 0 return "<span class='off'>-</span>" ok
	if paE[:refusal] = 1 return "<span class='no'>nothing</span>" ok
	if paE[:kind] = "floor" return StzHtmlEscaped(paE[:chosen]) + " <span class='tag'>floor</span>" ok
	return StzHtmlEscaped(paE[:chosen])

