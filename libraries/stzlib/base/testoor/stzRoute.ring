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

	# Builds a route map holding no plan items, no walks and no untouched methods.
	#
	#   returns    nothing; the object is built
	#   see        AddPlan, AddTour
	def init()
		@aItems = []
		@aWalks = []
		@aPlanTexts = []
		@aTouched = []

	#-- the plan: the routes owned ---------------------------------------#

	# Adds the items of a plan text to the routes owned, read by the court's own plan reader.
	#
	#   pcLabel      the name the plan goes by in findings and reports, such as its file path
	#   pcPlanText   the text of the plan, not a path
	#   returns      the map itself, so calls chain
	#   see          AddPlanFile, Items
	def AddPlan(pcLabel, pcPlanText)
		_aIt_ = StzPlanItemsOf("" + pcPlanText)
		_n_ = ring_len(_aIt_)
		for _k_ = 1 to _n_
			@aItems + [ _aIt_[_k_][1], _aIt_[_k_][2], _aIt_[_k_][3], "" + pcLabel ]
		next
		@aPlanTexts + [ "" + pcLabel, "" + pcPlanText ]
		return This

	# Reads a plan file and adds its items to the routes owned, labelled by the file's path.
	#
	#   pcPath     the path of the plan file
	#   returns    the map itself, so calls chain
	#   warning    a file that cannot be read adds nothing and raises nothing
	#   see        AddPlan
	def AddPlanFile(pcPath)
		_c_ = ""
		try
			_c_ = read("" + pcPath)
		catch
			return This
		done
		return This.AddPlan("" + pcPath, _c_)

	#-- the tours: the routes walked -------------------------------------#

	# Adds the walks one tour record declares, through its discharges() and Route() calls.
	#
	#   paRec      a record of the tour reader (Tour(path)), read for its :file and its :routes, each with :item,
	#              :stop and :line
	#   returns    the map itself, so calls chain
	#   see        AddTours, AddToursUnder
	def AddTour(paRec)
		_n_ = ring_len(paRec[:routes])
		for _k_ = 1 to _n_
			@aWalks + [ paRec[:routes][_k_][:item], paRec[:file],
			            paRec[:routes][_k_][:stop], paRec[:routes][_k_][:line] ]
		next
		return This

	# Adds the walks of every record a logbook holds.
	#
	#   poLogbook  a logbook whose Records() are tour records
	#   returns    the map itself, so calls chain
	#   see        AddTour
	def AddTours(poLogbook)
		_aR_ = poLogbook.Records()
		_n_ = ring_len(_aR_)
		for _k_ = 1 to _n_
			This.AddTour(_aR_[_k_])
		next
		return This

	# Reads every tour under a folder and adds their walks, without running any of them.
	#
	#   pcDir      the folder to read the tours under
	#   returns    the map itself, so calls chain
	#   see        AddTours
	def AddToursUnder(pcDir)
		return This.AddTours(StzLogbookQ().ReadTree("" + pcDir, ""))

	#-- the figures ------------------------------------------------------#

	# Returns every plan item added, as [ id, status, line, label ] rows in plan order.
	#
	#   returns    a list of rows; an id met in two plans has a row for each
	#   see        Owned, AddPlan
	def Items()
		return @aItems

	# Returns the distinct ids of the routes the plans own, in the order they were first met.
	#
	#   returns    a list of ids
	#   see        OwnedCount, Walked, Unwalked
	def Owned()
		return This._UniqueIds(@aItems)

	def _UniqueIds(paList)
		_acOut_ = []
		_n_ = ring_len(paList)
		for _k_ = 1 to _n_
			if ring_find(_acOut_, paList[_k_][1]) = 0  _acOut_ + paList[_k_][1]  ok
		next
		return _acOut_

	# Returns how many distinct routes the plans own.
	#
	#   returns    a number
	#   note       owned and walked are two figures and are never summed
	#   see        Owned, WalkedCount
	def OwnedCount()
		return ring_len(This.Owned())

	# TRUE if at least one tour declares the route of that id.
	#
	#   pcId       the plan item's id, such as GG6
	#   returns    1 or 0
	#   see        Walked, Unwalked
	def IsWalked(pcId)
		_n_ = ring_len(@aWalks)
		for _k_ = 1 to _n_
			if @aWalks[_k_][1] = pcId  return 1  ok
		next
		return 0

	# Returns the owned route ids that have at least one tour, in plan order.
	#
	#   returns    a list of ids
	#   see        WalkedCount, IsWalked, Unwalked
	def Walked()
		_acOut_ = []
		_ac_ = This.Owned()
		_n_ = ring_len(_ac_)
		for _k_ = 1 to _n_
			if This.IsWalked(_ac_[_k_])  _acOut_ + _ac_[_k_]  ok
		next
		return _acOut_

	# Returns how many owned routes have at least one tour.
	#
	#   returns    a number
	#   see        Walked, OwnedCount
	def WalkedCount()
		return ring_len(This.Walked())

	# Returns every owned route that no tour walks, as [ id, status, line, label ] rows in plan order.
	#
	#   returns    a list of rows, one for each id, taken from the first plan that defines it
	#   see        UnwalkedCount, Walked
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

	# Returns how many owned routes no tour walks.
	#
	#   returns    a number
	#   see        Unwalked, OwnedCount
	def UnwalkedCount()
		return ring_len(This.Unwalked())

	# Returns every walk that names a route no plan defines, as [ id, file, stop, line ] rows.
	#
	#   returns    a list of rows
	#   see        Findings, Owned
	def UnknownWalks()
		_ac_ = This.Owned()
		_aOut_ = []
		_n_ = ring_len(@aWalks)
		for _k_ = 1 to _n_
			if ring_find(_ac_, @aWalks[_k_][1]) = 0  _aOut_ + @aWalks[_k_]  ok
		next
		return _aOut_

	#-- the map: untouched methods ---------------------------------------#

	# Adds the public methods of a class file that none of the given tour files names, for Findings and Json.
	#
	#   pcClassFile    the path of the class file
	#   pacTourFiles   a list of tour file paths
	#   returns        the map itself, so calls chain
	#   note           a static name join, not execution coverage: a method reached only through another reads
	#                  untouched, and a method named in a tour that never ran it reads touched
	#   see            UntouchedMethods
	def MapMethods(pcClassFile, pacTourFiles)
		_aU_ = StzUntouchedMethods(pcClassFile, pacTourFiles)
		_n_ = ring_len(_aU_)
		for _k_ = 1 to _n_
			@aTouched + [ _aU_[_k_][1], _aU_[_k_][2], _aU_[_k_][3], "" + pcClassFile ]
		next
		@aMapFor + [ "" + pcClassFile, ring_len(pacTourFiles) ]
		return This

	# Returns the methods MapMethods found untouched, as [ class, line, method, class file ] rows.
	#
	#   returns    a list of rows, [] before any MapMethods
	#   see        MapMethods
	def UntouchedMethods()
		return @aTouched

	#-- the court --------------------------------------------------------#

	# Returns the court's findings in the unified rule shape, from its plan rules and this file's own rules.
	#
	# The court's plan rules (StzCheckPlanCoverage) run over the plans and the walks. Then each unwalked route
	# gives route_without_tour, a WARNING when the plan reads it closed and INFO otherwise, and each untouched
	# method gives method_without_tour, INFO.
	#
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ] rows, for stzRuleReport.Ingest()
	#   see        NeedsAttention, Unwalked, MapMethods
	def Findings()
		_aOut_ = This._CourtFindings()
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

	# The court's own plan findings (StzCheckPlanCoverage over each plan and the walks), in plan order. The
	# court is Ring and stays with the face; the join's own findings are written after these.
	def _CourtFindings()
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
		return _aOut_

	# TRUE if the court has a finding of warning severity or worse.
	#
	#   returns    1 or 0
	#   see        Findings
	def NeedsAttention()
		_aF_ = This.Findings()
		_n_ = ring_len(_aF_)
		for _k_ = 1 to _n_
			_c_ = "" + _aF_[_k_][:severity]
			if _c_ = "warning" or _c_ = "error"  return 1  ok
		next
		return 0

	#-- the logbook faces -------------------------------------------------#

	# Returns the routes report as text: the counts, then each unwalked route, unknown walk and untouched method.
	#
	#   returns    a text; the counts are never summed and never turned into a percentage
	#   see        Json
	def Prose()
		_c_ = This._CoreRoutes("prose")
		if _c_ != ""  return _c_  ok
		return This._ProseRing()

	def _ProseRing()
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

	# Returns the routes report as JSON: the counts, the unwalked and unknown routes, untouched methods and findings.
	#
	#   returns    a JSON text
	#   see        Prose
	def Json()
		_c_ = This._CoreRoutes("json")
		if _c_ != ""  return _c_  ok
		return This._JsonRing()

	# The routes report from the Zig core (engine/src/testoor_routes.zig): the join, the findings it
	# raises itself, the prose and the JSON. "" when the core is not there or cannot answer, and the
	# caller then runs the reference below. A library built before this call existed falls back too.
	def _CoreRoutes(pcWhich)
		if TestoorCoreIs() != "engine"  return ""  ok
		_cOut_ = ""
		try
			if pcWhich = "json"
				_cOut_ = StzEngineTestoorRoutes(This._RoutesRequest())
			else
				_cOut_ = StzEngineTestoorRoutesProse(This._RoutesRequest())
			ok
		catch
			_cOut_ = ""
		done
		return _cOut_

	# what the face read, as the core's request: the plan items, the walks, the untouched methods, and the court's findings
	def _RoutesRequest()
		_c_ = '{"items":['
		_n_ = ring_len(@aItems)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"id":' + _TourJsonStr(@aItems[_k_][1]) + ',"status":' + _TourJsonStr(@aItems[_k_][2]) +
			       ',"line":' + @aItems[_k_][3] + ',"label":' + _TourJsonStr(@aItems[_k_][4]) + "}"
		next
		_c_ += '],"walks":['
		_n_ = ring_len(@aWalks)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"id":' + _TourJsonStr(@aWalks[_k_][1]) + ',"file":' + _TourJsonStr(@aWalks[_k_][2]) +
			       ',"stop":' + _TourJsonStr(@aWalks[_k_][3]) + ',"line":' + @aWalks[_k_][4] + "}"
		next
		_c_ += '],"untouched":['
		_n_ = ring_len(@aTouched)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"class":' + _TourJsonStr(@aTouched[_k_][1]) + ',"line":' + @aTouched[_k_][2] +
			       ',"method":' + _TourJsonStr(@aTouched[_k_][3]) + ',"file":' + _TourJsonStr(@aTouched[_k_][4]) + "}"
		next
		_c_ += '],"court":['
		_aF_ = This._CourtFindings()
		_n_ = ring_len(_aF_)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += '{"rule":' + _TourJsonStr("" + _aF_[_k_][:rule]) + ',"severity":' + _TourJsonStr("" + _aF_[_k_][:severity]) +
			       ',"where":' + _TourJsonStr("" + _aF_[_k_][:where]) + ',"message":' + _TourJsonStr("" + _aF_[_k_][:message]) + "}"
		next
		return _c_ + "]}"

	def _JsonRing()
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
