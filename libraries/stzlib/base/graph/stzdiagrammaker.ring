#======================#
#  stzDiagramMaker - Fixed Implementation
#  Declarative, Composable Diagram API
#  Softanza Pattern Implementation
#======================#

#------------------------------------------
#  GLOBAL DESIGN SYSTEM
#------------------------------------------

$cDefaultNodeType = :Event
$cDefaultTheme = :Light
$cDefaultLayout = :TopDown
$cDefaultOutputFolder = "output"
@cDefaultOutputFile = "ouput.svg"

# Color Palettes - data-driven, globally configurable
$gDiagramPalettes = [
	:light = [
		:primary = "lightblue",
		:success = "lightgreen",
		:warning = "lightyellow",
		:danger = "lightcoral",
		:info = "lightcyan",
		:neutral = "lightgray",
		:background = "white"
	],
	:dark = [
		:primary = "#003366",
		:success = "#4CAF50",
		:warning = "#FF9800",
		:danger = "#F44336",
		:info = "#2196F3",
		:neutral = "#757575",
		:background = "#F5F5F5"
	],
	:vibrant = [
		:primary = "#0288D1",
		:success = "#43A047",
		:warning = "#FB8C00",
		:danger = "#E53935",
		:info = "#1E88E5",
		:neutral = "#424242",
		:background = "white"
	],
	:professional = [
		:primary = "lightblue",
		:success = "#006633",
		:warning = "#CC6600",
		:danger = "#CC0000",
		:info = "#0066CC",
		:neutral = "#666666",
		:background = "white"
	]
]

# Font color mapping for readable contrast
$gDiagramFontColors = [
	:light = [
		:primary = "black",
		:success = "black",
		:warning = "black",
		:danger = "black",
		:info = "black",
		:neutral = "black"
	],
	:dark = [
		:primary = "white",
		:success = "white",
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	],
	:vibrant = [
		:primary = "white",
		:success = "white",
		:warning = "white",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	],
	:professional = [
		:primary = "black",
		:success = "white",
		:warning = "white",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	]
]

# Node Style Templates - reusable visual patterns
$gDiagramNodeStyles = [
	:process = [
		:shape = "box",
		:style = "rounded,filled",
		:penwidth = 1.5
	],
	:decision = [
		:shape = "diamond",
		:style = "filled",
		:penwidth = 1.5
	],

	:state = [
		:shape = "circle",
		:penwidth = 1.5
	],

	:start = [
		:shape = "polygon",
		:sides = 3,
		:penwidth = 1.5,
		:width = 0.5,
		:height = 0.5,
		:fixedsize = true
	],

	:endpoint = [
		:shape = "doublecircle",
		:penwidth = 1.5,
		:width = 0.5,
		:height = 0.5,
		:fixedsize = true
	],
	:storage = [
		:shape = "cylinder",
		:style = "filled",
		:penwidth = 1.5
	],
	:data = [
		:shape = "box",
		:style = "rounded,filled",
		:penwidth = 1.5
	],
	:event = [
		:shape = "ellipse",
		:style = "filled",
		:penwidth = 1.5
	],

	:label = [
		:shape = "plaintext"
	]
	
]

# Edge Style Templates
$gDiagramEdgeStyles = [
	:normal = [
		:style = "solid",
		:penwidth = 1.5
	],
	:dashed = [
		:style = "dashed",
		:penwidth = 1.5
	],
	:bold = [
		:style = "solid",
		:penwidth = 3
	],
	:dotted = [
		:style = "dotted",
		:penwidth = 1
	],
	:optional = [
		:style = "dashed",
		:penwidth = 1
	],
	:decision = [
		:fromport = ":c",
		:toport = ":c"
	]
]

# Layout Presets
$gDiagramLayouts = [
	:topdown = [
		:rankdir = "TB",
		:splines = "ortho",
		:nodesep = 0.6,
		:ranksep = 0.8
	],
	:leftright = [
		:rankdir = "LR",
		:splines = "spline",
		:nodesep = 0.8,
		:ranksep = 1.0
	],
	:organic = [
		:rankdir = "TB",
		:splines = "curved",
		:nodesep = 0.8,
		:ranksep = 1.2
	],
	:hierarchy = [
		:rankdir = "TB",
		:splines = "ortho",
		:nodesep = 0.6,
		:ranksep = 1.0
	],
	:bottomup = [
		:rankdir = "BT",
		:splines = "ortho",
		:nodesep = 0.6,
		:ranksep = 0.8
	]
]

# Typography Presets
$gDiagramFonts = [
	:default = "Helvetica",
	:monospace = "Courier New",
	:sans = "Arial",
	:serif = "Times New Roman"
]

#------------------------------------------
#  stzDiagramMaker - Main Class
#------------------------------------------

class stzDiagramMaker

	@cTitle = ""
	@aNodes = []
	@aEdges = []
	@aClusters = []
	@aConfig = []
	@cTheme = :Light
	@aPalette = []
	@aFontColors = []
	@cLayout = :TopDown
	@cEdgeColor = "black"
	@cNodeStrokeColor = "black"

	def init(pTitle)
		this.@cTitle = pTitle
		this.@aNodes = []
		this.@aEdges = []
		this.@aClusters = []
		this.@cTheme = $cDefaultTheme
		this.@cLayout = $cDefaultLayout
		this.@aConfig = [
			:theme = $cDefaultTheme,
			:layout = $cDefaultLayout,
			:fontname = "Helvetica",
			:bgcolor = "white"
		]
		this.SetupTheme($cDefaultTheme)

	def SetupTheme(pTheme)
		this.@cTheme = pTheme
		this.@aConfig[:theme] = pTheme
		if HasKey($gDiagramPalettes, pTheme)
			this.@aPalette = $gDiagramPalettes[pTheme]
			this.@aFontColors = $gDiagramFontColors[pTheme]
		else
			this.@aPalette = $gDiagramPalettes[$cDefaultTheme]
			this.@aFontColors = $gDiagramFontColors[$cDefaultTheme]
		ok

	
	#------------------------------------------
	#  NODE OPERATIONS
	#------------------------------------------

	def AddNode(pNodeId, pLabel)
		This.AddNodeXT(pNodeId, pLabel, $cDefaultNodeType)

	def AddNodeXT(pcId, pcLabel, pcType)
		if isList(pcId) and len(pcId) = 2 and pcId[1] = :ID
			pcId = pcId[2]
		ok
		if isList(pcLabel) and len(pcLabel) = 2 and pcLabel[1] = :Label
			pcLabel = pcLabel[2]
		ok
		if isList(pcType) and len(pcType) = 2 and pcType[1] = :Type
			pcType = pcType[2]
		ok

		if pcType = :Default
			pcType = $cDefaultNodeType
		ok

		if HasKey($gDiagramNodeStyles, pcType)
			style = $gDiagramNodeStyles[pcType]
			
			if pcType = :start
				displayLabel = ""
			else if pcType = :endpoint
				displayLabel = ""
			else
				displayLabel = pcLabel
			ok
			ok
			
			oNode = [
				:id = pcId,
				:label = displayLabel,
				:type = pcType,
				:style = style,
				:color = "",
				:fontcolor = "",
				:attrs = []
			]
			this.@aNodes + oNode
		ok

	def Colored(pColor)
		if len(this.@aNodes) > 0
			this.@aNodes[len(this.@aNodes)][:color] = pColor
		ok

	def WithColor(pSemantic)
		if HasKey(this.@aPalette, pSemantic)
			color = this.@aPalette[pSemantic]
			fontcolor = this.@aFontColors[pSemantic]
			if len(this.@aNodes) > 0
				this.@aNodes[len(this.@aNodes)][:color] = color
				this.@aNodes[len(this.@aNodes)][:fontcolor] = fontcolor
			ok
		ok

	def Styled(pAttrs)
		if len(this.@aNodes) > 0
			this.@aNodes[len(this.@aNodes)][:attrs] = pAttrs
		ok

	#------------------------------------------
	#  EDGE OPERATIONS
	#------------------------------------------

	def Connect(pFromId, pToId)
		This.ConnectXT(pFromId, pToId, "")

	def ConnectXT(pcFromId, pcToId, pcLabel)
		if isList(pcFromId) and len(pcFromId) = 2 and pcFromId[1] = :From
			pcFromId = pcFromId[2]
		ok
		if isList(pcToId) and len(pcToId) = 2 and pcToId[1] = :To
			pcToId = pcToId[2]
		ok
		if isList(pcLabel) and len(pcLabel) = 2 and (pcLabel[1] = :With or pcLabel[1] = :Label)
			pcLabel = pcLabel[2]
		ok

		edge = [
			:from = pcFromId,
			:to = pcToId,
			:label = pcLabel,
			:type = :normal,
			:attrs = []
		]
		this.@aEdges + edge

	def ConnectWithLabel(pFromId, pToId, pLabel)
		This.ConnectXT(pFromId, pToId, pLabel)

	#------------------------------------------
	#  CLUSTER OPERATIONS
	#------------------------------------------

	def AddCluster(pClusterId, pLabel, pNodeIds, pColor)
		cluster = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = pNodeIds,
			:color = pColor
		]
		this.@aClusters + cluster

	def AddClusterXT(pcId, pcLabel, pcNodeIds, pcColor)
		if isList(pcId) and len(pcId) = 2 and pcId[1] = :ID
			pcId = pcId[2]
		ok
		if isList(pcLabel) and len(pcLabel) = 2 and pcLabel[1] = :Label
			pcLabel = pcLabel[2]
		ok
		if isList(pcNodeIds) and len(pcNodeIds) = 2 and pcNodeIds[1] = :Nodes
			pcNodeIds = pcNodeIds[2]
		ok
		if isList(pcColor) and len(pcColor) = 2 and pcColor[1] = :Color
			pcColor = pcColor[2]
		ok

		This.AddCluster(pcId, pcLabel, pcNodeIds, pcColor)

	#------------------------------------------
	#  CONFIGURATION
	#------------------------------------------

	def SetLayout(pLayout)
		if HasKey($gDiagramLayouts, pLayout)
			this.@cLayout = pLayout
			this.@aConfig[:layout] = pLayout
		ok

	def SetTheme(pTheme)
		This.SetupTheme(pTheme)

	def SetFont(pFont)
		if HasKey($gDiagramFonts, pFont)
			this.@aConfig[:fontname] = $gDiagramFonts[pFont]
		else
			this.@aConfig[:fontname] = pFont
		ok

	def SetBackgroundColor(pColor)
		this.@aConfig[:bgcolor] = pColor

	def SetEdgeColor(pColor)
		this.@cEdgeColor = pColor

	def SetNodeStrokeColor(pColor)
		this.@cNodeStrokeColor = pColor

	#------------------------------------------
	#  DOT CODE GENERATION
	#------------------------------------------

	def GenerateDOT()
		dot = ""
		layout = $gDiagramLayouts[this.@cLayout]

		dot += 'digraph "' + this.@cTitle + '" {' + NL
		dot += '	graph [' + NL
		dot += '		rankdir=' + layout[:rankdir] + NL
		dot += '		bgcolor="' + this.@aConfig[:bgcolor] + '"' + NL
		dot += '		fontname="' + this.@aConfig[:fontname] + '"' + NL
		dot += '		splines=' + layout[:splines] + NL
		dot += '		nodesep=' + layout[:nodesep] + NL
		dot += '		ranksep=' + layout[:ranksep] + NL
		dot += '	]' + NL + NL

		dot += '	node [fontname="' + this.@aConfig[:fontname] + '"]' + NL
		dot += '	edge [fontname="' + this.@aConfig[:fontname] + '"]' + NL + NL

		# Generate nodes
		dot += this.GenerateNodes()

		# Generate clusters
		dot += this.GenerateClusters()

		# Generate edges
		dot += this.GenerateEdges()

		dot += NL + '}' + NL
		return dot

	def GenerateNodes()
		dot = ""
		for oNode in this.@aNodes
			# Determine the font color for this node
			cFontColor = "black"
			if oNode[:fontcolor] != ""
				cFontColor = oNode[:fontcolor]
			ok
			
			# Build the label with embedded fontcolor
			cLabel = oNode[:label]
			if cLabel != "" and cLabel != " "
				cLabel = '<font color="' + cFontColor + '">' + cLabel + '</font>'
			ok
			
			dot += '	' + oNode[:id] + ' ['
			dot += 'label=<' + cLabel + '>, '

			if HasKey(oNode, :style) and len(oNode[:style]) > 0
				style = oNode[:style]
				if HasKey(style, :shape)
					dot += 'shape=' + style[:shape] + ', '
				ok
				if HasKey(style, :sides)
					dot += 'sides=' + style[:sides] + ', '
				ok
				
				# Dynamic orientation based on layout
				if oNode[:type] = :start
					if this.@cLayout = :leftright or this.@cLayout = :LeftRight
						dot += 'orientation=270, '
					else
						dot += 'orientation=180, '
					ok
				ok
				
				if HasKey(style, :style)
					dot += 'style="' + style[:style] + '", '
				ok
				if HasKey(style, :penwidth)
					dot += 'penwidth=' + style[:penwidth] + ', '
				ok
				if HasKey(style, :width)
					dot += 'width=' + style[:width] + ', '
				ok
				if HasKey(style, :height)
					dot += 'height=' + style[:height] + ', '
				ok
				if HasKey(style, :fixedsize)
					dot += 'fixedsize=true, '
				ok
			ok

			if HasKey(oNode, :color)
				dot += 'fillcolor="' + oNode[:color] + '", '

			else
				dot += 'fillcolor="' + this.@aPalette[:primary] + '", '
			ok

			# Add node stroke color if set
			if this.@cNodeStrokeColor != ""
				dot += 'color="' + this.@cNodeStrokeColor + '", '
			ok

			dot += 'fontcolor="' + cFontColor + '"'
			dot += ']' + NL
		end
		return dot


	def GenerateClusters()
		dot = ""
		for cluster in this.@aClusters
			dot += NL + '	subgraph cluster_' + cluster[:id] + ' {' + NL
			dot += '		label="' + cluster[:label] + '"' + NL
			dot += '		style=filled' + NL
			dot += '		fillcolor="' + cluster[:color] + '"' + NL
			for nodeId in cluster[:nodes]
				dot += '		' + nodeId + NL
			end
			dot += '	}' + NL
		end
		return dot

	def GenerateEdges()
		dot = ""
		for oEdge in this.@aEdges
			cFromPort = ""
			cToPort = ""
			
			# Check if edge connects to/from decision nodes
			for oNode in this.@aNodes
				if oNode[:id] = oEdge[:from] and oNode[:type] = :decision
					if HasKey($gDiagramEdgeStyles[:decision], :fromport)
						cFromPort = $gDiagramEdgeStyles[:decision][:fromport]
					ok
				ok
				if oNode[:id] = oEdge[:to] and oNode[:type] = :decision
					if HasKey($gDiagramEdgeStyles[:decision], :toport)
						cToPort = $gDiagramEdgeStyles[:decision][:toport]
					ok
				ok
			end
			
			dot += '	' + oEdge[:from] + cFromPort + ' -> ' + oEdge[:to] + cToPort
			dot += ' [color="' + this.@cEdgeColor + '"'
			if oEdge[:label] != ""
				dot += ', label="' + oEdge[:label] + '", labeldistance=2.0, labelangle=0'
			ok
			dot += ']'
			dot += NL
		end
		return dot


	def ToCode()
		return This.GenerateDOT()

	#------------------------------------------
	#  OUTPUT & EXECUTION
	#------------------------------------------

	def Render(pOutputFile)
		dot = new stzDotCode()
		dot.SetCode(this.GenerateDOT())
		dot.SetOutputFile(pOutputFile)
		dot.RunAndView()

	def RenderToSVG(pOutputFile)
		dot = new stzDotCode()
		dot.SetCode(this.GenerateDOT())
		dot.SetOutputFile(pOutputFile)
		dot.SetOutputFormat("svg")
		dot.RunAndView()

	def RenderToPNG(pOutputFile)
		dot = new stzDotCode()
		dot.SetCode(this.GenerateDOT())
		dot.SetOutputFile(pOutputFile)
		dot.SetOutputFormat("png")
		dot.RunAndView()

	def Inspect()
		? "=== Diagram: " + this.@cTitle + " ==="
		? "Theme: " + upper(this.@cTheme)
		? "Layout: " + upper(this.@cLayout)
		? "Nodes: " + len(this.@aNodes)
		? "Edges: " + len(this.@aEdges)
		? "Clusters: " + len(this.@aClusters)
