# stzRequestClassifier: AI-powered request analysis for routing
class stzRequestClassifier from stzObject
    _aPatterns_ = []
    
    def init()
        This.LoadClassificationPatterns()

    def LoadClassificationPatterns()
        # NLP patterns
        _aPatterns_ + [
            :domain = "nlp",
            :keywords = ["text", "analyze", "sentiment", "translate", "language", "parse", "extract"]
        ]
        # Math patterns  
        _aPatterns_ + [
            :domain = "math",
            :keywords = ["calculate", "compute", "model", "statistics", "optimize", "solve", "formula"]
        ]
        # Vision patterns
        _aPatterns_ + [
            :domain = "vision", 
            :keywords = ["image", "photo", "ocr", "scan", "visual", "picture", "document", "pdf"]
        ]
        # Search patterns
        _aPatterns_ + [
            :domain = "search",
            :keywords = ["search", "find", "query", "index", "lookup", "discover", "retrieve"]
        ]

    def ClassifyComputationalDomain(oRequest)
        _cContent_ = StzLower(oRequest.Path() + " " + oRequest.Body())
        _aScores_ = []
        
        _nPatterns1Len_ = len(_aPatterns_)
        for _iLoopPatterns1_ = 1 to _nPatterns1Len_
        	_aPattern_ = _aPatterns_[_iLoopPatterns1_]
            _nScore_ = 0
            _aPatternkeywords1_ = _aPattern_[:keywords]
            _nPatternkeywords1Len_ = len(_aPatternkeywords1_)
            for _iLoopPatternkeywords1_ = 1 to _nPatternkeywords1Len_
            	_cKeyword_ = _aPatternkeywords1_[_iLoopPatternkeywords1_]
                if StzFindFirst(_cContent_, _cKeyword_) > 0
                    _nScore_++
                ok
            next
            _aScores_ + [_aPattern_[:domain], _nScore_]
        next
        
        # Find highest scoring domain
        _cBestDomain_ = "general"
        _nHighestScore_ = 0
        _nScores1Len_ = len(_aScores_)
        for _iLoopScores1_ = 1 to _nScores1Len_
        	_aScore_ = _aScores_[_iLoopScores1_]
            if _aScore_[2] > _nHighestScore_
                _nHighestScore_ = _aScore_[2]
                _cBestDomain_ = _aScore_[1]
            ok
        next
        
        return _cBestDomain_
