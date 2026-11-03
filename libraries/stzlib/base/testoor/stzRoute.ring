# Testoor -- routes before roads, and the map. TR3 of SOFTANZA_TESTOOR_PLAN.md.
#
# A ROUTE is a meaningful path declared BEFORE it is walked: a plan item
# (GG6, DN12, TR3 ...), the thing the library promised to build. A TOUR
# walks a route by saying so -- `discharges("GG6")` in a gate (the dialect
# that already did), or `Route("GG6")` in any other tour. Coverage is first
# the count of routes that have a tour (ruling 8): OWNED and WALKED are two
# figures and are never summed, and no line or branch percentage is printed
# until this exists. None is printed here either: a ratio of two counts of
# different things is the percentage the ruling refuses.
#
# THE JOIN, and what is reused. The plan's items and their status come from
# the court's own reader (StzPlanItemsOf, base/meta/stzCodeRules.ring); the
# declarations come from the tour reader (stzTour.ring), which sees
# discharges() and Route() in every dialect; the court's plan rules
# (StzCheckPlanCoverage) run over the same two lists, so a guard section that
# names an item the plan does not define, or an item reading open that a
# section discharges, is the court's finding and not a second opinion. What
# this file adds is the one rule the court did not have:
#
#   route_without_tour   a plan item no tour walks.
#                        severity WARNING when the plan reads it closed --
#                        something is claimed done that nothing walks -- and
#                        INFO when it reads open or unstated, which is
#                        expected: nobody has promised it yet.
#
# THE MAP is the code graph (base/meta/stzRingCodeGraph.ring). Untouched
# methods are named by a STATIC NAME JOIN: a method of a class is touched
# when a tour in scope names it as a call (`.Name(` or `Name(`, any case --
# Ring is case-insensitive). It is a proxy for a route, not execution
# coverage: a method reached only through another method reads untouched,
# and a method named in a tour that never ran it reads touched. That is
# stated in every report that uses it, because the report must not be read
# as more than it measures. Names beginning with an underscore and `init`
# are not public surface and are not listed.
#
# Locals are _underscored_ for the reason stzTour.ring gives; nothing here
# reads or writes a top-level name, so it is clean under Rule A.

#--- Route ------------------------------------------------------------------

# Declares, inside a tour, the plan item it walks. A no-op at run time: the
# declaration is READ from the source by the tour reader, and running it
# only has to be harmless.
func Route(pcId)
	return 1

func StzRouteMapQ()
	return new stzRouteMap()

#--- the name join ----------------------------------------------------------

# The index of pcItem in a list of lower-case names, or 0. Not a binary search:
# Ring has binarysearch() and Ring++ does not (R3 on rnxc), and comparing two
# strings with < raises on Ring 1.27 (R41, invalid numeric string) while rnxc
# accepts it, so the one operation both VMs agree on is a plain find. Callers
# hand it de-duplicated lists, which keeps it fast.
func _RouteIndexOf(paNames, pcItem)
	return ring_find(paNames, pcItem)

# every identifier a source CALLS, lowercased, sorted, unique:
# `.Foo(`, `Foo(`, `Foo (` -- not definitions (`def Foo(`, `func Foo(`)
func _RouteCalledNames(pcSource)
	_acL_ = str2list(substr("" + pcSource, char(13), ""))
	_nL_ = len(_acL_)
	_acOut_ = []
	for _i_ = 1 to _nL_
		_c_ = _acL_[_i_]
		_n_ = len(_c_)
		if _n_ = 0  loop  ok
		_lt_ = lower(trim(_c_))
		if substr(_lt_, "#") = 1  loop  ok
		_bSkip_ = (substr(_lt_, "def ") = 1 or substr(_lt_, "func ") = 1 or substr(_lt_, "class ") = 1)
		_k_ = 1
		while _k_ <= _n_
			_ch_ = _c_[_k_]
			if _TravIsAlpha(_ch_) or _ch_ = "_"
				_j_ = _k_
				while _j_ <= _n_ and _TravIsWordChar(_c_[_j_])  _j_++  end
				_nSkip_ = _j_
				while _nSkip_ <= _n_ and _c_[_nSkip_] = " "  _nSkip_++  end
				if _nSkip_ <= _n_ and _c_[_nSkip_] = "("
					# the first call-shaped name on a def/func line is the
					# definition's own name, not a call
					if _bSkip_
						_bSkip_ = 0
					else
						_acOut_ + lower(substr(_c_, _k_, _j_ - _k_))
					ok
				ok
				_k_ = _j_
			else
				_k_++
			ok
		end
	next
	_acOut_ = sort(_acOut_)
	_acU_ = []
	_nO_ = len(_acOut_)
	for _i_ = 1 to _nO_
		if _i_ = 1 or _acOut_[_i_] != _acOut_[_i_ - 1]  _acU_ + _acOut_[_i_]  ok
	next
	return _acU_

# the public methods of every class in a Ring source that no tour names:
# [ [ class, line, method ] ... ] in source order
func StzUntouchedMethods(pcClassFile, pacTourFiles)
	_cSrc_ = ""
	try
		_cSrc_ = read("" + pcClassFile)
	catch
		return []
	done
	_acTours_ = []
	_nT_ = len(pacTourFiles)
	for _i_ = 1 to _nT_
		_cT_ = ""
		try
			_cT_ = read("" + pacTourFiles[_i_])
		catch
			_cT_ = ""
		done
		_acC_ = _RouteCalledNames(_cT_)
		_nC_ = len(_acC_)
		for _k_ = 1 to _nC_
			_acTours_ + _acC_[_k_]
		next
	next
	_acTours_ = sort(_acTours_)
	# one entry per name: the lookups below are linear
	_acUniq_ = []
	_nTn_ = len(_acTours_)
	for _i_ = 1 to _nTn_
		if _i_ = 1
			_acUniq_ + _acTours_[_i_]
		but _acTours_[_i_] != _acTours_[_i_ - 1]
			_acUniq_ + _acTours_[_i_]
		ok
	next
	_acTours_ = _acUniq_
	_oG_ = StzRingCodeGraphFromSource(_cSrc_)
	_aML_ = _oG_.MethodsWithLines()
	_nM_ = len(_aML_)
	_aOut_ = []
	for _i_ = 1 to _nM_
		_cM_ = "" + _aML_[_i_][2]
		_lm_ = lower(_cM_)
		if left(_lm_, 1) = "_" or _lm_ = "init"  loop  ok
		if _RouteIndexOf(_acTours_, _lm_) = 0
			_aOut_ + [ "" + _aML_[_i_][1], _aML_[_i_][3], _cM_ ]
		ok
	next
	return _aOut_

#--- stzRouteMap ------------------------------------------------------------

class stzRouteMap from stzObject

	@aItems = []        # [ id, status, line, label ]
	@aWalks = []        # [ id, file, stop, line ]
	@aPlanDischarges = []   # [ [ label, [ [ id, stop ] ... ] ] ... ], for the court
	@aPlanTexts = []        # [ [ label, text ] ... ]
	@aTouched = []      # [ [ class, line, method ] ... ] untouched, from the map
	@aMapFor = []       # [ class file, tour count ]

	def init()
		@aItems = []
		@aWalks = []
		@aPlanTexts = []
		@aTouched = []

	#-- the plan: the routes owned ---------------------------------------

	def AddPlan(pcLabel, pcPlanText)
		_aIt_ = StzPlanItemsOf("" + pcPlanText)
		_n_ = ring_len(_aIt_)
		for _k_ = 1 to _n_
			@aItems + [ _aIt_[_k_][1], _aIt_[_k_][2], _aIt_[_k_][3], "" + pcLabel ]
		next
		@aPlanTexts + [ "" + pcLabel, "" + pcPlanText ]
		return This

	def AddPlanFile(pcPath)
		_c_ = ""
		try
			_c_ = read("" + pcPath)
		catch
			return This
		done
		return This.AddPlan("" + pcPath, _c_)

	#-- the tours: the routes walked -------------------------------------

	# one reader record (Tour(path)); its discharges() and Route() are walks
	def AddTour(paRec)
		_n_ = ring_len(paRec[:routes])
		for _k_ = 1 to _n_
			@aWalks + [ paRec[:routes][_k_][:item], paRec[:file],
			            paRec[:routes][_k_][:stop], paRec[:routes][_k_][:line] ]
		next
		return This

	def AddTours(poLogbook)
		_aR_ = poLogbook.Records()
		_n_ = ring_len(_aR_)
		for _k_ = 1 to _n_
			This.AddTour(_aR_[_k_])
		next
		return This

	# every tour under a folder, read here (no run)
	def AddToursUnder(pcDir)
		return This.AddTours(StzLogbookQ().ReadTree("" + pcDir, ""))

	#-- the figures ------------------------------------------------------

	def Items()
		return @aItems

	def Owned()
		return This._UniqueIds(@aItems)

	def _UniqueIds(paList)
		_acOut_ = []
		_n_ = ring_len(paList)
		for _k_ = 1 to _n_
			if ring_find(_acOut_, paList[_k_][1]) = 0  _acOut_ + paList[_k_][1]  ok
		next
		return _acOut_

	def OwnedCount()
		return ring_len(This.Owned())

	def IsWalked(pcId)
		_n_ = ring_len(@aWalks)
		for _k_ = 1 to _n_
			if @aWalks[_k_][1] = pcId  return 1  ok
		next
		return 0

	# the ids that have at least one tour, in plan order
	def Walked()
		_acOut_ = []
		_ac_ = This.Owned()
		_n_ = ring_len(_ac_)
		for _k_ = 1 to _n_
			if This.IsWalked(_ac_[_k_])  _acOut_ + _ac_[_k_]  ok
		next
		return _acOut_

	def WalkedCount()
		return ring_len(This.Walked())

	# [ id, status, line, label ] of every route no tour walks, plan order
	def Unwalked()
		_aOut_ = []
		_acSeen_ = []
		_n_ = ring_len(@aItems)
		for _k_ = 1 to _n_
			_cId_ = @aItems[_k_][1]
			if ring_find(_acSeen_, _cId_) > 0  loop  ok
			_acSeen_ + _cId_
			if NOT This.IsWalked(_cId_)  _aOut_ + @aItems[_k_]  ok
		next
		return _aOut_

	def UnwalkedCount()
		return ring_len(This.Unwalked())

	# [ id, file, stop, line ] of every walk naming an item no plan defines
	def UnknownWalks()
		_ac_ = This.Owned()
		_aOut_ = []
		_n_ = ring_len(@aWalks)
		for _k_ = 1 to _n_
			if ring_find(_ac_, @aWalks[_k_][1]) = 0  _aOut_ + @aWalks[_k_]  ok
		next
		return _aOut_

	#-- the map: untouched methods ---------------------------------------

	# names the public methods of a class file that no tour of the given
	# files names; the answer is kept for Findings() and Json()
	def MapMethods(pcClassFile, pacTourFiles)
		_aU_ = StzUntouchedMethods(pcClassFile, pacTourFiles)
		_n_ = ring_len(_aU_)
		for _k_ = 1 to _n_
			@aTouched + [ _aU_[_k_][1], _aU_[_k_][2], _aU_[_k_][3], "" + pcClassFile ]
		next
		@aMapFor + [ "" + pcClassFile, ring_len(pacTourFiles) ]
		return This

	def UntouchedMethods()
		return @aTouched

	#-- the court --------------------------------------------------------

	# findings in the unified shape [ :rule, :subject, :where, :severity, :message ],
	# for stzRuleReport.Ingest(): the court's own plan rules over these two
	# lists, then the rules of this file
	def Findings()
		_aOut_ = []
		_nP_ = ring_len(@aPlanTexts)
		for _p_ = 1 to _nP_
			_cLabel_ = @aPlanTexts[_p_][1]
			_aDis_ = []
			_nW_ = ring_len(@aWalks)
			for _k_ = 1 to _nW_
				_aDis_ + [ @aWalks[_k_][1], @aWalks[_k_][3] ]
			next
			_aF_ = StzCheckPlanCoverage(@aPlanTexts[_p_][2], _cLabel_, _aDis_)
			_nF_ = ring_len(_aF_)
			for _k_ = 1 to _nF_
				_aOut_ + _aF_[_k_]
			next
		next
		_aU_ = This.Unwalked()
		_nU_ = ring_len(_aU_)
		for _k_ = 1 to _nU_
			_cSev_ = :info
			_cWhy_ = "the plan reads it " + _aU_[_k_][2] + ", which is expected: nobody has promised it yet"
			if _aU_[_k_][2] = "closed"
				_cSev_ = :warning
				_cWhy_ = "the plan reads it closed, and no tour walks it: something is claimed done that nothing walks"
			ok
			_aOut_ + [ :rule = :route_without_tour, :subject = :route,
			           :where = _aU_[_k_][4] + ":" + _aU_[_k_][3], :severity = _cSev_,
			           :message = "route " + _aU_[_k_][1] + " has no tour -- " + _cWhy_ ]
		next
		# A walk naming a route no plan defines is the court's own finding,
		# guard_discharges_unknown_item (StzCheckPlanCoverage above); a second
		# rule for the same fact would count it twice.
		_nM_ = ring_len(@aTouched)
		for _k_ = 1 to _nM_
			_aOut_ + [ :rule = :method_without_tour, :subject = @aTouched[_k_][1],
			           :where = @aTouched[_k_][4] + ":" + @aTouched[_k_][2], :severity = :info,
			           :message = "method " + @aTouched[_k_][3] + " is named by no tour in scope (a static name join, not execution coverage)" ]
		next
		return _aOut_

	# 1 when the court has a finding of warning or worse
	def NeedsAttention()
		_aF_ = This.Findings()
		_n_ = ring_len(_aF_)
		for _k_ = 1 to _n_
			_c_ = "" + _aF_[_k_][:severity]
			if _c_ = "warning" or _c_ = "error"  return 1  ok
		next
		return 0

	#-- the logbook faces -------------------------------------------------

	def Prose()
		_c_ = "routes owned " + This.OwnedCount() + ", walked " + This.WalkedCount() +
		      ", unwalked " + This.UnwalkedCount() + "  (counts, never summed, never a percentage)" + char(10)
		_aU_ = This.Unwalked()
		_nU_ = ring_len(_aU_)
		for _k_ = 1 to _nU_
			_c_ += "  UNWALKED  " + _aU_[_k_][1] + "  (" + _aU_[_k_][2] + ")  " + _aU_[_k_][4] + ":" + _aU_[_k_][3] + char(10)
		next
		_aUk_ = This.UnknownWalks()
		_nK_ = ring_len(_aUk_)
		for _k_ = 1 to _nK_
			_c_ += "  UNKNOWN   " + _aUk_[_k_][1] + "  declared in " + _aUk_[_k_][2] + char(10)
		next
		_nM_ = ring_len(@aTouched)
		if _nM_ > 0
			_c_ += "untouched methods (a static name join, not execution coverage): " + _nM_ + char(10)
			for _k_ = 1 to _nM_
				_c_ += "  " + @aTouched[_k_][1] + "." + @aTouched[_k_][3] + "  line " + @aTouched[_k_][2] + char(10)
			next
		ok
		return _c_

	def Json()
		_c_ = '{"testoor":"logbook","kind":"routes","owned":' + This.OwnedCount() +
		      ',"walked":' + This.WalkedCount() + ',"unwalked":['
		_aU_ = This.Unwalked()
		_nU_ = ring_len(_aU_)
		for _k_ = 1 to _nU_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"route":' + _TourJsonStr(_aU_[_k_][1]) + ',"status":' + _TourJsonStr(_aU_[_k_][2]) +
			       ',"where":' + _TourJsonStr(_aU_[_k_][4] + ":" + _aU_[_k_][3]) + "}"
		next
		_c_ += '],"unknown":['
		_aUk_ = This.UnknownWalks()
		_nK_ = ring_len(_aUk_)
		for _k_ = 1 to _nK_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"route":' + _TourJsonStr(_aUk_[_k_][1]) + ',"tour":' + _TourJsonStr(_aUk_[_k_][2]) + "}"
		next
		_c_ += '],"untouched_methods":['
		_nM_ = ring_len(@aTouched)
		for _k_ = 1 to _nM_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"class":' + _TourJsonStr(@aTouched[_k_][1]) + ',"method":' + _TourJsonStr(@aTouched[_k_][3]) +
			       ',"line":' + @aTouched[_k_][2] + "}"
		next
		_c_ += '],"findings":['
		_aF_ = This.Findings()
		_nF_ = ring_len(_aF_)
		for _k_ = 1 to _nF_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"rule":' + _TourJsonStr(_aF_[_k_][:rule]) + ',"severity":' + _TourJsonStr(_aF_[_k_][:severity]) +
			       ',"where":' + _TourJsonStr(_aF_[_k_][:where]) + ',"message":' + _TourJsonStr(_aF_[_k_][:message]) + "}"
		next
		_c_ += "]}"
		return _c_
