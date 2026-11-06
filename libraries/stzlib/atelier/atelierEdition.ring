# THE EDITION OF A NOTEBOOK (B4) -- a notebook with what was RECORDED when the library at
# one commit ran it, for a place that cannot run code: a page of the site, a page of a book.
# A3's rule, generalised from the checks to a notebook: no output is stored as truth; an
# edition shows a RECORDING named by its commit, and every cell of it is citable.
#
# Three moves, each a function here and a verb of edition.ring:
#
#   RECORD   AtelierRecordNotebook(port, notebook)  -- a running Atelier reads the notebook
#            file (/atelier/notebook/open), runs every cell (/atelier/notebook), and the answer
#            is written beside the file as <name>.recording.json, with what judged it: the
#            library commit, the rnxc build, the engine, when. Every cell gets its id:
#            notebook/<name>#<the first 8 hex of the sha256 of its title and its code>.
#   BUILD    AtelierBuildNotebook(notebook, out, atelierDir) -- one static page,
#            <out>/<commit>/notebook/<name>/index.html, holding the page, the recording and the
#            dictionary: nothing runs and nothing is fetched, so it opens from disk and sits in
#            a frame. It REFUSES a recording of other code (the file's sha256 must be the one
#            recorded), a commit that is not in this history, a machine path, and an out folder
#            inside the Atelier's own.
#   CITE     AtelierCiteNotebook(citation, recording) -- <commit>:notebook/<name>#<hash> back to
#            the cell, its code, each line it saw with its recorded value and state, and what
#            judged it; REFUSED when the commit is not the recording's or no cell has the id.
#
# And the same two moves for the library's CHECKS (A3), at the end of this file:
#
#   BUILD    AtelierBuildChecks(out, from, allowMixed, atelierDir) -- the static edition of the
#            checks, <out>/<commit>/ (EMBED.md section 5)
#   CITE     AtelierCiteCheck(citation, folder) -- <commit>:<id> back to the check (section 4)
#
# Written in Ring++ (the author's ruling of 2026-11-05: the library's tooling is library code,
# so Haro can carry it). Load it after the library and atelierClient.ring.

$cAtelierEditionMark = "const EDITION = null; /*EDITION*/"

# the cells' ids and the file's digest are sha256, as lowercase hex
func _AtelierSha(pcText)
	return StzLower("" + StzEngineCryptoSha256("" + pcText))

func _AtelierFileName(pcPath)
	_c_ = substr("" + pcPath, "\", "/")
	_ac_ = StzSplit(_c_, "/")
	return _ac_[len(_ac_)]

func _AtelierFolderOf(pcPath)
	_c_ = substr("" + pcPath, "\", "/")
	_n_ = 0
	for _i_ = 1 to len(_c_)
		if _c_[_i_] = "/"  _n_ = _i_  ok
	next
	if _n_ = 0  return "."  ok
	return left(_c_, _n_ - 1)

# a notebook's name: its file name without .ring, kept to letters, digits, - and _
func AtelierNotebookSlug(pcPath)
	_c_ = _AtelierFileName(pcPath)
	if lower(right(_c_, 5)) = ".ring"
		_c_ = left(_c_, len(_c_) - 5)
	ok
	_cOut_ = ""
	for _i_ = 1 to len(_c_)
		_ch_ = _c_[_i_]
		if (_ch_ >= "a" and _ch_ <= "z") or (_ch_ >= "A" and _ch_ <= "Z") or (_ch_ >= "0" and _ch_ <= "9") or _ch_ = "-" or _ch_ = "_"
			_cOut_ += _ch_
		else
			_cOut_ += "-"
		ok
	next
	return _cOut_

func AtelierRecordingFileOf(pcNotebook)
	_c_ = substr("" + pcNotebook, "\", "/")
	if lower(right(_c_, 5)) = ".ring"
		_c_ = left(_c_, len(_c_) - 5)
	ok
	return _c_ + ".recording.json"

# the digest a recording keeps of its notebook: the file's text, its line ends made LF, so a
# checkout that writes CRLF reads as the same notebook
func AtelierNotebookDigest(pcText)
	return "sha256:" + _AtelierSha(substr("" + pcText, char(13), ""))

# TRUE when a text names a folder of a machine: a letter, a colon, a slash, at the start of a word
func AtelierHasDrivePath(pcText)
	_c_ = "" + pcText
	_n_ = len(_c_)
	for _i_ = 1 to _n_ - 2
		if _c_[_i_ + 1] = ":" and (_c_[_i_ + 2] = "/" or _c_[_i_ + 2] = "\")
			_ch_ = _c_[_i_]
			if (_ch_ >= "a" and _ch_ <= "z") or (_ch_ >= "A" and _ch_ <= "Z")
				if _i_ = 1
					return 1
				ok
				_cb_ = _c_[_i_ - 1]
				if NOT ((_cb_ >= "a" and _cb_ <= "z") or (_cb_ >= "A" and _cb_ <= "Z") or (_cb_ >= "0" and _cb_ <= "9"))
					return 1
				ok
			ok
		ok
	next
	return 0

func _AtelierPostText(pnPort, pcPath, pcBody, pnTimeout)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(pnTimeout)
	_oH_.Post("http://127.0.0.1:" + pnPort + pcPath, pcBody)
	return [ _oH_.ResponseCode(), _oH_.ResponseBody() ]

#--- RECORD ------------------------------------------------------------------

# [ :ok = 1|0, :why, :file, :cells, :kept, :diverged ]
func AtelierRecordNotebook(pnPort, pcNotebook)
	if NOT fexists(pcNotebook)
		return [ :ok = 0, :why = "no notebook at " + pcNotebook ]
	ok
	_cText_ = read(pcNotebook)
	_aSt_ = AtelierState(pnPort)
	if len(_aSt_) = 0 or _aSt_[:library][:state] != "admitted"
		return [ :ok = 0, :why = "no Atelier with its library admitted on port " + pnPort ]
	ok
	AtelierScrubInit(_aSt_[:library][:folder], _aSt_[:rnxc][:folder])
	# the cells, as the Atelier itself reads a notebook file
	_aO_ = _AtelierPostText(pnPort, "/atelier/notebook/open", _cText_, 60)
	if _aO_[1] != 200
		return [ :ok = 0, :why = "the Atelier could not read the notebook: " + left(_aO_[2], 200) ]
	ok
	_aCells_ = StzJsonToList(_aO_[2])[:cells]
	if len(_aCells_) = 0
		return [ :ok = 0, :why = "the notebook holds no cell" ]
	ok
	# every cell, run as one file, from the first
	_aR_ = _AtelierPostText(pnPort, "/atelier/notebook", _aO_[2], 600)
	if _aR_[1] != 200
		return [ :ok = 0, :why = "the Atelier could not run the notebook: " + left(_aR_[2], 200) ]
	ok
	_aRun_ = StzJsonToList(_aR_[2])
	_cSlug_ = AtelierNotebookSlug(pcNotebook)
	_cJ_ = "{" + char(10)
	_cJ_ += '"kind": "notebook",' + char(10)
	_cJ_ += '"notebook": ' + _AtelierJsonStr(_AtelierFileName(pcNotebook)) + "," + char(10)
	_cJ_ += '"name": ' + _AtelierJsonStr(_cSlug_) + "," + char(10)
	_cJ_ += '"digest": ' + _AtelierJsonStr(AtelierNotebookDigest(_cText_)) + "," + char(10)
	_cJ_ += '"taken": ' + _AtelierJsonStr(date() + " " + time()) + "," + char(10)
	_cJ_ += '"library": ' + _AtelierJsonStr(_aSt_[:library][:commit]) + "," + char(10)
	_cJ_ += '"rnxc": ' + _AtelierJsonStr(_aSt_[:rnxc][:build]) + "," + char(10)
	_cJ_ += '"engine": ' + _AtelierJsonStr(_aSt_[:engine]) + "," + char(10)
	_cJ_ += '"kept": ' + _aRun_[:kept] + ', "diverged": ' + _aRun_[:diverged] + ', "unreached": ' + _aRun_[:unreached] + "," + char(10)
	_cJ_ += '"cells": [' + char(10)
	_acIds_ = []
	for _i_ = 1 to len(_aCells_)
		_cT_ = "" + _aCells_[_i_][:title]
		_cC_ = "" + _aCells_[_i_][:code]
		_cId_ = "notebook/" + _cSlug_ + "#" + left(_AtelierSha(_cT_ + char(10) + _cC_), 8)
		# two identical cells are told apart by their rank among the same
		_cBase_ = _cId_
		_k_ = 1
		while find(_acIds_, _cId_) > 0
			_k_++
			_cId_ = _cBase_ + "-" + _k_
		end
		_acIds_ + _cId_
		if _i_ > 1  _cJ_ += "," + char(10)  ok
		_cJ_ += '  {"id": ' + _AtelierJsonStr(_cId_) + ', "n": ' + _i_ + ', "title": ' + _AtelierJsonStr(_cT_) + ', "code": ' + _AtelierJsonStr(_cC_) + "}"
	next
	_cJ_ += char(10) + "]," + char(10)
	# the Atelier's own answer, kept whole: the page draws it as it draws a live run
	_cJ_ += '"run": ' + AtelierScrub(_aR_[2]) + char(10) + "}" + char(10)
	_cFile_ = AtelierRecordingFileOf(pcNotebook)
	write(_cFile_, _cJ_)
	return [ :ok = 1, :why = "", :file = _cFile_, :cells = len(_aCells_), :kept = _aRun_[:kept], :diverged = _aRun_[:diverged] ]

#--- BUILD -------------------------------------------------------------------

# [ answered, exit code ]: is this commit an ancestor of HEAD in the folder's git history?
# answered is 0 when there is no history to ask (an install), and the build does not ask then
func AtelierCommitInHistory(pcFolder, pcCommit)
	_aR_ = StzEngineSystemRunXT("git -C " + substr(pcFolder, "\", "/") + " rev-parse --is-inside-work-tree")
	if 0 + _aR_[2] != 0 or NOT (StzFindFirst("true", "" + _aR_[1]) > 0)
		return [ 0, 0 ]
	ok
	_aR_ = StzEngineSystemRunXT("git -C " + substr(pcFolder, "\", "/") + " merge-base --is-ancestor " + pcCommit + " HEAD")
	return [ 1, 0 + _aR_[2] ]

func _AtelierIsInside(pcPath, pcFolder)
	_a_ = lower(_AtelierNormalize(_AtelierAbsolute(pcPath))) + "/"
	_b_ = lower(_AtelierNormalize(_AtelierAbsolute(pcFolder))) + "/"
	return left(_a_, len(_b_)) = _b_

# a path made whole against the working folder: `--out _x` given from the Atelier's folder is
# inside it, and must read so
func _AtelierAbsolute(pcPath)
	_c_ = substr("" + pcPath, "\", "/")
	if left(_c_, 1) = "/" or (len(_c_) >= 2 and _c_[2] = ":")
		return _c_
	ok
	return substr(currentdir(), "\", "/") + "/" + _c_

# a JSON text set inside a <script>: "</" would end the script, "<\/" means the same in JSON
func _AtelierInScript(pcJson)
	return StzReplace("" + pcJson, "</", "<\/")

# [ :ok = 1|0, :why = [ reasons ], :file ]
func AtelierBuildNotebook(pcNotebook, pcOut, pcAtelierDir)
	_acWhy_ = []
	if pcOut = ""
		return [ :ok = 0, :why = [ "give an out folder: there is no default, a folder inside the library would ride into an install" ] ]
	ok
	if _AtelierIsInside(pcOut, pcAtelierDir)
		return [ :ok = 0, :why = [ "the out folder is inside the Atelier's own: choose a folder outside the library" ] ]
	ok
	if NOT fexists(pcNotebook)
		return [ :ok = 0, :why = [ "no notebook at " + pcNotebook ] ]
	ok
	_cRecFile_ = AtelierRecordingFileOf(pcNotebook)
	if NOT fexists(_cRecFile_)
		return [ :ok = 0, :why = [ "the notebook has no recording beside it (" + _AtelierFileName(_cRecFile_) + "): record it first, rnxc edition.ring record <notebook>" ] ]
	ok
	_cRec_ = read(_cRecFile_)
	_aRec_ = StzJsonToList(_cRec_)
	if AtelierNotebookDigest(read(pcNotebook)) != _aRec_[:digest]
		_acWhy_ + "the notebook changed since it was recorded (its sha256 is not the recording's): record it again"
	ok
	_cCommit_ = StzSplit("" + _aRec_[:library], " ")[1]
	_aH_ = AtelierCommitInHistory(pcAtelierDir, _cCommit_)
	if _aH_[1] = 1 and _aH_[2] != 0
		_acWhy_ + ("the recording names " + _cCommit_ + ", which is not in this history (rebased away, or never landed): push the code first, then record at it")
	ok
	if AtelierHasDrivePath(_cRec_)
		_acWhy_ + "the recording names a folder of a machine: record it again with the scrub (a public page carries no machine path)"
	ok
	_cPage_ = read(pcAtelierDir + "/atelier.html")
	if StzFindFirst($cAtelierEditionMark, _cPage_) = 0
		_acWhy_ + "atelier.html has lost its edition marker"
	ok
	if len(_acWhy_) > 0
		return [ :ok = 0, :why = _acWhy_ ]
	ok
	_cName_ = "" + _aRec_[:name]
	_cEd_ = 'const EDITION = {"kind":"notebook","commit":' + _AtelierJsonStr(_cCommit_) + ',"name":' + _AtelierJsonStr(_cName_)
	_cEd_ += ',"taken":' + _AtelierJsonStr(_aRec_[:taken]) + ',"library":' + _AtelierJsonStr(_aRec_[:library])
	_cEd_ += ',"rnxc":' + _AtelierJsonStr(_aRec_[:rnxc]) + ',"engine":' + _AtelierJsonStr(_aRec_[:engine])
	_cEd_ += ',"recording":' + _AtelierInScript(_cRec_) + ',"i18n":' + _AtelierInScript(read(pcAtelierDir + "/i18n.json")) + '};'
	_cDest_ = _AtelierNormalize(pcOut) + "/" + _cCommit_ + "/notebook/" + _cName_
	StzEngineDirCreatePath(_cDest_)
	_cFile_ = _cDest_ + "/index.html"
	write(_cFile_, StzReplace(_cPage_, $cAtelierEditionMark, _cEd_))
	AtelierNotebooksIndexAdd(_AtelierNormalize(pcOut), _cCommit_, _cName_, _aRec_)
	return [ :ok = 1, :why = [], :file = _cFile_ ]

# <out>/notebooks.json: every notebook edition the folder holds, one entry per commit and name
func AtelierNotebooksIndexAdd(pcOut, pcCommit, pcName, paRec)
	_cIdx_ = pcOut + "/notebooks.json"
	_aOld_ = []
	if fexists(_cIdx_)
		_aOld_ = StzJsonToList(read(_cIdx_))
	ok
	_cJ_ = "[" + char(10)
	_n_ = 0
	for _i_ = 1 to len(_aOld_)
		if "" + _aOld_[_i_][:commit] = pcCommit and "" + _aOld_[_i_][:name] = pcName  loop  ok
		if _n_ > 0  _cJ_ += "," + char(10)  ok
		_n_++
		_cJ_ += _AtelierIndexEntry(_aOld_[_i_][:commit], _aOld_[_i_][:name], _aOld_[_i_][:taken], _aOld_[_i_][:cells], _aOld_[_i_][:kept], _aOld_[_i_][:diverged])
	next
	if _n_ > 0  _cJ_ += "," + char(10)  ok
	_cJ_ += _AtelierIndexEntry(pcCommit, pcName, paRec[:taken], len(paRec[:cells]), paRec[:kept], paRec[:diverged])
	write(_cIdx_, _cJ_ + char(10) + "]" + char(10))

func _AtelierIndexEntry(pcCommit, pcName, pcTaken, pnCells, pnKept, pnDiv)
	return ' {"commit": ' + _AtelierJsonStr(pcCommit) + ', "name": ' + _AtelierJsonStr(pcName) + ', "taken": ' + _AtelierJsonStr(pcTaken) +
	       ', "cells": ' + pnCells + ', "kept": ' + pnKept + ', "diverged": ' + pnDiv +
	       ', "page": ' + _AtelierJsonStr(pcCommit + "/notebook/" + pcName + "/index.html") + '}'

#--- CITE --------------------------------------------------------------------

# [ :ok = 1|0, :why, :record ] -- the record: the citation, the cell (id, n, title, code), each
# line it saw [ :line, :kind, :expr, :promise, :state, :values ], how the run ended, what judged it
func AtelierCiteNotebook(pcCitation, pcRecording)
	_n_ = StzFindFirst(":", pcCitation)
	if _n_ = 0
		return [ :ok = 0, :why = "a citation is <commit>:<id>, with a colon" ]
	ok
	_cCommit_ = left(pcCitation, _n_ - 1)
	_cId_ = substr(pcCitation, _n_ + 1)
	if NOT fexists(pcRecording)
		return [ :ok = 0, :why = "no recording at " + pcRecording ]
	ok
	_aRec_ = StzJsonToList(read(pcRecording))
	_cRecCommit_ = StzSplit("" + _aRec_[:library], " ")[1]
	if _cCommit_ != _cRecCommit_
		return [ :ok = 0, :why = "this recording was taken at " + _cRecCommit_ + ", not " + _cCommit_ + ": pin the notebook at the commit cited, or use its edition" ]
	ok
	_aCell_ = []
	for _i_ = 1 to len(_aRec_[:cells])
		if _aRec_[:cells][_i_][:id] = _cId_
			_aCell_ = _aRec_[:cells][_i_]
			exit
		ok
	next
	if len(_aCell_) = 0
		return [ :ok = 0, :why = "no cell has the id " + _cId_ + " in the recording taken at " + _cRecCommit_ ]
	ok
	_aRun_ = _aRec_[:run]
	_aSeen_ = []
	for _i_ = 1 to len(_aRun_[:sees])
		_aS_ = _aRun_[:sees][_i_]
		_aW_ = _aRun_[:map][_aS_[:line]]
		if _aW_[1] = _aCell_[:n]
			_acV_ = []
			for _k_ = 1 to len(_aS_[:values])
				_acV_ + _aS_[:values][_k_][:payload]
			next
			_aSeen_ + [ :line = _aW_[2], :kind = _aS_[:kind], :expr = _aS_[:expr], :promise = _aS_[:promise], :state = _aS_[:state], :values = _acV_ ]
		ok
	next
	return [ :ok = 1, :why = "", :record = [
		:citation = pcCitation, :commit = _cCommit_, :id = _cId_, :notebook = _aRec_[:notebook],
		:n = _aCell_[:n], :title = _aCell_[:title], :code = _aCell_[:code], :seen = _aSeen_,
		:end = _aRun_[:end], :why = _aRun_[:why],
		:library = _aRec_[:library], :rnxc = _aRec_[:rnxc], :engine = _aRec_[:engine], :taken = _aRec_[:taken] ] ]

# the record as json, markdown or html
func AtelierCiteRender(paR, pcFormat)
	_aR_ = paR
	if pcFormat = "markdown"
		_c_ = "**" + _aR_[:title] + "** (cell " + _aR_[:n] + " of `" + _aR_[:notebook] + "`)" + char(10) + char(10)
		_c_ += "```ring" + char(10) + _AtelierNoTrailingNl(_aR_[:code]) + char(10) + "```" + char(10) + char(10)
		for _i_ = 1 to len(_aR_[:seen])
			_s_ = _aR_[:seen][_i_]
			_c_ += "- line " + _s_[:line] + ", `" + _s_[:expr] + "`: " + _AtelierJoinValues(_s_[:values])
			if _s_[:state] != ""  _c_ += " -- **" + _s_[:state] + "**"  ok
			_c_ += char(10)
		next
		_c_ += char(10) + "Recorded by the library " + _aR_[:library] + ", rnxc " + _aR_[:rnxc] + ", engine " + _aR_[:engine] + ", " + _aR_[:taken] + "." + char(10)
		return _c_ + char(10) + "Citation: `" + _aR_[:citation] + "`" + char(10)
	but pcFormat = "html"
		_c_ = '<article class="atelier-cell"><p><b>' + _AtelierHtml(_aR_[:title]) + "</b> (cell " + _aR_[:n] + " of <code>" + _AtelierHtml(_aR_[:notebook]) + "</code>)</p>"
		_c_ += "<pre>" + _AtelierHtml(_AtelierNoTrailingNl(_aR_[:code])) + "</pre><ul>"
		for _i_ = 1 to len(_aR_[:seen])
			_s_ = _aR_[:seen][_i_]
			_c_ += "<li>line " + _s_[:line] + ", <code>" + _AtelierHtml(_s_[:expr]) + "</code>: " + _AtelierHtml(_AtelierJoinValues(_s_[:values]))
			if _s_[:state] != ""  _c_ += " <b>" + _AtelierHtml(_s_[:state]) + "</b>"  ok
			_c_ += "</li>"
		next
		_c_ += "</ul><p>Recorded by the library " + _AtelierHtml(_aR_[:library]) + ", rnxc " + _AtelierHtml(_aR_[:rnxc]) + ", engine " + _AtelierHtml(_aR_[:engine]) + ", " + _AtelierHtml(_aR_[:taken]) + ".</p>"
		return _c_ + "<p>Citation: <code>" + _AtelierHtml(_aR_[:citation]) + "</code></p></article>"
	ok
	_c_ = "{" + char(10) + ' "citation": ' + _AtelierJsonStr(_aR_[:citation]) + "," + char(10)
	_c_ += ' "commit": ' + _AtelierJsonStr(_aR_[:commit]) + ', "id": ' + _AtelierJsonStr(_aR_[:id]) + ', "notebook": ' + _AtelierJsonStr(_aR_[:notebook]) + "," + char(10)
	_c_ += ' "n": ' + _aR_[:n] + ', "title": ' + _AtelierJsonStr(_aR_[:title]) + ', "code": ' + _AtelierJsonStr(_aR_[:code]) + "," + char(10)
	_c_ += ' "seen": ['
	for _i_ = 1 to len(_aR_[:seen])
		_s_ = _aR_[:seen][_i_]
		if _i_ > 1  _c_ += ","  ok
		_c_ += char(10) + '  {"line": ' + _s_[:line] + ', "kind": ' + _AtelierJsonStr(_s_[:kind]) + ', "expr": ' + _AtelierJsonStr(_s_[:expr]) +
		       ', "promise": ' + _AtelierJsonStr(_s_[:promise]) + ', "state": ' + _AtelierJsonStr(_s_[:state]) + ', "values": ['
		for _k_ = 1 to len(_s_[:values])
			if _k_ > 1  _c_ += ", "  ok
			_c_ += _AtelierJsonStr(_s_[:values][_k_])
		next
		_c_ += "]}"
	next
	_c_ += char(10) + " ]," + char(10)
	_c_ += ' "judged_by": {"library": ' + _AtelierJsonStr(_aR_[:library]) + ', "rnxc": ' + _AtelierJsonStr(_aR_[:rnxc]) + ', "engine": ' + _AtelierJsonStr(_aR_[:engine]) + ', "taken": ' + _AtelierJsonStr(_aR_[:taken]) + "}" + char(10)
	return _c_ + "}" + char(10)

func _AtelierJoinValues(pacV)
	_c_ = ""
	for _i_ = 1 to len(pacV)
		if _i_ > 1  _c_ += " / "  ok
		_v_ = "" + pacV[_i_]
		if len(_v_) > 200  _v_ = left(_v_, 200) + " ..."  ok
		_c_ += substr(_v_, char(10), " ")
	next
	if _c_ = ""  _c_ = "(nothing)"  ok
	return _c_

func _AtelierNoTrailingNl(pcText)
	_c_ = "" + pcText
	while len(_c_) > 0 and right(_c_, 1) = char(10)
		_c_ = left(_c_, len(_c_) - 1)
	end
	return _c_

func _AtelierHtml(pcText)
	_c_ = "" + pcText
	_c_ = StzReplace(_c_, "&", "&amp;")
	_c_ = StzReplace(_c_, "<", "&lt;")
	_c_ = StzReplace(_c_, ">", "&gt;")
	_c_ = StzReplace(_c_, '"', "&quot;")
	return StzReplace(_c_, "'", "&#x27;")

#--- THE CHECKS (A3) ---------------------------------------------------------
# The static edition of the library's checks, and the citation of one check. These were
# build_static.py and cite.py, written in Python before the ruling of 2026-11-05, and ported
# here on 2026-11-06 with every behaviour EMBED.md sections 4 and 5 promise.
#
# The edition is the page over the data this folder already carries -- checks.json,
# results.json, tours.json and i18n.json, committed with the tests they come from -- frozen at
# the commit the recording names, for a place that cannot run code: nothing runs, no
# playground, no run buttons, and NO RING COLUMN (the author's rulings of 2026-10-30: no
# comparison with Ring on a public page until he says so), so verdicts.json never goes out.
# The data files are copied as TEXT, never parsed and written back: a JSON writer would have
# to guess which "" was a null and which 1 was a true, and the page reads the text as it is.

# the commit token of "74757d462 on atelier/a0" or "0950e246a (installed)"
func _AtelierCommitOf(pcText)
	_c_ = "" + pcText
	if _c_ = ""  return ""  ok
	return StzSplit(_c_, " ")[1]

# TRUE for 7 to 40 lowercase hex digits: a commit git can be asked about (nothing else goes
# into the line the shell reads)
func _AtelierIsCommit(pcText)
	_c_ = "" + pcText
	_n_ = len(_c_)
	if _n_ < 7 or _n_ > 40  return 0  ok
	for _i_ = 1 to _n_
		_ch_ = _c_[_i_]
		if NOT ((_ch_ >= "0" and _ch_ <= "9") or (_ch_ >= "a" and _ch_ <= "f"))  return 0  ok
	next
	return 1

# a key of a parsed JSON object, or "" when the object has none
func _AtelierGet(paObject, pcKey)
	if NOT isList(paObject)  return ""  ok
	for _i_ = 1 to len(paObject)
		_a_ = paObject[_i_]
		if isList(_a_) and len(_a_) = 2 and isString(_a_[1]) and _a_[1] = pcKey
			return _a_[2]
		ok
	next
	return ""

# a parsed JSON value written back: a string, a number, an object (a list of [ key, value ]),
# an array. Only for the few values an edition states about itself, never for the data
func _AtelierJsonValue(pValue)
	if isString(pValue)  return _AtelierJsonStr(pValue)  ok
	if isNumber(pValue)  return "" + pValue  ok
	_bObject_ = len(pValue) > 0
	for _i_ = 1 to len(pValue)
		if NOT (isList(pValue[_i_]) and len(pValue[_i_]) = 2 and isString(pValue[_i_][1]))
			_bObject_ = 0
			exit
		ok
	next
	_c_ = ""
	for _i_ = 1 to len(pValue)
		if _i_ > 1  _c_ += ", "  ok
		if _bObject_
			_c_ += _AtelierJsonStr(pValue[_i_][1]) + ": " + _AtelierJsonValue(pValue[_i_][2])
		else
			_c_ += _AtelierJsonValue(pValue[_i_])
		ok
	next
	if _bObject_  return "{" + _c_ + "}"  ok
	return "[" + _c_ + "]"

# a number of a parsed JSON value, or null when the data had none
func _AtelierJsonNumOrNull(pValue)
	if isNumber(pValue)  return "" + pValue  ok
	return "null"

func _AtelierIsLetter(pcCh)
	return (pcCh >= "a" and pcCh <= "z") or (pcCh >= "A" and pcCh <= "Z")

func _AtelierIsAlnum(pcCh)
	return (pcCh >= "a" and pcCh <= "z") or (pcCh >= "A" and pcCh <= "Z") or (pcCh >= "0" and pcCh <= "9")

# [ text, count ]: every folder of a machine in a JSON TEXT replaced by <path>, and how many.
# A path begins at a drive letter that starts a word, a colon and a slash, and runs to the
# first space, quote, <, > or | -- as the Python builder's pattern did on the decoded strings.
# In the JSON text a backslash of the path is written as two, and a line break as backslash
# n, so a backslash followed by another or by a slash is the path's, and any other escape ends
# it: the path stops where the decoded text would stop it, and the JSON stays well formed.
func AtelierScrubDrivePaths(pcText)
	_c_ = "" + pcText
	_n_ = len(_c_)
	_cOut_ = ""
	_nFrom_ = 1
	_nCount_ = 0
	_i_ = 1
	while _i_ <= _n_ - 2
		_bAt_ = 0
		if _c_[_i_ + 1] = ":"
			_cs_ = _c_[_i_ + 2]
			if _cs_ = "/" or (_cs_ = "\" and _i_ + 3 <= _n_ and (_c_[_i_ + 3] = "\" or _c_[_i_ + 3] = "/"))
				if _AtelierIsLetter(_c_[_i_])
					if _i_ = 1
						_bAt_ = 1
					but NOT _AtelierIsAlnum(_c_[_i_ - 1])
						_bAt_ = 1
					ok
				ok
			ok
		ok
		if NOT _bAt_
			_i_++
			loop
		ok
		_j_ = _i_ + 2
		while _j_ <= _n_
			_ch_ = _c_[_j_]
			if _ch_ = "\"
				if _j_ < _n_ and (_c_[_j_ + 1] = "\" or _c_[_j_ + 1] = "/")
					_j_ += 2
					loop
				ok
				exit
			ok
			if _ch_ = " " or _ch_ = '"' or _ch_ = "'" or _ch_ = "<" or _ch_ = ">" or _ch_ = "|" or _ch_ = char(9) or _ch_ = char(10) or _ch_ = char(13)
				exit
			ok
			_j_++
		end
		_cOut_ += substr(_c_, _nFrom_, _i_ - _nFrom_) + "<path>"
		_nFrom_ = _j_
		_nCount_++
		_i_ = _j_
	end
	if _nCount_ = 0  return [ _c_, 0 ]  ok
	if _nFrom_ <= _n_
		_cOut_ += substr(_c_, _nFrom_, _n_ - _nFrom_ + 1)
	ok
	return [ _cOut_, _nCount_ ]

# the distinct texts of a list, sorted
func _AtelierDistinctSorted(pacList)
	_ac_ = sort(pacList)
	_aOut_ = []
	for _i_ = 1 to len(_ac_)
		if _i_ = 1 or _ac_[_i_] != _ac_[_i_ - 1]
			_aOut_ + _ac_[_i_]
		ok
	next
	return _aOut_

# "YYYY-MM-DD HH:MM", from the clock
func _AtelierNowIso()
	_d_ = date()
	return right(_d_, 4) + "-" + substr(_d_, 4, 2) + "-" + left(_d_, 2) + " " + left(time(), 5)

func _AtelierRefused(pcWhy)
	return [ :ok = 0, :mixed = 0, :notes = [], :why = [ pcWhy ] ]

# [ :ok = 1|0, :why = [ reasons ], :mixed = 1 when the reasons are that the files do not
#   describe one commit, :notes = [ what the maintainer is told ], and when built :commit,
#   :dest, :files, :bytes, :checks, :counts = [ pass, fail, err ], :judged, :claims ]
# pcFrom: "" for the Atelier's own data, or another folder holding the four files and the page
# (a guard plants one); the history is asked only of the Atelier's own data
func AtelierBuildChecks(pcOut, pcFrom, pbAllowMixed, pcAtelierDir)
	if "" + pcOut = ""
		return _AtelierRefused("give --out <folder>: there is no default, a folder inside the library would ride into an install")
	ok
	if _AtelierIsInside(pcOut, pcAtelierDir)
		return _AtelierRefused("--out is inside the Atelier folder: choose a folder outside the library")
	ok
	_cHere_ = _AtelierNormalize(_AtelierAbsolute(pcAtelierDir))
	_cSrc_ = _cHere_
	if "" + pcFrom != ""
		_cSrc_ = _AtelierNormalize(_AtelierAbsolute(pcFrom))
	ok
	_bOwn_ = lower(_cSrc_) = lower(_cHere_)
	_acNeed_ = [ "checks.json", "results.json", "i18n.json", "atelier.html" ]
	for _i_ = 1 to len(_acNeed_)
		if NOT fexists(_cSrc_ + "/" + _acNeed_[_i_])
			return _AtelierRefused(_acNeed_[_i_] + " is missing in " + _cSrc_)
		ok
	next
	_cChecks_ = read(_cSrc_ + "/checks.json")
	_cResults_ = read(_cSrc_ + "/results.json")
	_cI18n_ = read(_cSrc_ + "/i18n.json")
	_cPage_ = read(_cSrc_ + "/atelier.html")
	_cTours_ = ""
	if fexists(_cSrc_ + "/tours.json")  _cTours_ = read(_cSrc_ + "/tours.json")  ok
	if StzFindFirst($cAtelierEditionMark, _cPage_) = 0
		return _AtelierRefused("atelier.html has lost its edition marker")
	ok
	_aChecks_ = StzJsonToList(_cChecks_)
	_aRes_ = StzJsonToList(_cResults_)
	_aTours_ = []
	if _cTours_ != ""  _aTours_ = StzJsonToList(_cTours_)  ok
	if len(_aChecks_) = 0 or len(_aRes_) = 0
		return _AtelierRefused("checks.json or results.json is not a JSON document")
	ok
	_cCommit_ = _AtelierCommitOf(_AtelierGet(_aRes_, "library"))
	if _cCommit_ = "" or StzFindFirst("/", _cCommit_) > 0 or StzFindFirst("\", _cCommit_) > 0 or StzFindFirst("..", _cCommit_) > 0
		return _AtelierRefused("the recording names no library commit an edition can be named after: record again")
	ok

	# the three files must describe one commit
	_acWhy_ = []
	_cChecksAt_ = _AtelierCommitOf(_AtelierGet(_aChecks_, "commit"))
	if _cChecksAt_ != _cCommit_
		_acWhy_ + ("the checks were harvested at " + _cChecksAt_ + " but the recording names " + _cCommit_ + ": run python harvest.py then rnxc record.ring")
	ok
	if _cTours_ = ""
		_acWhy_ + "there is no tours.json: run rnxc tours.ring for the coverage section"
	else
		_cToursAt_ = _AtelierCommitOf(_AtelierGet(_aTours_, "library"))
		if _cToursAt_ != _cCommit_
			_acWhy_ + ("the sweep (tours.json) was taken at " + _cToursAt_ + " but the recording names " + _cCommit_ + ": run rnxc tours.ring")
		ok
	ok
	if _bOwn_
		if NOT _AtelierIsCommit(_cCommit_)
			_acWhy_ + ("the recording names " + _cCommit_ + ", which is not a commit: record again")
		else
			_aH_ = AtelierCommitInHistory(_cSrc_, _cCommit_)
			if _aH_[1] = 1 and _aH_[2] != 0
				_acWhy_ + ("the recording names " + _cCommit_ + ", which is not in this history (rebased away, or never landed): push the code first, then record at it")
			ok
		ok
	ok
	_aCk_ = _AtelierGet(_aChecks_, "checks")
	_acIds_ = []
	for _i_ = 1 to len(_aCk_)
		_acIds_ + ("" + _AtelierGet(_aCk_[_i_], "id"))
	next
	_aSt_ = _AtelierGet(_aRes_, "states")
	_acSt_ = []
	for _i_ = 1 to len(_aSt_)
		_acSt_ + ("" + _aSt_[_i_][1])
	next
	_acIds_ = _AtelierDistinctSorted(_acIds_)
	_acSt_ = _AtelierDistinctSorted(_acSt_)
	_bSame_ = len(_acIds_) = len(_acSt_)
	if _bSame_
		for _i_ = 1 to len(_acIds_)
			if _acIds_[_i_] != _acSt_[_i_]
				_bSame_ = 0
				exit
			ok
		next
	ok
	if NOT _bSame_
		_acWhy_ + ("the recording and the checks do not name the same ids (" + len(_acSt_) + " against " + len(_acIds_) + "): record again")
	ok
	if len(_acWhy_) > 0 and NOT pbAllowMixed
		return [ :ok = 0, :mixed = 1, :notes = [], :why = _acWhy_ ]
	ok
	_acNotes_ = []
	for _i_ = 1 to len(_acWhy_)
		_acNotes_ + ("mixed, as allowed - " + _acWhy_[_i_])
	next

	# no machine path goes out: a recording made without the scrub is mended here, and counted
	_aS1_ = AtelierScrubDrivePaths(_cChecks_)
	_aS2_ = AtelierScrubDrivePaths(_cResults_)
	_aS3_ = AtelierScrubDrivePaths(_cTours_)
	_nScrubbed_ = _aS1_[2] + _aS2_[2] + _aS3_[2]
	if _nScrubbed_ > 0
		_acNotes_ + ("" + _nScrubbed_ + " machine path(s) replaced by <path> in the data: record again with the scrub on")
	ok

	# what judged it
	_cTaken_ = "" + _AtelierGet(_aRes_, "taken")
	_cCounts_ = '{"pass": ' + _AtelierJsonNumOrNull(_AtelierGet(_aRes_, "pass")) + ', "fail": ' + _AtelierJsonNumOrNull(_AtelierGet(_aRes_, "fail")) +
	            ', "err": ' + _AtelierJsonNumOrNull(_AtelierGet(_aRes_, "err")) + '}'
	_cJudged_ = "null"
	_cClaims_ = "null"
	_cToursEd_ = "null"
	if _cTours_ != ""
		_aTot_ = _AtelierGet(_aTours_, "totals")
		_cJudged_ = _AtelierJsonNumOrNull(_AtelierGet(_aTot_, "judged"))
		_cClaims_ = _AtelierJsonNumOrNull(_AtelierGet(_aTot_, "claims"))
		_cToursEd_ = '{"library": ' + _AtelierJsonStr(_AtelierGet(_aTours_, "library")) + ', "totals": ' + _AtelierJsonValue(_aTot_) + '}'
	ok
	_cMixed_ = "false"
	if len(_acWhy_) > 0  _cMixed_ = "true"  ok
	_aHead_ = [ [ "commit", _AtelierJsonStr(_cCommit_) ], [ "taken", _AtelierJsonStr(_cTaken_) ],
	            [ "library", _AtelierJsonStr(_AtelierGet(_aRes_, "library")) ], [ "rnxc", _AtelierJsonStr(_AtelierGet(_aRes_, "rnxc")) ],
	            [ "engine", _AtelierJsonStr(_AtelierGet(_aRes_, "engine")) ], [ "checks_from", _AtelierJsonStr(_AtelierGet(_aChecks_, "commit")) ],
	            [ "source", _AtelierJsonStr(_AtelierGet(_aChecks_, "source")) ], [ "checks", "" + len(_aCk_) ] ]
	_cEdJs_ = ""
	for _i_ = 1 to len(_aHead_)
		if _i_ > 1  _cEdJs_ += ", "  ok
		_cEdJs_ += '"' + _aHead_[_i_][1] + '": ' + _aHead_[_i_][2]
	next
	_cEdition_ = '{' + char(10) + '"commit": ' + _aHead_[1][2] + "," + char(10) + '"built": ' + _AtelierJsonStr(_AtelierNowIso()) + "," + char(10)
	for _i_ = 2 to len(_aHead_)
		_cEdition_ += '"' + _aHead_[_i_][1] + '": ' + _aHead_[_i_][2] + "," + char(10)
	next
	_cEdition_ += '"counts": ' + _cCounts_ + "," + char(10) + '"tours": ' + _cToursEd_ + "," + char(10)
	_cEdition_ += '"mixed": ' + _cMixed_ + "," + char(10) + '"ring_column": false' + char(10) + "}" + char(10)

	# written: the edition's folder replaced whole
	_cOut_ = _AtelierNormalize(_AtelierAbsolute(pcOut))
	_cDest_ = _cOut_ + "/" + _cCommit_
	if StzEngineDirExists(_cDest_)  StzDirDeleteAll(_cDest_)  ok
	StzEngineDirCreatePath(_cDest_ + "/data")
	_cHtml_ = StzReplace(_cPage_, $cAtelierEditionMark, "const EDITION = " + _AtelierInScript("{" + _cEdJs_ + "}") + ";")
	_aFiles_ = [ [ "data/checks.json", _aS1_[1] ], [ "data/results.json", _aS2_[1] ] ]
	if _cTours_ != ""  _aFiles_ + [ "data/tours.json", _aS3_[1] ]  ok
	_aFiles_ + [ "data/i18n.json", _cI18n_ ]
	_aFiles_ + [ "edition.json", _cEdition_ ]
	_aFiles_ + [ "index.html", _cHtml_ ]
	_aFiles_ + [ "coverage.html", _cHtml_ ]
	_aFiles_ + [ "check.html", _cHtml_ ]
	_nBytes_ = 0
	for _i_ = 1 to len(_aFiles_)
		write(_cDest_ + "/" + _aFiles_[_i_][1], _aFiles_[_i_][2])
		_nBytes_ += len(_aFiles_[_i_][2])
	next
	AtelierEditionsIndexAdd(_cOut_, _cCommit_, _cTaken_, len(_aCk_), _cCounts_, _cJudged_, _cClaims_)
	return [ :ok = 1, :mixed = len(_acWhy_) > 0, :notes = _acNotes_, :why = [], :commit = _cCommit_, :dest = _cDest_,
	         :files = len(_aFiles_), :bytes = _nBytes_, :checks = len(_aCk_),
	         :counts = [ _AtelierGet(_aRes_, "pass"), _AtelierGet(_aRes_, "fail"), _AtelierGet(_aRes_, "err") ],
	         :judged = _cJudged_, :claims = _cClaims_ ]

# <out>/editions.json: every edition of the checks the folder holds, one per commit, by when taken
func AtelierEditionsIndexAdd(pcOut, pcCommit, pcTaken, pnChecks, pcCounts, pcJudged, pcClaims)
	_cIdx_ = pcOut + "/editions.json"
	_aRows_ = []
	if fexists(_cIdx_)
		_aOld_ = StzJsonToList(read(_cIdx_))
		for _i_ = 1 to len(_aOld_)
			_e_ = _aOld_[_i_]
			if "" + _AtelierGet(_e_, "commit") = pcCommit  loop  ok
			_aRows_ + [ "" + _AtelierGet(_e_, "taken"), _AtelierEditionRow(_AtelierGet(_e_, "commit"), _AtelierGet(_e_, "taken"),
			            _AtelierJsonNumOrNull(_AtelierGet(_e_, "checks")), _AtelierJsonValue(_AtelierGet(_e_, "counts")),
			            _AtelierJsonNumOrNull(_AtelierGet(_e_, "judged")), _AtelierJsonNumOrNull(_AtelierGet(_e_, "then_lines"))) ]
		next
	ok
	_aRows_ + [ "" + pcTaken, _AtelierEditionRow(pcCommit, pcTaken, "" + pnChecks, pcCounts, pcJudged, pcClaims) ]
	_aRows_ = sort(_aRows_, 1)
	_cJ_ = "[" + char(10)
	for _i_ = 1 to len(_aRows_)
		if _i_ > 1  _cJ_ += "," + char(10)  ok
		_cJ_ += _aRows_[_i_][2]
	next
	write(_cIdx_, _cJ_ + char(10) + "]" + char(10))

func _AtelierEditionRow(pcCommit, pcTaken, pcChecks, pcCounts, pcJudged, pcClaims)
	return ' {"commit": ' + _AtelierJsonStr(pcCommit) + ', "taken": ' + _AtelierJsonStr(pcTaken) + ', "checks": ' + pcChecks +
	       ', "counts": ' + pcCounts + ', "judged": ' + pcJudged + ', "then_lines": ' + pcClaims + '}'

# the file of a data folder: <folder>/<name>, or <folder>/data/<name> for a built edition
func _AtelierDataFile(pcFolder, pcName)
	_c_ = substr("" + pcFolder, "\", "/")
	if fexists(_c_ + "/" + pcName)  return _c_ + "/" + pcName  ok
	if fexists(_c_ + "/data/" + pcName)  return _c_ + "/data/" + pcName  ok
	return ""

# [ :ok = 1|0, :why, :record ] -- the record: the citation, the check (domain, file, line,
# scenario, description, code), its recorded state, what was said when it did not pass, what
# judged it, and where it was harvested from. A resolver that guessed would be quoting a state
# without its commit: another commit, or an id absent, is refused
func AtelierCiteCheck(pcCitation, pcFolder)
	_n_ = StzFindFirst(":", "" + pcCitation)
	if _n_ = 0
		return [ :ok = 0, :why = "a citation is <commit>:<id>, with a colon" ]
	ok
	_cCommit_ = left(pcCitation, _n_ - 1)
	_cId_ = substr(pcCitation, _n_ + 1)
	_cCk_ = _AtelierDataFile(pcFolder, "checks.json")
	_cRs_ = _AtelierDataFile(pcFolder, "results.json")
	if _cCk_ = "" or _cRs_ = ""
		return [ :ok = 0, :why = "no checks.json and results.json in " + pcFolder + " (or " + pcFolder + "/data)" ]
	ok
	_aChecks_ = StzJsonToList(read(_cCk_))
	_aRes_ = StzJsonToList(read(_cRs_))
	_cRec_ = _AtelierCommitOf(_AtelierGet(_aRes_, "library"))
	if _cCommit_ != _cRec_
		return [ :ok = 0, :why = "the data here was recorded at " + _cRec_ + ", not " + _cCommit_ + ": pin the library at " + _cCommit_ + ", or build that edition" ]
	ok
	_aCk_ = _AtelierGet(_aChecks_, "checks")
	for _i_ = 1 to len(_aCk_)
		_c_ = _aCk_[_i_]
		if "" + _AtelierGet(_c_, "id") = _cId_
			return [ :ok = 1, :why = "", :record = [
				:citation = pcCitation, :commit = _cCommit_, :id = _cId_, :domain = _AtelierGet(_c_, "domain"),
				:file = _AtelierGet(_c_, "file"), :line = _AtelierGet(_c_, "line"), :scenario = _AtelierGet(_c_, "scenario"),
				:description = _AtelierGet(_c_, "desc"), :code = _AtelierGet(_c_, "code"),
				:state = _AtelierGet(_AtelierGet(_aRes_, "states"), _cId_), :said = "" + _AtelierGet(_AtelierGet(_aRes_, "said"), _cId_),
				:library = _AtelierGet(_aRes_, "library"), :rnxc = _AtelierGet(_aRes_, "rnxc"), :engine = _AtelierGet(_aRes_, "engine"),
				:taken = _AtelierGet(_aRes_, "taken"),
				:harvested_from = "" + _AtelierGet(_aChecks_, "source") + " at " + _AtelierGet(_aChecks_, "commit") ] ]
		ok
	next
	return [ :ok = 0, :why = "no check has the id " + _cId_ + " in the data recorded at " + _cCommit_ ]

# the record of a check as json, markdown or html. The two last are a plain default, not a
# design: a book renders the json in its own style
func AtelierCiteCheckRender(paR, pcFormat)
	_aR_ = paR
	_cScen_ = "" + _aR_[:scenario]
	if _cScen_ = ""  _cScen_ = "-"  ok
	_cBy_ = "by the library " + _aR_[:library] + ", rnxc " + _aR_[:rnxc] + ", engine " + _aR_[:engine] + ", " + _aR_[:taken] + "."
	if pcFormat = "markdown"
		_c_ = "**" + _aR_[:description] + "**" + char(10) + char(10)
		_c_ += "`" + _aR_[:file] + "`, line " + _aR_[:line] + ", scenario: " + _cScen_ + char(10) + char(10)
		_c_ += "Recorded state: **" + _aR_[:state] + "**, " + _cBy_ + char(10)
		if _aR_[:said] != ""
			_c_ += char(10) + "```" + char(10) + _aR_[:said] + char(10) + "```" + char(10)
		ok
		_c_ += char(10) + "```ring" + char(10) + _AtelierRstrip(_aR_[:code]) + char(10) + "```" + char(10) + char(10)
		return _c_ + "Citation: `" + _aR_[:citation] + "`"
	but pcFormat = "html"
		_c_ = '<article class="atelier-check"><p><b>' + _AtelierHtml(_aR_[:description]) + "</b></p><p><code>" + _AtelierHtml(_aR_[:file]) + "</code>, line " + _aR_[:line] +
		      ", scenario: " + _AtelierHtml(_cScen_) + "</p><p>Recorded state: <b>" + _AtelierHtml(_aR_[:state]) + "</b>, " + _AtelierHtml(_cBy_) + "</p>"
		if _aR_[:said] != ""  _c_ += "<pre>" + _AtelierHtml(_aR_[:said]) + "</pre>"  ok
		return _c_ + "<pre>" + _AtelierHtml(_AtelierRstrip(_aR_[:code])) + "</pre><p>Citation: <code>" + _AtelierHtml(_aR_[:citation]) + "</code></p></article>"
	ok
	_cState_ = "null"
	if "" + _aR_[:state] != ""  _cState_ = _AtelierJsonStr(_aR_[:state])  ok
	_c_ = "{" + char(10)
	_c_ += ' "citation": ' + _AtelierJsonStr(_aR_[:citation]) + "," + char(10)
	_c_ += ' "commit": ' + _AtelierJsonStr(_aR_[:commit]) + "," + char(10)
	_c_ += ' "id": ' + _AtelierJsonStr(_aR_[:id]) + "," + char(10)
	_c_ += ' "domain": ' + _AtelierJsonStr(_aR_[:domain]) + "," + char(10)
	_c_ += ' "file": ' + _AtelierJsonStr(_aR_[:file]) + "," + char(10)
	_c_ += ' "line": ' + _AtelierJsonNumOrNull(_aR_[:line]) + "," + char(10)
	_c_ += ' "scenario": ' + _AtelierJsonStr(_aR_[:scenario]) + "," + char(10)
	_c_ += ' "description": ' + _AtelierJsonStr(_aR_[:description]) + "," + char(10)
	_c_ += ' "code": ' + _AtelierJsonStr(_aR_[:code]) + "," + char(10)
	_c_ += ' "state": ' + _cState_ + "," + char(10)
	_c_ += ' "said": ' + _AtelierJsonStr(_aR_[:said]) + "," + char(10)
	_c_ += ' "judged_by": {' + char(10) + '  "library": ' + _AtelierJsonStr(_aR_[:library]) + "," + char(10) + '  "rnxc": ' + _AtelierJsonStr(_aR_[:rnxc]) + "," + char(10)
	_c_ += '  "engine": ' + _AtelierJsonStr(_aR_[:engine]) + "," + char(10) + '  "taken": ' + _AtelierJsonStr(_aR_[:taken]) + char(10) + " }," + char(10)
	_c_ += ' "harvested_from": ' + _AtelierJsonStr(_aR_[:harvested_from]) + char(10)
	return _c_ + "}"

# a text without the spaces, tabs and line ends that close it
func _AtelierRstrip(pcText)
	_c_ = "" + pcText
	while len(_c_) > 0
		_ch_ = right(_c_, 1)
		if _ch_ = " " or _ch_ = char(9) or _ch_ = char(10) or _ch_ = char(13)
			_c_ = left(_c_, len(_c_) - 1)
		else
			exit
		ok
	end
	return _c_
