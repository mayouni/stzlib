# stzRequestClassifier: AI-powered request analysis for routing
class stzRequestClassifier
    aPatterns = []
    
    def init()
        This.LoadClassificationPatterns()

    def LoadClassificationPatterns()
        # NLP patterns
        aPatterns + [
            :domain = "nlp",
            :keywords = ["text", "analyze", "sentiment", "translate", "language", "parse", "extract"]
        ]
        # Math patterns  
        aPatterns + [
            :domain = "math",
            :keywords = ["calculate", "compute", "model", "statistics", "optimize", "solve", "formula"]
        ]
        # Vision patterns
        aPatterns + [
            :domain = "vision", 
            :keywords = ["image", "photo", "ocr", "scan", "visual", "picture", "document", "pdf"]
        ]
        # Search patterns
        aPatterns + [
            :domain = "search",
            :keywords = ["search", "find", "query", "index", "lookup", "discover", "retrieve"]
        ]

    def ClassifyComputationalDomain(oRequest)
        cContent = StzLower(oRequest.Path() + " " + oRequest.Body())
        aScores = []
        
        _nPatterns1Len_ = len(aPatterns)
        for _iLoopPatterns1_ = 1 to _nPatterns1Len_
        	aPattern = aPatterns[_iLoopPatterns1_]
            nScore = 0
            _aPatternkeywords1_ = aPattern[:keywords]
            _nPatternkeywords1Len_ = len(_aPatternkeywords1_)
            for _iLoopPatternkeywords1_ = 1 to _nPatternkeywords1Len_
            	cKeyword = _aPatternkeywords1_[_iLoopPatternkeywords1_]
                if StzFindFirst(cContent, cKeyword) > 0
                    nScore++
                ok
            next
            aScores + [aPattern[:domain], nScore]
        next
        
        # Find highest scoring domain
        cBestDomain = "general"
        nHighestScore = 0
        _nScores1Len_ = len(aScores)
        for _iLoopScores1_ = 1 to _nScores1Len_
        	aScore = aScores[_iLoopScores1_]
            if aScore[2] > nHighestScore
                nHighestScore = aScore[2]
                cBestDomain = aScore[1]
            ok
        next
        
        return cBestDomain
