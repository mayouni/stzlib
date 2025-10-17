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

class stzDiagram from stzGraph

	@cTheme = :Light
	@cLayout = :TopDown
	@aClusters = []
	@aAnnotations = []
	@aTemplates = []
	@cEdgeColor = "black"
	@cNodeStrokeColor = ""
	@aPalette = []
	@aFontColors = []

	def init(pTitle)
		super.init(pTitle)
		@cTheme = :Light
		@cLayout = :TopDown
		@aClusters = []
		@aAnnotations = []
		@aTemplates = []
		@cEdgeColor = "black"
		@cNodeStrokeColor = ""
		this.SetupTheme(:Light)

	def SetupTheme(pTheme)
		@cTheme = pTheme
		@aPalette = [
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

		@aFontColors = [
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

	def SetTheme(pTheme)
		this.SetupTheme(pTheme)

	def SetLayout(pLayout)
		@cLayout = pLayout

	def SetEdgeColor(pColor)
		@cEdgeColor = pColor

	def SetNodeStrokeColor(pColor)
		@cNodeStrokeColor = pColor

	#------------------------------------------
	#  DIAGRAM-SPECIFIC NODE OPERATIONS
	#------------------------------------------

	def AddDiagramNode(pNodeId, pLabel, pType, pColor)
		this.AddNode(pNodeId, pLabel, [
			"type" = pType,
			"color" = pColor
		])

	def Connect(pFromId, pToId, pLabel)
		this.AddEdge(pFromId, pToId, pLabel, [])

	#------------------------------------------
	#  CLUSTER OPERATIONS
	#------------------------------------------

	def AddCluster(pClusterId, pLabel, aNodeIds, pColor)
		oCluster = [
			"id" = pClusterId,
			"label" = pLabel,
			"nodes" = aNodeIds,
			"color" = pColor
		]
		@aClusters + oCluster

	def AllClusters()
		return @aClusters

	#------------------------------------------
	#  ANNOTATION OPERATIONS
	#------------------------------------------

	def AddAnnotation(oAnnotation)
		@aAnnotations + oAnnotation

	def AnnotationsByType(pType)
		aFiltered = []
		for oAnn in @aAnnotations
			if oAnn["type"] = pType
				aFiltered + oAnn
			ok
		end
		return aFiltered

	def AllAnnotations()
		return @aAnnotations

	#------------------------------------------
	#  TEMPLATE OPERATIONS
	#------------------------------------------

	def AddTemplate(oTemplate)
		@aTemplates + oTemplate

	def ApplyTemplates()
		for oTemplate in @aTemplates
			oTemplate.Apply(this)
		end

	#------------------------------------------
	#  VALIDATION
	#------------------------------------------

	def ValidateDAG()
		return NOT this.CyclicDependencies()

	def ValidateReachability()
		aStartNodes = []
		aEndpointNodes = []

		for oNode in this.AllNodes()
			if oNode["properties"]["type"] = :Start
				aStartNodes + oNode["id"]
			ok
			if oNode["properties"]["type"] = :Endpoint
				aEndpointNodes + oNode["id"]
			ok
		end

		for cEndpoint in aEndpointNodes
			bReachable = 0
			for cStart in aStartNodes
				if this.PathExists(cStart, cEndpoint)
					bReachable = 1
					exit
				ok
			end
			if NOT bReachable
				return ["status" = :fail, "issue" = "Endpoint unreachable: " + cEndpoint]
			ok
		end

		return ["status" = :pass]

	def ValidateCompleteness()
		aIssues = []

		for oNode in this.AllNodes()
			if oNode["properties"]["type"] = :Decision
				aNeighbors = this.Neighbors(oNode["id"])
				if len(aNeighbors) < 2
					aIssues + "Decision node has fewer than 2 paths: " + oNode["id"]
				ok
			ok
		end

		return ["status" = iif(len(aIssues) = 0, :pass, :fail), "issues" = aIssues]

	#------------------------------------------
	#  METRICS
	#------------------------------------------

	def ComputeMetrics()
		aMetrics = []
		aAllPaths = []

		for oNode in this.AllNodes()
			aReachable = this.ReachableFrom(oNode["id"])
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

		aMetrics["avgPathLength"] = nAvg
		aMetrics["maxPathLength"] = nMax
		aMetrics["bottlenecks"] = this.BottleneckNodes()
		aMetrics["density"] = this.NodeDensity()
		aMetrics["nodeCount"] = this.NodeCount()
		aMetrics["edgeCount"] = this.EdgeCount()

		return aMetrics

	#------------------------------------------
	#  EXPORT TO HASHLIST
	#------------------------------------------

	def ToHashlist()
		oBase = super.ToHashlist()
		oBase["theme"] = @cTheme
		oBase["layout"] = @cLayout
		oBase["clusters"] = @aClusters
		oBase["annotations"] = @aAnnotations
		oBase["templates"] = @aTemplates
		return oBase

#=====================================================
#  stzDiagramAnnotator - METADATA OVERLAY
#=====================================================

class stzDiagramAnnotator

	@cType = ""
	@aNodeData = []

	def init(pType)
		@cType = pType
		@aNodeData = []

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
		if @aNodeData[pNodeId] != ""
			return @aNodeData[pNodeId]
		ok
		return ""

	def AllNodeData()
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
		if HasKey(@aDiagramValidators, pcDomain)
			oValidator = @aValidators[pcDomain]
			return oValidator.Validate(oDiagram)
		else
			return [ :status = "error", :message = "No validator registered for domain: " + pDomain]
		ok

	def Validators()
		return @aDiagramValidators


#=====================================================
#  stzDiagramSoxValidator - SARBANES-OXLEY
#=====================================================

class stzDiagramSoxValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Financial processes must have audit trail
		aFinancialNodes = this.FindNodesByProperty(oDiag, "domain", :financial)
		for cNodeId in aFinancialNodes
			aAnnPerf = oDiag.AnnotationsByType(:Performance)
			bHasAudit = 0

			for oAnn in aAnnPerf
				oData = oAnn.NodeData(cNodeId)
				if oData != ""
					if oData["auditTrail"] != ""
						bHasAudit = 1
						exit
					ok
				ok
			end

			if NOT bHasAudit
				aIssues + "SOX-001: Financial process missing audit trail: " + cNodeId
			ok
		end

		# Rule 2: Payment/approval decisions must require approval
		aDec = this.FindNodesByType(oDiag, :Decision)
		for cNodeId in aDec
			oNode = oDiag.Node(cNodeId)
			bHasApprovalReq = 0

			if oNode["properties"]["requiresApproval"] = 1
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
			"status" = iif(len(aIssues) = 0, :pass, :fail),
			"domain" = :SOX,
			"issueCount" = len(aIssues),
			"issues" = aIssues
		]

	def FindNodesByType(pDiag, pType)
		aFound = []
		for oNode in pDiag.AllNodes()
			if oNode["properties"]["type"] = pType
				aFound + oNode["id"]
			ok
		end
		return aFound

	def FindNodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for oNode in pDiag.AllNodes()
			if oNode["properties"][pProperty] = pValue
				aFound + oNode["id"]
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
		aDataNodes = this.FindNodesByProperty(oDiag, "dataType", :personal)
		for cNodeId in aDataNodes
			oNode = oDiag.Node(cNodeId)
			bHasConsent = 0

			if oNode["properties"]["requiresConsent"] = 1
				bHasConsent = 1
			ok

			if NOT bHasConsent
				aIssues + "GDPR-001: Personal data processing missing consent: " + cNodeId
			ok
		end

		# Rule 2: Data retention policy must be defined
		for cNodeId in aDataNodes
			oNode = oDiag.Node(cNodeId)
			bHasRetention = 0

			if oNode["properties"]["retentionPolicy"] != ""
				bHasRetention = 1
			ok

			if NOT bHasRetention
				aIssues + "GDPR-002: Data node missing retention policy: " + cNodeId
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, :pass, :fail),
			:domain = :GDPR,
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def FindNodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for oNode in pDiag.AllNodes()
			if oNode["properties"][pProperty] = pValue
				aFound + oNode["id"]
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
		aLargeTransactions = this.FindNodesByProperty(oDiag, "transactionType", :large)
		for cNodeId in aLargeTransactions
			aIncoming = oDiag.Incoming(cNodeId)
			nApprovals = 0

			for cPrev in aIncoming
				oPrev = oDiag.Node(cPrev)
				if oPrev["properties"]["role"] = :approver
					nApprovals += 1
				ok
			end

			if nApprovals < 2
				aIssues + "BANK-001: Large transaction requires 2+ approvals: " + cNodeId
			ok
		end

		# Rule 2: Fraud detection before payment
		aPaymentNodes = this.FindNodesByProperty(oDiag, "operation", :payment)
		for cNodeId in aPaymentNodes
			aIncoming = oDiag.Incoming(cNodeId)
			bHasFraudCheck = 0

			for cPrev in aIncoming
				oPrev = oDiag.Node(cPrev)
				if oPrev["properties"]["operation"] = :fraud_check
					bHasFraudCheck = 1
					exit
				ok
			end

			if NOT bHasFraudCheck
				aIssues + "BANK-002: Payment missing fraud detection: " + cNodeId
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, :pass, :fail),
			:domain = :Banking,
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def FindNodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for oNode in pDiag.AllNodes()
			if oNode["properties"][pProperty] = pValue
				aFound + oNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramToStzDiag - NATIVE FORMAT
#=====================================================

class stzDiagramToStzDiag

	@oDiagram = NULL

	def init(pDiagram)
		if pDiagram != NULL
			@oDiagram = pDiagram
		ok

	def Generate()
		cOutput = ""

		cOutput += 'diagram "' + @oDiagram.Id() + '"' + NL + NL

		cOutput += "metadata" + NL
		cOutput += "    theme: " + Lower(String(@oDiagram.@cTheme)) + NL
		cOutput += "    layout: " + Lower(String(@oDiagram.@cLayout)) + NL + NL

		cOutput += "nodes" + NL
		for oNode in @oDiagram.AllNodes()
			cOutput += "    " + oNode["id"] + NL
			cOutput += "        label: " + this.EscapeString(oNode["label"]) + NL
			if oNode["properties"]["type"] != NULL
				cOutput += "        type: " + Lower(String(oNode["properties"]["type"])) + NL
			ok
			if oNode["properties"]["color"] != NULL
				cOutput += "        color: " + oNode["properties"]["color"] + NL
			ok
			cOutput += NL
		end

		if len(@oDiagram.AllEdges()) > 0
			cOutput += "edges" + NL
			for oEdge in @oDiagram.AllEdges()
				cOutput += "    " + oEdge["from"] + " -> " + oEdge["to"] + NL
				if oEdge["label"] != ""
					cOutput += "        label: " + this.EscapeString(oEdge["label"]) + NL
				ok
				cOutput += NL
			end
		ok

		if len(@oDiagram.AllClusters()) > 0
			cOutput += "clusters" + NL
			for oCluster in @oDiagram.AllClusters()
				cOutput += "    " + oCluster["id"] + NL
				cOutput += "        label: " + this.EscapeString(oCluster["label"]) + NL
				cNodeList = this.NodeListToString(oCluster["nodes"])
				cOutput += "        nodes: [" + cNodeList + "]" + NL
				cOutput += "        color: " + oCluster["color"] + NL
				cOutput += NL
			end
		ok

		if len(@oDiagram.AllAnnotations()) > 0
			cOutput += "annotations" + NL
			for oAnn in @oDiagram.AllAnnotations()
				cOutput += "    " + Lower(String(oAnn["type"])) + NL
				for cNodeId in this.HashlistKeys(oAnn["nodeData"])
					cData = oAnn["nodeData"][cNodeId]
					cOutput += "        " + cNodeId + ": "
					cOutput += this.DataToString(cData) + NL
				end
				cOutput += NL
			end
		ok

		return cOutput

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, this.Generate())
		fclose(oFile)
		return TRUE

	def EscapeString(pStr)
		return '"' + Replace(pStr, '"', '\"') + '"'

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
		cResult = "{"
		for cKey in this.HashlistKeys(aData)
			cValue = aData[cKey]
			if isString(cValue)
				cResult += cKey + ": " + this.EscapeString(cValue) + ", "
			else
				cResult += cKey + ": " + String(cValue) + ", "
			ok
		end
		if cResult != "{"
			cResult = Left(cResult, len(cResult) - 2)
		ok
		cResult += "}"
		return cResult

	def HashlistKeys(aHashlist)
		aKeys = []
		for cKey in aHashlist
			aKeys + cKey
		end
		return aKeys

#=====================================================
#  stzDiagramToDot - GRAPHVIZ DOT
#=====================================================

class stzDiagramToDot

	@oDiagram = NULL

	def init(pDiagram)
		@oDiagram = pDiagram

	def Generate()
		cOutput = ""

		cOutput += 'digraph "' + @oDiagram.Id() + '" {' + NL
		cOutput += "    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]" + NL
		cOutput += "    node [fontname=Helvetica]" + NL
		cOutput += "    edge [fontname=Helvetica, color=" + @oDiagram.@cEdgeColor + "]" + NL + NL

		for oNode in @oDiagram.AllNodes()
			cNodeId = oNode["id"]
			cLabel = oNode["label"]
			cShape = "box"
			cStyle = "rounded,filled"
			cFillColor = "lightblue"

			if oNode["properties"]["type"] != NULL
				cType = oNode["properties"]["type"]
				if cType = :process
					cShape = "box"
					cStyle = "rounded,filled"
				but cType = :decision
					cShape = "diamond"
					cStyle = "filled"
				but cType = :start
					cShape = "polygon"
					cStyle = "filled"
				but cType = :endpoint
					cShape = "doublecircle"
					cStyle = "filled"
				but cType = :state
					cShape = "circle"
					cStyle = "filled"
				but cType = :storage
					cShape = "cylinder"
					cStyle = "filled"
				but cType = :data
					cShape = "box"
					cStyle = "rounded,filled"
				but cType = :event
					cShape = "ellipse"
					cStyle = "filled"
				ok
			ok

			if oNode["properties"]["color"] != NULL
				cFillColor = oNode["properties"]["color"]
			ok

			cOutput += '    ' + cNodeId + ' [label="' + cLabel + '", '
			cOutput += 'shape=' + cShape + ', style="' + cStyle + '", '
			cOutput += 'fillcolor="' + cFillColor + '"]' + NL
		end

		cOutput += NL

		for oEdge in @oDiagram.AllEdges()
			cOutput += '    ' + oEdge["from"] + ' -> ' + oEdge["to"]
			if oEdge["label"] != ""
				cOutput += ' [label="' + oEdge["label"] + '"]'
			ok
			cOutput += NL
		end

		cOutput += NL + "}" + NL

		return cOutput

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, this.Generate())
		fclose(oFile)
		return TRUE

#=====================================================
#  stzDiagramToMermaid - MERMAID.JS
#=====================================================

class stzDiagramToMermaid

	@oDiagram = NULL

	def init(pDiagram)
		@oDiagram = pDiagram

	def Generate()
		cOutput = "graph TD" + NL

		for oNode in @oDiagram.AllNodes()
			cNodeId = oNode["id"]
			cLabel = oNode["label"]

			cType = oNode["properties"]["type"]
			if cType = :start
				cOutput += '    ' + cNodeId + '(["' + cLabel + '"])' + NL
			but cType = :endpoint
				cOutput += '    ' + cNodeId + '([" ' + cLabel + ' "])' + NL
			but cType = :decision
				cOutput += '    ' + cNodeId + '{{"' + cLabel + '"}}' + NL
			but cType = :process
				cOutput += '    ' + cNodeId + '[["' + cLabel + '"]]' + NL
			otherwise
				cOutput += '    ' + cNodeId + '["' + cLabel + '"]' + NL
			ok
		end

		cOutput += NL

		for oEdge in @oDiagram.AllEdges()
			cOutput += '    ' + oEdge["from"] + ' --> ' + oEdge["to"]
			if oEdge["label"] != ""
				cOutput += ' |' + oEdge["label"] + '|'
			ok
			cOutput += NL
		end

		return cOutput

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, this.Generate())
		fclose(oFile)
		return TRUE

#=====================================================
#  stzDiagramToJSON - JSON FORMAT
#=====================================================

class stzDiagramToJSON

	@oDiagram = NULL

	def init(pDiagram)
		@oDiagram = pDiagram

	def Generate()
		oData = @oDiagram.ToHashlist()
		return this.ToJSON(oData)

	def ToJSON(pValue)
		if pValue = NULL
			return "null"
		ok

		if isList(pValue)
			cResult = "{"
			for cKey in this.HashlistKeys(pValue)
				cResult += '"' + cKey + '": ' + this.ToJSON(pValue[cKey]) + ", "
			end
			if cResult != "{"
				cResult = Left(cResult, len(cResult) - 2)
			ok
			return cResult + "}"
		ok

		if isString(pValue)
			return '"' + Replace(pValue, '"', '\"') + '"'
		ok

		return String(pValue)

	def HashlistKeys(aHashlist)
		aKeys = []
		for cKey in aHashlist
			aKeys + cKey
		end
		return aKeys

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, this.Generate())
		fclose(oFile)
		return TRUE
