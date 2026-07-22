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
# Attach it with oDelivery.RunsAppQ(oApp); the emulator reads it via oDelivery.App().

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSolutionAppQ(pcName)
	return new stzSolutionApp(pcName)


  #=================#
 #  STZSOLUTIONAPP #
#=================#

class stzSolutionApp from stzObject

	@cName = ""
	@aDatasets = []    # [ [ name, [ rows ] ], ... ]  -- rows are lists (real domain data)
	@aRoles = []       # [ [ partName, role, datasetName ], ... ]

	def init(pcName)
		@cName = "" + pcName

	  #-- define the model (Q-fluent) -------------------------------------

	# a named dataset -- the solution's real domain data. A menu dataset is
	# [ [ name, desc, price ], ... ]; an orders dataset is [ [ dish, qty ], ... ].
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

	  #-- reads -----------------------------------------------------------

	def Name()
		return @cName

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
		_orders_ = This.DatasetOf(pcPart)
		_menu_ = This.Dataset("menu")
		_rows_ = []
		_dishes_ = []
		_revs_ = []
		_n_ = len(_orders_)
		for _i_ = 1 to _n_
			_dish_ = _orders_[_i_][1]
			_qty_ = _orders_[_i_][2]
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
