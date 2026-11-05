#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZADVISORYFEED             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# An advisory meets the inventory -- SOFTANZA_ONE_HOUR.md, B2 and B4 (rung W1).
#
# An advisory names a component and the versions it touches; stzExposure names
# what this process runs. This class holds advisories as rows, matches them
# against an exposure, and writes ONE ledger event per match -- kind
# advisory.matched, severity from the score, the component as subject, the
# advisory id as ORIGIN, exploited in the reason when the id is on the
# known-exploited list. The five kinds of the patch ledger chain by that
# origin, and StzTimeToSafe reads the number from the ledger: never from a
# person's memory.
#
# Two sources, one shape:
#   * a FIXTURE: rows seeded by a guard (SeedAdvisory), deterministic, offline --
#     the only source a guard ever uses;
#   * the LIVE feed: OSV (api.osv.dev, a JSON query per component) and CISA's
#     KEV list, fetched through the HTTP client only when a program calls
#     FetchLive -- a DOOR, declared by the call and recorded in the ledger as a
#     fact before any byte is read (ruling 4).
#
# The honest limit: OSV knows packages and kernels by name and ecosystem; a
# vendored C library is matched by its name and the version its record
# carries, and a bug in our own Zig is found by the shape rules, not here.

func StzAdvisoryFeedQ()
	return new stzAdvisoryFeed()

# Writes the door-shut record for an advisory: what was closed, and how.
func StzNoteExposureClosed(pcAdvisoryId, pcComponent, pcHow)
	StzNoteFactFrom("exposure.closed", "stzExposureResponder", "" + pcComponent, "" + pcHow, "" + pcAdvisoryId)

func StzNotePinMoved(pcAdvisoryId, pcComponent, pcFromTo)
	StzNoteFactFrom("pin.moved", "operator", "" + pcComponent, "" + pcFromTo, "" + pcAdvisoryId)

func StzNoteRebuilt(pcAdvisoryId, pcComponent, pcWhat)
	StzNoteFactFrom("rebuilt", "operator", "" + pcComponent, "" + pcWhat, "" + pcAdvisoryId)

func StzNoteGuardGreen(pcAdvisoryId, pcComponent, pcGuard)
	StzNoteFactFrom("guard.green", "operator", "" + pcComponent, "" + pcGuard, "" + pcAdvisoryId)

# The patch ledger, read for one advisory: the moments of its five kinds and
# the two numbers the budget is about. Milliseconds; -1 when a kind has not
# happened. Read from the ledger, which is why a person cannot misremember it.
func StzTimeToSafe(pcAdvisoryId)
	_a_ = [ :matchedAt = -1, :closedAt = -1, :pinMovedAt = -1, :rebuiltAt = -1, :greenAt = -1,
	        :msToClosed = -1, :msToGreen = -1 ]
	if NOT StzSecurityLedgerIsOpen()  return _a_  ok
	_aR_ = StzSecurityLedgerQ().OfOrigin("" + pcAdvisoryId)
	_n_ = len(_aR_)
	for _i_ = 1 to _n_
		_k_ = _aR_[_i_][:kind]
		_t_ = _aR_[_i_][:atWall]
		if _k_ = "advisory.matched" and _a_[:matchedAt] = -1  _a_[:matchedAt] = _t_  ok
		if _k_ = "exposure.closed"  _a_[:closedAt] = _t_  ok
		if _k_ = "pin.moved"        _a_[:pinMovedAt] = _t_  ok
		if _k_ = "rebuilt"          _a_[:rebuiltAt] = _t_  ok
		if _k_ = "guard.green"      _a_[:greenAt] = _t_  ok
	next
	if _a_[:matchedAt] >= 0 and _a_[:closedAt] >= 0  _a_[:msToClosed] = _a_[:closedAt] - _a_[:matchedAt]  ok
	if _a_[:matchedAt] >= 0 and _a_[:greenAt] >= 0   _a_[:msToGreen]  = _a_[:greenAt]  - _a_[:matchedAt]  ok
	return _a_

# The budget of ruling 4, in milliseconds: the door shut within an hour, the
# gate green within a day. One place, so a drill and a report read the same.
func StzTimeToSafeBudget()
	return [ :msToClosed = 60 * 60 * 1000, :msToGreen = 24 * 60 * 60 * 1000 ]

# TRUE when an advisory's measured times are inside the budget; -1 entries
# (not happened) are outside it.
func StzTimeToSafeHolds(pcAdvisoryId)
	_t_ = StzTimeToSafe(pcAdvisoryId)
	_b_ = StzTimeToSafeBudget()
	return _t_[:msToClosed] >= 0 and _t_[:msToClosed] <= _b_[:msToClosed] and
	       _t_[:msToGreen]  >= 0 and _t_[:msToGreen]  <= _b_[:msToGreen]


  #===================#
 #  STZADVISORYFEED  #
#===================#

# Holds published advisories and matches them against what this process runs, writing one ledger event per match.
#
# An advisory row carries an id, the component it names, the versions it touches (a prefix or
# an exact text, or * for every version), a score out of 10, and whether it is known to be
# exploited. A guard seeds rows; a program may fetch the live OSV and KEV feeds through a door.
# Match writes advisory.matched with the advisory id as origin, which is the key the patch
# ledger chains by.
#
#   receiver   o1 = new stzAdvisoryFeed()
#   example    o1.SeedAdvisory("TEST-2026-0001", "zlib", "1.3", 7.5, 0)
#              ? o1.NumberOfAdvisories()
#              #--> 1
#              ? o1.Affects("zlib 1.3.1", o1.Advisories()[1])
#              #--> 1
#   see        stzExposure, StzTimeToSafe, stzSecurityLedger
class stzAdvisoryFeed from stzObject

	@aAdvisories = []    # [ [ id, component, versions, score, exploited, summary ], ... ]
	@aMatches    = []    # the last Match: [ [ id, component, version-seen ], ... ]
	@cKevUrl     = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
	@cOsvUrl     = "https://api.osv.dev/v1/query"

	def init()

	  #-- the fixture door -----------------------------------------------------

	# Adds an advisory row by hand, the deterministic source a guard uses.
	#
	#   pcId          the advisory id, such as CVE-2026-98432 or a fixture id
	#   pcComponent   the component name as the exposure spells it: a vendored library, stz_<domain>, a model file,
	#                 or linux
	#   pcVersions    the versions touched: an exact text, a prefix such as 6.12, or * for all
	#   pnScore       the CVSS score out of 10
	#   pbExploited   1 when the id is on a known-exploited list
	#   returns       the feed itself, so calls chain
	#   see           Match, FetchLive
	def SeedAdvisory(pcId, pcComponent, pcVersions, pnScore, pbExploited)
		@aAdvisories + [ "" + pcId, StzLower("" + pcComponent), "" + pcVersions, pnScore, pbExploited, "" ]
		return This

	def Advisories()
		return @aAdvisories

	def NumberOfAdvisories()
		return len(@aAdvisories)

	def Clear()
		@aAdvisories = []
		@aMatches = []
		return This

	  #-- the live door ----------------------------------------------------------

	# Fetches the live feeds for the exposure's components through the HTTP client -- a DOOR.
	#
	#   poExposure   the stzExposure whose vendored libraries and domains are asked about
	#   returns      the number of advisory rows added
	#   note         the fetch is recorded in the ledger as a fact (kind network.fetch is not in the catalog, so it is
	#                filed as advisory.matched with origin "feed" and score 0, which a reader can tell apart) BEFORE
	#                any byte is read; a guard never calls this: it seeds instead
	#   warning      raises when no HTTP client is available; a failed fetch adds nothing and raises nothing more
	#   see          SeedAdvisory, Match
	def FetchLive(poExposure)
		_nBefore_ = len(@aAdvisories)
		_aKev_ = This._FetchKev()
		_aV_ = poExposure.Vendored()
		_n_ = len(_aV_)
		for _i_ = 1 to _n_
			This._FetchOsv(_aV_[_i_][1], _aV_[_i_][2], _aKev_)
		next
		return len(@aAdvisories) - _nBefore_

	  #-- matching -----------------------------------------------------------------

	# TRUE when an advisory's versions cover the version text the exposure carries.
	#
	#   pcVersionSeen   the version text as recorded, such as curl 8.22.0 (libcurl only)
	#   paAdvisory      an advisory row
	#   returns         TRUE or FALSE; * covers everything, a prefix covers every version starting with it
	def Affects(pcVersionSeen, paAdvisory)
		_v_ = paAdvisory[3]
		if _v_ = "*"  return 1  ok
		_cSeen_ = StzLower("" + pcVersionSeen)
		# the version is the first token that starts with a digit, in the recorded text
		_aT_ = StzSplit(_cSeen_, " ")
		_cNum_ = ""
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			if _aT_[_i_] != "" and isDigit(left(_aT_[_i_], 1))
				_cNum_ = _aT_[_i_]
				exit
			ok
		next
		if _cNum_ = ""  return 0  ok
		return left(_cNum_, len(_v_)) = _v_

	# Matches every advisory against the exposure and writes one advisory.matched event per match.
	#
	#   poExposure   the stzExposure to match against
	#   returns      the number of matches
	#   note         opens the process ledger when none is open, so a match cannot go unrecorded; a model and an
	#                engine domain are matched by name against the advisory's component (a domain as stz_<name>)
	#   see          Matches, StzTimeToSafe
	def Match(poExposure)
		if NOT StzSecurityLedgerIsOpen()  StzOpenSecurityLedger(4096)  ok
		@aMatches = []
		_aV_ = poExposure.Vendored()
		_aD_ = poExposure.Domains()
		_aM_ = poExposure.Models()
		_n_ = len(@aAdvisories)
		for _i_ = 1 to _n_
			_adv_ = @aAdvisories[_i_]
			_cSeen_ = ""
			_bHit_ = 0
			_nV_ = len(_aV_)
			for _j_ = 1 to _nV_
				if StzLower(_aV_[_j_][1]) = _adv_[2] and This.Affects(_aV_[_j_][2], _adv_)
					_bHit_ = 1  _cSeen_ = _aV_[_j_][2]  exit
				ok
			next
			if _bHit_ = 0
				_nD_ = len(_aD_)
				for _j_ = 1 to _nD_
					if "stz_" + _aD_[_j_] = _adv_[2] and _adv_[3] = "*"
						_bHit_ = 1  _cSeen_ = "loaded"  exit
					ok
				next
			ok
			if _bHit_ = 0
				_nM_ = len(_aM_)
				for _j_ = 1 to _nM_
					if StzLower(_aM_[_j_][1]) = _adv_[2] and _aM_[_j_][3] = 1
						_bHit_ = 1  _cSeen_ = "present"  exit
					ok
				next
			ok
			if _bHit_ = 1
				@aMatches + [ _adv_[1], _adv_[2], _cSeen_ ]
				This._Record(_adv_, _cSeen_)
			ok
		next
		return len(@aMatches)

	def Matches()
		return @aMatches

	def NumberOfMatches()
		return len(@aMatches)

	  #-- internals ------------------------------------------------------------------

	def _Record(paAdv, pcSeen)
		_e_ = new stzSecurityEvent("advisory.matched")
		_e_.ByActorNamed("stzAdvisoryFeed", "")
		_e_.About(paAdv[2])
		_e_.FromOrigin(paAdv[1])
		_cWhat_ = "score " + paAdv[4] + ", versions " + paAdv[3] + ", seen " + pcSeen
		if paAdv[5] = 1  _cWhat_ += ", EXPLOITED"  ok
		_e_.Observed(_cWhat_)
		if paAdv[4] >= 9 or paAdv[5] = 1
			_e_.AsError()
		ok
		StzRecordSecurityEvent(_e_)

	def _FetchKev()
		StzNoteFactFrom("advisory.matched", "stzAdvisoryFeed", "kev", "fetching " + @cKevUrl, "feed")
		_aIds_ = []
		try
			_oC_ = new stzHttpClient()
			_cBody_ = _oC_.Get_(@cKevUrl)
			_a_ = JsonToList(_cBody_)
			_aVul_ = _a_[:vulnerabilities]
			_n_ = len(_aVul_)
			for _i_ = 1 to _n_
				_aIds_ + _aVul_[_i_][:cveID]
			next
		catch
		done
		return _aIds_

	def _FetchOsv(pcName, pcVersion, paKev)
		StzNoteFactFrom("advisory.matched", "stzAdvisoryFeed", pcName, "fetching " + @cOsvUrl, "feed")
		try
			_oC_ = new stzHttpClient()
			_cQ_ = '{"package":{"name":"' + pcName + '"},"version":"' + pcVersion + '"}'
			_cBody_ = _oC_.PostJson(@cOsvUrl, _cQ_)
			_a_ = JsonToList(_cBody_)
			if NOT HasKey(_a_, :vulns)  return  ok
			_aV_ = _a_[:vulns]
			_n_ = len(_aV_)
			for _i_ = 1 to _n_
				_cId_ = _aV_[_i_][:id]
				_nScore_ = 0
				if HasKey(_aV_[_i_], :severity) and len(_aV_[_i_][:severity]) > 0
					_nScore_ = number(_aV_[_i_][:severity][1][:score])
				ok
				_bKev_ = 0
				_nK_ = len(paKev)
				for _k_ = 1 to _nK_
					if paKev[_k_] = _cId_  _bKev_ = 1  exit  ok
				next
				@aAdvisories + [ _cId_, StzLower(pcName), "*", _nScore_, _bKev_, "" ]
			next
		catch
		done
