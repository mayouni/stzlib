#=====================================================
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph
#  Workflows, org charts, semantic diagrams
#=====================================================

#  GLOBAL REGISTRY
#==================

$aDiagramValidators = [
	:SOX = new stzDiagramSoxValidator(),
	:GDPR = new stzDiagramGdprValidator(),
	:Banking = new stzDiagramBankingValidator()
]

# Global node type definitions
$acNodeTypes = [
	:Start,
	:Process,
	:Decision,
	:Endpoint,
	:State,
	:Storage,
	:Data,
	:Event,
	:Gateway,
	:Subprocess,
	:Timer,
	:Error,
	:Compensation
]

# Default colors for node types
$acNodeColors = [
	:Start = "lightgreen",
	:Process = "lightblue",
	:Decision = "lightyellow",
	:Endpoint = "lightcoral",
	:State = "lightcyan",
	:Storage = "lightgray",
	:Data = "lavender",
	:Event = "lightpink",
	:Gateway = "lightyellow",
	:Subprocess = "lightsteelblue",
	:Timer = "lightsalmon",
	:Error = "lightcoral",
	:Compensation = "lightgoldenrodyellow"
]

# Default node type and color
@cDefaultNodeType = "process"
@cDefaultNodeColor = "lightblue"

# Edge styles
$acEdgeStyles = [
	:Normal = "solid",
	:Conditional = "dashed",
	:ErrorFlow = "dotted",
	:MessageFlow = "bold"
]

@cDefaultEdgeStyle = "normal"

$acEdgeColors = [
	"black",
	"gray",
	"blue",
	"green",
	"red",
	"orange",
	"purple",
	"brown",
	"pink",
	"cyan",
	"magenta",
	"yellow",
	"navy",
	"teal",
	"olive",
	"maroon",
	"lime",
	"aqua",
	"silver",
	"gold"
]

@cDefaultEdgeColor = "black"

# THEMES

$acThemes = [
	"light",
	"dark",
	"vibrant",
	"professional"
]

@cDefaultTheme = "light"

# LAYOUT ~ These map to Graphviz's rankdir values:
$acLayouts = [
	"topdown",	# "TB" in Graphviz DOT notation
	"bottomup",	# "BT"
	"leftright",	# "LR"
	"rightLeft"	# "RL"
]

@cDefaultLayout = "topdown"

# PALETTE AND FONT COLORS

$aPalette = [
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

$aFontColors = [
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
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	],
	:professional = [
		:primary = "black",
		:success = "white",
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	]
]

func Palette()
	return $aPalette

func FontColors()
	return $aFontColors

# NODE TYPE CALL FUNCTIONS

func DefaultNodeType()
	return @cDefaultNodeType

func NodeTypes()
	return $acNodeTypes

func IsValidNodeType(pcType)
	return ring_find($acNodeTypes, pcType) > 0

func DefaultNodeColor()
	return @cDefaultNodeColor

func ColorForNodeType(pcType)
	if HasKey($acNodeColors, pcType)
		return $acNodeColors[pcType]
	ok
	return @cDefaultNodeColor

# EDGE STYLE CALL FUNCTIONS

func IsValidEdgeStyle(pcStyle)
	return HasKey($acEdgeStyles, pcStyle)

func EdgeStyles()
	return $acEdgeStyles

func DefaultEdgeStyle()
	return @cDefaultEdgeStyle

func StyleForEdgeType(pcType)
	if HasKey($acEdgeStyles, pcType)
		return $acEdgeStyles[pcType]
	ok
	return @cDefaultEdgeStyle

# VALIDATOR CALL FUNCTION

func DiagramValidators()
	return $aDiagramValidators


class stzDiagram from stzGraph

	@oVisualStyle = NULL
	@aClusters = []
	@aAnnotations = []
	@aTemplates = []
	@cEdgeColor = @cDefaultEdgeColor
	@cNodeStrokeColor = ""

	def init(pTitle)
		super.init(pTitle)
		@oVisualStyle = new stzVisualStyle("professional", "topdown")

	def SetTheme(pTheme)
		@oVisualStyle.SetTheme(pTheme)

	def Theme()
		return @oVisualStyle.Theme()

	def SetLayout(pLayout)
		@oVisualStyle.SetLayout(pLayout)

	def Layout()
		return @oVisualStyle.Layout()

	def VisualStyle()
		return @oVisualStyle

	def SetEdgeColor(pColor)
		@cEdgeColor = pColor

	def SetNodeStrokeColor(pColor)
		@cNodeStrokeColor = pColor

	#------------------------------------------
	#  COLOR RESOLUTION (delegated to theme)
	#------------------------------------------

	def ResolveColor(pColor)
		return @oVisualStyle.ResolveColor(pColor)

	def ResolveFontColor(pBgColor)
		return @oVisualStyle.ResolveFontColor(pBgColor)

	#------------------------------------------
	#  DIAGRAM-SPECIFIC NODE OPERATIONS
	#------------------------------------------

	def AddNode(pNodeId, pLabel)
		This.AddNodeXT(pNodeId, pLabel, @cDefaultNodeType, @cDefaultNodeColor)

	def AddNodeXT(pNodeId, pLabel, pType, pColor)
		super.AddNodeXTT(pNodeId, pLabel, [
			:type = pType,
			:color = pColor
		])

	def Connect(pFromId, pToId)
		This.ConnectXT(pFromId, pToId, "")

	def ConnectXT(pFromId, pToId, pLabel)
		This.AddEdgeXT(pFromId, pToId, pLabel)

	#------------------------------------------
	#  CLUSTER OPERATIONS
	#------------------------------------------

	def AddCluster(pClusterId, pLabel, aNodeIds, pColor)
		oCluster = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = aNodeIds,
			:color = pColor
		]
		@aClusters + oCluster

	def Clusters()
		return @aClusters

	#------------------------------------------
	#  ANNOTATION OPERATIONS
	#------------------------------------------

	def AddAnnotation(oAnnotation)
		@aAnnotations + oAnnotation

	def AnnotationsByType(pType)
		aFiltered = []

		for oAnn in @aAnnotations
			if oAnn.Type() = pType
				aFiltered + oAnn
			ok
		end
		return aFiltered

	def Annotations()
		return @aAnnotations

	#------------------------------------------
	#  TEMPLATE OPERATIONS
	#------------------------------------------

	def AddTemplate(oTemplate)
		@aTemplates + oTemplate

	def ApplyTemplates()
		for oTemplate in @aTemplates
			oTemplate.Apply(This)
		end

	#------------------------------------------
	#  VALIDATION
	#------------------------------------------

	def ValidateDAG()
		return NOT This.CyclicDependencies()

	def ValidateReachability()
		aStartNodes = []
		aEndpointNodes = []

		for aNode in This.Nodes()
			if aNode["properties"]["type"] = :Start
				aStartNodes + aNode["id"]
			ok
			if aNode["properties"]["type"] = :Endpoint
				aEndpointNodes + aNode["id"]
			ok
		end

		for cEndpoint in aEndpointNodes
			bReachable = 0
			for cStart in aStartNodes
				if This.PathExists(cStart, cEndpoint)
					bReachable = 1
					exit
				ok
			end
			if NOT bReachable
				return [
					:status = "fail",
					:issue = "Endpoint unreachable: " + cEndpoint
				]
			ok
		end

		return [ :status = "pass" ]

	def ValidateCompleteness()
		aIssues = []

		for aNode in This.Nodes()
			if aNode["properties"]["type"] = "decision"
				aNeighbors = This.Neighbors(aNode["id"])
				if len(aNeighbors) < 2
					aIssues + "Decision node has fewer than 2 paths: " + aNode["id"]
				ok
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:issues = aIssues
		]

	#------------------------------------------
	#  METRICS
	#------------------------------------------

	def ComputeMetrics()
		aMetrics = []
		aAllPaths = []

		for aNode in This.Nodes()
			aReachable = This.ReachableFrom(aNode["id"])
			if len(aReachable) > 1
				aAllPaths + (len(aReachable) - 1)
			ok
		end

		nAvg = 0
		if len(aAllPaths) > 0
			nSum = 0
			for nLen in aAllPaths
				nSum += nLen
			end
			nAvg = nSum / len(aAllPaths)
		ok

		nMax = 0
		for nLen in aAllPaths
			if nLen > nMax
				nMax = nLen
			ok
		end

		aMetrics[:avgPathLength] = nAvg
		aMetrics[:maxPathLength] = nMax
		aMetrics[:bottlenecks] = This.BottleneckNodes()
		aMetrics[:density] = This.NodeDensity()
		aMetrics[:nodeCount] = This.NodeCount()
		aMetrics[:edgeCount] = This.EdgeCount()

		return aMetrics

	#------------------------------------------
	#  VISUALIZATION
	#------------------------------------------

	def Show()
		# Generate DOT code
		cDotCode = This.Dot()
		
		# Create stzDotCode instance
		oDotExec = new stzDotCode()
		oDotExec.SetCode(cDotCode)
		
		# Set output format and file
		oDotExec.SetOutputFormat("svg")
		oDotExec.SetOutputFile("diagram_" + This.Id() + ".svg")
		
		# Execute and view
		oDotExec.ExecuteAndView()
		
		def Display()
			This.Show()
		
		def View()
			This.Show()
		
		def Visualize()
			This.Show()

	#------------------------------------------
	#  EXPORT
	#------------------------------------------

	def ToHashlist()
		aBase = super.ToHashlist()
		aBase["theme"] = @oVisualStyle.Theme().Name()
		aBase["layout"] = @oVisualStyle.Layout().Orientation()
		aBase["clusters"] = @aClusters
		aBase["annotations"] = @aAnnotations
		aBase["templates"] = @aTemplates
		return aBase

	def stzdiag()
		oConv = new stzDiagramToStzDiag(This)
		return oConv.stzdiag()

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
		oConv = new stzDiagramToDot(This)
		return oConv.Code()

		def ToDot()
			return This.Dot()

		def GraphvizDot()
			return This.Dot()

		def ToGraphvizDot()
			return This.Dot()

	def Json()
		oConv = new stzDiagramToJson(This)
		return oConv.Code()

		def ToJson()
			return This.Json()

	def Mermaid()
		oConv = new stzDiagramToMermaid(This)
		return oConv.Code()

		def ToMermaid()
			return This.Mermaid()

	#------------------
	#  WRITE TO FILE
	#------------------

	def WriteToFile(pcFileName)
		if right(pcFileName, 7) = "stzdiag"
			return This.WriteToStzDiagFile(pcFileName)

		but right(pcFileName, 3) = "dot"
			return This.WriteToDotFile(pcFileName)

		but right(pcFileName, 4) = "json"
			return This.WriteToJsonFile(pcFileName)

		but right(pcFileName, 3) = "mmd"
			return This.WriteToMermaidFile(pcFileName)

		else
			return 0
		ok

	def WriteToDiagFile(pcFileName)
		oConv = new stzDiagramToStzDiag(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

		def WriteToStzDiagFile(pcFileName)
			return This.WriteToDiagFile(pcFileName)

	def WriteToDotFile(pcFileName)
		oConv = new stzDiagramToDot(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

	def WriteToMermaidFile(pcFileName)
		oConv = new stzDiagramToMermaid(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

	def WriteToJsonFile(pcFileName)
		oConv = new stzDiagramToJson(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

#=====================================================
#  stzDiagramAnnotator - METADATA OVERLAY
#=====================================================

class stzDiagramAnnotator

	@cType = ""
	@aNodeData = []

	def init(pType)
		@cType = pType

	def Type()
		return @cType

	def Annotate(pNodeId, aData)
		if CheckParams()
			if isList(aData) and StzListQ(aData).IsWithNamedParam()
				aData = aData[2]
			ok
		ok

		@aNodeData[pNodeId] = aData

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

#=====================================================
#  stzDiagramValidators - PLUGGABLE VALIDATORS
#=====================================================

class stzDiagramValidator

	def init()
		@aValidators = []

	def ValidateDiagram(oDiagram, pcDomain)
		if HasKey($aDiagramValidators, pcDomain)
			oValidator = $aDiagramValidators[pcDomain]
			return oValidator.Validate(oDiagram)
		else
			return [
				:status = "error",
				:message = "No validator registered for domain: " + pcDomain
			]
		ok

	def Validators()
		return $aDiagramValidators


#=====================================================
#  stzDiagramSoxValidator - SARBANES-OXLEY
#=====================================================

class stzDiagramSoxValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Financial processes must have audit trail
		aFinancialNodes = This.NodesByProperty(oDiag, "domain", "financial")
		for cNodeId in aFinancialNodes
			aAnnPerf = oDiag.AnnotationsByType("performance")
			bHasAudit = 0

			for aAnnot in aAnnPerf
				aData = aAnnot.NodeData(cNodeId)
				if HasKey(aData, "audittrail")
					bHasAudit = 1
					exit
				ok
			end

			if NOT bHasAudit
				aIssues + "SOX-001: Financial process missing audit trail: " + cNodeId
			ok
		end

		# Rule 2: Payment/approval decisions must require approval
		aDec = This.NodesByType(oDiag, "decision")
		for cNodeId in aDec
			aNode = oDiag.Node(cNodeId)
			bHasApprovalReq = 0

			if aNode["properties"]["requiresApproval"] = 1
				bHasApprovalReq = 1
			ok

			if NOT bHasApprovalReq
				aIssues + "SOX-002: Decision node lacks approval requirement: " + cNodeId
			ok
		end

		# Rule 5: No cycles in financial workflow
		if oDiag.CyclicDependencies()
			aIssues + "SOX-005: Cyclic dependency detected in workflow"
		ok

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "sox",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByType(pDiag, pType)
		aFound = []
		for aNode in pDiag.Nodes()
			if aNode["properties"]["type"] = pType
				aFound + aNode["id"]
			ok
		end
		return aFound

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramGdprValidator - GDPR
#=====================================================

class stzDiagramGdprValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Personal data processing requires consent
		aDataNodes = This.NodesByProperty(oDiag, "dataType", "personal")
		for cNodeId in aDataNodes
			aNode = oDiag.Node(cNodeId)
			bHasConsent = 0

			if aNode["properties"]["requiresConsent"] = 1
				bHasConsent = 1
			ok

			if NOT bHasConsent
				aIssues + "GDPR-001: Personal data processing missing consent: " + cNodeId
			ok
		end

		# Rule 2: Data retention policy must be defined
		for cNodeId in aDataNodes
			aNode = oDiag.Node(cNodeId)
			bHasRetention = 0

			if aNode["properties"]["retentionPolicy"] != ""
				bHasRetention = 1
			ok

			if NOT bHasRetention
				aIssues + "GDPR-002: Data node missing retention policy: " + cNodeId
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "gdpr",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramBankingValidator - CUSTOM BANKING
#=====================================================

class stzDiagramBankingValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Large transactions require multi-level approval
		aLargeTransactions = This.NodesByProperty(oDiag, "transactionType", "large")
		for cNodeId in aLargeTransactions
			aIncoming = oDiag.Incoming(cNodeId)
			nApprovals = 0

			for cPrev in aIncoming
				oPrev = oDiag.Node(cPrev)
				if oPrev["properties"]["role"] = "approver"
					nApprovals += 1
				ok
			end

			if nApprovals < 2
				aIssues + "BANK-001: Large transaction requires 2+ approvals: " + cNodeId
			ok
		end

		# Rule 2: Fraud detection before payment
		aPaymentNodes = This.NodesByProperty(oDiag, "operation", "payment")
		for cNodeId in aPaymentNodes
			aIncoming = oDiag.Incoming(cNodeId)
			bHasFraudCheck = 0

			for cPrev in aIncoming
				aPrev = oDiag.Node(cPrev)
				if aPrev["properties"]["operation"] = "fraud_check"
					bHasFraudCheck = 1
					exit
				ok
			end

			if NOT bHasFraudCheck
				aIssues + "BANK-002: Payment missing fraud detection: " + cNodeId
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "banking",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramToStzDiag - NATIVE FORMAT
#=====================================================

class stzDiagramToStzDiag

	@oDiagram
	@cStzDiagCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		cOutput = ""

		cOutput += 'diagram "' +
			   @oDiagram.Id() + '"' + NL + NL

		cOutput += "metadata" + NL
		cOutput += "    theme: " + Lower(@oDiagram.Theme().Name()) + NL
		cOutput += "    layout: " + Lower(@oDiagram.Layout().Orientation()) + NL + NL

		cOutput += "nodes" + NL
		for aNode in @oDiagram.Nodes()

			cOutput += "    " + aNode["id"] + NL
			cOutput += "        label: " + This.EscapeString(aNode["label"]) + NL

			if aNode["properties"]["type"] != ""
				cOutput += "        type: " + Lower(aNode["properties"]["type"]) + NL
			ok

			if aNode["properties"]["color"] != ""
				cOutput += "        color: " + aNode["properties"]["color"] + NL
			ok

			cOutput += NL
		end

		if len(@oDiagram.Edges()) > 0
			cOutput += "edges" + NL

			for aEdge in @oDiagram.Edges()
				cOutput += "    " + aEdge["from"] + " -> " + aEdge["to"] + NL

				if aEdge["label"] != ""
					cOutput += "        label: " + This.EscapeString(aEdge["label"]) + NL
				ok

				cOutput += NL
			end

		ok

		if len(@oDiagram.Clusters()) > 0
			cOutput += "clusters" + NL

			for aCluster in @oDiagram.Clusters()
				cOutput += "    " + aCluster["id"] + NL
				cOutput += "        label: " + This.EscapeString(aCluster["label"]) + NL
				cNodeList = This.NodeListToString(aCluster["nodes"])
				cOutput += "        nodes: [" + cNodeList + "]" + NL
				cOutput += "        color: " + aCluster["color"] + NL
				cOutput += NL
			end
		ok

		if len(@oDiagram.Annotations()) > 0
			cOutput += "annotations" + NL
			for oAnnot in @oDiagram.Annotations()
				cOutput += "    " + Lower(oAnnot.Type()) + NL

				aAnnotData = oAnnot.NodesData()

				for cNodeId in Keys(aAnnotData)
					cData = aAnnotData[cNodeId]
					cOutput += "        " + String(cNodeId) + ": "
					cOutput += This.DataToString(cData) + NL
				end
				cOutput += NL
			end
		ok

		@cStzDiagCode = cOutput

	def stzdiag()
		return @cStzDiagCode

		def stzdiagCode()
			return @cStzDiagCode

		def Content()
			return @cStzDiagCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.stzdiag())
		fclose(oFile)
		return TRUE

	def EscapeString(pStr)
		return '"' +
			Replace(pStr, '"', '\"') + '"'

	def NodeListToString(aNodes)
		cResult = ""
		for cNode in aNodes
			cResult += cNode + ", "
		end
		if cResult != ""
			cResult = Left(cResult, len(cResult) - 2)
		ok
		return cResult

	def DataToString(aData)
		if NOT @IsHashList(aData)
			return "null"
		ok

		cResult = "{"
		for cKey in Keys(aData)
			cValue = aData[cKey]
			if isString(cValue)
				cResult += cKey + ": " + This.EscapeString(cValue) + ", "
			else
				cResult += cKey + ": " + String(cValue) + ", "
			ok
		end
		if cResult != "{"
			cResult = Left(cResult, len(cResult) - 2)
		ok
		cResult += "}"
		return cResult


#=====================================================
#  stzDiagramToDot - GRAPHVIZ DOT
#=====================================================

class stzDiagramToDot

	@oDiagram
	@cDotCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		cOutput = ""

		cOutput += 'digraph "' +
			   @oDiagram.Id() + '" {' + NL
		cOutput += "    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]" + NL
		cOutput += "    node [fontname=Helvetica]" + NL
		
		# Handle edge color
		cEdgeColor = @oDiagram.@cEdgeColor
		if cEdgeColor = "" or cEdgeColor = NULL
			cEdgeColor = "black"
		ok
		cOutput += "    edge [fontname=Helvetica, color=" + cEdgeColor + "]" + NL + NL

		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]
			cShape = "box"
			cStyle = "rounded,filled"
			cFillColor = "lightblue"
			cFontColor = "black"

			if aNode["properties"]["type"] != NULL
				cType = aNode["properties"]["type"]

				if cType = "process"
					cShape = "box"
					cStyle = "rounded,filled"

				but cType = "decision"
					cShape = "diamond"
					cStyle = "filled"

				but cType = "start"
					cShape = "ellipse"
					cStyle = "filled"

				but cType = "endpoint"
					cShape = "doublecircle"
					cStyle = "filled"

				but cType = "state"
					cShape = "circle"
					cStyle = "filled"

				but cType = "storage"
					cShape = "cylinder"
					cStyle = "filled"

				but cType = "data"
					cShape = "box"
					cStyle = "rounded,filled"

				but cType = "event"
					cShape = "ellipse"
					cStyle = "filled"
				ok
			ok

			# Resolve symbolic colors
			if aNode["properties"]["color"] != ""
				cFillColor = @oDiagram.ResolveColor(aNode["properties"]["color"])
				cFontColor = @oDiagram.ResolveFontColor(aNode["properties"]["color"])
			ok

			cOutput += '    ' + cNodeId +
				   ' [label="' +
				   cLabel + '", '

			cOutput += 'shape=' + cShape +
				   ', style="' +
				   cStyle + '", '

			cOutput += 'fillcolor="' +
				   cFillColor + '", '
			
			cOutput += 'fontcolor="' +
				   cFontColor + '"]' + NL
		end

		cOutput += NL

		for aEdge in @oDiagram.Edges()
			cOutput += '    ' + aEdge["from"] + ' -> ' + aEdge["to"]
			if aEdge["label"] != ""
				cOutput += ' [label="' +
					   aEdge["label"] + '"]'
			ok
			cOutput += NL
		end

		cOutput += NL + "}"

		@cDotCode = cOutput
	
	def DotCode()
		return @cDotCode

		def Code()
			return @cDotCode

		def Content()
			return @cDotCode


	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.DotCode())
		fclose(oFile)
		return TRUE

#=====================================================
#  stzDiagramToMermaid - MERMAID.JS
#=====================================================

class stzDiagramToMermaid

	@oDiagram
	@cMermaidCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		cOutput = "graph TD" + NL

		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]

			# Escape reserved Mermaid keywords
			cSafeNodeId = cNodeId
			if cNodeId = "end" or cNodeId = "start" or cNodeId = "subgraph"
				cSafeNodeId = "node_" + cNodeId
			ok

			cType = aNode["properties"]["type"]
			if cType = :start
				cOutput += '    ' + cSafeNodeId + '(["' +
					   cLabel + '"])' + NL

			but cType = :endpoint
				cOutput += '    ' + cSafeNodeId + '(["' +
					   cLabel + '"])' + NL

			but cType = :decision
				cOutput += '    ' + cSafeNodeId + '{{"' +
					   cLabel + '"}}' + NL

			but cType = :process
				cOutput += '    ' + cSafeNodeId + '["' +
					   cLabel + '"]' + NL

			else
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
			ok
		end

		cOutput += NL

		for aEdge in @oDiagram.Edges()
			cFromId = aEdge["from"]
			cToId = aEdge["to"]
			
			# Apply same escaping to edge references
			if cFromId = "end" or cFromId = "start" or cFromId = "subgraph"
				cFromId = "node_" + cFromId
			ok
			if cToId = "end" or cToId = "start" or cToId = "subgraph"
				cToId = "node_" + cToId
			ok
			
			cOutput += '    ' + cFromId + ' --> ' + cToId
			if aEdge["label"] != ""
				cOutput += ' |' + aEdge["label"] + '|'
			ok
			cOutput += NL
		end

		@cMermaidCode = cOutput

	def Code()
		return @cMermaidCode

		def MermaidCode()
			return @cMermaidCode

		def Content()
			return @cMermaidCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.Code())
		fclose(oFile)
		return TRUE

#=====================================================
#  stzDiagramToJSON - JSON FORMAT
#=====================================================

class stzDiagramToJSON

	@oDiagram
	@cJsonCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		aData = @oDiagram.ToHashlist()
		@cJsonCode = ToJSON(aData)

	def Json()
		return @cJsonCode

		def JsonCode()
			return @cJsonCode

		def Code()
			return @cJsonCode

		def Content()
			return @cJsonCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.JsonCode())
		fclose(oFile)
		return TRUE
