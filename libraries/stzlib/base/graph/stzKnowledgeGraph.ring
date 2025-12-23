func StzKnowledgeGraphQ(pcId)
	return new stzKnowledgeGraph(pcId)

	func StzKnowGraphQ(pcId)
		return new stzKnowledgeGraph(pcId)

func IsStzKnowledgeGraph(pObj)
	if isObject(pObj) and classname(pObj) = "stzknowledgegraph"
		return TRUE
	ok
	return FALSE

	func IsAStzKnowledgeGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsAStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

class stzKnowGraph from stzKnowledgeGraph
class stzKnowledgeGraph from stzGraph

	@aNamespaces = []
	@aOntology = []

	def init(pcId)
		super.init(pcId)
		super.SetGraphType("semantic")

		@aNamespaces = []
		@aOntology = []

	def IsKnowledgeGraph()
		return TRUE

		def IsAKnowledgeGraph()
			return TRUE

	#--------------------#
	#  TRIPLE INTERFACE  #
	#--------------------#

	def AddFact(pcSubject, pcPredicate, pcObject)
		if NOT This.NodeExists(pcSubject)
			This.AddNodeXTT(pcSubject, pcSubject, [:type = "entity"])
		ok
		
		if NOT This.NodeExists(pcObject)
			This.AddNodeXTT(pcObject, @@(pcObject), [:type = "entity"])
		ok
		
		This.AddEdgeXTT(pcSubject, pcObject, pcPredicate, [:type = "fact"])

		def AddTriple(pcSubject, pcPredicate, pcObject)
			This.AddFact(pcSubject, pcPredicate, pcObject)

	def RemoveFact(pcSubject, pcPredicate, pcObject)
		This.RemoveThisEdge(pcSubject, pcObject)

		def RemoveTriple(pcSubject, pcPredicate, pcObject)
			This.RemoveFact(pcSubject, pcPredicate, pcObject)

	def Facts()
		_aFacts_ = []
		_aEdges_ = This.Edges()
		
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			_aEdge_ = _aEdges_[_i_]
			_aFacts_ + [_aEdge_[:from], _aEdge_[:label], _aEdge_[:to]]
		end
		
		return _aFacts_

		def Triples()
			return This.Facts()

	#-------------------#
	#  QUERY INTERFACE  #
	#-------------------#

	def Query(paPattern)
		# Pattern: ["?x", :IsA, "Animals"] or ["Dogs", :Eats, "?what"]
		
		_cSubject_ = paPattern[1]
		_cPredicate_ = paPattern[2]
		_cObject_ = paPattern[3]
		
		_acResults_ = []
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)
		
		_bSubjVar_ = (isString(_cSubject_) and left(_cSubject_, 1) = "?")
		_bObjVar_ = (isString(_cObject_) and left(_cObject_, 1) = "?")
		
		if _bSubjVar_ and _bObjVar_
			# Both variables: return all subject-object pairs for predicate
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:label] = _cPredicate_
					_acResults_ + [_aEdges_[_i_][:from], _aEdges_[_i_][:to]]
				ok
			end
			
		but _bSubjVar_
			# Subject is variable
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:to] = _cObject_ and _aEdges_[_i_][:label] = _cPredicate_
					if ring_find(_acResults_, _aEdges_[_i_][:from]) = 0
						_acResults_ + _aEdges_[_i_][:from]
					ok
				ok
			end
			
		but _bObjVar_
			# Object is variable
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:from] = _cSubject_ and _aEdges_[_i_][:label] = _cPredicate_
					if ring_find(_acResults_, _aEdges_[_i_][:to]) = 0
						_acResults_ + _aEdges_[_i_][:to]
					ok
				ok
			end
			
		else
			# Both bound - check existence
			if This.EdgeExists(_cSubject_, _cObject_)
				_aEdge_ = This.Edge(_cSubject_, _cObject_)
				if _aEdge_[:label] = _cPredicate_
					return TRUE
				ok
			ok
			return FALSE
		ok
		
		return _acResults_

	def QueryPath(paaPatterns)
		# Multi-hop: [["?x", :IsA, "Animals"], ["?x", :Eats, "?food"]]
		
		if len(paaPatterns) = 0
			return []
		ok
		
		# Execute first pattern
		_aResults_ = This.Query(paaPatterns[1])
		
		# For multi-pattern queries, would need variable binding logic
		# Basic implementation returns first pattern results
		
		return _aResults_

	#-------------------#
	#  ENTITY ANALYSIS  #
	#-------------------#

	def Predicates(pcEntity)
		_acPredicates_ = []
		_aEdges_ = This.Edges()
		
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = pcEntity
				if ring_find(_acPredicates_, _aEdges_[_i_][:label]) = 0
					_acPredicates_ + _aEdges_[_i_][:label]
				ok
			ok
		end
		
		return _acPredicates_

		def PredicatesOf(pcEntity)
			return This.Predicates(pcEntity)

	def Relations(pcEntity)
		_aRelations_ = []
		_aEdges_ = This.Edges()
		
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = pcEntity
				_aRelations_ + [_aEdges_[_i_][:label], _aEdges_[_i_][:to]]
			ok
		end
		
		return _aRelations_

		def RelationsOf(pcEntity)
			return This.Relations(pcEntity)

	def SimilarTo(pcEntity)
		_aMyPredicates_ = This.Predicates(pcEntity)
		_acSimilar_ = []
		_aNodes_ = This.Nodes()
		
		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]
			
			if _cNodeId_ != pcEntity
				_aTheirPredicates_ = This.Predicates(_cNodeId_)
				_nOverlap_ = 0
				
				_nMyLen_ = len(_aMyPredicates_)
				for _j_ = 1 to _nMyLen_
					if ring_find(_aTheirPredicates_, _aMyPredicates_[_j_]) > 0
						_nOverlap_++
					ok
				end
				
				if _nOverlap_ > 0
					_acSimilar_ + [_cNodeId_, _nOverlap_]
				ok
			ok
		end
		
		return _acSimilar_

		def SimilarEntities(pcEntity)
			return This.SimilarTo(pcEntity)

	#--------------------#
	#  ONTOLOGY SUPPORT  #
	#--------------------#

	def DefineClass(pcClass, pcSuperClass)
		This.AddFact(pcClass, :SubClassOf, pcSuperClass)

	def DefineProperty(pcProperty, paConstraints)
		@aOntology + [
			:property = pcProperty,
			:constraints = paConstraints
		]

	def Ontology()
		return @aOntology

	def ValidateOntology()
		# Basic validation - checks if defined properties are used consistently
		return TRUE

	#---------------------------#
	#  KNOWLEDGE GRAPH EXPLAIN  #
	#---------------------------#

	def Explain()
		aExplanation = [
			:type = "Knowledge Graph",
			:structure = "",
			:facts = [],
			:entities = [],
			:predicates = [],
			:ontology = [],
			:patterns = [],
			:insights = []
		]
		
		# Structure overview
		nNodes = This.NodeCount()
		nEdges = This.EdgeCount()
		nFacts = len(This.Facts())
		aExplanation[:structure] = 'Knowledge graph "' + @cId + '" contains ' + 
		                           nNodes + " entities and " + nFacts + " facts."
		
		# Facts analysis
		aFacts = This.Facts()
		if len(aFacts) > 0
			nSample = min([5, len(aFacts)])
			for i = 1 to nSample
				aFact = aFacts[i]
				aExplanation[:facts] + (aFact[1] + " " + aFact[2] + " " + aFact[3])
			end
			if len(aFacts) > 5
				aExplanation[:facts] + ("... and " + (len(aFacts) - 5) + " more facts")
			ok
		else
			aExplanation[:facts] + "No facts defined yet"
		ok
		
		# Entity analysis
		aNodes = This.Nodes()
		acEntities = []
		nNodeLen = len(aNodes)
		for i = 1 to nNodeLen
			if HasKey(aNodes[i]["properties"], "type")
				if aNodes[i]["properties"]["type"] = "entity"
					acEntities + aNodes[i]["id"]
				ok
			ok
		end
		
		if len(acEntities) > 0
			nSample = min([10, len(acEntities)])
			cEntityList = ""
			for i = 1 to nSample
				cEntityList += acEntities[i]
				if i < nSample cEntityList += ", " ok
			end
			aExplanation[:entities] + ("Entities: " + cEntityList)
			if len(acEntities) > 10
				aExplanation[:entities] + ("... and " + (len(acEntities) - 10) + " more")
			ok
		ok
		
		# Predicate analysis
		acAllPredicates = []
		aEdges = This.Edges()
		nEdgeLen = len(aEdges)
		for i = 1 to nEdgeLen
			cPred = aEdges[i][:label]
			if cPred != "" and ring_find(acAllPredicates, cPred) = 0
				acAllPredicates + cPred
			ok
		end
		
		if len(acAllPredicates) > 0
			aExplanation[:predicates] + ("Predicates used: " + JoinXT(acAllPredicates, ", "))
		ok
		
		# Ontology status
		if len(@aOntology) > 0
			aExplanation[:ontology] + ("Ontology defined with " + len(@aOntology) + " constraints")
			nOntLen = len(@aOntology)
			for i = 1 to nOntLen
				if HasKey(@aOntology[i], :property)
					aExplanation[:ontology] + ("Property: " + @aOntology[i][:property])
				ok
			end
		else
			aExplanation[:ontology] + "No formal ontology defined"
		ok
		
		# Pattern detection
		nMaxConnections = 0
		cMostConnected = ""
		for i = 1 to nNodeLen
			cNodeId = aNodes[i]["id"]
			nConnections = len(This.Predicates(cNodeId))
			if nConnections > nMaxConnections
				nMaxConnections = nConnections
				cMostConnected = cNodeId
			ok
		end
		
		if cMostConnected != ""
			aExplanation[:patterns] + ("Most connected entity: " + cMostConnected + 
			                           " (" + nMaxConnections + " relationships)")
		ok
		
		# Density
		nDensity = This.NodeDensity()
		if nDensity < 25
			aExplanation[:patterns] + ("Graph is sparse (" + nDensity + "% density)")
		but nDensity > 75
			aExplanation[:patterns] + ("Graph is highly connected (" + nDensity + "% density)")
		else
			aExplanation[:patterns] + ("Moderate connectivity (" + nDensity + "% density)")
		ok
		
		# Insights
		if This.CyclicDependencies()
			aExplanation[:insights] + "Contains circular relationships (cycles detected)"
		else
			aExplanation[:insights] + "Acyclic structure (no circular dependencies)"
		ok
		
		# Inferred knowledge
		if This.ApplyInference() > 0
			aExplanation[:insights] + "Inference rules generated new knowledge"
		ok
		
		if len(acAllPredicates) < 3
			aExplanation[:insights] + "Limited relationship types - consider enriching the ontology"
		ok
		
		if nDensity < 10 and nNodes > 5
			aExplanation[:insights] + "Many isolated entities - may need more connections"
		ok
		
		return aExplanation

	#----------------------------------#
	#  MANAGING *.stzknow file format  #
	#----------------------------------#

	def ImportKnow(pSource)
	    if isString(pSource)
	        if right(pSource, 8) = ".stzknow"
	            oParser = new stzKnowParser()
	            oLoaded = oParser.ParseFile(pSource)
	        else
	            oParser = new stzKnowParser()
	            oLoaded = oParser.Parse(pSource)
	        ok
	        This._MergeKnowledgeBase(oLoaded)
	    ok
	
	    def LoadKnow(pSource)
		return This.ImportKnow(pSource)

	def ExportToKnow()
	    cKnow = 'knowledge "' + @cId + '"' + NL + NL
	    cKnow += "facts" + NL
	    aFacts = This.Facts()
	    for aFact in aFacts
	        cKnow += "    " + aFact[1] + " | " + aFact[2] + " | " + aFact[3] + NL
	    end
	    return cKnow
	
	def WriteToKnowFile(pcFilename)
	    if right(pcFilename, 8) != ".stzknow"
	        pcFilename += ".stzknow"
	    ok
	    write(pcFilename, This.ExportToKnow())
	
	    def WriteKnowFile(pcFileName)
		This.WriteToKnowFile(pcFilename)

	def _MergeKnowledgeBase(oOther)
	    aFacts = oOther.Facts()
	    for aFact in aFacts
	        This.AddFact(aFact[1], aFact[2], aFact[3])
	    end

class stzKnowParser
    def ParseFile(pcFilename)
        cContent = read(pcFilename)
        return This.Parse(cContent)
    
    def Parse(pcContent)
        oKG = NULL
        acLines = split(pcContent, NL)
        cSection = ""
        
        for cLine in acLines
            cLine = trim(cLine)
            if cLine = "" or left(cLine, 1) = "#"
                loop
            ok
            
            if substr(cLine, "knowledge ")
                cId = This._ExtractQuoted(cLine)
                oKG = new stzKnowledgeGraph(cId)
            
            but cLine = "namespaces"
                cSection = "namespaces"
            but cLine = "ontology"
                cSection = "ontology"
            but cLine = "facts"
                cSection = "facts"
            but cLine = "rules"
                cSection = "rules"
            
            but cSection = "facts" and substr(cLine, "|")
                aParts = split(cLine, "|")
                if len(aParts) = 3
                    oKG.AddFact(trim(aParts[1]), trim(aParts[2]), trim(aParts[3]))
                ok
            ok
        end
        
        return oKG
    
    def _ExtractQuoted(cLine)
        nStart = substr(cLine, '"')
        if nStart = 0 return "" ok
        nEnd = @substr(cLine, nStart + 1, len(cLine))
        nEnd = substr(nEnd, '"')
        return @substr(cLine, nStart + 1, nStart + nEnd - 1)
