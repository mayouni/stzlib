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
        cContent = lower(oRequest.Path() + " " + oRequest.Body())
        aScores = []
        
        for aPattern in aPatterns
            nScore = 0
            for cKeyword in aPattern[:keywords]
                if substr(cContent, cKeyword) > 0
                    nScore++
                ok
            next
            aScores + [aPattern[:domain], nScore]
        next
        
        # Find highest scoring domain
        cBestDomain = "general"
        nHighestScore = 0
        for aScore in aScores
            if aScore[2] > nHighestScore
                nHighestScore = aScore[2]
                cBestDomain = aScore[1]
            ok
        next
        
        return cBestDomain
