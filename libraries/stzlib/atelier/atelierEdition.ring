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
	_a_ = lower(_AtelierNormalize(pcPath)) + "/"
	_b_ = lower(_AtelierNormalize(pcFolder)) + "/"
	return left(_a_, len(_b_)) = _b_

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
	return StzReplace(_c_, '"', "&quot;")
