#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZMODELRELEASE                #
#--------------------------------------------------------------#
#                                                              #
#   Description  : MP3b of SOFTANZA_MODEL_PLACEMENT.md: the    #
#                  RELEASE of the model files Softanza         #
#                  converted, and their FETCH. The catalogue   #
#                  (models/catalog.zcat) says which files a    #
#                  hub repository holds; the publish gate says #
#                  which may be published at all; the stager   #
#                  writes one folder per repository (the files #
#                  checked against their sha256, a model card, #
#                  the licence, a notice, SHA256SUMS and a     #
#                  manifest) and the script the AUTHOR runs to #
#                  upload them with their own account. The     #
#                  fetch is the developer's explicit act: one  #
#                  call, streamed to disk, kept only with the  #
#                  sha256 this catalogue records -- the hub is #
#                  a mirror, never the authority.              #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

$cStzHubBase = "https://huggingface.co"
$cStzSoftanzaSource = "https://github.com/mayouni/stzlib"
$acStzPermissiveLicences = [ "MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause" ]

# The repository row (catalogue) that holds a file; [] when no repository holds it.
func StzModelRepoOf(pcPath)
	_aR_ = StzModelCatalog()[:repos]
	for _i_ = 1 to len(_aR_)
		if len(StzFind(pcPath, _aR_[_i_][:paths])) > 0 return _aR_[_i_] ok
	next
	return []

# The catalogue's repository rows.
func StzModelRepos()
	return StzModelCatalog()[:repos]

# THE PUBLISH GATE: may Softanza publish this file? [ 1, why ] or [ 0, why not ]. Only a file Softanza CONVERTED, under a permissive
# licence, named by a repository row whose licence text is here. A downloaded file is its upstream's to publish; a derived file is made
# from a published one by recorded steps.
func StzModelPublishGate(pcPath)
	_e_ = StzModelCatalogEntry(pcPath)
	if len(_e_) = 0 return [ 0, pcPath + " is not in the catalogue" ] ok
	if _e_[:how] = "download"
		return [ 0, pcPath + " is downloaded from its upstream (" + _e_[:url] + "): Softanza links to it and never republishes it" ]
	ok
	if _e_[:how] = "derive"
		return [ 0, pcPath + " is derived from " + _e_[:url] + " by recorded steps: a derivation is remade, not published" ]
	ok
	if _e_[:how] != "convert" return [ 0, pcPath + ": '" + _e_[:how] + "' is not a way of making a file Softanza publishes" ] ok
	if len(StzFind(_e_[:licence], $acStzPermissiveLicences)) = 0
		return [ 0, pcPath + " is under " + _e_[:licence] + ", which is not on the permissive list (" + _StzJoinComma($acStzPermissiveLicences) + ")" ]
	ok
	_r_ = StzModelRepoOf(pcPath)
	if len(_r_) = 0 return [ 0, pcPath + " is in no repository row: where it would be published is not decided" ] ok
	if NOT fexists(StzModelsDir() + "/" + _r_[:licencefile])
		return [ 0, pcPath + ": the licence text " + _r_[:licencefile] + " is not in " + StzModelsDir() + " -- a release carries the licence's TEXT, not its name" ]
	ok
	return [ 1, pcPath + " was converted by Softanza from " + _e_[:url] + " (" + _e_[:licence] + "), and is published in " + _r_[:repo] ]

# The last PUBLISHED release of a repository: [ :repo, :version, :state, :revision, :date ], or [].
func StzModelReleaseOf(pcRepo)
	_aL_ = StzModelCatalog()[:releases]
	_r_ = []
	for _i_ = 1 to len(_aL_)
		if _aL_[_i_][:repo] = pcRepo and _aL_[_i_][:state] = "published" and _aL_[_i_][:revision] != "" _r_ = _aL_[_i_] ok
	next
	return _r_

# Where StzModelFetch reads a file from: a downloaded file's upstream URL; a converted file's published release; "" when the file can only
# be MADE (not yet published, or derived) -- the setup plan then gives the steps.
func StzModelFetchSource(pcPath)
	_e_ = StzModelCatalogEntry(pcPath)
	if len(_e_) = 0 return "" ok
	if _e_[:how] = "download" return _e_[:url] ok
	if _e_[:how] != "convert" return "" ok
	_r_ = StzModelRepoOf(pcPath)
	if len(_r_) = 0 return "" ok
	_l_ = StzModelReleaseOf(_r_[:repo])
	if len(_l_) = 0 return "" ok
	return $cStzHubBase + "/" + _r_[:repo] + "/resolve/" + _l_[:revision] + "/" + StzEnginePathBasename(pcPath)

# Records a release's state in the catalogue file (a line appended; the last line about a repository wins): "staged", or "published" with
# the hub revision -- the commit (or tag) the upload made -- that StzModelFetch reads from.
func StzModelReleaseMark(pcRepo, pcVersion, pcState, pcRevision)
	if pcState != "staged" and pcState != "published" stzraise("StzModelReleaseMark: the state is 'staged' or 'published', not '" + pcState + "'") ok
	if pcState = "published" and pcRevision = "" stzraise("StzModelReleaseMark: a published release names the hub revision its files are read from") ok
	if len(StzModelRepoNamed(pcRepo)) = 0 stzraise("StzModelReleaseMark: no repository row names " + pcRepo) ok
	_c_ = read(StzModelCatalogFile())
	_nl_ = char(10)
	if StzFindFirst(char(13) + char(10), _c_) > 0 _nl_ = char(13) + char(10) ok
	if right(_c_, 1) != char(10) _c_ += _nl_ ok
	_c_ += "release|" + pcRepo + "|" + pcVersion + "|" + pcState + "|" + pcRevision + "|" + _StzIsoToday() + _nl_
	write(StzModelCatalogFile(), _c_)
	StzModelCatalogReload()

# the repository row by its name
func StzModelRepoNamed(pcRepo)
	_aR_ = StzModelCatalog()[:repos]
	for _i_ = 1 to len(_aR_)
		if _aR_[_i_][:repo] = pcRepo return _aR_[_i_] ok
	next
	return []

func _StzIsoToday()
	_d_ = date()
	return right(_d_, 4) + "-" + _d_[4] + _d_[5] + "-" + _d_[1] + _d_[2]

# THE STAGER: one folder per repository under pcOutDir, ready for the author to upload, and upload.ps1 beside them. A repository is staged
# only when every one of its files passes the gate AND is here with its catalogued sha256 -- a release publishes the measured bytes, never
# others -- and the copy is checked again after it is written. paRepos [] = every repository row.
#
#   returns    [ [ :repo, :staged = 1|0, :reason, :dir, :bytes ] ... ]
#   example    aR = StzModelReleaseStage("v1", "D:/release", [])
#   see        StzModelPublishGate, StzModelReleaseMark
func StzModelReleaseStage(pcVersion, pcOutDir, paRepos)
	_aOut_ = []
	_StzReportDeclareShipped()      # the faculties' measurements and court, which the model cards quote
	if NOT StzDirExists(pcOutDir) StzDirCreatePath(pcOutDir) ok
	_aR_ = StzModelRepos()
	for _i_ = 1 to len(_aR_)
		_r_ = _aR_[_i_]
		if len(paRepos) > 0 and len(StzFind(_r_[:repo], paRepos)) = 0 loop ok
		_aOut_ + _StzStageRepo(_r_, pcVersion, pcOutDir)
	next
	write(pcOutDir + "/upload.ps1", _StzUploadScript(_aOut_, pcVersion))
	return _aOut_

func _StzStageRepo(paR, pcVersion, pcOutDir)
	_cName_ = StzEnginePathBasename(paR[:repo])
	_cDir_ = pcOutDir + "/" + _cName_
	_aP_ = paR[:paths]
	for _k_ = 1 to len(_aP_)
		_g_ = StzModelPublishGate(_aP_[_k_])
		if _g_[1] = 0 return [ :repo = paR[:repo], :staged = 0, :reason = _g_[2], :dir = "", :bytes = 0 ] ok
		_s_ = StzModelFileState(_aP_[_k_], 1)
		if _s_[:digest] != "ok"
			return [ :repo = paR[:repo], :staged = 0, :reason = _aP_[_k_] + ": " + _s_[:reason] + " -- a release publishes only the catalogued bytes", :dir = "", :bytes = 0 ]
		ok
	next
	if NOT StzDirExists(_cDir_) StzDirCreatePath(_cDir_) ok
	_nB_ = 0
	for _k_ = 1 to len(_aP_)
		_e_ = StzModelCatalogEntry(_aP_[_k_])
		_cDst_ = _cDir_ + "/" + StzEnginePathBasename(_aP_[_k_])
		if NOT (fexists(_cDst_) and lower(StzModelDigest(_cDst_)) = lower(_e_[:sha256]))
			if StzEngineFileCopy(StzModelsDir() + "/" + _aP_[_k_], _cDst_) != 1
				return [ :repo = paR[:repo], :staged = 0, :reason = "could not copy " + _aP_[_k_] + " to " + _cDst_, :dir = _cDir_, :bytes = 0 ]
			ok
			if lower(StzModelDigest(_cDst_)) != lower(_e_[:sha256])
				return [ :repo = paR[:repo], :staged = 0, :reason = "the copy " + _cDst_ + " is not the catalogued bytes", :dir = _cDir_, :bytes = 0 ]
			ok
		ok
		_nB_ += _e_[:bytes]
	next
	write(_cDir_ + "/LICENSE", read(StzModelsDir() + "/" + paR[:licencefile]))
	write(_cDir_ + "/NOTICE", _StzReleaseNotice(paR))
	write(_cDir_ + "/SHA256SUMS", _StzReleaseSums(paR))
	write(_cDir_ + "/softanza.zcat", _StzReleaseManifest(paR, pcVersion))
	write(_cDir_ + "/README.md", _StzReleaseCard(paR, pcVersion))
	return [ :repo = paR[:repo], :staged = 1, :reason = "staged: " + len(_aP_) + " file(s), " + _nB_ + " bytes, each checked against its sha256", :dir = _cDir_, :bytes = _nB_ ]

func _StzReleaseSums(paR)
	_c_ = ""
	for _k_ = 1 to len(paR[:paths])
		_c_ += lower(StzModelCatalogEntry(paR[:paths][_k_])[:sha256]) + "  " + StzEnginePathBasename(paR[:paths][_k_]) + char(10)
	next
	return _c_

func _StzLicenceOfRepo(paR)
	return StzModelCatalogEntry(paR[:paths][1])[:licence]

func _StzReleaseNotice(paR)
	_cNl_ = char(10)
	return paR[:title] + " -- converted for Softanza" + _cNl_ + _cNl_ +
		"This repository holds files converted by Softanza (" + $cStzSoftanzaSource + ") from" + _cNl_ +
		paR[:upstream] + "." + _cNl_ + _cNl_ +
		"The original work is licensed under " + _StzLicenceOfRepo(paR) + "; its full text is in LICENSE, and it governs" + _cNl_ +
		"these files. Any NOTICE the upstream distribution carries applies to them as well." + _cNl_ + _cNl_ +
		"Changes: the original model's graph and weights were re-encoded into GGUF files that the Softanza" + _cNl_ +
		"engine reads (architecture stz-ocr-graph). Nothing was trained. The steps for each file are in" + _cNl_ +
		"README.md and softanza.zcat." + _cNl_

# the catalogue rows of this repository's files, as the manifest a Softanza installation reads
func _StzReleaseManifest(paR, pcVersion)
	_cNl_ = char(10)
	_c_ = "# zcat 1 -- the manifest of " + paR[:repo] + " " + pcVersion + ", written by StzModelReleaseStage from models/catalog.zcat." + _cNl_ +
	      "# A path is where the file goes in a Softanza models directory; in this repository the file sits at the root under its name." + _cNl_ +
	      "# The sha256 a Softanza installation checks is the one in ITS catalogue (in git), not this copy." + _cNl_
	for _k_ = 1 to len(paR[:paths])
		_e_ = StzModelCatalogEntry(paR[:paths][_k_])
		_c_ += "file|" + _e_[:path] + "|" + _e_[:bytes] + "|" + _e_[:sha256] + "|" + _e_[:licence] + "|" + _e_[:how] + "|" + _e_[:url] + "|" +
		       _e_[:sourcebytes] + "|" + _e_[:sourcesha256] + "|" + _e_[:steps] + _cNl_
	next
	_aRq_ = StzModelCatalog()[:requires]
	for _i_ = 1 to len(_aRq_)
		if NOT _StzAnyIn(_aRq_[_i_][:paths], paR[:paths]) loop ok
		_cW_ = ""
		if len(_aRq_[_i_][:langs]) > 0 _cW_ = "lang=" + _StzJoinComma(_aRq_[_i_][:langs]) ok
		_c_ += "requires|" + _aRq_[_i_][:faculty] + "|" + _aRq_[_i_][:impl] + "|" + StzReplace(_StzJoinComma(_aRq_[_i_][:paths]), ", ", ",") + "|" + _cW_ + _cNl_
	next
	_c_ += "repo|" + paR[:repo] + "|" + StzReplace(_StzJoinComma(paR[:paths]), ", ", ",") + "|" + paR[:licencefile] + "|" + paR[:upstream] + "|" + paR[:title] + _cNl_
	_c_ += "release|" + paR[:repo] + "|" + pcVersion + "|staged||" + _StzIsoToday() + _cNl_
	return _c_

# THE MODEL CARD: what the files are, where they come from, how each was made, what Softanza measured them to do -- and the limits of that
func _StzReleaseCard(paR, pcVersion)
	_cNl_ = char(10)
	_cLic_ = _StzLicenceOfRepo(paR)
	_cHfLic_ = lower(_cLic_)
	_c_ = "---" + _cNl_ + "license: " + _cHfLic_ + _cNl_ + "library_name: softanza" + _cNl_
	if left(paR[:upstream], len($cStzHubBase) + 1) = $cStzHubBase + "/"
		_c_ += "base_model: " + right(paR[:upstream], len(paR[:upstream]) - len($cStzHubBase) - 1) + _cNl_
	ok
	_c_ += "tags:" + _cNl_ + "- softanza" + _cNl_ + "- gguf" + _cNl_ + "- stz-ocr-graph" + _cNl_ + "---" + _cNl_ + _cNl_
	_c_ += "# " + paR[:title] + ", converted for Softanza" + _cNl_ + _cNl_
	_c_ += "These files are " + paR[:title] + " converted by [Softanza](" + $cStzSoftanzaSource + ") from [its upstream](" + paR[:upstream] +
	       "). They are GGUF files of architecture `stz-ocr-graph`: the Softanza engine reads them. They are not llama.cpp models, and llama.cpp " +
	       "cannot run them." + _cNl_ + _cNl_ +
	       "Release " + pcVersion + ". Softanza fetches a file from here only on a developer's explicit call (`StzModelFetchFile`), streams it to disk, " +
	       "and keeps it only when its sha256 is the one written in Softanza's own catalogue (`models/catalog.zcat`, in git). This repository is a " +
	       "mirror; the catalogue is the authority." + _cNl_ + _cNl_
	_c_ += "## Files" + _cNl_ + _cNl_
	for _k_ = 1 to len(paR[:paths])
		_e_ = StzModelCatalogEntry(paR[:paths][_k_])
		_c_ += "### " + StzEnginePathBasename(_e_[:path]) + _cNl_ + _cNl_ +
		       "- size: " + _e_[:bytes] + " bytes" + _cNl_ +
		       "- sha256: `" + lower(_e_[:sha256]) + "`" + _cNl_ +
		       "- made from: " + _e_[:url]
		if _e_[:sourcesha256] != "" _c_ += " (sha256 `" + _e_[:sourcesha256] + "`)" ok
		_c_ += _cNl_ + "- steps: `" + _e_[:steps] + "`" + _cNl_ +
		       "- replayed: " + _StzReplayedOf(_e_[:path]) + _cNl_ + _cNl_
	next
	_c_ += "## What Softanza measured" + _cNl_ + _cNl_ + _StzReleaseMeasured(paR) + _cNl_
	_c_ += "These numbers come from Softanza's own golden sets, each of n items, run on one Windows machine. They say what the file did there, " +
	       "against the other implementations of the same faculty. They do not say what it will do on your data, and they are not a benchmark " +
	       "of the original model." + _cNl_ + _cNl_
	_c_ += "## Check" + _cNl_ + _cNl_ + "```" + _cNl_ + "sha256sum -c SHA256SUMS" + _cNl_ + "```" + _cNl_ + _cNl_ +
	       "In Softanza, a graph model is parsed only once its sha256 is the recorded one; a file with any other digest is refused before parsing." + _cNl_ + _cNl_
	_c_ += "## Licence" + _cNl_ + _cNl_ + _cLic_ + ", as the upstream model: see LICENSE and NOTICE. The upstream model card governs its intended use." + _cNl_
	return _c_

# one line per faculty and implementation these files serve: each measurement, and where the court puts it
func _StzReleaseMeasured(paR)
	_cNl_ = char(10)
	_c_ = ""
	_aSeen_ = []
	_aRq_ = StzModelCatalog()[:requires]
	_aM_ = StzMeasurements()
	for _i_ = 1 to len(_aRq_)
		if NOT _StzAnyIn(_aRq_[_i_][:paths], paR[:paths]) loop ok
		_cKey_ = _aRq_[_i_][:faculty] + "/" + _aRq_[_i_][:impl]
		if len(StzFind(_cKey_, _aSeen_)) > 0 loop ok
		_aSeen_ + _cKey_
		_cF_ = _aRq_[_i_][:faculty]
		_cI_ = _aRq_[_i_][:impl]
		_c_ += "- faculty `:" + _cF_ + "`, implementation `" + _cI_ + "`:"
		_n_ = 0
		for _m_ = 1 to len(_aM_)
			if _aM_[_m_][:faculty] != _cF_ or _aM_[_m_][:impl] != _cI_ loop ok
			if _aM_[_m_][:n] = 0 loop ok
			_n_++
			_c_ += _cNl_ + "  - " + _aM_[_m_][:golden] + ": " + _StzRound2(_aM_[_m_][:score]) + " over " + _aM_[_m_][:n] + " items; " +
			       _StzReleaseCourtLine(_cF_, _cI_, _aM_[_m_][:golden])
		next
		if _n_ = 0 _c_ += " not measured yet" ok
		_c_ += _cNl_
	next
	if _c_ = "" _c_ = "- no faculty names these files yet" + _cNl_ ok
	return _c_

func _StzReleaseCourtLine(pcF, pcImpl, pcGold)
	_cInc_ = StzCourtIncumbent(pcF, pcGold)
	if _cInc_ = ""
		# no incumbent recorded: the floor is the bar, as the registry resolves it (and as the setup plan says)
		_aI_ = StzFacultyQ(pcF).Implementations()
		for _i_ = 1 to len(_aI_)
			if _aI_[_i_][:kind] = "floor" _cInc_ = _aI_[_i_][:id] ok
		next
	ok
	if _cInc_ = "" return "no court has sat on this golden set" ok
	if _cInc_ = pcImpl and NOT StzCourtHasRecords(pcF, pcGold) return "the floor, with no challenger heard by the court" ok
	if _cInc_ = pcImpl return "the court's incumbent: the answer Softanza gives by default" ok
	_v_ = StzCourtVerdictOf(pcF, pcGold, pcImpl, _cInc_)
	if len(_v_) = 0 return "no court evidence yet against the incumbent '" + _cInc_ + "'" ok
	if _v_[:verdict] = "upheld" return "UPHELD by the court over '" + _cInc_ + "' (" + _v_[:gains] + " better, " + _v_[:losses] + " worse)" ok
	# a challenger the court did not uphold still answers wherever the incumbent cannot run (MP0: capability before quality)
	return "not upheld against '" + _cInc_ + "' (" + _v_[:gains] + " better, " + _v_[:losses] + " worse): Softanza chooses it where '" + _cInc_ + "' cannot run"

# the script the AUTHOR runs, signed in to the hub, to upload what was staged (and nothing else)
func _StzUploadScript(paStaged, pcVersion)
	_cNl_ = char(13) + char(10)
	_c_ = "# Softanza model release " + pcVersion + " -- written by StzModelReleaseStage on " + _StzIsoToday() + "." + _cNl_ +
	      "# Run it YOURSELF, signed in to Hugging Face with write access to the organisation that owns the repositories." + _cNl_ +
	      "# It uploads the folders beside it and nothing else; every model file in them was checked against its sha256 when staged." + _cNl_ +
	      "#   install the CLI once:   powershell -ExecutionPolicy ByPass -c " + char(34) + "irm https://hf.co/cli/install.ps1 | iex" + char(34) + _cNl_ +
	      "#   sign in once:           hf auth login" + _cNl_ +
	      "$ErrorActionPreference = " + char(34) + "Stop" + char(34) + _cNl_ +
	      "function Run([string[]]$a) { & hf @a; if ($LASTEXITCODE -ne 0) { throw (" + char(34) + "hf " + char(34) + " + ($a -join ' ') + " + char(34) + " failed" + char(34) + ") } }" + _cNl_ +
	      "Run @('auth', 'whoami')" + _cNl_
	_nUp_ = 0
	for _i_ = 1 to len(paStaged)
		_s_ = paStaged[_i_]
		if _s_[:staged] != 1
			_c_ += _cNl_ + "# NOT STAGED, not uploaded: " + _s_[:repo] + " -- " + _s_[:reason] + _cNl_
			loop
		ok
		_nUp_++
		_cT_ = StzModelRepoNamed(_s_[:repo])[:title]
		_c_ += _cNl_ + "# " + _s_[:repo] + ": " + _s_[:bytes] + " bytes" + _cNl_ +
		       "Run @('repos', 'create', '" + _s_[:repo] + "', '--exist-ok')" + _cNl_ +
		       "Run @('upload', '" + _s_[:repo] + "', '" + _s_[:dir] + "', '.', '--commit-message', 'Softanza release " + pcVersion + ": " + StzReplace(_cT_, "'", "''") + "')" + _cNl_ +
		       "Run @('repos', 'tag', 'create', '" + _s_[:repo] + "', '" + pcVersion + "', '-m', 'Softanza release " + pcVersion + "')" + _cNl_
	next
	_c_ += _cNl_ + "Write-Host 'Uploaded " + _nUp_ + " repositories. Record each release in the catalogue with the commit its upload printed:'" + _cNl_
	for _i_ = 1 to len(paStaged)
		if paStaged[_i_][:staged] = 1
			_c_ += "Write-Host " + char(34) + "  StzModelReleaseMark('" + paStaged[_i_][:repo] + "', '" + pcVersion + "', 'published', '<commit>')" + char(34) + _cNl_
		ok
	next
	return _c_

# THE FETCH of one catalogued file into the models directory: the developer's explicit act. Streamed to disk, kept only with the sha256 and
# size this catalogue records (the engine refuses anything else and leaves nothing at the path).
#
#   returns    [ :path, :ok = 1|0, :reason, :bytes ]
#   see        StzModelFetch, StzModelFetchSource
func StzModelFetchFile(pcPath)
	return StzModelFetchFileTo(pcPath, StzModelsDir())

# the same, into another models directory (a deployment's, a guard's)
func StzModelFetchFileTo(pcPath, pcDir)
	_e_ = StzModelCatalogEntry(pcPath)
	if len(_e_) = 0 return [ :path = pcPath, :ok = 0, :reason = pcPath + " is not in the catalogue: there is no sha256 to fetch it against", :bytes = 0 ] ok
	_cFull_ = pcDir + "/" + pcPath
	if fexists(_cFull_) and lower(StzModelDigest(_cFull_)) = lower(_e_[:sha256])
		return [ :path = pcPath, :ok = 1, :reason = "already here and intact (sha256 checked)", :bytes = _e_[:bytes] ]
	ok
	_cUrl_ = StzModelFetchSource(pcPath)
	if _cUrl_ = ""
		return [ :path = pcPath, :ok = 0, :reason = pcPath + " is not published anywhere Softanza fetches from: make it with its steps (" + _e_[:steps] + ")", :bytes = 0 ]
	ok
	_n_ = StzEngineHttpDownloadVerified(_cUrl_, _cFull_, _e_[:sha256], _e_[:bytes], "")
	if _n_ = 1
		return [ :path = pcPath, :ok = 1, :reason = "fetched from " + _cUrl_ + " and kept: " + _e_[:bytes] + " bytes, sha256 the catalogued one", :bytes = _e_[:bytes] ]
	ok
	return [ :path = pcPath, :ok = 0, :reason = _StzFetchCode(_n_) + ": " + StzEngineHttpLastError(), :bytes = StzEngineHttpDownloadBytes() ]

func _StzFetchCode(n)
	if n = -1 return "the transfer failed" ok
	if n = -2 return "the server refused" ok
	if n = -3 return "REFUSED, not the catalogued file" ok
	if n = -4 return "REFUSED, not the catalogued size" ok
	if n = -5 return "the file could not be written" ok
	if n = -6 return "no recorded sha256" ok
	return "failed (" + n + ")"

# Fetches every file a faculty's setup plan lists that can be fetched ("" = every faculty), one after the other. Files that can only be
# made are reported with their steps, not attempted.
#
#   returns    [ [ :path, :ok, :reason, :bytes ] ... ]
func StzModelFetch(pcFaculty)
	_aOut_ = []
	_aSeen_ = []
	_aP_ = StzModelSetupPlan(pcFaculty)
	for _i_ = 1 to len(_aP_)
		if _aP_[_i_][:kind] != "file" loop ok
		if len(StzFind(_aP_[_i_][:path], _aSeen_)) > 0 loop ok
		_aSeen_ + _aP_[_i_][:path]
		_aOut_ + StzModelFetchFile(_aP_[_i_][:path])
	next
	return _aOut_
