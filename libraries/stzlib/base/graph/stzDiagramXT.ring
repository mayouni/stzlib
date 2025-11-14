#=====================================================
#  VISUAL EXPRESSION LANGUAGE - Semantic Metadata to Visual Mapping
#=====================================================

#------------------
#  VISUAL MAPPINGS
#------------------

# Icon mappings for node tags
$aNodeIcons = [
	:security = "🔒",
	:database = "💾",
	:api = "🔌",
	:user = "👤",
	:error = "⚠️",
	:success = "✓",
	:warning = "⚡",
	:cloud = "☁",
	:mobile = "📱",
	:payment = "💳",
	:audit = "📋",
	:approval = "✓✓"
]

# Shape modifiers for metadata attributes
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
	:data_flow = [:arrowhead = "normal", :style = "solid", :label_position = "center"]
]

# Color gradients for numeric metadata (0-100 scale)
$aMetricColorGradients = [
	:performance = [
		[0, 50] = "#FF4444",   # Poor (red)
		[51, 75] = "#FFA500",  # Moderate (orange)
		[76, 100] = "#44FF44"  # Good (green)
	],
	:risk = [
		[0, 33] = "#44FF44",   # Low risk (green)
		[34, 66] = "#FFA500",  # Medium risk (orange)
		[67, 100] = "#FF4444"  # High risk (red)
	],
	:priority = [
		[0, 33] = "#CCCCCC",   # Low (gray)
		[34, 66] = "#4488FF",  # Medium (blue)
		[67, 100] = "#FF4444"  # High (red)
	]
]

# Badge positions for metadata labels
$aBadgePositions = [
	:top_left = "nw",
	:top_right = "ne",
	:bottom_left = "sw",
	:bottom_right = "se",
	:center = "c"
]

#------------------
#  VISUAL RULES
#------------------

class stzVisualRule
	@cRuleId
	@cConditionType  # :metadata_exists, :metadata_equals, :metadata_range, :tag_exists
	@aConditionParams
	@aVisualEffects  # List of [aspect, value] pairs
	
	def init(pcRuleId)
		@cRuleId = pcRuleId
		@aVisualEffects = []
	
	def WhenMetadataExists(pcKey)
		@cConditionType = :metadata_exists
		@aConditionParams = [pcKey]
		return This
	
	def WhenMetadataEquals(pcKey, pValue)
		@cConditionType = :metadata_equals
		@aConditionParams = [pcKey, pValue]
		return This
	
	def WhenMetadataInRange(pcKey, nMin, nMax)
		@cConditionType = :metadata_range
		@aConditionParams = [pcKey, nMin, nMax]
		return This
	
	def WhenTagExists(pcTag)
		@cConditionType = :tag_exists
		@aConditionParams = [pcTag]
		return This
	
	def ApplyColor(pColor)
		@aVisualEffects + [:color, pColor]
		return This
	
	def ApplyShape(pcShape)
		@aVisualEffects + [:shape, pcShape]
		return This
	
	def ApplyIcon(pcIcon)
		@aVisualEffects + [:icon, pcIcon]
		return This
	
	def ApplyBadge(pcText, pcPosition)
		@aVisualEffects + [:badge, [pcText, pcPosition]]
		return This
	
	def ApplyStyle(pcStyle)
		@aVisualEffects + [:style, pcStyle]
		return This
	
	def ApplyPenWidth(nWidth)
		@aVisualEffects + [:penwidth, nWidth]
		return This
	
	def Matches(aNodeOrEdge)
		switch @cConditionType
			on :metadata_exists
				cKey = @aConditionParams[1]
				return HasKey(aNodeOrEdge["metadata"], cKey)
			
			on :metadata_equals
				cKey = @aConditionParams[1]
				pValue = @aConditionParams[2]
				if HasKey(aNodeOrEdge["metadata"], cKey)
					return aNodeOrEdge["metadata"][cKey] = pValue
				ok
				return FALSE
			
			on :metadata_range
				cKey = @aConditionParams[1]
				nMin = @aConditionParams[2]
				nMax = @aConditionParams[3]
				if HasKey(aNodeOrEdge["metadata"], cKey)
					nValue = aNodeOrEdge["metadata"][cKey]
					return nValue >= nMin and nValue <= nMax
				ok
				return FALSE
			
			on :tag_exists
				cTag = @aConditionParams[1]
				if HasKey(aNodeOrEdge, "tags")
					return ring_find(aNodeOrEdge["tags"], cTag) > 0
				ok
				return FALSE
		off
		
		return FALSE
	
	def Effects()
		return @aVisualEffects

#------------------
#  ENHANCED DIAGRAM
#------------------

class stzDiagramXT from stzDiagram
	@aVisualRules = []
	@aMetadataKeys = []  # Track all metadata keys used
	
	def AddVisualRule(oRule)
		@aVisualRules + oRule
		return This
	
	def AddNodeWithMetadata(pNodeId, pLabel, pType, pColor, aMetadata, aTags)
		This.AddNodeXT(pNodeId, pLabel, pType, pColor)
		
		# Ensure metadata is a hashlist
		if NOT isList(aMetadata)
			aMetadata = []
		ok
		
		# Store metadata
		oNode = This.Node(pNodeId)
		if NOT HasKey(oNode, "metadata")
			oNode["metadata"] = []
		ok
		oNode["metadata"] = aMetadata
		oNode["tags"] = aTags
		
		# Track metadata keys
		if @IsHashList(aMetadata)
			for i = 1 to len(aMetadata) step 2
				cKey = aMetadata[i]
				if NOT ring_find(@aMetadataKeys, cKey)
					@aMetadataKeys + cKey
				ok
			end
		ok
	
	def AddEdgeWithMetadata(pFromId, pToId, pLabel, aMetadata, aTags)
		# First add the edge using parent method
		This.ConnectXT(pFromId, pToId, pLabel)
		
		# Find the edge we just added and enhance it with metadata
		aEdges = This.Edges()
		for i = 1 to len(aEdges)
			aEdge = aEdges[i]
			if aEdge["from"] = pFromId and aEdge["to"] = pToId
				# Ensure the label is stored as a clean string
				if aEdge["label"] = NULL or NOT isString(aEdge["label"])
					aEdge["label"] = ""
				ok
				
				# Initialize metadata and tags
				if NOT HasKey(aEdge, "metadata")
					aEdge["metadata"] = []
				ok
				aEdge["metadata"] = aMetadata
				
				if NOT HasKey(aEdge, "tags")
					aEdge["tags"] = []
				ok
				aEdge["tags"] = aTags
				
				exit
			ok
		end
	
	def Dot()
		# Use enhanced DOT converter for stzDiagramXT
		oConv = new stzDiagramXTToDot(This)
		cResult = oConv.Code()
		return cResult
		
		def ToDot()
			return This.Dot()
		
		def DotCode()
			return This.Dot()
		
		def Code()
			return This.Dot()
	
	def ApplyVisualRules()
		# Apply rules to nodes
		for aNode in This.Nodes()
			if NOT HasKey(aNode, "metadata")
				aNode["metadata"] = []
			ok
			if NOT HasKey(aNode, "tags")
				aNode["tags"] = []
			ok
			
			for oRule in @aVisualRules
				if oRule.Matches(aNode)
					aEffects = oRule.Effects()
					for aEffect in aEffects
						cAspect = aEffect[1]
						pValue = aEffect[2]
						
						switch cAspect
							on :color
								aNode["properties"]["color"] = pValue
							
							on :shape
								aNode["properties"]["shape"] = pValue
							
							on :icon
								aNode["properties"]["icon"] = pValue
							
							on :badge
								if NOT HasKey(aNode["properties"], "badges")
									aNode["properties"]["badges"] = []
								ok
								aNode["properties"]["badges"] + pValue
							
							on :style
								aNode["properties"]["style"] = pValue
							
							on :penwidth
								aNode["properties"]["penwidth"] = pValue
						off
					end
				ok
			end
		end
		
		# Apply rules to edges
		for aEdge in This.Edges()
			if NOT HasKey(aEdge, "metadata")
				aEdge["metadata"] = []
			ok
			if NOT HasKey(aEdge, "tags")
				aEdge["tags"] = []
			ok
			
			for oRule in @aVisualRules
				if oRule.Matches(aEdge)
					aEffects = oRule.Effects()
					for aEffect in aEffects
						cAspect = aEffect[1]
						pValue = aEffect[2]
						
						if NOT HasKey(aEdge, "properties")
							aEdge["properties"] = []
						ok
						
						# Don't overwrite the label!
						if cAspect != "label"
							aEdge["properties"][cAspect] = pValue
						ok
					end
				ok
			end
		end
	
	def MetadataLegend()
		# Generate legend showing metadata-to-visual mappings
		aLegend = []
		
		aLegend + "=== METADATA LEGEND ==="
		aLegend + ""
		
		for oRule in @aVisualRules
			cDesc = "When: " + oRule.@cConditionType
			aLegend + cDesc
			
			aEffects = oRule.Effects()
			for aEffect in aEffects
				aLegend + "  → " + aEffect[1] + ": " + aEffect[2]
			end
			aLegend + ""
		end
		
		return aLegend

#------------------
#  ENHANCED DOT CONVERTER
#------------------

class stzDiagramXTToDot from stzDiagramToDot
	
	def init(poDiagram)
		cClassName = lower(ring_classname(poDiagram))
		if NOT (isObject(poDiagram) and (cClassName = "stzdiagram" or cClassName = "stzdiagramxt"))
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram or stzDiagramXT object.")
		ok
		@oDiagram = poDiagram
		This._Generate()
	
	def _Generate()
		# Apply visual rules first
		@oDiagram.ApplyVisualRules()
		
		# Generate DOT with enhanced visual features
		cOutput = ""
		cTheme = lower(@oDiagram.@cTheme)
		
		cOutput += 'digraph "' + @oDiagram.Id() + '" {' + NL
		
		# Standard graph attributes
		cRankDir = This.GetRankDir()
		cFont = @oDiagram.@cFont
		if cFont = "" or cFont = NULL
			cFont = "helvetica"
		ok
		nFontSize = @oDiagram.@nFontSize
		if nFontSize = 0 or nFontSize = NULL
			nFontSize = 12
		ok
		
		cOutput += "    graph [rankdir=" + cRankDir + ", bgcolor=white, fontname=" + cFont + ", fontsize=" + nFontSize + "]" + NL
		cOutput += "    node [fontname=" + cFont + ", fontsize=" + nFontSize + "]" + NL
		cOutput += "    edge [fontname=" + cFont + ", fontsize=" + nFontSize + "]" + NL + NL
		
		# Generate nodes with visual enhancements (inlined to apply rules properly)
		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]
			
			# Add icon prefix if present
			if HasKey(aNode["properties"], "icon")
				cLabel = aNode["properties"]["icon"] + " " + cLabel
			ok
			
			# Add badges if present
			if HasKey(aNode["properties"], "badges")
				for aBadge in aNode["properties"]["badges"]
					cBadgeText = aBadge[1]
					cLabel += "\n[" + cBadgeText + "]"
				end
			ok
			
			# Determine shape from type
			cShape = "box"
			cType = lower("" + aNode["properties"]["type"])
			if cType = "process"
				cShape = "box"
			but cType = "decision"
				cShape = "diamond"
			but cType = "start"
				cShape = "ellipse"
			but cType = "endpoint"
				cShape = "doublecircle"
			but cType = "state"
				cShape = "circle"
			but cType = "storage"
				cShape = "cylinder"
			ok
			
			# Override shape if specified in properties
			if HasKey(aNode["properties"], "shape")
				cShape = aNode["properties"]["shape"]
			ok
			
			# Determine style
			cStyle = "rounded,filled"
			if HasKey(aNode["properties"], "style")
				cStyle = aNode["properties"]["style"]
			ok
			
			# Resolve colors
			cFillColor = @oDiagram.ResolveColor(aNode["properties"]["color"])
			
			# Handle gray/print themes
			if cTheme = "gray"
				cFillColor = @oDiagram.ConvertColorTogray(cFillColor)
			ok
			if cTheme = "print"
				cFillColor = "white"
			ok
			
			cFontColor = @oDiagram.ResolveFontColor(aNode["properties"]["color"])
			
			# Build node declaration
			cNodeLine = '    ' + cNodeId + ' [label="' + cLabel + '", '
			cNodeLine += 'shape=' + cShape + ', style="' + cStyle + '", '
			cNodeLine += 'fillcolor="' + cFillColor + '", '
			cNodeLine += 'fontcolor="' + cFontColor + '"'
			
			# Add penwidth if specified
			if HasKey(aNode["properties"], "penwidth")
				cNodeLine += ', penwidth=' + aNode["properties"]["penwidth"]
			ok
			
			# Add stroke color for themes or custom
			if @oDiagram.@cNodeStrokeColor != ""
				cNodeLine += ', color="' + @oDiagram.@cNodeStrokeColor + '"'
			but cTheme = "print" or cTheme = "gray"
				cNodeLine += ', color="black", penwidth=2'
			ok
			
			cNodeLine += ']'
			cOutput += cNodeLine + NL
		end
		
		cOutput += NL
		
		# Generate edges with visual enhancements (inlined to avoid method resolution issues)
		for aEdge in @oDiagram.Edges()
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			cEdgeLine = '    ' + cFrom + ' -> ' + cTo
			
			aAttrs = []
			
			# Add label with spacing fix for TB layout
			if HasKey(aEdge, "label")
				cLabel = aEdge["label"]
				if cLabel != "" and cLabel != NULL
					# Add leading space for top-down layout to fix visual alignment
					cLabelText = iff(cRankDir = "TB", " ", "") + cLabel
					cLabelAttr = 'label="' + cLabelText + '"'
					aAttrs + cLabelAttr
				ok
			ok
			
			# Add properties-based attributes
			if HasKey(aEdge, "properties") and @IsHashList(aEdge["properties"])
				if HasKey(aEdge["properties"], "style")
					aAttrs + ('style="' + aEdge["properties"]["style"] + '"')
				ok
				if HasKey(aEdge["properties"], "arrowhead")
					aAttrs + ('arrowhead=' + aEdge["properties"]["arrowhead"])
				ok
				if HasKey(aEdge["properties"], "color")
					aAttrs + ('color="' + aEdge["properties"]["color"] + '"')
				ok
				if HasKey(aEdge["properties"], "penwidth")
					aAttrs + ('penwidth=' + aEdge["properties"]["penwidth"])
				ok
			ok
			
			# Build final attributes string
			if len(aAttrs) > 0
				cEdgeLine += ' ['
				for i = 1 to len(aAttrs)
					cEdgeLine += aAttrs[i]
					if i < len(aAttrs)
						cEdgeLine += ', '
					ok
				end
				cEdgeLine += ']'
			ok
			
			cOutput += cEdgeLine + NL
		end
		
		cOutput += NL + "}"
		
		@cDotCode = cOutput
	
	def GenerateEnhancedNode(aNode)
		cNodeId = aNode["id"]
		cLabel = aNode["label"]
		
		# Build label with icon and badges
		if HasKey(aNode["properties"], "icon")
			cLabel = aNode["properties"]["icon"] + " " + cLabel
		ok
		
		if HasKey(aNode["properties"], "badges")
			for aBadge in aNode["properties"]["badges"]
				cBadgeText = aBadge[1]
				cLabel += "\n[" + cBadgeText + "]"
			end
		ok
		
		# Base attributes
		cShape = "box"
		cStyle = "rounded,filled"
		cFillColor = @oDiagram.ResolveColor(aNode["properties"]["color"])
		cFontColor = @oDiagram.ResolveFontColor(aNode["properties"]["color"])
		
		# Override with rule-based attributes
		if HasKey(aNode["properties"], "shape")
			cShape = aNode["properties"]["shape"]
		ok
		
		if HasKey(aNode["properties"], "style")
			cStyle = aNode["properties"]["style"]
		ok
		
		# Build DOT node declaration
		cOutput = '    ' + cNodeId + ' [label="' + cLabel + '", '
		cOutput += 'shape=' + cShape + ', style="' + cStyle + '", '
		cOutput += 'fillcolor="' + cFillColor + '", '
		cOutput += 'fontcolor="' + cFontColor + '"'
		
		if HasKey(aNode["properties"], "penwidth")
			cOutput += ', penwidth=' + aNode["properties"]["penwidth"]
		ok
		
		cOutput += ']'
		
		return cOutput
	
	def GenerateEnhancedEdge(aEdge)
		cOutput = '    ' + aEdge["from"] + ' -> ' + aEdge["to"]
		
		aAttrs = []
		
		# Add label if present - extract as clean string
		if HasKey(aEdge, "label")
			cLabel = "" + aEdge["label"]  # Force string conversion
			cLabel = @trim(cLabel)
			
			if cLabel != "" and cLabel != "NULL"
				aAttrs + 'label="' + cLabel + '"'
			ok
		ok
		
		# Add properties-based attributes
		if HasKey(aEdge, "properties") and isList(aEdge["properties"])
			if HasKey(aEdge["properties"], "style")
				aAttrs + 'style="' + aEdge["properties"]["style"] + '"'
			ok
			
			if HasKey(aEdge["properties"], "arrowhead")
				aAttrs + 'arrowhead=' + aEdge["properties"]["arrowhead"]
			ok
			
			if HasKey(aEdge["properties"], "color")
				aAttrs + 'color="' + aEdge["properties"]["color"] + '"'
			ok
			
			if HasKey(aEdge["properties"], "penwidth")
				aAttrs + 'penwidth=' + aEdge["properties"]["penwidth"]
			ok
		ok
		
		# Build final attribute string
		if len(aAttrs) > 0
			cOutput += ' ['
			for i = 1 to len(aAttrs)
				cOutput += aAttrs[i]
				if i < len(aAttrs)
					cOutput += ', '
				ok
			end
			cOutput += ']'
		ok
		
		return cOutput
	
	def GetRankDir()
		cLayout = lower(@oDiagram.@cLayout)
		
		if cLayout = "topdown" or ring_find($acLayouts[:TopDown], cLayout)
			return "TB"
		but cLayout = "bottomup" or ring_find($acLayouts[:BottomUp], cLayout)
			return "BT"
		but cLayout = "leftright" or ring_find($acLayouts[:LeftRight], cLayout)
			return "LR"
		but cLayout = "rightleft" or ring_find($acLayouts[:RightLeft], cLayout)
			return "RL"
		ok
		
		return "TB"

#=====================================================
#  USAGE EXAMPLES
#=====================================================

/*---  Example 1: Security Risk Visualization

oDiag = new stzDiagramXT("SecurityFlow")

# Define visual rules based on metadata
oHighRiskRule = new stzVisualRule("high_risk")
oHighRiskRule.WhenMetadataInRange("risk_score", 70, 100).
	      ApplyColor("#FF4444").
	      ApplyPenWidth(3).
	      ApplyIcon("⚠️")

oSecureRule = new stzVisualRule("secure")
oSecureRule.WhenTagExists(:security).
	    ApplyIcon("🔒").
	    ApplyBadge("SEC", :top_right)

oDiag.AddVisualRule(oHighRiskRule)
oDiag.AddVisualRule(oSecureRule)

# Add nodes with metadata
oDiag.AddNodeWithMetadata("auth", "Authentication", :Process, :Primary,
	["risk_score" = 85, "sla_ms" = 100],
	[:security, :critical])

oDiag.AddNodeWithMetadata("db", "Database", :Storage, :Info,
	["risk_score" = 45, "encrypted" = TRUE],
	[:security])

oDiag.AddEdgeWithMetadata("auth", "db", "query",
	["type" = :requires],
	[:data_flow])

oDiag.View()

---*/

/*---  Example 2: Performance Monitoring

oDiag = new stzDiagramXT("APIFlow")

# Performance-based coloring
oSlowRule = new stzVisualRule("slow_api")
oSlowRule.WhenMetadataInRange("latency_ms", 500, 9999).
	  ApplyColor("#FFA500").
	  ApplyBadge("SLOW", :bottom_right)

oFastRule = new stzVisualRule("fast_api")
oFastRule.WhenMetadataInRange("latency_ms", 0, 100).
	  ApplyColor("#44FF44").
	  ApplyIcon("⚡")

oDiag.AddVisualRule(oSlowRule)
oDiag.AddVisualRule(oFastRule)

oDiag.AddNodeWithMetadata("api1", "User API", :Process, :Primary,
	["latency_ms" = 50, "throughput" = 1000], [:api])

oDiag.AddNodeWithMetadata("api2", "Payment API", :Process, :Primary,
	["latency_ms" = 800, "throughput" = 100], [:api, :critical])

oDiag.View()

---*/

/*---  Example 3: Compliance Tagging

oDiag = new stzDiagramXT("DataFlow")

# GDPR compliance visualization
oGdprRule = new stzVisualRule("gdpr")
oGdprRule.WhenTagExists(:gdpr).
	  ApplyIcon("🇪🇺").
	  ApplyBadge("GDPR", :top_left).
	  ApplyPenWidth(2)

# PCI-DSS compliance
oPciRule = new stzVisualRule("pci")
oPciRule.WhenTagExists(:pci).
	 ApplyIcon("💳").
	 ApplyColor("#0066CC")

oDiag.AddVisualRule(oGdprRule)
oDiag.AddVisualRule(oPciRule)

oDiag.AddNodeWithMetadata("collect", "Data Collection", :Process, :Info,
	["retention_days" = 90], [:gdpr])

oDiag.AddNodeWithMetadata("payment", "Payment Processing", :Process, :Warning,
	["encryption" = TRUE], [:pci, :critical])

oDiag.View()

---*/
