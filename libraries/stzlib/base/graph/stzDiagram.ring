#--------------------------------------------------#
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph  #
#  Workflows, org charts, semantic diagrams        #
#--------------------------------------------------#
#  Part of GRAPH MODULE in StzLib (V0.9)           #
#  By: Mansour Ayouni (kalidianow@gamil.com)       #
#==================================================#

# Edge styles
$acEdgeStyles = [
	:Normal = "solid",
	:Conditional = "dashed",
	:ErrorFlow = "dotted",
	:MessageFlow = "bold"
]

$cDefaultEdgeStyle = "normal"
$cDefaultEdgeColor = "black"
#TODO Add $cDefaultEdgeSpline = "spline" or "ortho" ...

$cDefaultOrgChartEdgeStyle = "normal"
$cDefaultOrgChartEdgeSpline = "spline"
$cDefaultOrgChartEdgeColor = "gray"

# LAYOUT
# THE TWO HORIZONTAL DIRECTIONS USED TO HAVE ONE SPELLING EACH while the
# vertical pair had seven, and the asymmetry was not a decision -- it was an
# oversight that silently ignored callers. `SetLayout(:LeftToRight)` stored
# a string matching nothing, `_NativeRankDir` fell through to its "TB"
# default, and the picture came out top-down with no complaint. Every
# caller in this library that asked for a horizontal layout -- :LeftRight,
# :LeftToRight, :RightLeft, "leftright" -- was quietly getting the opposite
# axis, and a rendered diagram cannot be told from a correct one unless you
# know which way you asked for.
$acLayouts = [
	:TopDown = [ "tb", "td", "topbottom", "ud", "updown", "ub", "upbottom",
	             "topdown", "toptobottom", "vertical" ],
	:BottomUp = [ "bt", "dt", "bottomtop", "du", "downup", "bu", "bottomup",
	              "bottomtotop" ],
	:LeftRight = [ "lr", "leftright", "lefttoright", "horizontal" ],
	:RightLeft = [ "rl", "rightleft", "righttoleft" ]
]

# The graphviz ENGINE names. A different axis from rank direction entirely,
# but they arrive through the same setter and have always been accepted, so
# they are named here rather than left to be refused by a check that cannot
# tell them from a typo.
$acLayoutEngines = [ "dot", "neato", "fdp", "sfdp", "circo", "twopi", "osage" ]

$cDefaultLayout = "topdown"

# LAYOUT ENGINE OPTIONS
$acSplineTypes = ["ortho", "spline", "polyline", "curved", "line", "none"]
$cDefaultSplineType = "spline"

$anNodeSeparations = [0.3, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5]
$nDefaultNodeSep = 0.6

$anRankSeparations = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]
$nDefaultRankSep = 0.8

$acConcentrate = ["true", "false"]
$cDefaultConcentrate = "false"

# FONTS
$acFonts = [
	"helvetica",
	"arial",
	"times",
	"courier",
	"verdana",
	"georgia",
	"palatino",
	"garamond",
	"comic sans ms",
	"trebuchet ms",
	"impact"
]

$cDefaultFont = "helvetica"
$cDefaultFontSize = 12

# Theme-specific font settings
$aThemeFonts = [
	:light = [:font = "helvetica", :size = 12],
	:dark = [:font = "helvetica", :size = 12],
	:vibrant = [:font = "helvetica", :size = 12],
	:pro = [:font = "helvetica", :size = 12],
	:access = [:font = "arial", :size = 16],
	:print = [:font = "times", :size = 11],
	:gray = [:font = "helvetica", :size = 12]
]

#-- Visual focus color

$cDefaultFocusColor = "magenta+"

#  VISUAL MAPPINGS
#------------------

# Shape modifiers for properties attributes
$aShapeModifiers = [
	:critical = [:penwidth = 3, :style = "bold,filled"],
	:optional = [:style = "dashed,filled"],
	:automated = [:style = "rounded,filled", :peripheries = 2],
	:manual = [:style = "rounded,filled"],
	:deprecated = [:style = "dotted,filled", :fontcolor = "gray"]
]

# Edge decorations for relationship types
$aEdgeDecorations = [
	:requires = [:arrowhead = "normal", :style = "bold"],
	:optional = [:arrowhead = "empty", :style = "dashed"],
	:async = [:arrowhead = "normal", :style = "dashed"],
	:sync = [:arrowhead = "normal", :style = "solid"],
	:triggers = [:arrowhead = "vee", :style = "bold"],
	:data_flow = [:arrowhead = "normal", :style = "solid"]
]

# Pen and arrow styles
$acNodePenStyles = ["solid", "dashed", "dotted", "bold", "invis"]
$acEdgePenStyles = ["solid", "dashed", "dotted", "bold", "invis"]

$acArrowStyles = [
	"normal", "vee", "diamond", "dot", "inv", "curve", 
	"box", "crow", "tee", "none"
]

$acDotShapes = [
	"box", "ellipse", "circle", "diamond", "parallelogram", 
	"hexagon", "octagon", "cylinder", "rect", "square", 
	"doublecircle", "tripleoctagon", "invtriangle", "house",
	"pentagon", "septagon", "trapezium", "invtrapezium",
	"triangle", "egg", "tab", "folder", "component", "note"
]

$aPolygonShapes = [
	"hexagon", "octagon", "parallelogram", "pentagon", 
	"septagon", "trapezium", "invtrapezium", "triangle",
	"house", "invtriangle", "diamond"
]


#--------------------#
#  GLOBAL FUNCTIONS  #
#--------------------#

func IsStzDiagram(pObj)
	if isObject(pObj)
		_cClass_ = StzLower(classname(pObj))
		if _cClass_ = "stzdiagram"
			return 1
		ok
	ok
	return 0

# STYLE RESOLUTION

func StzResolveEdgeStyle(pStyle)
	_cStyleKey_ = StzLower("" + pStyle)

	if HasKey($acEdgeStyles, _cStyleKey_)
		return $acEdgeStyles[_cStyleKey_]
	ok

	if StzFindFirst(_cStyleKey_, ["solid", "dashed", "dotted", "bold"])
		return _cStyleKey_
	ok

	return $cDefaultEdgeStyle

	func ResolveEdgeStyle(pStyle)
		return StzResolveEdgeStyle(pStyle)

func StzResolveNodeType(pcType)
	_cTypeKey_ = StzLower("" + pcType)

	if StzFindFirst(_cTypeKey_, $acDotShapes) > 0
		return _cTypeKey_
	ok

	if StzFindFirst(_cTypeKey_, $acNodeTypes)
		return _cTypeKey_
	ok

	_aVisualMap_ = [
		:box = "process",
		:diamond = "decision",
		:ellipse = "start",
		:circle = "state",
		:cylinder = "storage",
		:doublecircle = "endpoint"
	]

	if HasKey(_aVisualMap_, _cTypeKey_)
		return _aVisualMap_[_cTypeKey_]
	ok

	_aShapeMap_ = [
		:square = "box",
		:rect = "box",
		:egg = "ellipse",
		:tab = "box",
		:folder = "box",
		:component = "box",
		:note = "box",
		:ellpise = "ellipse"
	]

	if HasKey(_aShapeMap_, _cTypeKey_)
		return _aShapeMap_[_cTypeKey_]
	ok

	return $cDefaultNodeType

	func ResolveNodeType(pcType)
		return StzResolveNodeType(pcType)

func StzDefaultNodeType()
	return $cDefaultNodeType

	func DefaultNodeType()
		return StzDefaultNodeType()

func StzNodeTypes()
	return $acNodeTypes

	func NodeTypes()
		return StzNodeTypes()

func StzIsValidNodeType(pcType)
	return StzFindFirst(pcType, $acNodeTypes) > 0

	func IsValidNodeType(pcType)
		return StzIsValidNodeType(pcType)

func StzIsValidEdgeStyle(pcStyle)
	return HasKey($acEdgeStyles, pcStyle)

	func IsValidEdgeStyle(pcStyle)
		return StzIsValidEdgeStyle(pcStyle)

func StzEdgeStyles()
	return $acEdgeStyles

	func EdgeStyles()
		return StzEdgeStyles()

func StzDefaultEdgeStyle()
	return $cDefaultEdgeStyle

	func DefaultEdgeStyle()
		return StzDefaultEdgeStyle()

func StzStyleForEdgeType(pcType)
	if HasKey($acEdgeStyles, pcType)
		return $acEdgeStyles[pcType]
	ok
	return $cDefaultEdgeStyle

	func StyleForEdgeType(pcType)
		return StzStyleForEdgeType(pcType)

#--------------------------------------------------#
#  stzDiagram Class - Main Diagram Implementation  #
#--------------------------------------------------#

# THE SEMANTIC VOCABULARY TRANSLATED TO THE GEOMETRIC ONE, in one place.
#
# `start`, `process`, `decision`, `storage`, `endpoint` say what a node
# MEANS; `ellipse`, `box`, `diamond`, `cylinder`, `doublecircle` say what
# it looks like. Every renderer needs the mapping between them, and it
# lived as a private method on the DOT exporter -- so ToDot drew a
# decision as a diamond and the native tier, unable to reach it, drew a
# rounded box for every type there is. Two renderers of one model
# disagreeing, with the right answer already written down.
#
# A translation used by more than one face is not a detail of either.
func StzNodeShapeForType(pcType)
	_t_ = StzLower(StzTrim("" + pcType))
	if _t_ = ""  return ""  ok
	# an explicit geometric name passes straight through
	if StzIsNodeShape(_t_)  return _t_  ok
	switch _t_
	on "process"   return "box"
	on "task"      return "box"
	on "data"      return "box"
	on "decision"  return "diamond"
	on "start"     return "ellipse"
	on "event"     return "ellipse"
	on "end"       return "doublecircle"
	on "endpoint"  return "doublecircle"
	on "state"     return "circle"
	on "storage"   return "cylinder"
	on "database"  return "cylinder"
	off
	return ""

class stzDiagram from stzGraph

	@cTheme = $cDefaultColorTheme
	@cLayout = $cDefaultLayout
	@aClusters = []
	@nEdgeCornerRad = 10
	@nLastEdgeW = 2
	@cLabelPlacement = "beside"
	@bRoundElbows = 1

	# THE NOTATION -- which domain's declaration this diagram is judged
	# and drawn under (DN0). Every diagram has one, the way it has a
	# theme; the default is the generic diagram expressed AS a profile,
	# and its answers are byte-identical to the pre-profile renderer --
	# the guard holds that as a live assertion.
	@cNotation = "default"
	@oNotation = NULL
	@cNotationLayout = ""
	@cSelfLoopId = ""
	# per-node drawn size: [ id, w, h ] for anything that is not a full
	# cell. A mark's geometry has to be the SAME number the drawing uses
	# and the clipping uses, or an arrow stops short of the thing it
	# points at.
	@aBoxOf = []
	# rows that already hold a return lane, refilled per render
	@aSameRowLanes = []
	@aDrawXY = []
	@aLaneKept = []
	@aStubOf = []
	# how far apart two return lanes stand -- a clearance plus whatever
	# is written beside them
	@nLanePitch = 24
	# the font this render is using, so geometry that must reserve room
	# for a word can ask how wide the word is
	@oLastFont = NULL
	@nLastFsz = 13
	@nModeCols = 1
	@nModeRows = 1
	@nModeRegionRows = 0
	@aModeRegionRowsAt = []
	@aModeOfId = []

	# The cluster rectangles OF THE CURRENT RENDER, with their member ids:
	# [ [ x, y, w, h, [ ids... ] ], ... ]. Render-scoped state, refilled by
	# every ToCanvasXT -- it exists because the edge drawers need to know
	# what a channel would traverse, and threading it through five
	# signatures buys nothing over reading it off the object that owns
	# both the clusters and the render.
	@aRenderClusRects = []

	# The NODE rectangles of the current render, [ [ x, y, w, h, id ], ... ].
	# A channel must clear these as much as it clears a cluster frame -- a
	# line grazing the underside of a row is the same illegibility as one
	# grazing a frame, and the row is what it was pushed into when only
	# frames were known.
	@aRenderNodeRects = []

	# Channels already granted in this render: [ spanLo, spanHi, srcId, y ].
	# THE VISUAL CONTRACT, I2: two edges may run collinear only where they
	# share the endpoint on that side of the ink -- a trunk out of one
	# source is one line honestly; two edges that merely both go somewhere
	# are two lines, a clearance apart, or the reader concludes their
	# sources share something the graph never said.
	@aChanUsed = []

	# Rank-axis segments of every ortho edge, collected on a DRY first
	# pass: [ pos, lo, hi, edgeKey ]. THE WIRE HOP needs to know every
	# line it might cross BEFORE anything is drawn -- an edge drawn early
	# cannot hop a line that does not exist yet, which is why electric
	# CAD does this in two passes too.
	@aVertSegs = []
	@nDrawPass = 2

	# The drawn geometry of every ortho edge, keyed "from>to" -- captured
	# on the dry pass so the label placer anchors on the path the edge
	# ACTUALLY takes, never on a pre-channel fiction.
	@aEdgePaths = []

	# Where the labels actually landed: [ text, x, y, w, h, edgeKey ] per
	# label. The SVG backend emits no text, so the placement facts are
	# the only instrument a guard can put on the label law.
	@aRenderLabels = []
	# node labels of the current render: [ id, x, y, w, h, bOutside ] --
	# bOutside says the label sits BELOW its glyph (non-rectangular cells)
	@aRenderNodeLabels = []

	# THE INTERACTION'S STATE, and only its state: idle, dragging,
	# linking or labelling, plus what the gesture is about and what to
	# restore if it is abandoned. See OnPress().
	@cUiState = :Idle
	@cUiSubject = ""
	@aUiWas = []
	@aUiAt = []
	@bUiDown = FALSE
	@bUiLinking = FALSE
	@aUiRewire = []

	# The linear fit between the layout's coordinate and the canvas's
	# pixels, as [ offset, scale ] -- see SlotAtPixel().
	@aSlotMap = []

	# THE SESSION'S MEMORY: every edit and its inverse, so an editor can
	# be explored rather than merely operated. Nothing here mutates the
	# model directly -- see Do().
	@aUndo = []
	@aRedo = []

	# WHERE THE AUTHOR HAS PLACED A CELL BY HAND: [ id, slotX ]. A pin
	# is a position the layout may not argue with -- see Pin().
	@aPins = []

	# WHAT THE PICTURE CAN BE ASKED ABOUT: tag -> [ kind, a, b ]. The
	# display list is tagged as it is drawn, so a point in the picture
	# answers with a NODE or an EDGE rather than with a shape -- the
	# batch pipeline's one-way street (model -> layout -> paint) opened
	# so a reader can point back up it.
	@aRenderPicks = []
	@oLastCanvas = NULL

	# The last render's paper size, so the label placer can refuse a spot
	# that hangs off it.
	@nRenderW = 0
	@nRenderH = 0

	# The layered crossing count of the order the last render drew --
	# the graph tier's structure fact. Only the crossings the structure
	# REQUIRES survive the engine sweep, and each survivor earns a wire
	# hop; this number is what a guard compares the picture against.
	# -1 = no natural hierarchical render has run.
	@nRenderCrossings = -1
	@aoAnnotations = []
	@aoTemplates = []

	@cEdgeColor = $cDefaultEdgeColor
	@cNodeColor = $cDefaultNodeColor
	@cNodeStrokeColor = $cDefaultNodeStrokeColor
	@cClusterColor = $cDefaultClusterColor

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = $cDefaultEdgeStyle

	@cFont = $cDefaultFont
	@nFontSize = $cDefaultFontSize
	@bFontCustomized = 0

	@apropertiesKeys = []

	# Validation state
	@cLastValidator = ""
	@aLastValidationResult = []
	
	# Pen attributes

	@nNodePenWidth = 1
	@nEdgePenWidth = 1

	# Pen styles : solid, dashed, dotted, bold, invis
	# Can be combine: "bold,dashed" or "dashed,rounded" for nodes.

	@cNodePenStyle = "solid"
	@cEdgePenStyle = "solid"

	# Arrow styles: normal, vee, diamond, dot, inv, curve, box, crow, tee, none.
	@cArrowHead = "normal"
	@cArrowTail = "none"

	@cSplineType = $cDefaultSplineType
	@nNodeSep = $nDefaultNodeSep
	@nRankSep = $nDefaultRankSep
	@bConcentrate = 0

	@cTitle = ""
	@cSubtitle = ""

	@aLoadedStyles = []

	@cFocusColor = $cDefaultFocusColor
	@cOutputFormat = $cDefaultDiagramOutputFormat

	@aoVisualRules = []
	@aNodesAffectedByRules = []
	@aEdgesAffectedByRules = []
	@aNodeRulesEffects = []    # Track visual rule effects
	@aEdgesRulesEffects = []

	@aTooltipConfig = []

	def init(pcName)

		super.init(pcName)

		@cEdgeColor = ResolveColor($cDefaultEdgeColor)
		@cFocusColor = ResolveColor($cDefaultFocusColor)
		@cSplineType = $cDefaultSplineType

	def Name()
		return super.Id()

	def SetTheme(pTheme)
	    _cThemeKey_ = StzLower(pTheme)
	    
	    if HasKey($aPalette, _cThemeKey_)
	        @cTheme = _cThemeKey_
	        
	        # Only apply theme fonts if not customized by user
	        if NOT @bFontCustomized and HasKey($aThemeFonts, _cThemeKey_)
	            @cFont = $aThemeFonts[_cThemeKey_][:font]
	            @nFontSize = $aThemeFonts[_cThemeKey_][:size]
	        ok
	    ok
	
	#-- THE NOTATION (DN0) ------------------------------------------------

	# Takes a registered name or a profile object. A name the registry
	# does not know resolves to the default -- a diagram always has a
	# notation, the way it always has a theme.
	def SetNotation(pNotation)
		if isObject(pNotation)
			@oNotation = pNotation
			@cNotation = StzLower("" + pNotation.Name_())
		else
			@cNotation = StzLower(ring_trim("" + pNotation))
			@oNotation = NULL
		ok
		# a notation may amend the grammar; "" amends nothing
		_oN_ = This.NotationO()
		if _oN_.RankDir() != ""  This.SetLayout(_oN_.RankDir())  ok
		if _oN_.Splines() != ""  This.SetSplines(_oN_.Splines())  ok
		@cNotationLayout = "" + _oN_.LayoutMode()
		return This

		def SetNotationQ(pNotation)
			return This.SetNotation(pNotation)

	def NotationO()
		if isObject(@oNotation)  return @oNotation  ok
		return StzNotation(@cNotation)

	def Notation()
		return @cNotation

	# The model swept against its notation's rules, in the house rule
	# shape -- ready for stzRuleReport.Ingest(), which is the one CI gate.
	#
	# NOT Validate(): stzOrgChart already owns Validate() for its
	# governance rule bases, and a name that answers structure on one
	# class and content on its child is two faces disagreeing. The
	# notation's sweep is named for what it sweeps.
	# The regions a MODE layout draws: one per strongly connected component
	# holding two or more states. A single state is not a region -- a box
	# inside a box says nothing, and the picture would gain a boundary for
	# every leaf.
	#
	# Membership is computed on a throwaway canvas because the modes are a
	# property of the GRAPH, not of any render: the same machine gives the
	# same regions at every size.
	def _DeclareModeRegions()
		if This.NumberOfNodes() < 2  return This  ok
		@aModeRegionRowsAt = []
		_oMc_ = new stzGraphCanvas(This, [ :Layout = :Modes,
			:Width = 600, :Height = 400 ])
		_aM_ = _oMc_.ModeOf()
		if len(_aM_) != This.NumberOfNodes()  return This  ok
		_nK_ = _oMc_.ModeCount()
		_aNd_ = This.Nodes()
		@aModeOfId = []
		# the SHAPE of the mode picture, kept so the natural size can be
		# derived from it: the widest rank in states, and the depth in
		# modes. A picture sized from anything else would be sized from a
		# guess about a layout it did not run.
		@nModeCols = 1
		@nModeRows = _oMc_.LayerCount()
		@nModeRegionRows = 0
		@aModeOfId = []
		for _iM_ = 1 to len(_aM_)
			@aModeOfId + [ StzLower("" + _aNd_[_iM_][:id]), _aM_[_iM_] ]
		next
		_aWid_ = []
		for _r_ = 1 to max([ @nModeRows, 1 ])  _aWid_ + 0  next
		_aPos_ = _oMc_.RawPositions()
		_aRy_ = []
		for _pM_ in _oMc_.Positions()
			_bS_ = 0
			for _vR_ in _aRy_
				if fabs(_vR_ - _pM_[3]) < 2  _bS_ = 1  exit  ok
			next
			if NOT _bS_  _aRy_ + _pM_[3]  ok
		next
		for _vR_ in _aRy_
			_nAt_ = 0
			for _pM_ in _oMc_.Positions()
				if fabs(_pM_[3] - _vR_) < 2  _nAt_++  ok
			next
			if _nAt_ > @nModeCols  @nModeCols = _nAt_  ok
		next
		for _k_ = 1 to _nK_
			_aIn_ = []
			for _i_ = 1 to len(_aM_)
				if _aM_[_i_] = _k_  _aIn_ + ("" + _aNd_[_i_][:id])  ok
			next
			if len(_aIn_) < 2  loop  ok
			# how many RANKS hold a region -- three regions side by side
			# eat their chrome ONCE, not three times
			_nRw_ = 0
			for _pM2_ in _oMc_.Positions()
				if StzLower("" + _pM2_[1]) = StzLower("" + _aIn_[1])
					_nRw_ = floor(_pM2_[3])
					exit
				ok
			next
			_bNewRw_ = 1
			for _vRw_ in @aModeRegionRowsAt
				if fabs(_vRw_ - _nRw_) < 2  _bNewRw_ = 0  exit  ok
			next
			if _bNewRw_
				@aModeRegionRowsAt + _nRw_
				@nModeRegionRows++
			ok
			# UNLABELLED on purpose. The graph knows these states belong
			# together; it does not know what to CALL the grouping, and a
			# manufactured name ("Mode 2") is noise a reader must ignore.
			# An author who wants one declares the cluster themselves.
			# THE REGION WEARS THE TINTED CONTAINER STEP of its members'
			# role -- .Surface, which the OKLCH ramp already computes and
			# keeps hue-stable, so a region reads as "the same colour,
			# quieter" rather than as a second palette
			_cRf_ = This.NotationO().RegionFill()
			if _cRf_ != ""
				This.AddClusterXTT("mode" + _k_, "", _aIn_, _cRf_)
			else
				This.AddClusterXT("mode" + _k_, "", _aIn_)
			ok
		next
		return This

	# The drawn size of a node: the picture's cell, scaled by whatever
	# fraction its KIND declares. One place, so the box that is painted,
	# the border an edge clips to and the port it leaves from can never
	# be three different rectangles.
	# THE SAME ANSWER, KEYED BY POSITION. The attachment and clipping
	# helpers are handed a node's CENTRE, not its id -- they sit six
	# layers below the loop that knows both -- and threading an id
	# through six signatures to ask one question is how a rule ends up
	# with two implementations. The published rects hold the answer and
	# are filled before any edge is drawn, so a centre is enough.
	# THE COLOUR OF WHATEVER A POINT SITS ON. A label plate exists to
	# hide the line under the words, so it must be painted in the colour
	# it covers -- and inside a region that is the region's tint, not the
	# paper's white. Painted in the paper's colour it becomes a white
	# card lying on a tinted field, which is what the Principal marked:
	# "you can't write a label in a background different from the
	# underlying background". Innermost frame wins, since that is what is
	# actually visible there.
	# The point at a fraction of a PATH's own length, with the direction
	# of the leg it lands on: [ x, y, |dx|, |dy| ]. A label centred at
	# 0.5 of the journey is what a reader calls the middle of an edge;
	# 0.5 of whichever leg the placer happened to walk first is not.
	def _PointAlong(paFlat, nFrac)
		_paN_ = len(paFlat)
		if _paN_ < 4  return []  ok
		_paTot_ = 0
		for _paI_ = 1 to _paN_ - 3 step 2
			_paTot_ += sqrt(pow(paFlat[_paI_+2] - paFlat[_paI_], 2) +
				pow(paFlat[_paI_+3] - paFlat[_paI_+1], 2))
		next
		if _paTot_ <= 0  return []  ok
		_paWant_ = _paTot_ * nFrac
		_paAcc_ = 0
		for _paI_ = 1 to _paN_ - 3 step 2
			_paDx_ = paFlat[_paI_+2] - paFlat[_paI_]
			_paDy_ = paFlat[_paI_+3] - paFlat[_paI_+1]
			_paL_ = sqrt(_paDx_*_paDx_ + _paDy_*_paDy_)
			if _paL_ <= 0  loop  ok
			if _paAcc_ + _paL_ >= _paWant_ or _paI_ + 4 > _paN_
				_paT_ = (_paWant_ - _paAcc_) / _paL_
				if _paT_ < 0  _paT_ = 0  ok
				if _paT_ > 1  _paT_ = 1  ok
				return [ paFlat[_paI_] + _paDx_ * _paT_,
					paFlat[_paI_+1] + _paDy_ * _paT_,
					fabs(_paDx_), fabs(_paDy_) ]
			ok
			_paAcc_ += _paL_
		next
		return []

	def _SurfaceAt(nX, nY, cPaper)
		_cS_ = "" + cPaper
		_nBest_ = -1
		for _srR_ in @aRenderClusRects
			if nX < _srR_[1] or nX > _srR_[1] + _srR_[3]  loop  ok
			if nY < _srR_[2] or nY > _srR_[2] + _srR_[4]  loop  ok
			_nA_ = _srR_[3] * _srR_[4]
			if _nBest_ < 0 or _nA_ < _nBest_
				_nBest_ = _nA_
				_cS_ = "" + This._ClusterFillAt(_srR_)
			ok
		next
		if _cS_ = ""  _cS_ = "" + cPaper  ok
		return _cS_

	def _ClusterFillAt(aRect)
		for _cfC_ in @aClusters
			_cfB_ = []
			for _cfM_ in _cfC_[:nodes]  _cfB_ + StzLower("" + _cfM_)  next
			if len(_cfB_) != len(aRect[5])  loop  ok
			_bSame_ = 1
			for _cfI_ = 1 to len(_cfB_)
				if _cfB_[_cfI_] != aRect[5][_cfI_]  _bSame_ = 0  exit  ok
			next
			if _bSame_  return "" + _cfC_[:color]  ok
		next
		return ""

	def _BoxAt(aCentre, nBoxW, nBoxH)
		if len(aCentre) < 2  return [ nBoxW, nBoxH ]  ok
		for _bq_ in @aRenderNodeRects
			if fabs(_bq_[1] + _bq_[3] / 2 - aCentre[1]) < 1.5 and
			   fabs(_bq_[2] + _bq_[4] / 2 - aCentre[2]) < 1.5
				return [ _bq_[3], _bq_[4] ]
			ok
		next
		return [ nBoxW, nBoxH ]

	# Which mode an id landed in, 0 when the picture has none.
	# Which placed ROW a node sits in, 0 when it is not placed. The row
	# list is the distinct y values, sorted, so this is the index a gap
	# is counted from.
	# How far the frame on this row reaches above and below the cells
	# standing in it: [ above, below ], or [] when the row holds none.
	# Asked of the frame's OWN box, so the placement and the drawing
	# cannot disagree about where a region ends.
	def _RowFrameBox(paXY, nRowY, nBoxW, nBoxH)
		_rfTop_ = 1000000
		_rfBot_ = 0 - 1000000
		_bAny_ = 0
		for _rfC_ in @aClusters
			_bHere_ = 0
			for _rfM_ in _rfC_[:nodes]
				_rfA_ = This._XYOf(paXY, "" + _rfM_)
				if len(_rfA_) != 2  loop  ok
				if fabs(_rfA_[2] - nRowY) < 2  _bHere_ = 1  ok
			next
			if NOT _bHere_  loop  ok
			_rfB_ = This._ClusterBox(_rfC_, paXY, nBoxW, nBoxH)
			if len(_rfB_) != 4  loop  ok
			# the label strip lives above the box and is drawn too --
			# WHEN THERE IS A LABEL. Reserved unconditionally, it was
			# 24.7px of air above a row that nothing balanced below it,
			# and the entry gap read 107.85 against an exit gap of
			# 81.95. Three places had to be told; this is the third, and
			# they are three because each one answers a different
			# question about the same strip -- what the frame draws,
			# what the paper must hold, and what the row must reserve.
			_rfSt_ = 0
			if StzTrim("" + _rfC_[:label]) != ""
				_rfSt_ = @nLastFsz * 1.9
			ok
			_rfT2_ = _rfB_[2] - _rfSt_
			if _rfT2_ < _rfTop_  _rfTop_ = _rfT2_  ok
			if _rfB_[2] + _rfB_[4] > _rfBot_  _rfBot_ = _rfB_[2] + _rfB_[4]  ok
			_bAny_ = 1
		next
		if NOT _bAny_  return []  ok
		return [ max([ 0, nRowY - nBoxH / 2 - _rfTop_ ]),
			max([ 0, _rfBot_ - (nRowY + nBoxH / 2) ]) ]

	def _RowOfXY(paXY, paRows, pcId)
		_rid_ = StzLower("" + pcId)
		for _rq_ in paXY
			if _rq_[1] != _rid_  loop  ok
			for _rk_ = 1 to len(paRows)
				if fabs(paRows[_rk_] - _rq_[3]) < 2  return _rk_  ok
			next
			return 0
		next
		return 0

	def _ModeOfId(pcId)
		_mid_ = StzLower("" + pcId)
		for _mr_ in @aModeOfId
			if _mr_[1] = _mid_  return _mr_[2]  ok
		next
		return 0

	def _BoxOf(pcId, nBoxW, nBoxH)
		_bid_ = StzLower("" + pcId)
		for _br_ in @aBoxOf
			if _br_[1] = _bid_  return [ _br_[2], _br_[3] ]  ok
		next
		return [ nBoxW, nBoxH ]

	def _FillBoxSizes(nBoxW, nBoxH)
		@aBoxOf = []
		_oNn_ = This.NotationO()
		for _nd_ in This.Nodes()
			_k_ = ""
			if HasKey(_nd_, "properties") and isList(_nd_["properties"])
				if HasKey(_nd_["properties"], "type")
					_k_ = "" + _nd_["properties"]["type"]
				ok
			ok
			if _k_ = ""  loop  ok
			_sc_ = _oNn_.ScaleOf(_k_)
			if NOT isNumber(_sc_)  loop  ok
			if _sc_ >= 0.999 or _sc_ <= 0  loop  ok
			# a MARK is square: it carries no text, so nothing makes it
			# wider than it is tall
			_d_ = min([ nBoxW, nBoxH ]) * _sc_
			@aBoxOf + [ StzLower("" + _nd_[:id]), _d_, _d_ ]
		next
		return This

	def NotationFindings()
		return This.NotationO().Check(This)

	# The nodes whose KIND the notation declares as a source or a sink --
	# the lifecycle template's anchors. Lowercased ids, for the layout.
	def _KindedIds(paKinds)
		_aOut_ = []
		if len(paKinds) = 0  return _aOut_  ok
		for _nd_ in This.Nodes()
			_k_ = ""
			if HasKey(_nd_, "properties") and isList(_nd_["properties"])
				if HasKey(_nd_["properties"], "type")
					_k_ = StzLower("" + _nd_["properties"]["type"])
				ok
			ok
			if _k_ = ""  loop  ok
			for _kk_ in paKinds
				if _kk_ = _k_
					_aOut_ + StzLower("" + _nd_[:id])
					exit
				ok
			next
		next
		return _aOut_

	# A LAYOUT NAME THIS DOES NOT KNOW IS REFUSED, not stored. It used to
	# take anything, and an unrecognised name became top-down in silence --
	# so `SetLayout(:LeftToRight)` drew a top-down picture and there was
	# nothing anywhere to say the instruction had been dropped. A setter
	# that accepts a value it will not honour is worse than one that
	# refuses: the caller has evidence of neither.
	def SetLayout(pLayout)
		_c_ = StzLower("" + pLayout)
		if _c_ = ""
			StzRaise("stzDiagram.SetLayout: name a direction (:TopDown, " +
				":BottomUp, :LeftRight, :RightLeft) or a graphviz engine.")
		ok
		_bOk_ = 0
		for _k_ in [ :TopDown, :BottomUp, :LeftRight, :RightLeft ]
			if _c_ = StzLower("" + _k_) or StzFindFirst(_c_, $acLayouts[_k_]) > 0
				_bOk_ = 1
				exit
			ok
		next
		if _bOk_ = 0 and StzFindFirst(_c_, $acLayoutEngines) > 0  _bOk_ = 1  ok
		if _bOk_ = 0
			StzRaise("stzDiagram.SetLayout: '" + pLayout + "' is not a " +
				"layout I know. Directions are :TopDown, :BottomUp, " +
				":LeftRight and :RightLeft (or tb/bt/lr/rl); engines are " +
				StzJoinWith($acLayoutEngines, ", ") + ".")
		ok
		@cLayout = _c_

	def SetEdgeStyle(pStyle)
		@cEdgeStyle = StzLower(pStyle)

	def SetEdgeColor(pColor)
		@cEdgeColor = ResolveColor(pColor)

	# The focus colour's setter, missing until now. ExportToStyl() has always
	# WRITTEN a focus section (color + penwidth), and _ApplyStyle() has always
	# called This.SetFocusColor() to read it back -- a method nobody had
	# written, so loading any exported .stzstyl died on R14. Same shape as its
	# siblings: resolve the name, keep the resolved value.
	def SetFocusColor(pColor)
		@cFocusColor = ResolveColor(pColor)

	def FocusColor()
		return @cFocusColor

	def SetNodeColor(pColor)
		@cNodeColor = ResolveColor(pColor)

	def SetNodeStrokeColor(pColor)
	    if pColor = "" or StzLower(pColor) = 'invisible'
	        @cNodeStrokeColor = ""
	    else
	        @cNodeStrokeColor = ResolveColor(pColor)
	    ok

	    def SetStrokeColor(pColor)
		This.SetNodeStrokeColor(pColor)

	def SetFont(pFont)
		@cFont = StzLower(pFont)
		@bFontCustomized = 1

	def SetFontSize(pSize)
	    @nFontSize = pSize
	    @bFontCustomized = 1
	

	def SetPenWidth(pnWidth)
		@nNodePenWidth = pnWidth

	def SetNodePenWidth(pnWidth)
		@nNodePenWidth = pnWidth
		@nEdgePenWidth = pnWidth

	def SetEdgePenWidth(pnWidth)
		@nEdgePenWidth = pnWidth
	
	def SetNodePenStyle(pcStyle)
		# Parse + and , as separators
		@cNodePenStyle = This._NormalizeStyle(pcStyle)
	
	def SetEdgePenStyle(pcStyle)
		@cEdgePenStyle = This._NormalizeStyle(pcStyle)
	
	def _NormalizeStyle(pcStyle)
		_cStyle_ = StzLower(pcStyle)
		# Replace + with ,
		_cStyle_ = StzReplace(_cStyle_, "+", ",")
		return _cStyle_
	
	def SetArrowHead(pcStyle)
		@cArrowHead = StzLower(pcStyle)

	def SetArrowTail(pcStyle)
		@cArrowTail = StzLower(pcStyle)

	def SetSplines(pcType)

	    # A VALUE THIS DOES NOT RECOGNISE USED TO RESET THE SPLINE TO THE DEFAULT,
	    # so SetSplines("ortho") followed by SetSplines("dashed") left you with
	    # "spline" -- not the ortho you asked for and not the dashed you asked for
	    # either. A rejected value now leaves the knob alone, which is what every
	    # other validating setter here does (SetTheme, SetLayoutPreset).
	    _cType_ = StzLower(pcType)
	    if StzFindFirst(_cType_, $acSplineTypes) > 0
	        @cSplineType = _cType_
	    ok

	    # THESE TWO ARE NAMED FOR A DIFFERENT GRAPHVIZ ATTRIBUTE than the one they
	    # reach. A spline is the ROUTE an edge takes (ortho, curved, polyline); a
	    # line style is how it is DRAWN (dashed, dotted, bold). Both names read as
	    # the second and both delegated to the first, so SetEdgeLineStyle("dashed")
	    # -- the obvious call -- was swallowed.
	    #
	    # Routing on the value keeps every call that works today working: a spline
	    # name still sets the spline, and a pen style now sets the pen style
	    # instead of vanishing.
	    def SetEdgeLineStyle(pcType)
		This._SetEdgeLine(pcType)

	    def SetEdgeLineType(pcType)
		This._SetEdgeLine(pcType)

	    def _SetEdgeLine(pcType)
		_cWanted_ = StzLower(pcType)
		if StzFindFirst(_cWanted_, $acSplineTypes) > 0
			This.SetSplines(_cWanted_)
		but StzFindFirst(_cWanted_, $acEdgePenStyles) > 0
			This.SetEdgePenStyle(_cWanted_)
		ok

	    def SetEdgeSpline(pcType)
		This.SetSplines(pcType)

	def SetNodeSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nNodeSep = pnValue
	    ok
	
	def SetRankSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nRankSep = pnValue
	    ok
	
	def SetConcentrate(pbValue) #TODO // Check this
	    @bConcentrate = pbValue

	def SetLayoutPreset(pcPreset)
	    switch StzLower(pcPreset)
	    on "orgchart"
		This.SetEdgeColor($cDefaultOrgChartEdgeColor)
	        This.SetSplines($cDefaultOrgChartEdgeSpline)
	        This.SetNodeSeparation(1.0)   # Increased for side-by-side
	        This.SetRankSeparation(1.0)   # Increased for vertical clarity
	        This.SetConcentrate(0)
	        
	    on "orgchart_compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.6)
	        This.SetRankSeparation(0.8)
	        This.SetConcentrate(0)
	        
	    on "compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.3)
	        This.SetRankSeparation(0.5)
	        This.SetConcentrate(1)
	        
	    on "spacious"
	        This.SetSplines("ortho")
	        This.SetNodeSeparation(1.2)
	        This.SetRankSeparation(1.5)
	        This.SetConcentrate(0)
	        
	    on "flowchart"
	        This.SetSplines("polyline")
	        This.SetNodeSeparation(0.8)
	        This.SetRankSeparation(1.0)
	        This.SetConcentrate(0)
	    off

	def SetTitle(pcTitle)
	    @cTitle = pcTitle
	
	def SetSubtitle(pcSubtitle)
	    @cSubtitle = pcSubtitle

	def SetOutputFormat(cFormat)
		@cOutputFormat = StzLower(cFormat)

		def SetOutput(cFormat)
			@cOutputFormat = StzLower(cFormat)

	def SetTooltip(paConfig)
	    @aTooltipConfig = paConfig

	def DisableTooltip()
		@aTooltipConfig = []

	# Getters
	def NodePenWidth()
		if @nNodePenWidth = @nEdgePenWidth
			return @nNodePenWidth
		else
			return [ @nNodePenWidth, @nNodePenWidth ]
		ok
	
	def EdgePenWidth()
		return @nEdgePenWidth
	
	def NodePenStyle()
		return @cNodePenStyle
	
	def EdgePenStyle()
		return @cEdgePenStyle
	
	def ArrowHead()
		return @cArrowHead
	
	def ArrowTail()
		return @cArrowTail

	def Splines()
	    return @cSplineType
	
	def NodeSeparation()
	    return @nNodeSep
	
	def RankSeparation()
	    return @nRankSep
	
	def Concentrate()
	    return @bConcentrate

	#---

	def Theme()
		return @cTheme
	
	def Layout()
		return @cLayout
	
	def EdgeColor()
		return @cEdgeColor

	def NodeStrokeColor()
		return @cNodeStrokeColor
	
	def EdgeStyle()
		return @cEdgeStyle
	
	def Font()
		return @cFont
	
	def FontSize()
		return @nFontSize
	
	def PenWidth()
		return @nPenWidth

	def EdgeSplines()
		return @cSplineType

		def SplineType()
			return @cSplineType

		def EdgeLineStyle()
			return @cSplineType

		def EdgeLineType()
			return @cSplineType

	def Title()
	    return @cTitle
	
	def Subtitle()
	    return @cSubtitle

	def OutputFormat()
		return @cOutputFormat

	
	def TooltipConfig()
	    return @aTooltipConfig

	#--------------------#
	#  COLOR RESOLUTION  #
	#--------------------#

	def ResolveFontColor(pBgColor)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ResolveFontColor(pBgColor)
		return _cResult_
	
	def ContrastingTextColor(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ContrastingTextColor(_cColor_)
		return _cResult_
	
	def ColorToRGB(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ColorToRGB(_cColor_)
		return _cResult_

	def NodeStrokeColorForTheme(_cTheme_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.NodeStrokeColorForTheme(_cTheme_)
		return _cResult_

	def ConvertColorTogray(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ConvertColorTogray(_cColor_)
		return _cResult_

	#--------------------------------------------------------------------------------#
	# ADDING SPECIFIC FORMS OF NODES (ALL SUPPORTED FORMS IN GRAPHVIZ DOT LANGAUGE)  #
	#--------------------------------------------------------------------------------#
	
	#NOTE // We can add nodes using parent stzGraph methods AddNode(), AddNodeXT() and AddNodeXTT()
	
	# Rounded/Elliptical Shapes
	
	def AddCircle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "circle", :color = $cDefaultNodeColor])
	
	def AddCircleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "circle", :color = $cDefaultNodeColor])
	
	def AddCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "circle" ]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddDoubleCircle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "doublecircle", :color = $cDefaultNodeColor])
	
	def AddDoubleCircleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "doublecircle", :color = $cDefaultNodeColor])
	
	def AddDoubleCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "doublecircle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddEllipse(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "ellipse", :color = $cDefaultNodeColor])
	
	def AddEllipseXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "ellipse", :color = $cDefaultNodeColor])
	
	def AddEllipseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "ellipse"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddEgg(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "egg", :color = $cDefaultNodeColor])
	
	def AddEggXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "egg", :color = $cDefaultNodeColor])
	
	def AddEggXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "egg"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Quadrilateral Shapes
	
	def AddSquare(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "square", :color = $cDefaultNodeColor])
	
	def AddSquareXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "square", :color = $cDefaultNodeColor])
	
	def AddSquareXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "square"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddRect(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "rect", :color = $cDefaultNodeColor])
	
	def AddRectXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "rect", :color = $cDefaultNodeColor])
	
	def AddRectXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "rect"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddBox(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "box", :color = $cDefaultNodeColor])
	
	def AddBoxXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "box", :color = $cDefaultNodeColor])
	
	def AddBoxXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "box"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddParallelogram(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "parallelogram", :color = $cDefaultNodeColor])
	
	def AddParallelogramXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "parallelogram", :color = $cDefaultNodeColor])
	
	def AddParallelogramXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "parallelogram"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTrapezium(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "trapezium", :color = $cDefaultNodeColor])
	
	def AddTrapeziumXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "trapezium", :color = $cDefaultNodeColor])
	
	def AddTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "trapezium"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddInvTrapezium(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "invtrapezium", :color = $cDefaultNodeColor])
	
	def AddInvTrapeziumXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "invtrapezium", :color = $cDefaultNodeColor])
	
	def AddInvTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "invtrapezium"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddDiamond(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "diamond", :color = $cDefaultNodeColor])
	
	def AddDiamondXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "diamond", :color = $cDefaultNodeColor])
	
	def AddDiamondXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "diamond"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Polygon Shapes
	
	def AddTriangle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "triangle", :color = $cDefaultNodeColor])
	
	def AddTriangleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "triangle", :color = $cDefaultNodeColor])
	
	def AddTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "triangle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddInvTriangle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "invtriangle", :color = $cDefaultNodeColor])
	
	def AddInvTriangleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "invtriangle", :color = $cDefaultNodeColor])
	
	def AddInvTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "invtriangle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddPentagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "pentagon", :color = $cDefaultNodeColor])
	
	def AddPentagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "pentagon", :color = $cDefaultNodeColor])
	
	def AddPentagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "pentagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddHexagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "hexagon", :color = $cDefaultNodeColor])
	
	def AddHexagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "hexagon", :color = $cDefaultNodeColor])
	
	def AddHexagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "hexagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddSeptagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "septagon", :color = $cDefaultNodeColor])
	
	def AddSeptagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "septagon", :color = $cDefaultNodeColor])
	
	def AddSeptagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "septagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddOctagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "octagon", :color = $cDefaultNodeColor])
	
	def AddOctagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "octagon", :color = $cDefaultNodeColor])
	
	def AddOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "octagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTripleOctagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "tripleoctagon", :color = $cDefaultNodeColor])
	
	def AddTripleOctagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "tripleoctagon", :color = $cDefaultNodeColor])
	
	def AddTripleOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "tripleoctagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Non-geometric/Conceptual Shapes
	
	def AddCylinder(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "cylinder", :color = $cDefaultNodeColor])
	
	def AddCylinderXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "cylinder", :color = $cDefaultNodeColor])
	
	def AddCylinderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "cylinder"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddHouse(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "house", :color = $cDefaultNodeColor])
	
	def AddHouseXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "house", :color = $cDefaultNodeColor])
	
	def AddHouseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "house"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTab(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "tab", :color = $cDefaultNodeColor])
	
	def AddTabXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "tab", :color = $cDefaultNodeColor])
	
	def AddTabXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "tab"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddFolder(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "folder", :color = $cDefaultNodeColor])
	
	def AddFolderXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "folder", :color = $cDefaultNodeColor])
	
	def AddFolderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + [ "type", "folder" ]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddComponent(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "component", :color = $cDefaultNodeColor])
	
	def AddComponentXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "component", :color = $cDefaultNodeColor])
	
	def AddComponentXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "component"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddNote(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "note", :color = $cDefaultNodeColor])
	
	def AddNoteXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "note", :color = $cDefaultNodeColor])
	
	def AddNoteXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "note"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)

	#----------------------#
	#  CLUSTER OPERATIONS  #
	#----------------------#

	def SetClusterColor(pcColor)
		@cClusterColor = ResolveColor(pcColor)

	def AddCluster(pClusterId, aNodeIds)
		This.AddClusterXT(pClusterId, pClusterId, aNodeIds)

	def AddClusterXT(pClusterId, pLabel, aNodeIds)
		This.AddClusterXTT(pClusterId, pLabel, aNodeIds, @cClusterColor)

	def AddClusterXTT(pClusterId, pLabel, aNodeIds, pColor)
		_aCluster_ = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = aNodeIds,
			:color = ResolveColor(pColor)
		]
		@aClusters + _aCluster_

	def Clusters()
		return @aClusters

	#-------------------------#
	#  ANNOTATION OPERATIONS  #
	#-------------------------#

	def AddAnnotation(oAnnotation)
		@aoAnnotations + oAnnotation

	def AnnotationsByType(pcType)
		_aoFiltered_ = []
		_nLen_ = len(@aoAnnotations)

		for i = 1 to _nLen_
			if @aoAnnotations[i].Type() = pcType
				_aoFiltered_ + @aoAnnotations[i]
			ok
		end
		return _aoFiltered_

	# The annotators overlaying this diagram -- OBJECTS, hence Q.
	def AnnotationsQ()
		return @aoAnnotations

	# ... and what they are, as data: the type each one annotates.
	def Annotations()
		_acTypes_ = []
		_nLen_ = len(@aoAnnotations)
		for i = 1 to _nLen_
			_acTypes_ + @aoAnnotations[i].Type()
		end
		return _acTypes_

	#-----------------------#
	#  TEMPLATE OPERATIONS  #
	#-----------------------#

	def AddTemplate(oTemplate) #TODO // #TODO Test this
		@aoTemplates + oTemplate

	def ApplyTemplates()
		_nLen_ = len(@aoTemplates)
		for i = 1 to _nLen_
			@aoTemplates[i].Apply(This)
		end

	#----------------#
	#  VISUAL RULES  #
	#----------------#

	# This section manages visual styling rules that change
	# diagram appearance based on node/edge properties.

	def RegisterVisualRule(pcRuleName, paDefinition)
		# Store visual rule as data structure
		_aRule_ = [
			:name = pcRuleName,
			:conditionType = paDefinition[:conditionType],
			:conditionParams = paDefinition[:conditionParams],
			:effects = paDefinition[:effects]
		]
		@aoVisualRules + _aRule_
	
	def ApplyVisualRules()
		@aNodeRulesEffects = []
		@aEdgesRulesEffects = []
		
		# Apply to nodes
		_aNodes_ = This.Nodes()
		_nNodes4Len_ = len(_aNodes_)
		for _iLoopNodes4_ = 1 to _nNodes4Len_
			_aNode_ = _aNodes_[_iLoopNodes4_]
			_aEnhancements_ = This._ApplyRulesToElement(_aNode_, "node")
			if len(_aEnhancements_) > 0
				@aNodeRulesEffects[_aNode_[:id]] = _aEnhancements_
			ok
		end
		
		# Apply to edges
		_aEdges_ = This.Edges()
		_nEdges3Len_ = len(_aEdges_)
		for _iLoopEdges3_ = 1 to _nEdges3Len_
			_aEdge_ = _aEdges_[_iLoopEdges3_]
			_aEnhancements_ = This._ApplyRulesToElement(_aEdge_, "edge")
			_cKey_ = _aEdge_[:from] + "->" + _aEdge_[:to]
			if len(_aEnhancements_) > 0
				@aEdgesRulesEffects[_cKey_] = _aEnhancements_
			ok
		end
	
	def _ApplyRulesToElement(aElement, _cType_)
	    _aEnhancements_ = []
	    
	    _nAoVisualRules3Len_ = len(@aoVisualRules)
	    for _iLoopAoVisualRules3_ = 1 to _nAoVisualRules3Len_
	    	_aRule_ = @aoVisualRules[_iLoopAoVisualRules3_]
	        _aContext_ = This._BuildRuleContext(aElement)
	        
	        if This._RuleMatches(_aRule_, _aContext_)
	            # DEBUG
	            # ? "Rule '" + aRule[:name] + "' matched node: " + aElement[:id]
	            # ? "  Effects: " + @@(aRule[:effects])
	            
	            _aEffects_ = _aRule_[:effects]
	            
	            # Merge effects
	            _nEffects2Len_ = len(_aEffects_)
	            for _iLoopEffects2_ = 1 to _nEffects2Len_
	            	_aEffect_ = _aEffects_[_iLoopEffects2_]
	                _aEnhancements_[_aEffect_[1]] = _aEffect_[2]
	            end
	        ok
	    end
	    
	    # DEBUG
	    # if len(aEnhancements) > 0
	    #     ? "Final enhancements for " + aElement[:id] + ": " + @@(aEnhancements)
	    # ok
	    
	    return _aEnhancements_

	
	def _RuleMatches(_aRule_, _aContext_)
		_cType_ = _aRule_[:conditionType]
		_aParams_ = _aRule_[:conditionParams]
		
		switch _cType_
		on "property_range"
			return This._MatchRange(_aContext_, _aParams_)
		on "property_equals"
			return This._MatchEquals(_aContext_, _aParams_)
		on "property_exists"
			return This._MatchExists(_aContext_, _aParams_)
		on "tag_exists"
			return This._MatchTag(_aContext_, _aParams_)
		off
		
		return 0
	
	def _MatchRange(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		_nMin_ = _aParams_[2]
		_nMax_ = _aParams_[3]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return 0
		ok
		
		pValue = _aContext_[:properties][_cKey_]
		if NOT isNumber(pValue)
			return 0
		ok
		
		return (pValue >= _nMin_ and pValue <= _nMax_)
	
	def _MatchEquals(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		pExpected = _aParams_[2]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return 0
		ok
		
		return (_aContext_[:properties][_cKey_] = pExpected)
	
	def _MatchExists(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		return HasKey(_aContext_[:properties], _cKey_)
	
	def _MatchTag(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :tags)
			return 0
		ok
		
		_cTag_ = _aParams_[1]
		return StzFindFirst(_cTag_, _aContext_[:tags]) > 0
	
	def _BuildRuleContext(aElement)
		_aContext_ = aElement
		
		if HasKey(aElement, :properties) and aElement[:properties] != ""
			_aContext_[:properties] = aElement[:properties]
			_aContext_[:tags] = []
			if HasKey(aElement[:properties], :tags)
				_aContext_[:tags] = aElement[:properties][:tags]
			ok
		ok
		
		return _aContext_
	

	def NodesAffectedByVisualRules()
	    _acResult_ = []
	    _acKeys_ = keys(@aNodeRulesEffects)
	    _nAcKeys2Len_ = len(_acKeys_)
	    for _iLoopAcKeys2_ = 1 to _nAcKeys2Len_
	    	_cKey_ = _acKeys_[_iLoopAcKeys2_]
	        _acResult_ + _cKey_
	    next
	    return _acResult_
	
	def VisualRulesApplied()
	    _aResult_ = []
	    _nAoVisualRules2Len_ = len(@aoVisualRules)
	    for _iLoopAoVisualRules2_ = 1 to _nAoVisualRules2Len_
	    	_aRule_ = @aoVisualRules[_iLoopAoVisualRules2_]
	        _aResult_ + [
	            :name = _aRule_[:name],
	            :conditionType = _aRule_[:conditionType],
	            :effectsCount = len(_aRule_[:effects])
	        ]
	    next
	    return _aResult_

	#-----------------#
	#  QUERY METHODS  #
	#-----------------#
	
	# properties-based queries
	def NodesWithProperty(pcProp)
		_acResult_ = []
		_aNodes_ = This.Nodes()
		
		_nNodes3Len_ = len(_aNodes_)
		for _iLoopNodes3_ = 1 to _nNodes3Len_
			_aNode_ = _aNodes_[_iLoopNodes3_]
			if HasKey(_aNode_, :properties) and 
			   HasKey(_aNode_[:properties], pcProp)
				_acResult_ + _aNode_[:id]
			ok
		end
		
		return _acResult_
	
	def NodesWith(pcProp, pcOp, pValue)
		# Reuse graph query system
		_oQuery_ = new stzGraphQuery(This, "nodes")
		_oQuery_.Where(pcProp, pcOp, pValue)
		return _oQuery_.Run()
	
	def NodesWithTag(pcTag)
		_acResult_ = []
		_aNodes_ = This.Nodes()
		
		_nNodes2Len_ = len(_aNodes_)
		for _iLoopNodes2_ = 1 to _nNodes2Len_
			_aNode_ = _aNodes_[_iLoopNodes2_]
			if HasKey(_aNode_, :properties) and 
			   HasKey(_aNode_[:properties], :tags) and
			   StzFindFirst(pcTag, _aNode_[:properties][:tags]) > 0
				_acResult_ + _aNode_[:id]
			ok
		end
		
		return _acResult_
	
	def EdgesWithProperty(pcProp)
		_acResult_ = []
		_aEdges_ = This.Edges()
		
		_nEdges2Len_ = len(_aEdges_)
		for _iLoopEdges2_ = 1 to _nEdges2Len_
			_aEdge_ = _aEdges_[_iLoopEdges2_]
			if HasKey(_aEdge_, :properties) and 
			   HasKey(_aEdge_[:properties], pcProp)
				_acResult_ + (_aEdge_[:from] + "->" + _aEdge_[:to])
			ok
		end
		
		return _acResult_
	
	def EdgesWithPropertyValue(pcProp, pValue)
		_acResult_ = []
		_aEdges_ = This.Edges()
		
		_nEdges1Len_ = len(_aEdges_)
		for _iLoopEdges1_ = 1 to _nEdges1Len_
			_aEdge_ = _aEdges_[_iLoopEdges1_]
			if HasKey(_aEdge_, :properties) and 
			   HasKey(_aEdge_[:properties], pcProp) and
			   _aEdge_[:properties][pcProp] = pValue
				_acResult_ + (_aEdge_[:from] + "->" + _aEdge_[:to])
			ok
		end
		
		return _acResult_
	
	#---------------------#
	#  properties LEGEND  # #TODO Should be abstarcted in stzGraph!!
	#---------------------#
	
	def propertiesLegend()
		_acLegend_ = ["=== properties LEGEND ===", ""]
		
		_nAoVisualRules1Len_ = len(@aoVisualRules)
		for _iLoopAoVisualRules1_ = 1 to _nAoVisualRules1Len_
			_oRule_ = @aoVisualRules[_iLoopAoVisualRules1_]
			_cCondition_ = _oRule_.@cConditionType
			_aParams_ = _oRule_.@aConditionParams
			_aEffects_ = _oRule_.Effects()
			
			_acLegend_ + "When: " + _cCondition_
			if len(_aParams_) > 0
				_acLegend_ + "  Params: " + @@(_aParams_)
			ok
			
			_nEffects1Len_ = len(_aEffects_)
			for _iLoopEffects1_ = 1 to _nEffects1Len_
				_aEffect_ = _aEffects_[_iLoopEffects1_]
				# NOTE: this marker was corrupted beyond recovery -- the bytes were
				# SUBSTITUTED, not merely re-encoded, so the original glyph cannot
				# be derived (no candidate reproduces the run under any number of
				# corruption passes, and it predates the variable's current name).
				# ASCII "->" matches its sibling lines ("When: ", "  Params: ").
				_acLegend_ + "  -> " + _aEffect_[1] + ": " + _aEffect_[2]
			next
			
			_acLegend_ + ""
		end
		
		return _acLegend_

	#-----------#
	#  METRICS  # #TODO Should be abstracted in stzGraph!
	#-----------#

	def ComputeMetrics()
		_aMetrics_ = []
		_anAllPaths_ = []
		_aNodes_ = This.Nodes()
		_nLenNodes_ = len(_aNodes_)

		for i = 1 to _nLenNodes_
			_aReachable_ = This.ReachableFrom(_aNodes_[i]["id"])
			_nLen_ = len(_aReachable_)
			if _nLen_ > 1
				_anAllPaths_ + (_nLen_ - 1)
			ok
		end

		_nAvg_ = 0
		_nLen_ = len(_anAllPaths_)

		_nSum_ = 0
		for i = 1 to _nLen_
			_nSum_ += _anAllPaths_[i]
		end
		_nAvg_ = _nSum_ / _nLen_

		_nMax_ = 0
		for i = 1 to _nLen_
			if _anAllPaths_[i] > _nMax_
				_nMax_ = _anAllPaths_[i]
			ok
		end

		_aMetrics_[:avgPathLength] = _nAvg_
		_aMetrics_[:maxPathLength] = _nMax_
		_aMetrics_[:bottlenecks] = This.BottleneckNodes()
		_aMetrics_[:density] = This.NodeDensity()
		_aMetrics_[:nodeCount] = This.NodeCount()
		_aMetrics_[:edgeCount] = This.EdgeCount()

		return _aMetrics_

	#-----------------#
	#  VISUALIZATION  #
	#-----------------#

	#-----------------------------------------------------------------#
	#  THE NATIVE TIER -- a diagram drawn WITHOUT dot.exe             #
	#-----------------------------------------------------------------#
	#
	#     oD.ToSVG()               # vector, needs no GPU and no graphviz
	#     oD.ToPNG("d.png")        # pixels, through the GPU
	#     oD.ToCanvas()            # the stzCanvas, to compose further
	#
	# ToDot() and Display() are untouched: emitting the dot LANGUAGE is a
	# legitimate export, and a caller with graphviz installed may still
	# want its renderer. What changes is that neither is REQUIRED any more.
	#
	# LAYOUT IS BORROWED, DRAWING IS NOT. Positions come from
	# stzGraphCanvas -- the engine-side layout GG1 built, measured and
	# guarded -- because layout is the expensive, correctness-critical part
	# and a second implementation of it would diverge. The DRAWING is here,
	# because a diagram is a different picture from a graph: boxes with
	# labels inside, twenty-four shapes, clusters behind. That is the same
	# split stzOrgChart already made.
	#
	# KILL CRITERION, written before the code: dot still wins on two things
	# this route does not attempt -- SPLINE edges routed around nodes, and
	# nested clusters. If a diagram needs those, ToDot() remains the honest
	# answer and this tier is a convenience, not a replacement. What it must
	# do is draw every shape in the vocabulary, keep cluster members inside
	# their cluster, and never need an external binary.

	def ToCanvas()
		return This.ToCanvasXT([])

	def ToCanvasXT(paOptions)
		if NOT isList(paOptions)  paOptions = []  ok

		_aNodes_ = This.Nodes()
		_nN_ = len(_aNodes_)
		if _nN_ = 0
			StzRaise("stzDiagram.ToCanvas: this diagram has no nodes to draw.")
		ok

		_nW_    = This._DiagOpt(paOptions, "width", 1000)
		_nH_    = This._DiagOpt(paOptions, "height", 700)
		_nBoxW_ = This._DiagOpt(paOptions, "nodewidth", 150)
		_nBoxH_ = This._DiagOpt(paOptions, "nodeheight", 56)
		_oFont_ = This._DiagOpt(paOptions, "font", "")
		_nFsz_  = This._DiagOpt(paOptions, "fontsize", 14)
		_cBg_   = This._DiagOpt(paOptions, "background", "#FFFFFF")
		_cEdge_ = This._DiagOpt(paOptions, "edgecolor", "#8A8A8A")
		_nEdgeW_= This._DiagOpt(paOptions, "edgewidth", 2)
		_nRad_  = This._DiagOpt(paOptions, "corner", 10)

		# THE FONT IS KNOWN NOW, so say so now. Everything that measures
		# a picture before it is drawn -- how tall a frame must be to
		# hold the word under its deepest rail, for one -- needs the
		# font, and these were published only in the DRAWING section.
		# A measurement taken with no font silently answers zero, which
		# is the kind of failure that shows up as a label 4px from a
		# frame's rule rather than as an error.
		@oLastFont = _oFont_
		@nLastFsz = _nFsz_
		@nLastEdgeW = _nEdgeW_
		@nEdgeCornerRad = _nRad_

		# A MARK IS SMALLER THAN A CELL, AND THE LAYOUT HAS TO KNOW IT
		# NOW. Per-node drawn sizes were computed in the DRAWING section,
		# so every row was budgeted as though the thing standing in it
		# were a full cell -- an initial mark 21.84px tall was given a
		# 52px row, and the 30px it did not use was handed to whichever
		# side of it the arithmetic happened to fall on. That is why the
		# way in and the way out came out 1.56px apart on the door: the
		# two marks are different sizes, so they wasted different
		# amounts. It is also a row and a half of paper in every picture
		# that has a mark in it.
		This._FillBoxSizes(_nBoxW_, _nBoxH_)

		# WHERE AN EVENT IS WRITTEN, as a dial rather than a rule: beside
		# its line (the default -- the line stays unbroken) or ON the
		# middle of it, plated with the surface underneath.
		_cLP_ = StzLower("" + This._DiagOpt(paOptions, "labelplacement",
			"beside"))
		if _cLP_ = "middle" or _cLP_ = "on" or _cLP_ = "online" or
		   _cLP_ = "center" or _cLP_ = "centre"
			@cLabelPlacement = "middle"
		else
			@cLabelPlacement = "beside"
		ok

		# THE ELBOW IS DRAWN IN THE SAME HAND AS THE CELL -- I5 applied to
		# style rather than to structure. A rounded box wired with square
		# elbows is two hands in one picture, and the reader has no graph
		# fact to attribute the difference to; the Principal saw it as
		# soon as the rest of the grammar settled. So the corner an edge
		# turns follows the corner a node is drawn with, and the wholly
		# rectangular style stays available by asking for it -- either
		# :Corner = 0, which squares both, or :EdgeCorners = :Sharp,
		# which squares only the wires.
		_cEcor_ = StzLower("" + This._DiagOpt(paOptions, "edgecorners", "auto"))
		if _cEcor_ = "sharp" or _cEcor_ = "square" or _cEcor_ = "0"
			@bRoundElbows = 0
		but _cEcor_ = "round" or _cEcor_ = "rounded" or _cEcor_ = "1"
			@bRoundElbows = 1
		else
			@bRoundElbows = (_nRad_ > 0)
		ok

		# :SCALE IS RESOLUTION, NOT ZOOM. A raster is only as sharp as the
		# pixels it was drawn with: enlarging a finished PNG enlarges its
		# blur, and a 12px label in a 3000px picture is unreadable at 100%
		# and worse magnified. Scaling every INPUT -- boxes, font,
		# separations, stroke, corners -- redraws the same diagram with
		# more pixels, so the glyphs are rasterised at their new size and
		# the edges are re-antialiased at it. :Scale = 2 gives text a
		# reader can actually magnify; 3 is print.
		#
		# Everything here is proportional, so ONE multiplier is enough and
		# the picture cannot come out subtly different -- which is what
		# scaling only some of these would give.
		_nScl_ = This._DiagOpt(paOptions, "scale", 1)
		if NOT isNumber(_nScl_)  _nScl_ = 1  ok
		if _nScl_ < 1  _nScl_ = 1  ok
		if _nScl_ > 1
			_nBoxW_ = _nBoxW_ * _nScl_
			_nBoxH_ = _nBoxH_ * _nScl_
			_nFsz_  = _nFsz_ * _nScl_
			_nEdgeW_= _nEdgeW_ * _nScl_
			_nRad_  = _nRad_ * _nScl_
			if This._HasOpt(paOptions, "width")   _nW_ = _nW_ * _nScl_  ok
			if This._HasOpt(paOptions, "height")  _nH_ = _nH_ * _nScl_  ok
		ok

		# A CELL IS AS WIDE AS THE WIDEST NAME IN THE PICTURE.
		#
		# "Awaiting Payment" came out as "Awaiting Pay..." in a box the
		# caller had sized for "In Cart", and an elided name is a diagram
		# that has quietly stopped saying what it is about. The author
		# writes MEANING and the layout owns GEOMETRY -- the plastic
		# position algorithm the Principal named -- and a width is
		# geometry.
		#
		# ONE width for every cell, not a width each: I5 says two cells
		# drawn differently assert a difference, and between two states
		# whose names happen to be different lengths there is none. So
		# the widest name sets the width and every cell takes it.
		#
		# The requested width is a MINIMUM, and there is a ceiling: past
		# two and a half times what was asked for, one enormous name
		# would blow up every cell in the picture, and eliding that one
		# is the smaller lie.
		if isObject(_oFont_)
			_nWide_ = 0
			for _nd9_ in _aNodes_
				_cLb9_ = StzTrim("" + _nd9_[:label])
				if _cLb9_ = ""  loop  ok
				# a mark writes its name OUTSIDE itself, so it asks
				# nothing of the box
				_cSh9_ = StzLower("" + This._NativeShapeOf(_nd9_))
				_bMk9_ = 0
				for _cO9_ in [ "circle", "doublecircle", "dot" ]
					if _cSh9_ = _cO9_  _bMk9_ = 1  exit  ok
				next
				if _bMk9_  loop  ok
				_w9_ = _oFont_.WidthOf(_cLb9_, _nFsz_)
				if _w9_ > _nWide_  _nWide_ = _w9_  ok
			next
			_nNeed_ = _nWide_ + 24
			_nCap9_ = _nBoxW_ * 2.5
			if _nNeed_ > _nCap9_  _nNeed_ = _nCap9_  ok
			if _nNeed_ > _nBoxW_  _nBoxW_ = ceil(_nNeed_)  ok
		ok

		# THE DIAGRAM'S OWN SETTINGS ARE READ, not re-asked for. SetLayout and
		# SetSplines already exist and already drive the dot output; a native
		# tier that ignored them would be a second diagram over the same data.
		_cRank_ = This._NativeRankDir()
		_cSpl_  = StzLower("" + This.Splines())
		if _cSpl_ = ""  _cSpl_ = "spline"  ok

		# Layout in a space inset by half a box, so a node on the border is not
		# half off-canvas -- and TRANSPOSED afterwards for LR/RL/BT, because
		# rankdir is a property of the picture, not of the graph.
		_cLM_ = StzLower("" + This._DiagOpt(paOptions, "layoutmode", :Hierarchical))
		# ...and the NOTATION may name it instead: a domain whose objects
		# are peers is read in a ring, not in ranks (DN2b). An explicit
		# :LayoutMode option still wins -- the caller is closer than the
		# profile.
		if @cNotationLayout != "" and NOT This._HasOpt(paOptions, "layoutmode")
			_cLM_ = StzLower("" + @cNotationLayout)
		ok
		_bRing_ = (_cLM_ = "ring" or _cLM_ = "circular")
		_bModes_ = (_cLM_ = "modes")

		_mx_ = _nBoxW_ / 2 + 14 * _nScl_
		_my_ = _nBoxH_ / 2 + 14 * _nScl_
		# A RING IS INSET EQUALLY ON BOTH AXES. The inset is half a cell
		# plus air, and a cell is wider than it is tall -- so a square
		# canvas still handed the layout a 768x832 box, and the circle
		# arrived as an ellipse with its "border" radii 32px apart. The
		# ring's one hard requirement is a square inner box.
		if _bRing_
			_mx_ = max([ _mx_, _my_ ])
			_my_ = _mx_
		ok

		# A MODE PICTURE'S INSET HOLDS WHAT REACHES PAST A CENTRE. Its
		# layout is given :Margin = 0 -- two margin systems stacked is
		# how a picture grows a border nobody asked for -- so the layout
		# spreads node CENTRES to the edges of the box, and everything a
		# node draws BEYOND its centre lives in this inset: half a cell,
		# the frame drawn around it, the loop radiating out of it, and
		# the name written under it. Half a cell alone let the frame run
		# off the right edge and cut "Demolished" in half.
		if _bModes_
			This._SetLanePitch(_oFont_, _nFsz_, _nBoxW_)
			# ...INCLUDING THE WORD BESIDE A LOOP, which sits beyond the
			# loop and so beyond everything else on that side. Funded in
			# the WIDTH it merely made the canvas bigger while the layout
			# still spread centres to the same edges, and the word stayed
			# outside. What reaches past a centre is paid for in the
			# inset, not in the total.
			_nLoopLabW_ = 0
			if isObject(_oFont_)
				for _e6_ in This.Edges()
					if StzLower("" + _e6_[:from]) != StzLower("" + _e6_[:to])
						loop
					ok
					_l6_ = StzTrim("" + _e6_[:label])
					if _l6_ = ""  loop  ok
					_w6_ = _oFont_.WidthOf(_l6_, _nFsz_) + 14
					if _w6_ > _nLoopLabW_  _nLoopLabW_ = _w6_  ok
				next
			ok
			# ...and the frame's own RULE needs room to be seen: at
			# exactly the inset it lands on the paper's last column and
			# reads as a picture cut off rather than a frame closed.
			_mx_ = max([ _mx_, _nBoxW_ / 2 + This._ClusterPadMax() +
				This._SelfLoopReach(_nBoxW_, _nBoxH_) + 6 + _nLoopLabW_ +
				_nEdgeW_ * 2 + 6 ])
			_my_ = max([ _my_, _nBoxH_ / 2 + This._ClusterChromeAbove(_nFsz_),
				_nBoxH_ / 2 + _nFsz_ * 2.4 ])
		ok

		_bSwap_ = 0
		if _cRank_ = "LR" or _cRank_ = "RL"  _bSwap_ = 1  ok

		# SPACING IS THE CONTRACT; THE SIZE IS DERIVED. That is dot's model,
		# and this tier had it inverted: the caller fixed a canvas and the
		# layout was stretched to fill it, so the minimum gap between two
		# nodes was whatever the stretch left over -- 2px in a crowded rank,
		# 20px in a loose one, in the same picture. Meanwhile the diagram
		# already OWNED the contract: SetNodeSeparation and SetRankSeparation
		# exist, in dot's own units, and only the DOT WRITER read them. The
		# knob the caller sends and the knob the face reads have to be the
		# same knob.
		#
		# So: when the caller does not name a size, the picture takes its
		# size from its content -- every gap exactly nodesep, every rank
		# exactly ranksep apart, like dot. Naming :Width/:Height keeps the
		# old fill-the-canvas behaviour, with :FitBoxes as the safety net.
		# Separations arrive in dot's inches (96dpi), overridable in pixels
		# via :NodeSep / :RankSep.
		_aRoute_ = []

		# A MODE OF TWO OR MORE STATES IS DRAWN AS A REGION. The cluster
		# machinery already owns boundaries, chrome, air and containment,
		# so a mode reuses it rather than inventing a second kind of box.
		# Discovered, not declared: the author never names a mode, the
		# graph does -- and an author's OWN clusters always win, so this
		# only ever fills a vacuum.
		if _bModes_ and len(@aClusters) = 0
			This._DeclareModeRegions()
		ok

		# A NAMED SIZE IS A MAXIMUM, NEVER A TARGET -- the plastic layout's
		# space rule, marked by the Principal on the live editor: "at any
		# situation, space is optimised". The old rule took :Width/:Height
		# as a canvas to FILL, so a five-column graph in an 1100px window
		# was tight and the same window after three link edits -- the graph
		# now two columns -- was two cells with 836px of void between them:
		# every gap the contract set was multiplied by whatever the stretch
		# needed. Nothing in the graph said "far apart"; the paper did.
		#
		# So every hierarchical picture is laid out at CONTRACT spacing
		# first. A named size that the natural picture fits inside buys
		# paper, not distance -- the content keeps its exact natural
		# geometry and the canvas grows to the named size (a window has a
		# size; its diagram does not have to wear it). Only when the
		# natural picture does NOT fit does the named size constrain, and
		# that is the fill-and-shrink path below, unchanged.
		_bNamed_ = This._HasOpt(paOptions, "width") or This._HasOpt(paOptions, "height")
		_nReqW_ = _nW_
		_nReqH_ = _nH_
		_bNat_ = 0
		if _cLM_ = "hierarchical"
			_bNat_ = 1
		ok

		if _bRing_  _bNat_ = 0  ok
		_nSepN_ = This._DiagOpt(paOptions, "nodesep",
			floor(This.NodeSeparation() * 96)) * _nScl_
		_nSepR_ = This._DiagOpt(paOptions, "ranksep",
			floor(This.RankSeparation() * 96)) * _nScl_

		# A LABELLED EDGE NEEDS THE GAP IT IS WRITTEN IN. dot reserves this
		# by giving the label its own virtual rank; the same effect, at this
		# scale, is that the rank gap must be at least tall enough to hold a
		# line of text with air around it. Without the reservation a label
		# is drawn into whatever space the ranks happened to leave, which is
		# how labels come to sit on top of each other and on the arrowheads.
		#
		# Only when a label EXISTS -- an unlabelled diagram keeps exactly the
		# separation its author asked for.
		#
		# THE GAP MUST CARRY THE TALLEST LABEL, wrapped as it will be
		# drawn, with a clearance of line showing above and below it.
		# That is the other half of the Principal's rule: a label always
		# sits IN its line, never outside it, so the line it sits in has
		# to be longer than the label -- and since wrapping trades width
		# for height, the gap is where the height is paid. One number,
		# grown once, for every label in the picture.
		_bELab_ = 0
		_nLabH_ = 0
		_nLabW_ = 0
		for _e0_ in This.Edges()
			if StzTrim("" + _e0_[:label]) != ""
				_bELab_ = 1
				if isObject(_oFont_)
					_blk0_ = This._LabelBlock("" + _e0_[:label], _oFont_,
						_nFsz_, _nBoxW_)
					if _blk0_[3] > _nLabH_  _nLabH_ = _blk0_[3]  ok
					if _blk0_[2] > _nLabW_  _nLabW_ = _blk0_[2]  ok
				ok
			ok
		next
		# THE LABEL'S GAP DEMAND IS KEPT APART from the base separation,
		# because a gap only owes label room if a LABELLED edge actually
		# crosses it (the Principal's state machine: init's unlabelled
		# entry gap was as tall as the gap holding four labels, so the
		# picture opened with a dead vertical stretch and read as
		# "somehow scrambled"). _nSepLab_ is the labelled gap's height;
		# the natural branch applies it per gap, the fill branch -- which
		# stretches anyway -- keeps the old uniform maximum.
		_nSepLab_ = 0
		if _bELab_
			_nSepLab_ = max([ _nSepR_, _nFsz_ * 2 + 34 ])
			if _nLabH_ > 0
				# TWICE the label's room, because the label rides the
				# DROP and the drop is only half the gap: the channel
				# every fan shares sits at the middle of its rank gap, so
				# a gap that merely fits a label leaves a drop that fits
				# half of one. "Let the lines be longer" is this number.
				_nSepLab_ = max([ _nSepLab_,
					(_nLabH_ + max([ 14, _nRad_ * 2 + 4 ]) * 2) * 2 ])
			ok
			# ...but NOT for a MODE picture, whose vertical gaps carry one
			# transition each -- a one-way door out of a region -- rather
			# than a fan riding a shared channel. The doubled figure buys
			# a channel plus its drop; a single labelled drop needs the
			# label and its clearances, and the picture is 27% shorter
			# for saying so.
			if NOT _bNat_ and NOT _bModes_
				_nSepR_ = max([ _nSepR_, _nSepLab_ ])
			ok
			# A GAP PAYS FOR WHAT CROSSES IT, and in a mode picture what
			# crosses a gap is a transition BETWEEN modes. The peer
			# chords inside a region run sideways and carry the longest
			# labels in the machine -- pricing the vertical gap from
			# those bought height for words that never stand in it.
			if _bModes_
				_nMdLabH_ = 0
				if isObject(_oFont_)
					for _e0_ in This.Edges()
						if StzTrim("" + _e0_[:label]) = ""  loop  ok
						if This._ModeOfId("" + _e0_[:from]) =
						   This._ModeOfId("" + _e0_[:to])  loop  ok
						_blk1_ = This._LabelBlock("" + _e0_[:label],
							_oFont_, _nFsz_, _nBoxW_)
						if _blk1_[3] > _nMdLabH_  _nMdLabH_ = _blk1_[3]  ok
					next
				ok
				if _nMdLabH_ > 0
					_nSepR_ = max([ _nSepR_,
						_nMdLabH_ + max([ 14, _nRad_ * 2 + 4 ]) * 2 ])
				ok
			ok
			# ...AND THE PEER CHORD CARRIES ITS EVENT. Inside a region the
			# transitions run sideways between neighbours, so it is the
			# NODE separation that must be longer than what is written on
			# it -- the same rule the rank gap obeys, on the other axis.
			# Without it "EvNumLock" was drawn across the two cells it
			# joins.
			if _bModes_ and _nLabW_ > 0
				_nSepN_ = max([ _nSepN_,
					_nLabW_ + max([ 14, _nRad_ * 2 + 4 ]) * 2 ])
			ok
		ok

		# A GAP MUST BE CROSSABLE. A horizontal channel divides the rank
		# gap it runs in, and both halves have to stay comfortably visible
		# -- otherwise centring the channel has nothing to centre in, and
		# the line reads as touching the row above or the frame below
		# whatever the placement rule says. Two clearances plus the line
		# itself is the least that leaves a readable band on each side.
		# The same floor serves left-to-right, where the gap is horizontal
		# and the channel vertical: one rule, one axis-free statement.
		_nClr0_ = max([ 14, _nRad_ * 2 + 4 ])
		_nSepR_ = max([ _nSepR_, _nClr0_ * 2 + _nEdgeW_ * 2 ])
		# the floor a gap owes whatever crosses it -- kept apart from
		# the label demand, which is per gap and not per picture
		_nSepBase_ = _nClr0_ * 2 + _nEdgeW_ * 2

		# ...and clusters EAT the gap. A frame's top strip and padding live
		# inside the rank gap above its first member row, so a gap that
		# satisfies the floor on paper leaves a band narrower than one
		# clearance above the frame -- which is where the Principal found
		# a channel pinned against Web B with nowhere fair to stand. When
		# clusters exist, the gap must fund the chrome AND the crossable
		# band.
		# ...and asked of the SAME expression the boxes are drawn with,
		# never of a second estimate of it (see _ClusterChromeAbove).
		# ...ONCE, and not in a mode picture, which funds its regions'
		# chrome explicitly in its own derived size. Charged in both
		# places the entry gap came out three times what stands in it --
		# the "so tall" the Principal marked, and the third time this
		# session that one quantity was paid for twice.
		if len(@aClusters) > 0 and NOT _bModes_
			_nSepR_ = max([ _nSepR_,
				This._ClusterChromeAbove(_nFsz_) + _nClr0_ * 2 + _nEdgeW_ * 2 ])
		ok

		# A RING SIZES ITSELF FROM ITS CIRCUMFERENCE, and stays SQUARE:
		# _Normalise fits the layout's bounding box to the canvas, so a
		# non-square canvas would deliver the circle as an ellipse. The
		# radius is what makes adjacent cells clear each other -- the
		# circumference must hold every cell plus its separation -- and
		# the box adds a cell's width all round, for the outward
		# self-loops and the labels that ride the chords.
		# A MODE PICTURE SIZES ITSELF FROM ITS SHAPE: the widest rank in
		# states across, the mode depth down, plus the region chrome the
		# boundaries eat. Same contract as everywhere else -- spacing is
		# the contract, the size is derived -- applied to a layout whose
		# ranks are modes rather than states.
		if _bModes_ and NOT _bNamed_
			_nMdW_ = @nModeCols * _nBoxW_ +
				max([ @nModeCols - 1, 0 ]) * _nSepN_ + _mx_ * 2
			# A RANK PAYS FOR THE TALLEST THING STANDING IN IT. Every
			# rank was charged a full cell, including the ones holding
			# nothing but a mark a fifth that size.
			_nMdTall_ = 0
			for _nd4_ in This.Nodes()
				_b4_ = This._BoxOf("" + _nd4_[:id], _nBoxW_, _nBoxH_)
				if _b4_[2] > _nMdTall_  _nMdTall_ = _b4_[2]  ok
			next
			if _nMdTall_ <= 0  _nMdTall_ = _nBoxH_  ok
			# THE SIZE IS THE CONTENT, and the content is N rows plus the
			# N-1 gaps BETWEEN them -- not N gaps, and not N+1. Charging
			# a gap per row bought two gaps the picture has no room to
			# put anywhere, and the canvas then handed them to its own
			# margins: 104px of white above the entry mark, which is the
			# long vertical the Principal keeps marking. The layout is
			# told :Margin = 0 for the same reason -- the diagram adds
			# its own inset already, and two margin systems stacked is
			# how a picture grows a border nobody asked for.
			_nMdH_ = @nModeRows * _nMdTall_ +
				max([ @nModeRows - 1, 0 ]) * _nSepR_ + _my_ * 2
			# ...and the frame's own height sits in ITS row, counted once
			if len(@aClusters) > 0
				_nMdH_ += (This._ClusterChromeAbove(_nFsz_) +
					This._ClusterPadMax() +
					This._LaneOffset(max([ @nModeCols - 1, 1 ]), _nMdTall_) -
					_nMdTall_ / 2) * max([ @nModeRegionRows, 1 ])
			ok
			# region chrome is paid ONCE PER REGION ROW, not per rank: a
			# rank with no boundary in it eats none of it
			# chrome is paid ONCE PER REGION ROW: three regions side by
			# side (which is what concurrency looks like) eat one strip
			# between them, not three
			# CHROME IS COUNTED ONCE. The generic cluster floor above
			# already raises the rank separation to fund a frame's strip
			# and padding, and this added the same money again per
			# region row -- so the entry gap came out twice as deep as
			# anything stands in it, which is the "waste" he marked. The
			# frame's own body still has to be paid for, and that is the
			# padding, not the strip.
			# the frame's own width: its padding, the loops that radiate
			# out of its rightmost member, and the words beside them --
			# paid ONCE for the region, not once per column
			_nMdLoopW_ = 0
			if isObject(_oFont_)
				for _e5_ in This.Edges()
					if StzLower("" + _e5_[:from]) != StzLower("" + _e5_[:to])
						loop
					ok
					_l5_ = StzTrim("" + _e5_[:label])
					if _l5_ = ""  loop  ok
					_w5_ = _oFont_.WidthOf(_l5_, _nFsz_) + 14
					if _w5_ > _nMdLoopW_  _nMdLoopW_ = _w5_  ok
				next
			ok
			if 1 = 0
				# the frame's height is counted in its own row above, and
				# the inset holds its pad, its loop and the word beside
				_nMdH_ += (This._ClusterPadMax() * 2 +
					This._LineClearance() * (@nModeCols + 1)) *
					max([ @nModeRegionRows, 1 ])
			ok
			_nW_ = ceil(_nMdW_)
			_nH_ = ceil(_nMdH_)
			_bNamed_ = 1
			_nReqW_ = _nW_
			_nReqH_ = _nH_
		ok

		if _bRing_ and NOT _bNamed_
			_nRingN_ = max([ This.NumberOfNodes(), 3 ])
			_nRingR_ = _nRingN_ * (_nBoxW_ + _nSepN_) / 6.283185307179586
			# ...AND A CHORD MUST HOLD ITS EVENT. The shortest chord in a
			# ring is the radius -- centre to border, where a hub's
			# transitions run -- and BOTH members of an opposite pair
			# write their event on it. A circumference-sized radius left
			# 50px of visible line for two labels, so "open" and "close"
			# lay across the cells they join. The radius therefore also
			# clears both cells' halves plus two labels stacked with a
			# clearance each: the same "the line must be longer than
			# what is written on it" rule the rank gap already obeys,
			# stated in the ring's own geometry.
			if _nLabW_ > 0
				_nRingR_ = max([ _nRingR_,
					_nBoxW_ / 2 + _nBoxH_ / 2 +
					(_nLabW_ + This._LineClearance() * 2) * 2 ])
			ok
			_nRingSide_ = ceil(_nRingR_ * 2 + _nBoxW_ * 2 + _nSepN_ * 2)
			_nW_ = _nRingSide_
			_nH_ = _nRingSide_
			_bNamed_ = 1
			_nReqW_ = _nW_
			_nReqH_ = _nH_
		ok

		if _bNat_
			# any provisional size -- only the FRACTIONS of it are read back
			# LABELS STEER THE LAYOUT. Reserving gap HEIGHT gave a label
			# somewhere to be written; it did nothing about width, so two
			# edges running close together still fought over the same
			# horizontal space and the loser was nudged onto something
			# else. Nudging moves the label; only the layout can make
			# ROOM. A node whose incoming edge carries a label wider than
			# the node itself asks for the difference, and its whole rank
			# spreads to give it.
			_slot0_ = _nBoxW_
			if _bSwap_  _slot0_ = _nBoxH_  ok
			_slot0_ += _nSepN_
			_aXtra_ = This._LabelDemand(_oFont_, _nFsz_, _nBoxW_, _slot0_,
				_bSwap_)

			# the air a cluster boundary needs, in SLOT units, from the
			# pixels this face knows: a frame's own padding plus one line
			# clearance, over the slot it will be measured in
			_nAir_ = 0.55
			if len(@aClusters) > 0 and _slot0_ > 0
				_nAir_ = (This._ClusterPadMax() + This._LineClearance()) /
					_slot0_
			ok
			_oGC_ = new stzGraphCanvas(This, [
				:Layout = :Hierarchical,
				:Width = 1000, :Height = 700, :Margin = 0,
				:Clusters = This._ClusterPairs(),
				:NodeExtra = _aXtra_,
				:ClusterAir = _nAir_,
				:Pins = This._PinVector(),
				:Sources = This._KindedIds(This.NotationO().SourceKinds()),
				:Sinks = This._KindedIds(This.NotationO().SinkKinds())
			])
			# the layered crossing count of the order being drawn -- the
			# graph tier's structure fact, kept with the render's other
			# facts (node rects, cluster rects, claimed channels)
			@nRenderCrossings = _oGC_.LayoutCrossings()
			# slot and pitch along the LAYOUT axes; the boxes do not rotate
			# with the rank direction, so the box dimension that matters
			# swaps when the picture does
			_slotB_ = _nBoxW_
			_pitchB_ = _nBoxH_
			if _bSwap_
				_slotB_ = _nBoxH_
				_pitchB_ = _nBoxW_
			ok
			_slot_ = _slotB_ + _nSepN_
			_pitch_ = _pitchB_ + _nSepR_
			# unit-true x: 1.0 = one minimum separation, so span * slot IS
			# the content width. The ordinal fallback (a diagram with no
			# edges) is one even layer: n slots.
			if _oGC_.IsUnitX()
				_inX_ = _oGC_.RawSpanX() * _slot_
			else
				_inX_ = max([ 0, _nN_ - 1 ]) * _slot_
			ok
			# A RANK GAP MUST ANSWER TO THE SPAN IT IS CROSSED BY.
			#
			# An edge running far sideways over a shallow gap is nearly
			# HORIZONTAL, and a nearly horizontal edge in a layered
			# drawing travels along its target's rank -- grazing, and
			# often crossing, every node between. A broker fanning to
			# fourteen workers put fourteen near-flat lines across the
			# row: the attachment sides were right, the curve was right,
			# and the picture was still unreadable because 130px of gap
			# cannot absorb 4000px of fan.
			#
			# So the widest edge in the picture sets a floor under the
			# pitch. A tenth of the longest horizontal run is enough to
			# give every edge a visible descent; diagrams whose edges are
			# all short never reach the floor and keep exactly the
			# separation their author asked for.
			# PER RANK CROSSED, not per edge. Using an edge's whole
			# horizontal run made one long multi-rank edge inflate EVERY
			# gap in the picture -- a diagram with a single edge from top
			# to bottom grew until the guard scanning its pixels stopped
			# finishing. What decides whether an edge reads as flat is
			# its run divided by the number of gaps it descends through,
			# because that is the slope of each leg.
			# ASKED ONCE, AND LOWERED ONCE. This scanned
			# `_oGC_.Positions()` from inside a per-edge loop -- the
			# iterator form over a METHOD CALL, so the whole position
			# list was rebuilt for every step of every edge -- and
			# compared ids with four StzLower crossings per row. Ninety
			# nine edges over a hundred nodes came to forty thousand
			# engine crossings and a rebuilt list per comparison: 4.5
			# seconds of a 4.7 second picture, all of it in a loop whose
			# job is to find one number.
			#
			# The same graph drawn at a fixed size took 0.55s, because
			# the fixed path never enters this branch -- which is how the
			# cost hid: only pictures that size themselves paid it, and
			# those are the big ones.
			_maxdx_ = 0
			_nlay_ = _oGC_.LayerCount()
			_aPosL_ = []
			for _pL_ in _oGC_.Positions()
				_aPosL_ + [ StzLower("" + _pL_[1]), _pL_[2], _pL_[3] ]
			next
			_nPosL_ = len(_aPosL_)
			for _e2_ in This.Edges()
				_pa_ = 0  _pb_ = 0  _ya_ = 0  _yb_ = 0
				_bfa_ = 0  _bfb_ = 0
				_cFrL_ = StzLower("" + _e2_[:from])
				_cToL_ = StzLower("" + _e2_[:to])
				for _pi2_ = 1 to _nPosL_
					_p2_ = _aPosL_[_pi2_]
					if _p2_[1] = _cFrL_
						_pa_ = _p2_[2]  _ya_ = _p2_[3]  _bfa_ = 1
					but _p2_[1] = _cToL_
						_pb_ = _p2_[2]  _yb_ = _p2_[3]  _bfb_ = 1
					ok
					if _bfa_ and _bfb_  exit  ok
				next
				if _bfa_ and _bfb_
					_gaps2_ = fabs(_ya_ - _yb_) / 700 * max([ _nlay_ - 1, 1 ])
					if _gaps2_ < 1  _gaps2_ = 1  ok
					_dxe_ = fabs(_pa_ - _pb_) / 1000 * _inX_ / _gaps2_
					if _dxe_ > _maxdx_  _maxdx_ = _dxe_  ok
				ok
			next
			if _maxdx_ * 0.20 > _pitch_  _pitch_ = _maxdx_ * 0.20  ok

			# EACH GAP IS PRICED BY WHAT CROSSES IT. One uniform pitch made
			# the state machine's unlabelled entry gap as tall as the gap
			# carrying four event labels -- a dead stretch between the
			# initial dot and its first state, marked as "somehow
			# scrambled". A gap crossed by at least one labelled edge is
			# _nSepLab_ tall; every other gap keeps the base separation.
			# Cumulative heights replace L*pitch, and the same piecewise
			# map carries the route bends.
			_nlay2_ = _oGC_.LayerCount()
			_aGapSep_ = []
			for _gi_ = 1 to max([ _nlay2_ - 1, 1 ])  _aGapSep_ + _nSepR_  next
			if _nSepLab_ > _nSepR_ and _nlay2_ > 1
				# a node's layer, recovered from the provisional frame the
				# engine normalised into (rank rows are even there)
				_aLayOf_ = []
				for _pL2_ in _aPosL_
					_aLayOf_ + [ _pL2_[1],
						floor(_pL2_[3] / 700.0 * (_nlay2_ - 1) + 0.5) ]
				next
				for _e0_ in This.Edges()
					if StzTrim("" + _e0_[:label]) = ""  loop  ok
					_lu_ = -1  _lv_ = -1
					_cF0_ = StzLower("" + _e0_[:from])
					_cT0_ = StzLower("" + _e0_[:to])
					for _pL2_ in _aLayOf_
						if _pL2_[1] = _cF0_  _lu_ = _pL2_[2]  ok
						if _pL2_[1] = _cT0_  _lv_ = _pL2_[2]  ok
					next
					if _lu_ < 0 or _lv_ < 0 or _lu_ = _lv_  loop  ok
					for _gi_ = min([ _lu_, _lv_ ]) + 1 to max([ _lu_, _lv_ ])
						_aGapSep_[_gi_] = _nSepLab_
					next
				next
			ok
			# the fan floor raises every gap alike -- slope is slope
			for _gi_ = 1 to len(_aGapSep_)
				if _pitchB_ + _aGapSep_[_gi_] < _pitch_
					_aGapSep_[_gi_] = _pitch_ - _pitchB_
				ok
			next
			_aCumY_ = [ 0 ]
			for _gi_ = 1 to _nlay2_ - 1
				_aCumY_ + (_aCumY_[_gi_] + _pitchB_ + _aGapSep_[_gi_])
			next

			_inY_ = _aCumY_[ max([ _nlay2_, 1 ]) ]
			if _bSwap_
				_nW_ = ceil(_inY_ + 2 * _mx_)
				_nH_ = ceil(_inX_ + 2 * _my_)
			else
				_nW_ = ceil(_inX_ + 2 * _mx_)
				_nH_ = ceil(_inY_ + 2 * _my_)
			ok
			_aXY_ = []
			for _p_ in _oGC_.Positions()
				_px_ = _p_[2] / 1000 * _inX_
				_py_ = This._GapMapY(_p_[3], _nlay2_, _aCumY_)
				if _bSwap_
					_t_ = _px_
					_px_ = _py_
					_py_ = _t_
				ok
				if _cRank_ = "RL"  _px_ = _inY_ - _px_  ok
				if _cRank_ = "BT"  _py_ = _inY_ - _py_  ok
				_aXY_ + [ StzLower("" + _p_[1]), _px_ + _mx_, _py_ + _my_ ]
			next
			# the long edges' routes ride the SAME transform as the nodes --
			# one rule, so a route can never land in a different frame from
			# the boxes it joins
			for _r_ in _oGC_.EdgeRoutes()
				_rp_ = []
				for _bp_ in _r_[3]
					_px_ = _bp_[1] / 1000 * _inX_
					_py_ = This._GapMapY(_bp_[2], _nlay2_, _aCumY_)
					if _bSwap_
						_t_ = _px_
						_px_ = _py_
						_py_ = _t_
					ok
					if _cRank_ = "RL"  _px_ = _inY_ - _px_  ok
					if _cRank_ = "BT"  _py_ = _inY_ - _py_  ok
					_rp_ + [ _px_ + _mx_, _py_ + _my_ ]
				next
				_aRoute_ + [ StzLower("" + _r_[1]), StzLower("" + _r_[2]), _rp_ ]
			next

			# A CLUSTER IS BIGGER THAN ITS MEMBERS. Its box is padded and
			# carries a label ABOVE the topmost member, and the derived size
			# was computed from node centres alone -- so the "Data" box ran
			# off the bottom of its own picture, drawn correctly into space
			# that was never reserved. Deriving a size from content means
			# ALL the content, chrome included.
			# THE FRAME ASKS THE LANE PLAN HOW DEEP ITS RAILS RUN, so
			# the plan has to exist before the frame is measured -- and
			# this is the branch that measures it. Without this line the
			# frames on the natural-size path were sized against an
			# EMPTY plan and came out shorter than the rails they hold.
			@aDrawXY = _aXY_
			This._PlanRowLanes(_aXY_, _nBoxW_, _nBoxH_, _cRank_)
			_bChrome_ = len(@aClusters) > 0
			for _e0_ in This.Edges()
				if StzLower("" + _e0_[:from]) = StzLower("" + _e0_[:to])
					_bChrome_ = 1
					exit
				ok
			next
			# ...and a non-rectangular cell's label lives BELOW its glyph,
			# which is content too: a final state on the bottom rank would
			# otherwise have its name clipped by a canvas sized to boxes
			_bOutLb_ = 0
			if isObject(_oFont_)
				for _n0_ in This.Nodes()
					_cSh0_ = StzLower("" + This._NativeShapeOf(_n0_))
					for _cO0_ in [ "circle", "doublecircle", "dot",
						"diamond", "triangle", "invtriangle" ]
						if _cSh0_ = _cO0_  _bOutLb_ = 1  _bChrome_ = 1  exit  ok
					next
					if _bOutLb_  exit  ok
				next
			ok
			if _bChrome_
				# THE PAPER IS THE CONTENT, and seeding this from the
				# canvas is what stopped it being. Starting at [0,0,W,H]
				# meant the extent could only GROW, so a picture whose
				# rows collapsed into regions kept the height its layers
				# had asked for before the regions existed -- the three
				# switches were 539px tall over 276px of drawing, and
				# "space is optimised" had been said of exactly this.
				#
				# Seeded from the node boxes, every clause below still
				# grows it to cover loops, outside labels and frames, and
				# what is left over is white nobody drew on.
				_ex0_ = 1000000000  _ey0_ = 1000000000  _ex1_ = 0 - 1000000000  _ey1_ = 0 - 1000000000
				for _n1_ in This.Nodes()
					_at1_ = This._XYOf(_aXY_, "" + _n1_[:id])
					if len(_at1_) != 2  loop  ok
					_bb1_ = This._BoxOf("" + _n1_[:id], _nBoxW_, _nBoxH_)
					if _at1_[1] - _bb1_[1] / 2 < _ex0_
						_ex0_ = _at1_[1] - _bb1_[1] / 2
					ok
					if _at1_[2] - _bb1_[2] / 2 < _ey0_
						_ey0_ = _at1_[2] - _bb1_[2] / 2
					ok
					if _at1_[1] + _bb1_[1] / 2 > _ex1_
						_ex1_ = _at1_[1] + _bb1_[1] / 2
					ok
					if _at1_[2] + _bb1_[2] / 2 > _ey1_
						_ey1_ = _at1_[2] + _bb1_[2] / 2
					ok
				next
				if _ex1_ < _ex0_
					_ex0_ = 0  _ey0_ = 0  _ex1_ = _nW_  _ey1_ = _nH_
				ok

				# a self-loop reaches beyond its node, on the side the
				# drawing puts it
				_slr_ = This._SelfLoopReach(_nBoxW_, _nBoxH_) + 6
				for _e0_ in This.Edges()
					if StzLower("" + _e0_[:from]) != StzLower("" + _e0_[:to])
						loop
					ok
					_at_ = This._XYOf(_aXY_, "" + _e0_[:from])
					if len(_at_) != 2  loop  ok
					# ...and its LABEL sits BEYOND the loop, so the reach is
					# not the whole reservation. Reserving only the loop
					# clipped "retry" against the top edge of the picture --
					# the same shape as the loop bug itself, one layer out.
					_slx_ = _slr_
					if StzTrim("" + _e0_[:label]) != "" and isObject(_oFont_)
						_slx_ += _nFsz_ * 2
					ok
					# one side, one reservation: the loop lives on the
					# right border for every rank direction now
					_slw_ = 0
					if StzTrim("" + _e0_[:label]) != "" and isObject(_oFont_)
						_slw_ = _oFont_.WidthOf("" + _e0_[:label], _nFsz_) + 10
					ok
					if _at_[1] + _nBoxW_ / 2 + _slr_ + _slw_ > _ex1_
						_ex1_ = _at_[1] + _nBoxW_ / 2 + _slr_ + _slw_
					ok
				next

				if _bOutLb_
					for _n0_ in This.Nodes()
						_cSh0_ = StzLower("" + This._NativeShapeOf(_n0_))
						_bO0_ = 0
						for _cO0_ in [ "circle", "doublecircle", "dot",
							"diamond", "triangle", "invtriangle" ]
							if _cSh0_ = _cO0_  _bO0_ = 1  exit  ok
						next
						if NOT _bO0_  loop  ok
						_at0_ = This._XYOf(_aXY_, "" + _n0_[:id])
						if len(_at0_) != 2  loop  ok
						if _at0_[2] + _nBoxH_ / 2 + _nFsz_ * 2 > _ey1_
							_ey1_ = _at0_[2] + _nBoxH_ / 2 + _nFsz_ * 2
						ok
					next
				ok

				for _cl_ in @aClusters
					_cb_ = This._ClusterBox(_cl_, _aXY_, _nBoxW_, _nBoxH_)
					if len(_cb_) != 4  loop  ok
					# the label sits 24px above the box, matching the draw
					if _cb_[1] < _ex0_  _ex0_ = _cb_[1]  ok
					if _cb_[2] - _nFsz_ * 1.9 < _ey0_
						_ey0_ = _cb_[2] - _nFsz_ * 1.9
					ok
					if _cb_[1] + _cb_[3] > _ex1_  _ex1_ = _cb_[1] + _cb_[3]  ok
					if _cb_[2] + _cb_[4] > _ey1_  _ey1_ = _cb_[2] + _cb_[4]  ok
				next
				# ONE BORDER, ON ALL FOUR SIDES. The content is moved so
				# its own top-left lands on the border, whether it was
				# hanging off the paper or floating well inside it --
				# trimming only where it overflowed is what left 32px of
				# white on one side and 8 on the other.
				_nBor_ = 16
				_dx_ = _nBor_ - _ex0_
				_dy_ = _nBor_ - _ey0_
				if fabs(_dx_) > 0.001 or fabs(_dy_) > 0.001
					_moved_ = []
					for _p2_ in _aXY_
						_moved_ + [ _p2_[1], _p2_[2] + _dx_, _p2_[3] + _dy_ ]
					next
					_aXY_ = _moved_
					_movedR_ = []
					for _r2_ in _aRoute_
						_rp2_ = []
						for _bp2_ in _r2_[3]
							_rp2_ + [ _bp2_[1] + _dx_, _bp2_[2] + _dy_ ]
						next
						_movedR_ + [ _r2_[1], _r2_[2], _rp2_ ]
					next
					_aRoute_ = _movedR_
				ok
				_nW_ = ceil(_ex1_ + _dx_ + _nBor_)
				_nH_ = ceil(_ey1_ + _dy_ + _nBor_)
			ok

			# the named-size verdict: paper, or the fill path
			#
			# ...EXCEPT WHERE THE NAME WAS A PREDICTION. A modes picture
			# computes its size before it knows how the rows will fall,
			# and then the regions collapse ranks into single rows and
			# the prediction is simply too big. Padding back up to it
			# is how three switches came out 539px tall over 276px of
			# drawing. The prediction still buys the layout its working
			# space; the PAPER is what was measured.
			if _bNamed_ and _bModes_ and _bChrome_
				_bNamed_ = 0
			ok
			if _bNamed_
				if _nW_ <= _nReqW_ and _nH_ <= _nReqH_
					_nW_ = _nReqW_
					_nH_ = _nReqH_
				else
					# too big for the medium: the old fit applies whole,
					# and it reads the REQUESTED size, not the natural one
					# this attempt computed
					_bNat_ = 0
					_aRoute_ = []
					_nW_ = _nReqW_
					_nH_ = _nReqH_
				ok
			ok
		ok
		if NOT _bNat_
			_lw_ = _nW_ - 2 * _mx_
			_lh_ = _nH_ - 2 * _my_
			if _bSwap_
				_lw_ = _nH_ - 2 * _my_
				_lh_ = _nW_ - 2 * _mx_
			ok

			_oGC_ = new stzGraphCanvas(This, [
				:Layout = _cLM_,
				:Margin = iif(_bModes_, 0, 70),
				:Width  = max([ _lw_, 60 ]),
				:Height = max([ _lh_, 60 ]),
				:Clusters = This._ClusterPairs(),
				# ...AND THE PINS HERE TOO. This branch draws every
				# picture given an explicit :Width/:Height -- which is
				# every LIVE one, since a window has a size -- and it was
				# the one branch that never received them. Pins worked in
				# the guard, worked at natural size, and did nothing at
				# all in the editor they were built for.
				:Pins = This._PinVector(),
				:Sources = This._KindedIds(This.NotationO().SourceKinds()),
				:Sinks = This._KindedIds(This.NotationO().SinkKinds())
			])
			# the crossing count is a render fact on EVERY path, not only
			# the natural one -- a ring reaches the picture through here
			@nRenderCrossings = _oGC_.LayoutCrossings()

			_aXY_ = []
			for _p_ in _oGC_.Positions()
				_px_ = _p_[2]
				_py_ = _p_[3]
				if _bSwap_
					_t_ = _px_
					_px_ = _py_
					_py_ = _t_
				ok
				if _cRank_ = "RL"  _px_ = _lh_ - _px_  ok
				if _cRank_ = "BT"  _py_ = _lh_ - _py_  ok
				_aXY_ + [ StzLower("" + _p_[1]), _px_ + _mx_, _py_ + _my_ ]
			next
			# A ROW IS AS TALL AS WHAT STANDS IN IT, AND A GAP IS A GAP.
			#
			# This is the entry edge the Principal has now marked four
			# times, and every previous attempt trimmed the wrong number.
			# The layout spreads rank CENTRES evenly across whatever
			# height it is given, so EVERY pixel added to the total is
			# split between the gaps -- and a region's frame adds a lot:
			# its label strip above, its return lanes and padding below.
			# On the door that was 152px of frame, handed 76px each to
			# the gap above and the gap below, which is why the mark sat
			# 160px from the state it enters with nothing in between.
			#
			# A frame's height belongs to the ROW THAT HOLDS IT. So the
			# rows are re-placed here, cumulatively: each row is as tall
			# as the tallest thing standing in it -- plus, where a region
			# lives there, the frame drawn around it -- and between two
			# rows there is one separation and nothing else.
			@aDrawXY = _aXY_
			This._PlanRowLanes(_aXY_, _nBoxW_, _nBoxH_, _cRank_)
			for _mpass_ = 1 to 2
			if _bModes_
				_aRows_ = []
				for _xi_ = 1 to len(_aXY_)
					_bSeen_ = 0
					for _vr_ in _aRows_
						if fabs(_vr_ - _aXY_[_xi_][3]) < 2  _bSeen_ = 1  exit  ok
					next
					if NOT _bSeen_  _aRows_ + _aXY_[_xi_][3]  ok
				next
				_aRows_ = ring_sort(_aRows_)
				_nAt_ = _my_
				for _ri_ = 1 to len(_aRows_)
					# the tallest cell standing in this row
					_nTall_ = 0
					_bReg_ = 0
					for _xi_ = 1 to len(_aXY_)
						if fabs(_aXY_[_xi_][3] - _aRows_[_ri_]) > 2  loop  ok
						_bx_ = This._BoxOf(_aXY_[_xi_][1], _nBoxW_, _nBoxH_)
						if _bx_[2] > _nTall_  _nTall_ = _bx_[2]  ok
						for _clC_ in @aClusters
							for _clM_ in _clC_[:nodes]
								if StzLower("" + _clM_) = _aXY_[_xi_][1]
									_bReg_ = 1
								ok
							next
						next
					next
					if _nTall_ <= 0  _nTall_ = _nBoxH_  ok
					# THE OVERHANG IS MEASURED, NOT ESTIMATED. A formula
					# for how far a frame reaches above and below its row
					# has to predict the padding, the label strip, the
					# lanes and their labels -- and being wrong by 40px
					# put the exit edge at a third of the entry edge,
					# which is the inequality marked over and over. The
					# frame knows its own box; this asks it. Two passes,
					# because the box needs positions and the positions
					# need the box: place, measure, place again.
					_nAbove_ = 0
					_nBelow_ = 0
					if _bReg_
						_aBx_ = This._RowFrameBox(_aXY_, _aRows_[_ri_],
							_nBoxW_, _nBoxH_)
						if len(_aBx_) = 2
							_nAbove_ = _aBx_[1]
							_nBelow_ = _aBx_[2]
						else
							_nAbove_ = This._ClusterChromeAbove(_nFsz_)
							_nBelow_ = This._ClusterPadMax() +
								This._LaneOffset(max([ @nModeCols - 1, 1 ]),
									_nTall_) - _nTall_ / 2
						ok
					ok
					_nCy_ = _nAt_ + _nAbove_ + _nTall_ / 2
					for _xi_ = 1 to len(_aXY_)
						if fabs(_aXY_[_xi_][3] - _aRows_[_ri_]) > 2  loop  ok
						_aXY_[_xi_][3] = _nCy_
					next
					# ...AND THE GAP BELOW THIS ROW IS PRICED BY WHAT
					# CROSSES IT. Rows are placed explicitly now, so the
					# gaps no longer have to be equal -- and they should
					# not be: the entry gap on the door carries an
					# unlabelled edge and was paying for "demolish",
					# which crosses the gap two rows down. A gap holds
					# what stands in it.
					# ...AND EVERY GAP IN ONE PICTURE IS THE SAME GAP.
					# Pricing each gap by its own crossings shortened the
					# entry edge and made it a different length from the
					# exit edge -- which is I5: two gaps drawn differently
					# assert a difference, and between an entry and an
					# exit there is none. The price is taken over ALL the
					# crossings and paid to every gap. The entry edge
					# stays short, because the shortening came from
					# putting a frame in its own row, never from charging
					# the gaps unequally.
					_nGap_ = _nSepBase_
					if _ri_ < len(_aRows_) and isObject(_oFont_)
						for _e7_ in This.Edges()
							if StzTrim("" + _e7_[:label]) = ""  loop  ok
							_r7a_ = This._RowOfXY(_aXY_, _aRows_,
								"" + _e7_[:from])
							_r7b_ = This._RowOfXY(_aXY_, _aRows_,
								"" + _e7_[:to])
							if _r7a_ < 1 or _r7b_ < 1  loop  ok
							if _r7a_ = _r7b_  loop  ok
							_blk7_ = This._LabelBlock("" + _e7_[:label],
								_oFont_, _nFsz_, _nBoxW_)
							_nWant_ = _blk7_[3] +
								max([ 14, _nRad_ * 2 + 4 ]) * 2
							if _nWant_ > _nGap_  _nGap_ = _nWant_  ok
						next
					ok
					_nAt_ += _nAbove_ + _nTall_ + _nBelow_ + _nGap_
				next
			ok
			next

			# THE PAPER IS TRIMMED TO WHAT WAS DRAWN. The size above was
			# computed BEFORE the regions existed, from a layer count the
			# regions then collapse -- a prediction, and one that buys
			# the layout its working space honestly enough. It is not the
			# paper: three independent switch pairs came out 539px tall
			# over 276px of drawing, and "space is optimised" has been
			# said of exactly this. Measure, shift onto one border, trim.
			if _bModes_
				_aMx_ = This._ContentExtent(_aXY_, _nBoxW_, _nBoxH_,
					_oFont_, _nFsz_)
				if len(_aMx_) = 4
					_nBor2_ = 16
					_dx2_ = _nBor2_ - _aMx_[1]
					_dy2_ = _nBor2_ - _aMx_[2]
					if fabs(_dx2_) > 0.001 or fabs(_dy2_) > 0.001
						_mv2_ = []
						for _p3_ in _aXY_
							_mv2_ + [ _p3_[1], _p3_[2] + _dx2_,
								_p3_[3] + _dy2_ ]
						next
						_aXY_ = _mv2_
						_mr2_ = []
						for _r3_ in _aRoute_
							_rp3_ = []
							for _bp3_ in _r3_[3]
								_rp3_ + [ _bp3_[1] + _dx2_, _bp3_[2] + _dy2_ ]
							next
							_mr2_ + [ _r3_[1], _r3_[2], _rp3_ ]
						next
						_aRoute_ = _mr2_
					ok
					_nW_ = ceil(_aMx_[3] + _dx2_ + _nBor2_)
					_nH_ = ceil(_aMx_[4] + _dy2_ + _nBor2_)
				ok
			ok

			for _r_ in _oGC_.EdgeRoutes()
				_rp_ = []
				for _bp_ in _r_[3]
					_px_ = _bp_[1]
					_py_ = _bp_[2]
					if _bSwap_
						_t_ = _px_
						_px_ = _py_
						_py_ = _t_
					ok
					if _cRank_ = "RL"  _px_ = _lh_ - _px_  ok
					if _cRank_ = "BT"  _py_ = _lh_ - _py_  ok
					_rp_ + [ _px_ + _mx_, _py_ + _my_ ]
				next
				_aRoute_ + [ StzLower("" + _r_[1]), StzLower("" + _r_[2]), _rp_ ]
			next
		ok

		# THE BOXES MUST FIT THE RANK THEY LANDED IN. The layout spreads a rank
		# evenly across the available width and knows nothing about how wide a
		# node is drawn; the caller sets the box size and knows nothing about
		# how many nodes will share a rank. Neither side could see the
		# collision, so nothing prevented it: sixteen 96px nodes were placed
		# 82px apart in a 1400px picture and drawn ON TOP of one another --
		# found by rendering a 40-node tree and LOOKING at row five.
		#
		# dot solves this by growing the canvas. Ours is given, so the box
		# shrinks instead -- uniformly in both axes, because the node shapes are
		# drawn inside the box and squashing one axis alone deforms them (a
		# cylinder's cap stops being an ellipse in perspective). A caller who
		# genuinely wants the exact size it asked for, overlap included, passes
		# :FitBoxes = FALSE.
		if This._DiagOpt(paOptions, "fitboxes", 1)
			_nSc_ = This._RankFitScale(_aXY_, _nBoxW_, _nBoxH_)
			if _nSc_ < 1
				_nBoxW_ = max([ floor(_nBoxW_ * _nSc_), 6 ])
				_nBoxH_ = max([ floor(_nBoxH_ * _nSc_), 6 ])
				_nFsz_  = max([ floor(_nFsz_ * _nSc_), 5 ])
				_nRad_  = floor(_nRad_ * _nSc_)
			ok
		ok

		# A GPU TEXTURE HAS A MAXIMUM DIMENSION, and past it there is no
		# picture at all. wgpu's floor is 8192; a canvas wider than that
		# fails to allocate, the view is invalid, and the failure arrives
		# as a Rust panic from inside the driver -- no line of this
		# library in the trace and nothing naming the size that caused it.
		#
		# It is reachable by accident precisely because :Scale multiplies
		# a size the caller never typed: a 4064px diagram is fine and the
		# same diagram at :Scale = 3 is 12192 and cannot be drawn. So the
		# limit is checked HERE, where both numbers are known and can be
		# quoted back.
		# ...unless the caller is TILING, which is the honest answer to
		# this limit rather than a way around it. A tile is rendered
		# into a page-sized target, so the picture's own size never
		# has to be allocated at all -- and ToPages is exactly the
		# caller that never asks for it. Refusing here refused the
		# feature written to retire the refusal.
		if (_nW_ > 8192 or _nH_ > 8192) and
			NOT This._DiagOpt(paOptions, "tiled", 0)
			StzRaise("stzDiagram: this picture is " + _nW_ + "x" + _nH_ +
				", and a GPU texture cannot exceed 8192 in either axis. " +
				"At :Scale = " + _nScl_ + " the diagram's natural " +
				floor(_nW_ / _nScl_) + "x" + floor(_nH_ / _nScl_) +
				" is multiplied past that. Use a smaller :Scale, give " +
				"explicit :Width/:Height, answer ToSVG() -- which has no " +
				"such limit and stays sharp at every zoom -- or ToPages(), " +
				"which renders it a sheet at a time and never needs the " +
				"whole picture to exist.")
		ok

		# the edge geometry aims under the outline that is drawn, so it
		# needs the radius this render settled on -- after any fit scaling
		@nEdgeCornerRad = _nRad_

		_oC_ = new stzCanvas(_nW_, _nH_)
		# the paper's own edges, so a label placed beside its edge cannot
		# solve its crowding by stepping off the picture
		@nRenderW = _nW_
		@nRenderH = _nH_
		_oC_.SetBackground(_cBg_)

		# 1. CLUSTERS behind everything, each with its LABEL -- the box without
		#    the label is not what dot draws.
		#
		#    OUTERMOST FIRST, because each box is FILLED. In declaration
		#    order an outer cluster declared second painted its fill over
		#    the inner box that was already there, and the inner cluster
		#    vanished into it -- correct geometry, invisible result.
		#    _ClusterDepths sorts outermost first for exactly this.
		@aRenderClusRects = []
		@oLastFont = _oFont_
		@nLastFsz = _nFsz_
		This._SetLanePitch(_oFont_, _nFsz_, _nBoxW_)
		# hoisted above the loop: the rect capture below reads it, and in
		# Ring a method local read before its assigning statement is not
		# an error but a stale or empty value
		_clstrip_ = _nFsz_ * 1.9
		for _cd_ in This._ClusterDepths()
			_cl_ = This._ClusterById(_cd_[1])
			if len(_cl_) = 0  loop  ok
			_aBox_ = This._ClusterBox(_cl_, _aXY_, _nBoxW_, _nBoxH_)
			if len(_aBox_) != 4  loop  ok
			# NO NAME, NO STRIP. The band above a frame exists to carry
			# the frame's name; reserved unconditionally it became air
			# above the row that had no counterpart below it, and the
			# Principal drew the two distances on the traffic light to
			# say they were not the same. A frame's air is the same on
			# every side, and a strip nobody writes in is not air, it is
			# a reservation for something that never arrives.
			_clstrip_ = 0
			if StzTrim("" + _cl_[:label]) != ""
				_clstrip_ = _nFsz_ * 1.9
			ok
			_clids_ = []
			for _cm_ in _cl_[:nodes]  _clids_ + StzLower("" + _cm_)  next
			# the strip above the box belongs to the frame too -- the label
			# lives there, so a channel through it crosses the SURFACE
			@aRenderClusRects + [ _aBox_[1], _aBox_[2] - _clstrip_,
				_aBox_[3], _aBox_[4] + _clstrip_, _clids_ ]
			_oC_.Flush()
			# THE LABEL STRIP IS MEASURED FROM THE FONT, not a constant
			# (hoisted above the loop; history in the commit that sized it)
			# THE FRAME IS PAINTED IN ITS OWN COLOUR, not in a literal.
			# The fill was hard-coded #FFF8FE -- a pale pink that belongs
			# to no palette and answers to no theme, so a diagram whose
			# regions were declared Info.Surface still drew pink. A
			# cluster's colour is the tinted container; its rule is the
			# next step down, which the ramp already computes hue-stable.
			_cClFill_ = "" + _cl_[:color]
			_cClRule_ = _cClFill_
			if _cClFill_ = ""  _cClFill_ = "#FFF8FE"  ok
			_cClRule_ = StzColorAtLightness(_cClFill_, StzRoleStepL(:Border))
			_oC_.FillQ(_cClFill_).StrokeQ(_cClRule_, 2).
				AddRect(_aBox_[1], _aBox_[2] - _clstrip_, _aBox_[3],
					_aBox_[4] + _clstrip_)
			if isObject(_oFont_)
				# INSET FROM THE CORNER. At +10/-8 the label sat in the
				# angle of the frame with its ascenders touching the top
				# rule and its left edge on the side rule -- legible, and
				# visibly crammed. The inset scales with the font so it
				# stays proportional at any :Scale.
				_oC_.Flush()
				_oC_.AddTextQ("" + _cl_[:label],
					_aBox_[1] + _nFsz_ * 0.8,
					_aBox_[2] - _nFsz_ * 0.6).
					SetFontQ(_oFont_, _nFsz_ - 1).Color("#555555")
			ok
		next

		# 2. EDGES: clipped at the node boundary, routed in the requested
		#    spline style, and finished with an ARROWHEAD.
		#
		#    ROUTED, NOT JUST DRAWN. Every edge used to leave its node from
		#    the centre-line and cross the rank gap at the same middle
		#    height, so a parent's edges left as ONE line and split late,
		#    and two neighbouring parents' horizontal runs shared a channel
		#    and read as a crossing. Two disciplines fix both:
		#    - PORTS: a node's edges fan out from distinct points on its
		#      border, ordered by where they are going, so they never cross
		#      each other at birth.
		#    - LANES: each parent's orthogonal trunk crosses the rank gap at
		#      its own height, cycled among four, so neighbouring trunks do
		#      not overlap.
		@aChanUsed = []
		@aRenderNodeRects = []
		@aRenderLabels = []
		@aRenderNodeLabels = []
		@aRenderPicks = []
		# THE MAP BACK, fitted in the coordinates actually DRAWN. Pins
		# live in the layout's space and a cursor lives in pixels, so a
		# drag can only become a pin if the picture reads backwards.
		# The fit is linear -- the layout is scaled and shifted into the
		# paper and nothing else -- so two nodes with different raw x
		# determine it exactly. Fitted HERE and not against the
		# measuring canvas: that one is a provisional 1000x700 used to
		# size the picture, and its pixels are not these.
		@aSlotMap = []
		_aRawP_ = _oGC_.RawPositions()
		if len(_aRawP_) >= 2
			_sm1_ = []
			_sm2_ = []
			for _smK_ = 1 to len(_aRawP_)
				_smP_ = This._XYOf(_aXY_, "" + _aRawP_[_smK_][1])
				if len(_smP_) != 2  loop  ok
				if len(_sm1_) = 0
					_sm1_ = [ _aRawP_[_smK_][2], _smP_[1] ]
				but fabs(_aRawP_[_smK_][2] - _sm1_[1]) > 0.0001
					_sm2_ = [ _aRawP_[_smK_][2], _smP_[1] ]
					exit
				ok
			next
			if len(_sm2_) = 2
				_smB_ = (_sm2_[2] - _sm1_[2]) / (_sm2_[1] - _sm1_[1])
				@aSlotMap = [ _sm1_[2] - _smB_ * _sm1_[1], _smB_ ]
			ok
		ok
		@oLastCanvas = _oC_
		This._FillBoxSizes(_nBoxW_, _nBoxH_)
		for _nr_ in _aXY_
			_aRb_ = This._BoxOf("" + _nr_[1], _nBoxW_, _nBoxH_)
			@aRenderNodeRects + [ _nr_[2] - _aRb_[1] / 2, _nr_[3] - _aRb_[2] / 2,
				_aRb_[1], _aRb_[2], StzLower("" + _nr_[1]) ]
		next

		_aE_ = This.Edges()
		_nEc_ = len(_aE_)
		@aSameRowLanes = []
		This._FillBoxSizes(_nBoxW_, _nBoxH_)
		_aPort_ = This._EdgePorts(_aE_, _aXY_, _nBoxW_, _nBoxH_, _cRank_, _aRoute_)

		# A PORT IS A POSITION ON A BORDER, so it is clamped to the border
		# it sits on -- and to the node's OWN border, not the picture's
		# cell. Two edges arriving at a MARK were spread across a full
		# cell's width, and the outer one dropped beside the mark with its
		# arrow pointing at paper. Clamped here, where the values are
		# made, because the ortho staircase reads them directly to choose
		# its arrival column and never passes through _PortPoint.
		# A SURFACE TOO SMALL FOR PORTS TAKES NONE -- the Principal's
		# rule, and it is I2 finishing a sentence it had already begun.
		# Ports exist so a node's edges leave from distinct places and
		# never cross at birth; a MARK has no distinct places, so
		# spreading its edges over a 17px circle draws several lines
		# grazing one dot instead of one line arriving at it. Edges
		# sharing an endpoint may share ink -- that is the blessed merge
		# -- so at a mark they MUST: every edge takes the centre, and the
		# picture shows one stem that splits (or converges) away from the
		# mark, where there is room for the split to be read.
		#
		# For an ordinary cell the port still spreads, clamped to the
		# node's OWN border rather than the picture's cell.
		for _pcI_ = 1 to len(_aPort_)
			_pcA_ = This._BoxOf("" + _aE_[_pcI_][:from], _nBoxW_, _nBoxH_)
			_pcB_ = This._BoxOf("" + _aE_[_pcI_][:to], _nBoxW_, _nBoxH_)
			if _pcA_[1] < _nBoxW_ - 0.5 or _pcA_[2] < _nBoxH_ - 0.5
				_aPort_[_pcI_][1] = 0
			else
				_pcLa_ = max([ _pcA_[1], _pcA_[2] ]) * 0.34
				if _aPort_[_pcI_][1] > _pcLa_   _aPort_[_pcI_][1] = _pcLa_   ok
				if _aPort_[_pcI_][1] < 0 - _pcLa_  _aPort_[_pcI_][1] = 0 - _pcLa_  ok
			ok
			if _pcB_[1] < _nBoxW_ - 0.5 or _pcB_[2] < _nBoxH_ - 0.5
				_aPort_[_pcI_][2] = 0
			else
				_pcLb_ = max([ _pcB_[1], _pcB_[2] ]) * 0.34
				if _aPort_[_pcI_][2] > _pcLb_   _aPort_[_pcI_][2] = _pcLb_   ok
				if _aPort_[_pcI_][2] < 0 - _pcLb_  _aPort_[_pcI_][2] = 0 - _pcLb_  ok
			ok
		next

		# AN OPPOSITE PAIR IS ONE CONVERSATION, DRAWN AS TWO PARALLEL
		# LANES -- the state machine's convention, ruled by the Principal
		# when open/close and lock/unlock came out as tree edges plus
		# long detour channels and the middle of the picture scrambled.
		# A->B and B->A are the same relationship read both ways, so the
		# RETURN edge mirrors its partner's exact path, offset one
		# clearance -- two rails, unmistakably one pair, and the return
		# never wanders through foreign channels. The downward edge (the
		# rank-forward one) is the CANONICAL path; its twin is derived.
		_aTwinOf_ = []
		_aPairSide_ = []
		for _ti_ = 1 to _nEc_  _aTwinOf_ + 0  _aPairSide_ + 0  next
		if 1 = 1
			for _ti_ = 1 to _nEc_
				_cTf_ = StzLower("" + _aE_[_ti_][:from])
				_cTt_ = StzLower("" + _aE_[_ti_][:to])
				if _cTf_ = _cTt_  loop  ok
				for _tj_ = 1 to _nEc_
					if _tj_ = _ti_  loop  ok
					if StzLower("" + _aE_[_tj_][:from]) = _cTt_ and
					   StzLower("" + _aE_[_tj_][:to]) = _cTf_
						# the pair found: the rank-forward member is
						# canonical, the other is its twin
						_aTa_ = This._XYOf(_aXY_, _cTf_)
						_aTb_ = This._XYOf(_aXY_, _cTt_)
						if len(_aTa_) = 2 and len(_aTb_) = 2
							# ON A RING there is no forward: both members
							# are chords of equal standing, so each takes
							# its own side of the line they share.
							if _bRing_
								_aPairSide_[_ti_] = iif(_ti_ < _tj_, 1, -1)
							else
								_nTfw_ = _aTb_[2] - _aTa_[2]
								if _bSwap_  _nTfw_ = _aTb_[1] - _aTa_[1]  ok
								if _nTfw_ < 0 or (_nTfw_ = 0 and _ti_ > _tj_)
									if _cSpl_ = "ortho"
										_aTwinOf_[_ti_] = _tj_
									else
										_aPairSide_[_ti_] = -1
									ok
								but _cSpl_ != "ortho"
									_aPairSide_[_ti_] = 1
								ok
							ok
						ok
					ok
				next
			next
		ok
		# TWO PASSES under ortho: the first draws nothing and learns every
		# rank-axis segment; the second draws with wire hops over the
		# crossings the first pass revealed. One pass cannot hop a line
		# that has not been drawn yet.
		# THE DRAWERS NEED TO KNOW WHO ELSE IS ON THE ROW. An edge
		# joining two peers may only keep the row if the row between
		# them is EMPTY -- see _SomethingBetween(). Without the
		# positions here, that question cannot be asked, and a peer
		# edge was drawn straight through whatever stood in the way.
		@aDrawXY = _aXY_
		This._PlanRowLanes(_aXY_, _nBoxW_, _nBoxH_, _cRank_)
		_nPassN_ = 1
		if _cSpl_ = "ortho"  _nPassN_ = 2  ok
		for _ePass_ = 1 to _nPassN_
		if _cSpl_ = "ortho"
			@nDrawPass = _ePass_
			@aChanUsed = []
			if _ePass_ = 1
				@aVertSegs = []
				@aEdgePaths = []
			ok
		else
			@nDrawPass = 2
		ok
		for _ei_ = 1 to _nEc_
			_a_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:from])
			_b_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:to])
			if len(_a_) != 2 or len(_b_) != 2  loop  ok

			# A SELF-LOOP IS A LOOP, not a line of length zero. Both ends
			# clip to the same point, so the generic path drew nothing at
			# all and a state machine's "stay here" arrow was simply absent
			# from the picture -- the most complete kind of rendering bug,
			# because there is nothing wrong to notice.
			# an edge answers as itself, above the node tags because
			# tags are recorded once and edges are drawn before nodes:
			# the ranges never overlap
			if @nDrawPass = 2
				_oC_.SetPickTag(1000000 + _ei_)
				@aRenderPicks + [ 1000000 + _ei_, "edge",
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to] ]
			ok

			if StzLower("" + _aE_[_ei_][:from]) = StzLower("" + _aE_[_ei_][:to])
				if @nDrawPass = 2
					# ON A RING a self-loop radiates OUTWARD, away from
					# the space -- inward it would cross the very chords
					# it sits among. The rank direction handed to the
					# loop drawer is what chooses its side, so the
					# outward quadrant is named in those terms.
					_cLoopDir_ = _cRank_
					if _bRing_
						_cLoopDir_ = This._RingOutward(_a_, _nW_, _nH_)
					ok
					@cSelfLoopId = StzLower("" + _aE_[_ei_][:from])
					This._DrawSelfLoop(_oC_, _a_, _nBoxW_, _nBoxH_, _cEdge_,
						_nEdgeW_, _cLoopDir_, _cSpl_)
				ok
				loop
			ok

			# a return edge is drawn FROM its partner's path, after the
			# partner exists -- see the twin block after this loop
			if _aTwinOf_[_ei_] > 0 and
			   This._TwinIsPlain("" + _aE_[_ei_][:from],
				"" + _aE_[_ei_][:to])  loop  ok

			# THE PORT IS APPLIED AT THE BOUNDARY, not to the centre.
			# It used to shift the node's CENTRE and then clip a box
			# around the shifted point -- a box that is not where the node
			# is. For a near-vertical edge that happened to land on the
			# real bottom edge and looked fine; for anything more sideways
			# the exit point sat off the node entirely, which is the
			# "edges leaving from nowhere" in a wide fan-out. _PortPoint
			# puts it on the real boundary, on the side the rank runs.
			# A PAIR SEPARATES ON A CHORD TOO. Under ortho the return is
			# its partner's path offset a clearance (the twin block
			# below); a straight chord has no path to mirror, so both
			# members simply step half a clearance to their own side of
			# the line they share -- symmetric rails, which is how every
			# statechart draws a two-way transition.
			if _aPairSide_[_ei_] != 0
				# the coordinates are read into NUMBERS before any method
				# call: a Ring helper's locals can reach back into this
				# scope, and rebuilding _a_ from itself after calling one
				# is exactly where that bites
				_pax_ = _a_[1]  _pay_ = _a_[2]
				_pbx_ = _b_[1]  _pby_ = _b_[2]
				# THE PERPENDICULAR IS TAKEN FROM A CANONICAL DIRECTION,
				# never from the edge's own: the two members of a pair
				# run opposite ways, so a perpendicular computed per
				# edge flips with it and both members step the SAME way
				# -- they overlapped instead of separating, which is
				# what the crossed rails in the first ring were. The
				# member the pair named FIRST defines the direction for
				# both, so the two sides are genuinely opposite sides of
				# one line.
				_pdx_ = _pbx_ - _pax_
				_pdy_ = _pby_ - _pay_
				if _aPairSide_[_ei_] < 0
					_pdx_ = 0 - _pdx_
					_pdy_ = 0 - _pdy_
				ok
				_pln_ = sqrt(_pdx_*_pdx_ + _pdy_*_pdy_)
				_pclr_ = This._LineClearance()
				if _pln_ > 0.001
					_poff_ = _pclr_ * _aPairSide_[_ei_]
					_pox_ = 0 - _pdy_ / _pln_ * _poff_
					_poy_ = _pdx_ / _pln_ * _poff_
					_a_ = [ _pax_ + _pox_, _pay_ + _poy_ ]
					_b_ = [ _pbx_ + _pox_, _pby_ + _poy_ ]
				ok
			ok

			_aBend_ = This._RouteOf(_aRoute_, "" + _aE_[_ei_][:from],
				"" + _aE_[_ei_][:to])
			if len(_aBend_) > 0
				This._DrawRoutedEdge(_oC_, _a_, _b_, _aBend_, _nBoxW_,
					_nBoxH_, _cEdge_, _nEdgeW_, _cSpl_, _cRank_,
					_aPort_[_ei_][1], _aPort_[_ei_][2], _aPort_[_ei_][5],
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to])
			else
				This._DrawEdgeXT(_oC_, _a_, _b_, _nBoxW_, _nBoxH_, _cEdge_,
					_nEdgeW_, _cSpl_, _cRank_, _aPort_[_ei_][3],
					_aPort_[_ei_][1], _aPort_[_ei_][2], _aPort_[_ei_][5],
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to],
					_aPort_[_ei_][6])
			ok
		next

		# THE TWINS, after every canonical path exists in @aEdgePaths.
		#
		# ONE LANE EACH, and this is I2 said for the third time: distinct
		# channels, spaced a clearance apart. Every return took the SAME
		# single-clearance offset, so two returns into one state -- close
		# and unlock, in a machine with three peers -- were drawn on top
		# of each other under the forward line, and their labels fought
		# over the strip between. The Principal redrew one of them lower
		# by hand, which is the allocation this loop should have been
		# doing: the Nth return in a row rides the Nth lane.
		_nTwLane_ = 0
		_aTwRow_ = []
		for _ei_ = 1 to _nEc_
			if _aTwinOf_[_ei_] = 0  loop  ok
			if NOT This._TwinIsPlain("" + _aE_[_ei_][:from],
				"" + _aE_[_ei_][:to])  loop  ok
			if @nDrawPass = 2
				_oC_.SetPickTag(1000000 + _ei_)
				@aRenderPicks + [ 1000000 + _ei_, "edge",
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to] ]
			ok
			# WHICH LANE -- asked of the ONE allocator, so a return
			# and a step-aside edge on the same stretch of row cannot
			# be handed the same depth. Counting twins privately was
			# how "resume" and "stop" ended up drawn on one line with
			# their two words fighting over it.
			# ...OF THE MEMBER THAT ACTUALLY TAKES ONE. A pair keeps the
			# row with its forward member and steps aside with its
			# return, so the depth to draw at is the RETURN's lane --
			# whichever of the two that is.
			_nTwLane_ = This._LaneKept(
				StzLower("" + _aE_[_ei_][:from]) + ">" +
				StzLower("" + _aE_[_ei_][:to]))
			if _nTwLane_ < 1
				_nTwLane_ = This._LaneKept(
					StzLower("" + _aE_[_aTwinOf_[_ei_]][:from]) + ">" +
					StzLower("" + _aE_[_aTwinOf_[_ei_]][:to]))
			ok
			if _nTwLane_ < 1  _nTwLane_ = 1  ok
			This._DrawTwinEdgeXT(_oC_, _ei_, _aTwinOf_[_ei_], _aE_, _aXY_,
				_nBoxW_, _nBoxH_, _cEdge_, _nEdgeW_, _cRank_, _nTwLane_)
		next
		next

		# 2b. EDGE LABELS, drawn LAST of the edge work and on a plate of the
		#     background colour.
		#
		#     They were in the model, they reached the dot writer, and this
		#     tier simply never drew them -- an edge that said "fails check"
		#     in the data was an anonymous arrow in the picture, which is
		#     the difference between a diagram and a decoration.
		#
		#     The plate is not decoration either: a label sits ON its own
		#     edge, and dark text crossed by a grey line at x-height is
		#     genuinely hard to read. dot draws labels over a filled box for
		#     the same reason.
		if isObject(_oFont_) and _bELab_
			_aLabAt_ = []
			for _ei_ = 1 to _nEc_
				_cLab_ = StzTrim("" + _aE_[_ei_][:label])
				if _cLab_ = ""  loop  ok
				_a_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:from])
				_b_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:to])
				if len(_a_) != 2 or len(_b_) != 2  loop  ok

				_bSelf_ = 0
				if StzLower("" + _aE_[_ei_][:from]) =
				   StzLower("" + _aE_[_ei_][:to])  _bSelf_ = 1  ok

				if _bSelf_
					# BESIDE the loop, and CLEAR of it. The anchor is the
					# label's centre, so placing it a few pixels past the
					# loop's outer edge put half the plate ON the loop --
					# which, being background-coloured, erased the segment
					# it covered. Under ortho that was the whole right side
					# of the rectangle, so the loop read as two stray
					# horizontal lines. Offset by half the label's own
					# width, which is the only number that clears it.
					_lr_ = This._SelfLoopReach(_nBoxW_, _nBoxH_)
					_slw2_ = _oFont_.WidthOf(_cLab_, _nFsz_) + 8
					# BESIDE THE LOOP'S OWN SIDE. The loop's side is no
					# longer a function of the rank direction alone (the
					# ring radiates outward, the lifecycle keeps every
					# loop on the right), so the label reads the DRAWN
					# path and stands off its outer extreme -- the same
					# "follow the ink, never the assumption" rule as
					# every other label.
					_slK2_ = StzLower("" + _aE_[_ei_][:from] + ">" +
						"" + _aE_[_ei_][:to])
					_slP2_ = []
					for _pp2_ in @aEdgePaths
						if StzLower("" + _pp2_[1]) = _slK2_
							_slP2_ = _pp2_[2]
						ok
					next
					if len(_slP2_) >= 4
						_sbx_ = 0  _sby_ = 0
						for _sq2_ = 1 to len(_slP2_) - 1 step 2
							_sbx_ += _slP2_[_sq2_]
							_sby_ += _slP2_[_sq2_ + 1]
						next
						_sbx_ = _sbx_ / (len(_slP2_) / 2)
						_sby_ = _sby_ / (len(_slP2_) / 2)
						_sdx2_ = _sbx_ - _a_[1]
						_sdy2_ = _sby_ - _a_[2]
						if fabs(_sdx2_) >= fabs(_sdy2_)
							_lax_ = _a_[1] +
								iif(_sdx2_ >= 0,
									_nBoxW_ / 2 + _lr_ + _slw2_ / 2 + 6,
									0 - _nBoxW_ / 2 - _lr_ - _slw2_ / 2 - 6)
							_lay_ = _a_[2]
						else
							_lax_ = _a_[1]
							_lay_ = _a_[2] +
								iif(_sdy2_ >= 0,
									_nBoxH_ / 2 + _lr_ + _nFsz_,
									0 - _nBoxH_ / 2 - _lr_ - _nFsz_)
						ok
					else
						_lax_ = _a_[1] + _nBoxW_ / 2 + _lr_ +
							_slw2_ / 2 + 6
						_lay_ = _a_[2]
					ok
				else
					# under ORTHO the drawn path was captured on the dry
					# pass; the placer walks IT, so the label is deferred
					# to the placement loop with its key
					_cLKey_ = ""
					if _cSpl_ = "ortho"
						_cLKey_ = "" + _aE_[_ei_][:from] + ">" +
							"" + _aE_[_ei_][:to]
					ok
					_aBend_ = This._RouteOf(_aRoute_, "" + _aE_[_ei_][:from],
						"" + _aE_[_ei_][:to])
					if len(_aBend_) > 0
						# a routed edge is labelled where it actually runs,
						# not on the straight line it never takes
						_mid_ = _aBend_[ ceil(len(_aBend_) / 2) ]
						_lax_ = _mid_[1]
						_lay_ = _mid_[2]
					else
						# BIASED TOWARDS THE TARGET, not the midpoint.
						# Widening a rank spreads the CHILDREN; the
						# midpoints of a fan-out stay bunched near the
						# parent however far apart the children get, so
						# labels placed at 0.5 crowded exactly where the
						# extra room was not. At the shared bias they
						# inherit the spread the layout just paid for.
						#
						# ON the real path, CENTRED, on its plate. A
						# beside-the-line placement was tried for dot
						# parity and reverted the same day: shifted half
						# its width toward the target, a label on a
						# rightward edge reached the NEXT edge's arrowhead
						# -- it traded a plate over its own stroke for ink
						# over somebody else's. The plate erases a few
						# pixels of the line it names, which is the
						# cheaper of the two collisions and the one dot's
						# own label boxes accept too.
						_lat_ = This._EdgePathAt(_a_, _b_, _nBoxW_,
							_nBoxH_, _cRank_, This._EdgeLabelBias(),
							_aPort_[_ei_][1], _aPort_[_ei_][2],
							_aPort_[_ei_][5])
						_lax_ = _lat_[1]
						_lay_ = _lat_[2]
					ok
				ok
				# THE LOOP'S LABEL CARRIES ITS EDGE'S KEY TOO. It was
				# blanked, so nothing could relate the word to the ink it
				# names -- no instrument, and no reader of the render
				# facts. The loop publishes its path like any edge now,
				# so its label is keyed like any label; the 5th field
				# keeps the PLACER off it, because a loop's label is
				# positioned against the loop's own side and not by
				# walking a staircase.
				_aLabAt_ + [ _cLab_, _lax_, _lay_,
					StzLower("" + _aE_[_ei_][:from] + ">" +
						"" + _aE_[_ei_][:to]), _bSelf_ ]
			next

			# A LABEL MUST CLAIM ITS EDGE -- I1 for text. The old nudge
			# pushed an overlapping label blindly down the rank axis: it
			# cleared the other LABELS and ignored all the INK, so a label
			# could float in empty space attributed to nothing, or sit on
			# a foreign edge whose line its background plate then ERASED.
			# Under ortho the placer now walks the label's OWN drawn path
			# and takes the first anchor whose plate clears foreign ink,
			# placed labels, and node boxes -- moving ALONG the edge it
			# names, never off it. The plate erasing a few pixels of its
			# own stroke stays the accepted cost; erasing anyone else's is
			# a false picture.
			_aDone_ = []
			for _li_ = 1 to len(_aLabAt_)
				_cLab_ = _aLabAt_[_li_][1]
				_aBlk_ = This._LabelBlock(_cLab_, _oFont_, _nFsz_,
					_nBoxW_)
				_aLines_ = _aBlk_[1]
				_lw_ = _aBlk_[2]
				_lh_ = _aBlk_[3]
				_lx_ = _aLabAt_[_li_][2]
				_ly_ = _aLabAt_[_li_][3]
				_cLK_ = "" + _aLabAt_[_li_][4]
				_aPth_ = []
				if _cLK_ != ""
					for _pp_ in @aEdgePaths
						if _pp_[1] = _cLK_
							_aPth_ = _pp_[2]
							exit
						ok
					next
				ok
				if _aLabAt_[_li_][5]  _aPth_ = []  ok
				if len(_aPth_) >= 4
					# ON THE LINE ONLY WHERE THE LINE CAN HOLD IT, and
					# BESIDE it otherwise -- the Principal's rule for the
					# labelled fan, where two labels sat on a bus barely
					# their own width long and read as a bar laid over it.
					# A label centred on a segment hides the middle of
					# that segment; that only reads as a LABELLED LINE if
					# line still shows on both sides, so a segment must be
					# the label's length plus a clearance each side to
					# carry one. Shorter segments -- the drops of a fan --
					# take the label BESIDE them, offset perpendicular,
					# where it needs no line length at all and its nearest
					# ink is still its own edge.
					#
					# Segments are tried from the TARGET end backwards, so
					# a label inherits the spread of the children rather
					# than crowding the shared trunk they all leave from.
					# ON EVERY SEGMENT THAT CAN CARRY IT FIRST, beside
					# only when none can. Ordering the two kinds per
					# segment instead put a label beside a short drop
					# while its own long run stood empty two segments
					# away -- the fallback winning over the answer.
					_nClr2_ = This._LineClearance()
					_aOn_ = []
					_aBes_ = []
					# THREE STANDS PER SEGMENT, not one. The midpoint was
					# the only candidate, and the lifecycle template made
					# that a dead end: two returns lawfully share the
					# funnel lane into one target, and a drop crosses the
					# run at its exact middle -- every midpoint candidate
					# touched ink, and the least-bad rule put "unlock" ON
					# a line it does not name. A label can SLIDE along
					# its own segment; the middle is only the first seat
					# it tries.
					# CENTRED ON THE FULL EDGE, not on a segment of it.
					# The candidates used to be the middle of each
					# SEGMENT, so a three-legged return was labelled at
					# the middle of whichever leg the placer reached
					# first -- never at the middle of the journey. The
					# fractions below are of the PATH's own length, and
					# the point at each fraction is found by walking the
					# legs, so 0.5 means what a reader means by it.
					for _sfr_ in [ 0.5, 0.42, 0.58, 0.32, 0.68, 0.22, 0.78 ]
						_aAt_ = This._PointAlong(_aPth_, _sfr_)
						if len(_aAt_) != 4  loop  ok
						_smx_ = _aAt_[1]
						_smy_ = _aAt_[2]
						_sdx_ = _aAt_[3]
						_sdy_ = _aAt_[4]
						if 1 = 1
							if _sdx_ >= _sdy_
								# a horizontal run carries the label only
								# if it is longer than the label plus a
								# clearance of line showing at each end
								if _sdx_ >= _lw_ + _nClr2_ * 2
									_aOn_ + [ _smx_, _smy_ ]
								ok
								if _sdx_ >= 8
									_aBes_ + [ _smx_, _smy_ - _lh_ / 2 - _nClr2_ * 0.25 ]
									_aBes_ + [ _smx_, _smy_ + _lh_ / 2 + _nClr2_ * 0.25 ]
								ok
							else
								if _sdy_ >= _lh_ + _nClr2_ * 2
									_aOn_ + [ _smx_, _smy_ ]
								ok
								if _sdy_ >= 8
									_aBes_ + [ _smx_ - _lw_ / 2 - _nClr2_ * 0.25, _smy_ ]
									_aBes_ + [ _smx_ + _lw_ / 2 + _nClr2_ * 0.25, _smy_ ]
								ok
							ok
						ok
					next
					# ON THE LINE where the line can hold it -- and NEVER at
					# the price of another line's meaning. The Principal's
					# second ruling, from the state machine's "unlock": the
					# best ON spot sat beside two foreign drops, and a label
					# that stands against ink it does not name has CACHED the
					# meaning of a connection -- the reader cannot tell which
					# line is being spoken about. So a spot within the
					# clearance of FOREIGN ink is not a candidate that scored
					# poorly; it is not an answer at all. BESIDE spots are in
					# the same race now, after the ON spots, and only when NO
					# spot anywhere clears the bar does the least-bad one win
					# -- a crowded picture still labels every edge.
					# BESIDE THE LINE, ALWAYS, AND AT ONE DISTANCE. Two
					# rulings met here. A label ON its line needs a plate,
					# and the plate ERASES the line it sits on -- the
					# notch the Principal circled under "close". And with
					# ON and BESIDE both in play, one event sat above its
					# run and the next sat on its own, so the picture had
					# two conventions and the reader had to learn both.
					#
					# Beside-placement satisfies the older ruling too: the
					# label is still centred ALONG its line, which is what
					# "in the middle of the line, not outside it" asks --
					# it just does not stand ON the ink. The ON candidates
					# remain as the last resort for an edge whose every
					# segment is too short to carry a word beside it.
					#
					# ...AND THE AUTHOR MAY ASK FOR THE OTHER ONE.
					# :LabelPlacement = :Middle puts every event ON the
					# middle of its own line, on a plate of whatever
					# surface it covers -- paper, or a region's tint --
					# so the word reads as sitting on top of the line
					# rather than beside it. Both orders are legible and
					# they say slightly different things: BESIDE keeps
					# the line unbroken, ON binds the word to the line
					# past any doubt about which line it belongs to. The
					# Principal asked for the second where several
					# events run close together, and it is a dial
					# because the answer depends on the picture.
					_aCand_ = []
					if @cLabelPlacement = "middle"
						for _cOn_ in _aOn_   _aCand_ + _cOn_   next
						for _cBe_ in _aBes_  _aCand_ + _cBe_   next
					else
						for _cBe_ in _aBes_  _aCand_ + _cBe_   next
						for _cOn_ in _aOn_   _aCand_ + _cOn_   next
					ok
					_nBestD_ = -1
					_nBestX_ = _lx_
					_nBestY_ = _ly_
					for _cd_ in _aCand_
						_nD_ = This._LabelSpotScore(_cd_[1], _cd_[2], _lw_,
							_lh_, _cLK_, _aDone_)
						if _nD_ < 0  loop  ok
						if _nD_ >= _nClr2_ * 0.6
							_nBestD_ = _nD_
							_nBestX_ = _cd_[1]
							_nBestY_ = _cd_[2]
							exit
						ok
						if _nD_ > _nBestD_
							_nBestD_ = _nD_
							_nBestX_ = _cd_[1]
							_nBestY_ = _cd_[2]
						ok
					next
					if _nBestD_ >= 0
						_lx_ = _nBestX_
						_ly_ = _nBestY_
					ok
				else
					# no captured path (splines, self-loops): the old
					# label-vs-label nudge still applies
					for _try_ = 1 to 6
						_bHit_ = 0
						for _d_ in _aDone_
							if fabs(_lx_ - _d_[1]) < (_lw_ + _d_[3]) / 2 and
							   fabs(_ly_ - _d_[2]) < (_lh_ + _d_[4]) / 2
								_bHit_ = 1
								exit
							ok
						next
						if _bHit_ = 0  exit  ok
						if _bSwap_
							_lx_ += _lw_ * 0.55
						else
							_ly_ += _lh_ * 1.15
						ok
					next
				ok
				_aDone_ + [ _lx_, _ly_, _lw_, _lh_ ]
				@aRenderLabels + [ _cLab_, _lx_, _ly_, _lw_, _lh_, _cLK_ ]

				_oC_.Flush()
				_cPl1_ = This._SurfaceAt(_lx_, _ly_, _cBg_)
				_oC_.FillQ(_cPl1_).StrokeQ(_cPl1_, 1).
					AddRect(_lx_ - _lw_ / 2, _ly_ - _lh_ / 2, _lw_, _lh_)
				_oC_.Flush()
				# every line of the wrapped block, each centred in the
				# plate -- a wrapped label whose lines were left-aligned
				# would lean away from the line it is centred on
				_nLnH_ = _nFsz_ * 1.35
				_nTop_ = _ly_ - _lh_ / 2 + (_lh_ - len(_aLines_) * _nLnH_) / 2
				for _lni_ = 1 to len(_aLines_)
					_cLn_ = _aLines_[_lni_]
					_nLnW_ = _oFont_.WidthOf(_cLn_, _nFsz_)
					_oC_.AddTextQ(_cLn_, _lx_ - _nLnW_ / 2,
						_nTop_ + _lni_ * _nLnH_ - _nLnH_ * 0.25).
						SetFontQ(_oFont_, _nFsz_).
						Color(This.ContrastingTextColor(_cBg_))
				next
			next
		ok

		# 3. NODES
		for _i_ = 1 to _nN_
			_cId_ = "" + _aNodes_[_i_][:id]
			_a_ = This._XYOf(_aXY_, _cId_)
			if len(_a_) != 2  loop  ok
			# everything drawn for this node answers as this node: the
			# fill, the outline and the label are one thing to a reader
			# pointing at them
			_oC_.SetPickTag(_i_)
			@aRenderPicks + [ _i_, "node", _cId_, "" ]
			_cShape_ = This._NativeShapeOf(_aNodes_[_i_])
			_cFill_ = This._NativeFillOf(_aNodes_[_i_])
			_aBx_ = This._BoxOf(_cId_, _nBoxW_, _nBoxH_)
			_nBw_ = _aBx_[1]
			_nBh_ = _aBx_[2]
			_x0_ = _a_[1] - _nBw_ / 2
			_y0_ = _a_[2] - _nBh_ / 2
			_cStroke_ = This._DiagOpt(paOptions, "strokecolor", "#3A3A3A")

			# AN OUTLINE IS PROPORTIONAL TO WHAT IT OUTLINES. Every glyph
			# was stroked at 2px, which is a hairline round a 132px cell
			# and a BAND round a 25px mark: the order's final state was
			# 186 pixels of dark outline over 241 pixels of green, so the
			# stroke was very nearly as much ink as the thing it was
			# drawn around, and the Principal read the mark as dark
			# rather than as green.
			#
			# The rule is I5 the other way up. A stroke of one width on
			# two glyph sizes does not read as the same treatment -- it
			# reads as two, one of them shouting. Sameness is in the
			# RATIO, so the width follows the glyph and is floored at a
			# pixel, because a stroke thinner than that is not a stroke.
			_nStkW_ = 2 * min([ _nBw_ / _nBoxW_, _nBh_ / _nBoxH_ ])
			if _nStkW_ > 2  _nStkW_ = 2  ok
			if _nStkW_ < 1  _nStkW_ = 1  ok

			# ROUNDED is the default look of these charts. A node that named a
			# real shape keeps it; a plain box becomes a rounded box.
			if StzLower("" + _cShape_) = "box"
				_oC_.Flush()
				# A ROUND RECT OF RADIUS ZERO IS A RECT, and asking for one
				# lost the fill entirely -- so :Corner = 0, the dial that
				# selects the wholly rectangular style, drew white boxes
				# with white labels in them. The degenerate arc is the
				# canvas's to fix; naming the shape here is what makes the
				# style usable today.
				if _nRad_ > 0
					_oC_.FillQ(_cFill_).StrokeQ(_cStroke_, _nStkW_).
						AddRoundRect(_x0_, _y0_, _nBw_, _nBh_, _nRad_)
				else
					_oC_.FillQ(_cFill_).StrokeQ(_cStroke_, _nStkW_).
						AddRect(_x0_, _y0_, _nBw_, _nBh_)
				ok
			else
				StzDrawNodeShapeXT(_oC_, _cShape_, _x0_, _y0_,
					_nBw_, _nBh_, _cFill_, _cStroke_, _nStkW_)
			ok
		next

		# 4. LABELS INSIDE the node, in a colour that CONTRASTS with the fill.
		#    White text on a gold box is the failure this avoids, and
		#    stzDiagram already knows how to pick: ContrastingTextColor.
		if isObject(_oFont_)
			# ONE WEIGHT FOR EVERY NAME IN THE PICTURE -- I5, and the
			# Principal read the failure as a contrast problem, which is
			# how it looks from the outside. "In Cart" on muted grey was
			# black at 9.14:1 -- objectively the most readable label on
			# that page -- and it looked the weakest, because every cell
			# BESIDE it carried bolded white and it carried thin black.
			#
			# The weight was being decided per cell, from that cell's own
			# contrast ratio. So a picture came out in two weights, and
			# two weights among things that are all states asserts a
			# difference between them that the graph does not contain.
			# The heaviest any label needs is the weight they all take.
			_bInkBold_ = 0
			for _i_ = 1 to _nN_
				_aInk0_ = StzReadableTextOn(
					This._NativeFillOf(_aNodes_[_i_]), _nFsz_, 0)
				if _aInk0_[3]  _bInkBold_ = 1  exit  ok
			next
			for _i_ = 1 to _nN_
				_cId_ = "" + _aNodes_[_i_][:id]
				_a_ = This._XYOf(_aXY_, _cId_)
				if len(_a_) != 2  loop  ok
				# A LABEL BELONGS TO ITS NODE, and this loop runs long
				# after the one that drew the boxes -- so without saying
				# so again, every label in the picture carried the LAST
				# node's tag. Labels are drawn over the boxes, and a pick
				# answers with the topmost thing it finds, so every cell
				# in the diagram reported itself as the final one. The
				# tag has to follow the ink, not the loop.
				_oC_.SetPickTag(_i_)
				_cLb_ = "" + _aNodes_[_i_][:label]
				# AN EMPTY LABEL IS A CHOICE, not a missing value. The id
				# was used as a fallback, which is right for a node
				# nobody labelled and wrong for one labelled "" on
				# purpose -- a state machine's entry and exit
				# pseudostates are drawn as marks, and printing "i" and
				# "e" under them is the id leaking into the picture.
				if _cLb_ = ""
					if HasKey(_aNodes_[_i_], "label")  loop  ok
					_cLb_ = _cId_
				ok

				# A CELL THAT IS NOT A RECTANGLE WRITES ITS LABEL OUTSIDE
				# -- the Principal's ruling on the state machine's final
				# state, whose name was crammed inside its doublecircle.
				# The criterion behind the list: these are the glyphs
				# whose inscribed text rectangle is under about half the
				# node box, so text inside them is squeezed, clipped, or
				# laid over their geometry. The label sits BELOW, centred,
				# in the outline's ink on a plate of paper -- the same
				# legibility mechanism edge labels use -- and it still
				# answers as its node to a pick.
				_cShp2_ = StzLower("" + This._NativeShapeOf(_aNodes_[_i_]))
				_bOut_ = 0
				for _cOsh_ in [ "circle", "doublecircle", "dot", "diamond",
					"triangle", "invtriangle" ]
					if _cShp2_ = _cOsh_  _bOut_ = 1  exit  ok
				next
				if _bOut_
					_cLb_ = This._FitLabel(_cLb_, _oFont_, _nFsz_,
						_nBoxW_ + 24)
					_nTw_ = _oFont_.WidthOf(_cLb_, _nFsz_)
					_nLbY_ = _a_[2] + _nBoxH_ / 2 + _nFsz_ * 1.15
					_oC_.Flush()
					# ITS OWN POSITION, not the edge labels'. This asked
					# what surface was under the last EDGE label placed,
					# so a cell's name outside a region was painted in
					# the region's tint on white paper -- a coloured card
					# under a word that stands nowhere near the frame.
					_cPl2_ = This._SurfaceAt(_a_[1], _nLbY_, _cBg_)
					_oC_.FillQ(_cPl2_).StrokeQ(_cPl2_, 1).
						AddRect(_a_[1] - _nTw_ / 2 - 3,
							_nLbY_ - _nFsz_ * 0.75,
							_nTw_ + 6, _nFsz_ * 1.5)
					_oC_.Flush()
					_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2,
						_nLbY_ + _nFsz_ / 3).
						SetFontQ(_oFont_, _nFsz_).Color(_cStroke_)
					@aRenderNodeLabels + [ _cId_, _a_[1], _nLbY_, _nTw_,
						_nFsz_ * 1.5, 1 ]
					loop
				ok
				_cLb_ = This._FitLabel(_cLb_, _oFont_, _nFsz_, _nBoxW_ - 18)
				_nTw_ = _oFont_.WidthOf(_cLb_, _nFsz_)
				@aRenderNodeLabels + [ _cId_, _a_[1], _a_[2], _nTw_,
					_nFsz_ * 1.5, 0 ]
				_oC_.Flush()
				# THE SIZE DECIDES THE INK, and whether the ink needs
				# weight. White is the right colour on a saturated fill --
				# dark ink on a dark-ish saturated field reads muddy
				# whatever the ratio says -- but white on those fills sits
				# between WCAG's normal-text minimum and its LARGE-text
				# one, so at a small size it is not wrong, it is text that
				# must be bolder. StzReadableTextOn says which and says
				# when; this draws the emphasis rather than quietly
				# swapping to a colour nobody can read either.
				_aInk_ = StzReadableTextOn(
					This._NativeFillOf(_aNodes_[_i_]), _nFsz_, 0)
				_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2, _a_[2] + _nFsz_ / 3).
					SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
				if _bInkBold_
					# FAUX BOLD: the same glyphs a fraction of a pixel
					# over, twice. A real bold face would be better and
					# needs a second font file the caller has not given
					# us; thickening the stem is what makes 3.4:1 legible
					# at 12px, and it is what the large-text rule is
					# actually asking for.
					_oC_.Flush()
					_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2 + 0.6,
						_a_[2] + _nFsz_ / 3).
						SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
					_oC_.Flush()
					_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2 + 0.3,
						_a_[2] + _nFsz_ / 3 + 0.3).
						SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
				ok
			next
		ok

		# THE PICTURE IS FINISHED WHEN IT IS HANDED OVER. The canvas holds
		# one shape pending until the next is added, so the LAST thing
		# drawn -- the last node's outline, most often -- was still in
		# Ring's hands when the caller received the canvas. Every output
		# method flushes, so nothing rendered was ever wrong; but a
		# question asked of the picture BEFORE rendering it, which is what
		# picking is, could not see that last shape. A returned canvas is
		# a finished one.
		_oC_.Flush()
		_oC_.SetPickTag(0)

		return _oC_

	def ToSVG()
		return This.ToCanvas().ToSVG()

	def ToSVGXT(paOptions)
		return This.ToCanvasXT(paOptions).ToSVG()

	# A PICTURE LARGER THAN ITS MEDIUM IS RENDERED PER TILE, never
	# rendered whole and cut -- because "whole" is exactly what fails. A
	# GPU texture stops at 8192 in either axis and this library ships that
	# as a refusal; print never had a whole at all. dot has tiled
	# PostScript across A4 since the eighties for the same reason.
	#
	# Each page is drawn from the SAME retained scene through a moved
	# projection (stzCanvas.SetRegion), so a tile is the picture seen
	# through a window rather than a crop of an image nobody could
	# allocate. The pages are then composed at page size, which is what
	# lets the marks and the caption live in the MARGIN in page
	# coordinates instead of being smuggled into the diagram's own
	# geometry.
	#
	# Overlap is a glue margin: sheets are meant to be trimmed and joined,
	# so consecutive tiles share a band. Strip the overlap and the tiles
	# reassemble pixel-identical to a single render -- which is the
	# property the guard asserts, and the only one that makes tiling a
	# rendering rather than a resampling.
	#
	# Returns [ [ path, row, col, sceneX, sceneY ], ... ] -- what was
	# written and which part of the picture each sheet holds.
	def ToPages(pcPath)
		return This.ToPagesXT(pcPath, [ :Page = :A4 ])

	def ToPagesXT(pcPath, paOptions)
		if NOT isString(pcPath) or pcPath = ""
			StzRaise("stzDiagram: ToPages needs a path to write the sheets to.")
		ok
		if NOT isList(paOptions)  paOptions = []  ok

		# the page, in pixels at the chosen resolution. A4 at 150dpi is
		# 1240x1754, which is a real sheet rather than a round number.
		_pgDpi_ = This._DiagOpt(paOptions, "dpi", 150)
		_pgName_ = StzLower("" + This._DiagOpt(paOptions, "page", "a4"))
		_pgWmm_ = 210  _pgHmm_ = 297
		if _pgName_ = "letter"  _pgWmm_ = 216  _pgHmm_ = 279  ok
		if _pgName_ = "a3"      _pgWmm_ = 297  _pgHmm_ = 420  ok
		if _pgName_ = "a5"      _pgWmm_ = 148  _pgHmm_ = 210  ok
		_pgW_ = floor(This._DiagOpt(paOptions, "pagew",
			_pgWmm_ / 25.4 * _pgDpi_))
		_pgH_ = floor(This._DiagOpt(paOptions, "pageh",
			_pgHmm_ / 25.4 * _pgDpi_))
		if This._DiagOpt(paOptions, "landscape", 0)
			_pgT_ = _pgW_  _pgW_ = _pgH_  _pgH_ = _pgT_
		ok
		# 12mm of glue, dot's own default order of magnitude
		_pgOv_ = floor(This._DiagOpt(paOptions, "overlap",
			12 / 25.4 * _pgDpi_))
		if _pgOv_ < 0  _pgOv_ = 0  ok
		if _pgOv_ > _pgW_ / 2  _pgOv_ = floor(_pgW_ / 2)  ok
		if _pgOv_ > _pgH_ / 2  _pgOv_ = floor(_pgH_ / 2)  ok
		_pgMarks_ = This._DiagOpt(paOptions, "marks", 1)

		# THE PICTURE IS RENDERED ONCE. Every sheet is a window onto this
		# one scene, so the layout, the labels and the routing are settled
		# before any page exists -- pages cannot disagree with each other
		# about where a node is.
		_pgOpt_ = []
		for _pgO_ in paOptions  _pgOpt_ + _pgO_  next
		# [ key, value ], NOT [ :Key = value ] -- the second nests the pair
		# one level deeper and every reader skips it in silence, which is
		# the option-list trap this repository has paid for before
		_pgOpt_ + [ :Tiled, 1 ]
		_pgCv_ = This.ToCanvasXT(_pgOpt_)
		_pgTotW_ = _pgCv_.Width()
		_pgTotH_ = _pgCv_.Height()

		_pgStepX_ = _pgW_ - _pgOv_
		_pgStepY_ = _pgH_ - _pgOv_
		if _pgStepX_ < 1  _pgStepX_ = 1  ok
		if _pgStepY_ < 1  _pgStepY_ = 1  ok
		_pgCols_ = max([ 1, ceil((_pgTotW_ - _pgOv_) / _pgStepX_) ])
		_pgRows_ = max([ 1, ceil((_pgTotH_ - _pgOv_) / _pgStepY_) ])

		# the path becomes a family: name.png -> name_r1c1.png
		_pgBase_ = pcPath
		_pgExt_ = ".png"
		_pgDot_ = StzFindLast(".", pcPath)
		if _pgDot_ > 1
			_pgBase_ = StzSubStr(pcPath, 1, _pgDot_ - 1)
			_pgExt_ = StzSubStr(pcPath, _pgDot_, StzLen(pcPath) - _pgDot_ + 1)
		ok

		_pgOut_ = []
		for _pgR_ = 1 to _pgRows_
			for _pgC_ = 1 to _pgCols_
				_pgX_ = (_pgC_ - 1) * _pgStepX_
				_pgY_ = (_pgR_ - 1) * _pgStepY_
				_pgCv_.SetRegion(_pgX_, _pgY_, _pgW_, _pgH_)
				_pgPx_ = _pgCv_.ToPixels()
				if _pgPx_ = ""
					_pgCv_.ClearRegion()
					StzRaise("stzDiagram: ToPages needs a graphics " +
						"device to draw pixels. ToPagesSVG() needs none.")
				ok
				_pgSheet_ = new stzCanvas(_pgW_, _pgH_)
				_pgSheet_.SetBackgroundQ("#FFFFFF")
				_pgSheet_.AddImage(0, 0, _pgW_, _pgH_, _pgW_, _pgH_, _pgPx_)
				if _pgMarks_
					This._PageMarks(_pgSheet_, _pgW_, _pgH_, _pgOv_,
						_pgR_, _pgC_, _pgRows_, _pgCols_)
				ok
				_pgFile_ = _pgBase_ + "_r" + _pgR_ + "c" + _pgC_ + _pgExt_
				_pgSheet_.ToPNG(_pgFile_)
				_pgOut_ + [ _pgFile_, _pgR_, _pgC_, _pgX_, _pgY_ ]
			next
		next
		_pgCv_.ClearRegion()
		return _pgOut_

	# CROP MARKS AND THE SHEET'S NAME, in the overlap margin where the
	# trim happens -- so a reader with a stack of sheets can tell which
	# joins which without laying them all out first.
	def _PageMarks(oSheet, nW, nH, nOv, nR, nC, nRows, nCols)
		_pmM_ = max([ 6, floor(nOv / 3) ])
		_pmG_ = "#808080"
		oSheet.Flush()
		# a tick at each corner, pointing along the trim line
		for _pmI_ = 1 to 4
			_pmX_ = 0  _pmY_ = 0  _pmDx_ = 1  _pmDy_ = 1
			if _pmI_ = 2  _pmX_ = nW  _pmDx_ = -1  ok
			if _pmI_ = 3  _pmY_ = nH  _pmDy_ = -1  ok
			if _pmI_ = 4  _pmX_ = nW  _pmY_ = nH  _pmDx_ = -1  _pmDy_ = -1  ok
			oSheet.AddLineQ(_pmX_, _pmY_ + _pmDy_ * nOv,
				_pmX_ + _pmDx_ * _pmM_, _pmY_ + _pmDy_ * nOv).Stroke(_pmG_, 1)
			oSheet.AddLineQ(_pmX_ + _pmDx_ * nOv, _pmY_,
				_pmX_ + _pmDx_ * nOv, _pmY_ + _pmDy_ * _pmM_).Stroke(_pmG_, 1)
		next
		oSheet.Flush()
		return This

	def ToPNG(pcPath)
		return This.ToCanvas().ToPNG(pcPath)

	def ToPNGXT(pcPath, paOptions)
		return This.ToCanvasXT(paOptions).ToPNG(pcPath)

	#-- native-tier internals ------------------------------------------

	# How much the box must shrink for no two nodes to overlap: 1 when the
	# picture already fits, less when it does not.
	#
	# NOT the O(n^2) all-pairs distance it looks like. Nodes are bucketed into
	# ranks by y and the list is sorted ONCE on a composite key, so the closest
	# horizontal neighbour is the previous entry in the same bucket -- one pass
	# after a builtin sort, which keeps a 10,000-node picture out of a
	# 50-million-comparison loop written in Ring.
	def _RankFitScale(paXY, pnBoxW, pnBoxH)
		_rfN_ = len(paXY)
		if _rfN_ < 2  return 1  ok

		# 4px of tolerance: a rank is "the same y", not "the identical float"
		_rfA_ = []
		for _rfI_ = 1 to _rfN_
			_rfB_ = floor(paXY[_rfI_][3] / 4)
			_rfA_ + [ _rfB_ * 1000000 + paXY[_rfI_][2], _rfB_,
			          paXY[_rfI_][2], paXY[_rfI_][3] ]
		next
		_rfA_ = sort(_rfA_, 1)

		_rfMinX_ = -1
		_rfMinY_ = -1
		for _rfI_ = 2 to _rfN_
			if _rfA_[_rfI_][2] = _rfA_[_rfI_ - 1][2]
				# same rank -> a horizontal neighbour
				_rfD_ = _rfA_[_rfI_][3] - _rfA_[_rfI_ - 1][3]
				if _rfD_ > 0 and (_rfMinX_ < 0 or _rfD_ < _rfMinX_)
					_rfMinX_ = _rfD_
				ok
			else
				# a new rank -> the gap between two ranks
				_rfD_ = _rfA_[_rfI_][4] - _rfA_[_rfI_ - 1][4]
				if _rfD_ < 0  _rfD_ = -_rfD_  ok
				if _rfD_ > 0 and (_rfMinY_ < 0 or _rfD_ < _rfMinY_)
					_rfMinY_ = _rfD_
				ok
			ok
		next

		# 6px of air, so adjacent boxes read as two boxes and not as one wall
		_rfS_ = 1
		if _rfMinX_ > 0 and pnBoxW > 0
			_rfS_ = min([ _rfS_, _rfMinX_ / (pnBoxW + 6) ])
		ok
		if _rfMinY_ > 0 and pnBoxH > 0
			_rfS_ = min([ _rfS_, _rfMinY_ / (pnBoxH + 6) ])
		ok
		return _rfS_

	# rankdir, from the diagram's OWN SetLayout -- TB / BT / LR / RL.
	def _NativeRankDir()
		_c_ = StzLower("" + @cLayout)
		if _c_ = ""  _c_ = $cDefaultLayout  ok
		if _c_ = "topdown" or StzFindFirst(_c_, $acLayouts[:TopDown]) > 0
			return "TB"
		but _c_ = "bottomup" or StzFindFirst(_c_, $acLayouts[:BottomUp]) > 0
			return "BT"
		but _c_ = "leftright" or StzFindFirst(_c_, $acLayouts[:LeftRight]) > 0
			return "LR"
		but _c_ = "rightleft" or StzFindFirst(_c_, $acLayouts[:RightLeft]) > 0
			return "RL"
		ok
		return "TB"

	# One edge: clipped to both node boxes, routed in the requested spline
	# style, finished with an arrowhead. A centre-to-centre line that runs
	# UNDER the node is what a hand-rolled renderer draws; dot clips, so this
	# clips.
	# For each edge: [ portFrom, portTo, laneFrac ]. Ports are offsets along
	# the slot axis; the lane is where an ortho trunk crosses the rank gap.
	#
	# Ports are ORDERED BY DESTINATION: a parent's leftmost edge leaves from
	# its leftmost port. Assigned by rank order instead, two edges swap
	# within the box's own width and cross a pixel after leaving it.
	def _EdgePorts(paEdges, paXY, nBoxW, nBoxH, cRank, paRoutes)
		_epN_ = len(paEdges)
		_epRes_ = []
		for _epI_ = 1 to _epN_  _epRes_ + [ 0, 0, 0.5, 0, 0, 0 ]  next
		_bV_ = 0
		if cRank = "LR" or cRank = "RL"  _bV_ = 1  ok    # slot axis = y
		_epBox_ = nBoxW
		if _bV_  _epBox_ = nBoxH  ok

		# fan OUT of each from-node, fan IN to each to-node
		for _epSide_ = 1 to 2
			_epKeys_ = []
			for _epI_ = 1 to _epN_
				_epId_ = StzLower("" + paEdges[_epI_][ iif(_epSide_ = 1, :from, :to) ])
				_epFound_ = 0
				for _epK_ = 1 to len(_epKeys_)
					if _epKeys_[_epK_][1] = _epId_
						_epKeys_[_epK_][2] + _epI_
						_epFound_ = 1
						exit
					ok
				next
				if NOT _epFound_
					_epKeys_ + [ _epId_, [ _epI_ ] ]
				ok
			next
			for _epK_ = 1 to len(_epKeys_)
				_epGrp_ = _epKeys_[_epK_][2]
				_epGn_ = len(_epGrp_)
				if _epGn_ < 2  loop  ok
				# order the group by where its OTHER end sits on the slot axis
				_epSort_ = []
				for _epJ_ = 1 to _epGn_
					_epE_ = paEdges[_epGrp_[_epJ_]]
					# ORDERED BY WHERE THE EDGE ACTUALLY COMES FROM, which
					# for a ROUTED edge is its nearest bend and not its
					# far-off source node. Sorting arrivals by the source's
					# position put the edge approaching from the left onto
					# the right-hand port whenever its route had carried it
					# around -- so the two crossed in the last few pixels
					# before the node, which is the one place a reader is
					# certain of what they are looking at.
					_epRt_ = This._RouteOf(paRoutes, "" + _epE_[:from],
						"" + _epE_[:to])
					_epC_ = 0
					_epGot_ = 0
					if len(_epRt_) > 0
						if _epSide_ = 1
							_epB_ = _epRt_[1]
						else
							_epB_ = _epRt_[ len(_epRt_) ]
						ok
						_epC_ = _epB_[ iif(_bV_, 2, 1) ]
						_epGot_ = 1
					ok
					if _epGot_ = 0
						_epOth_ = This._XYOf(paXY,
							"" + _epE_[ iif(_epSide_ = 1, :to, :from) ])
						if len(_epOth_) = 2
							_epC_ = _epOth_[ iif(_bV_, 2, 1) ]
						ok
					ok
					_epSort_ + [ _epC_, _epGrp_[_epJ_], _epGot_ ]
				next
				_epSort_ = sort(_epSort_, 1)
				# PROPORTIONAL TO THE BORDER, not a flat 14px per edge.
				# Two arrows arriving at one node were placed 14px apart
				# -- narrower than the arrowheads themselves, so they
				# overlapped and read as one thick arrow. The border a
				# node offers is what there is to share; 26px per edge
				# uses it and still caps at the border's width, so a
				# heavily-fanned node degrades to evenly packed rather
				# than to overlapping.
				# A FRACTION OF THE BORDER, never a count of pixels. Both
				# earlier versions were literals -- 14px per edge, then
				# 26px -- and a literal cannot know how wide the node is
				# or that :Scale has just doubled everything, so two
				# arrivals at a 200px box were placed 26px apart and read
				# as one arrow with a thick head. The border is the
				# resource being shared, so the share is expressed in it:
				# a third of it for two edges, all of it from four up.
				# THE ALIGNED EDGE OWNS THE CENTRE, and the others spread
				# AROUND it. The alignment pass moves a cell exactly onto
				# its counterpart so the edge between them can be a
				# straight column -- and an even port spread then handed
				# that same edge an offset, leaning it between two
				# perfectly aligned cells. Two fixes fighting: the layout
				# buying a spine and the ports spending it. So any member
				# of the fan whose far end sits exactly on this node's
				# own cross-position is pinned to port ZERO, and the rest
				# take successive steps to its left and right in their
				# sorted order. No aligned member: the even spread as
				# before.
				# ...and only a SINGLE-HOP member can claim the pin. A routed
				# member's sort key is its nearest bend, and the router aims
				# bends at the target's own centre -- so a routed arrival
				# always "aligned" with the node it arrives at, pinned itself
				# to the centre, and pushed the whole group off it. Alignment
				# is a claim about two CELLS sharing a spine; a bend the
				# route derived from this very node cannot make it.
				_epAt2_ = This._XYOf(paXY, _epKeys_[_epK_][1])
				_epAl_ = 0
				if len(_epAt2_) = 2
					_epNC_ = _epAt2_[ iif(_bV_, 2, 1) ]
					for _epJ_ = 1 to _epGn_
						if fabs(_epSort_[_epJ_][1] - _epNC_) < 1 and
						   _epSort_[_epJ_][3] = 0
							_epAl_ = _epJ_
							exit
						ok
					next
				ok
				_epSpread_ = (_epBox_ - 16) *
					min([ 1, (_epGn_ - 1) / 3 ])
				if _epSpread_ < 0  _epSpread_ = 0  ok
				_epStep_ = _epSpread_ / (_epGn_ - 1)
				for _epJ_ = 1 to _epGn_
					if _epAl_ > 0
						_epOff_ = _epStep_ * (_epJ_ - _epAl_)
					else
						_epOff_ = 0 - (_epSpread_ / 2) +
							(_epSpread_ * (_epJ_ - 1) / (_epGn_ - 1))
					ok
					_epRes_[ _epSort_[_epJ_][2] ][_epSide_] = _epOff_
				next
			next
		next

		# THE CORRIDOR VETO. A side entry is only honest when the run into
		# that border is EMPTY: an edge flattening along a rank to reach a
		# far cell passes over every same-rank cell between -- and a line
		# grazing a box reads as a link to it, which is exactly the
		# erroneous information the Principal named on the fan. So a side
		# landing is refused whenever any same-rank node stands strictly
		# between the target and the point the edge approaches from; the
		# aspect rule in _AttachPoint then keeps such an edge on the
		# rank-facing border, descending into its cell from above instead
		# of sliding in along the row.
		for _epI_ = 1 to _epN_
			_epTo_ = This._XYOf(paXY, "" + paEdges[_epI_][:to])
			if len(_epTo_) != 2  loop  ok
			_epRt2_ = This._RouteOf(paRoutes, "" + paEdges[_epI_][:from],
				"" + paEdges[_epI_][:to])
			if len(_epRt2_) > 0
				_epAp_ = _epRt2_[ len(_epRt2_) ]
			else
				_epAp_ = This._XYOf(paXY, "" + paEdges[_epI_][:from])
			ok
			if len(_epAp_) != 2  loop  ok
			_epLoT_ = min([ _epTo_[ iif(_bV_, 2, 1) ], _epAp_[ iif(_bV_, 2, 1) ] ])
			_epHiT_ = max([ _epTo_[ iif(_bV_, 2, 1) ], _epAp_[ iif(_bV_, 2, 1) ] ])
			_epRkT_ = _epTo_[ iif(_bV_, 1, 2) ]
			for _epP2_ in paXY
				if StzLower("" + _epP2_[1]) = StzLower("" + paEdges[_epI_][:to])
					loop
				ok
				if StzLower("" + _epP2_[1]) = StzLower("" + paEdges[_epI_][:from])
					loop
				ok
				# paXY rows are [ id, x, y ] -- one wider than the [ x, y ]
				# _XYOf answers, so the axis indices shift by one here
				_epC2_ = _epP2_[ iif(_bV_, 3, 2) ]
				_epR2_ = _epP2_[ iif(_bV_, 2, 3) ]
				if fabs(_epR2_ - _epRkT_) < nBoxH * 1.2 and
				   _epC2_ > _epLoT_ + 2 and _epC2_ < _epHiT_ - 2
					_epRes_[_epI_][5] = 1
					exit
				ok
			next

			# THE UNIQUE LATERAL EDGE LEAVES ITS SIDE-BORDER CENTRE -- the
			# Principal's rule for image 1. A single edge bound far
			# sideways, with a free corridor at its own row height and no
			# sibling out-edge competing for that side, is one horizontal
			# statement and should read as one: out of the lateral border's
			# middle, along the row corridor, down into the target. The
			# conditions are ALL of: single-hop, shallower than the box's
			# aspect, corridor free at row height, and no other out-edge of
			# the same source heading the same side.
			#
			# UNIQUE MEANS THE SOURCE'S ONLY OUT-EDGE, and that word had
			# been read too loosely: "no sibling on THIS side" let the
			# outermost child of a four-way fan leave sideways while its
			# three siblings dropped off a shared bus. Four children of
			# one parent stand in one rank in one relation, and a picture
			# that draws one of them differently states a difference the
			# graph does not contain -- the same law that forbids two
			# unrelated edges sharing a line, seen from the other side.
			# Congruence outranks the lateral form: siblings are drawn
			# alike, and a genuinely lone edge still gets its border
			# centre.
			# ...and SIBLINGS MEANS SIBLINGS OF THE SAME KIND. The
			# first form of this rule counted out-edges: two or more and
			# no lateral form, full stop. That drew the four-way fan
			# correctly and then forced a service's log edge -- whose
			# sibling drops into a database inside its own cluster while
			# it leaves for a logger outside every cluster -- to descend
			# into the cluster's interior and run out sideways beneath
			# it, three turns instead of two, grazing a foreign frame on
			# the way. Drawing those two alike states a likeness that is
			# not there.
			#
			# Cluster membership is a DECLARED difference, so edges whose
			# targets sit in different cluster contexts are different
			# kinds, and drawing them differently states a difference the
			# graph does contain. Two out-edges are siblings-in-kind when
			# their targets belong to exactly the same clusters; the
			# lateral form asks only that no OTHER edge shares its kind.
			# A fan with no clusters has one kind and stays a bus.
			_epKin_ = 0
			_epMyK_ = This._ClusterKeyOf("" + paEdges[_epI_][:to])
			for _epJ3_ = 1 to _epN_
				if _epJ3_ = _epI_  loop  ok
				if StzLower("" + paEdges[_epJ3_][:from]) !=
				   StzLower("" + paEdges[_epI_][:from])
					loop
				ok
				if StzLower("" + paEdges[_epJ3_][:from]) =
				   StzLower("" + paEdges[_epJ3_][:to])
					loop
				ok
				if This._ClusterKeyOf("" + paEdges[_epJ3_][:to]) = _epMyK_
					_epKin_++
				ok
			next
			if len(_epRt2_) = 0 and _epKin_ = 0
				_epFr_ = This._XYOf(paXY, "" + paEdges[_epI_][:from])
				if len(_epFr_) = 2
					_epDx2_ = fabs(_epTo_[ iif(_bV_, 2, 1) ] - _epFr_[ iif(_bV_, 2, 1) ])
					_epDy2_ = fabs(_epTo_[ iif(_bV_, 1, 2) ] - _epFr_[ iif(_bV_, 1, 2) ])
					_epShal_ = 0
					if _bV_
						if _epDy2_ > 0.001 and _epDx2_ / _epDy2_ < (nBoxW / nBoxH) * 1.4
							_epShal_ = 1
						ok
					else
						if _epDx2_ > 0.001 and _epDy2_ / _epDx2_ < (nBoxH / nBoxW) * 1.4
							_epShal_ = 1
						ok
					ok
					# ...OR THE EDGE LEAVES ITS SOURCE'S CLUSTER, whatever its
					# angle. The shallow test asks whether an edge is mostly
					# sideways, which is a good proxy for 'a side departure will
					# look natural' and a bad one for the case that matters most:
					# an edge going OUT of a cluster. Its alternative is to
					# descend inside the cluster and slide out beneath it, which
					# is longer and runs the line along frames it does not belong
					# to. Tightening the boundary air proved the point by
					# accident: the target came close enough to fail the angle
					# test, and a correct picture reverted to the detour the
					# Principal had just had removed. Leaving a cluster is a
					# reason of its own; the corridor test below still decides
					# whether the side is actually clear.
					if This._LeavesCluster("" + paEdges[_epI_][:from],
						"" + paEdges[_epI_][:to])
						_epShal_ = 1
					ok
					if _epShal_
						# corridor at the SOURCE's row height
						_epCy_ = _epFr_[ iif(_bV_, 1, 2) ]
						_epL2_ = min([ _epFr_[ iif(_bV_, 2, 1) ], _epTo_[ iif(_bV_, 2, 1) ] ])
						_epH2_ = max([ _epFr_[ iif(_bV_, 2, 1) ], _epTo_[ iif(_bV_, 2, 1) ] ])
						_epFree_ = 1
						for _epP3_ in paXY
							if StzLower("" + _epP3_[1]) = StzLower("" + paEdges[_epI_][:to])
								loop
							ok
							if StzLower("" + _epP3_[1]) = StzLower("" + paEdges[_epI_][:from])
								loop
							ok
							_epC3_ = _epP3_[ iif(_bV_, 3, 2) ]
							_epR3_ = _epP3_[ iif(_bV_, 2, 3) ]
							if fabs(_epR3_ - _epCy_) < nBoxH * 1.2 and
							   _epC3_ > _epL2_ + 2 and _epC3_ < _epH2_ - 2
								_epFree_ = 0
								exit
							ok
						next
						# no sibling out-edge to the same side
						if _epFree_
							_epSgn_ = 1
							if _epTo_[ iif(_bV_, 2, 1) ] < _epFr_[ iif(_bV_, 2, 1) ]
								_epSgn_ = -1
							ok
							for _epJ2_ = 1 to _epN_
								if _epJ2_ = _epI_  loop  ok
								if StzLower("" + paEdges[_epJ2_][:from]) !=
								   StzLower("" + paEdges[_epI_][:from])
									loop
								ok
								_epOt2_ = This._XYOf(paXY,
									"" + paEdges[_epJ2_][:to])
								if len(_epOt2_) != 2  loop  ok
								_epD3_ = _epOt2_[ iif(_bV_, 2, 1) ] -
									_epFr_[ iif(_bV_, 2, 1) ]
								if _epD3_ * _epSgn_ > 0 and
								   fabs(_epOt2_[ iif(_bV_, 1, 2) ] - _epCy_) <
								   nBoxH * 1.2
									_epFree_ = 0
									exit
								ok
							next
						ok
						if _epFree_  _epRes_[_epI_][6] = 1  ok
					ok
				ok
			ok
		next

		# ortho LANES: parents in one rank take successive channel heights,
		# cycled among four, so neighbouring trunks never share one
		_epP_ = []
		for _epI_ = 1 to _epN_
			_epId_ = StzLower("" + paEdges[_epI_][:from])
			_epAt_ = This._XYOf(paXY, _epId_)
			if len(_epAt_) != 2  loop  ok
			_epRk_ = floor(_epAt_[ iif(_bV_, 1, 2) ] / 4)
			_epSl_ = _epAt_[ iif(_bV_, 2, 1) ]
			_epSeen_ = 0
			for _epK_ = 1 to len(_epP_)
				if _epP_[_epK_][3] = _epId_  _epSeen_ = 1  exit  ok
			next
			if NOT _epSeen_
				_epP_ + [ (_epRk_ * 1000000) + _epSl_, _epRk_, _epId_ ]
			ok
		next
		_epP_ = sort(_epP_, 1)
		_epLanes_ = []
		_epPrevRk_ = -1
		_epC_ = 0
		for _epK_ = 1 to len(_epP_)
			if _epP_[_epK_][2] != _epPrevRk_
				_epPrevRk_ = _epP_[_epK_][2]
				_epC_ = 0
			ok
			# ONE RHYTHM, and the cycling that used to be here is gone.
			#
			# Parents in a rank took successive channel heights -- 0.30,
			# 0.43, 0.57, 0.70 of their gap, cycled by position -- so that
			# neighbouring trunks could never share a line. That was a
			# PRE-EMPTIVE spread, invented before the channel claim
			# registry existed, and it bought its safety by making every
			# vertical in the picture a different length: the Principal
			# measured 29%, 43% and 7% of one constant 92.6px gap and read
			# it, correctly, as no design system at all.
			#
			# The registry now answers the real question -- do these two
			# channels actually OVERLAP in span -- and steps only those
			# that do, by exactly one clearance. So every trunk proposes
			# the same canonical height, the middle of its own gap, and a
			# reader who sees two drops of different length is seeing a
			# stated reason: an obstacle the band had to clear, or a
			# conflict the claim had to step.
			_epLanes_ + [ _epP_[_epK_][3], 0.5 ]
			_epC_++
		next
		for _epI_ = 1 to _epN_
			_epId_ = StzLower("" + paEdges[_epI_][:from])
			for _epK_ = 1 to len(_epLanes_)
				if _epLanes_[_epK_][1] = _epId_
					_epRes_[_epI_][3] = _epLanes_[_epK_][2]
					exit
				ok
			next
		next
		return _epRes_

	# [ [ clusterId, [ nodeIds ] ], ... ] -- the shape stzGraphCanvas asks
	# for. Passed as an OPTION rather than read off the object, so the
	# canvas stays a graph renderer and does not have to know what an
	# stzDiagram is.
	def _ClusterPairs()
		_cp_ = []
		for _cd_ in This._ClusterDepths()
			_cp_ + [ _cd_[1], _cd_[2], _cd_[3] ]
		next
		return _cp_

	# [ [ id, nodes, depth ], ... ] with depth 1 = outermost, sorted
	# outermost first.
	#
	# NESTING IS INFERRED, NOT DECLARED, and that is the design decision
	# here. A cluster whose node set is a SUBSET of another's IS inside it
	# -- the data already says so, and asking the author to repeat it in a
	# parent link would be a second statement of one fact, free to
	# disagree with the first. It also costs no API change: every existing
	# caller keeps working and gains nesting the moment its sets nest.
	#
	# PARTIAL OVERLAP IS REFUSED. Two clusters that share a node while
	# neither contains the other cannot both be drawn as boxes -- there is
	# no arrangement of two rectangles where each holds all its own members
	# and neither holds a stranger. Silently picking one to break would
	# produce a picture that lies about membership, so it is named instead.
	def _ClusterDepths()
		_n_ = len(@aClusters)
		_res_ = []
		for _i_ = 1 to _n_
			_ai_ = This._ClusterNodeSet(@aClusters[_i_])
			_d_ = 1
			for _j_ = 1 to _n_
				if _j_ = _i_  loop  ok
				_aj_ = This._ClusterNodeSet(@aClusters[_j_])
				if This._SetInside(_ai_, _aj_)
					# j contains i; if they are IDENTICAL only one can be
					# the outer, and the earlier declaration wins so the
					# result does not depend on list order twice over
					if This._SetInside(_aj_, _ai_)
						if _j_ < _i_  _d_++  ok
					else
						_d_++
					ok
				but This._SetsOverlap(_ai_, _aj_) and
				    NOT This._SetInside(_aj_, _ai_)
					# BOTH directions, not one. Checking only "is i inside
					# j" made every legitimate OUTER cluster refuse its own
					# child: Backend is not inside Data, they share nodes,
					# and the overlap branch fired -- so declaring a nesting
					# raised the error written to forbid a non-nesting.
					StzRaise("stzDiagram: clusters '" + @aClusters[_i_][:id] +
						"' and '" + @aClusters[_j_][:id] + "' share nodes " +
						"but neither contains the other. Two boxes cannot " +
						"both hold all their own members without one " +
						"holding a stranger -- nest one inside the other " +
						"(make its nodes a subset), or keep them disjoint.")
				ok
			next
			_res_ + [ "" + @aClusters[_i_][:id], @aClusters[_i_][:nodes], _d_ ]
		next
		# outermost first: the layout compacts inner groups before outer
		# ones, and the drawing paints outer boxes behind inner ones
		_ord_ = []
		for _i_ = 1 to len(_res_)
			_ord_ + [ _res_[_i_][3] * 100000 + _i_, _i_ ]
		next
		_ord_ = sort(_ord_, 1)
		_out_ = []
		for _o_ in _ord_  _out_ + _res_[ _o_[2] ]  next
		return _out_

	# WHERE ALONG ITS EDGE A LABEL SITS, as a fraction from source to
	# target. Named once because TWO places must agree about it: the
	# drawing, which puts the label there, and the demand below, which buys
	# the room. They are the same number seen from two sides -- a label
	# placed at 0.72 of the way to its target inherits 0.72 of the spread
	# between two targets, so the room needed between them is the label's
	# width DIVIDED by this. Get the two out of step and the layout pays
	# for space the label is not standing in.
	# The corner radius the nodes are drawn with, so the edge geometry can
	# aim under the outline rather than at the rectangle behind it.
	# The piecewise rank-axis map for per-gap pitches: a provisional
	# 0..700 coordinate whose rank rows are even becomes the cumulative
	# frame where each gap has its own height. Within a gap the map is
	# linear, so a route bend keeps its fraction of the gap it rides in.
	def _GapMapY(pnY, pnLayers, paCum)
		if pnLayers < 2  return 0  ok
		_lf_ = pnY / 700.0 * (pnLayers - 1)
		_l0_ = floor(_lf_)
		if _l0_ < 0  _l0_ = 0  ok
		if _l0_ > pnLayers - 2  _l0_ = pnLayers - 2  ok
		_fr_ = _lf_ - _l0_
		return paCum[_l0_ + 1] + _fr_ * (paCum[_l0_ + 2] - paCum[_l0_ + 1])

	def _EdgeCorner()
		return @nEdgeCornerRad

	def _EdgeLabelBias()
		# THE MIDPOINT, because the arrowhead lives at the end. Biasing
		# toward the target was meant to let labels inherit a fan's
		# spread, and it did -- straight onto the arrowheads, where the
		# label's own background plate then erased the head it was
		# standing on. A label that hides the thing it describes is worse
		# than a label that crowds its neighbour, and crowding already
		# has an answer: the nudge below moves overlapping labels into
		# the next band, and the demand that widens the rank is computed
		# from THIS number, so both stay consistent with wherever it sits.
		return 0.5

	# Per-node extra half-width demand, in SLOT units, from the edge labels
	# arriving at each node.
	#
	# CHARGED TO THE TARGET, not to the edge. A label sits between two
	# ranks and no node owns it, so something has to; the target is the
	# right payer because a fan-out's labels spread the way its children
	# do -- widening the children is exactly what stops their labels
	# meeting. Charging the source instead would widen one rank too early
	# and leave the labels as crowded as before.
	#
	# Zero when the label is no wider than the node it points at, so an
	# ordinary diagram of short labels is laid out exactly as before.
	# A LABEL WRAPPED IS WIDTH TRADED FOR HEIGHT, and in a layered drawing
	# that is a bargain: width is the scarce axis -- every child's label
	# competes with its neighbours' for the same rank -- while the rank
	# GAP is one number the layout can grow once for everybody. The
	# Principal drew it: "Condition 1 / holds" on two lines, the lines a
	# little longer, the picture much narrower.
	#
	# Returns the lines. ONE function, because the demand that buys the
	# room and the drawing that fills it must wrap identically -- the
	# label bug just fixed was exactly those two disagreeing.
	def _WrapLabel(cText, oFont, nFsz, nTargetW)
		_wlT_ = StzTrim("" + cText)
		if _wlT_ = "" or NOT isObject(oFont)  return [ _wlT_ ]  ok
		if oFont.WidthOf(_wlT_, nFsz) <= nTargetW  return [ _wlT_ ]  ok
		_wlW_ = StzSplit(_wlT_, " ")
		if len(_wlW_) < 2  return [ _wlT_ ]  ok
		# try two lines, then three: the fewest that fits the target, and
		# never more than three -- a label taller than the node it names
		# stops being a label and starts being a paragraph
		for _wlK_ = 2 to 3
			_wlLim_ = oFont.WidthOf(_wlT_, nFsz) / _wlK_ * 1.25
			_wlOut_ = []
			_wlCur_ = ""
			for _wlI_ = 1 to len(_wlW_)
				if _wlCur_ = ""
					_wlTry_ = _wlW_[_wlI_]
				else
					_wlTry_ = _wlCur_ + " " + _wlW_[_wlI_]
				ok
				if _wlCur_ != "" and oFont.WidthOf(_wlTry_, nFsz) > _wlLim_
					_wlOut_ + _wlCur_
					_wlCur_ = _wlW_[_wlI_]
				else
					_wlCur_ = _wlTry_
				ok
			next
			if _wlCur_ != ""  _wlOut_ + _wlCur_  ok
			_wlMax_ = 0
			for _wlL_ in _wlOut_
				if oFont.WidthOf(_wlL_, nFsz) > _wlMax_
					_wlMax_ = oFont.WidthOf(_wlL_, nFsz)
				ok
			next
			if len(_wlOut_) <= _wlK_ and _wlMax_ <= nTargetW  return _wlOut_  ok
			if _wlK_ = 3  return _wlOut_  ok
		next
		return [ _wlT_ ]

	# The wrapped label's block: [ lines, width, height ].
	def _LabelBlock(cText, oFont, nFsz, nTargetW)
		_lbL_ = This._WrapLabel(cText, oFont, nFsz, nTargetW)
		_lbW_ = 0
		for _lbI_ in _lbL_
			if isObject(oFont) and oFont.WidthOf(_lbI_, nFsz) > _lbW_
				_lbW_ = oFont.WidthOf(_lbI_, nFsz)
			ok
		next
		return [ _lbL_, _lbW_ + 8, len(_lbL_) * (nFsz * 1.35) + 6 ]

	def _LabelDemand(oFont, nFsz, nBoxW, nSlot, bSwap)
		_ids_ = This.NodesIds()
		_nn_ = len(_ids_)
		_dem_ = []
		for _i_ = 1 to _nn_  _dem_ + 0  next
		if NOT isObject(oFont)  return _dem_  ok
		if nSlot <= 0  return _dem_  ok

		_pos_ = []
		for _i_ = 1 to _nn_  _pos_ + [ StzLower("" + _ids_[_i_]), _i_ ]  next

		for _e_ in This.Edges()
			_cl_ = StzTrim("" + _e_[:label])
			if _cl_ = ""  loop  ok
			# a self-loop's label is drawn beside the node, not between
			# ranks, and the derived-size pass already reserves for it
			if StzLower("" + _e_[:from]) = StzLower("" + _e_[:to])  loop  ok
			_at_ = 0
			for _p_ in _pos_
				if _p_[1] = StzLower("" + _e_[:to])  _at_ = _p_[2]  exit  ok
			next
			if _at_ = 0  loop  ok
			# WRAPPED, because that is what will be drawn. The width the
			# demand buys and the width the label occupies have to be the
			# same number, and wrapping is where they would drift apart.
			_blk_ = This._LabelBlock(_cl_, oFont, nFsz, nBoxW)
			_w_ = _blk_[2] + 2
			if bSwap
				# ranks run horizontally, so the label's HEIGHT is what
				# competes along the slot axis
				_w_ = _blk_[3]
			ok
			# WHAT THE LABEL OCCUPIES, not that divided by where it sits.
			#
			# This asked for the label's width DIVIDED by the placement
			# bias -- the arithmetic of a model where a label at fraction
			# f inherits f of the spread between two targets, so buying
			# w/f of spread yields w of room. That model died when labels
			# were anchored on the drawn ortho path: a label now sits
			# where its own edge has room, which is nowhere near a fixed
			# fraction. The division stayed, and at bias 0.5 it demanded
			# TWICE the label's width -- a 108px label pushed a 153px
			# pitch out to 277px, and the picture paid for 124px of empty
			# paper per child that no label was standing in.
			#
			# What it needs instead is the LINE IT SITS ON: the label's
			# own width plus a clearance of line showing at each end, so
			# the label reads as centred inside its edge rather than laid
			# across it. That is the Principal's rule stated as a
			# quantity, and it is nearly free -- on the four-way fan it
			# buys 3px of pitch where the old arithmetic bought 124.
			# Slots already that wide demand NOTHING, which is why an
			# ordinary diagram of short labels is untouched.
			_need_ = (_w_ + This._LineClearance() * 2 - nSlot) / 2
			if _need_ <= 0  loop  ok
			_d_ = _need_ / nSlot
			if _d_ > _dem_[_at_]  _dem_[_at_] = _d_  ok
		next
		return _dem_

	# DOES THIS EDGE LEAVE A CLUSTER -- is there a cluster holding the
	# source and not the target? That is a stricter question than
	# 'different membership', and the difference is a whole class of
	# edges: an API inside Backend pointing at a database inside
	# Backend AND Data has different membership from its source, but
	# it leaves nothing -- it goes DEEPER. Reading the looser question
	# sent every such edge out of the side of its box.
	def _LeavesCluster(pcFrom, pcTo)
		_lcF_ = StzLower("" + pcFrom)
		_lcT_ = StzLower("" + pcTo)
		for _lcC_ in @aClusters
			_lcHasF_ = 0
			_lcHasT_ = 0
			for _lcM_ in _lcC_[:nodes]
				if StzLower("" + _lcM_) = _lcF_  _lcHasF_ = 1  ok
				if StzLower("" + _lcM_) = _lcT_  _lcHasT_ = 1  ok
			next
			if _lcHasF_ and NOT _lcHasT_  return 1  ok
		next
		return 0

	# WHICH CLUSTERS A NODE BELONGS TO, as one comparable string. Two
	# nodes with the same key stand in the same declared context, and two
	# edges reaching them are siblings of the same kind; different keys
	# are a difference the graph itself states, which is the only kind a
	# picture is allowed to draw.
	def _ClusterKeyOf(pcNode)
		_ckN_ = StzLower("" + pcNode)
		_ckK_ = ""
		for _ckC_ in @aClusters
			for _ckM_ in _ckC_[:nodes]
				if StzLower("" + _ckM_) = _ckN_
					_ckK_ += StzLower("" + _ckC_[:id]) + "|"
					exit
				ok
			next
		next
		return _ckK_

	def _ClusterById(pcId)
		_c_ = StzLower("" + pcId)
		for _cl_ in @aClusters
			if StzLower("" + _cl_[:id]) = _c_  return _cl_  ok
		next
		return []

	def _ClusterNodeSet(aCluster)
		_s_ = []
		for _id_ in aCluster[:nodes]  _s_ + StzLower("" + _id_)  next
		return _s_

	def _SetInside(paA, paB)
		for _x_ in paA
			if StzFindFirst(_x_, paB) = 0  return 0  ok
		next
		return 1

	def _SetsOverlap(paA, paB)
		for _x_ in paA
			if StzFindFirst(_x_, paB) > 0  return 1  ok
		next
		return 0

	# How far a self-loop reaches beyond the node box. Named once because
	# TWO places need the same number: the drawing, and the derived-size
	# pass that has to reserve room for it -- a loop drawn into space the
	# canvas does not own is clipped away, which looks exactly like the
	# bug it replaced.
	def _SelfLoopReach(nBoxW, nBoxH)
		return max([ 22, min([ nBoxH * 0.95, 44 ]) ])

	# A loop leaving the node's side and returning to it, as dot draws one:
	# off the RIGHT for a top-down picture, off the TOP when the ranks run
	# left-to-right, so it never points back along the rank axis and gets
	# confused with an ordinary edge.
	# Which way is OUT of the ring from this cell: the loop drawer places
	# a loop on the TOP for a top-down picture and on the RIGHT for a
	# left-to-right one, so naming the outward quadrant in rank terms is
	# how a ring asks for an outward loop without the drawer learning
	# what a ring is.
	def _RingOutward(aAt, nW, nH)
		_dx_ = aAt[1] - nW / 2
		_dy_ = aAt[2] - nH / 2
		if fabs(_dx_) >= fabs(_dy_)
			if _dx_ >= 0  return "TB"  ok      # right cell -> right loop
			return "RINGLEFT"
		ok
		if _dy_ >= 0  return "RINGDOWN"  ok    # bottom cell -> down loop
		return "LR"                            # top cell -> top loop

	def _DrawSelfLoop(oC, aAt, nBoxW, nBoxH, cColor, nWidth, cRank, cSpline)
		_R_ = This._SelfLoopReach(nBoxW, nBoxH)

		# ORTHO MEANS ORTHO, INCLUDING THIS ONE. The loop ignored the spline
		# setting and was always a curve, so a picture asked for
		# splines=ortho came back with every edge right-angled EXCEPT its
		# self-loops -- one rounded shape among the corners, which reads as
		# a mistake rather than a style. A rectangular loop is three
		# segments out of the same side the curve leaves from.
		if cSpline = "ortho"
			if cRank = "RINGDOWN"
				# A RING'S SELF-LOOP RADIATES AWAY FROM THE SPACE. The
				# two rank-derived sides -- top and right -- cover a
				# top or right cell; a cell at the bottom or on the
				# left needs the other two, or its loop is drawn INTO
				# the ring, across the very chords it sits among.
				_od_ = nBoxW * 0.22
				_oy_ = aAt[2] + nBoxH / 2
				_pts_ = [ aAt[1] + _od_, _oy_,
				          aAt[1] + _od_, _oy_ + _R_,
				          aAt[1] - _od_, _oy_ + _R_,
				          aAt[1] - _od_, _oy_ ]
				_oend_ = [ aAt[1] - _od_, _oy_ ]
				_oprev_ = [ aAt[1] - _od_, _oy_ + _R_ ]
			but cRank = "RINGLEFT"
				_od_ = nBoxH * 0.22
				_ox_ = aAt[1] - nBoxW / 2
				_pts_ = [ _ox_, aAt[2] - _od_,
				          _ox_ - _R_, aAt[2] - _od_,
				          _ox_ - _R_, aAt[2] + _od_,
				          _ox_, aAt[2] + _od_ ]
				_oend_ = [ _ox_, aAt[2] + _od_ ]
				_oprev_ = [ _ox_ - _R_, aAt[2] + _od_ ]
			else
				# ONE SIDE FOR EVERY RANK DIRECTION: the right border.
				# The LR form used to put the loop on TOP, where the
				# lifecycle template's return channels live -- the
				# Locked loop was drawn straight across the close and
				# unlock rails. The right border is the one side no
				# channel runs along in either direction, and one side
				# means ONE size reservation.
				# UPWARD, not downward. A loop that leaves high and
				# returns low points its arrow DOWN -- the same direction
				# as every ordinary edge in a top-down picture -- so a
				# self-transition read as flow continuing rather than
				# returning. Leaving low and coming back high makes the
				# arrow oppose the rank direction, which is what says
				# "back to where you were" at a glance.
				_od_ = nBoxH * 0.22
				_ox_ = aAt[1] + nBoxW / 2
				_pts_ = [ _ox_, aAt[2] + _od_,
				          _ox_ + _R_, aAt[2] + _od_,
				          _ox_ + _R_, aAt[2] - _od_,
				          _ox_, aAt[2] - _od_ ]
				_oend_ = [ _ox_, aAt[2] - _od_ ]
				_oprev_ = [ _ox_ + _R_, aAt[2] - _od_ ]
			ok
			# ...and its two corners turn in the same hand as everybody
			# else's. The note above stands either way: what reads as a
			# mistake is ONE shape disagreeing with the rest, whichever
			# shape the rest happens to be.
			if @bRoundElbows
				_slp_ = []
				_slp_ + _pts_[1]  _slp_ + _pts_[2]
				for _sli_ = 1 to len(_pts_) - 5 step 2
					_sla_ = This._ElbowArc(_pts_[_sli_], _pts_[_sli_+1],
						_pts_[_sli_+2], _pts_[_sli_+3],
						_pts_[_sli_+4], _pts_[_sli_+5],
						max([ 5, @nEdgeCornerRad * 0.8 ]))
					if len(_sla_) > 0
						for _slz_ = 1 to len(_sla_)  _slp_ + _sla_[_slz_]  next
					else
						_slp_ + _pts_[_sli_+2]  _slp_ + _pts_[_sli_+3]
					ok
				next
				_slp_ + _pts_[len(_pts_) - 1]  _slp_ + _pts_[len(_pts_)]
				_pts_ = _slp_
			ok
			oC.Flush()
			oC.AddPolylineQ(_pts_).Stroke(cColor, nWidth)
			This._DrawArrow(oC, _oprev_, _oend_, cColor, nWidth, "line", cRank)
			# the loop PUBLISHES its path like any edge, so its label is
			# placed beside its own ink instead of guessed at the node
			_slFlat_ = []
			for _slQ_ = 1 to len(_pts_)  _slFlat_ + _pts_[_slQ_]  next
			This._PublishPath("" + @cSelfLoopId, "" + @cSelfLoopId, _slFlat_)
			return
		ok

		if cRank = "RINGDOWN"
			# a ring cell at the BOTTOM loops downward, away from the space
			_d_ = nBoxW * 0.22
			_p0_ = [ aAt[1] + _d_, aAt[2] + nBoxH / 2 ]
			_c1_ = [ aAt[1] + _d_ + _R_ * 0.4, aAt[2] + nBoxH / 2 + _R_ ]
			_c2_ = [ aAt[1] - _d_ - _R_ * 0.4, aAt[2] + nBoxH / 2 + _R_ ]
			_p3_ = [ aAt[1] - _d_, aAt[2] + nBoxH / 2 ]
		but cRank = "RINGLEFT"
			# ...and one on the LEFT loops leftward, for the same reason
			_d_ = nBoxH * 0.22
			_p0_ = [ aAt[1] - nBoxW / 2, aAt[2] - _d_ ]
			_c1_ = [ aAt[1] - nBoxW / 2 - _R_, aAt[2] - _d_ - _R_ * 0.4 ]
			_c2_ = [ aAt[1] - nBoxW / 2 - _R_, aAt[2] + _d_ + _R_ * 0.4 ]
			_p3_ = [ aAt[1] - nBoxW / 2, aAt[2] + _d_ ]
		else
			# leaves LOW and re-enters HIGH on the right edge, so the
			# arrowhead opposes the rank direction and reads as a return
			_d_ = nBoxH * 0.22
			_p0_ = [ aAt[1] + nBoxW / 2, aAt[2] + _d_ ]
			_c1_ = [ aAt[1] + nBoxW / 2 + _R_, aAt[2] + _d_ + _R_ * 0.4 ]
			_c2_ = [ aAt[1] + nBoxW / 2 + _R_, aAt[2] - _d_ - _R_ * 0.4 ]
			_p3_ = [ aAt[1] + nBoxW / 2, aAt[2] - _d_ ]
		ok

		_pts_ = []
		for _si_ = 0 to 24
			_t_ = _si_ / 24
			_u_ = 1 - _t_
			_pts_ + (_u_*_u_*_u_ * _p0_[1] + 3*_u_*_u_*_t_ * _c1_[1] +
				3*_u_*_t_*_t_ * _c2_[1] + _t_*_t_*_t_ * _p3_[1])
			_pts_ + (_u_*_u_*_u_ * _p0_[2] + 3*_u_*_u_*_t_ * _c1_[2] +
				3*_u_*_t_*_t_ * _c2_[2] + _t_*_t_*_t_ * _p3_[2])
		next
		oC.Flush()
		oC.AddPolylineQ(_pts_).Stroke(cColor, nWidth)

		_n_ = len(_pts_)
		This._DrawArrow(oC, [ _pts_[_n_ - 3], _pts_[_n_ - 2] ], _p3_,
			cColor, nWidth, "line", cRank)

	def _RouteOf(paRoutes, cFrom, cTo)
		_rf_ = StzLower("" + cFrom)
		_rt_ = StzLower("" + cTo)
		for _r_ in paRoutes
			if _r_[1] = _rf_ and _r_[2] = _rt_  return _r_[3]  ok
		next
		return []

	# An edge that spans more than one rank, drawn THROUGH the bend points
	# the layout reserved for it.
	#
	# Without this an edge from rank 1 to rank 9 was a straight line and
	# crossed every box between them -- and no routing rule could have
	# saved it, because the edge had no presence in those ranks for
	# anything to route around. The dummy chain is what gives it one.
	#
	# CATMULL-ROM through the bends rather than a polyline: the bends are
	# where the edge must BE, not where it must turn a corner, and a curve
	# reading smoothly past a box is what distinguishes a routed edge from
	# a dog-leg. Ortho keeps its corners -- that is the point of ortho.
	def RenderClusterRects()
		return @aRenderClusRects

	def RenderNodeRects()
		return @aRenderNodeRects

	def ClaimedChannels()
		return @aChanUsed

	def RenderCrossings()
		return @nRenderCrossings

	def RenderEdgePaths()
		return @aEdgePaths

	# Which edges left their row, and how deep each one runs. Published
	# for the same reason the paths are: a frame has to be tall enough
	# to hold its rails, and an instrument has to be able to ask whether
	# it is -- without either of them re-deriving the answer.
	def LanePlan()
		return @aLaneKept

	def RenderNodeLabels()
		return @aRenderNodeLabels

	def RenderLabels()
		return @aRenderLabels

	def RenderPicks()
		return @aRenderPicks

	# The picture as last drawn. A live session redraws THIS between
	# gestures instead of building a new one -- the difference between a
	# frame that costs a present and a frame that costs a layout.
	def LastCanvas()
		return @oLastCanvas

	#-- READING THE PICTURE BACKWARDS ------------------------------------
	#
	# A pin lives in the layout's coordinate and a cursor lives in
	# pixels. Without a way between them a drag cannot become a pin, and
	# the whole inversion GG7 is about -- the author owns positions --
	# stops at the mouse.
	#
	# The fit is linear (scale and shift into the canvas), so the map is
	# two numbers and its inverse is exact. Both are published because a
	# session needs the round trip: pixels in to place a cell, slots out
	# to show where it will land.
	def SlotAtPixel(pnPx)
		if len(@aSlotMap) != 2 or fabs(@aSlotMap[2]) < 0.000001  return 0  ok
		return (pnPx - @aSlotMap[1]) / @aSlotMap[2]

	def PixelAtSlot(pnSlot)
		if len(@aSlotMap) != 2  return 0  ok
		return @aSlotMap[1] + @aSlotMap[2] * pnSlot

	def SlotMap()
		return @aSlotMap

	#-- THE INTERACTION, as a state machine ------------------------------
	#
	# Not event soup. A pointer that is pressed, moved and released means
	# different things depending on what was under it when it went down,
	# and code that answers each event on its own has to reconstruct that
	# every time -- which is how editors grow flags that contradict each
	# other. Four states cover the whole vocabulary:
	#
	#   idle      nothing is being done
	#   dragging  a cell is following the pointer
	#   linking   an edge is being drawn from a cell
	#   labelling a cell's text is being typed
	#
	# The events are fed in explicitly rather than polled, and that is a
	# design decision, not a convenience: a state machine that reads a
	# window can only be tested by opening one. This one is a function of
	# (state, event) and is therefore testable headless, which is why the
	# guard for it runs in the same suite as everything else. A window
	# session just calls these from what it polled.
	#
	# A DRAG IS ONE UNDO, not one per pointer-move. The cell follows the
	# cursor by pinning directly -- the picture has to keep up -- and the
	# COMMAND is issued once, at release, from the position the cell held
	# when the drag began. Otherwise a single drag would leave a hundred
	# entries in the log and an undo would move the cell one pixel.
	def OnPress(pnX, pnY)
		@cUiState = :Idle
		@cUiSubject = ""
		@aUiRewire = []
		_opAt_ = This.PickAt(pnX, pnY)
		if len(_opAt_) < 2  return This  ok

		# A LINK IS GRABBED BY ITS KNOBS. The author's main verb is
		# managing links -- the Principal's ruling when the editor came
		# alive -- and a link has exactly two places an author can mean:
		# its ends. Pressing an edge near either end picks that end up;
		# the other stays anchored; releasing over a cell is ONE Rewire
		# command. Pressing the middle of an edge is nothing, on purpose:
		# the middle's geometry belongs to the plastic layout, not to the
		# author, so there is nothing there for a gesture to say.
		if _opAt_[1] = :edge
			_opKb_ = This._KnobAt("" + _opAt_[2], "" + _opAt_[3], pnX, pnY)
			if _opKb_ != ""
				@cUiState = :Rewiring
				@cUiSubject = StzLower("" + _opAt_[2] + ">" + _opAt_[3])
				@aUiRewire = [ "" + _opAt_[2], "" + _opAt_[3], _opKb_ ]
			ok
			return This
		ok
		if _opAt_[1] != :node  return This  ok
		@cUiSubject = "" + _opAt_[2]
		# what to restore if this gesture is abandoned, and what the
		# single command at the end has to be an inverse of
		if This.IsPinned(@cUiSubject)
			@aUiWas = [ :movecell, [ @cUiSubject, This._PinOf(@cUiSubject) ] ]
		else
			@aUiWas = [ :freecell, [ @cUiSubject ] ]
		ok
		if @bUiLinking
			@cUiState = :Linking
		else
			@cUiState = :Dragging
		ok
		return This

	# A MOVE PREVIEWS. IT DOES NOT RE-LAY-OUT.
	#
	# Measured before it was designed: re-rendering a 500-node diagram
	# per pointer-move costs 11,675 ms a frame against a 16 ms budget --
	# 730 times over, and no faster scene upload could rescue it, since
	# the cost is the layout and the edge work rather than the drawing.
	# A live editor cannot re-lay-out while a cell is moving, and every
	# editor that feels alive knows it: the cell moves, the picture does
	# not.
	#
	# So a move records where the pointer is and nothing else. The
	# window draws the scene it already has and puts the dragged cell on
	# top of it -- DragPreview() says where -- and the layout runs ONCE,
	# at release, when the author has decided. The model is untouched
	# until then, which is also why an abandoned drag leaves nothing
	# behind: there was nothing to undo.
	def OnMove(pnX, pnY)
		if @cUiState = :Idle  return This  ok
		@aUiAt = [ pnX, pnY ]
		return This

	# Where the gesture currently is: [ subject, x, y ], or [] when
	# nothing is being dragged. What a window paints over the picture.
	def DragPreview()
		if @cUiState = :Idle or @cUiSubject = ""  return []  ok
		if len(@aUiAt) != 2  return []  ok
		return [ @cUiSubject, @aUiAt[1], @aUiAt[2] ]

	def OnRelease(pnX, pnY)
		if @cUiState = :Dragging
			# ONE command, from the position the author chose. The model
			# has not moved until this line, so the log gets a single
			# entry whose inverse is where the cell actually was.
			This.Edit(:MoveCell, [ @cUiSubject, This.SlotAtPixel(pnX) ])
		but @cUiState = :Linking
			_orAt_ = This.PickAt(pnX, pnY)
			if len(_orAt_) = 2 and _orAt_[1] = :node
				if StzLower("" + _orAt_[2]) != StzLower(@cUiSubject)
					This.Edit(:Link, [ @cUiSubject, "" + _orAt_[2] ])
				ok
			ok
		but @cUiState = :Rewiring
			# released over a cell: that end of the link now means THAT
			# cell, as one command. Released over paper: the gesture was
			# abandoned and the model was never touched.
			_orAt_ = This.PickAt(pnX, pnY)
			if len(_orAt_) = 2 and _orAt_[1] = :node and len(@aUiRewire) = 3
				This.Edit(:Rewire, [ @aUiRewire[1], @aUiRewire[2],
					@aUiRewire[3], "" + _orAt_[2] ])
			ok
		ok
		@cUiState = :Idle
		@cUiSubject = ""
		@aUiRewire = []
		return This

	# ABANDONED, not completed: the cell goes back where it was and
	# nothing enters the log. A gesture the author gave up on should
	# leave no trace to undo.
	def OnCancel()
		# nothing to restore: a gesture in progress never touched the
		# model, which is what makes abandoning one free
		@cUiState = :Idle
		@cUiSubject = ""
		@aUiRewire = []
		return This

	# Which end of the edge from>to sits within a knob's reach of (x, y),
	# as "from", "to", or "" for neither. The reach scales with the render
	# -- half a rendered cell's height -- because a literal distance is a
	# bug by construction (I3): the same gesture must work at every scale.
	def _KnobAt(pcFrom, pcTo, pnX, pnY)
		_kaKey_ = StzLower("" + pcFrom + ">" + pcTo)
		_kaR_ = 16
		if len(@aRenderNodeRects) > 0
			_kaR_ = max([ 10, @aRenderNodeRects[1][4] / 2 ])
		ok
		for _kaP_ in @aEdgePaths
			if StzLower("" + _kaP_[1]) != _kaKey_  loop  ok
			_kaF_ = _kaP_[2]
			_kaN_ = len(_kaF_)
			if _kaN_ < 4  loop  ok
			_kaD1_ = sqrt(pow(pnX - _kaF_[1], 2) + pow(pnY - _kaF_[2], 2))
			_kaD2_ = sqrt(pow(pnX - _kaF_[_kaN_-1], 2) + pow(pnY - _kaF_[_kaN_], 2))
			# nearest end wins; outside both reaches, neither
			if _kaD1_ <= _kaR_ and _kaD1_ <= _kaD2_  return "from"  ok
			if _kaD2_ <= _kaR_  return "to"  ok
		next
		return ""

	# During :Rewiring, the pixel of the end that is NOT moving -- what a
	# window draws the ghost line from. [] outside the gesture.
	def RewireAnchor()
		if @cUiState != :Rewiring or len(@aUiRewire) != 3  return []  ok
		_raKey_ = StzLower(@aUiRewire[1] + ">" + @aUiRewire[2])
		for _raP_ in @aEdgePaths
			if StzLower("" + _raP_[1]) != _raKey_  loop  ok
			_raF_ = _raP_[2]
			_raN_ = len(_raF_)
			if _raN_ < 4  loop  ok
			if @aUiRewire[3] = "from"
				# the FROM end is in hand, so the TO end anchors
				return [ _raF_[_raN_-1], _raF_[_raN_] ]
			ok
			return [ _raF_[1], _raF_[2] ]
		next
		return []

	# What the gesture in hand is doing to which link: [ from, to, end ],
	# or [] outside :Rewiring. The window half reads this, the guard
	# asserts on it.
	def UiRewire()
		if @cUiState != :Rewiring  return []  ok
		return @aUiRewire

	# REMOVE THE LINK UNDER THE POINTER, as one logged command. Not a
	# gesture: removal is instantaneous, so it is a verb the window binds
	# to whatever it likes (a key held while clicking, a context action)
	# rather than a state the machine has to carry.
	def RemoveLinkAt(pnX, pnY)
		_rlAt_ = This.PickAt(pnX, pnY)
		if len(_rlAt_) != 3 or _rlAt_[1] != :edge  return FALSE  ok
		return This.Edit(:Unlink, [ "" + _rlAt_[2], "" + _rlAt_[3] ])

	def BeginLinking()
		@bUiLinking = TRUE
		return This

	def EndLinking()
		@bUiLinking = FALSE
		return This

	def BeginLabelling(pcNode)
		if NOT This.NodeExists(pcNode)  return This  ok
		@cUiState = :Labelling
		@cUiSubject = "" + pcNode
		return This

	def CommitLabel(pcText)
		if @cUiState != :Labelling  return FALSE  ok
		_clOk_ = This.Edit(:SetLabel, [ @cUiSubject, "" + pcText ])
		@cUiState = :Idle
		@cUiSubject = ""
		return _clOk_

	def UiState()
		return @cUiState

	def UiSubject()
		return @cUiSubject

	#-- THE SESSION: one poll, one frame ---------------------------------
	#
	# The window half of a live diagram is small on purpose, and it is
	# small because everything above it was built to be driven rather
	# than to drive. Picking reads the retained scene; the state machine
	# is a function of (state, event); the log is over the model's own
	# mutations. So a session is the loop that turns polled input into
	# those calls, and nothing else -- no second rulebook, no parallel
	# graph, no event soup.
	#
	# Step(oWindow) is ONE frame: read what the pointer did, feed the
	# machine, re-render only when the model actually changed, and draw.
	# It answers whether anything changed, so a caller can idle.
	#
	# The re-render is the whole reason a drag previews instead of
	# moving: laying a 500-node diagram out again costs eleven seconds,
	# and a gesture cannot pay that per frame. Structure changes pay it
	# once, where the author expects a pause.
	def Step(oWindow, paOptions)
		if NOT isObject(oWindow)  return FALSE  ok
		if NOT isList(paOptions)  paOptions = []  ok
		oWindow.Poll()

		_stX_ = oWindow.MouseX()
		_stY_ = oWindow.MouseY()
		_stDown_ = oWindow.MouseDown(1)
		_stChanged_ = FALSE

		if _stDown_ and NOT @bUiDown
			This.OnPress(_stX_, _stY_)
		but _stDown_ and @bUiDown
			This.OnMove(_stX_, _stY_)
		but NOT _stDown_ and @bUiDown
			_stBefore_ = len(@aUndo)
			This.OnRelease(_stX_, _stY_)
			if len(@aUndo) != _stBefore_  _stChanged_ = TRUE  ok
		ok
		@bUiDown = _stDown_

		# THE PICTURE IS REBUILT ONLY WHEN THE MODEL MOVED. A frame that
		# re-lays-out because the pointer twitched is the 730x cost this
		# design exists to avoid.
		if _stChanged_ or NOT isObject(@oLastCanvas)
			This.ToCanvasXT(paOptions)
		ok
		if isObject(@oLastCanvas)
			oWindow.Draw(@oLastCanvas)
		ok
		return _stChanged_

	# The loop, for a caller that has nothing else to do. Answers when the
	# window closes.
	def RunIn(oWindow, paOptions)
		if NOT isObject(oWindow)  return This  ok
		while oWindow.IsOpen()
			This.Step(oWindow, paOptions)
		end
		return This

	#-- EDITS: the session executes COMMANDS, never mutations ------------
	#
	# A live editor that mutates the model directly can offer no undo, so
	# nothing here mutates: every edit is a command with an inverse, and
	# the log is the session's memory. mxGraph's model, and the reason it
	# has one -- an editor without undo is an editor nobody trusts enough
	# to explore with.
	#
	# The commands go through the EXISTING mutation API and its existing
	# refusals, so every guard in this plane governs the editor for free
	# and a refused edit surfaces as feedback rather than as a second
	# rulebook. That was the design decision: the model stays stzDiagram,
	# and a session is state ALONGSIDE it, not a parallel graph.
	#
	# Five commands cover the editor's whole vocabulary:
	#   MoveCell   pin a cell somewhere      <-> pin it back (or unpin)
	#   AddCell    a node exists             <-> it does not
	#   RemoveCell a node is gone            <-> it is back, with its edges
	#   Link       an edge exists            <-> it does not
	#   SetLabel   a node reads this         <-> it read that
	# NOT Do() -- "do" is a Ring keyword (do...again), so a method named
	# for it is a parse error four hundred lines away from anything that
	# looks wrong. Edit() says what it does anyway.
	def Edit(pcKind, paArgs)
		_dcK_ = StzLower("" + pcKind)
		if NOT isList(paArgs)  paArgs = []  ok
		_dcInv_ = This._ApplyEdit(_dcK_, paArgs)
		if len(_dcInv_) = 0  return FALSE  ok
		# a fresh edit closes the redo branch: the future it led to is
		# not the future this edit leads to
		@aRedo = []
		@aUndo + [ _dcK_, paArgs, _dcInv_[1], _dcInv_[2] ]
		return TRUE

	def Undo()
		if len(@aUndo) = 0  return FALSE  ok
		_uE_ = @aUndo[ len(@aUndo) ]
		_uNew_ = []
		for _uI_ = 1 to len(@aUndo) - 1  _uNew_ + @aUndo[_uI_]  next
		@aUndo = _uNew_
		This._ApplyEdit(_uE_[3], _uE_[4])
		@aRedo + _uE_
		return TRUE

	def Redo()
		if len(@aRedo) = 0  return FALSE  ok
		_rE_ = @aRedo[ len(@aRedo) ]
		_rNew_ = []
		for _rI_ = 1 to len(@aRedo) - 1  _rNew_ + @aRedo[_rI_]  next
		@aRedo = _rNew_
		This._ApplyEdit(_rE_[1], _rE_[2])
		@aUndo + _rE_
		return TRUE

	def CanUndo()
		return len(@aUndo) > 0

	def CanRedo()
		return len(@aRedo) > 0

	def EditLog()
		return @aUndo

	def ClearEditLog()
		@aUndo = []
		@aRedo = []
		return This

	# Perform one edit and answer its INVERSE as [ kind, args ], or [] if
	# the edit was refused. The inverse is computed BEFORE the change,
	# because afterwards the information it needs is gone -- a removed
	# node's label and edges cannot be read from a model that no longer
	# holds them.
	def _ApplyEdit(pcKind, paArgs)
		switch StzLower("" + pcKind)
		on "movecell"
			if len(paArgs) < 2  return []  ok
			_aeId_ = "" + paArgs[1]
			if This.IsPinned(_aeId_)
				_aeWas_ = [ :movecell, [ _aeId_, This._PinOf(_aeId_) ] ]
			else
				_aeWas_ = [ :freecell, [ _aeId_ ] ]
			ok
			This.Pin(_aeId_, paArgs[2])
			return _aeWas_

		on "freecell"
			if len(paArgs) < 1  return []  ok
			_aeId_ = "" + paArgs[1]
			if NOT This.IsPinned(_aeId_)  return []  ok
			_aeWas_ = [ :movecell, [ _aeId_, This._PinOf(_aeId_) ] ]
			This.Unpin(_aeId_)
			return _aeWas_

		on "addcell"
			if len(paArgs) < 1  return []  ok
			_aeId_ = "" + paArgs[1]
			if This.NodeExists(_aeId_)  return []  ok
			_aeLb_ = _aeId_
			if len(paArgs) >= 2  _aeLb_ = "" + paArgs[2]  ok
			This.AddNodeXT(_aeId_, _aeLb_)
			return [ :removecell, [ _aeId_ ] ]

		on "removecell"
			if len(paArgs) < 1  return []  ok
			_aeId_ = "" + paArgs[1]
			if NOT This.NodeExists(_aeId_)  return []  ok
			# THE EDGES GO WITH IT, so the inverse has to carry them:
			# undoing a removal that silently dropped three edges would
			# restore a node into a graph it is no longer part of.
			_aeLb_ = "" + This.NodeLabel(_aeId_)
			_aeEd_ = []
			for _aeE_ in This.Edges()
				if StzLower("" + _aeE_[:from]) = StzLower(_aeId_) or
				   StzLower("" + _aeE_[:to]) = StzLower(_aeId_)
					_aeEd_ + [ "" + _aeE_[:from], "" + _aeE_[:to] ]
				ok
			next
			This.RemoveThisNode(_aeId_)
			return [ :restorecell, [ _aeId_, _aeLb_, _aeEd_ ] ]

		on "restorecell"
			if len(paArgs) < 2  return []  ok
			_aeId_ = "" + paArgs[1]
			if This.NodeExists(_aeId_)  return []  ok
			This.AddNodeXT(_aeId_, "" + paArgs[2])
			if len(paArgs) >= 3 and isList(paArgs[3])
				for _aeP_ in paArgs[3]
					if len(_aeP_) = 2  This.AddEdge(_aeP_[1], _aeP_[2])  ok
				next
			ok
			return [ :removecell, [ _aeId_ ] ]

		on "link"
			if len(paArgs) < 2  return []  ok
			# THE NOTATION'S RULES ARE THE EDITOR'S REFUSALS (DN0): a
			# link the domain forbids is refused at the gesture, with no
			# editor code knowing any domain.
			if NOT This.NotationO().MayLink(This, "" + paArgs[1], "" + paArgs[2])
				return []
			ok
			This.AddEdge("" + paArgs[1], "" + paArgs[2])
			return [ :unlink, [ "" + paArgs[1], "" + paArgs[2] ] ]

		on "unlink"
			if len(paArgs) < 2  return []  ok
			This.RemoveThisEdge("" + paArgs[1], "" + paArgs[2])
			return [ :link, [ "" + paArgs[1], "" + paArgs[2] ] ]

		on "rewire"
			# [ from, to, whichEnd, newNode ]: the link from>to now ends
			# (or begins) at newNode instead. ONE command, not an unlink
			# plus a link, so one undo restores the link the author had --
			# an edit that leaves two entries needs two undos to take
			# back, and the author made one gesture.
			if len(paArgs) < 4  return []  ok
			_aeF_ = "" + paArgs[1]
			_aeT_ = "" + paArgs[2]
			_aeEnd_ = StzLower("" + paArgs[3])
			_aeNew_ = "" + paArgs[4]
			if NOT This.EdgeExists(_aeF_, _aeT_)  return []  ok
			if NOT This.NodeExists(_aeNew_)  return []  ok
			if _aeEnd_ = "to"
				_aeF2_ = _aeF_
				_aeT2_ = _aeNew_
				_aeBack_ = _aeT_
			but _aeEnd_ = "from"
				_aeF2_ = _aeNew_
				_aeT2_ = _aeT_
				_aeBack_ = _aeF_
			else
				return []
			ok
			# dropping the knob back where it came from is not an edit,
			# and a pair the graph already holds is refused BEFORE the
			# old link is touched -- a refused rewire must change nothing
			if StzLower(_aeF2_ + ">" + _aeT2_) = StzLower(_aeF_ + ">" + _aeT_)
				return []
			ok
			if This.EdgeExists(_aeF2_, _aeT2_)  return []  ok
			# the same notation gate as Link -- asked of the graph WITHOUT
			# the edge being re-aimed, or a from-end rewire under a
			# one-parent rule would refuse itself: the old edge into the
			# same target is the one being replaced, and counting it makes
			# every target look already-parented. Remove, ask, and put it
			# back on refusal, so a refused rewire still changes nothing.
			This.RemoveThisEdge(_aeF_, _aeT_)
			if NOT This.NotationO().MayLink(This, _aeF2_, _aeT2_)
				This.AddEdge(_aeF_, _aeT_)
				return []
			ok
			This.AddEdge(_aeF2_, _aeT2_)
			return [ :rewire, [ _aeF2_, _aeT2_, _aeEnd_, _aeBack_ ] ]

		on "setlabel"
			if len(paArgs) < 2  return []  ok
			_aeId_ = "" + paArgs[1]
			if NOT This.NodeExists(_aeId_)  return []  ok
			_aeWas_ = "" + This.NodeLabel(_aeId_)
			This.SetNodeLabel(_aeId_, "" + paArgs[2])
			return [ :setlabel, [ _aeId_, _aeWas_ ] ]
		off
		return []

	def _PinOf(pcNode)
		_poN_ = StzLower("" + pcNode)
		for _poP_ in @aPins
			if _poP_[1] = _poN_  return _poP_[2]  ok
		next
		return 0

	#-- PINS: the layout advises, the author decides ---------------------
	#
	# The batch pipeline lets the layout own positions. A live diagram
	# inverts that: a cell someone has placed by hand is PINNED, and no
	# pass may argue with it -- not the relaxation, not the territories,
	# not the alignment, not the centring. Unpinned cells are laid out
	# around the pins as they stand.
	#
	# Pinned in SLOT units, the layout's own coordinate, so a pin means
	# the same thing whatever size the picture is rendered at. That is
	# what makes a pin survive a re-render, which is the only reason to
	# have one.
	def Pin(pcNode, nSlotX)
		_pnN_ = StzLower("" + pcNode)
		for _pnI_ = 1 to len(@aPins)
			if @aPins[_pnI_][1] = _pnN_
				@aPins[_pnI_][2] = nSlotX
				return This
			ok
		next
		@aPins + [ _pnN_, nSlotX ]
		return This

	def Unpin(pcNode)
		_pnN_ = StzLower("" + pcNode)
		_pnNew_ = []
		for _pnP_ in @aPins
			if _pnP_[1] != _pnN_  _pnNew_ + _pnP_  ok
		next
		@aPins = _pnNew_
		return This

	def UnpinAll()
		@aPins = []
		return This

	def IsPinned(pcNode)
		_pnN_ = StzLower("" + pcNode)
		for _pnP_ in @aPins
			if _pnP_[1] = _pnN_  return TRUE  ok
		next
		return FALSE

	def Pins()
		return @aPins

	# The pins as the layout tier wants them: one number per node, in
	# node order, with -999999999 for "free". Built here because this is
	# the tier that knows which name is which node.
	def _PinVector()
		_pvIds_ = This.NodesIds()
		_pvOut_ = []
		for _pvI_ = 1 to len(_pvIds_)
			_pvV_ = 0 - 999999999
			_pvN_ = StzLower("" + _pvIds_[_pvI_])
			for _pvP_ in @aPins
				if _pvP_[1] = _pvN_  _pvV_ = _pvP_[2]  exit  ok
			next
			_pvOut_ + _pvV_
		next
		return _pvOut_

	# WHAT IS AT THIS POINT OF THE LAST PICTURE -- [ :node, id ],
	# [ :edge, from, to ], or [] for bare paper.
	#
	# This is the batch pipeline's one-way street opened: model, layout
	# and paint each own their successor, so the picture could never be
	# asked anything. Now it can, and the answer is in the GRAPH's terms
	# rather than the display list's, because the face tags what it draws
	# as it draws it.
	#
	# The reading itself is engine work over the retained command list --
	# no copy, one crossing per question -- which is what makes it fast
	# enough to sit under a cursor.
	def PickAt(pnX, pnY)
		return This.PickAtXT(pnX, pnY, 3)

	def PickAtXT(pnX, pnY, pnTol)
		if NOT isObject(@oLastCanvas)  return []  ok
		_pkT_ = @oLastCanvas.PickXT(pnX, pnY, pnTol)
		if _pkT_ = 0  return []  ok
		for _pkR_ in @aRenderPicks
			if _pkR_[1] = _pkT_
				if _pkR_[2] = "node"  return [ :node, _pkR_[3] ]  ok
				return [ :edge, _pkR_[3], _pkR_[4] ]
			ok
		next
		return []

	# Score one candidate label spot: the distance from the label's plate
	# to the nearest FOREIGN edge ink, or -1 when the spot is unusable
	# (it overlaps an already-placed label, or a node box). Zero means
	# the plate would ERASE foreign ink -- the caller treats that as the
	# worst legal answer, never as a hit to accept.
	def _LabelSpotScore(nLx, nLy, nLw, nLh, cOwnKey, paDone)
		_lsL_ = nLx - nLw / 2
		_lsT_ = nLy - nLh / 2
		# OFF THE PAPER IS NOT A SPOT. Beside-the-edge placement gave the
		# leftmost label of a fan an empty margin to move into, and it
		# moved there -- off the canvas, where the picture is not. A spot
		# outside the paper is refused like any other occupied one, so
		# the label tries its edge's OTHER side instead.
		if @nRenderW > 0 and @nRenderH > 0
			if _lsL_ < 0 or _lsT_ < 0 or
			   _lsL_ + nLw > @nRenderW or _lsT_ + nLh > @nRenderH
				return -1
			ok
		ok
		for _lsD_ in paDone
			if fabs(nLx - _lsD_[1]) < (nLw + _lsD_[3]) / 2 and
			   fabs(nLy - _lsD_[2]) < (nLh + _lsD_[4]) / 2
				return -1
			ok
		next
		# A CELL IS INK TOO, and a label must CLEAR it, not merely miss
		# it. Refusing only overlap let a word sit flush against a
		# node's underside once labels moved beside their lines --
		# legible by a pixel, and read as belonging to the cell rather
		# than to the line. The same clearance every other pair of marks
		# in this picture gets.
		_lsG_ = This._LineClearance() * 0.5
		# A FRAME'S RULE IS INK TOO. A label straddling a region's
		# boundary erases the rule under it -- the plate now takes the
		# surface, and on a boundary there are two surfaces, so it must
		# get one wrong. Kept off the line entirely instead.
		for _lsC_ in @aRenderClusRects
			for _lsE_ = 1 to 2
				_lsY_ = _lsC_[2]
				if _lsE_ = 2  _lsY_ = _lsC_[2] + _lsC_[4]  ok
				if nLx + nLw / 2 < _lsC_[1] or
				   nLx - nLw / 2 > _lsC_[1] + _lsC_[3]  loop  ok
				if fabs(nLy - _lsY_) < nLh / 2 + 3  return -1  ok
			next
		next
		for _lsN_ in @aRenderNodeRects
			if _lsL_ < _lsN_[1] + _lsN_[3] + _lsG_ and
			   _lsL_ + nLw > _lsN_[1] - _lsG_ and
			   _lsT_ < _lsN_[2] + _lsN_[4] + _lsG_ and
			   _lsT_ + nLh > _lsN_[2] - _lsG_
				return -1
			ok
		next
		_lsMin_ = 1000000
		for _lsP_ in @aEdgePaths
			if _lsP_[1] = cOwnKey  loop  ok
			_lsF_ = _lsP_[2]
			for _lsI_ = 1 to len(_lsF_) - 3 step 2
				_lsAx_ = min([ _lsF_[_lsI_], _lsF_[_lsI_ + 2] ])
				_lsBx_ = max([ _lsF_[_lsI_], _lsF_[_lsI_ + 2] ])
				_lsAy_ = min([ _lsF_[_lsI_ + 1], _lsF_[_lsI_ + 3] ])
				_lsBy_ = max([ _lsF_[_lsI_ + 1], _lsF_[_lsI_ + 3] ])
				_lsDx_ = 0
				if _lsBx_ < _lsL_  _lsDx_ = _lsL_ - _lsBx_  ok
				if _lsAx_ > _lsL_ + nLw  _lsDx_ = _lsAx_ - (_lsL_ + nLw)  ok
				_lsDy_ = 0
				if _lsBy_ < _lsT_  _lsDy_ = _lsT_ - _lsBy_  ok
				if _lsAy_ > _lsT_ + nLh  _lsDy_ = _lsAy_ - (_lsT_ + nLh)  ok
				_lsD2_ = sqrt(_lsDx_ * _lsDx_ + _lsDy_ * _lsDy_)
				if _lsD2_ < _lsMin_  _lsMin_ = _lsD2_  ok
			next
		next
		return _lsMin_

	# THE MINIMUM DISTANCE BETWEEN AN EDGE LINE AND ANY PARALLEL LINE -- a
	# frame rule, another channel. Named because it is a LEGIBILITY
	# quantity, not a geometric one: two lines a few pixels apart are
	# distinct on a good screen at 100% and one thick line to tired eyes
	# or in a thumbnail. Derived from the corner radius because that is
	# already scaled by :Scale, so the clearance grows with the render
	# instead of collapsing relative to it -- the fate of every literal
	# distance this file has shipped.
	def _LineClearance()
		return max([ 14, @nEdgeCornerRad * 2 + 4 ])

	# WHERE A CHANNEL BELONGS: the MIDDLE of the free band it runs in.
	#
	# The first version pushed a channel a fixed clearance off whatever
	# cluster frame it crossed -- and pushed it straight into the node row
	# on the other side, which is the same illegibility seen from above.
	# Clearance from ONE obstacle is not placement. A band bounded by two
	# obstacles has a centre, and the centre is the only position that
	# treats both sides fairly and survives being miniaturised.
	#
	# Obstacles are foreign cluster frames AND node rows -- everything the
	# run passes that a reader could mistake it for touching. The edge's
	# own endpoints are exempt (it must reach them) and so are clusters it
	# belongs to (its frame is its home). Bounded on both sides: take the
	# centre. Bounded on one: stand a clearance off it. Bounded on
	# neither: stay where the router put it.
	#
	# bVert says which axis the channel RUNS along: 0 = horizontal (a
	# top-down picture), 1 = vertical (left-to-right). The rule is the
	# same rule on the other axis, which is what makes it one rule.
	# The merged blocked intervals a channel with this span must avoid --
	# foreign cluster surfaces and foreign node rows, endpoints exempt.
	# Factored out of _ChannelBand so the CLAIMER can test a stepped lane
	# against the same obstacles: its first revalidation asked _ChannelBand
	# to return the candidate unchanged, but the band always recentres to
	# the gap's middle, so every honest step candidate failed the test and
	# two foreign channels fell back onto ONE shared lane -- K2,2's two
	# trunks drew a single line both ways.
	# IS THIS STRAIGHT LEG ACTUALLY CLEAR? Asked of the obstacles
	# themselves, because asking _ChannelBand whether it returns the
	# position unchanged asks the wrong question: the band RECENTRES
	# any proposal lying in an interior gap to that gap's middle, so a
	# perfectly clear column comes back moved and reads as blocked.
	#
	# That is the second time this exact confusion has cost a picture --
	# the channel claimer had it too, and its stepped lanes silently
	# shared a line for it. A predicate must not be built out of a
	# function whose job is to MOVE things.
	def _LegIsClear(nPos, nA1, nA2, cFrom, cTo, bVert)
		_lcB_ = This._ChannelBlocked(nA1, nA2, cFrom, cTo, bVert)
		_lcC_ = This._LineClearance() * 0.5
		for _lcI_ in _lcB_
			if nPos > _lcI_[1] - _lcC_ and nPos < _lcI_[2] + _lcC_
				return FALSE
			ok
		next
		return TRUE

	def _ChannelBlocked(nA1, nA2, cFrom, cTo, bVert)
		_cbLo_ = min([ nA1, nA2 ])
		_cbHi_ = max([ nA1, nA2 ])
		_cbF_ = StzLower("" + cFrom)
		_cbT_ = StzLower("" + cTo)
		_cbBl_ = []
		for _cbPass_ = 1 to 2
			if _cbPass_ = 1
				_cbSet_ = @aRenderClusRects
			else
				_cbSet_ = @aRenderNodeRects
			ok
			for _cbR_ in _cbSet_
				if _cbPass_ = 1
					if StzFindFirst(_cbF_, _cbR_[5]) > 0  loop  ok
					if StzFindFirst(_cbT_, _cbR_[5]) > 0  loop  ok
				else
					if _cbR_[5] = _cbF_ or _cbR_[5] = _cbT_  loop  ok
				ok
				if bVert
					_cbA_ = _cbR_[2]
					_cbB_ = _cbR_[2] + _cbR_[4]
					_cbC_ = _cbR_[1]
					_cbD_ = _cbR_[1] + _cbR_[3]
				else
					_cbA_ = _cbR_[1]
					_cbB_ = _cbR_[1] + _cbR_[3]
					_cbC_ = _cbR_[2]
					_cbD_ = _cbR_[2] + _cbR_[4]
				ok
				if _cbHi_ <= _cbA_ or _cbLo_ >= _cbB_  loop  ok
				_cbBl_ + [ _cbC_, _cbD_ ]
			next
		next
		if len(_cbBl_) = 0  return []  ok
		_cbBl_ = sort(_cbBl_, 1)
		_cbM_ = []
		for _cbI_ = 1 to len(_cbBl_)
			if len(_cbM_) > 0 and _cbBl_[_cbI_][1] <= _cbM_[len(_cbM_)][2]
				if _cbBl_[_cbI_][2] > _cbM_[len(_cbM_)][2]
					_cbM_[len(_cbM_)][2] = _cbBl_[_cbI_][2]
				ok
			else
				_cbM_ + [ _cbBl_[_cbI_][1], _cbBl_[_cbI_][2] ]
			ok
		next
		return _cbM_

	def _ChannelBand(nPos, nA1, nA2, cFrom, cTo, bVert, nLimA, nLimB)
		# BLOCKED INTERVALS, MERGED -- not "the nearest face either side".
		# That shortcut was wrong whenever the proposed channel fell
		# INSIDE an obstacle: it recorded that obstacle's near face as a
		# bound and then centred between it and something beyond, landing
		# the channel back inside the very rect it was escaping. Free
		# space is what is left after the blocked spans are unioned, and
		# nothing shorter than computing that union answers it.
		_cbM_ = This._ChannelBlocked(nA1, nA2, cFrom, cTo, bVert)
		# THE CORRIDOR IS LAW. A single-hop channel lives between its two
		# attachment borders and a routed one between its fold points;
		# free space OUTSIDE that range is not usable however empty it is.
		# Without this the placer once chose a lovely clear band ABOVE the
		# source's own bottom border, and the trunk obediently folded
		# BACKWARD up the side of the box it had just left.
		_cbLimLo_ = min([ nLimA, nLimB ]) + 4
		_cbLimHi_ = max([ nLimA, nLimB ]) - 4
		if _cbLimHi_ < _cbLimLo_
			_cbLimLo_ = (nLimA + nLimB) / 2
			_cbLimHi_ = _cbLimLo_
		ok
		if len(_cbM_) = 0  return min([ max([ nPos, _cbLimLo_ ]), _cbLimHi_ ])  ok

		# the free gaps between merged blocks, plus the open ends
		_cbClr_ = This._LineClearance()
		_cbBest_ = nPos
		_cbBestD_ = 1000000
		_cbNM_ = len(_cbM_)
		for _cbI_ = 0 to _cbNM_
			if _cbI_ = 0
				_cbGa_ = _cbM_[1][1] - 1000000
				_cbGb_ = _cbM_[1][1]
				_cbCand_ = _cbGb_ - _cbClr_
			but _cbI_ = _cbNM_
				_cbGa_ = _cbM_[_cbNM_][2]
				_cbGb_ = _cbGa_ + 1000000
				_cbCand_ = _cbGa_ + _cbClr_
			else
				_cbGa_ = _cbM_[_cbI_][2]
				_cbGb_ = _cbM_[_cbI_ + 1][1]
				if _cbGb_ - _cbGa_ < 1  loop  ok
				_cbCand_ = (_cbGa_ + _cbGb_) / 2
			ok
			# an open end keeps the router's own position when that
			# position already lies in it
			if _cbI_ = 0 and nPos <= _cbGb_ - _cbClr_  _cbCand_ = nPos  ok
			if _cbI_ = _cbNM_ and nPos >= _cbGa_ + _cbClr_  _cbCand_ = nPos  ok
			# A GAP IS NOT DISQUALIFIED BY ITS CENTRE. This dropped any
			# gap whose preferred position fell outside the corridor,
			# even when the gap and the corridor plainly OVERLAP -- and
			# a channel with no candidate left falls back to its raw
			# proposal, which is the one position nothing has checked.
			# That is how an edge came to run 21px from a foreign
			# cluster's frame with a 24px clearance in force: the gap
			# above that frame was usable from 387 to 445, the corridor
			# started at 387, and the gap was thrown away because its
			# MIDDLE sat at 343.
			#
			# So when the centre is unreachable, the gap still offers
			# what it has: the position nearest the proposal that keeps
			# a clearance from both blocks and stays inside the
			# corridor. Only a gap whose usable part is EMPTY is not a
			# candidate.
			if _cbCand_ < _cbLimLo_ or _cbCand_ > _cbLimHi_
				_cbLo2_ = _cbGa_ + _cbClr_
				_cbHi2_ = _cbGb_ - _cbClr_
				if _cbLo2_ < _cbLimLo_  _cbLo2_ = _cbLimLo_  ok
				if _cbHi2_ > _cbLimHi_  _cbHi2_ = _cbLimHi_  ok
				if _cbHi2_ < _cbLo2_  loop  ok
				_cbCand_ = min([ max([ nPos, _cbLo2_ ]), _cbHi2_ ])
			ok
			_cbD2_ = fabs(_cbCand_ - nPos)
			if _cbD2_ < _cbBestD_
				_cbBestD_ = _cbD2_
				_cbBest_ = _cbCand_
			ok
		next
		if _cbBestD_ >= 1000000
			# every free band lies outside the corridor: the least-bad
			# honest answer is the proposal clamped into it
			return min([ max([ nPos, _cbLimLo_ ]), _cbLimHi_ ])
		ok
		return _cbBest_

	# Grant a channel lane: the banded position if free, else the nearest
	# clearance-stepped lane inside the corridor that no FOREIGN channel
	# holds. Same-source channels share by design -- that is the trunk of
	# a fan, one line because it is one origin.
	def _ClaimChannel(nY, nSpanA, nSpanB, cSrc, nLimA, nLimB, cFrom2, cTo2, bVert2)
		_ccLo_ = min([ nSpanA, nSpanB ])
		_ccHi_ = max([ nSpanA, nSpanB ])

		# A ZERO-WIDTH CHANNEL IS NOT A LINE. An aligned edge's trunk has
		# no horizontal run at all, yet it registered a degenerate span --
		# and its phantom "channel" then forced a REAL channel to step two
		# lanes away, off the band's centre and into the frame the band
		# had just escaped. Only ink a reader can see may claim a lane.
		if _ccHi_ - _ccLo_ < 2  return nY  ok

		_ccS_ = StzLower("" + cSrc)

		# ONE STEM, OR CLEARLY TWO. Channels from the SAME source are
		# allowed to share a line -- that is the bus a fan draws, one
		# line because it is one origin -- but nothing made them
		# actually COINCIDE, and each was banded independently against
		# its own span's obstacles. On the service diagram two channels
		# out of the same web tier landed 9px apart with a 24px
		# clearance in force: neither one line nor two, which is the
		# near-miss this library forbids everywhere else and was
		# producing in its own default picture.
		#
		# So a channel that lands within a clearance of one its own
		# source already holds joins it exactly -- but only if that
		# height is legal for THIS span, since the two spans meet
		# different obstacles and sharing must never mean colliding.
		for _ccJ_ in @aChanUsed
			if _ccJ_[3] != _ccS_  loop  ok
			if fabs(_ccJ_[4] - nY) < 0.5  return _ccJ_[4]  ok
			if fabs(_ccJ_[4] - nY) >= This._LineClearance()  loop  ok
			if NOT This._LegIsClear(_ccJ_[4], nSpanA, nSpanB,
				cFrom2, cTo2, bVert2)
				loop
			ok
			@aChanUsed + [ min([ nSpanA, nSpanB ]), max([ nSpanA, nSpanB ]),
				_ccS_, _ccJ_[4] ]
			return _ccJ_[4]
		next
		_ccClr_ = This._LineClearance()
		_ccLimLo_ = min([ nLimA, nLimB ]) + 4
		_ccLimHi_ = max([ nLimA, nLimB ]) - 4
		# A STEPPED CANDIDATE OBEYS THE SAME OBSTACLES AS THE FIRST.
		# Without this, dodging a sibling channel walked candidates
		# straight into a foreign cluster -- the claimer undoing the
		# band's work one clearance at a time. Tested against the blocked
		# intervals THEMSELVES: the first version asked _ChannelBand to
		# return the candidate unchanged, but the band recentres every
		# interior proposal to its gap's middle, so every honest step
		# failed the test and conflicting channels shared one lane.
		_ccBlk_ = This._ChannelBlocked(nSpanA, nSpanB, cFrom2, cTo2, bVert2)
		for _ccK_ in [ 0, 1, -1, 2, -2, 3, -3 ]
			_ccCand_ = nY + _ccK_ * _ccClr_
			if _ccLimHi_ > _ccLimLo_
				if _ccCand_ < _ccLimLo_ or _ccCand_ > _ccLimHi_  loop  ok
			ok
			if _ccK_ != 0
				_ccHit_ = 0
				for _ccB2_ in _ccBlk_
					if _ccCand_ > _ccB2_[1] - 3 and _ccCand_ < _ccB2_[2] + 3
						_ccHit_ = 1
						exit
					ok
				next
				if _ccHit_  loop  ok
			ok
			_ccBad_ = 0
			for _ccU_ in @aChanUsed
				if _ccU_[3] = _ccS_  loop  ok
				if _ccHi_ > _ccU_[1] and _ccLo_ < _ccU_[2] and
				   fabs(_ccCand_ - _ccU_[4]) < _ccClr_ * 0.9
					_ccBad_ = 1
					exit
				ok
			next
			if _ccBad_ = 0
				@aChanUsed + [ _ccLo_, _ccHi_, _ccS_, _ccCand_ ]
				return _ccCand_
			ok
		next
		@aChanUsed + [ _ccLo_, _ccHi_, _ccS_, nY ]
		return nY

	# Emit an ortho polyline -- or, on the dry pass, only LEARN from it.
	#
	# THE WIRE HOP, from the Principal's electric-diagram rule: where one
	# edge's channel crosses another edge's line, the crossing must read
	# as a NON-junction, so the channel takes a small semicircular hop
	# over the line it does not touch -- exactly as circuit schematics
	# have drawn non-connecting wires for a century. Without it, a
	# crossing and a junction are the same ink, and the reader must guess
	# which the author meant. Same-edge segments never hop each other
	# (their meeting IS a junction), and hops bulge against the rank
	# direction so they read as "over", not "under".
	# THE RETURN LANE OF AN OPPOSITE PAIR: its partner's path, reversed,
	# offset one clearance so the two read as rails of one conversation.
	# Rank-axis legs shift along the slot axis and slot-axis legs along
	# the rank axis -- a true parallel offset, so the corners stay square
	# and the twin can never cross its partner. The ends clamp to the
	# node borders so a wide offset cannot walk off a narrow cell.
	def _DrawTwinEdge(oC, nEi, nEj, paE, paXY, nBoxW, nBoxH, cColor, nWidth, cRank)
		return This._DrawTwinEdgeXT(oC, nEi, nEj, paE, paXY, nBoxW, nBoxH,
			cColor, nWidth, cRank, 1)

	def _DrawTwinEdgeXT(oC, nEi, nEj, paE, paXY, nBoxW, nBoxH, cColor, nWidth, cRank, nLane)
		_twKey_ = StzLower("" + paE[nEj][:from] + ">" + paE[nEj][:to])
		_twP_ = []
		for _twR_ in @aEdgePaths
			if StzLower("" + _twR_[1]) = _twKey_  _twP_ = _twR_[2]  ok
		next
		_twN_ = len(_twP_)
		if _twN_ < 4  return  ok
		_twOff_ = This._LaneOffset(nLane,
			This._BoxOf("" + paE[nEi][:from], nBoxW, nBoxH)[2])
		_bH_ = 0
		if cRank = "LR" or cRank = "RL"  _bH_ = 1  ok

		# offset each segment perpendicular to its own direction, then
		# rebuild the corners from consecutive segment intersections
		_aSegs_ = []
		for _twI_ = 1 to _twN_ - 3 step 2
			_x1_ = _twP_[_twI_]    _y1_ = _twP_[_twI_+1]
			_x2_ = _twP_[_twI_+2]  _y2_ = _twP_[_twI_+3]
			if fabs(_x2_ - _x1_) < 0.5 and fabs(_y2_ - _y1_) < 0.5  loop  ok
			if fabs(_x2_ - _x1_) < 0.5
				# vertical: shift in x
				_aSegs_ + [ 1, _x1_ + _twOff_, min([ _y1_, _y2_ ]),
					max([ _y1_, _y2_ ]) ]
			else
				# horizontal: shift in y
				_aSegs_ + [ 0, _y1_ + _twOff_, min([ _x1_, _x2_ ]),
					max([ _x1_, _x2_ ]) ]
			ok
		next
		_nSg_ = len(_aSegs_)
		if _nSg_ = 0  return  ok

		_twOut_ = []
		# the first end: the partner's start border, offset along it
		if _aSegs_[1][1] = 1
			_twOut_ + [ _aSegs_[1][2], _twP_[2] ]
		else
			_twOut_ + [ _twP_[1], _aSegs_[1][2] ]
		ok
		for _twI_ = 1 to _nSg_ - 1
			_sA_ = _aSegs_[_twI_]
			_sB_ = _aSegs_[_twI_ + 1]
			if _sA_[1] = _sB_[1]  loop  ok
			if _sA_[1] = 1
				_twOut_ + [ _sA_[2], _sB_[2] ]
			else
				_twOut_ + [ _sB_[2], _sA_[2] ]
			ok
		next
		_sZ_ = _aSegs_[_nSg_]
		if _sZ_[1] = 1
			_twOut_ + [ _sZ_[2], _twP_[_twN_] ]
		else
			_twOut_ + [ _twP_[_twN_ - 1], _sZ_[2] ]
		ok

		# REVERSE: the twin runs from the partner's target back to its
		# source, and both ends clamp onto their node borders
		_twRev_ = []
		for _twI_ = len(_twOut_) to 1 step -1
			_twRev_ + [ _twOut_[_twI_][1], _twOut_[_twI_][2] ]
		next
		_aFm_ = This._XYOf(paXY, StzLower("" + paE[nEi][:from]))
		_aTo_ = This._XYOf(paXY, StzLower("" + paE[nEi][:to]))
		# THE END CLAMP FOLLOWS THE END SEGMENT'S AXIS. It pulled every
		# end onto the rank-facing border, which is right for a twin
		# whose last leg is a vertical drop and catastrophic for one
		# whose last leg runs along a row: a return allocated the second
		# lane was dragged straight back onto the first, so two returns
		# into one state were drawn on top of each other however many
		# lanes the allocator handed out. A horizontal end attaches to a
		# SIDE border and keeps its lane.
		_twN2_ = len(_twRev_)
		_bV1_ = 1
		_bV2_ = 1
		if _twN2_ >= 2
			if fabs(_twRev_[1][2] - _twRev_[2][2]) < 0.5  _bV1_ = 0  ok
			if fabs(_twRev_[_twN2_][2] - _twRev_[_twN2_-1][2]) < 0.5  _bV2_ = 0  ok
		ok
		# AN END EITHER SITS ON THE BORDER OR TURNS INTO IT. Keeping a
		# lane and touching the node are not alternatives -- the previous
		# version chose the lane and left the endpoint floating beside
		# the cell (measured: 28px of daylight between an arrow and the
		# state it points at). A horizontal end running in a lane below
		# its node TURNS: it runs to the node's own column and then goes
		# up into the border. One bend, and the line ends on the thing it
		# names, which is I1 and is not negotiable for a lane.
		if len(_aFm_) = 2
			if _bV1_ and NOT _bH_
				_twRev_[1][1] = min([ max([ _twRev_[1][1],
					_aFm_[1] - nBoxW/2 + 4 ]), _aFm_[1] + nBoxW/2 - 4 ])
				_twRev_[1][2] = iif(_twRev_[1][2] < _aFm_[2],
					_aFm_[2] - nBoxH/2, _aFm_[2] + nBoxH/2)
			but NOT _bV1_
				_aFb_ = This._BoxAt(_aFm_, nBoxW, nBoxH)
				if fabs(_twRev_[1][2] - _aFm_[2]) <= _aFb_[2] / 2
					_twRev_[1][1] = iif(_twRev_[1][1] < _aFm_[1],
						_aFm_[1] - _aFb_[1] / 2, _aFm_[1] + _aFb_[1] / 2)
				else
					_aNw_ = [ [ _aFm_[1],
						iif(_twRev_[1][2] < _aFm_[2],
							_aFm_[2] - _aFb_[2] / 2, _aFm_[2] + _aFb_[2] / 2) ],
						[ _aFm_[1], _twRev_[1][2] ] ]
					for _tq_ = 1 to len(_twRev_)  _aNw_ + _twRev_[_tq_]  next
					_twRev_ = _aNw_
					_twN2_ = len(_twRev_)
				ok
			ok
		ok
		if len(_aTo_) = 2
			if _bV2_ and NOT _bH_
				_twRev_[_twN2_][1] = min([ max([ _twRev_[_twN2_][1],
					_aTo_[1] - nBoxW/2 + 4 ]), _aTo_[1] + nBoxW/2 - 4 ])
				_twRev_[_twN2_][2] = iif(_twRev_[_twN2_][2] < _aTo_[2],
					_aTo_[2] - nBoxH/2, _aTo_[2] + nBoxH/2)
			but NOT _bV2_
				_aTb_ = This._BoxAt(_aTo_, nBoxW, nBoxH)
				if fabs(_twRev_[_twN2_][2] - _aTo_[2]) <= _aTb_[2] / 2
					_twRev_[_twN2_][1] = iif(_twRev_[_twN2_][1] < _aTo_[1],
						_aTo_[1] - _aTb_[1] / 2, _aTo_[1] + _aTb_[1] / 2)
				else
					_twRev_[_twN2_][1] = _aTo_[1]
					_twRev_ + [ _aTo_[1],
						iif(_twRev_[_twN2_][2] < _aTo_[2],
							_aTo_[2] - _aTb_[2] / 2, _aTo_[2] + _aTb_[2] / 2) ]
					_twN2_ = len(_twRev_)
				ok
			ok
		ok

		# ...AND THE ENDS TAKE THEIR OWN COLUMNS. Every clamp above puts
		# an end on its node's CENTRE line, which is right until a second
		# edge does the same at the same border: a departure and an
		# arrival then stand on one column running opposite ways, and the
		# Principal read the player exactly as it draws -- one line with
		# an arrowhead at each end, from which no reader can tell which
		# direction is meant. The column comes from the border's own
		# allocation (see _PlanLaneStubs), and the segment feeding the
		# end moves with it so the stub stays vertical.
		_cTwSk_ = StzLower("" + paE[nEi][:from] + ">" + paE[nEi][:to])
		_nTwSa_ = This._StubOf(_cTwSk_, 1)
		_nTwSb_ = This._StubOf(_cTwSk_, 2)
		_nTwR_ = len(_twRev_)
		if NOT _bH_ and _nTwR_ >= 2
			if len(_aFm_) = 2 and fabs(_nTwSa_) > 0.01 and
			   fabs(_twRev_[1][1] - _twRev_[2][1]) < 0.5
				_twRev_[1][1] = _aFm_[1] + _nTwSa_
				_twRev_[2][1] = _aFm_[1] + _nTwSa_
			ok
			if len(_aTo_) = 2 and fabs(_nTwSb_) > 0.01 and
			   fabs(_twRev_[_nTwR_][1] - _twRev_[_nTwR_-1][1]) < 0.5
				_twRev_[_nTwR_][1] = _aTo_[1] + _nTwSb_
				_twRev_[_nTwR_-1][1] = _aTo_[1] + _nTwSb_
			ok
		ok

		_twFlat_ = []
		for _twQ_ in _twRev_
			_twFlat_ + _twQ_[1]
			_twFlat_ + _twQ_[2]
		next
		_cTwKey_ = StzLower("" + paE[nEi][:from] + ">" + paE[nEi][:to])
		if @nDrawPass = 1
			@aEdgePaths + [ _cTwKey_, _twFlat_ ]
			for _twI_ = 1 to len(_twFlat_) - 3 step 2
				if fabs(_twFlat_[_twI_+2] - _twFlat_[_twI_]) < 0.5 and
				   fabs(_twFlat_[_twI_+3] - _twFlat_[_twI_+1]) > 2
					@aVertSegs + [ _twFlat_[_twI_],
						min([ _twFlat_[_twI_+1], _twFlat_[_twI_+3] ]),
						max([ _twFlat_[_twI_+1], _twFlat_[_twI_+3] ]), _cTwKey_ ]
				ok
			next
			return
		ok
		This._EmitOrthoPolyline(oC, _twFlat_, cColor, nWidth, _cTwKey_)
		_nTF_ = len(_twFlat_)
		This._DrawArrow(oC, [ _twFlat_[_nTF_-3], _twFlat_[_nTF_-2] ],
			[ _twFlat_[_nTF_-1], _twFlat_[_nTF_] ], cColor, nWidth,
			"line", cRank)

	# ONE CORNER, TWO CALLERS. The staircase turns corners and so does the
	# self-loop, and the two used to be drawn by different hands -- which
	# is how the loop came to be the one rounded shape in a square picture
	# before, and would have been the one square shape in a rounded one
	# now. The arc lives here so there is a single place that decides what
	# a turn looks like.
	#
	# Returns the quarter arc from p1->p2->p3 as a flat point list, or an
	# empty list when the vertex does not earn one: a straight-through
	# point, a segment too short to give up the radius, or a radius so
	# small the arc is not ink.
	def _ElbowArc(nX1, nY1, nX2, nY2, nX3, nY3, nMaxR)
		_eaAx_ = nX1 - nX2   _eaAy_ = nY1 - nY2
		_eaBx_ = nX3 - nX2   _eaBy_ = nY3 - nY2
		_eaL1_ = sqrt(_eaAx_ * _eaAx_ + _eaAy_ * _eaAy_)
		_eaL2_ = sqrt(_eaBx_ * _eaBx_ + _eaBy_ * _eaBy_)
		if _eaL1_ < 0.5 or _eaL2_ < 0.5  return []  ok
		_eaAx_ = _eaAx_ / _eaL1_   _eaAy_ = _eaAy_ / _eaL1_
		_eaBx_ = _eaBx_ / _eaL2_   _eaBy_ = _eaBy_ / _eaL2_
		# the two legs leave the vertex in opposite directions: no turn
		if fabs(_eaAx_ + _eaBx_) < 0.01 and fabs(_eaAy_ + _eaBy_) < 0.01
			return []
		ok
		_eaR_ = min([ nMaxR, _eaL1_ * 0.40, _eaL2_ * 0.40 ])
		if _eaR_ < 1  return []  ok

		# centre = vertex + r along BOTH legs; the arc then runs from
		# (vertex + r*A) to (vertex + r*B), which is exactly where each
		# leg leaves off
		_eaCx_ = nX2 + _eaR_ * (_eaAx_ + _eaBx_)
		_eaCy_ = nY2 + _eaR_ * (_eaAy_ + _eaBy_)
		_eaOut_ = []
		for _eaS_ = 0 to 6
			_eaT_ = (_eaS_ / 6.0) * 1.5707963
			_eaOut_ + (_eaCx_ - _eaR_ *
				(_eaBx_ * cos(_eaT_) + _eaAx_ * sin(_eaT_)))
			_eaOut_ + (_eaCy_ - _eaR_ *
				(_eaBy_ * cos(_eaT_) + _eaAy_ * sin(_eaT_)))
		next
		return _eaOut_

	def _EmitOrthoPolyline(oC, paFlat, cColor, nWidth, cKey)
		_eoN_ = len(paFlat)
		_eoH_ = 0
		if StzLower("" + This.Layout()) = "lr" or
		   StzLower("" + This.Layout()) = "rl"  _eoH_ = 1  ok

		if @nDrawPass = 1
			# the flat IS the edge's drawn geometry -- keep it, keyed, so
			# the label placer can anchor a label on the path its edge
			# actually takes. Labels were anchored on _EdgePathFlat's
			# pre-channel fiction, so under ortho a label could float in
			# empty space far from its own ink.
			@aEdgePaths + [ cKey, paFlat ]
			# learn the rank-axis segments (the drops a channel can cross)
			for _eoI_ = 1 to _eoN_ - 3 step 2
				_eoX1_ = paFlat[_eoI_]
				_eoY1_ = paFlat[_eoI_ + 1]
				_eoX2_ = paFlat[_eoI_ + 2]
				_eoY2_ = paFlat[_eoI_ + 3]
				if NOT _eoH_ and fabs(_eoX2_ - _eoX1_) < 0.5 and
				   fabs(_eoY2_ - _eoY1_) > 2
					@aVertSegs + [ _eoX1_, min([ _eoY1_, _eoY2_ ]),
						max([ _eoY1_, _eoY2_ ]), cKey ]
				ok
				if _eoH_ and fabs(_eoY2_ - _eoY1_) < 0.5 and
				   fabs(_eoX2_ - _eoX1_) > 2
					@aVertSegs + [ _eoY1_, min([ _eoX1_, _eoX2_ ]),
						max([ _eoX1_, _eoX2_ ]), cKey ]
				ok
			next
			return
		ok

		_eoR_ = max([ 5, @nEdgeCornerRad * 0.8 ])
		_eoOut_ = []
		_eoOut_ + paFlat[1]
		_eoOut_ + paFlat[2]
		for _eoI_ = 1 to _eoN_ - 3 step 2
			_eoX1_ = paFlat[_eoI_]
			_eoY1_ = paFlat[_eoI_ + 1]
			_eoX2_ = paFlat[_eoI_ + 2]
			_eoY2_ = paFlat[_eoI_ + 3]
			_eoCross_ = []
			if NOT _eoH_ and fabs(_eoY2_ - _eoY1_) < 0.5 and
			   fabs(_eoX2_ - _eoX1_) > _eoR_ * 2
				_eoLo_ = min([ _eoX1_, _eoX2_ ])
				_eoHi_ = max([ _eoX1_, _eoX2_ ])
				for _eoV_ in @aVertSegs
					if _eoV_[4] = cKey  loop  ok
					if _eoV_[1] > _eoLo_ + _eoR_ and _eoV_[1] < _eoHi_ - _eoR_ and
					   _eoY1_ > _eoV_[2] + 1 and _eoY1_ < _eoV_[3] - 1
						_eoCross_ + _eoV_[1]
					ok
				next
			ok
			if _eoH_ and fabs(_eoX2_ - _eoX1_) < 0.5 and
			   fabs(_eoY2_ - _eoY1_) > _eoR_ * 2
				_eoLo_ = min([ _eoY1_, _eoY2_ ])
				_eoHi_ = max([ _eoY1_, _eoY2_ ])
				for _eoV_ in @aVertSegs
					if _eoV_[4] = cKey  loop  ok
					if _eoV_[1] > _eoLo_ + _eoR_ and _eoV_[1] < _eoHi_ - _eoR_ and
					   _eoX1_ > _eoV_[2] + 1 and _eoX1_ < _eoV_[3] - 1
						_eoCross_ + _eoV_[1]
					ok
				next
			ok
			if len(_eoCross_) > 0
				_eoCross_ = sort(_eoCross_)
				_eoDir_ = 1
				if NOT _eoH_
					if _eoX2_ < _eoX1_  _eoDir_ = -1  ok
					if _eoDir_ = -1  _eoCross_ = reverse(_eoCross_)  ok
					for _eoC_ in _eoCross_
						_eoOut_ + (_eoC_ - _eoDir_ * _eoR_)
						_eoOut_ + _eoY1_
						for _eoA_ = 1 to 7
							_eoT_ = _eoA_ / 8.0
							_eoOut_ + (_eoC_ - _eoDir_ * _eoR_ * cos(3.14159265 * _eoT_))
							_eoOut_ + (_eoY1_ - _eoR_ * sin(3.14159265 * _eoT_))
						next
						_eoOut_ + (_eoC_ + _eoDir_ * _eoR_)
						_eoOut_ + _eoY1_
					next
				else
					if _eoY2_ < _eoY1_  _eoDir_ = -1  ok
					if _eoDir_ = -1  _eoCross_ = reverse(_eoCross_)  ok
					for _eoC_ in _eoCross_
						_eoOut_ + _eoX1_
						_eoOut_ + (_eoC_ - _eoDir_ * _eoR_)
						for _eoA_ = 1 to 7
							_eoT_ = _eoA_ / 8.0
							_eoOut_ + (_eoX1_ - _eoR_ * sin(3.14159265 * _eoT_))
							_eoOut_ + (_eoC_ - _eoDir_ * _eoR_ * cos(3.14159265 * _eoT_))
						next
						_eoOut_ + _eoX1_
						_eoOut_ + (_eoC_ + _eoDir_ * _eoR_)
					next
				ok
			ok

			# AND THE CORNER ITSELF, rounded in the same hand the cells
			# are drawn in. Ink only: the logical path this render
			# publishes still turns at the exact vertex, so channels,
			# labels and every guard that reads geometry see the same
			# picture they always did -- the same contract the wire hop
			# already lives under.
			#
			# Never the first or last vertex, which sit on a node border
			# and carry the attachment; never wider than the segments it
			# eats into, or a short jog would round away entirely; and
			# never wider than the hop's own end margin, so an arc and a
			# hop on one segment cannot reach each other.
			_eoArc_ = []
			if @bRoundElbows and _eoI_ + 5 <= _eoN_
				_eoArc_ = This._ElbowArc(_eoX1_, _eoY1_, _eoX2_, _eoY2_,
					paFlat[_eoI_ + 4], paFlat[_eoI_ + 5], _eoR_)
			ok
			if len(_eoArc_) > 0
				for _eoS_ = 1 to len(_eoArc_)  _eoOut_ + _eoArc_[_eoS_]  next
			else
				_eoOut_ + _eoX2_
				_eoOut_ + _eoY2_
			ok
		next
		oC.Flush()
		oC.AddPolylineQ(_eoOut_).Stroke(cColor, nWidth)

	def _DrawRoutedEdge(oC, aFrom, aTo, paBend, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nPortA, nPortB, pBlockSide, cFromId, cToId)
		_pts_ = []
		_pts_ + [ aFrom[1], aFrom[2] ]
		for _b_ in paBend  _pts_ + [ _b_[1], _b_[2] ]  next
		_pts_ + [ aTo[1], aTo[2] ]

		# THE SAME ATTACHMENT AS EVERY OTHER EDGE. This clipped toward the
		# first bend instead, which is aim-directed clipping under another
		# name -- so a ROUTED edge left whichever border faced its first
		# bend, took no port, and arrived unported too. Every fault just
		# fixed for single-hop edges was still live here: an edge leaving
		# the SIDE of its node with a gap at the corner, and two routed
		# arrivals landing on the same point.
		#
		# It survived because the fix was verified on a picture whose
		# edges all span ONE rank. Two paths draw edges in this file and
		# only one of them was corrected -- the other kept the old rule
		# and the old faults, and looked fine wherever it was not used.
		# under ORTHO the arrival must be on the rank-facing border -- the
		# staircase below ends with a vertical drop, and a vertical drop
		# into a side border is a contradiction
		_qveto_ = pBlockSide
		if cSpline = "ortho"  _qveto_ = 1  ok
		_p_ = This._AttachPoint(aFrom, _pts_[2], nBoxW, nBoxH, nPortA,
			This._EdgeCorner(), cRank, 1, 0)
		_q_ = This._AttachPoint(aTo, _pts_[ len(_pts_) - 1 ], nBoxW, nBoxH,
			nPortB, This._EdgeCorner(), cRank, 0, _qveto_)
		# ...and under ORTHO IT LEAVES ON THE STEM, perpendicular, like
		# every other edge of the same source.
		#
		# This was ported once, to cure a real fault -- the aim-attach
		# clipped toward the first bend, so a routed edge left at
		# whatever height the aim happened to cross the border, half a
		# lane from its sibling, reading as a spacing mistake. Porting
		# it fixed the spacing and introduced a worse thing: the trunk
		# form leaves on the source's CENTRE and the routed form left on
		# a port, so one cell with a short edge and a long one grew TWO
		# parallel verticals a few pixels apart. The Principal drew a
		# ring round them and asked for one line.
		#
		# One stem out of a source is I2's blessed merge -- one line
		# because it is one origin -- and it is what keeps a fan a bus.
		# The port belongs to the ARRIVAL, where it separates edges that
		# genuinely converge. Departures merge, arrivals fan: the same
		# rule the trunk already follows, now followed here too.
		if cSpline = "ortho"
			if cRank = "LR" or cRank = "RL"
				_pdir_ = iif(_pts_[2][1] >= aFrom[1], 1, -1)
				_p_ = [ aFrom[1] + _pdir_ * This._BoxAt(aFrom, nBoxW, nBoxH)[1] / 2, aFrom[2] ]
			else
				_pdir_ = iif(_pts_[2][2] >= aFrom[2], 1, -1)
				_p_ = [ aFrom[1], aFrom[2] + _pdir_ * This._BoxAt(aFrom, nBoxW, nBoxH)[2] / 2 ]
			ok
		ok
		_pts_[1] = _p_
		_pts_[ len(_pts_) ] = _q_

		_flat_ = []
		if cSpline = "ortho"
			# NO OBLIQUE LINES -- and NO CHANNELS AT ROW HEIGHT. The first
			# staircase folded each leg at the bend's own coordinates, and
			# the router places bends AT node rows, so the horizontal runs
			# lay exactly along the ranks: the Web-to-Logger run passed
			# through the API row and read as an API-to-API link -- the
			# false-link sin in orthogonal form. The rank GAPS are node-free
			# by construction, so that is where every horizontal belongs.
			# Five segments, the classic ortho long edge and the Principal's
			# red path: drop into the first gap, run to the free column the
			# router found, descend it, run to the target's column in the
			# last gap, drop in.
			_ob1_ = _pts_[2]
			_obl_ = _pts_[ len(_pts_) - 1 ]
			_flat_ = []
			# A BEND NEEDS A CAUSE. The router chose its free lane before
			# ports existed, so the staircase ended with a one-lane jog
			# into the target -- a bend with no obstacle behind it,
			# claiming a constraint the picture does not contain. When
			# the corridor straight to the PORTED ARRIVAL is itself
			# free, the long leg runs there and the jog never exists;
			# failing that, when the corridor straight from the PORTED
			# DEPARTURE is free, the one transfer moves to the last gap.
			# Only when both corridors are blocked does the five-segment
			# staircase earn all four of its bends.
			if cRank = "LR" or cRank = "RL"
				_oc1_ = (_p_[1] + _ob1_[1]) / 2
				_oc2_ = (_obl_[1] + _q_[1]) / 2
				_ofy_ = _obl_[2]
				_oc1_ = This._ChannelBand(_oc1_, _p_[2], _ofy_,
					cFromId, cToId, 1, _p_[1], _ob1_[1])
				_odn_ = This._LegIsClear(_q_[2], _oc1_, _q_[1],
					cFromId, cToId, 0)
				_oup_ = This._LegIsClear(_p_[2], _p_[1], _oc2_,
					cFromId, cToId, 0)
				if _odn_
					_ofy_ = _q_[2]
					_oc1_ = This._ClaimChannel(_oc1_, _p_[2], _ofy_,
						cFromId, _p_[1], _ob1_[1], cFromId, cToId, 1)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _oc1_    _flat_ + _p_[2]
					_flat_ + _oc1_    _flat_ + _ofy_
					_flat_ + _q_[1]   _flat_ + _ofy_
				but _oup_
					_ofy_ = _p_[2]
					_oc2_ = This._ChannelBand(_oc2_, _ofy_, _q_[2],
						cFromId, cToId, 1, _obl_[1], _q_[1])
					_oc2_ = This._ClaimChannel(_oc2_, _ofy_, _q_[2],
						cFromId, _obl_[1], _q_[1], cFromId, cToId, 1)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _oc2_    _flat_ + _p_[2]
					_flat_ + _oc2_    _flat_ + _q_[2]
					_flat_ + _q_[1]   _flat_ + _q_[2]
				else
					_oc1_ = This._ClaimChannel(_oc1_, _p_[2], _ofy_,
						cFromId, _p_[1], _ob1_[1], cFromId, cToId, 1)
					_oc2_ = This._ChannelBand(_oc2_, _ofy_, _q_[2],
						cFromId, cToId, 1, _obl_[1], _q_[1])
					_oc2_ = This._ClaimChannel(_oc2_, _ofy_, _q_[2],
						cFromId, _obl_[1], _q_[1], cFromId, cToId, 1)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _oc1_    _flat_ + _p_[2]
					_flat_ + _oc1_    _flat_ + _ofy_
					_flat_ + _oc2_    _flat_ + _ofy_
					_flat_ + _oc2_    _flat_ + _q_[2]
					_flat_ + _q_[1]   _flat_ + _q_[2]
				ok
			else
				_oc1_ = (_p_[2] + _ob1_[2]) / 2
				_oc2_ = (_obl_[2] + _q_[2]) / 2
				_ofx_ = _obl_[1]
				_oc1_ = This._ChannelBand(_oc1_, _p_[1], _ofx_,
					cFromId, cToId, 0, _p_[2], _ob1_[2])
				_odn_ = This._LegIsClear(_q_[1], _oc1_, _q_[2],
					cFromId, cToId, 1)
				_oup_ = This._LegIsClear(_p_[1], _p_[2], _oc2_,
					cFromId, cToId, 1)
				if _odn_
					_ofx_ = _q_[1]
					_oc1_ = This._ClaimChannel(_oc1_, _p_[1], _ofx_,
						cFromId, _p_[2], _ob1_[2], cFromId, cToId, 0)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _p_[1]   _flat_ + _oc1_
					_flat_ + _ofx_    _flat_ + _oc1_
					_flat_ + _ofx_    _flat_ + _q_[2]
				but _oup_
					_ofx_ = _p_[1]
					_oc2_ = This._ChannelBand(_oc2_, _ofx_, _q_[1],
						cFromId, cToId, 0, _obl_[2], _q_[2])
					_oc2_ = This._ClaimChannel(_oc2_, _ofx_, _q_[1],
						cFromId, _obl_[2], _q_[2], cFromId, cToId, 0)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _p_[1]   _flat_ + _oc2_
					_flat_ + _q_[1]   _flat_ + _oc2_
					_flat_ + _q_[1]   _flat_ + _q_[2]
				else
					_oc1_ = This._ClaimChannel(_oc1_, _p_[1], _ofx_,
						cFromId, _p_[2], _ob1_[2], cFromId, cToId, 0)
					_oc2_ = This._ChannelBand(_oc2_, _ofx_, _q_[1],
						cFromId, cToId, 0, _obl_[2], _q_[2])
					_oc2_ = This._ClaimChannel(_oc2_, _ofx_, _q_[1],
						cFromId, _obl_[2], _q_[2], cFromId, cToId, 0)
					_flat_ + _p_[1]   _flat_ + _p_[2]
					_flat_ + _p_[1]   _flat_ + _oc1_
					_flat_ + _ofx_    _flat_ + _oc1_
					_flat_ + _ofx_    _flat_ + _oc2_
					_flat_ + _q_[1]   _flat_ + _oc2_
					_flat_ + _q_[1]   _flat_ + _q_[2]
				ok
			ok
		but cSpline = "line" or cSpline = "polyline"
			for _pt_ in _pts_  _flat_ + _pt_[1]  _flat_ + _pt_[2]  next
		else
			_flat_ = This._SmoothThrough(_pts_)
		ok
		# the same cut-for-the-head contract as a single-hop edge: the
		# stroke stops where the arrow begins, so the head is whole at any
		# arrival angle
		_cut_ = This._ArrowCut(_flat_, 9 + nWidth * 2)
		if cSpline = "ortho"
			This._EmitOrthoPolyline(oC, _cut_[1], cColor, nWidth,
				cFromId + ">" + cToId)
			if @nDrawPass = 2
				This._DrawArrowHead(oC, _cut_[2], _cut_[3], cColor)
			ok
		else
			oC.Flush()
			oC.AddPolylineQ(_cut_[1]).Stroke(cColor, nWidth)
			This._DrawArrowHead(oC, _cut_[2], _cut_[3], cColor)
		ok

	# Catmull-Rom through every point, sampled. Passes THROUGH its control points,
	# unlike the quadratic used for a single hop, which is what a route needs:
	# the bends are reserved space, not suggestions.
	def _SmoothThrough(paPts)
		_n_ = len(paPts)
		if _n_ < 3
			_o_ = []
			for _pt_ in paPts  _o_ + _pt_[1]  _o_ + _pt_[2]  next
			return _o_
		ok
		_o_ = []
		for _i_ = 1 to _n_ - 1
			_p0_ = paPts[ max([ 1, _i_ - 1 ]) ]
			_p1_ = paPts[_i_]
			_p2_ = paPts[_i_ + 1]
			_p3_ = paPts[ min([ _n_, _i_ + 2 ]) ]
			for _s_ = 0 to 7
				_t_ = _s_ / 8
				_t2_ = _t_ * _t_
				_t3_ = _t2_ * _t_
				_o_ + (0.5 * ((2 * _p1_[1]) +
					(0 - _p0_[1] + _p2_[1]) * _t_ +
					(2 * _p0_[1] - 5 * _p1_[1] + 4 * _p2_[1] - _p3_[1]) * _t2_ +
					(0 - _p0_[1] + 3 * _p1_[1] - 3 * _p2_[1] + _p3_[1]) * _t3_))
				_o_ + (0.5 * ((2 * _p1_[2]) +
					(0 - _p0_[2] + _p2_[2]) * _t_ +
					(2 * _p0_[2] - 5 * _p1_[2] + 4 * _p2_[2] - _p3_[2]) * _t2_ +
					(0 - _p0_[2] + 3 * _p1_[2] - 3 * _p2_[2] + _p3_[2]) * _t3_))
			next
		next
		_o_ + paPts[_n_][1]
		_o_ + paPts[_n_][2]
		return _o_

	# WHERE an edge meets a node: a point ON THE BOUNDARY, on the side the
	# rank direction says edges leave and arrive from.
	#
	# This replaces clipping a ray against the box. Clipping is the right
	# tool when an edge may come from any direction; in a LAYERED drawing
	# it never does -- everything leaves the bottom and arrives at the top
	# (or the sides, turned) -- and clipping a ray that had been aimed
	# through a PORT-SHIFTED centre put the exit point on a box that was
	# not where the node is.
	def _PortPoint(aCentre, nPort, nBoxW, nBoxH, cRank, bOut)
		# THE BORDER IS THE NODE'S OWN, and the port spread is clamped to
		# it. Two edges arriving at a MARK were ported across a full
		# cell's width, so one of them landed beside the mark and its
		# arrow pointed at paper. A port is a position ON a border; it
		# cannot be further out than the border is.
		_apB_ = This._BoxAt(aCentre, nBoxW, nBoxH)
		_hw_ = _apB_[1] / 2
		_hh_ = _apB_[2] / 2
		_lim_ = max([ _hw_, _hh_ ]) * 0.8
		if nPort > _lim_   nPort = _lim_   ok
		if nPort < 0 - _lim_  nPort = 0 - _lim_  ok
		if cRank = "LR"
			if bOut  return [ aCentre[1] + _hw_, aCentre[2] + nPort ]  ok
			return [ aCentre[1] - _hw_, aCentre[2] + nPort ]
		but cRank = "RL"
			if bOut  return [ aCentre[1] - _hw_, aCentre[2] + nPort ]  ok
			return [ aCentre[1] + _hw_, aCentre[2] + nPort ]
		but cRank = "BT"
			if bOut  return [ aCentre[1] + nPort, aCentre[2] - _hh_ ]  ok
			return [ aCentre[1] + nPort, aCentre[2] + _hh_ ]
		ok
		if bOut  return [ aCentre[1] + nPort, aCentre[2] + _hh_ ]  ok
		return [ aCentre[1] + nPort, aCentre[2] - _hh_ ]

	# THE EDGE GRAMMAR, learned by rendering the same diagrams through
	# dot.exe and putting the pictures side by side. Three rules, and the
	# previous model broke all three:
	#
	# 1. AN EDGE IS AIMED AT ITS TARGET. The exit point sits on the source
	#    border in the target's direction and the path runs essentially
	#    straight -- the angles separate a fan by themselves, which is why
	#    dot needs no port spreading. The old model forced a vertical
	#    tangent at BOTH ends (ELK's style, not dot's): every lateral edge
	#    became an S, and an S bows inward somewhere, which is exactly the
	#    "not an outer arc" a reader notices.
	#
	# 2. THE DEPARTURE IS SOFT, THE ARRIVAL IS STRAIGHT. The curve leaves
	#    leaning along the rank axis and straightens into the aim line --
	#    one bend, always outward. The arrival tangent IS the aim, so the
	#    arrowhead points the way the line actually travels.
	#
	# 3. THE LINE IS CUT FOR THE ARROW. dot shortens the spline by the
	#    head's length and sets the tip exactly on the border. Drawing the
	#    full line and stamping a head over it leaves the line poking past
	#    the head at any angle the stamp did not cover -- the "arrows not
	#    always visible" of every hand-rolled renderer.
	#
	# One geometry, read three times: the stroke, the arrowhead, and the
	# label all sample THIS path.

	# The path between two BORDER points: a cubic that departs along the
	# rank axis and arrives along the straight aim. Flat [x,y,...] samples.
	# THE EDGE GRAMMAR, v3 -- from the Principal's own reference sketch,
	# which settled a question two earlier grammars got wrong in opposite
	# ways. v1 forced BOTH tangents vertical: every lateral edge ballooned
	# into an S. v2 (dot-derived) departed vertical and arrived along the
	# aim: arrivals grazed their borders, and a fan BRAIDED -- the control
	# scales with length, so a far edge stayed vertical longest, descended
	# deepest, then cut flat across every nearer arc. The reference shows
	# the mirror: DEPART ALONG THE AIM, so the fan spreads immediately and
	# a farther target means a flatter leave that stays HIGHER -- arcs
	# nested like onion layers, unable to cross -- and ARRIVE PERPENDICULAR
	# to the landed border, so every head meets its surface square.
	#
	# An aligned pair keeps its straight spine: aim and perpendicular
	# coincide, both controls sit on the centre line.
	#
	# pQSide: which border the arrival landed on (from _AttachPoint) --
	# perpendicular means the RANK axis into a rank-facing border and the
	# SLOT axis into a side border.
	def _EdgePathFlat(aP, aQ, cRank, pQSide)
		_gdx_ = aQ[1] - aP[1]
		_gdy_ = aQ[2] - aP[2]
		_glen_ = sqrt(_gdx_ * _gdx_ + _gdy_ * _gdy_)
		if _glen_ < 0.001
			return [ aP[1], aP[2], aQ[1], aQ[2] ]
		ok
		# departure control: along the aim -- the fan opens at once
		_gk_ = _glen_ * 0.35
		_c1_ = [ aP[1] + _gdx_ / _glen_ * _gk_, aP[2] + _gdy_ / _glen_ * _gk_ ]
		# arrival control: back along the landed border's own normal, its
		# reach bounded by the travel available on that axis so a shallow
		# edge turns inside the gap instead of hooking past its target
		_bH_ = 0
		if cRank = "LR" or cRank = "RL"  _bH_ = 1  ok
		if (pQSide and NOT _bH_) or (NOT pQSide and _bH_)
			# normal is the X axis
			_gax_ = fabs(_gdx_)
			_gk2_ = min([ _gk_, _gax_ * 0.9 ])
			_gsx_ = 1
			if _gdx_ < 0  _gsx_ = -1  ok
			_c2_ = [ aQ[1] - _gsx_ * _gk2_, aQ[2] ]
		else
			# normal is the Y axis
			_gax_ = fabs(_gdy_)
			_gk2_ = min([ _gk_, _gax_ * 0.9 ])
			_gsy_ = 1
			if _gdy_ < 0  _gsy_ = -1  ok
			_c2_ = [ aQ[1], aQ[2] - _gsy_ * _gk2_ ]
		ok
		_ga_ = []
		for _gi_ = 0 to 24
			_gt_ = _gi_ / 24
			_gu_ = 1 - _gt_
			_ga_ + (_gu_*_gu_*_gu_ * aP[1] + 3*_gu_*_gu_*_gt_ * _c1_[1] +
				3*_gu_*_gt_*_gt_ * _c2_[1] + _gt_*_gt_*_gt_ * aQ[1])
			_ga_ + (_gu_*_gu_*_gu_ * aP[2] + 3*_gu_*_gu_*_gt_ * _c1_[2] +
				3*_gu_*_gt_*_gt_ * _c2_[2] + _gt_*_gt_*_gt_ * aQ[2])
		next
		return _ga_

	# Walk back from the end of a flat polyline and CUT it nLen before its
	# tip: [ aShortenedFlat, aBase, aTip ]. The stroke is drawn to the cut,
	# the head owns the rest.
	# THE ARRIVAL MUST BE LONG ENOUGH TO CARRY ITS OWN HEAD.
	#
	# An arrowhead is drawn from the point the cut released to the point
	# the edge ends, so its direction is the direction of ARRIVAL -- as
	# long as the arrival segment is at least as long as the cut. The
	# connection's "handshake ok" turned left 5.6 pixels above its
	# target and dropped in; the cut, 13 pixels, walked straight back
	# through that and around the corner, and the head came out pointing
	# LEFT at a spot above the state instead of DOWN into it. The
	# Principal has marked "edges that are not linked to their nodes"
	# more than once, and this is one of the ways one gets made.
	#
	# So a short final segment is LENGTHENED rather than argued with:
	# the corner slides back along the arrival's own axis, taking the
	# run before it along, which keeps every angle square and moves the
	# turn to where a reader can see it turn. Ortho only -- a curve has
	# no corner to slide.
	def _EnsureArrival(paFlat, nMin)
		_eaN_ = len(paFlat)
		if _eaN_ < 6  return paFlat  ok
		_eaX1_ = paFlat[_eaN_ - 3]  _eaY1_ = paFlat[_eaN_ - 2]
		_eaX2_ = paFlat[_eaN_ - 1]  _eaY2_ = paFlat[_eaN_]
		_eaDx_ = _eaX2_ - _eaX1_
		_eaDy_ = _eaY2_ - _eaY1_
		# axis-aligned, or this is not a staircase and not ours to touch
		if fabs(_eaDx_) > 0.001 and fabs(_eaDy_) > 0.001  return paFlat  ok
		_eaLen_ = fabs(_eaDx_) + fabs(_eaDy_)
		if _eaLen_ >= nMin  return paFlat  ok
		if _eaLen_ < 0.001  return paFlat  ok
		_eaGrow_ = nMin - _eaLen_
		_eaSx_ = 0  _eaSy_ = 0
		if fabs(_eaDy_) > 0.001
			_eaSy_ = 0 - _eaGrow_ * iif(_eaDy_ > 0, 1, -1)
		else
			_eaSx_ = 0 - _eaGrow_ * iif(_eaDx_ > 0, 1, -1)
		ok
		# the corner and the run that feeds it move together
		_eaOut_ = []
		for _eaJ_ = 1 to _eaN_  _eaOut_ + paFlat[_eaJ_]  next
		_eaOut_[_eaN_ - 3] = _eaX1_ + _eaSx_
		_eaOut_[_eaN_ - 2] = _eaY1_ + _eaSy_
		_eaOut_[_eaN_ - 5] = _eaOut_[_eaN_ - 5] + _eaSx_
		_eaOut_[_eaN_ - 4] = _eaOut_[_eaN_ - 4] + _eaSy_
		return _eaOut_

	def _ArrowCut(paFlat, nLen)
		paFlat = This._EnsureArrival(paFlat, nLen + This._LineClearance())
		_an_ = len(paFlat)
		if _an_ < 4  return [ paFlat, [ 0, 0 ], [ 0, 0 ] ]  ok
		_atx_ = paFlat[_an_ - 1]
		_aty_ = paFlat[_an_]
		_arem_ = nLen
		_ai_ = _an_ - 2
		while _ai_ >= 2
			_ax1_ = paFlat[_ai_ - 1]
			_ay1_ = paFlat[_ai_]
			_ax2_ = paFlat[_ai_ + 1]
			_ay2_ = paFlat[_ai_ + 2]
			_aseg_ = sqrt((_ax2_ - _ax1_) * (_ax2_ - _ax1_) +
				(_ay2_ - _ay1_) * (_ay2_ - _ay1_))
			if _aseg_ >= _arem_ and _aseg_ > 0.0001
				_af_ = (_aseg_ - _arem_) / _aseg_
				_abx_ = _ax1_ + (_ax2_ - _ax1_) * _af_
				_aby_ = _ay1_ + (_ay2_ - _ay1_) * _af_
				_aout_ = []
				for _aj_ = 1 to _ai_
					_aout_ + paFlat[_aj_]
				next
				_aout_ + _abx_
				_aout_ + _aby_
				return [ _aout_, [ _abx_, _aby_ ], [ _atx_, _aty_ ] ]
			ok
			_arem_ -= _aseg_
			_ai_ -= 2
		end
		return [ paFlat, [ paFlat[1], paFlat[2] ], [ _atx_, _aty_ ] ]

	# The solid head: base to tip, wings perpendicular. It owns the whole
	# stretch the cut released, so nothing shows through it.
	def _DrawArrowHead(oC, aBase, aTip, cColor)
		_hdx_ = aTip[1] - aBase[1]
		_hdy_ = aTip[2] - aBase[2]
		_hl_ = sqrt(_hdx_ * _hdx_ + _hdy_ * _hdy_)
		if _hl_ < 0.001  return  ok
		_hdx_ = _hdx_ / _hl_
		_hdy_ = _hdy_ / _hl_
		_hw_ = _hl_ * 0.40
		_hpx_ = 0 - _hdy_
		_hpy_ = _hdx_
		oC.Flush()
		oC.FillQ(cColor).StrokeQ(cColor, 0).
			AddPolygon([ aTip[1], aTip[2],
				aBase[1] + _hpx_ * _hw_, aBase[2] + _hpy_ * _hw_,
				aBase[1] - _hpx_ * _hw_, aBase[2] - _hpy_ * _hw_ ])

	# Clip EXACTLY on the border -- no air. _ClipToBox pads by 2px, which
	# was right when the stroke ran all the way to the node and must not
	# overdraw its border; the head's TIP has to touch the border, as
	# dot's does, and 2px short reads as an arrow shying away from its
	# target.
	def _ClipExact(aCentre, aOther, nBoxW, nBoxH)
		_cdx_ = aOther[1] - aCentre[1]
		_cdy_ = aOther[2] - aCentre[2]
		if _cdx_ = 0 and _cdy_ = 0  return [ aCentre[1], aCentre[2] ]  ok
		_ctx_ = 1000000
		_cty_ = 1000000
		if _cdx_ != 0  _ctx_ = fabs(nBoxW / 2 / _cdx_)  ok
		if _cdy_ != 0  _cty_ = fabs(nBoxH / 2 / _cdy_)  ok
		_ct_ = min([ _ctx_, _cty_ ])
		return [ aCentre[1] + _cdx_ * _ct_, aCentre[2] + _cdy_ * _ct_ ]

	# The whole geometry for one single-hop edge, from CENTRES: clip both
	# ends toward the other, path, cut. [ aFlat, aBase, aTip ].
	# THE ATTACHMENT POINT: aimed at the other end, slid ALONG the border by
	# this edge's port, and pulled under the rounded outline at a corner.
	#
	# TWO FAULTS FIXED IN ONE PLACE, because they are both about where a
	# line meets a box.
	#
	# PORTS CAME BACK. Adopting dot's grammar, I dropped port spreading on
	# the reasoning that "the angles separate a fan by themselves". That
	# holds only when the targets are angularly apart. A broker fanning to
	# fourteen workers strung out sideways aims almost the same direction
	# at all of them, so every edge left the same point and ran parallel --
	# fourteen lines on top of each other, and any labels on them in the
	# same place. The aim still decides the DIRECTION; the port decides
	# where along the border it starts, which is what separates them.
	#
	# AND THE BOX IS ROUND. Clipping to a rectangle puts the endpoint
	# outside the drawn shape wherever the corner is rounded, so the line
	# stopped short of the node with a visible gap -- always at a corner,
	# never on a flat edge, which is exactly the pattern the Principal
	# circled. The point is pulled toward the centre by how far into the
	# corner region it fell, so it lands under the outline that is
	# actually drawn.
	def _AttachPoint(aCentre, aOther, nBoxW, nBoxH, nPort, nRad, cRank, bOut, pBlockSide)
		_ahw_ = nBoxW / 2
		_ahh_ = nBoxH / 2

		# THE SIDE IS THE RANK'S, NOT THE AIM'S -- and getting that wrong
		# is what put edges THROUGH other nodes. Clipping in the target's
		# direction attaches an edge to whichever border faces it, so an
		# edge to a distant sibling left the SIDE of its parent and
		# arrived at the SIDE of its child -- travelling along the child
		# row and crossing every node in between. A broker fanning to
		# fourteen workers drew fourteen lines through the workers.
		#
		# In a layered drawing every edge crosses the same gap: out of the
		# rank-facing border, into the one opposite. That is what keeps a
		# fan above its row instead of inside it. The tangent grammar is
		# unchanged -- it is the ATTACHMENT that is decided by rank, and
		# the aim still shapes the curve between the two points.
		# THE BORDER MUST FACE THE APPROACH -- for ARRIVALS. A shallow
		# approach pierces the rank-facing border at a grazing angle: the
		# head lies almost parallel to the surface it enters, which is
		# the wrongness the Principal circled. dot decides by clipping
		# along the aim, and the geometry of that clip is one comparison:
		# an aim shallower than the box's own aspect hits the SIDE first,
		# where it lands near-perpendicular. The 1.4 bias prefers the
		# side on borderline aims -- a clearly-sideways landing over an
		# ambiguous top graze. DEPARTURES stay rank-facing always: that
		# is guard 24's subject, and a fan must leave its parent
		# downward however lateral its targets.
		_adx2_ = fabs(aOther[1] - aCentre[1])
		_ady2_ = fabs(aOther[2] - aCentre[2])
		# pBlockSide is the CORRIDOR VETO, computed where the whole rank is
		# visible (in _EdgePorts): a side entry whose horizontal corridor
		# passes other same-rank nodes is refused there, because an edge
		# running the row into its target reads as a link with every cell
		# it grazes -- the erroneous info the Principal named.
		_bSide_ = 0
		if NOT bOut and NOT pBlockSide
			if cRank = "LR" or cRank = "RL"
				if _ady2_ > 0.001 and _adx2_ / _ady2_ < (nBoxW / nBoxH) * 1.4
					_bSide_ = 1
				ok
			else
				if _adx2_ > 0.001 and _ady2_ / _adx2_ < (nBoxH / nBoxW) * 1.4
					_bSide_ = 1
				ok
			ok
		ok

		_asx_ = 0
		_asy_ = 0
		if _bSide_
			if cRank = "LR" or cRank = "RL"
				# ranks run horizontally: the off-axis border is top/bottom
				if aOther[2] < aCentre[2]  _asy_ = 0 - _ahh_  else  _asy_ = _ahh_  ok
			else
				if aOther[1] < aCentre[1]  _asx_ = 0 - _ahw_  else  _asx_ = _ahw_  ok
			ok
		but cRank = "LR"
			if bOut  _asx_ = _ahw_  else  _asx_ = 0 - _ahw_  ok
		but cRank = "RL"
			if bOut  _asx_ = 0 - _ahw_  else  _asx_ = _ahw_  ok
		but cRank = "BT"
			if bOut  _asy_ = 0 - _ahh_  else  _asy_ = _ahh_  ok
		else
			if bOut  _asy_ = _ahh_  else  _asy_ = 0 - _ahh_  ok
		ok

		# the port spreads the attachment ALONG that border, which is what
		# separates the members of a fan from each other
		# A SIDE LANDING TAKES THE BORDER'S CENTRE, not the group port.
		# Ports are shares of ONE border, allocated before anyone knew
		# which border each edge would land on -- so a side-lander
		# arriving with a port meant for the TOP border was pushed to the
		# very corner of the side (34px of border, a 30px port: 2px from
		# the corner). The centre of the side border is "a bit down" from
		# the corner by construction, which is the red path the Principal
		# drew. Two edges landing on the SAME side border will overlap at
		# its centre -- accepted until a real diagram produces the case.
		if _bSide_  nPort = 0  ok

		_apx_ = aCentre[1] + _asx_
		_apy_ = aCentre[2] + _asy_
		if _asx_ = 0
			_apx_ += nPort
			_alim_ = _ahw_ - 2
			if _apx_ - aCentre[1] > _alim_      _apx_ = aCentre[1] + _alim_  ok
			if _apx_ - aCentre[1] < 0 - _alim_  _apx_ = aCentre[1] - _alim_  ok
		else
			_apy_ += nPort
			_alim_ = _ahh_ - 2
			if _apy_ - aCentre[2] > _alim_      _apy_ = aCentre[2] + _alim_  ok
			if _apy_ - aCentre[2] < 0 - _alim_  _apy_ = aCentre[2] - _alim_  ok
		ok

		# AND THE BOX IS ROUND. A point on the rectangle lies outside the
		# drawn outline wherever the corner is rounded, so the line
		# stopped short with a visible gap -- always at a corner, never on
		# a flat edge, which is exactly the pattern the Principal circled.
		if nRad > 0
			_aox_ = fabs(_apx_ - aCentre[1]) - (_ahw_ - nRad)
			_aoy_ = fabs(_apy_ - aCentre[2]) - (_ahh_ - nRad)
			if _aox_ > 0 and _aoy_ > 0
				_avx_ = aCentre[1] - _apx_
				_avy_ = aCentre[2] - _apy_
				_avl_ = sqrt(_avx_ * _avx_ + _avy_ * _avy_)
				if _avl_ > 0.001
					_ain_ = min([ nRad * 0.9, _avl_ * 0.5 ])
					_apx_ += _avx_ / _avl_ * _ain_
					_apy_ += _avy_ / _avl_ * _ain_
				ok
			ok
		ok
		# THE SOURCE END STARTS INSIDE THE NODE. Measured, the attachment
		# is exactly on the border -- and a long edge leaves it and sweeps
		# away immediately, so at a rounded corner the stroke and the
		# outline part company within a pixel or two and read as detached.
		# Nodes are painted AFTER edges, so an overlap costs nothing and
		# no rounding, antialiasing or curvature can open a gap the node
		# does not cover. The TARGET end is never overlapped: the arrow
		# tip belongs on the border, and burying it would hide the head.
		if bOut
			_avx2_ = aCentre[1] - _apx_
			_avy2_ = aCentre[2] - _apy_
			_avl2_ = sqrt(_avx2_ * _avx2_ + _avy2_ * _avy2_)
			if _avl2_ > 0.001
				_aov_ = min([ nBoxH * 0.25, nBoxW * 0.25, _avl2_ * 0.5 ])
				_apx_ += _avx2_ / _avl2_ * _aov_
				_apy_ += _avy2_ / _avl2_ * _aov_
			ok
		ok
		return [ _apx_, _apy_, _bSide_ ]

	def _EdgeGeometry(aFrom, aTo, nBoxW, nBoxH, cRank, nWidth, nPortA, nPortB, nRad, pBlockSide)
		_bA_ = This._BoxAt(aFrom, nBoxW, nBoxH)
		_bB_ = This._BoxAt(aTo, nBoxW, nBoxH)
		_ep_ = This._AttachPoint(aFrom, aTo, _bA_[1], _bA_[2], nPortA, nRad, cRank, 1, 0)
		_eq_ = This._AttachPoint(aTo, aFrom, _bB_[1], _bB_[2], nPortB, nRad, cRank, 0, pBlockSide)
		_eqs_ = 0
		if len(_eq_) >= 3  _eqs_ = _eq_[3]  ok
		_efl_ = This._EdgePathFlat(_ep_, _eq_, cRank, _eqs_)
		return This._ArrowCut(_efl_, 9 + nWidth * 2)

	# The point at fraction t along that same path -- the label's anchor,
	# so a label sits ON the curve it names.
	def _EdgePathAt(aFrom, aTo, nBoxW, nBoxH, cRank, nT, nPortA, nPortB, pBlockSide)
		_bA_ = This._BoxAt(aFrom, nBoxW, nBoxH)
		_bB_ = This._BoxAt(aTo, nBoxW, nBoxH)
		_ep_ = This._AttachPoint(aFrom, aTo, _bA_[1], _bA_[2], nPortA, This._EdgeCorner(), cRank, 1, 0)
		_eq_ = This._AttachPoint(aTo, aFrom, _bB_[1], _bB_[2], nPortB, This._EdgeCorner(), cRank, 0, pBlockSide)
		_eqs_ = 0
		if len(_eq_) >= 3  _eqs_ = _eq_[3]  ok
		_efl_ = This._EdgePathFlat(_ep_, _eq_, cRank, _eqs_)
		_en_ = len(_efl_) / 2
		_ek_ = floor(nT * (_en_ - 1)) + 1
		if _ek_ < 1  _ek_ = 1  ok
		if _ek_ > _en_  _ek_ = _en_  ok
		return [ _efl_[_ek_ * 2 - 1], _efl_[_ek_ * 2] ]

	def _DrawEdgeXT(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nLane, nPortA, nPortB, pBlockSide, cFromId, cToId, pSideDep)
		if cSpline = "ortho"
			# TWO NEIGHBOURS ON ONE ROW ARE JOINED BY ONE LINE -- I4, and
			# the Principal circled the cost of forgetting it. Every ortho
			# arrival was forced onto the RANK-FACING border, which is
			# right when an edge crosses a rank gap and absurd when it
			# does not: for two peers side by side the path ran out of the
			# side, along the row, and then UP into the target's top --
			# a hook where the reader looks for a constraint and finds
			# none. Peers are joined side to side, one segment, no bends.
			_srSame_ = 0
			if cRank = "LR" or cRank = "RL"
				if fabs(aTo[1] - aFrom[1]) < 1.5  _srSame_ = 1  ok
			else
				if fabs(aTo[2] - aFrom[2]) < 1.5  _srSame_ = 1  ok
			ok
			if _srSame_
				_srA_ = This._BoxAt(aFrom, nBoxW, nBoxH)
				_srB_ = This._BoxAt(aTo, nBoxW, nBoxH)
				# A RETURN TAKES ITS OWN LANE -- I2, and the Principal
				# redrew one by hand to say so. Two peers talk both ways;
				# the forward run keeps the row and every RETURN steps
				# off it, the Nth return by N clearances, so two returns
				# into one state are two readable lines with room for
				# their events between them instead of one line carrying
				# two words.
				_srBack_ = 0
				if cRank = "LR" or cRank = "RL"
					if aTo[2] < aFrom[2]  _srBack_ = 1  ok
				else
					if aTo[1] < aFrom[1]  _srBack_ = 1  ok
				ok
				# A LANE IS TAKEN FOR ONE OF TWO REASONS, and the
				# second was missing. A RETURN steps off the row so it
				# does not overlay its partner. And an edge with
				# SOMETHING IN THE WAY steps off the row because the
				# row is not free -- the case that drew a line through
				# the middle of an innocent state.
				_srLane_ = This._LaneKept(
					StzLower("" + cFromId) + ">" + StzLower("" + cToId))
				_srOff_ = This._LaneOffset(_srLane_, _srA_[2])
				if cRank = "LR" or cRank = "RL"
					_srSg_ = iif(aTo[2] >= aFrom[2], 1, -1)
					if _srLane_ > 0
						# OUT OF THE SIDE, ALONG THE LANE, BACK IN --
						# four points, so the ends still sit on their
						# nodes' borders and only the MIDDLE leaves the
						# row. A two-point path at the lane's depth had
						# both ends hanging in open paper.
						_srLn_ = aFrom[1] + _srOff_
						_srK_ = StzLower("" + cFromId) + ">" +
							StzLower("" + cToId)
						_srPts_ = [ aFrom[1] + _srA_[1] / 2,
							aFrom[2] + This._StubOf(_srK_, 1),
							_srLn_, aFrom[2] + This._StubOf(_srK_, 1),
							_srLn_, aTo[2] + This._StubOf(_srK_, 2),
							aTo[1] + _srB_[1] / 2,
							aTo[2] + This._StubOf(_srK_, 2) ]
					else
						_srPts_ = [ aFrom[1], aFrom[2] + _srSg_ * _srA_[2] / 2,
							aTo[1], aTo[2] - _srSg_ * _srB_[2] / 2 ]
					ok
				else
					_srSg_ = iif(aTo[1] >= aFrom[1], 1, -1)
					if _srLane_ > 0
						_srLn_ = aFrom[2] + _srOff_
						_srK_ = StzLower("" + cFromId) + ">" +
							StzLower("" + cToId)
						_srDx_ = This._StubOf(_srK_, 1)
						_srAx2_ = This._StubOf(_srK_, 2)
						_srPts_ = [ aFrom[1] + _srDx_,
							aFrom[2] + _srA_[2] / 2,
							aFrom[1] + _srDx_, _srLn_,
							aTo[1] + _srAx2_, _srLn_,
							aTo[1] + _srAx2_, aTo[2] + _srB_[2] / 2 ]
					else
						_srPts_ = [ aFrom[1] + _srSg_ * _srA_[1] / 2,
							aFrom[2],
							aTo[1] - _srSg_ * _srB_[1] / 2,
							aTo[2] ]
					ok
				ok
				_srCut_ = This._ArrowCut(_srPts_, 9 + nWidth * 2)
				This._EmitOrthoPolyline(oC, _srCut_[1], cColor, nWidth,
					cFromId + ">" + cToId)
				if @nDrawPass = 2
					This._DrawArrowHead(oC, _srCut_[2], _srCut_[3], cColor)
				ok
				return
			ok

			# THE UNIQUE LATERAL EDGE, image 1's rule: out of the lateral
			# border's CENTRE, one run along its own free row corridor,
			# one drop into the target -- a single horizontal statement
			# drawn as one. Falls back to the trunk form if another
			# channel already holds the row.
			if pSideDep and NOT (cRank = "LR" or cRank = "RL")
				_sdSgn_ = 1
				if aTo[1] < aFrom[1]  _sdSgn_ = -1  ok
				_sdX_ = aFrom[1] + _sdSgn_ * nBoxW / 2
				_sdCy_ = aFrom[2]
				# the arrival keeps its PORT, or two edges funnelling into
				# one target share their final drop and read as one line
				_sdTx_ = aTo[1] + nPortB
				_sdBad_ = 0
				for _sdU_ in @aChanUsed
					if _sdU_[3] = StzLower("" + cFromId)  loop  ok
					if max([ _sdX_, _sdTx_ ]) > _sdU_[1] and
					   min([ _sdX_, _sdTx_ ]) < _sdU_[2] and
					   fabs(_sdCy_ - _sdU_[4]) < This._LineClearance() * 0.9
						_sdBad_ = 1
						exit
					ok
				next
				if _sdBad_ = 0
					@aChanUsed + [ min([ _sdX_, _sdTx_ ]),
						max([ _sdX_, _sdTx_ ]), StzLower("" + cFromId), _sdCy_ ]
					_sdQe_ = aTo[2] - nBoxH / 2
					if aTo[2] < aFrom[2]  _sdQe_ = aTo[2] + nBoxH / 2  ok
					_sdCut_ = This._ArrowCut([ _sdX_, _sdCy_,
						_sdTx_, _sdCy_, _sdTx_, _sdQe_ ], 9 + nWidth * 2)
					This._EmitOrthoPolyline(oC, _sdCut_[1], cColor, nWidth,
						cFromId + ">" + cToId)
					if @nDrawPass = 2
						This._DrawArrowHead(oC, _sdCut_[2], _sdCut_[3], cColor)
					ok
					return
				ok
			ok
			if pSideDep and (cRank = "LR" or cRank = "RL")
				_sdSgn_ = 1
				if aTo[2] < aFrom[2]  _sdSgn_ = -1  ok
				_sdY_ = aFrom[2] + _sdSgn_ * nBoxH / 2
				_sdCx_ = aFrom[1]
				_sdTy_ = aTo[2] + nPortB
				_sdBad_ = 0
				for _sdU_ in @aChanUsed
					if _sdU_[3] = StzLower("" + cFromId)  loop  ok
					if max([ _sdY_, _sdTy_ ]) > _sdU_[1] and
					   min([ _sdY_, _sdTy_ ]) < _sdU_[2] and
					   fabs(_sdCx_ - _sdU_[4]) < This._LineClearance() * 0.9
						_sdBad_ = 1
						exit
					ok
				next
				if _sdBad_ = 0
					@aChanUsed + [ min([ _sdY_, _sdTy_ ]),
						max([ _sdY_, _sdTy_ ]), StzLower("" + cFromId), _sdCx_ ]
					_sdQe_ = aTo[1] - nBoxW / 2
					if aTo[1] < aFrom[1]  _sdQe_ = aTo[1] + nBoxW / 2  ok
					_sdCut_ = This._ArrowCut([ _sdCx_, _sdY_,
						_sdCx_, _sdTy_, _sdQe_, _sdTy_ ], 9 + nWidth * 2)
					This._EmitOrthoPolyline(oC, _sdCut_[1], cColor, nWidth,
						cFromId + ">" + cToId)
					if @nDrawPass = 2
						This._DrawArrowHead(oC, _sdCut_[2], _sdCut_[3], cColor)
					ok
					return
				ok
			ok
			# TRUNK AND CHANNEL, the way dot draws a tree: one stem leaves
			# the parent's border, runs along the parent's own channel
			# height, and drops into the child. A parent's edges overlap on
			# the trunk deliberately -- they ARE one stem until they split.
			# The old form crossed at the gap's midpoint for every edge, so
			# every parent in a rank shared one channel and neighbouring
			# families read as crossings.
			This._DrawEdge(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth,
				cSpline, cRank, nLane, nPortA, nPortB, cFromId, cToId,
				pSideDep)
			return
		ok
		_dg_ = This._EdgeGeometry(aFrom, aTo, nBoxW, nBoxH, cRank, nWidth, nPortA, nPortB, This._EdgeCorner(), pBlockSide)
		if cSpline = "line" or cSpline = "polyline"
			_bdA_ = This._BoxAt(aFrom, nBoxW, nBoxH)
			_bdB_ = This._BoxAt(aTo, nBoxW, nBoxH)
			_dp_ = This._AttachPoint(aFrom, aTo, _bdA_[1], _bdA_[2], nPortA, This._EdgeCorner(), cRank, 1, 0)
			_dq_ = This._AttachPoint(aTo, aFrom, _bdB_[1], _bdB_[2], nPortB, This._EdgeCorner(), cRank, 0, pBlockSide)
			_dg_ = This._ArrowCut([ _dp_[1], _dp_[2], _dq_[1], _dq_[2] ],
				9 + nWidth * 2)
		ok
		oC.Flush()
		oC.AddPolylineQ(_dg_[1]).Stroke(cColor, nWidth)
		This._DrawArrowHead(oC, _dg_[2], _dg_[3], cColor)
		# THE DRAWN GEOMETRY, PUBLISHED -- this is where a straight edge
		# is actually drawn (the delegation below serves the ortho trunk
		# alone), so it is where the path has to be recorded
		This._PublishPath(cFromId, cToId, _dg_[1])

	def _DrawEdge(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nLane, nPortA, nPortB, cFromId, cToId, pSideDep)
		_bcA_ = This._BoxAt(aFrom, nBoxW, nBoxH)
		_bcB_ = This._BoxAt(aTo, nBoxW, nBoxH)
		_p_ = This._ClipToBox(aFrom, aTo, _bcA_[1], _bcA_[2])
		_q_ = This._ClipToBox(aTo, aFrom, _bcB_[1], _bcB_[2])

		switch cSpline
		on "ortho"
			# THE TRUNK IS A STEM WITH PORTED FINGERS. The departure stays
			# at the source's centre -- same-source edges sharing their
			# stem is I2's blessed merge, one line because it is one
			# origin, and it is what keeps a 14-way fan a bus instead of
			# fourteen micro-spaced lanes. The ARRIVAL takes its port:
			# this form dropped nPortB on the floor, so K2,2's crossing
			# edge landed exactly on its target's own spine column and two
			# foreign edges shared one vertical line. Porting only the
			# arrival resolves the crossing pair to ONE transversal
			# crossing -- which the wire hop then declares -- where
			# porting BOTH ends double-books a column unavoidably: each
			# edge would use the other's column, and on a shared column
			# one pair of spans must overlap.
			if cRank = "LR" or cRank = "RL"
				_pay_ = aFrom[2]
				_qay_ = aTo[2] + nPortB
				_sgn_ = 1
				if aTo[1] < aFrom[1]  _sgn_ = -1  ok
				_pe_ = aFrom[1] + _sgn_ * _bcA_[1] / 2
				_qe_ = aTo[1] - _sgn_ * _bcB_[1] / 2
				_chan_ = _pe_ + (_qe_ - _pe_) * nLane
				# the span is the run's own axis: a VERTICAL channel in a
				# left-to-right picture runs across Y
				_chan_ = This._ChannelBand(_chan_, _pay_, _qay_,
					cFromId, cToId, 1, _pe_, _qe_)
				_chan_ = This._ClaimChannel(_chan_, _pay_, _qay_,
					cFromId, _pe_, _qe_, cFromId, cToId, 1)
				_chan_ = This._ChannelClear(_chan_, _pe_, _qe_, nWidth)
				This._EmitOrthoPolyline(oC, [ _pe_, _pay_, _chan_,
					_pay_, _chan_, _qay_, _qe_, _qay_ ],
					cColor, nWidth, cFromId + ">" + cToId)
				_p_ = [ _chan_, _qay_ ]
				_q_ = [ _qe_, _qay_ ]
			else
				_pax_ = aFrom[1]
				_qax_ = aTo[1] + nPortB
				_sgn_ = 1
				if aTo[2] < aFrom[2]  _sgn_ = -1  ok
				_pe_ = aFrom[2] + _sgn_ * _bcA_[2] / 2
				_qe_ = aTo[2] - _sgn_ * _bcB_[2] / 2
				_chan_ = _pe_ + (_qe_ - _pe_) * nLane
				# a HORIZONTAL channel spans X -- the first call here
				# passed the Y pair, so every obstacle test ran against a
				# span from the wrong axis and the placer worked on
				# fiction
				_chan_ = This._ChannelBand(_chan_, _pax_, _qax_,
					cFromId, cToId, 0, _pe_, _qe_)
				_chan_ = This._ClaimChannel(_chan_, _pax_, _qax_,
					cFromId, _pe_, _qe_, cFromId, cToId, 0)
				_chan_ = This._ChannelBelowRails(_chan_, aFrom[2], nBoxH,
					_pe_, _qe_, nWidth)
				_chan_ = This._ChannelClear(_chan_, _pe_, _qe_, nWidth)
				This._EmitOrthoPolyline(oC, [ _pax_, _pe_, _pax_,
					_chan_, _qax_, _chan_, _qax_, _qe_ ],
					cColor, nWidth, cFromId + ">" + cToId)
				_p_ = [ _qax_, _chan_ ]
				_q_ = [ _qax_, _qe_ ]
			ok
		on "line"
			oC.Flush()
			oC.AddLineQ(_p_[1], _p_[2], _q_[1], _q_[2]).Stroke(cColor, nWidth)
			This._PublishPath(cFromId, cToId, [ _p_[1], _p_[2], _q_[1], _q_[2] ])
		on "polyline"
			oC.Flush()
			oC.AddLineQ(_p_[1], _p_[2], _q_[1], _q_[2]).Stroke(cColor, nWidth)
			This._PublishPath(cFromId, cToId, [ _p_[1], _p_[2], _q_[1], _q_[2] ])
		other
			oC.Flush()
			_cvp_ = This._CurvePoints(_p_, _q_, cRank)
			oC.AddPolylineQ(_cvp_).Stroke(cColor, nWidth)
			This._PublishPath(cFromId, cToId, _cvp_)
		off

		if @nDrawPass = 2
			This._DrawArrow(oC, _p_, _q_, cColor, nWidth, cSpline, cRank)
		ok

	# THE DRAWN GEOMETRY, PUBLISHED. Ortho edges have recorded their path
	# since the label placer needed one; straight chords and curves never
	# did, so under a non-ortho spline every instrument -- and the label
	# placer itself -- fell back to guessing. A ring is drawn in straight
	# chords, so the ring made the omission matter.
	# A CHANNEL MUST LEAVE ROOM FOR THE HEAD IT FEEDS.
	#
	# The channel placer's whole job is dodging obstacles, and it will
	# happily park a run five pixels above the state it is arriving at.
	# The arrowhead is thirteen: it then overlaps its own approach run
	# and comes out as a smudged tee rather than an arrow entering a
	# cell. The connection diagram's "handshake ok" was exactly this.
	#
	# So the channel is pushed back off both borders -- the head's length
	# at the arrival, one clearance at the departure -- and where the gap
	# is too small to hold both, it takes the middle, which is the best
	# a narrow gap allows and is at least symmetric.
	# THE DEEPEST RAIL RUNNING UNDER ONE ROW, in the picture's own
	# coordinates. Asked by anything that wants to put a line under that
	# row and would rather not put it ON one.
	def _DeepestRailAt(nRowY, nBoxH)
		_drBest_ = 0
		for _drE_ in This.Edges()
			_drF_ = StzLower("" + _drE_[:from])
			_drT_ = StzLower("" + _drE_[:to])
			if _drF_ = _drT_  loop  ok
			_drL_ = This._LaneKept(_drF_ + ">" + _drT_)
			if _drL_ < 1  loop  ok
			_drAt_ = This._XYOf(@aDrawXY, _drF_)
			if len(_drAt_) != 2  loop  ok
			if fabs(_drAt_[2] - nRowY) > 2  loop  ok
			_drY_ = _drAt_[2] + This._LaneOffset(_drL_, nBoxH)
			if _drY_ > _drBest_  _drBest_ = _drY_  ok
		next
		return _drBest_

	# ONE LADDER FOR EVERYTHING THAT RUNS UNDER A ROW.
	#
	# Two allocators were handing out horizontal runs under the same row
	# and neither could see the other's: the lane placer for returns and
	# the channel placer for edges crossing a rank. In the order they
	# put "retry" at y=431.55 and "authorised" at y=443.20 -- ELEVEN
	# pixels apart, two lines a reader has to separate by eye, and the
	# Principal marked it twice in one picture.
	#
	# A row's rails belong to that row. An edge LEAVING the row passes
	# under all of them, which is the true reading as well as the legible
	# one -- so a channel that would land in the rails' band is pushed
	# past the deepest of them, and it keeps a clearance there like
	# everything else.
	def _ChannelBelowRails(nChan, nRowY, nBoxH, nPe, nQe, nWidth)
		_cbRail_ = This._DeepestRailAt(nRowY, nBoxH)
		if _cbRail_ <= 0  return nChan  ok
		_cbClr_ = This._LineClearance()
		if nQe <= nPe  return nChan  ok             # this edge goes UP
		if nChan > _cbRail_ + _cbClr_  return nChan  ok
		_cbWant_ = _cbRail_ + _cbClr_
		# ...but never past the border it is about to arrive at
		_cbHead_ = 9 + nWidth * 2 + _cbClr_
		if _cbWant_ > nQe - _cbHead_  _cbWant_ = nQe - _cbHead_  ok
		if _cbWant_ < nChan  return nChan  ok
		return _cbWant_

	def _ChannelClear(nChan, nPe, nQe, nWidth)
		_ccHead_ = 9 + nWidth * 2 + This._LineClearance()
		_ccFoot_ = This._LineClearance()
		_ccLo_ = nPe  _ccHi_ = nQe
		_ccSg_ = 1
		if _ccLo_ > _ccHi_
			_ccSg_ = -1
			_ccT_ = _ccLo_  _ccLo_ = _ccHi_  _ccHi_ = _ccT_
		ok
		if _ccHi_ - _ccLo_ < _ccHead_ + _ccFoot_
			return (_ccLo_ + _ccHi_) / 2
		ok
		if _ccSg_ > 0
			if nChan < _ccLo_ + _ccFoot_  return _ccLo_ + _ccFoot_  ok
			if nChan > _ccHi_ - _ccHead_  return _ccHi_ - _ccHead_  ok
		else
			if nChan < _ccLo_ + _ccHead_  return _ccLo_ + _ccHead_  ok
			if nChan > _ccHi_ - _ccFoot_  return _ccHi_ - _ccFoot_  ok
		ok
		return nChan

	def _PublishPath(cFromId, cToId, paFlat)
		_ppK_ = StzLower("" + cFromId + ">" + cToId)
		for _ppR_ in @aEdgePaths
			if StzLower("" + _ppR_[1]) = _ppK_  return  ok
		next
		@aEdgePaths + [ _ppK_, paFlat ]

	# A quadratic bend, sampled. The control point leans along the RANK axis,
	# which is what makes dot's splines read as flowing down the hierarchy
	# rather than as an arbitrary arc.
	def _CurvePoints(aP, aQ, cRank)
		if cRank = "LR" or cRank = "RL"
			_cx_ = aP[1] + (aQ[1] - aP[1]) * 0.55
			_cy_ = aP[2]
		else
			_cy_ = aP[2] + (aQ[2] - aP[2]) * 0.55
			_cx_ = aP[1]
		ok
		_a_ = []
		for _i_ = 0 to 18
			_t_ = _i_ / 18
			_u_ = 1 - _t_
			_a_ + (_u_ * _u_ * aP[1] + 2 * _u_ * _t_ * _cx_ + _t_ * _t_ * aQ[1])
			_a_ + (_u_ * _u_ * aP[2] + 2 * _u_ * _t_ * _cy_ + _t_ * _t_ * aQ[2])
		next
		return _a_

	# The arrowhead points the way the edge ARRIVES. On a curve that is the
	# tangent at the end, which is NOT the straight line between centres --
	# an arrow pointing the wrong way is worse than no arrow.
	def _DrawArrow(oC, aP, aQ, cColor, nWidth, cSpline, cRank)
		_bx_ = aP[1]
		_by_ = aP[2]
		if cSpline = "ortho"
			if cRank = "LR" or cRank = "RL"
				_bx_ = aQ[1] - 10
				_by_ = aQ[2]
			else
				_bx_ = aQ[1]
				_by_ = aQ[2] - 10
			ok
		but cSpline != "line" and cSpline != "polyline"
			_a_ = This._CurvePoints(aP, aQ, cRank)
			_n_ = len(_a_)
			if _n_ >= 4
				_bx_ = _a_[_n_ - 3]
				_by_ = _a_[_n_ - 2]
			ok
		ok
		_dx_ = aQ[1] - _bx_
		_dy_ = aQ[2] - _by_
		_L_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
		if _L_ < 0.001  return  ok
		_dx_ = _dx_ / _L_
		_dy_ = _dy_ / _L_
		_sz_ = 6 + nWidth * 2
		_px_ = 0 - _dy_
		_py_ = _dx_
		# STROKE WIDTH 0, explicitly. An arrowhead is a solid triangle, and
		# without this it inherits whatever outline the canvas last had --
		# which, after a cluster border, drew grey arrows outlined in
		# magenta. Setting only the fill leaves the other half of the style
		# to whoever ran before.
		oC.Flush()
		oC.Stroke(cColor, 0)
		oC.FillQ(cColor).AddPolygon([
			aQ[1], aQ[2],
			aQ[1] - _dx_ * _sz_ + _px_ * _sz_ * 0.45,
			aQ[2] - _dy_ * _sz_ + _py_ * _sz_ * 0.45,
			aQ[1] - _dx_ * _sz_ - _px_ * _sz_ * 0.45,
			aQ[2] - _dy_ * _sz_ - _py_ * _sz_ * 0.45 ])
		oC.Flush()

	# Where the segment from aCentre towards aOther leaves aCentre's box.
	def _ClipToBox(aCentre, aOther, nBoxW, nBoxH)
		_dx_ = aOther[1] - aCentre[1]
		_dy_ = aOther[2] - aCentre[2]
		if _dx_ = 0 and _dy_ = 0  return [ aCentre[1], aCentre[2] ]  ok
		_hw_ = nBoxW / 2 + 2
		_hh_ = nBoxH / 2 + 2
		_tx_ = 1000000
		_ty_ = 1000000
		if _dx_ != 0  _tx_ = fabs(_hw_ / _dx_)  ok
		if _dy_ != 0  _ty_ = fabs(_hh_ / _dy_)  ok
		_t_ = min([ _tx_, _ty_ ])
		return [ aCentre[1] + _dx_ * _t_, aCentre[2] + _dy_ * _t_ ]

	# Trim a label to the node width with an ellipsis, so a long title never
	# spills outside the shape it belongs to.
	def _FitLabel(cText, oFont, nSize, nMaxW)
		if NOT isObject(oFont)  return cText  ok
		if oFont.WidthOf(cText, nSize) <= nMaxW  return cText  ok
		_c_ = cText
		while len(_c_) > 1 and oFont.WidthOf(_c_ + "...", nSize) > nMaxW
			_c_ = StzSubStr(_c_, 1, len(_c_) - 1)
		end
		return _c_ + "..."

	# Whether the caller NAMED this option at all -- _DiagOpt cannot tell
	# "absent" from "given the default", and natural sizing turns on
	# exactly when a size was not named.
	def _HasOpt(paOptions, cKey)
		if NOT isList(paOptions)  return 0  ok
		for _ho_ in paOptions
			if isList(_ho_) and len(_ho_) = 2
				if StzLower("" + _ho_[1]) = StzLower("" + cKey)  return 1  ok
			ok
		next
		return 0

	def _DiagOpt(paOptions, cKey, xDefault)
		if NOT isList(paOptions)  return xDefault  ok
		for _p_ in paOptions
			if isList(_p_) and len(_p_) = 2
				if StzLower("" + _p_[1]) = StzLower("" + cKey)
					return _p_[2]
				ok
			ok
		next
		return xDefault

	def _XYOf(aXY, cId)
		_c_ = StzLower(cId)
		for _r_ in aXY
			if _r_[1] = _c_  return [ _r_[2], _r_[3] ]  ok
		next
		return []

	# The shape a node asked for, mapped into the drawable vocabulary. An
	# unknown name becomes a box rather than a refusal: a diagram that
	# would not draw at all because one node named a shape graphviz has and
	# this does not is a worse outcome than a box.
	# THE SAME TRANSLATION THE DOT WRITER USES, not a second one.
	#
	# This read the node's `type` and asked StzIsNodeShape whether it was a
	# shape. It never is: `start`, `process`, `decision`, `storage` are the
	# SEMANTIC vocabulary and `ellipse`, `box`, `diamond`, `cylinder` are
	# the geometric one, and translating between them is exactly what
	# _GetNodeShape was already written to do for ToDot. So every diagram
	# that named a type got the fallback -- a rounded box for a decision, a
	# rounded box for a database, a rounded box for everything -- while the
	# SAME diagram exported to dot came out with the right shapes. Two
	# renderers of one model disagreeing, with the correct answer already
	# in the file.
	#
	# Found by rendering the node types side by side and looking at them;
	# no assertion here had ever named a shape a TYPE should produce.
	def _NativeShapeOf(aNode)
		_c_ = ""
		if HasKey(aNode, "properties") and isList(aNode["properties"])
			if HasKey(aNode["properties"], "shape")
				_c_ = "" + aNode["properties"]["shape"]
			but HasKey(aNode["properties"], "type")
				_c_ = "" + aNode["properties"]["type"]
			ok
		ok
		# THROUGH THE NOTATION, which is the DN seam: the profile owns
		# the kind->glyph answer. The default profile answers through the
		# same shared table this line used to call directly, so the
		# default picture cannot move; a domain profile answers from its
		# own declared vocabulary.
		_c_ = This.NotationO().GlyphOf(_c_)
		if _c_ != "" and StzIsNodeShape(_c_)  return _c_  ok
		return :Box

	def _NativeFillOf(aNode)
		_cKd_ = ""
		if HasKey(aNode, "properties") and isList(aNode["properties"])
			if HasKey(aNode["properties"], "color")
				return ResolveColor("" + aNode["properties"]["color"])
			but HasKey(aNode["properties"], "fillcolor")
				return ResolveColor("" + aNode["properties"]["fillcolor"])
			ok
			if HasKey(aNode["properties"], "type")
				_cKd_ = "" + aNode["properties"]["type"]
			ok
		ok
		# THE NOTATION'S OWN PALETTE, when the author named no colour.
		# A domain that declares what a state IS should declare what a
		# state LOOKS like, in the house role vocabulary -- so a profile
		# inherits the whole colour system rather than carrying hex.
		if _cKd_ != ""
			_cNf_ = This.NotationO().FillOf(_cKd_)
			if _cNf_ != ""  return ResolveColor(_cNf_)  ok
		ok
		return "#2E4970"

	# The box that contains every member of a cluster, padded. Returns []
	# when no member has a position, so a cluster naming nodes that are not
	# in the diagram draws nothing instead of a rectangle at the origin.
	# HOW MUCH OF A RANK GAP A CLUSTER'S CHROME EATS -- its label strip
	# plus its padding, at the deepest nesting in the picture.
	#
	# Named once because two places must agree about it, and they did not:
	# the box adds `max(16, clearance*0.75) + 34 per level of nesting` and
	# then a label strip on top, while the rank-gap floor that was meant to
	# leave room for it estimated the padding WITHOUT the nesting term. On
	# the service diagram that was 42.7 estimated against 76.7 actual, so
	# the gap grew, the frame grew with it, and the band left for a
	# traversing channel stayed 14px -- the Principal measured a 7px stem
	# where every other stem was 46. A floor computed from a different
	# formula than the thing it is flooring is not a floor.
	# THE DEEPEST PADDING ANY FRAME IN THIS PICTURE CARRIES. A frame
	# stands this far outside its own members, so a neighbour outside
	# it must stand this far plus a clearance from those members for
	# the frame to clear the neighbour.
	# A FRAME CONTAINS THE INK OF ITS OWN MEMBERS, not just their boxes --
	# I1, which the region model made visible. Two peers inside a mode
	# talk both ways, and the return rail of an opposite pair rides one
	# clearance below the row: at 0.75 of a clearance the padding was
	# narrower than the ink it had to hold, so `close` and `unlock` were
	# drawn OUTSIDE the region whose states they join. The pad is one
	# clearance plus the stroke now -- the width of the thing it contains.
	# HOW FAR A FRAME OVERHANGS ITS OWN ROW, above and below. A region
	# grows downward to hold the return lanes its peers ride, so equal
	# RANK gaps come out as unequal WHITE -- 103px of paper above the
	# frame against 74 below, which is what the Principal braced. What a
	# reader sees is the distance to the FRAME, so that is the distance
	# the layout has to make equal: the gap below a region owes the
	# overhang the gap above does not carry.
	def _ClusterOverhangBelow(paXY, nBoxH)
		_nOv_ = 0
		for _ohC_ in @aClusters
			_ohLo_ = -1
			for _ohM_ in _ohC_[:nodes]
				_ohA_ = This._XYOf(paXY, "" + _ohM_)
				if len(_ohA_) != 2  loop  ok
				if _ohA_[2] > _ohLo_  _ohLo_ = _ohA_[2]  ok
			next
			if _ohLo_ < 0  loop  ok
			_ohB_ = This._ClusterBox(_ohC_, paXY, 0, nBoxH)
			if len(_ohB_) != 4  loop  ok
			_ohD_ = (_ohB_[2] + _ohB_[4]) - (_ohLo_ + nBoxH / 2)
			if _ohD_ > _nOv_  _nOv_ = _ohD_  ok
		next
		return _nOv_

	# HOW FAR A RETURN LANE SITS FROM ITS ROW -- ONE ANSWER, THREE
	# CALLERS. The offset was counted from the row's CENTRE-LINE, so the
	# first lane landed a clearance from the centre and four pixels from
	# the boxes: a rail hugging the cells it runs under, which is what
	# the Principal circled. A clearance is clearance FROM THE INK, and
	# the ink here is the row of cells -- so a lane clears the box first
	# and then counts.
	#
	# One method because three places need this number -- the drawing,
	# the twin's mirror, and the frame that has to contain them -- and
	# the last time one rule lived in several places an edge ended 28px
	# from the state it named.
	# IS ANYTHING STANDING BETWEEN THESE TWO?
	#
	# Two peers on one row are joined by one straight segment, which is
	# right when they are neighbours and a LIE when they are not: the
	# Principal's player drew paused>stopped as a horizontal line
	# through the middle of Playing, and the picture then said that
	# Playing was on the way from Paused to Stopped. It is not on the
	# way; it is merely in the way.
	#
	# The margin is half a box plus a clearance on each side, so a node
	# whose EDGE reaches into the corridor counts as standing in it --
	# grazing a box is as unreadable as crossing it.
	# WHAT THE PICTURE ACTUALLY OCCUPIES -- every mark, not every
	# coordinate the layout reserved. A canvas sized from a reservation
	# is a canvas with white on it nobody drew, and that white reads as
	# space the author left deliberately.
	#
	# Five kinds of mark reach past a node's centre, and each of them was
	# learnt by something falling off an edge: half a cell; the name
	# written UNDER a cell that is not a rectangle; the loop that
	# radiates out of a cell; the word beside that loop; and the frame
	# drawn around a region, with its own name above it.
	def _ContentExtent(paXY, nBoxW, nBoxH, poFont, nFsz)
		_ceX0_ = 1000000000  _ceY0_ = 1000000000  _ceX1_ = 0 - 1000000000  _ceY1_ = 0 - 1000000000
		_ceAny_ = 0
		for _ceN_ in This.Nodes()
			_ceAt_ = This._XYOf(paXY, "" + _ceN_[:id])
			if len(_ceAt_) != 2  loop  ok
			_ceB_ = This._BoxOf("" + _ceN_[:id], nBoxW, nBoxH)
			_ceL_ = _ceAt_[1] - _ceB_[1] / 2
			_ceR_ = _ceAt_[1] + _ceB_[1] / 2
			_ceT_ = _ceAt_[2] - _ceB_[2] / 2
			_ceBo_ = _ceAt_[2] + _ceB_[2] / 2
			# a round cell writes its name underneath
			_ceSh_ = StzLower("" + This._NativeShapeOf(_ceN_))
			for _ceO_ in [ "circle", "doublecircle", "dot", "diamond",
				"triangle", "invtriangle" ]
				if _ceSh_ != _ceO_  loop  ok
				_ceBo_ += nFsz * 2.4
				if isObject(poFont)
					_ceW2_ = poFont.WidthOf("" + _ceN_[:label], nFsz) / 2
					if _ceAt_[1] - _ceW2_ < _ceL_  _ceL_ = _ceAt_[1] - _ceW2_  ok
					if _ceAt_[1] + _ceW2_ > _ceR_  _ceR_ = _ceAt_[1] + _ceW2_  ok
				ok
				exit
			next
			if _ceL_ < _ceX0_  _ceX0_ = _ceL_  ok
			if _ceT_ < _ceY0_  _ceY0_ = _ceT_  ok
			if _ceR_ > _ceX1_  _ceX1_ = _ceR_  ok
			if _ceBo_ > _ceY1_  _ceY1_ = _ceBo_  ok
			_ceAny_ = 1
		next
		if NOT _ceAny_  return []  ok

		# the loops, and the words beside them
		_ceSlr_ = This._SelfLoopReach(nBoxW, nBoxH) + 6
		for _ceE_ in This.Edges()
			if StzLower("" + _ceE_[:from]) != StzLower("" + _ceE_[:to])
				loop
			ok
			_ceAt_ = This._XYOf(paXY, "" + _ceE_[:from])
			if len(_ceAt_) != 2  loop  ok
			_ceRch_ = _ceSlr_
			if StzTrim("" + _ceE_[:label]) != "" and isObject(poFont)
				_ceRch_ += poFont.WidthOf("" + _ceE_[:label], nFsz) + 14
			ok
			if _ceAt_[1] - _ceRch_ < _ceX0_  _ceX0_ = _ceAt_[1] - _ceRch_  ok
			if _ceAt_[1] + _ceRch_ > _ceX1_  _ceX1_ = _ceAt_[1] + _ceRch_  ok
			if _ceAt_[2] - _ceSlr_ < _ceY0_  _ceY0_ = _ceAt_[2] - _ceSlr_  ok
			if _ceAt_[2] + _ceSlr_ > _ceY1_  _ceY1_ = _ceAt_[2] + _ceSlr_  ok
		next

		# the frames, and their names above them
		for _ceC_ in @aClusters
			_ceBx_ = This._ClusterBox(_ceC_, paXY, nBoxW, nBoxH)
			if len(_ceBx_) != 4  loop  ok
			if _ceBx_[1] < _ceX0_  _ceX0_ = _ceBx_[1]  ok
			# ...and the name strip only when there is a name, the same
			# rule the drawing follows -- reserved either way, it was air
			# above the picture that nothing balanced below it
			_ceSt_ = 0
			if StzTrim("" + _ceC_[:label]) != ""  _ceSt_ = nFsz * 1.9  ok
			if _ceBx_[2] - _ceSt_ < _ceY0_
				_ceY0_ = _ceBx_[2] - _ceSt_
			ok
			if _ceBx_[1] + _ceBx_[3] > _ceX1_  _ceX1_ = _ceBx_[1] + _ceBx_[3]  ok
			if _ceBx_[2] + _ceBx_[4] > _ceY1_  _ceY1_ = _ceBx_[2] + _ceBx_[4]  ok
		next
		return [ _ceX0_, _ceY0_, _ceX1_, _ceY1_ ]

	def _SomethingBetween(paA, paB, nBoxW, nBoxH, cRank, pcFrom, pcTo)
		_sbAx_ = 1  _sbCr_ = 2
		if cRank = "LR" or cRank = "RL"  _sbAx_ = 2  _sbCr_ = 1  ok
		_sbLo_ = paA[_sbAx_]
		_sbHi_ = paB[_sbAx_]
		if _sbLo_ > _sbHi_
			_sbT_ = _sbLo_  _sbLo_ = _sbHi_  _sbHi_ = _sbT_
		ok
		_sbF_ = StzLower("" + pcFrom)
		_sbT2_ = StzLower("" + pcTo)
		for _sbR_ in @aDrawXY
			if len(_sbR_) < 3  loop  ok
			_sbId_ = StzLower("" + _sbR_[1])
			if _sbId_ = _sbF_ or _sbId_ = _sbT2_  loop  ok
			_sbP_ = [ _sbR_[2], _sbR_[3] ]
			# only what shares the row is in the way
			if fabs(_sbP_[_sbCr_] - paA[_sbCr_]) > 1.5  loop  ok
			_sbB_ = This._BoxOf(_sbId_, nBoxW, nBoxH)
			_sbHalf_ = _sbB_[1] / 2
			if _sbAx_ = 2  _sbHalf_ = _sbB_[2] / 2  ok
			_sbHalf_ += This._LineClearance()
			if _sbP_[_sbAx_] + _sbHalf_ > _sbLo_ and
			   _sbP_[_sbAx_] - _sbHalf_ < _sbHi_
				return 1
			ok
		next
		return 0

	# A LANE BELONGS TO A CORRIDOR, NOT TO A ROW.
	#
	# The old bookkeeping counted lanes per row coordinate, so three
	# INDEPENDENT switch pairs sitting on one row -- nothing linking
	# them, three separate regions -- were given lanes one, two and
	# three. Three pictures of the same shape came out looking like
	# three different shapes, and the third region's return line was
	# pushed clean outside the frame that was supposed to contain it.
	#
	# Two edges only contend for a lane when their spans OVERLAP. This
	# hands back the lowest lane free over [nLo, nHi] and records the
	# claim, so identical structures get identical lanes wherever they
	# sit on the row.
	# A LANE IS DECIDED ONCE, IN PASS ONE, AND REMEMBERED. Ortho draws
	# twice -- pass one learns the segments, pass two draws with the
	# hops. Allocating again in pass two would see pass one's claims
	# still standing and hand every edge a second, deeper lane, so the
	# picture drawn would not be the picture measured.
	# IS THIS PAIR THE SHAPE THE TWIN DRAWER KNOWS?
	#
	# The twin drawer builds the return by MIRRORING its partner's path,
	# offset by a lane -- which is right, and only right, while the
	# partner is a single run along the row. When the forward member is
	# ITSELF a staircase (because a state stands between the two, so it
	# had to step off the row as well), mirroring it produces a shape
	# that is neither: the door's "unlock" came out as two diagonals
	# reaching 22px off the right-hand edge of its own picture.
	#
	# So the pair is the twin drawer's only while exactly ONE member
	# leaves the row. When both leave it, they are two ordinary laned
	# edges and each is drawn as one.
	def _TwinIsPlain(pcA, pcB)
		_tpA_ = This._LaneKept(
			StzLower("" + pcA) + ">" + StzLower("" + pcB))
		_tpB_ = This._LaneKept(
			StzLower("" + pcB) + ">" + StzLower("" + pcA))
		if _tpA_ > 0 and _tpB_ > 0  return 0  ok
		return 1


	def _LaneKept(pcKey)
		for _lkR_ in @aLaneKept
			if _lkR_[1] = pcKey  return _lkR_[2]  ok
		next
		return 0

	# EVERY LANE IN THE PICTURE, DECIDED ONCE, BEFORE ANYTHING IS DRAWN.
	#
	# The frame around a region has to be tall enough to hold the return
	# lines inside it, so it needs the lane depths -- and it is measured
	# during LAYOUT, while the lanes were being handed out during
	# DRAWING. So the frame estimated them, by a rule ("count the twin
	# pairs") that was a good guess and not the answer: a return with no
	# partner was invisible to it, and the third rail was drawn on top of
	# the frame's own bottom rule.
	#
	# An estimate of something the program will later compute exactly is
	# a bug waiting for its picture. This computes it, once; the frame
	# reads it, the drawing reads it, and the two cannot disagree.
	def _PlanRowLanes(paXY, nBoxW, nBoxH, cRank)
		@aSameRowLanes = []
		@aLaneKept = []
		_plAx_ = 1  _plCr_ = 2
		if cRank = "LR" or cRank = "RL"  _plAx_ = 2  _plCr_ = 1  ok
		for _plE_ in This.Edges()
			_plF_ = "" + _plE_[:from]
			_plT_ = "" + _plE_[:to]
			if StzLower(_plF_) = StzLower(_plT_)  loop  ok
			_plA_ = This._XYOf(paXY, _plF_)
			_plB_ = This._XYOf(paXY, _plT_)
			if len(_plA_) != 2 or len(_plB_) != 2  loop  ok
			if fabs(_plA_[_plCr_] - _plB_[_plCr_]) > 1.5  loop  ok
			# A RETURN steps off the row so it does not overlay its
			# partner; an edge WITH SOMETHING IN THE WAY steps off it
			# because the row is not free. Everything else keeps the row.
			_plWant_ = 0
			if _plB_[_plAx_] < _plA_[_plAx_] and This.EdgeExists(_plT_, _plF_)
				_plWant_ = 1
			ok
			if This._SomethingBetween(_plA_, _plB_, nBoxW, nBoxH,
				cRank, _plF_, _plT_)  _plWant_ = 1  ok
			if NOT _plWant_  loop  ok
			_plKey_ = ceil(_plA_[_plCr_])
			_plLane_ = This._SameRowLane(_plKey_, _plA_[_plAx_], _plB_[_plAx_])
			@aLaneKept + [ StzLower(_plF_) + ">" + StzLower(_plT_), _plLane_ ]
		next
		This._PlanLaneStubs(paXY, nBoxW, nBoxH, cRank)

	# WHERE EACH LANED EDGE MEETS ITS NODE'S BORDER.
	#
	# The staircase used the node's CENTRE at both ends, so an edge
	# leaving a state and an edge arriving at it stood on the same
	# column running opposite ways -- and the Principal read the result
	# exactly as it looks: one line carrying an arrowhead at each end,
	# from which no reader can tell which direction is meant. Two edges
	# are two lines, and two lines do not share a column.
	#
	# So each border hands out its own columns, spread evenly across it
	# and ordered by where the other end lies, which is also what stops
	# them crossing each other on the way out.
	def _PlanLaneStubs(paXY, nBoxW, nBoxH, cRank)
		@aStubOf = []
		_psAx_ = 1
		if cRank = "LR" or cRank = "RL"  _psAx_ = 2  ok
		for _psN_ in This.Nodes()
			_psId_ = StzLower("" + _psN_[:id])
			_psAt_ = This._XYOf(paXY, _psId_)
			if len(_psAt_) != 2  loop  ok
			# every laned edge touching this node, with the coordinate
			# of its OTHER end -- the key that orders them
			_psTouch_ = []
			for _psE_ in This.Edges()
				_psF_ = StzLower("" + _psE_[:from])
				_psT_ = StzLower("" + _psE_[:to])
				if _psF_ = _psT_  loop  ok
				if This._LaneKept(_psF_ + ">" + _psT_) < 1  loop  ok
				_psOther_ = ""
				_psEnd_ = 0
				if _psF_ = _psId_
					_psOther_ = _psT_  _psEnd_ = 1
				but _psT_ = _psId_
					_psOther_ = _psF_  _psEnd_ = 2
				else
					loop
				ok
				_psOAt_ = This._XYOf(paXY, _psOther_)
				if len(_psOAt_) != 2  loop  ok
				_psTouch_ + [ _psF_ + ">" + _psT_, _psEnd_,
					_psOAt_[_psAx_] ]
			next
			_psN2_ = len(_psTouch_)
			if _psN2_ = 0  loop  ok
			# ordered by the other end, so the columns fan the way the
			# lines go and no two of them have to cross to get there
			for _psI_ = 1 to _psN2_ - 1
				for _psJ_ = 1 to _psN2_ - _psI_
					if _psTouch_[_psJ_][3] > _psTouch_[_psJ_ + 1][3]
						_psSw_ = _psTouch_[_psJ_]
						_psTouch_[_psJ_] = _psTouch_[_psJ_ + 1]
						_psTouch_[_psJ_ + 1] = _psSw_
					ok
				next
			next
			_psB_ = This._BoxOf(_psId_, nBoxW, nBoxH)
			_psSpan_ = _psB_[1]
			if _psAx_ = 2  _psSpan_ = _psB_[2]  ok
			# ...and a SINGLE stub takes the middle. Spreading one edge
			# off-centre says there is another one to make room for,
			# and there is not.
			for _psI_ = 1 to _psN2_
				_psOff_ = 0
				if _psN2_ > 1
					_psOff_ = 0 - _psSpan_ / 2 +
						_psSpan_ * _psI_ / (_psN2_ + 1)
				ok
				@aStubOf + [ _psTouch_[_psI_][1], _psTouch_[_psI_][2],
					_psOff_ ]
			next
		next

	# The offset for one end of one laned edge: 1 for where it leaves,
	# 2 for where it arrives.
	def _StubOf(pcKey, nEnd)
		for _soR_ in @aStubOf
			if _soR_[1] = pcKey and _soR_[2] = nEnd  return _soR_[3]  ok
		next
		return 0

	# The deepest lane running inside one region, so the frame drawn
	# around it can be tall enough to contain it -- read from the plan,
	# never guessed.
	# How far below its rail the deepest return writes its event. The
	# label sits beside the line, so the frame must hold a whole label
	# plus the air it keeps from the line -- and zero when the deepest
	# rail carries no word at all.
	def _DeepestRailLabel(paXY, paMembers, nRowY, nLane, nBoxW)
		for _dlE_ in This.Edges()
			_dlF_ = StzLower("" + _dlE_[:from])
			_dlT_ = StzLower("" + _dlE_[:to])
			if _dlF_ = _dlT_  loop  ok
			if This._LaneKept(_dlF_ + ">" + _dlT_) != nLane  loop  ok
			_dlIn1_ = 0  _dlIn2_ = 0
			for _dlM_ in paMembers
				if StzLower("" + _dlM_) = _dlF_  _dlIn1_ = 1  ok
				if StzLower("" + _dlM_) = _dlT_  _dlIn2_ = 1  ok
			next
			if NOT (_dlIn1_ and _dlIn2_)  loop  ok
			if StzTrim("" + _dlE_[:label]) = ""  loop  ok
			_dlB_ = This._LabelBlock("" + _dlE_[:label], @oLastFont,
				@nLastFsz, nBoxW)
			# the DRAWN height, which is what has to fit -- a block's
			# measured height is its glyphs, and a label occupies its
			# line box
			_dlH_ = _dlB_[3]
			if @nLastFsz * 1.7 > _dlH_  _dlH_ = @nLastFsz * 1.7  ok
			return _dlH_ + This._LineClearance() * 0.25
		next
		return 0

	def _MaxLaneIn(paXY, paMembers, nRowY)
		_mlBest_ = 0
		for _mlE_ in This.Edges()
			_mlF_ = StzLower("" + _mlE_[:from])
			_mlT_ = StzLower("" + _mlE_[:to])
			if _mlF_ = _mlT_  loop  ok
			_mlIn1_ = 0  _mlIn2_ = 0
			for _mlM_ in paMembers
				if StzLower("" + _mlM_) = _mlF_  _mlIn1_ = 1  ok
				if StzLower("" + _mlM_) = _mlT_  _mlIn2_ = 1  ok
			next
			if NOT (_mlIn1_ and _mlIn2_)  loop  ok
			_mlAt_ = This._XYOf(paXY, _mlF_)
			if len(_mlAt_) != 2  loop  ok
			if fabs(_mlAt_[2] - nRowY) > 2  loop  ok
			_mlL_ = This._LaneKept(_mlF_ + ">" + _mlT_)
			if _mlL_ > _mlBest_  _mlBest_ = _mlL_  ok
		next
		return _mlBest_

	def _SameRowLane(nRowKey, nLo, nHi)
		_slLo_ = nLo  _slHi_ = nHi
		if _slLo_ > _slHi_
			_slT_ = _slLo_  _slLo_ = _slHi_  _slHi_ = _slT_
		ok
		# TOUCHING IS OVERLAPPING. Two runs that meet at one x are
		# disjoint by arithmetic and a single continuous line to the
		# eye: "stop" ended where "resume" began, both at the same
		# depth, and the picture showed one wire from Paused to Stopped
		# with a tee in it. A span is claimed with a clearance at each
		# end, so a shared endpoint pushes the second run to its own
		# lane.
		_slPad_ = This._LineClearance()
		_slLo_ -= _slPad_
		_slHi_ += _slPad_
		_slLane_ = 1
		while _slLane_ < 64
			_slFree_ = 1
			for _slR_ in @aSameRowLanes
				if len(_slR_) < 4  loop  ok
				if _slR_[4] != _slLane_  loop  ok
				if fabs(_slR_[1] - nRowKey) > 1.5  loop  ok
				if _slR_[3] > _slLo_ and _slR_[2] < _slHi_
					_slFree_ = 0
					exit
				ok
			next
			if _slFree_  exit  ok
			_slLane_++
		end
		@aSameRowLanes + [ nRowKey, _slLo_, _slHi_, _slLane_ ]
		return _slLane_

	def _LanePitchValue()
		return @nLanePitch

	def _LaneOffset(nLane, nBoxH)
		if nLane < 1  return 0  ok
		# THE PITCH BETWEEN LANES HOLDS WHAT IS WRITTEN BESIDE THEM. At
		# one clearance the lanes cleared each other and left nowhere for
		# their events to stand: the placer found every beside-spot
		# refused and fell back to putting "close" ON its own rail, where
		# the plate erased the line -- the alteration this library has
		# now been marked for twice. A lane's pitch is a clearance plus a
		# label, so a return can always be named beside itself.
		return nBoxH / 2 + @nLanePitch * nLane

	# HOW FAR APART TWO RAILS RUN.
	#
	# Two things set it, and only one of them was being asked. A rail
	# carries a word, so consecutive rails are at least a word apart --
	# that was here. And a rail CLIMBS into its node at the end, and that
	# climb has to be long enough to hold an arrowhead -- that was not,
	# so _EnsureArrival lengthened the climb afterwards, silently, by
	# pushing the rail deeper than the depth it had been given. The frame
	# measured the allocation and the picture drew the correction: the
	# traffic light's return ran 13px below where its frame believed it
	# was, and the word under it stood 4px from the frame's own rule.
	#
	# A correction applied after a measurement is a measurement that was
	# wrong. The floor is in the pitch now, so nothing needs correcting.
	def _ArrowRun()
		return 9 + @nLastEdgeW * 2 + This._LineClearance()

	def _SetLanePitch(oFont, nFsz, nBoxW)
		@nLanePitch = This._LineClearance()
		if This._ArrowRun() > @nLanePitch  @nLanePitch = This._ArrowRun()  ok
		if NOT isObject(oFont)  return This  ok
		# EVERY EDGE THAT CAN TAKE A LANE, not just the paired ones.
		# The gap above a rail is where that rail's word goes; measured
		# over twins alone it was big enough for a twin's word and not
		# for anyone else's, so a return with no partner -- the traffic
		# light's, and it is the whole machine -- had no room above its
		# line and its word was pushed BELOW instead. The frame then had
		# to reserve for a word underneath, and the air above the row
		# stopped matching the air below it, which is the equilibrium
		# the Principal drew twice.
		#
		# A row is what makes an edge a candidate for a lane, so a row
		# is the filter.
		_nH_ = 0
		for _lpE_ in This.Edges()
			if StzTrim("" + _lpE_[:label]) = ""  loop  ok
			_lpF_ = StzLower("" + _lpE_[:from])
			_lpT_ = StzLower("" + _lpE_[:to])
			if _lpF_ = _lpT_  loop  ok
			if len(@aDrawXY) > 0
				_lpA_ = This._XYOf(@aDrawXY, _lpF_)
				_lpZ_ = This._XYOf(@aDrawXY, _lpT_)
				if len(_lpA_) = 2 and len(_lpZ_) = 2
					if fabs(_lpA_[2] - _lpZ_[2]) > 1.5 and
					   fabs(_lpA_[1] - _lpZ_[1]) > 1.5  loop  ok
				ok
			ok
			_lpB_ = This._LabelBlock("" + _lpE_[:label], oFont, nFsz, nBoxW)
			if _lpB_[3] > _nH_  _nH_ = _lpB_[3]  ok
		next
		if _nH_ > 0
			# the DRAWN height of a word, not its glyph box -- the same
			# quantity the frame and the placer use, so the three agree
			_nHd_ = _nH_
			if nFsz * 1.7 > _nHd_  _nHd_ = nFsz * 1.7  ok
			@nLanePitch = This._LineClearance() + _nHd_
		ok
		if This._ArrowRun() > @nLanePitch  @nLanePitch = This._ArrowRun()  ok
		return This

	def _ClusterPadBase()
		# ONE CLEARANCE, ON EVERY SIDE. Doubling it to make room for the
		# return rail paid for that rail on all four sides -- including
		# the top, where nothing runs -- and the entry gap came out twice
		# as deep as anything standing in it. The rail is paid for where
		# the rail IS, by measuring it (see the box), not by inflating
		# every margin in the picture.
		return max([ 16, This._LineClearance() + 4 ])

	def _ClusterPadMax()
		_cpMax_ = 0
		for _cpC_ in @aClusters
			_cpP_ = This._ClusterPadBase() +
				34 * This._ClusterLevelsBelow(_cpC_)
			if _cpP_ > _cpMax_  _cpMax_ = _cpP_  ok
		next
		return _cpMax_

	def _ClusterChromeAbove(nFsz)
		_ccaMax_ = 0
		for _ccaC_ in @aClusters
			_ccaP_ = This._ClusterPadBase() +
				34 * This._ClusterLevelsBelow(_ccaC_)
			_ccaT_ = _ccaP_ + nFsz * 1.9
			if _ccaT_ > _ccaMax_  _ccaMax_ = _ccaT_  ok
		next
		return _ccaMax_

	def _ClusterBox(aCluster, aXY, nBoxW, nBoxH)
		_bAny_ = 0
		_x0_ = 0  _y0_ = 0  _x1_ = 0  _y1_ = 0
		for _id_ in aCluster[:nodes]
			_a_ = This._XYOf(aXY, "" + _id_)
			if len(_a_) != 2  loop  ok
			_lx_ = _a_[1] - nBoxW / 2  _rx_ = _a_[1] + nBoxW / 2
			_ty_ = _a_[2] - nBoxH / 2  _by_ = _a_[2] + nBoxH / 2
			if NOT _bAny_
				_x0_ = _lx_  _x1_ = _rx_  _y0_ = _ty_  _y1_ = _by_
				_bAny_ = 1
			else
				if _lx_ < _x0_  _x0_ = _lx_  ok
				if _rx_ > _x1_  _x1_ = _rx_  ok
				if _ty_ < _y0_  _y0_ = _ty_  ok
				if _by_ > _y1_  _y1_ = _by_  ok
			ok
		next
		if NOT _bAny_  return []  ok
		# ...and the BASE pad scales with the render: it was a flat 16px,
		# so at :Scale = 2 an arrowhead arriving at a member sat visually
		# on the frame line -- a literal distance is a bug by
		# construction (the visual contract, I3).
		_padBase_ = This._ClusterPadBase()
		# PADDING GROWS WITH WHAT IS NESTED INSIDE. A fixed 16 was right
		# while every cluster was a leaf; once one can contain another, the
		# outer box has to clear not just the inner box but the inner
		# LABEL, which is drawn 24px above it. At a fixed pad the two
		# borders landed within a few pixels of each other and the inner
		# label was written across the outer one.
		_pad_ = _padBase_ + 34 * This._ClusterLevelsBelow(aCluster)
		# ...AND A MEMBER'S SELF-LOOP IS THE MEMBER'S INK. The frame
		# contains what its members draw, and a loop radiates OUTWARD --
		# so the rightmost member of a region had its loop, and the
		# loop's label, hanging outside the boundary that is supposed to
		# hold it. Same law as the return rails, one shape further out.
		# THE INK THIS FRAME HOLDS, MEASURED WHERE IT RUNS. A return rail
		# rides one clearance below its row and needs a clearance of air
		# under it; a self-loop radiates to the right and needs the same
		# beside it. Both are member ink, so the frame grows on THOSE
		# sides -- and nowhere else, which is what keeps the entry gap
		# honest.
		# ...AND THE DEPTH IS READ FROM THE LANE PLAN, never counted
		# here. This used to count the twin PAIRS among the members and
		# take that as the number of rails -- a good guess, and wrong
		# for a return with no partner, and wrong again for an edge that
		# steps off the row because a state stands in its way. Both
		# exist in the player: three rails where two were budgeted, and
		# the third was drawn across the frame's own bottom rule.
		_y1L_ = _y1_
		_nRowY3_ = 0
		_bRow3_ = 0
		for _cm3_ in aCluster[:nodes]
			_at3_ = This._XYOf(aXY, "" + _cm3_)
			if len(_at3_) != 2  loop  ok
			if NOT _bRow3_ or _at3_[2] > _nRowY3_
				_nRowY3_ = _at3_[2]
				_bRow3_ = 1
			ok
		next
		if _bRow3_
			_nLn3_ = This._MaxLaneIn(aXY, aCluster[:nodes], _nRowY3_)
			if _nLn3_ > 0
				# ...AND NOTHING IS RESERVED BELOW IT. A rail writes its
				# word ABOVE its own line -- the gap above every rail is
				# sized to hold one (see _SetLanePitch) -- so the deepest
				# rail is the deepest ink in the frame and one clearance
				# under it is the whole floor.
				#
				# Reserving for a word underneath was the second half of
				# the same defect: the pitch was too small for the word
				# to go above, the word went below, the frame paid for it
				# there, and the air under the frame's last rail came out
				# larger than the air over its first row. Sizing the gap
				# correctly removes the need for the reservation, which
				# is why both changes are one change.
				# ...and the rail IS the edge of the ink, with nothing
				# added. A clearance here plus the frame's own padding
				# is the same distance paid twice -- 52px under the last
				# rail against 28px over the first row, which is the
				# equilibrium marked on the player. The padding is what
				# keeps ink off the rule, and it keeps this ink off it
				# exactly as it keeps a cell's.
				_rail3_ = _nRowY3_ + This._LaneOffset(_nLn3_, nBoxH)
				if _rail3_ > _y1L_  _y1L_ = _rail3_  ok
			ok
		ok

		_x1L_ = _x1_
		for _clE_ in This.Edges()
			if StzLower("" + _clE_[:from]) != StzLower("" + _clE_[:to])  loop  ok
			_bMem_ = 0
			for _cm2_ in aCluster[:nodes]
				if StzLower("" + _cm2_) = StzLower("" + _clE_[:from])
					_bMem_ = 1
					exit
				ok
			next
			if NOT _bMem_  loop  ok
			_atL_ = This._XYOf(aXY, "" + _clE_[:from])
			if len(_atL_) != 2  loop  ok
			# ...AND ITS LABEL, which is the part that escaped: the frame
			# grew to hold the loop and stopped three pixels short of the
			# word beside it, so "lock" sat outside the region whose
			# state it belongs to.
			_reachL_ = _atL_[1] + nBoxW / 2 +
				This._SelfLoopReach(nBoxW, nBoxH) + 6
			# ...and the reserve ends where the WORD ends. A further 14px
			# of padding was being added after it, so the frame stood
			# 34px clear of "lock" on the right while it stood 28px clear
			# of "Closed" on the left -- the same distance measured two
			# ways, which is what the Principal compared. The frame's
			# padding is the air; ink is where the ink stops.
			# ...measured with the SAME call the placer uses. WidthOf is
			# the width of a run of glyphs; _LabelBlock is the width of
			# the thing that actually gets drawn, and the two differ by
			# enough (8px on "lock") to leave the frame short of the
			# word it is supposed to contain.
			_labL_ = StzTrim("" + _clE_[:label])
			if _labL_ != "" and isObject(@oLastFont)
				_lbkL_ = This._LabelBlock(_labL_, @oLastFont, @nLastFsz,
					nBoxW)
				_reachL_ += _lbkL_[2]
			ok
			if _reachL_ > _x1L_  _x1L_ = _reachL_  ok
		next
		return [ _x0_ - _pad_, _y0_ - _pad_,
			(_x1L_ - _x0_) + 2 * _pad_, (_y1L_ - _y0_) + 2 * _pad_ ]

	# How many nesting levels sit INSIDE this cluster: 0 for a leaf.
	def _ClusterLevelsBelow(aCluster)
		_mine_ = This._ClusterNodeSet(aCluster)
		_deep_ = 0
		for _o_ in @aClusters
			if StzLower("" + _o_[:id]) = StzLower("" + aCluster[:id])  loop  ok
			_os_ = This._ClusterNodeSet(_o_)
			# strictly inside: a subset that is not the whole thing
			if This._SetInside(_os_, _mine_) and NOT This._SetInside(_mine_, _os_)
				_d_ = 1 + This._ClusterLevelsBelow(_o_)
				if _d_ > _deep_  _deep_ = _d_  ok
			ok
		next
		return _deep_

	# DISPLAY, not View. In this very module `View` is already a NOUN for a
	# data projection -- stzGraphView, stzGraphQuery.ToView(), IsView() --
	# so one word carried two meanings in one namespace: "a filtered
	# projection of the graph" and "open a window on the picture".
	# Display() says only the second thing.
	#
	# View() stays as an alternative form because callers exist (the
	# diagram suite among them), and breaking working code over a naming
	# improvement is a worse trade than carrying an alias.
	def Display()

		# Generate DOT code
		_cDotCode_ = This.Dot()

		# Create stzDotCode instance and execute
		_oDotExec_ = new stzDotCode()
		_oDotExec_.SetCode(_cDotCode_)
		_oDotExec_.SetOutputFormat(@cOutputFormat)
		_oDotExec_.ExecuteAndView()

		#< @FunctionAlternativeForm

		def View()
			This.Display()

		#>

	#----------#
	#  EXPORT  #
	#----------#

	def ToHashlist()
		_aBase_ = super.ToHashlist()
		_aBase_["theme"] = @cTheme
		_aBase_["layout"] = @cLayout
		_aBase_["clusters"] = @aClusters
		_aBase_["annotations"] = @aoAnnotations
		_aBase_["templates"] = @aoTemplates
		return _aBase_

	def stzdiag()
		_oConv_ = new stzDiagramToStzDiag(This)
		return _oConv_.stzdiag()

		def ToStzDiag()
			return This.stzdiag()

		def ToStzDiagString()
			return This.stzdiag()
		
		def ToStzDiagFormat()
			return This.stzdiag()

		def StzDiagFormat()
			return This.stzdiag()

		def StzDiagString()
			return This.stzdiag()
		
		def DiagFormat()
			return This.stzdiag()

	def Dot()
		_oConv_ = new stzDiagramToDot(This)
		_cResult_ = _oConv_.Code()
		return _cResult_

		def ToDot()
			return This.Dot()

		def GraphvizDot()
			return This.Dot()

		def ToGraphvizDot()
			return This.Dot()

		def DotCode()
			return This.Dot()

		def Code()
			return This.Dot()

	def Json()
		_oConv_ = new stzDiagramToJson(This)
		return _oConv_.Code()

		def ToJson()
			return This.Json()

	def Mermaid()
		_oConv_ = new stzDiagramToMermaid(This)
		return _oConv_.Code()

		def ToMermaid()
			return This.Mermaid()

	#-----------------#
	#  WRITE TO FILE  # #TODO Shoulmd move to stzGraph level
	#-----------------#

	def WriteToFile()
		_oConv_ = new stzDiagramToStzDiag(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".stzdiag")
		return _bSuccess_

		def SaveToFile()
			return This.WritetoFile()

		def SaveFile()
			return This.WritetoFile()

		def SaveInFile()
			return This.WritetoFile()

		#--

		def WriteToStzDiagFile()
			return This.WriteToDiagFile()

		def WriteStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveToDiagFile()
			return This.WriteToDiagFile()

		def SaveToStzDiagFile()
			return This.WriteToDiagFile()

		def SaveToStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveInDiagFile()
			return This.WriteToDiagFile()

		def SaveInStzDiagFile()
			return This.WriteToDiagFile()

		def SaveInStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveDiagFile()
			return This.WriteToDiagFile()

		def SaveStzDiagFile()
			return This.WriteToDiagFile()

		def SaveStzDiag()
			return This.WriteToDiagFile()

	def WriteToFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToStzDiag(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".stzdiag")
		return _bSuccess_

		#< @FunctionAlternativeForms

		def SaveInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveToFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveInFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		#--

		def WriteToStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def WriteStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveToDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveToStzDiagFileXT(pcFolder)
			return This.WriteToDiagFile(pcFolder)

		def SaveToStzDiagXT()
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveInDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#===

		def SaveToFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveInFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		#--

		def WriteToStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def WriteStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveToDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveToStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFile(pcFolder)

		def SaveToStzDiagInFolder()
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveInDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#>
	#---

	def WriteToDotFile()
		_oConv_ = new stzDiagramToDot(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".dot")
		return _bSuccess_

		def WriteInDotFile()
			return This.WriteToDotFile()

		def SaveDotFile()
			return This.WriteToDotFile()

		def SaveInDotFile()
			return This.WriteToDotFile()

	def WriteToDotFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToDot(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".dot")
		return _bSuccess_

		#< @FunctionAlternativeForms

		def WriteInDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteToDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteToDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		#--

		def SaveToDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveInDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveToDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveToDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		#>

	#---

	def WriteToMermaidFile()
		_oConv_ = new stzDiagramToMermaid(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".mmd")
		return _bSuccess_

		def WriteInMermaidFile()
			return This.WriteToMermaidFile()

		def SaveMermaidFile()
			return This.WriteToMermaidFile()

		def SaveInMermaidFile()
			return This.WriteToMermaidFile()

	def WriteToMermaidFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToMermaid(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".mmd")
		return _bSuccess_


		#< @FunctionAlternativeForms

		def WriteInMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteToMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteToMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		#--

		def SaveToMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveInMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveToMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveToMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		#>

	#--

	def WriteToJsonFile(pcFileName)
		_oConv_ = new stzDiagramToJson(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".json")
		return _bSuccess_

		def WriteInJsonFile()
			return This.WriteToJsonFile()

		def SaveJsonFile()
			return This.WriteToJsonFile()

		def SaveInJsonFile()
			return This.WriteToJsonFile()

	def WriteToJsonFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToJson(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".json")
		return _bSuccess_


		#< @FunctionAlternativeForms

		def WriteInJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteToJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteToJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		#--

		def SaveToJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveInJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveToJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveToJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		#>

	#-----------------------------------------#
	# Get diagram overview with rules context #
	#-----------------------------------------#

	#NOTE // There also is an Explain() at the parent stzGraph level

	def Explain()
		_aExplanation_ = [
			:diagram = @cId,
			:structure = "",
			:rules = "",
			:effects = ""
		]
		
		_nNodes_ = This.NodeCount()
		_nEdges_ = This.EdgeCount()
		_aExplanation_[:structure] = "Diagram '" + @cId + "' contains " + _nNodes_ + " nodes and " + _nEdges_ + " edges."
		
		_nRules_ = len(@aoVisualRules)
		if _nRules_ = 0
			_aExplanation_[:rules] = "No visual rules defined."
		else
			_cRules_ = "Applied " + _nRules_ + " visual rule(s): "
			for i = 1 to _nRules_
				_cRules_ += @aoVisualRules[i].@cRuleId
				if i < _nRules_
					_cRules_ += ", "
				ok
			end
			_aExplanation_[:rules] = _cRules_
		ok
		
		_nNodesAffected_ = len(@aNodeRulesEffects)
		_nEdgesAffected_ = len(@aEdgesRulesEffects)
		
		if _nNodesAffected_ = 0 and _nEdgesAffected_ = 0
			_aExplanation_[:effects] = "No rules matched any elements."
		else
			_cEffects_ = ""
			if _nNodesAffected_ > 0
				_cEffects_ += ""+ _nNodesAffected_ + " node(s) enhanced"
			ok
			if _nEdgesAffected_ > 0
				if _cEffects_ != ""
					_cEffects_ += ", "
				ok
				_cEffects_ += ""+ _nEdgesAffected_ + " edge(s) enhanced"
			ok
			_aExplanation_[:effects] = _cEffects_ + "."
		ok
		
		return _aExplanation_

	#----------------------------------#
	#  IMPORT WITH SUBDIAGRAM SUPPORT  #
	#----------------------------------#

	def ImportDiag(cDiagString)
		# Parse first node of imported diagram
		_cFirstNodeId_ = This.ExtractFirstNodeId(cDiagString)
		
		if _cFirstNodeId_ = ""
			StzRaise("Cannot parse imported diagram - no nodes found")
		ok
		
		# Check if current diagram has nodes
		if This.NodeCount() > 0
			# Check if first node exists in current diagram
			if This.HasNode(_cFirstNodeId_)
				# Import as subdiagram under this node
				This.ImportAsSubdiagram(cDiagString, _cFirstNodeId_)
			else
				StzRaise("Import failed: First node '" + _cFirstNodeId_ + "' not found in current diagram. " +
					"Either add node '" + _cFirstNodeId_ + "', or clear the diagram with RemoveAllNodes()")
			ok
		else
			# Empty diagram - do normal import
			This.ParseAndImport(cDiagString)
		ok

	def ExtractFirstNodeId(cDiagString)
		_acLines_ = @split(cDiagString, char(10))
		_nLen_ = len(_acLines_)
		_bInNodesSection_ = 0

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = "nodes"
				_bInNodesSection_ = 1
				loop
			ok
			
			if _bInNodesSection_ and _cLine_ != "" and
			   NOT StzFindFirst("label:", _cLine_) and
			   NOT StzFindFirst("type:", _cLine_) and
			   NOT StzFindFirst("color:", _cLine_)
				return _cLine_
			ok
			
			if _bInNodesSection_ and (_cLine_ = "edges" or _cLine_ = "clusters")
				exit
			ok
		end
	
	def ImportAsSubdiagram(cDiagString, cParentNodeId)
		_oTemp_ = new stzDiagram("temp")
		_oTemp_.ParseAndImport(cDiagString)
		
		_acNodes_ = _oTemp_.Nodes()
		_nLenNodes_ = len(_acNodes_)

		_acEdges_ = _oTemp_.Edges()
		_nLenEdges_ = len(_acEdges_)
		
		# Add all nodes EXCEPT the parent (which already exists)

		for i = 1 to _nLenNodes_
			if _acNodes_[i]["id"] != cParentNodeId
				This.AddNodeXTT(_acNodes_[i]["id"], _acNodes_[i]["label"], [
					:type = _acNodes_[i]["properties"]["type"], 
					:color = _acNodes_[i]["properties"]["color"]
				])
			ok
		end

		# Add all edges
		for i = 1 to _nLenEdges_
			_cFrom_ = _acEdges_[i]["from"]
			_cTo_ = _acEdges_[i]["to"]
			
			# All edges are added normally since parent node exists
			This.Connect(_cFrom_, _cTo_)
		end

	def ParseAndImport(cDiagString)
		_acLines_ = @split(cDiagString, char(10))
		_cCurrentSection_ = ""
		_cCurrentNode_ = ""
		_cLabel_ = ""
		_cType_ = ""
		_cColor_ = ""
		_aEdgesToAdd_ = []  # Store edges for later

		_nLen_ = len(_acLines_)
		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = "" or
			   StzLeft(_cLine_, 1) = "#"
				loop
			ok
			
			if StzFindFirst("diagram ", _cLine_)
				_cTitle_ = trim(StzMid(_cLine_, 10, stzlen(_cLine_) - 10))
				@cId = _cTitle_

			but _cLine_ = "properties"
				_cCurrentSection_ = "properties"

			but _cLine_ = "nodes"
				_cCurrentSection_ = "nodes"

			but _cLine_ = "edges"
				_cCurrentSection_ = "edges"

			but _cCurrentSection_ = "properties" and StzFindFirst(":", _cLine_)
				_aParts_ = @split(_cLine_, ":")
				_cKey_ = trim(_aParts_[1])
				_cValue_ = trim(_aParts_[2])

				if _cKey_ = "theme"
					This.SetTheme(_cValue_)
				but _cKey_ = "layout"
					This.SetLayout(_cValue_)
				ok

			but _cCurrentSection_ = "nodes"
				if NOT StzFindFirst("label:", _cLine_) and NOT StzFindFirst("type:", _cLine_) and NOT StzFindFirst("color:", _cLine_)
					if _cCurrentNode_ != "" and _cLabel_ != ""
						if _cType_ = "" _cType_ = $cDefaultNodeType ok
						if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
						This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
					ok
					_cCurrentNode_ = _cLine_
					_cLabel_ = ""
					_cType_ = ""
					_cColor_ = ""

				but StzFindFirst("label:", _cLine_)
					_cLabel_ = StzMid(_cLine_, 9, stzlen(_cLine_) - 9)

				but StzFindFirst("type:", _cLine_)
					_cType_ = trim(StzMid(_cLine_, 7, stzlen(_cLine_) - 6))

				but StzFindFirst("color:", _cLine_)
					_cColor_ = trim(StzMid(_cLine_, 8, stzlen(_cLine_) - 7))
				ok

			but _cCurrentSection_ = "edges"

				# An edge is TWO lines: the arrow, then its label beneath it --
				#     a -> b
				#         label: "next"
				# This branch only ever matched the arrow line, so the label
				# was read by nobody and every imported edge came back
				# UNLABELLED. The writer has always emitted it.

				if StzFindFirst("->", _cLine_)
					_aEdgeParts_ = @split(_cLine_, "->")
					_cFrom_ = trim(_aEdgeParts_[1])
					_cTo_ = trim(_aEdgeParts_[2])
					_aEdgesToAdd_ + [_cFrom_, _cTo_, ""]  # Store for later

				but StzFindFirst("label:", _cLine_) and len(_aEdgesToAdd_) > 0
					# ... and it belongs to the arrow just read. Same
					# arithmetic the node labels use above.
					_aEdgesToAdd_[len(_aEdgesToAdd_)][3] =
						StzMid(_cLine_, 9, stzlen(_cLine_) - 9)
				ok
			ok
		end

		# Add last node
		if _cCurrentNode_ != "" and _cLabel_ != ""
			if _cType_ = "" _cType_ = $cDefaultNodeType ok
			if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
			This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
		ok

		# Now add all edges -- with the label the file carried, when it had one
		_nLen_ = len(_aEdgesToAdd_)
		for i = 1 to _nLen_
			if _aEdgesToAdd_[i][3] != ""
				This.AddEdgeXT(_aEdgesToAdd_[i][1], _aEdgesToAdd_[i][2], _aEdgesToAdd_[i][3])
			else
				This.Connect(_aEdgesToAdd_[i][1], _aEdgesToAdd_[i][2])
			ok
		end
	
	#--------------------#
	#  FOCUS MANAGEMENT  #
	#--------------------#

	def ApplyFocusTo(acNodeIds)
	    # Reset all first
	    This.ResetAllNodeColors()
	    
	    # Apply focus to specified nodes
	    _nLen_ = len(acNodeIds)
	    for i = 1 to _nLen_
	        This.SetNodeProperty(acNodeIds[i], "color", @cFocusColor)
	    end
	
	def ResetAllNodeColors()
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    for i = 1 to _nLen_
	        _cNodeId_ = _aNodes_[i]["id"]
	        This.SetNodeProperty(_cNodeId_, "color", @cNodeColor)
	    end

	#-------------------------#
	#  STYLE FILE MANAGEMENT  #
	#-------------------------#

	def LoadStyle(pSource)
		if isString(pSource)
			if StzRight(pSource, 8) = ".stzstyl"
				_oParser_ = new stzStylParser()
				_aStyle_ = _oParser_.ParseFile(pSource)
			else
				_oParser_ = new stzStylParser()
				_aStyle_ = _oParser_.Parse(pSource)
			ok
			
			This._ApplyStyle(_aStyle_)
			@aLoadedStyles + _aStyle_[:name]
		ok
	
	def _ApplyStyle(_aStyle_)
		# Apply theme
		if HasKey(_aStyle_, :theme) and _aStyle_[:theme] != ""
			This.SetTheme(_aStyle_[:theme])
		ok
		
		# Apply layout
		if HasKey(_aStyle_, :layout) and _aStyle_[:layout] != ""
			This.SetLayout(_aStyle_[:layout])
		ok
		
		# stzStylParser builds each section as a list of PAIRS --
		#     _aStyle_[section] + [ key, value ]
		# and Ring's + appends that pair as ONE element. Every section here
		# walked it as a flat [k,v,k,v] run and fell off the end (R2 on the
		# last pair), so LoadStyle() died on any .stzstyl file -- including the
		# one ExportToStyl() had just written. Same fault, same era, as the
		# .stzflow parser's _AddStep/_AddActor.
		# Apply colors
		if HasKey(_aStyle_, :colors) and len(_aStyle_[:colors]) > 0
			_nLen_ = len(_aStyle_[:colors])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:colors][i][1]
				_cValue_ = _aStyle_[:colors][i][2]
				
				# Update color palette
				if HasKey(@aPalette[@cTheme], _cKey_)
					@aPalette[@cTheme][_cKey_] = _cValue_
				ok
			end
		ok
		
		# Apply fonts
		if HasKey(_aStyle_, :fonts) and len(_aStyle_[:fonts]) > 0
			_nLen_ = len(_aStyle_[:fonts])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:fonts][i][1]
				pValue = _aStyle_[:fonts][i][2]
				
				if _cKey_ = "default"
					This.SetFont(pValue)
				but _cKey_ = "size"
					This.SetFontSize(pValue)
				ok
			end
		ok
		
		# Apply edge settings
		if HasKey(_aStyle_, :edges) and len(_aStyle_[:edges]) > 0
			_nLen_ = len(_aStyle_[:edges])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:edges][i][1]
				pValue = _aStyle_[:edges][i][2]
				
				if _cKey_ = "style"
					This.SetEdgeStyle(pValue)
				but _cKey_ = "color"
					This.SetEdgeColor(pValue)
				but _cKey_ = "spline"
					This.SetSplines(pValue)
				but _cKey_ = "penwidth"
					This.SetEdgePenWidth(pValue)
				ok
			end
		ok
		
		# Apply node settings
		if HasKey(_aStyle_, :nodes) and len(_aStyle_[:nodes]) > 0
			_nLen_ = len(_aStyle_[:nodes])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:nodes][i][1]
				pValue = _aStyle_[:nodes][i][2]
				
				if _cKey_ = "penwidth"
					This.SetNodePenWidth(pValue)
				but _cKey_ = "penstyle"
					This.SetNodePenStyle(pValue)
				but _cKey_ = "color"
					This.SetNodeColor(pValue)
				but _cKey_ = "strokecolor"
					This.SetStrokeColor(pValue)
				ok
			end
		ok
		
		# Apply focus settings
		if HasKey(_aStyle_, :focus) and len(_aStyle_[:focus]) > 0
			_nLen_ = len(_aStyle_[:focus])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:focus][i][1]
				pValue = _aStyle_[:focus][i][2]
				
				if _cKey_ = "color"
					This.SetFocusColor(pValue)
				but _cKey_ = "penwidth"
					@nFocusPenWidth = pValue
				ok
			end
		ok
	
	def LoadedStyles()
		return @aLoadedStyles
	
	def ExportToStyl()
		_cStyl_ = 'style "' + @cId + '_style"' + char(10)
		_cStyl_ += '    theme: ' + @cTheme + char(10)
		_cStyl_ += '    layout: ' + @cLayout + char(10) + char(10)
		
		_cStyl_ += 'colors' + char(10)
		if HasKey(@aPalette, @cTheme)
			_acKeys_ = keys(@aPalette[@cTheme])
			_nAcKeys1Len_ = len(_acKeys_)
			for _iLoopAcKeys1_ = 1 to _nAcKeys1Len_
				_cKey_ = _acKeys_[_iLoopAcKeys1_]
				_cStyl_ += '    ' + _cKey_ + ': ' + @aPalette[@cTheme][_cKey_] + char(10)
			end
		ok
		_cStyl_ += char(10)
		
		_cStyl_ += 'fonts' + char(10)
		_cStyl_ += '    default: ' + @cFont + char(10)
		_cStyl_ += '    size: ' + @nFontSize + char(10) + char(10)
		
		_cStyl_ += 'edges' + char(10)
		_cStyl_ += '    style: ' + @cEdgeStyle + char(10)
		_cStyl_ += '    color: ' + @cEdgeColor + char(10)
		_cStyl_ += '    spline: ' + @cSplineType + char(10)
		_cStyl_ += '    penwidth: ' + @nEdgePenWidth + char(10)
		# the nodes block below has carried its penstyle all along; the edges
		# block did not, so a stylesheet could not round-trip one
		_cStyl_ += '    penstyle: ' + @cEdgePenStyle + char(10) + char(10)
		
		_cStyl_ += 'nodes' + char(10)
		_cStyl_ += '    penwidth: ' + @nNodePenWidth + char(10)
		_cStyl_ += '    penstyle: ' + @cNodePenStyle + char(10)
		_cStyl_ += '    color: ' + @cNodeColor + char(10)
		if @cNodeStrokeColor != ""
			_cStyl_ += '    strokecolor: ' + @cNodeStrokeColor + char(10)
		ok
		_cStyl_ += char(10)
		
		_cStyl_ += 'focus' + char(10)
		_cStyl_ += '    color: ' + @cFocusColor + char(10)
		
		return _cStyl_
	
	def WriteToStylFile(pcFilename)
		if NOT StzRight(pcFileName, 8) = ".stzstyl"
			pcFileName += ".stzstyl"
		ok
		write(pcFilename, This.ExportToStyl())

		def WriteStyl(pcFileName)
			This.WriteToStylFile(pcFilename)

#==========================================#
#  stzDiagramAnnotator - properties OVERLAY  #
#==========================================#

class stzDiagramAnnotator from stzObject

	@cType = ""
	@aNodeData = []

	def init(pcType)
		@cType = pcType

	def Type()
		return @cType

	def Annotate(pNodeId, _aData_)
		if CheckParams()
			if isList(_aData_) and IsWithNamedParamList(_aData_)
				_aData_ = _aData_[2]
			ok
		ok

		@aNodeData[pNodeId] = _aData_

	def NodeData(pNodeId)
		if HasKey(@aNodeData, pNodeId)
			return @aNodeData[pNodeId]
		ok

	def NodesData()
		return @aNodeData

	def ToHashlist()
		return [
			:type = @cType,
			:nodeData = @aNodeData
		]


#=======================================#
#  stzDiagramToStzDiag - NATIVE FORMAT  #
#=======================================#

class stzDiagramToStzDiag from stzObject

	@oDiagram
	@cStzDiagCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_cOutput_ = ""

		# Generating diagram attributes

		_cOutput_ += 'diagram "' +
			   @oDiagram.Id() + '"' + char(10) + char(10)

		_cOutput_ += "properties" + char(10)
		_cOutput_ += "    theme: " + Lower(@oDiagram.@cTheme) + char(10)
		_cOutput_ += "    layout: " + Lower(@oDiagram.@cLayout) + char(10) + char(10)

		# Generating the diagram title

		if @oDiagram.Title() != "" or trim(@oDiagram.Subtitle()) != ""
		    _cTitle_ = @oDiagram.Title()
		    _cSubtitle_ = @oDiagram.Subtitle()
		    if trim(_cSubtitle_) != ""
			_cTitle_ += " : " + _cSubtitle_
		    ok

		    _cOutput_ += '    labelloc="t";' + char(10)

		    _cOutput_ += '    label="' + _cTitle_
		    _cOutput_ += '";'
		    _cOutput_ += '    fontsize=16;'
		ok

		# Generating nodes

		_cOutput_ += "nodes" + char(10)
		_aNodes_ = @oDiagram.Nodes()
		_nLen_ = len(_aNodes_)

		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_cOutput_ += "    " + _aNode_["id"] + char(10)
			_cOutput_ += "        label: " + This.EscapeString(_aNode_["label"]) + char(10)

			if _aNode_["properties"]["type"] != ""
				_cOutput_ += "        type: " + Lower(_aNode_["properties"]["type"]) + char(10)
			ok

			if _aNode_["properties"]["color"] != ""
				_cOutput_ += "        color: " + _aNode_["properties"]["color"] + char(10)
			ok

			_cOutput_ += char(10)
		end

		# Generating edges

		_aEdges_ = @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		if _nLen_ > 0
			_cOutput_ += "edges" + char(10)
			for i = 1 to _nLen_
				_aEdge_ = _aEdges_[i]
				_cOutput_ += "    " + _aEdge_["from"] + " -> " + _aEdge_["to"] + char(10)

				_cLabel_ = _aEdge_["label"]
				if _cLabel_ != ""
					_cOutput_ += "        label: " + This.EscapeString(_cLabel_) + char(10)
				ok

				_cOutput_ += char(10)
			end

		ok

		# Generating clusters

		_aClusters_ = @oDiagram.Clusters()
		_nLen_ = len(_aClusters_)
		if _nLen_ > 0
			_cOutput_ += "clusters" + char(10)

			for i = 1 to _nLen_
				_aCluster_ = _aClusters_[i]
				_cOutput_ += "    " + _aCluster_["id"] + char(10)
				_cOutput_ += "        label: " + This.EscapeString(_aCluster_["label"]) + char(10)
				_cNodeList_ = This.NodeListToString(_aCluster_["nodes"])
				_cOutput_ += "        nodes: [" + _cNodeList_ + "]" + char(10)
				_cOutput_ += "        color: " + _aCluster_["color"] + char(10)
				_cOutput_ += char(10)
			end
		ok

		# Generating annotations

		_aAnnotations_ = @oDiagram.AnnotationsQ()
		_nLen_ = len(_aAnnotations_)

		if _nLen_ > 0
			_cOutput_ += "annotations" + char(10)
			for i = 1 to _nLen_
				_aAnnot_ = _aAnnotations_[i]
				_cOutput_ += "    " + Lower(_aAnnot_.Type()) + char(10)

				_aAnnotData_ = _aAnnot_.NodesData()

				_acKeys_ = Keys(_aAnnotData_)
				_nLenK_ = len(_acKeys_)

				for j = 1 to _nLenK_
					_cNodeId_ = _acKeys_[j] 
					_cData_ = _aAnnotData_[_cNodeId_]
					_cOutput_ += "        " + String(_cNodeId_) + ": "
					_cOutput_ += This.DataToString(_cData_) + char(10)
				end
				_cOutput_ += char(10)
			end
		ok

		# Setting the DOT code

		@cStzDiagCode = _cOutput_

	def stzdiag()
		return @cStzDiagCode

		def stzdiagCode()
			return @cStzDiagCode

		def Content()
			return @cStzDiagCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.stzdiag())
		fclose(_oFile_)
		return 1

	def EscapeString(pStr)
		return '"' +
			Replace(pStr, '"', '\"') + '"'

	def NodeListToString(_aNodes_)
		_cResult_ = ""
		_nNodes1Len_ = len(_aNodes_)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			_cNode_ = _aNodes_[_iLoopNodes1_]
			_cResult_ += _cNode_ + ", "
		end
		if _cResult_ != ""
			_cResult_ = Left(_cResult_, stzlen(_cResult_) - 2)
		ok
		return _cResult_

	def DataToString(_aData_)
		if NOT @IsHashList(_aData_)
			return "null"
		ok

		_cResult_ = "{"
		_aKeysaData1_ = Keys(_aData_)
		_nKeysaData1Len_ = len(_aKeysaData1_)
		for _iLoopKeysaData1_ = 1 to _nKeysaData1Len_
			_cKey_ = _aKeysaData1_[_iLoopKeysaData1_]
			_cValue_ = _aData_[_cKey_]
			if isString(_cValue_)
				_cResult_ += _cKey_ + ": " + This.EscapeString(_cValue_) + ", "
			else
				_cResult_ += _cKey_ + ": " + String(_cValue_) + ", "
			ok
		end
		if _cResult_ != "{"
			_cResult_ = Left(_cResult_, stzlen(_cResult_) - 2)
		ok
		_cResult_ += "}"
		return _cResult_


#==================================#
#  stzDiagramToDot - GRAPHVIZ DOT  #
#==================================#

class stzDiagramToDot from stzObject

	@oDiagram
	@cDotCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and

			find([ "stzdiagram", "stzorgchart", "stzworkflow" ],
				ring_classname(poDiagram)) )

			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()


	def _Generate()
	
		_cOutput_ = ""
		
		# Apply visual rules if any
		if len(@oDiagram.@aoVisualRules) > 0
			@oDiagram.ApplyVisualRules()
		ok
		
		# Get theme
		_cTheme_ = This._GetTheme()
		
		# Start digraph
		_cOutput_ += 'digraph "' + @oDiagram.Id() + '" {' + char(10)
		
		# Graph attributes
		_cOutput_ += This._GenerateGraphAttributes(_cTheme_)
		
		# Add title/subtitle if present -- EITHER of them is enough, a subtitle on
		# its own used to be dropped here without a word
		if @oDiagram.Title() != "" or @oDiagram.Subtitle() != ""
		    _cOutput_ += '    labelloc="t";' + char(10)
		    _cTitle_ = char(10) + @oDiagram.Title()
		    if @oDiagram.Subtitle() != ""
		        _cTitle_ += char(10) + @oDiagram.Subtitle() + char(10)
		    ok
		    _cTitle_ += char(10) + char(10)
		    _cOutput_ += '    label="' + _cTitle_ + '";' + char(10)
		    _cOutput_ += '    fontsize=16;' + char(10) + char(10)
		ok
	
		# Node attributes  
		_cOutput_ += This._GenerateNodeAttributes(_cTheme_)
		
		# Edge attributes
		_cOutput_ += This._GenerateEdgeAttributes(_cTheme_)
		
		_cOutput_ += char(10)
		
		# Generate nodes
		_cOutput_ += This._GenerateNodes(_cTheme_)
		_cOutput_ += char(10)
		
		# Generate clusters (subgraphs)
		if len(@oDiagram.Clusters()) > 0
			_cOutput_ += char(10)
			
			_aDiagramClusters1_ = @oDiagram.Clusters()
			_nDiagramClusters1Len_ = len(_aDiagramClusters1_)
			for _iLoopDiagramClusters1_ = 1 to _nDiagramClusters1Len_
				_aCluster_ = _aDiagramClusters1_[_iLoopDiagramClusters1_]
				_cClusterId_ = "cluster_" + _aCluster_["id"]
				_cLabel_ = _aCluster_["label"]
				_cColor_ = _aCluster_["color"]
				
				_cOutput_ += '    subgraph ' + _cClusterId_ + ' {' + char(10)
				_cOutput_ += '        label="' + _cLabel_ + '";' + char(10)
				_cOutput_ += '        style=filled;' + char(10)
				_cOutput_ += '        color="' + _cColor_ + '";' + char(10)
				_cOutput_ += '        fillcolor="' + _cColor_ + '20";' + char(10)  # 20 = transparency
				
				# List nodes in cluster
				_aClusternodes1_ = _aCluster_["nodes"]
				_nClusternodes1Len_ = len(_aClusternodes1_)
				for _iLoopClusternodes1_ = 1 to _nClusternodes1Len_
					_cNodeId_ = _aClusternodes1_[_iLoopClusternodes1_]
					_cOutput_ += '        ' + This._SanitizeNodeId(_cNodeId_) + ';' + char(10)
				end
				
				_cOutput_ += '    }' + char(10)
			end
		ok
	
		# Generate edges
		_cOutput_ += This._GenerateEdges(_cTheme_)
		
		_cOutput_ += char(10) + "}"
		
		@cDotCode = _cOutput_
	
	def _GetTheme()
		_cTheme_ = StzLower(@oDiagram.@cTheme)
		if _cTheme_ = ""
			_cTheme_ = $cDefaultColorTheme
		ok
		return _cTheme_

	def _GenerateGraphAttributes(_cTheme_)
	    _cRankDir_ = This._GetRankDir()
	    _cFont_ = This._GetFont()
	    _nFontSize_ = This._GetFontSize()
	    
	    _cResult_ = '    graph [rankdir=' + _cRankDir_ + 
	               ', bgcolor=white' +
	               ', fontname="' + _cFont_ + '"' +
	               ', fontsize=' + _nFontSize_ +
	               ', splines=' + @oDiagram.@cSplineType +
	               ', nodesep=' + @oDiagram.@nNodeSep +
	               ', ranksep=' + @oDiagram.@nRankSep +
	               ', ordering=out' +
	               ', tooltip=" "'  #TODO // Has no effect
	    
	    if @oDiagram.@bConcentrate
	        _cResult_ += ', concentrate=true'
	    ok
	    
	    _cResult_ += ']' + char(10)
	    return _cResult_

	def _GenerateNodeAttributes(_cTheme_)
		_cFont_ = This._GetFont()
		_nFontSize_ = This._GetFontSize()
		
		_cResult_ = '    node [fontname="' + _cFont_ + '", fontsize=' + _nFontSize_ + ']' + char(10)
	
		return _cResult_

	def _GenerateEdgeAttributes(_cTheme_)
		_cFont_ = This._GetFont()
		_nFontSize_ = This._GetFontSize()
		_cEdgeColor_ = This._GetEdgeColor(_cTheme_)
		_cEdgeStyle_ = This._GetEdgeStyle()

		_cResult_ = '    edge [fontname="' + _cFont_ + '", fontsize=' + _nFontSize_ + 
		          ', color="' + _cEdgeColor_ + '", style=' + _cEdgeStyle_ +
		          ', penwidth=' + @oDiagram.@nEdgePenWidth + 
		          ', arrowhead=' + @oDiagram.@cArrowHead + 
		          ', arrowtail=' + @oDiagram.@cArrowTail + ']' + char(10)

		return _cResult_
	
	def _GetRankDir()
		_cLayout_ = StzLower(@oDiagram.@cLayout)
		
		# Handle empty/null layout
		if _cLayout_ = ""
			_cLayout_ = $cDefaultLayout
		ok
		
		_cRankDir_ = "TB"

		if _cLayout_ = "topdown" or StzFindFirst(_cLayout_, $acLayouts[:TopDown])
			_cRankDir_ = "TB"
	
		but _cLayout_ = "bottomup" or StzFindFirst(_cLayout_, $acLayouts[:BottomUp])
			_cRankDir_ = "BT"
	
		but _cLayout_ = "leftright" or StzFindFirst(_cLayout_, $acLayouts[:LeftRight])
			_cRankDir_ = "LR"
	
		but _cLayout_ = "rightleft" or StzFindFirst(_cLayout_, $acLayouts[:RightLeft])
			_cRankDir_ = "RL"
		ok
	
		return _cRankDir_
	
	def _GetFont()
		_cFont_ = @oDiagram.@cFont
		if _cFont_ = ""
			_cFont_ = $cDefaultFont
		ok

		return _cFont_
	
	def _GetFontSize()
		_nFontSize_ = @oDiagram.@nFontSize
		if _nFontSize_ = 0 or _nFontSize_ = ""
			_nFontSize_ = $cDefaultFontSize
		ok

		return _nFontSize_
	
	def _GetEdgeColor(_cTheme_)
		# Use resolved color from diagram, default to black
		_cEdgeColor_ = @oDiagram.@cEdgeColor
		
		if _cEdgeColor_ = ""
			_cEdgeColor_ = ResolveColor("black")  # Changed from using @cDefaultEdgeColor
		else
			_cEdgeColor_ = ResolveColor(_cEdgeColor_)
		ok
		
		# Theme-specific edge colors
		if _cTheme_ = "print"
			_cEdgeColor_ = ResolveColor(:black)
		but _cTheme_ = "gray" or _cTheme_ = "lightgray" or _cTheme_ = "darkgray"
			_cEdgeColor_ = ResolveColor(:black)
		but _cTheme_ = "dark"
			_cEdgeColor_ = ResolveColor("gray-")
		ok
		
		return _cEdgeColor_
	
	# THE EDGE STYLE COMES FROM TWO SETTERS, and both have to reach the DOT.
	#
	# SetEdgePenStyle takes the Graphviz vocabulary -- solid, dashed, dotted, bold,
	# invis -- and is the exact counterpart of SetNodePenStyle, which does reach it
	# (there is no SetNodeStyle; the node side has only the pen style). SetEdgeStyle
	# takes SEMANTIC values instead, where :Conditional resolves to dashed, so the
	# two are different layers over one attribute rather than aliases.
	#
	# Only the semantic one was ever read here. SetEdgePenStyle set an attribute
	# that nothing emitted: it drew nothing and raised nothing, and its accessor
	# went on reporting the value back, which is what kept it looking alive.
	#
	# The pen style is the base; a semantic style set on top of it wins.
	#
	# "Set on top of it" has to mean CHANGED FROM ITS DEFAULT. @cEdgeStyle is born
	# holding $cDefaultEdgeStyle, so a test for "not empty" is true on every diagram
	# ever made -- which is precisely what shadowed the pen style, and why wiring it
	# in underneath was not enough on its own.
	def _GetEdgeStyle()
		_cEdgeStyle_ = "solid"

		if @oDiagram.@cEdgePenStyle != "" and @oDiagram.@cEdgePenStyle != ""
			_cEdgeStyle_ = @oDiagram.@cEdgePenStyle
		ok

		_bSemanticSet_ = @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != "" and
		                 StzLower("" + @oDiagram.@cEdgeStyle) != StzLower("" + $cDefaultEdgeStyle)

		if _bSemanticSet_ or @oDiagram.@cEdgePenStyle = "" or @oDiagram.@cEdgePenStyle = "solid"
			if @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != ""
				_cEdgeStyle_ = StzResolveEdgeStyle(@oDiagram.@cEdgeStyle)
			ok
		ok

		return _cEdgeStyle_
	
	def _GenerateNodes(_cTheme_)
		_cOutput_ = ""
		
		_aDiagramNodes1_ = @oDiagram.Nodes()
		_nDiagramNodes1Len_ = len(_aDiagramNodes1_)
		for _iLoopDiagramNodes1_ = 1 to _nDiagramNodes1Len_
			_aNode_ = _aDiagramNodes1_[_iLoopDiagramNodes1_]
			_cOutput_ += This._GenerateNode(_aNode_, _cTheme_)
		end
		
		return _cOutput_
	
	def _GenerateNode(_aNode_, _cTheme_)
	    _cNodeId_ = This._SanitizeNodeId(_aNode_["id"])
	    
	    # Handle helper nodes
	    if HasKey(_aNode_, "properties") and HasKey(_aNode_["properties"], "ishelper") and _aNode_["properties"]["ishelper"] = 1
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + char(10)
	        return _cOutput_
	    ok
	    
	    if StzLeft(_cNodeId_, 8) = "_helper_"
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + char(10)
	        return _cOutput_
	    ok
	    
	    _cLabel_ = _aNode_["label"]
	    
	    # Get visual rule effects FIRST
	    _aAppliedRules_ = []
	    if HasKey(@oDiagram.@aNodeRulesEffects, _aNode_["id"])
	        _aAppliedRules_ = @oDiagram.@aNodeRulesEffects[_aNode_["id"]]
	    ok
	    
	    # Apply effects to override defaults
	    _cShape_ = This._GetNodeShape(_aNode_, _aAppliedRules_)
	    _cStyle_ = This._GetNodeStyle(_aNode_, _aAppliedRules_)
	    _cFillColor_ = This._GetNodeFillColor(_aNode_, _aAppliedRules_, _cTheme_)
	    
	    # Check if visual rules set penwidth
	    _nPenWidth_ = @oDiagram.@nNodePenWidth
	    if HasKey(_aAppliedRules_, "penwidth")
	        _nPenWidth_ = _aAppliedRules_["penwidth"]
	    ok
	    
	    # Ensure filled is always present (visual rules already merged in _GetNodeStyle)
	    if NOT StzFindFirst("filled", _cStyle_)
	        if _cStyle_ = ""
	            _cStyle_ = "filled"
	        else
	            _cStyle_ += ",filled"
	        ok
	    ok
	    
	    _cOutput_ = '    ' + _cNodeId_ + ' [label="' + _cLabel_ + '"'
	    _cOutput_ += ', shape=' + _cShape_
	    _cOutput_ += ', style="' + _cStyle_ + '"'
	    _cOutput_ += ', fillcolor="' + _cFillColor_ + '"'
	    _cOutput_ += ', penwidth=' + _nPenWidth_
	    
	    # Add contrasting font color
	    _cFontColor_ = @oDiagram.ResolveFontColor(_cFillColor_)
	    _cOutput_ += ', fontcolor="' + _cFontColor_ + '"'
	    
	    # ORG CHART POSITION NODES
	    if HasKey(_aNode_["properties"], "positiontype") and 
	        _aNode_["properties"]["positiontype"] = "position"
	        
	        _cFillColor_ = ResolveColor(_aNode_["properties"]["color"])
	        _cOutput_ += ', fillcolor="' + _cFillColor_ + '"'
	        _cOutput_ += ', fontcolor="' + @oDiagram.ResolveFontColor(_cFillColor_) + '"'
	        
	        # Use diagram's stroke color setting
	        _cStrokeColor_ = @oDiagram.@cNodeStrokeColor
	        if _cStrokeColor_ = '' or _cStrokeColor_ = "invisible"
	            _cStrokeColor_ = _cFillColor_
	        ok
	        _cOutput_ += ', color="' + ResolveColor(_cStrokeColor_) + '"'
	    ok
	    
	    # Generate tooltip
	    _cTooltip_ = This._GenerateTooltip(_aNode_)
	    if _cTooltip_ != ""
	        _cOutput_ += ', tooltip="' + This._EscapeTooltip(_cTooltip_) + '"'
	    else
	        # Explicitly disable default tooltip
	        _cOutput_ += ', tooltip=" "'
	    ok
	    
	    _cOutput_ += ']' + char(10)
	    
	    return _cOutput_

	def _SanitizeNodeId(_cNodeId_)
		if StzLeft(_cNodeId_, 1) = "@"
			return StzMid(_cNodeId_, 2, stzlen(_cNodeId_) - 1)
		ok

		return _cNodeId_
	
	def _GetNodeShape(_aNode_, _aEnhancements_)
		# Check enhancements FIRST (from visual rules)
		if HasKey(_aEnhancements_, "shape")
			return _aEnhancements_["shape"]
		ok
		
		# Check node properties for explicit shape
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != "" and 
		   HasKey(_aNode_["properties"], "shape") and _aNode_["properties"]["shape"] != ""
			return _aNode_["properties"]["shape"]
		ok
		
		# Get type for semantic mapping
		_cType_ = ""
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != "" and 
		   HasKey(_aNode_["properties"], "type") and _aNode_["properties"]["type"] != ""
			_cType_ = StzLower("" + _aNode_["properties"]["type"])
		ok
		
		# Direct DOT shape (bypasses semantic mapping)
		if StzFindFirst(_cType_, $acDotShapes) > 0
			return _cType_
		ok
		
		# Semantic to shape mapping
		switch _cType_
		on "process"
			return "box"

		on "decision"
			return "diamond"

		on "start"
			return "ellipse"

		on "endpoint"
			return "doublecircle"

		on "state"
			return "circle"

		on "storage"
			return "cylinder"

		on "data"
			return "box"

		on "event"
			return "ellipse"

		other
			return "box"
		off
	
	def _GetNodeStyle(_aNode_, _aEnhancements_)
		# Get the actual shape that will be rendered
		_cShape_ = This._GetNodeShape(_aNode_, _aEnhancements_)
		
		# Start with global node pen style
		_cBaseStyle_ = @oDiagram.@cNodePenStyle
		
		# If visual rule sets style, merge with base
		if HasKey(_aEnhancements_, "style")
			_cRuleStyle_ = _aEnhancements_["style"]
			# Merge: ensure filled + rounded (for boxes) + rule style
			if NOT StzFindFirst("filled", _cRuleStyle_)
				_cRuleStyle_ += ",filled"
			ok
			if _cShape_ = "box" and NOT StzFindFirst("rounded", _cRuleStyle_)
				_cRuleStyle_ = "rounded," + _cRuleStyle_
			ok
			return _cRuleStyle_
		ok
		
		# Polygon shapes don't support rounded
		
		if StzFindFirst(_cShape_, $aPolygonShapes) > 0
			# Add filled if not already there
			if NOT StzFindFirst("filled", _cBaseStyle_)
				return _cBaseStyle_ + ",filled"
			ok
			return _cBaseStyle_
		ok

		# For box-like shapes, add rounded and filled
		if NOT StzFindFirst("filled", _cBaseStyle_)
			_cBaseStyle_ += ",filled"
		ok
		if NOT StzFindFirst("rounded", _cBaseStyle_) and _cShape_ = "box"
			_cBaseStyle_ = "rounded," + _cBaseStyle_
		ok
		
		return _cBaseStyle_
	
	def _GetNodeFillColor(_aNode_, _aEnhancements_, _cTheme_)
	    _cColor_ = ""
	    
	    if HasKey(_aEnhancements_, "color")
	        _cColor_ = _aEnhancements_["color"]
	    ok
	    
	    if _cColor_ = "" and HasKey(_aNode_, "properties") and 
	       HasKey(_aNode_["properties"], "color")
	        _cColor_ = _aNode_["properties"]["color"]
	    ok
	    
	    # Use theme's primary color when no color specified
	    if _cColor_ = ''
	        if HasKey($aPalette, _cTheme_)
	            _cColor_ = $aPalette[_cTheme_]["primary"]
	        else
	            _cColor_ = $cDefaultNodeColor
	        ok
	    ok
	    
	    # If already hex, return after theme transforms
	    if StzFindFirst("#", _cColor_)
	        if _cTheme_ = "gray"
	            return @oDiagram.ConvertColorTogray(_cColor_)
	        but _cTheme_ = "print"
	            return ResolveColor(:white)
	        ok
	        return _cColor_
	    ok
	    
	    # Resolve through theme palette for semantic colors
	    _cLowerColor_ = StzLower(_cColor_)
	    if HasKey($aPalette, _cTheme_) and HasKey($aPalette[_cTheme_], _cLowerColor_)
	        _cColor_ = $aPalette[_cTheme_][_cLowerColor_]
	    ok
	    
	    # Resolve to hex
	    _cColor_ = ResolveColor(_cColor_)
	    
	    # Final theme transforms
	    if _cTheme_ = "gray"
	        _cColor_ = @oDiagram.ConvertColorTogray(_cColor_)
	    but _cTheme_ = "print"
	        _cColor_ = ResolveColor(:white)
	    ok
	    
	    return _cColor_
	
	def _GetNodeStrokeColor(_cTheme_)
		if @oDiagram.@cNodeStrokeColor != "" and @oDiagram.@cNodeStrokeColor != ""
			return @oDiagram.@cNodeStrokeColor
		ok
		
		if _cTheme_ = "print" or _cTheme_ = "gray"
			return "black"
		ok
		
		return ""
	
	def _GenerateEdges(_cTheme_)
		_cOutput_ = ""
		
		# Add invisible edges to force vertical layout when no real edges exist
		if len(@oDiagram.Edges()) = 0
			_acNodes_ = @oDiagram.Nodes()
			_nLen_ = len(_acNodes_)
			for i = 1 to _nLen_ - 1
				_cFrom_ = This._SanitizeNodeId(_acNodes_[i]["id"])
				_cTo_ = This._SanitizeNodeId(_acNodes_[i+1]["id"])
				_cOutput_ += '    ' + _cFrom_ + ' -> ' + _cTo_ + ' [style=invis]' + char(10)
			end
		ok
		
		_aDiagramEdges1_ = @oDiagram.Edges()
		_nDiagramEdges1Len_ = len(_aDiagramEdges1_)
		for _iLoopDiagramEdges1_ = 1 to _nDiagramEdges1Len_
			_aEdge_ = _aDiagramEdges1_[_iLoopDiagramEdges1_]
			_cOutput_ += This._GenerateEdge(_aEdge_, _cTheme_)
		end
		
		return _cOutput_

	def _GenerateEdge(_aEdge_, _cTheme_)
	    _cFrom_ = This._SanitizeNodeId(_aEdge_["from"])
	    _cTo_ = This._SanitizeNodeId(_aEdge_["to"])
	    _cEdgeKey_ = _aEdge_["from"] + "->" + _aEdge_["to"]
	    
	    _cOutput_ = '    ' + _cFrom_ + ' -> ' + _cTo_
	    _aAttrs_ = []
	    
	    # Check if this is a supervisor -> helper edge
	    if StzLeft(_cTo_, 8) = "_helper_"
	        _aAttrs_ + 'arrowhead=none'
	        _aAttrs_ + 'weight=10'
	    ok
	    
	    # Handle edge label with spacing fix for TB layout
	    if HasKey(_aEdge_, "label") and _aEdge_["label"] != "" and _aEdge_["label"] != ""
	        _cLabel_ = _aEdge_["label"]
	        _cRankDir_ = This._GetRankDir()
	        
	        # Add leading space for TB/BT layouts to prevent label collapse
	        if _cRankDir_ = "TB" or _cRankDir_ = "BT"
	            _cLabel_ = " " + _cLabel_
	        ok
	        
	        _aAttrs_ + ('label="' + _cLabel_ + '"')
	    ok
	    
	    # Check edge properties
	    if HasKey(_aEdge_, "properties")
	        if HasKey(_aEdge_["properties"], "arrowhead")
	            _aAttrs_ + ('arrowhead=' + _aEdge_["properties"]["arrowhead"])
	        ok
	        if HasKey(_aEdge_["properties"], "weight")
	            _aAttrs_ + ('weight=' + _aEdge_["properties"]["weight"])
	        ok
	    ok
	    
	    # Check rule effects from parent
	    if HasKey(@oDiagram.@aEdgesAffectedByRules, _cEdgeKey_)
	        _aAppliedRules_ = @oDiagram.@aEdgesAffectedByRules[_cEdgeKey_]
	        
	        if HasKey(_aAppliedRules_, "style")
	            _aAttrs_ + ('style="' + _aAppliedRules_["style"] + '"')
	        ok
	        
	        if HasKey(_aAppliedRules_, "color")
	            _cColor_ = ResolveColor(_aAppliedRules_["color"])
	            _aAttrs_ + ('color="' + _cColor_ + '"')
	        ok
	        
	        if HasKey(_aAppliedRules_, "penwidth")
	            _aAttrs_ + ('penwidth=' + _aAppliedRules_["penwidth"])
	        ok
	    ok
	    
	    if len(_aAttrs_) > 0
	        _cOutput_ += ' [' + This._JoinAttributes(_aAttrs_) + ']'
	    ok
	    
	    _cOutput_ += char(10)
	    return _cOutput_
	
	def _GenerateTooltip(_aNode_)
	    _aConfig_ = @oDiagram.@aTooltipConfig
	    
	    if len(_aConfig_) = 0
	        return ""  # Explicitly no tooltip
	    ok
	    
	    _cTooltip_ = ""
	    
	    _nConfig1Len_ = len(_aConfig_)
	    for _iLoopConfig1_ = 1 to _nConfig1Len_
	    	_item_ = _aConfig_[_iLoopConfig1_]
	        _cKey_ = StzLower("" + _item_)
	        
	        if _cKey_ = "nodeid"
	            _cTooltip_ += "ID: " + _aNode_["id"] + "\n"
	            
	        but _cKey_ = "label"
	            _cTooltip_ += "Label: " + _aNode_["label"] + "\n"
	            
	        but _cKey_ = "type"
	            if HasKey(_aNode_["properties"], "type")
	                _cTooltip_ += "Type: " + _aNode_["properties"]["type"] + "\n"
	            ok
	            
	        but _cKey_ = "color"
	            if HasKey(_aNode_["properties"], "color")
	                _cTooltip_ += "Color: " + _aNode_["properties"]["color"] + "\n"
	            ok
	            
	        else
	            # Custom property
	            if HasKey(_aNode_["properties"], _cKey_)
	                _cValue_ = _aNode_["properties"][_cKey_]
	                _cTooltip_ += _cKey_ + ": " + _cValue_ + "\n"
	            ok
	        ok
	    end
	    
	    return _cTooltip_
	
	def _EscapeTooltip(_cText_)
	    _cText_ = StzReplace(_cText_, '"', '\"')
	    _cText_ = StzReplace(_cText_, "\n", "&#10;")  # HTML entity for newline
	    return _cText_

	def _JoinAttributes(_aAttrs_)
		_cResult_ = ""
		_nLen_ = len(_aAttrs_)

		for i = 1 to _nLen_
			_cResult_ += _aAttrs_[i]
			if i < _nLen_
				_cResult_ += ', '
			ok
		end

		return _cResult_

	def DotCode()
		return @cDotCode

		def Code()
			return @cDotCode

		def Content()
			return @cDotCode


	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.DotCode())
		fclose(_oFile_)
		return 1

#====================================#
#  stzDiagramToMermaid - MERMAID.JS  #
#====================================#

class stzDiagramToMermaid from stzObject

	@oDiagram
	@cMermaidCode

	def init(poDiagram)

		if NOT ( isObject(poDiagram) and ( ring_classname(poDiagram) = "stzdiagram" or
				ring_classname(poDiagram) = "stzorgchart"
				)
			)

			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_cOutput_ = "graph TD" + char(10)
		
		# Mermaid reserved keywords
		_aReservedWords_ = ["end", "start", "subgraph", "graph", "style", "class", 
		                  "click", "call", "direction", "flowchart", "stateDiagram",
		                  "state", "note", "default", "loop", "alt", "par", "and"]
	
		_aNodes_ = @oDiagram.Nodes()
		_nLen_ = len(_aNodes_)
		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_cNodeId_ = _aNode_["id"]
			_cLabel_ = _aNode_["label"]
	
			# Escape reserved keywords
			_cSafeNodeId_ = _cNodeId_
			if StzFindFirst(StzLower(_cNodeId_), _aReservedWords_) > 0
				_cSafeNodeId_ = "node_" + _cNodeId_
			ok
	
			_cType_ = _aNode_["properties"]["type"]
			if _cType_ = "start"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + char(10)
	
			but _cType_ = "endpoint"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + char(10)
	
			but _cType_ = "decision"
				_cOutput_ += '    ' + _cSafeNodeId_ + '{{"' + _cLabel_ + '"}}' + char(10)
	
			but _cType_ = "process"
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + char(10)
	
			else
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + char(10)
			ok
		end
	
		_cOutput_ += char(10)
	
		_aEdges_ =  @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			_cFromId_ = _aEdge_["from"]
			_cToId_ = _aEdge_["to"]
			
			# Escape reserved keywords in edges
			if StzFindFirst(StzLower(_cFromId_), _aReservedWords_) > 0
				_cFromId_ = "node_" + _cFromId_
			ok
			if StzFindFirst(StzLower(_cToId_), _aReservedWords_) > 0
				_cToId_ = "node_" + _cToId_
			ok
			
			if _aEdge_["label"] != "" and _aEdge_["label"] != ""
				_cOutput_ += '    ' + _cFromId_ + ' -->|' + _aEdge_["label"] + '| ' + _cToId_ + char(10)
			else
				_cOutput_ += '    ' + _cFromId_ + ' --> ' + _cToId_ + char(10)
			ok
		end
	
		@cMermaidCode = _cOutput_
	
	def Code()
		return @cMermaidCode

		def MermaidCode()
			return @cMermaidCode

		def Content()
			return @cMermaidCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.Code())
		fclose(_oFile_)
		return 1

#==================================#
#  stzDiagramToJSON - JSON FORMAT  #
#==================================#

class stzDiagramToJSON from stzObject

	@oDiagram
	@cJsonCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_aData_ = @oDiagram.ToHashlist()
		@cJsonCode = ToJSONXT(_aData_)

	def Json()
		return @cJsonCode

		def JsonCode()
			return @cJsonCode

		def Code()
			return @cJsonCode

		def Content()
			return @cJsonCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.JsonCode())
		fclose(_oFile_)
		return 1

#========================#
#  COLOR RESOLVER CLASS  #
#========================#

class stzColorResolver from stzObject

	def init()

	def ResolveFontColor(pBgColor)
		# Get actual resolved background color
		_cBgColor_ = ResolveColor(pBgColor)
		
		# Always use luminance calculation for consistent contrast
		return This.ContrastingTextColor(_cBgColor_)
	
	# DELEGATES to the universal StzContrastingText. This carried its own
	# copy of the BT.709 rule, so a plot or a canvas wanting the same
	# answer had to instantiate a diagram to borrow it. One rule, one
	# place -- the two colour TABLES already showed what happens when
	# that slips.
	def ContrastingTextColor(_cColor_)
		return StzContrastingText(_cColor_)
	
	def ColorToRGB(_cColor_)
		# First resolve to hex, then convert
		_cHex_ = ResolveColor(_cColor_)
		return HexToRGB(_cHex_)

	def NodeStrokeColorForTheme(_cTheme_)
		if _cTheme_ = "print" or _cTheme_ = "gray"
			return "black"
		ok
		return ""

	def ConvertColorToGray(_cColor_)
		_aRGB_ = This.ColorToRGB(_cColor_)
		_nR_ = _aRGB_[1]
		_nG_ = _aRGB_[2]
		_nB_ = _aRGB_[3]
		
		# Use perceptual brightness formula
		_nGray_ = floor(0.299 * _nR_ + 0.587 * _nG_ + 0.114 * _nB_)
		
		# Use global helper
		return RGBToHex(_nGray_, _nGray_, _nGray_)

	def ResolveWithPalette(pcColor, pacPalette)

		if isString(pcColor) and StzFindFirst("#", pcColor)
			return pcColor
		ok

		_cColorKey_ = StzLower("" + pcColor)

		# Extract intensity modifier (++, +, --, -)
		_cIntensity_ = ""
		_cBaseKey_ = _cColorKey_

		if StzRight(_cColorKey_, 2) = "++" or StzRight(_cColorKey_, 2) = "--"
			_cIntensity_ = StzRight(_cColorKey_, 2)
			_cBaseKey_ = StzLeft(_cColorKey_, stzlen(_cColorKey_) - 2)

		but StzRight(_cColorKey_, 1) = "+" or StzRight(_cColorKey_, 1) = "-"
			_cIntensity_ = StzRight(_cColorKey_, 1)
			_cBaseKey_ = StzLeft(_cColorKey_, stzlen(_cColorKey_) - 1)
		ok
		
		# Try direct palette lookup
		if HasKey(pacPalette, _cColorKey_)
			return pacPalette[_cColorKey_]
		ok
		
		# Try semantic meaning
		if HasKey($acColorsBySemanticMeaning, _cBaseKey_)
			_cBaseColor_ = "" + $acColorsBySemanticMeaning[_cBaseKey_]
			return ResolveColor(_cBaseColor_ + _cIntensity_)
		ok
		
		# Try node type
		if HasKey($acColorsByNodeType, _cBaseKey_)
			_cBaseColor_ = "" + $acColorsByNodeType[_cBaseKey_]
			return ResolveColor(_cBaseColor_ + _cIntensity_)
		ok
		
		# Legacy map #TODO Shoud it be global?
		_aLegacyMap_ = [
			:lightblue = "blue+",
			:lightgreen = "green+",
			:lightyellow = "yellow+",
			:lightcoral = "coral",
			:lightgray = "gray+",
			:lightcyan = "cyan+",
			:lightpink = "pink+",
			:darkgreen = "green-",
			:darkblue = "blue-",
			:darkred = "red-"
		]
		
		if HasKey(_aLegacyMap_, _cColorKey_)
			return ResolveColor(_aLegacyMap_[_cColorKey_])
		ok

		# UNKNOWN. This used to `return pacPalette[:blue]`, so every typo in
		# a colour name silently became BLUE -- and so did the empty string.
		# A picture drawn from a misspelt palette looked deliberate.
		#
		# It answers "" now, which is the only honest thing a lookup can say
		# about a name it does not have. The DECISION of what to do about
		# that belongs to the caller and is made in exactly one place:
		# StzResolveColor applies the documented fallback,
		# StzTryResolveColor hands the "" straight back so a face can refuse.
		return ""

#============================================#
#  stzStylParser - *.stzstyl Format Parser   #
#  Visual theme and styling definitions      #
#============================================#

class stzStylParser from stzObject
	
	def init()

	def ParseFile(pcFilename)
		_cContent_ = read(pcFilename)
		return This.Parse(_cContent_)
	
	def Parse(pcContent)
		_aStyle_ = [
			:name = "",
			:theme = $cDefaultColorTheme,
			:layout = $cDefaultLayout,
			:colors = [],
			:fonts = [],
			:edges = [],
			:nodes = [],
			:focus = [],
			:custom = []
		]
		
		_acLines_ = split(pcContent, char(10))
		_cSection_ = ""
		
		_nAcLines1Len_ = len(_acLines_)
		for _iLoopAcLines1_ = 1 to _nAcLines1Len_
			_cLine_ = _acLines_[_iLoopAcLines1_]
			_cLine_ = trim(_cLine_)
			
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
				loop
			ok

			# Style header
			if StzFindFirst("style ", _cLine_)
				_aStyle_[:name] = This._ExtractQuoted(_cLine_)

			but StzFindFirst("theme:", _cLine_)
				_aStyle_[:theme] = This._ExtractValue(_cLine_)

			but StzFindFirst("layout:", _cLine_)
				_aStyle_[:layout] = This._ExtractValue(_cLine_)

			# Sections
			but _cLine_ = "colors"
				_cSection_ = "colors"

			but _cLine_ = "fonts"
				_cSection_ = "fonts"

			but _cLine_ = "edges"
				_cSection_ = "edges"

			but _cLine_ = "nodes"
				_cSection_ = "nodes"

			but _cLine_ = "focus"
				_cSection_ = "focus"

			but _cLine_ = "custom"
				_cSection_ = "custom"

			# Parse section content
			but _cSection_ != "" and StzFindFirst(":", _cLine_)
				_aParts_ = split(_cLine_, ":")
				_cKey_ = trim(_aParts_[1])
				_cValue_ = trim(_aParts_[2])
				
				_aStyle_[_cSection_] + [_cKey_, This._ParseValue(_cValue_)]
			ok
		end
		

		return _aStyle_
	
	def _ParseValue(_cValue_)
		# Try number
		if isdigit(_cValue_)
			return 0 + _cValue_
		ok
		
		# Remove quotes
		if StzLeft(_cValue_, 1) = '"' and StzRight(_cValue_, 1) = '"'
			return StzMid(_cValue_, 2, StzLen(_cValue_) - 2)
		ok

		return _cValue_

	def _ExtractValue(_cLine_)
		_nPos_ = StzFindFirst(":", _cLine_)
		if _nPos_ = 0 return "" ok
		_cValue_ = trim(StzMid(_cLine_, _nPos_ + 1, StzLen(_cLine_) - _nPos_))
		return This._ParseValue(_cValue_)

	def _ExtractQuoted(_cLine_)
		_nStart_ = StzFindFirst('"', _cLine_)
		if _nStart_ = 0 return "" ok
		_nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
		_nEnd_ = StzFindFirst('"', _nEnd_)
		return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)
