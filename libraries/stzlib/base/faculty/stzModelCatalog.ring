#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZMODELCATALOG                #
#--------------------------------------------------------------#
#                                                              #
#   Description  : MP3 of SOFTANZA_MODEL_PLACEMENT.md: the     #
#                  model CATALOGUE the library reads           #
#                  (models/catalog.zcat) and the SETUP PLAN    #
#                  it writes from it -- what to fetch or       #
#                  convert to make a faculty answer, or answer #
#                  better, on this machine: the files, their   #
#                  sources, sizes, licences, the exact steps,  #
#                  the digests to check, whether the steps     #
#                  were replayed, and what installing changes. #
#                  It fetches NOTHING: a download is the       #
#                  developer's act.                            #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

$aStzCatalog = []          # [ :files, :requires, :platforms, :replayed ] once read
$bStzCatalogRead = 0
$cStzCatalogPath = ""      # "" = models/catalog.zcat; a guard may point it at another file

func StzModelCatalogFile()
	if $cStzCatalogPath != "" return $cStzCatalogPath ok
	_d_ = StzModelsDir()
	if _d_ = "" return "" ok
	return _d_ + "/catalog.zcat"

# Reads the catalogue once per process.
#
#   returns    [ :files = [ [ :path, :bytes, :sha256, :licence, :how, :url, :sourcebytes, :sourcesha256, :steps ] ... ],
#                :requires = [ [ :faculty, :impl, :paths, :langs ] ... ], :platforms = [ [ :faculty, :impl, :os, :needs, :how ] ... ],
#                :replayed = [ [ :path, :date, :result ] ... ] ]
#   see        StzModelSetupPlan, StzImplementationFiles, StzModelFileState
func StzModelCatalog()
	if $bStzCatalogRead = 1 return $aStzCatalog ok
	_aF_ = []
	_aR_ = []
	_aP_ = []
	_aY_ = []
	_cPath_ = StzModelCatalogFile()
	if _cPath_ != "" and fexists(_cPath_)
		_aL_ = str2list(read(_cPath_))
		for _i_ = 1 to len(_aL_)
			_l_ = StzReplace(_aL_[_i_], char(13), "")
			if len(_l_) = 0 loop ok
			if left(_l_, 1) = "#" loop ok
			_a_ = _StzCatalogFields(_l_)
			if _a_[1] = "file" and len(_a_) >= 10
				_aF_ + [ :path = _a_[2], :bytes = 0 + _a_[3], :sha256 = _a_[4], :licence = _a_[5], :how = _a_[6], :url = _a_[7],
					 :sourcebytes = _a_[8], :sourcesha256 = _a_[9], :steps = _a_[10] ]
			but _a_[1] = "requires" and len(_a_) >= 4
				_cW_ = ""
				if len(_a_) >= 5 _cW_ = _a_[5] ok
				_aLg_ = []
				if left(_cW_, 5) = "lang=" _aLg_ = split(right(_cW_, len(_cW_) - 5), ",") ok
				_aR_ + [ :faculty = _a_[2], :impl = _a_[3], :paths = split(_a_[4], ","), :langs = _aLg_ ]
			but _a_[1] = "platform" and len(_a_) >= 6
				_aP_ + [ :faculty = _a_[2], :impl = _a_[3], :os = _a_[4], :needs = _a_[5], :how = _a_[6] ]
			but _a_[1] = "replayed" and len(_a_) >= 4
				_aY_ + [ :path = _a_[2], :date = _a_[3], :result = _a_[4] ]
			ok
		next
	ok
	$aStzCatalog = [ :files = _aF_, :requires = _aR_, :platforms = _aP_, :replayed = _aY_ ]
	$bStzCatalogRead = 1
	return $aStzCatalog

# forget what was read, so the next call reads the file again (a guard that points $cStzCatalogPath elsewhere)
func StzModelCatalogReload()
	$bStzCatalogRead = 0
	$aStzCatalog = []

# the fields of a catalogue line, split on "|" by scanning (a field may hold any character but the bar)
func _StzCatalogFields(pcLine)
	_aOut_ = []
	_c_ = ""
	_n_ = len(pcLine)
	for _k_ = 1 to _n_
		if pcLine[_k_] = "|"
			_aOut_ + _c_
			_c_ = ""
		else
			_c_ += pcLine[_k_]
		ok
	next
	_aOut_ + _c_
	return _aOut_

# The catalogue row of a file (a path relative to the models directory); [] when it is not catalogued.
func StzModelCatalogEntry(pcPath)
	_aF_ = StzModelCatalog()[:files]
	for _i_ = 1 to len(_aF_)
		if _aF_[_i_][:path] = pcPath return _aF_[_i_] ok
	next
	return []

# The files an implementation needs, for a language ("" = the ones it always needs): from the catalogue's requires rows.
func StzImplementationFiles(pcFaculty, pcImpl, pcLang)
	_aOut_ = []
	_aR_ = StzModelCatalog()[:requires]
	for _i_ = 1 to len(_aR_)
		_r_ = _aR_[_i_]
		if _r_[:faculty] != pcFaculty or _r_[:impl] != pcImpl loop ok
		if len(_r_[:langs]) > 0
			if pcLang = "" or len(StzFind(lower(pcLang), _r_[:langs])) = 0 loop ok
		ok
		for _k_ = 1 to len(_r_[:paths])
			if len(StzFind(_r_[:paths][_k_], _aOut_)) = 0 _aOut_ + _r_[:paths][_k_] ok
		next
	next
	return _aOut_

# The state of a catalogued file here: [ :present, :sizeok, :digest = "" | "ok" | "differs", :reason ]. The digest is computed only when
# pbDigest is 1 (it reads the whole file: about three seconds a gigabyte); size is always checked.
func StzModelFileState(pcPath, pbDigest)
	_cFull_ = StzModelsDir() + "/" + pcPath
	_e_ = StzModelCatalogEntry(pcPath)
	if NOT fexists(_cFull_)
		return [ :present = 0, :sizeok = 0, :digest = "", :reason = "not installed: " + pcPath + " is not in " + StzModelsDir() ]
	ok
	if len(_e_) = 0
		return [ :present = 1, :sizeok = 1, :digest = "", :reason = "present, but not in the catalogue: nothing to check it against" ]
	ok
	_nB_ = _StzFileSize(_cFull_)
	if _nB_ != _e_[:bytes]
		return [ :present = 1, :sizeok = 0, :digest = "", :reason = "present but " + _nB_ + " bytes, not the catalogued " + _e_[:bytes] + ": a partial or a different file" ]
	ok
	if pbDigest = 1
		if lower(StzModelDigest(_cFull_)) != lower(_e_[:sha256])
			return [ :present = 1, :sizeok = 1, :digest = "differs", :reason = "present, the right size, but its sha256 is not the catalogued one" ]
		ok
		return [ :present = 1, :sizeok = 1, :digest = "ok", :reason = "present and intact (sha256 checked)" ]
	ok
	return [ :present = 1, :sizeok = 1, :digest = "", :reason = "present, the catalogued size" ]

func _StzFileSize(pcPath)
	_h_ = fopen(pcPath, "rb")
	if isNull(_h_) or NOT isPointer(_h_) return -1 ok
	fseek(_h_, 0, 2)
	_n_ = ftell(_h_)
	fclose(_h_)
	return _n_

# MP3 capability: [ 1, "" ] when every file the catalogue says an implementation needs (for this language) is here at its catalogued size;
# else [ 0, the first missing file and where its setup is ]. StzImplementationAvailable asks it for every implementation, floor included.
func StzImplementationFilesAvailable(pcFaculty, pcImpl, pcLang)
	if pcFaculty = "" return [ 1, "" ] ok
	_aP_ = StzImplementationFiles(pcFaculty, pcImpl, pcLang)
	for _i_ = 1 to len(_aP_)
		_s_ = StzModelFileState(_aP_[_i_], 0)
		if _s_[:present] = 0 or _s_[:sizeok] = 0
			return [ 0, "needs " + _aP_[_i_] + " (" + _s_[:reason] + "; see StzModelSetupPlan('" + pcFaculty + "'))" ]
		ok
	next
	return [ 1, "" ]

# THE SETUP PLAN for a faculty ("" = every faculty) on THIS machine: one step per thing to do, never done for you.
#
#   returns    a list of steps [ :faculty, :impl, :kind = "file" | "platform", :what, :bytes, :licence, :how, :url, :sha256, :steps,
#              :replayed, :value ] -- :value says what installing changes, read from the measurements and the court
#   example    ? StzModelSetupPlanText("ocr")
#   see        StzModelCatalog, StzModelsReport
func StzModelSetupPlan(pcFaculty)
	_StzReportDeclareShipped()
	_aOut_ = []
	_aN_ = StzFacultyNames()
	for _f_ = 1 to len(_aN_)
		_cF_ = _aN_[_f_]
		if pcFaculty != "" and _cF_ != pcFaculty loop ok
		_oF_ = StzFacultyQ(_cF_)
		_aI_ = _oF_.Implementations()
		_aLgs_ = _StzReportLanguages(_cF_, _oF_.GoldenVersion())
		for _i_ = 1 to len(_aI_)
			_cId_ = _aI_[_i_][:id]
			# the files: the ones always needed, then each measured language's own
			_aPaths_ = StzImplementationFiles(_cF_, _cId_, "")
			for _l_ = 1 to len(_aLgs_)
				_aPl_ = StzImplementationFiles(_cF_, _cId_, _aLgs_[_l_])
				for _k_ = 1 to len(_aPl_)
					if len(StzFind(_aPl_[_k_], _aPaths_)) = 0 _aPaths_ + _aPl_[_k_] ok
				next
			next
			for _k_ = 1 to len(_aPaths_)
				_s_ = StzModelFileState(_aPaths_[_k_], 0)
				if _s_[:present] = 1 and _s_[:sizeok] = 1 loop ok
				_e_ = StzModelCatalogEntry(_aPaths_[_k_])
				_aOut_ + [ :faculty = _cF_, :impl = _cId_, :kind = "file", :what = _aPaths_[_k_] + " -- " + _s_[:reason],
					   :bytes = _e_[:bytes], :licence = _e_[:licence], :how = _e_[:how], :url = _e_[:url], :sha256 = _e_[:sha256],
					   :steps = _e_[:steps], :replayed = _StzReplayedOf(_aPaths_[_k_]), :value = _StzSetupValue(_cF_, _cId_, "") ]
			next
			# the platform's own needs, for each measured language it cannot read here
			_aPf_ = StzModelCatalog()[:platforms]
			for _p_ = 1 to len(_aPf_)
				if _aPf_[_p_][:faculty] != _cF_ or _aPf_[_p_][:impl] != _cId_ loop ok
				_aLgCheck_ = _aLgs_
				if len(_aLgCheck_) = 0 _aLgCheck_ = [ "" ] ok
				for _l_ = 1 to len(_aLgCheck_)
					_aAv_ = StzImplementationAvailable(_aI_[_i_], _aLgCheck_[_l_])
					if _aAv_[1] = 1 loop ok
					_cWhat_ = _aPf_[_p_][:needs]
					if _aLgCheck_[_l_] != "" _cWhat_ += " ('" + _aLgCheck_[_l_] + "')" ok
					_aOut_ + [ :faculty = _cF_, :impl = _cId_, :kind = "platform", :what = _cWhat_ + " -- " + _aAv_[2],
						   :bytes = 0, :licence = "", :how = "platform", :url = "", :sha256 = "",
						   :steps = StzReplace(_aPf_[_p_][:how], "<tag>", _StzOcrTagFor(_aLgCheck_[_l_])), :replayed = "",
						   :value = _StzSetupValue(_cF_, _cId_, _aLgCheck_[_l_]) ]
				next
			next
		next
	next
	return _aOut_

# a language code as the tag a Windows language pack carries (the common region; the developer may want another)
func _StzOcrTagFor(pcLang)
	_aT_ = [ [ "en", "en-US" ], [ "fr", "fr-FR" ], [ "ar", "ar-SA" ], [ "ru", "ru-RU" ], [ "de", "de-DE" ], [ "es", "es-ES" ],
		 [ "it", "it-IT" ], [ "pt", "pt-PT" ], [ "nl", "nl-NL" ], [ "zh", "zh-CN" ], [ "uk", "uk-UA" ], [ "bg", "bg-BG" ] ]
	for _i_ = 1 to len(_aT_)
		if _aT_[_i_][1] = lower(pcLang) return _aT_[_i_][2] ok
	next
	return "<tag>"

func _StzReplayedOf(pcPath)
	_aY_ = StzModelCatalog()[:replayed]
	_c_ = ""
	for _i_ = 1 to len(_aY_)
		if _aY_[_i_][:path] = pcPath _c_ = _aY_[_i_][:result] + " (" + _aY_[_i_][:date] + ")" ok
	next
	if _c_ = "" return "the steps have not been replayed" ok
	return _c_

# what installing an implementation changes HERE, read from the measurements and the court -- never promised beyond them
func _StzSetupValue(pcF, pcImpl, pcLang)
	_oF_ = StzFacultyQ(pcF)
	_cGold_ = _oF_.GoldenVersion()
	if pcLang != ""
		# for one language: what it would change THERE, which only a measurement in that language can say
		if len(StzMeasurementOf(pcF, pcImpl, _cGold_ + "/" + pcLang)) = 0
			return "unmeasured in '" + pcLang + "': adding it makes '" + pcImpl + "' AVAILABLE for '" + pcLang + "' here, and the choice stays with what is measured there until it is measured in '" + pcLang + "' too (StzRunGoldens)"
		ok
		_cGold_ = _cGold_ + "/" + pcLang
	ok
	_aM_ = StzMeasurementOf(pcF, pcImpl, _cGold_)
	if len(_aM_) = 0 return "unmeasured on " + _cGold_ + ": installing it changes no choice until it is measured" ok
	_aI_ = _oF_.Implementations()
	_cFloor_ = ""
	for _i_ = 1 to len(_aI_)
		if _aI_[_i_][:kind] = "floor" _cFloor_ = _aI_[_i_][:id] ok
	next
	if pcImpl = _cFloor_ return "it is the floor (measured " + _StzRound2(_aM_[:score]) + " on " + _cGold_ + "): with it, this faculty has a fallback here" ok
	_cInc_ = StzCourtIncumbent(pcF, _cGold_)
	if _cInc_ = "" _cInc_ = _cFloor_ ok
	if pcImpl = _cInc_ return "it is the incumbent (measured " + _StzRound2(_aM_[:score]) + "): without it the faculty does not answer as measured" ok
	_aV_ = StzCourtVerdictOf(pcF, _cGold_, pcImpl, _cInc_)
	if len(_aV_) = 0 return "measured " + _StzRound2(_aM_[:score]) + " but with no court evidence against '" + _cInc_ + "': it would not be chosen" ok
	if _aV_[:verdict] = "upheld" return "measured " + _StzRound2(_aM_[:score]) + " and UPHELD by the court over '" + _cInc_ + "' (" + _aV_[:gains] + " better, " + _aV_[:losses] + " worse): installing it makes it the answer" ok
	return "measured " + _StzRound2(_aM_[:score]) + " but REFUSED by the court against '" + _cInc_ + "' (" + _aV_[:gains] + " better, " + _aV_[:losses] + " worse): installing it changes no choice"

# The setup plan as text, for a console. pcFaculty "" = every faculty.
func StzModelSetupPlanText(pcFaculty)
	_aP_ = StzModelSetupPlan(pcFaculty)
	_c_ = "SOFTANZA SETUP PLAN -- " + StzPlacementOS() + ", this machine; models directory: " + StzModelsDir() + char(10) +
	      "Softanza fetches nothing: each step is yours to run. Check every file against its sha256 before use (StzModelVerify)." + char(10)
	if len(_aP_) = 0
		return _c_ + char(10) + "Nothing to do: every file the catalogue says these faculties need is here, and every platform implementation can run." + char(10)
	ok
	_nBytes_ = 0
	for _i_ = 1 to len(_aP_)
		_s_ = _aP_[_i_]
		_c_ += char(10) + ":" + _s_[:faculty] + " / " + _s_[:impl] + char(10) + "  needs     " + _s_[:what] + char(10)
		if _s_[:kind] = "file"
			_nBytes_ += _s_[:bytes]
			_c_ += "  size      " + _s_[:bytes] + " bytes; licence " + _s_[:licence] + char(10) +
			       "  source    " + _s_[:url] + char(10) +
			       "  how       " + _s_[:how] + ": " + _s_[:steps] + char(10) +
			       "  check     sha256 " + _s_[:sha256] + char(10) +
			       "  replayed  " + _s_[:replayed] + char(10)
		else
			_c_ += "  how       " + _s_[:steps] + char(10)
		ok
		_c_ += "  value     " + _s_[:value] + char(10)
	next
	if _nBytes_ > 0 _c_ += char(10) + "files to fetch or make: " + _nBytes_ + " bytes in all" + char(10) ok
	return _c_

# Every catalogued file that is here, checked against its sha256 (MP4's doctor will build on it). Returns [ [ path, state ] ... ].
func StzModelVerify()
	_aOut_ = []
	_aF_ = StzModelCatalog()[:files]
	for _i_ = 1 to len(_aF_)
		if fexists(StzModelsDir() + "/" + _aF_[_i_][:path])
			_aOut_ + [ _aF_[_i_][:path], StzModelFileState(_aF_[_i_][:path], 1) ]
		ok
	next
	return _aOut_
