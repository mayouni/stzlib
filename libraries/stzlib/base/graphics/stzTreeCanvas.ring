#---------------------------------------------------------------------------#
#  STZTREECANVAS -- a HIERARCHY, laid out and drawn. No external binary.    #
#---------------------------------------------------------------------------#
#
#     oC = StzTreeCanvasQ([
#             [ "ceo",  "Chief Executive", "" ],
#             [ "cto",  "CTO",             "ceo" ],
#             [ "cfo",  "CFO",             "ceo" ],
#             [ "dev",  "Engineering",     "cto" ]
#          ], [ :Font = oFont ])
#     oC.ToPNG("org.png")   oC.ToSVG()
#
# This is a TREE canvas, not an org-chart canvas -- org charts are its
# first tenant, the way glyphs were the texture atlas's. Any parent/child
# structure (a file tree, a taxonomy, a decision tree) is the same shape.
#
# WHY IT EXISTS: the diagram family reaches SVG by shelling out to an
# external dot.exe. Graph LAYOUT is a deep specialty and stays there --
# but a TREE does not need it. Laying a hierarchy out is a page of
# arithmetic, and doing it here means an org chart needs no external
# binary at all, and gains the PNG tier that rasterizing dot's SVG could
# never have given us (this plane has no SVG parser).
#
# The layout is the classic tidy-tree pass, done ITERATIVELY: leaves take
# consecutive slots left to right, and every parent centres over its
# children. Iterative on purpose -- a recursive version would be shorter
# and would put a caller's own deep hierarchy at the mercy of the
# interpreter's stack.
#
# Nodes: [ id, label, parentId ] -- a parentId that is "" (or names
# nothing) makes a root, and several roots simply stand side by side.

func StzTreeCanvasQ(paNodes, paOptions)
	return _StzTreeRender(paNodes, paOptions)

func _StzTreeRender(paNodes, paOptions)
	if NOT isList(paNodes) or len(paNodes) = 0
		StzRaise("stzTreeCanvas: there is no hierarchy to draw.")
	ok
	_nN_ = len(paNodes)

	_oFont_  = _StzPlotOpt(paOptions, "font", "")
	_nNodeW_ = _StzPlotOpt(paOptions, "nodewidth", 168)
	_nNodeH_ = _StzPlotOpt(paOptions, "nodeheight", 54)
	_nHGap_  = _StzPlotOpt(paOptions, "hgap", 26)
	_nVGap_  = _StzPlotOpt(paOptions, "vgap", 52)
	_nMarg_  = _StzPlotOpt(paOptions, "margin", 40)
	_cBg_    = _StzPlotOpt(paOptions, "background", "#0e1016")
	_cNode_  = _StzPlotOpt(paOptions, "nodecolor", "#243050")
	_cEdge_  = _StzPlotOpt(paOptions, "nodeborder", "#5a9ee6")
	_cLine_  = _StzPlotOpt(paOptions, "linecolor", "#5c6880")
	_cText_  = _StzPlotOpt(paOptions, "textcolor", "#e6ebf5")
	_cTitle_ = _StzPlotOpt(paOptions, "title", "")
	_nFontSz_= _StzPlotOpt(paOptions, "fontsize", 15)

	# --- index the ids, then the parent of each node
	_aIds_ = []
	_aLabels_ = []
	for _i_ = 1 to _nN_
		_aIds_ + ("" + paNodes[_i_][1])
		if len(paNodes[_i_]) >= 2 and paNodes[_i_][2] != "" and ("" + paNodes[_i_][2]) != ""
			_aLabels_ + ("" + paNodes[_i_][2])
		else
			_aLabels_ + ("" + paNodes[_i_][1])
		ok
	next

	_aParent_ = []
	_aRoots_ = []
	for _i_ = 1 to _nN_
		_nP_ = 0
		if len(paNodes[_i_]) >= 3 and paNodes[_i_][3] != ""
			_cP_ = "" + paNodes[_i_][3]
			if _cP_ != ""
				for _j_ = 1 to _nN_
					if _aIds_[_j_] = _cP_ and _j_ != _i_
						_nP_ = _j_
						exit
					ok
				next
			ok
		ok
		_aParent_ + _nP_
		if _nP_ = 0
			_aRoots_ + _i_
		ok
	next
	if len(_aRoots_) = 0
		StzRaise("stzTreeCanvas: every node names a parent -- that is a " +
			"cycle, not a tree.")
	ok

	# --- children, in the order the nodes were given
	_aKids_ = []
	for _i_ = 1 to _nN_
		_aKids_ + []
	next
	for _i_ = 1 to _nN_
		if _aParent_[_i_] > 0
			_aKids_[_aParent_[_i_]] + _i_
		ok
	next

	# --- pre-order, left to right, without recursion
	_aOrder_ = []
	_aStack_ = []
	for _i_ = len(_aRoots_) to 1 step -1
		_aStack_ + _aRoots_[_i_]
	next
	while len(_aStack_) > 0
		_n_ = _aStack_[len(_aStack_)]
		del(_aStack_, len(_aStack_))
		_aOrder_ + _n_
		_aK_ = _aKids_[_n_]
		for _k_ = len(_aK_) to 1 step -1
			_aStack_ + _aK_[_k_]
		next
	end

	# --- depth, and the slot each node sits in
	_aDepth_ = []
	_aSlot_ = []
	for _i_ = 1 to _nN_
		_aDepth_ + 0
		_aSlot_ + 0
	next
	_nLeaf_ = 0
	_nOrd_ = len(_aOrder_)
	for _i_ = 1 to _nOrd_
		_n_ = _aOrder_[_i_]
		if _aParent_[_n_] > 0
			_aDepth_[_n_] = _aDepth_[_aParent_[_n_]] + 1
		ok
		if len(_aKids_[_n_]) = 0
			_aSlot_[_n_] = _nLeaf_
			_nLeaf_++
		ok
	next
	# parents centre over their children: REVERSE pre-order visits every
	# child before its parent, which is the whole reason to walk it that way
	for _i_ = _nOrd_ to 1 step -1
		_n_ = _aOrder_[_i_]
		_aK_ = _aKids_[_n_]
		if len(_aK_) > 0
			_aSlot_[_n_] = (_aSlot_[_aK_[1]] + _aSlot_[_aK_[len(_aK_)]]) / 2
		ok
	next

	# --- the canvas, sized to what the layout actually needs
	_nMaxSlot_ = 0
	_nMaxDepth_ = 0
	for _i_ = 1 to _nN_
		if _aSlot_[_i_] > _nMaxSlot_   _nMaxSlot_ = _aSlot_[_i_]  ok
		if _aDepth_[_i_] > _nMaxDepth_ _nMaxDepth_ = _aDepth_[_i_] ok
	next
	_nTop_ = _nMarg_
	if _cTitle_ != ""  _nTop_ = _nMarg_ + 46  ok
	_nW_ = _StzPlotOpt(paOptions, "width",
		_nMarg_ * 2 + _nMaxSlot_ * (_nNodeW_ + _nHGap_) + _nNodeW_)
	_nH_ = _StzPlotOpt(paOptions, "height",
		_nTop_ + _nMarg_ + _nMaxDepth_ * (_nNodeH_ + _nVGap_) + _nNodeH_)

	_oCanvas_ = new stzCanvas(_nW_, _nH_)
	_oCanvas_.SetBackground(_cBg_)
	if _cTitle_ != "" and isObject(_oFont_)
		_oCanvas_.SetFont(_oFont_, 26)
		_oCanvas_.AddTextQ(_cTitle_, _nMarg_, _nMarg_ + 22).ColorQ(_cText_)
	ok

	# --- the connectors FIRST, so boxes sit on top of them
	for _i_ = 1 to _nN_
		_nP_ = _aParent_[_i_]
		if _nP_ = 0
			loop
		ok
		_nPx_ = _nMarg_ + _aSlot_[_nP_] * (_nNodeW_ + _nHGap_) + _nNodeW_ / 2
		_nPy_ = _nTop_ + _aDepth_[_nP_] * (_nNodeH_ + _nVGap_) + _nNodeH_
		_nCx_ = _nMarg_ + _aSlot_[_i_] * (_nNodeW_ + _nHGap_) + _nNodeW_ / 2
		_nCy_ = _nTop_ + _aDepth_[_i_] * (_nNodeH_ + _nVGap_)
		_nMid_ = _nPy_ + (_nCy_ - _nPy_) / 2
		# an orthogonal elbow reads as a reporting line; a diagonal does not
		_oCanvas_.AddPolylineQ([ _nPx_, _nPy_, _nPx_, _nMid_,
			_nCx_, _nMid_, _nCx_, _nCy_ ]).StrokeQ(_cLine_, 2)
	next

	# --- the boxes and their labels
	for _i_ = 1 to _nN_
		_nX_ = _nMarg_ + _aSlot_[_i_] * (_nNodeW_ + _nHGap_)
		_nY_ = _nTop_ + _aDepth_[_i_] * (_nNodeH_ + _nVGap_)
		_oCanvas_.AddRectQ(_nX_, _nY_, _nNodeW_, _nNodeH_).
		   FillQ(_cNode_).StrokeQ(_cEdge_, 2)
		if isObject(_oFont_)
			_oCanvas_.SetFont(_oFont_, _nFontSz_)
			_cLb_ = _StzTreeFit(_aLabels_[_i_], _oFont_, _nFontSz_, _nNodeW_ - 16)
			_oCanvas_.AddTextQ(_cLb_,
				_nX_ + (_nNodeW_ - _oFont_.WidthOf(_cLb_, _nFontSz_)) / 2,
				_nY_ + _nNodeH_ / 2 + _nFontSz_ / 3).ColorQ(_cText_)
		ok
	next
	return _oCanvas_

# Shorten a label until it fits its box, with an ellipsis to say so. A
# label that silently overflows its box is a chart that lies about what
# it contains.
func _StzTreeFit(pcLabel, poFont, pnSize, pnMaxW)
	_c_ = "" + pcLabel
	if poFont.WidthOf(_c_, pnSize) <= pnMaxW
		return _c_
	ok
	while len(_c_) > 1
		_c_ = left(_c_, len(_c_) - 1)
		if poFont.WidthOf(_c_ + "...", pnSize) <= pnMaxW
			return _c_ + "..."
		ok
	end
	return _c_
