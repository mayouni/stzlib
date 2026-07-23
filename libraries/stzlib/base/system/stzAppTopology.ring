#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSOLUTIONAPP            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The APPLICATION MODEL of a solution -- what each part actually DOES, as data,
# not hardcoded HTML. A solution holds named DATASETS (its real domain data --
# the menu, the order history) and gives each PART a ROLE over them:
#
#   * "menu"      -- an orderable list a guest-facing app shows (the menu);
#   * "dashboard" -- a manager view whose numbers are COMPUTED by the engine
#                    (revenue by dish, total, top seller -- a real aggregation,
#                    the part's declared :PivotTable capability running for real);
#   * "api"       -- endpoints a backend serves over the data;
#   * "device"    -- a firmware view (pins/sensors).
#
# One model, defined once, drives BOTH the emulator (each part renders ITS app,
# not a shared placeholder) and -- next -- the real deployed app. The dashboard
# is the load-bearing proof: its figures come from stzTable.SumCol / MaxColumn
# over the real orders, so the "app logic" is genuine compute, not a fake number.
#
# Attach it with oDelivery.SetAppTopology(oApp) -- SetAppTopologyQ when chaining;
# the emulator reads it back via oDelivery.AppTopology().

  #=============#
 #  FUNCTIONS  #
#=============#

func StzAppTopologyQ(pcName)
	return new stzAppTopology(pcName)


  #=================#
 #  STZSOLUTIONAPP #
#=================#

class stzAppTopology from stzObject

	@cName = ""
	@aDatasets = []    # [ [ name, [ rows ] ], ... ]  -- rows are lists (real domain data)
	@aRoles = []       # [ [ partName, role, datasetName ], ... ]
	@aDevices = []     # [ [ partName, [ pins ], [ rule ] ], ... ]  -- firmware parts
	@aColumns = []     # [ [ datasetName, [ colNames ] ], ... ]  -- the LIVE backend's schema

	def init(pcName)
		@cName = "" + pcName

	  #-- define the model (Q-fluent) -------------------------------------

	# a named dataset -- the solution's real domain data. A menu dataset is
	# [ [ name, desc, price ], ... ]; an orders dataset is [ [ dish, qty ], ... ].
	def AddDataset(pcName, paRows)
		This.AddDatasetQ(pcName, paRows)

	def AddDatasetQ(pcName, paRows)
		_nm_ = StzLower(ring_trim("" + pcName))
		_i_ = This._DatasetIndex(_nm_)
		if _i_ > 0
			@aDatasets[_i_][2] = paRows
		else
			@aDatasets + [ _nm_, paRows ]
		ok
		return This

	# give a part an app ROLE + the dataset it works over.
	def SetPartRole(pcPart, pcRole, pcDataset)
		This.SetPartRoleQ(pcPart, pcRole, pcDataset)

	def SetPartRoleQ(pcPart, pcRole, pcDataset)
		_p_ = StzLower(ring_trim("" + pcPart))
		_i_ = This._RoleIndex(_p_)
		_row_ = [ _p_, StzLower(ring_trim("" + pcRole)), StzLower(ring_trim("" + pcDataset)) ]
		if _i_ > 0
			@aRoles[_i_] = _row_
		else
			@aRoles + _row_
		ok
		return This

	# the dataset's COLUMN NAMES. Only the live backend needs them (it
	# materialises each dataset as a real sqlite table, and a part POSTs
	# "dish=Couscous&qty=2" -- form keys ARE column names). Optional: when
	# unset, ColumnsOf() derives c1..cN, so the static model is unaffected.
	def SetDatasetColumns(pcName, paCols)
		This.SetDatasetColumnsQ(pcName, paCols)

	def SetDatasetColumnsQ(pcName, paCols)
		_nm_ = StzLower(ring_trim("" + pcName))
		_i_ = This._ColumnsIndex(_nm_)
		if _i_ > 0
			@aColumns[_i_][2] = paCols
		else
			@aColumns + [ _nm_, paCols ]
		ok
		return This

	  #-- reads -----------------------------------------------------------

	def Name()
		return @cName

	# every dataset's name, in declaration order (the live backend
	# materialises one table per entry).
	def DatasetNames()
		_out_ = []
		_n_ = len(@aDatasets)
		for _i_ = 1 to _n_
			_out_ + @aDatasets[_i_][1]
		next
		return _out_

	# every part that has been given a role, in declaration order (the remote
	# backend serialises these so a hosting PROCESS can rebuild the model).
	def PartNames()
		_out_ = []
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			_out_ + @aRoles[_i_][1]
		next
		return _out_

	# declared column names, or derived c1..cN from the dataset's widest row.
	def ColumnsOf(pcName)
		_nm_ = StzLower(ring_trim("" + pcName))
		_i_ = This._ColumnsIndex(_nm_)
		if _i_ > 0
			return @aColumns[_i_][2]
		ok
		_rows_ = This.Dataset(_nm_)
		_w_ = 0
		_n_ = len(_rows_)
		for _j_ = 1 to _n_
			if len(_rows_[_j_]) > _w_
				_w_ = len(_rows_[_j_])
			ok
		next
		_out_ = []
		for _j_ = 1 to _w_
			_out_ + ("c" + _j_)
		next
		return _out_

	# the aggregation over ANY orders list -- public so the LIVE backend can
	# run the very same computation over rows fetched from the running server
	# (the admin part's :PivotTable, over live data instead of a frozen list).
	def DashboardFromOrders(paOrders)
		return This._DashboardFromOrders(paOrders)

	def Dataset(pcName)
		_i_ = This._DatasetIndex(StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return []
		ok
		return @aDatasets[_i_][2]

	def HasRoleFor(pcPart)
		return This._RoleIndex(StzLower(ring_trim("" + pcPart))) > 0

	def RoleOf(pcPart)
		_i_ = This._RoleIndex(StzLower(ring_trim("" + pcPart)))
		if _i_ = 0
			return ""
		ok
		return @aRoles[_i_][2]   # [ part, ROLE, dataset ]

	# the NAME of the part's dataset (DatasetOf returns its rows). The live
	# backend needs the name to address the running server's REST resource.
	def DatasetNameOf(pcPart)
		_i_ = This._RoleIndex(StzLower(ring_trim("" + pcPart)))
		if _i_ = 0
			return ""
		ok
		return @aRoles[_i_][3]

	def DatasetOf(pcPart)
		_i_ = This._RoleIndex(StzLower(ring_trim("" + pcPart)))
		if _i_ = 0
			return []
		ok
		return This.Dataset(@aRoles[_i_][3])

	# the menu a "menu"-role part shows: [ [ name, desc, price ], ... ].
	def MenuOf(pcPart)
		return This.DatasetOf(pcPart)

	# the REAL dashboard for a "dashboard"-role part: join the part's orders
	# dataset ([ dish, qty ]) with the "menu" dataset (for prices), compute
	# revenue per dish, and aggregate via the engine (stzTable). Returns
	# [ [ [dish, qty, revenue], ... ], total, topDish, topRevenue ].
	def DashboardOf(pcPart)
		return This._DashboardFromOrders(This.DatasetOf(pcPart))

	# the aggregation itself, over any orders dataset ([ dish, qty ]) -- so both a
	# dashboard PART and an api /stats endpoint compute the same figures.
	def _DashboardFromOrders(paOrders)
		_menu_ = This.Dataset("menu")
		_rows_ = []
		_dishes_ = []
		_revs_ = []
		_n_ = len(paOrders)
		for _i_ = 1 to _n_
			_dish_ = paOrders[_i_][1]
			_qty_ = paOrders[_i_][2]
			_price_ = This._PriceOf(_dish_, _menu_)
			_rev_ = _qty_ * _price_
			_rows_ + [ _dish_, _qty_, _rev_ ]
			_dishes_ + _dish_
			_revs_ + _rev_
		next
		if len(_dishes_) = 0
			return [ [], 0, "", 0 ]
		ok
		# the engine does the aggregation -- the admin's :PivotTable, for real.
		_oT_ = new stzTable([ [ "dish", _dishes_ ], [ "revenue", _revs_ ] ])
		_total_ = _oT_.SumCol("revenue")
		_topRev_ = _oT_.MaxColumn("revenue")
		_top_ = This._DishWithRevenue(_topRev_, _rows_)
		return [ _rows_, _total_, _top_, _topRev_ ]

	  #-- the API a backend part serves (real endpoints over the data) ----

	# the endpoints an "api"-role part exposes: GET /<dataset> for each dataset,
	# plus GET /stats (the engine aggregation) when there are orders to total.
	# Each entry: [ req, count, statsOrEmpty ] -- count = -1 marks the stats one.
	def ApiEndpointsFor(pcPart)
		_eps_ = []
		_nd_ = len(@aDatasets)
		for _i_ = 1 to _nd_
			_eps_ + [ "GET /" + @aDatasets[_i_][1], len(@aDatasets[_i_][2]), [] ]
		next
		if This._DatasetIndex("orders") > 0 and This._DatasetIndex("menu") > 0
			_st_ = This._DashboardFromOrders(This.Dataset("orders"))
			_eps_ + [ "GET /stats", -1, [ _st_[2], _st_[3], _st_[4] ] ]  # total, top, topRev
		ok
		return _eps_

	  #-- a firmware part's DEVICE model (pins + an automation rule) -------

	# pins: [ [ pinNo, label, role, value ], ... ]  role = "sensor" | "actuator".
	def AddDevice(pcPart, paPins)
		This.AddDeviceQ(pcPart, paPins)

	def AddDeviceQ(pcPart, paPins)
		_p_ = StzLower(ring_trim("" + pcPart))
		_i_ = This._DeviceIndex(_p_)
		if _i_ > 0
			@aDevices[_i_][2] = paPins
		else
			@aDevices + [ _p_, paPins, [] ]
		ok
		return This

	# an automation rule: actuator ON when sensor < threshold (the real firmware
	# logic the emulator applies -- not a blind toggle).
	def SetRule(pcPart, pcSensor, pnThreshold, pcActuator)
		This.SetRuleQ(pcPart, pcSensor, pnThreshold, pcActuator)

	def SetRuleQ(pcPart, pcSensor, pnThreshold, pcActuator)
		_p_ = StzLower(ring_trim("" + pcPart))
		_i_ = This._DeviceIndex(_p_)
		if _i_ = 0
			@aDevices + [ _p_, [], [] ]
			_i_ = len(@aDevices)
		ok
		@aDevices[_i_][3] = [ "" + pcSensor, pnThreshold, "" + pcActuator ]
		return This

	def HasDevice(pcPart)
		return This._DeviceIndex(StzLower(ring_trim("" + pcPart))) > 0

	# [ pins, rule ] for a device part; [ [], [] ] if none.
	def DeviceOf(pcPart)
		_i_ = This._DeviceIndex(StzLower(ring_trim("" + pcPart)))
		if _i_ = 0
			return [ [], [] ]
		ok
		return [ @aDevices[_i_][2], @aDevices[_i_][3] ]

	  #-- internals -------------------------------------------------------

	def _DatasetIndex(pcName)
		_n_ = len(@aDatasets)
		for _i_ = 1 to _n_
			if @aDatasets[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def _RoleIndex(pcPart)
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			if @aRoles[_i_][1] = pcPart
				return _i_
			ok
		next
		return 0

	def _ColumnsIndex(pcName)
		_n_ = len(@aColumns)
		for _i_ = 1 to _n_
			if @aColumns[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def _DeviceIndex(pcPart)
		_n_ = len(@aDevices)
		for _i_ = 1 to _n_
			if @aDevices[_i_][1] = pcPart
				return _i_
			ok
		next
		return 0

	def _PriceOf(pcDish, paMenu)
		_n_ = len(paMenu)
		for _i_ = 1 to _n_
			if paMenu[_i_][1] = pcDish
				return paMenu[_i_][3]
			ok
		next
		return 0

	def _DishWithRevenue(pnRev, paRows)
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			if paRows[_i_][3] = pnRev
				return paRows[_i_][1]
			ok
		next
		return ""
