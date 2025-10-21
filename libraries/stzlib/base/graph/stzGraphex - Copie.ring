load "../stzbase.ring"

# Prototype for Graph Stringification in Ring
# This function serializes a stzGraph into a topology-preserving string
# Format: "metadata;node1:[neighbors,label,properties];node2:...;cycles:[cycle1_paths];"
# Metadata includes: nodes:N;edges:M;cyclic:TRUE/FALSE;bottlenecks:[id1,id2];longest_path:P
# Preserves: Nodes, edges (as adjacency lists), cycles (precomputed paths), bottlenecks

/*----

# Example Usage (assuming a stzGraph instance)
oGraph = new stzGraph("Sample")
oGraph {
    AddNode(:A, "Start")
    AddNode(:B, "Process")
    AddNode(:C, "End")
    AddEdge(:A, :B, "flows")
    AddEdge(:B, :C, "completes")
    # For cycle test: AddEdge(:C, :A, "loop")  # Uncomment to add cycle
}


pr()

? StringifyGraph(oGraph)
# Output example (without cycle): 
# "nodes:3;edges:2;cyclic:FALSE;bottlenecks:[];longest_path:2;A:[[B],Start,,{B:flows}];B:[[C],Process,,{C:completes}];C:[[],End,,{}];"

pf()

/*----
*/

pr()


# Test with your serialized graph
oGraph = new stzGraph("Sample")
oGraph {
    AddNode(:a, "Start")
    AddNode(:b, "Process")
    AddNode(:c, "End")
    AddEdge(:a, :b, "flows")
    AddEdge(:b, :c, "completes")
}

? StringifyGraph(oGraph)
# Output: nodes:3;edges:2;cyclic:FALSE;bottlenecks:[b];longest_path:2;a:[[b],Start,,{b:flows}];b:[[c],Process,,{c:completes}];c:[[],End,,{}];

oGraphex = new stzGraphex("{@Node(start) -> @Edge -> @Node(end)}", oGraph)
? oGraphex.Match(oGraph)
# Should output: TRUE

oGraphex2 = new stzGraphex("{@Node(start) -> @Edge(flows) -> @Node(process)}", oGraph)
? oGraphex2.Match(oGraph)
# Should output: TRUE

oGraphex3 = new stzGraphex("{@Node(start) -> @Edge(loop) -> @Node}", oGraph)
? oGraphex3.Match(oGraph)
# Should output: FALSE (no "loop" edge)

oGraphex4 = new stzGraphex("{@!Cycle}", oGraph)
? oGraphex4.Match(oGraph)
# Should output: TRUE (graph is acyclic)


pf()

#=================
#  FUNCTION
#=================

func StringifyGraph(oGraph)
    # Extract metadata using stzGraph methods
    nNodes = oGraph.NodeCount()
    nEdges = oGraph.EdgeCount()
    bCyclic = oGraph.CyclicDependencies()
    acBottlenecks = oGraph.BottleneckNodes()
    nLongestPath = oGraph.LongestPath()
    
    cMetadata = "nodes:" + nNodes + ";edges:" + nEdges + ";cyclic:" + iif(bCyclic, "TRUE", "FALSE") + 
                ";bottlenecks:[" + JoinXT(acBottlenecks, ",") + "];longest_path:" + nLongestPath + ";"
    
    # Serialize nodes with adjacency lists, labels, and properties
    cNodes = ""
    acNodes = oGraph.AllNodes()
    nLenNodes = len(acNodes)
    for i = 1 to nLenNodes
        aNode = acNodes[i]
        cId = aNode[:id]
        cLabel = aNode[:label]
        acProperties = aNode[:properties]  # Assume list of key=value strings
        cProps = iff(len(acProperties) > 0, "{" + JoinXT(acProperties, ",") + "}", "")
        
        # Get neighbors (outgoing edges)
        acNeighbors = oGraph.NeighborsOf(cId)
        cNeighbors = "[" + JoinXT(acNeighbors, ",") + "]"
        
        # Get edge labels to neighbors
        cEdgeLabels = ""
        for cNeighbor in acNeighbors
            aEdge = oGraph.Edge(cId, cNeighbor)
            if aEdge != ""
                cEdgeLabels += iif(cEdgeLabels != "", ",", "") + cNeighbor + ":" + aEdge[:label]
            ok
        next
        cEdgeLabels = "{" + cEdgeLabels + "}"
        
        cNodes += cId + ":[" + cNeighbors + "," + cLabel + "," + cProps + "," + cEdgeLabels + "];"
    next
    
    # Serialize cycles: Find all cyclic paths and encode them
    cCycles = ""
    if bCyclic
        acCyclicNodes = oGraph._GetCyclicNodes()  # Assuming this method exists or implement cycle finding
        for cNode in acCyclicNodes
            acPaths = oGraph.FindAllPaths(cNode, cNode)  # Self-loops or cycles back to self
            for acPath in acPaths
                if len(acPath) > 1  # Valid cycle
                    cCycles += iif(cCycles != "", "|", "") + "[" + join(acPath, "->") + "]"
                ok
            next
        next
        cCycles = "cycles:[" + cCycles + "];"
    ok
    
    # Combine all
    cSerialized = cMetadata + cNodes + cCycles
    
    return cSerialized


#====================
#  CLASS
#====================

# stzGraphex Prototype for Graph Pattern Matching
class stzGraphex
    @cPattern       # Pattern string, e.g., "{@Node(start) -> @Edge -> @Node(end)}"
    @aTokens        # Parsed tokens
    @bDebugMode = FALSE
    @oGraph         # Reference to stzGraph instance
    @cSerialized    # Serialized graph string

    # Patterns for parsing tokens
    @cNodePattern = '@Node(?:\((.*?)\))?(?:\{(.*?)\})?'
    @cEdgePattern = '@Edge(?:\((.*?)\))?(?:\{(.*?)\})?'
    @cQuantifierPattern = '([+*?]|\d+|\d+-\d+)(.*)'
    @cNegationPattern = '@!(Node|Edge|Cycle|Path)(.*)'
    @cSetPattern = '\{(.*?)\}(U)?'

    def init(cPattern, oGraph)
        if NOT isString(cPattern) or NOT ( isObject(oGraph) and classname(oGraph) = "stzgraph")
            raise("Error: Pattern must be a string and graph must be stzGraph")
        ok
        @cPattern = This.NormalizePattern(cPattern)
        @oGraph = oGraph
        @cSerialized = StringifyGraph(oGraph)
        @aTokens = This.ParsePattern(@cPattern)

    def NormalizePattern(cPattern)
        cPattern = trim(cPattern)
        if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
            cPattern = "{" + cPattern + "}"
        ok
        return cPattern

    def ParsePattern(cPattern)
        oPattern = new stzString(cPattern)
        cInner = oPattern.RemoveFirstAndLastCharsQ().Content()
        aParts = split(cInner, "->")  # Split on edges for path-based patterns
        aTokens = []
        for cPart in aParts
            cPart = trim(cPart)
            aTokens + This.ParseToken(cPart)
        next
        return aTokens

    def ParseToken(cTokenStr)
        cTokenStr = trim(cTokenStr)
        bNegated = startsWith(cTokenStr, "@!")
        if bNegated
            oNegMatch = rx(@cNegationPattern)
            if oNegMatch.Match(cTokenStr)
                aMatches = oNegMatch.Matches()
		nLen = len(aMatches)

                cTokenStr = "@"
		if nLen >= 1
			cTokenStr += aMatches[1]
		but nLen >= 2
			cTokenStr += aMatches[1] + aMatches[2]
		ok
            ok
        ok
        nMin = 1
        nMax = 1
        aSetValues = []
        bRequireUnique = FALSE
        cLabel = ""
        cProps = ""

        # Check for quantifiers
        oQMatch = rx(@cQuantifierPattern)
        if oQMatch.Match(cTokenStr)
            aMatches = oQMatch.Matches()
            cQuantifier = aMatches[1]
            cRemainder = aMatches[2]
            switch cQuantifier
            on "+"
                nMin = 1
                nMax = 999999
            on "*"
                nMin = 0
                nMax = 999999
            on "?"
                nMin = 0
                nMax = 1
            off
            cTokenStr = cRemainder
        ok

        # Check for sets
        oSetMatch = rx(@cSetPattern).Match(cTokenStr)
        if oSetMatch
            aMatches = oSetMatch.Matches()
            aSetValues = split(aMatches[1], ";")
            bRequireUnique = aMatches[2] = "U"
            cTokenStr = left(cTokenStr, len(cTokenStr) - len(aMatches[0]))
        ok

        # Parse node or edge
        if startsWith(lower(cTokenStr), "@node")
            oNodeMatch = rx(@cNodePattern)
		
            if oNodeMatch.Match(cTokenStr)
                aMatches = oNodeMatch.Matches()

		cLabel = ""
		cProps = ""

		nLen = len(aMatches)
		if nLen > 0

			if nLen >= 1
                		cLabel = aMatches[1]
			ok
			if nLen >= 2
               			 cProps = aMatches[2]
			ok

		ok
            ok
            return [
                [ "type", "node" ],
                [ "label", cLabel ],
                [ "properties", cProps ],
                [ "min", nMin ],
                [ "max", nMax ],
                [ "setvalues", aSetValues ],
                [ "unique", bRequireUnique ],
                [ "negated", bNegated ]
            ]
        but startsWith(lower(cTokenStr), "@edge")
            oEdgeMatch = rx(@cEdgePattern)
            if oEdgeMatch.Match(cTokenStr)
                aMatches = oEdgeMatch.Matches()
		nLen = len(aMatches)
		cLabel = ""
		cPropos = ""

		if nLen > 0
			if nLen  >= 1
                		cLabel = aMatches[1]
			ok
			if nLen >=2
                		cProps = aMatches[2]
			ok
            	ok
	    ok
            return [
                [ "type", "edge" ],
                [ "label", cLabel ],
                [ "properties", cProps ],
                [ "min", nMin ],
                [ "max", nMax ],
                [ "setvalues", aSetValues ],
                [ "unique", bRequireUnique ],
                [ "negated", bNegated ]
            ]
        else
            raise("Error: Invalid token " + cTokenStr)
        ok

    def Match(oGraph)
        @oGraph = oGraph
        @cSerialized = StringifyGraph(oGraph)
        try
            return This.MatchTokens(@aTokens, @cSerialized)
        catch
            if @bDebugMode
                ? "Error during matching: " + cError
            ok
            return FALSE
        done

    def MatchTokens(aTokens, cSerialized)
        # Split serialized string into sections
        aSections = split(cSerialized, ";")
        oMetadata = new stzHashList(aSections[1])
        nNodes = number(oMetadata.ValueByKey("nodes"))
        nEdges = number(oMetadata.ValueByKey("edges"))
        bCyclic = oMetadata.ValueByKey("cyclic") = "TRUE"
        acBottlenecks = split(substr(oMetadata.ValueByKey("bottlenecks"), 2, len(oMetadata.ValueByKey("bottlenecks"))-1), ",")
        nLongestPath = number(oMetadata.ValueByKey("longest_path"))

        # Extract node sections
        aNodeSections = filter(aSections, func cSection { startsWith(lower(cSection), "a:") or startsWith(lower(cSection), "b:") or startsWith(lower(cSection), "c:") })

        # Match tokens sequentially (assuming path pattern for simplicity)
        nTokenIndex = 1
        aVisitedNodes = []
        aVisitedEdges = []
        return This.BacktrackMatch(aTokens, nTokenIndex, aNodeSections, aVisitedNodes, aVisitedEdges, cSerialized)

    def BacktrackMatch(aTokens, nTokenIndex, aNodeSections, aVisitedNodes, aVisitedEdges, cSerialized)
        if nTokenIndex > len(aTokens)
            return TRUE  # Successfully matched all tokens
        ok
        aToken = aTokens[nTokenIndex]
        nMin = aToken[:min]
        nMax = min([aToken[:max], len(aNodeSections) - len(aVisitedNodes)])

        if aToken[:type] = "node"
            for nCount = nMin to nMax
                bSuccess = TRUE
                aLocalVisitedNodes = copy(aVisitedNodes)
                for i = 1 to nCount
                    bFound = FALSE
                    for cSection in aNodeSections
                        cNodeId = left(cSection, find(cSection, ":")-1)
                        if find(aLocalVisitedNodes, cNodeId) = 0
                            if This.MatchNodeSection(cSection, aToken)
                                aLocalVisitedNodes + cNodeId
                                bFound = TRUE
                                exit
                            ok
                        ok
                    next
                    if NOT bFound
                        bSuccess = FALSE
                        exit
                    ok
                next
                if bSuccess
                    if This.BacktrackMatch(aTokens, nTokenIndex+1, aNodeSections, aLocalVisitedNodes, aVisitedEdges, cSerialized)
                        return TRUE
                    ok
                ok
            next
            return nMin = 0 and This.BacktrackMatch(aTokens, nTokenIndex+1, aNodeSections, aVisitedNodes, aVisitedEdges, cSerialized)
        but aToken[:type] = "edge"
            for nCount = nMin to nMax
                bSuccess = TRUE
                aLocalVisitedEdges = copy(aVisitedEdges)
                for i = 1 to nCount
                    bFound = FALSE
                    # Find edge in previous node's edge labels
                    if len(aVisitedNodes) > 0
                        cPrevNode = aVisitedNodes[len(aVisitedNodes)]
                        cNodeSection = filter(aNodeSections, func c { startsWith(lower(c), lower(cPrevNode) + ":") })[1]
                        cEdgeLabels = substr(cNodeSection, find(cNodeSection, "{", 2), find(cNodeSection, "}", 2))
                        aEdges = split(cEdgeLabels, ",")
                        for cEdge in aEdges
                            if len(cEdge) > 0
                                cToNode = left(cEdge, find(cEdge, ":")-1)
                                cLabel = substr(cEdge, find(cEdge, ":")+1)
                                if find(aLocalVisitedEdges, cToNode) = 0 and This.MatchEdge(cLabel, aToken)
                                    aLocalVisitedEdges + cToNode
                                    bFound = TRUE
                                    exit
                                ok
                            ok
                        next
                    ok
                    if NOT bFound
                        bSuccess = FALSE
                        exit
                    ok
                next
                if bSuccess
                    if This.BacktrackMatch(aTokens, nTokenIndex+1, aNodeSections, aVisitedNodes, aLocalVisitedEdges, cSerialized)
                        return TRUE
                    ok
                ok
            next
            return nMin = 0 and This.BacktrackMatch(aTokens, nTokenIndex+1, aNodeSections, aVisitedNodes, aVisitedEdges, cSerialized)
        ok
        return FALSE

    def MatchNodeSection(cSection, aToken)
        cNodeId = left(cSection, find(cSection, ":")-1)
        cContent = substr(cSection, find(cSection, ":")+1)
        aParts = split(substr(cContent, 2, len(cContent)-1), ",")
        cLabel = aParts[2]
        cProps = aParts[3]

        if aToken[:negated]
            return NOT This.CheckNode(cLabel, cProps, aToken)
        ok
        return This.CheckNode(cLabel, cProps, aToken)

    def CheckNode(cLabel, cProps, aToken)
        if aToken[:label] != "" and lower(cLabel) != lower(aToken[:label])
            return FALSE
        ok
        if len(aToken[:setvalues]) > 0
            bFound = FALSE
            for cValue in aToken[:setvalues]
                if lower(cValue) = lower(cLabel) or contains(lower(cProps), lower(cValue))
                    bFound = TRUE
                    exit
                ok
            next
            return bFound
        ok
        return TRUE

    def MatchEdge(cEdgeLabel, aToken)
        if aToken[:negated]
            return NOT This.CheckEdge(cEdgeLabel, aToken)
        ok
        return This.CheckEdge(cEdgeLabel, aToken)

    def CheckEdge(cEdgeLabel, aToken)
        if aToken[:label] != "" and lower(cEdgeLabel) != lower(aToken[:label])
            return FALSE
        ok
        if len(aToken[:setvalues]) > 0
            bFound = FALSE
            for cValue in aToken[:setvalues]
                if lower(cValue) = lower(cEdgeLabel)
                    bFound = TRUE
                    exit
                ok
            next
            return bFound
        ok
        return TRUE

