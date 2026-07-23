#======================================================#
#  STZAPPBACKEND - LIVE CROSS-PART STATE               #
#======================================================#

/*--- The solution's parts stop being islands (2026-07-23)

stzAppTopology gives each part a ROLE over a named DATASET -- but those
datasets are STATIC in-memory lists. An order "created" on the phone
never reaches the admin's dashboard: each part reads its own frozen
copy of the model. The emulator can only ever render a rehearsal.

stzAppBackend closes that gap. It is the solution's LIVE backend: it
owns the shared state, serves it over a REAL running stzAppServer, and
lets every part read and write it over REAL HTTP. What one part writes,
another part sees -- because there is now exactly one copy of the state
and it lives outside them both.

	oB = new stzAppBackend("restolean", oTopology)
	oB.Start(0)                                     # ephemeral port

	oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
	? oB.Dashboard(:admin)[2]                       # the total INCLUDES it

	oB.Stop()

WHY SQLITE IS THE SUBSTRATE (the load-bearing design choice). Ring copies
objects on `=`, so shared state held in a Ring attribute fragments into
private copies -- the trap that killed the stzLog object sink and forced
stzSecretStore's by-reference reveal. A stzDatabase is immune: its sqlite
connection is an ENGINE HANDLE, so a copied wrapper still addresses the
SAME database. Putting the live state in sqlite means the copy trap
cannot fragment it, no matter how many parts, servers, or handlers hold a
wrapper. The MODEL (the topology) is copied on purpose -- it is a static
snapshot; only the STATE has to be shared.

ONE PROCESS, BOTH ENDS. A second stzReactor plays the parts' HTTP client:
SubmitTcp (non-blocking) -> ServeOne -> AwaitTcp. So a round trip is
genuinely over the loopback -- framed HTTP, the MBaaS floor, real sqlite
-- with no deadlock and no public network. Offline by construction, the
same discipline the reactor guard uses.

GOVERNED LIKE EVERY OTHER CROSSING. A cross-part WRITE is an effect, so
it obeys the library's one rule: expression is free, admission is
governed. Bind an actor with SetActorQ and only an effectful actor may
commit -- an LLMActor can read the whole solution and write none of it.
Reads are sensing and stay open. Every crossing is recorded in Traffic(),
so who-wrote-what-across-parts is auditable the way stzSecretStore audits
reveals.

SCOPE SIGILS: attributes are @-prefixed and method temps are _x_ wrapped
(bare class-head attributes capture same-named user globals in Ring 1.27).
*/

func StzAppBackendQ(pcName, poTopology)
	return new stzAppBackend(pcName, poTopology)

class stzAppBackend from stzObject

	@cName = ""
	@oTopology = NULL      # the MODEL -- a snapshot copy, deliberately
	@oDb = NULL            # the LIVE state (engine handle: copy-proof)
	@oServer = NULL        # the running host
	@oClient = NULL        # a second reactor: the parts' HTTP client
	@bRunning = FALSE
	@nPort = 0
	@aTraffic = []         # [ [ part, verb, dataset, status ], ... ]
	@oActor = NULL
	@bGoverned = FALSE

	def init(pcName, poTopology)
		@cName = "" + pcName
		@oTopology = poTopology
		@aTraffic = []

	  #--------------------#
	 #  BACKEND LIFECYCLE  #
	#--------------------#

	# Materialise every dataset of the model as a real sqlite table (seeded
	# with the model's rows), expose each for REST CRUD, and bind the host.
	# nPortNum 0 = ephemeral. After this, the state is LIVE: it no longer
	# lives in the model, it lives in the database the parts share.
	def Start(pnPortNum)
		if @bRunning
			stzraise("stzAppBackend '" + @cName + "' is already live on port " + @nPort)
		ok
		@oDb = new stzDatabase(":memory:")
		@oServer = new stzAppServer()
		_aNames_ = @oTopology.DatasetNames()
		_n_ = len(_aNames_)
		for _i_ = 1 to _n_
			This._Materialise(_aNames_[_i_])
			@oServer.Expose(@oDb, _aNames_[_i_])
		next
		@oServer.Start(pnPortNum, "127.0.0.1")
		@nPort = @oServer.Port()
		@oClient = new stzReactor()
		@bRunning = TRUE
		return This

	def Stop()
		if NOT @bRunning
			return This
		ok
		@oServer.Stop()
		@oClient.Destroy()
		@oDb.Close()
		@oClient = NULL
		@bRunning = FALSE
		return This

	def IsLive()
		return @bRunning

	def Port()
		return @nPort

	def Name()
		return @cName

	  #-------------------------------------#
	 #  THE PARTS' VIEW OF THE LIVE STATE  #
	#-------------------------------------#

	# A part WRITES: a real HTTP POST to the running backend, which the MBaaS
	# floor turns into a sqlite INSERT. Returns TRUE on 201.
	# paFields: [ [ "dish", "Couscous" ], [ "qty", 2 ] ]
	def Create(pcPart, pcDataset, paFields)
		This._RequireLive("Create")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		if NOT This._MayCommit()
			@aTraffic + [ _p_, "POST", _ds_, 403 ]
			stzraise("stzAppBackend: part '" + _p_ + "' may not write '" + _ds_ +
			         "' -- the acting actor is not effectful (expression is free; admission is governed).")
		ok
		_cResp_ = This._Roundtrip("POST", "/api/" + _ds_, This._FormBody(paFields))
		_nSt_ = This._StatusOf(_cResp_)
		@aTraffic + [ _p_, "POST", _ds_, _nSt_ ]
		return _nSt_ = 201

	# A part READS: a real HTTP GET. Returns [ [ cell, cell ], ... ].
	def Rows(pcPart, pcDataset)
		This._RequireLive("Rows")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		_cResp_ = This._Roundtrip("GET", "/api/" + _ds_, "")
		@aTraffic + [ _p_, "GET", _ds_, This._StatusOf(_cResp_) ]
		return This._ParseRowsJson(_cResp_)

	def RowCount(pcPart, pcDataset)
		This._RequireLive("RowCount")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		_cResp_ = This._Roundtrip("GET", "/api/" + _ds_ + "/count", "")
		@aTraffic + [ _p_, "GET", _ds_ + "/count", This._StatusOf(_cResp_) ]
		return This._CountJson(_cResp_)

	# The part's dashboard, computed over LIVE rows fetched from the running
	# backend -- the SAME aggregation the static model runs (stzTable SumCol /
	# MaxColumn: the part's declared :PivotTable), but over state another part
	# may have written a moment ago. Returns [ rows, total, topDish, topRev ].
	def Dashboard(pcPart)
		This._RequireLive("Dashboard")
		_ds_ = @oTopology.DatasetNameOf(pcPart)
		if _ds_ = ""
			_ds_ = "orders"
		ok
		_aLive_ = This.Rows(pcPart, _ds_)
		# cells cross JSON as strings -- qty must be numeric for the sum.
		# ring_number(), never 0+str (that coercion is poisoned after a raise).
		_aOrders_ = []
		_n_ = len(_aLive_)
		for _i_ = 1 to _n_
			if len(_aLive_[_i_]) >= 2
				_aOrders_ + [ _aLive_[_i_][1], ring_number(_aLive_[_i_][2]) ]
			ok
		next
		return @oTopology.DashboardFromOrders(_aOrders_)

	  #---------------------------------#
	 #  GOVERNANCE + CROSS-PART AUDIT  #
	#---------------------------------#

	# Bind the acting actor: cross-part WRITES then require an effectful one
	# (an LLMActor reads the whole solution and commits none of it). Reads are
	# sensing and stay open. Unbound = ungoverned (dev).
	def SetActorQ(poActor)
		@oActor = poActor
		@bGoverned = TRUE
		return This

	def IsGoverned()
		return @bGoverned

	# [ [ part, verb, dataset, status ], ... ] -- every crossing, in order.
	def Traffic()
		return @aTraffic

	def TrafficCount()
		return len(@aTraffic)

	# the crossings a given part made
	def TrafficOf(pcPart)
		_p_ = StzLower(ring_trim("" + pcPart))
		_out_ = []
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			if @aTraffic[_i_][1] = _p_
				_out_ + @aTraffic[_i_]
			ok
		next
		return _out_

	def RefusedCrossings()
		_out_ = []
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			if @aTraffic[_i_][4] = 403
				_out_ + @aTraffic[_i_]
			ok
		next
		return _out_

	# a legible account of the live backend (a list of lines, per the plane's
	# Explain() convention).
	def Explain()
		_out_ = []
		_out_ + ("Live backend '" + @cName + "' -- " + This._StateWord() +
		         ", port " + @nPort + ", " + len(@aTraffic) + " crossing(s)")
		if @bGoverned
			_out_ + ("  governed: writes require an effectful actor")
		ok
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			_out_ + ("  #" + _i_ + " " + @aTraffic[_i_][1] + " " + @aTraffic[_i_][2] +
			         " " + @aTraffic[_i_][3] + " -> " + @aTraffic[_i_][4])
		next
		return _out_

	def Show()
		_a_ = This.Explain()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			? _a_[_i_]
		next
		return This

	  #--------------#
	 #  INTERNALS   #
	#--------------#

	def _StateWord()
		if @bRunning
			return "live"
		ok
		return "stopped"

	def _RequireLive(pcWhat)
		if NOT @bRunning
			stzraise("stzAppBackend." + pcWhat + "() needs a live backend -- Start() first.")
		ok
		return TRUE

	def _MayCommit()
		if NOT @bGoverned
			return TRUE
		ok
		if @oActor = NULL
			return TRUE
		ok
		return @oActor.IsEffectful()

	# CREATE the dataset's table, then seed it with the model's rows: the
	# state STARTS from the model and lives on independently of it.
	def _Materialise(pcDataset)
		_cols_ = @oTopology.ColumnsOf(pcDataset)
		_nC_ = len(_cols_)
		if _nC_ = 0
			return FALSE
		ok
		_cDef_ = ""
		for _i_ = 1 to _nC_
			if _i_ > 1
				_cDef_ += ", "
			ok
			_cDef_ += ("" + _cols_[_i_] + " TEXT")
		next
		@oDb.Exec("CREATE TABLE " + pcDataset + "(" + _cDef_ + ")")
		_rows_ = @oTopology.Dataset(pcDataset)
		_nR_ = len(_rows_)
		for _i_ = 1 to _nR_
			This._Insert(pcDataset, _cols_, _rows_[_i_])
		next
		return TRUE

	def _Insert(pcTable, paCols, paRow)
		_nW_ = len(paRow)
		if _nW_ > len(paCols)
			_nW_ = len(paCols)
		ok
		if _nW_ = 0
			return FALSE
		ok
		_cC_ = ""
		_cV_ = ""
		for _i_ = 1 to _nW_
			if _i_ > 1
				_cC_ += ", "
				_cV_ += ", "
			ok
			_cC_ += ("" + paCols[_i_])
			_cV_ += ("'" + StzReplace("" + paRow[_i_], "'", "''") + "'")
		next
		@oDb.Exec("INSERT INTO " + pcTable + " (" + _cC_ + ") VALUES (" + _cV_ + ")")
		return TRUE

	# [ [ k, v ], ... ] -> "k=v&k=v"
	def _FormBody(paFields)
		_c_ = ""
		_n_ = len(paFields)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += "&"
			ok
			_c_ += ("" + paFields[_i_][1] + "=" + paFields[_i_][2])
		next
		return _c_

	# ONE real HTTP round trip: submit (non-blocking) -> serve -> await.
	def _Roundtrip(pcMethod, pcPath, pcBody)
		_cCRLF_ = char(13) + char(10)
		_cReq_ = pcMethod + " " + pcPath + " HTTP/1.1" + _cCRLF_ + "Host: local" + _cCRLF_
		if pcBody != ""
			_cReq_ += ("Content-Length: " + len(pcBody) + _cCRLF_)
		ok
		_cReq_ += ("Connection: close" + _cCRLF_ + _cCRLF_ + pcBody)
		_nJob_ = @oClient.SubmitTcp("127.0.0.1", @nPort, _cReq_)
		@oServer.ServeOne(3000)
		return @oClient.AwaitTcp(_nJob_, 5000)

	# --- response parsing, SPLIT-ONLY ------------------------------------
	# These deliberately use ONLY StzSplit / StzReplace and never a positional
	# slice. StzMidToEnd / StzMid / StzLeft / StzRight feed CODEPOINT indices
	# to a BYTE-addressed engine slice, so on any multibyte payload they return
	# empty or a truncated string (verified 2026-07-23: StzLeft("cafe-kuskus"
	# with real accents, 4) = "", StzMidToEnd(arabic, 2) = ""). A dish name in
	# Arabic is an ordinary value here, so slicing is simply not usable.

	# "HTTP/1.1 201 Created" -> 201
	def _StatusOf(pcResp)
		_aLines_ = StzSplit(pcResp, char(13) + char(10))
		if len(_aLines_) = 0
			return 0
		ok
		_aParts_ = StzSplit(_aLines_[1], " ")
		if len(_aParts_) < 2
			return 0
		ok
		return ring_number(ring_trim(_aParts_[2]))

	# '{"count":3}' -> 3
	def _CountJson(pcResp)
		_aA_ = StzSplit(pcResp, '"count":')
		if len(_aA_) < 2
			return 0
		ok
		_aB_ = StzSplit(_aA_[2], "}")
		if len(_aB_) = 0
			return 0
		ok
		return ring_number(ring_trim(_aB_[1]))

	# '{"rows":[["a","b"],["c","d"]]}' -> [ [ "a", "b" ], [ "c", "d" ] ]
	# Shape-specific by design: the producer is stzAppServer._RowsJson, so the
	# grammar is known. LIMITATION (documented, not hidden): a cell containing
	# a comma or the sequence ],[ would split wrongly -- fine for the domain
	# values this carries; a general JSON parse is the upgrade path.
	def _ParseRowsJson(pcResp)
		_out_ = []
		_aA_ = StzSplit(pcResp, '"rows":[')
		if len(_aA_) < 2
			return _out_
		ok
		_aB_ = StzSplit(_aA_[2], "]}")
		if len(_aB_) = 0
			return _out_
		ok
		_cBody_ = ring_trim(_aB_[1])
		if _cBody_ = ""
			return _out_
		ok
		_aRows_ = StzSplit(_cBody_, "],[")
		_n_ = len(_aRows_)
		for _i_ = 1 to _n_
			_cRow_ = StzReplace(StzReplace(_aRows_[_i_], "[", ""), "]", "")
			_aCells_ = StzSplit(_cRow_, ",")
			_row_ = []
			_m_ = len(_aCells_)
			for _j_ = 1 to _m_
				_row_ + This._Unquote(_aCells_[_j_])
			next
			_out_ + _row_
		next
		return _out_

	# '"kuskus"' -> kuskus  (split on the quote: [ "", value, "" ])
	def _Unquote(pcCell)
		_c_ = ring_trim("" + pcCell)
		_a_ = StzSplit(_c_, '"')
		if len(_a_) >= 3
			_c_ = _a_[2]
		but len(_a_) = 2
			_c_ = _a_[1] + _a_[2]
		ok
		return StzReplace(_c_, '\"', '"')
