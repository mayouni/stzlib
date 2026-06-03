# Narrative
# --------
# Advanced computational API
#
# Extracted from stzappserverTest.ring, block #2.

load "../../stzBase.ring"

pr()

app = new stzAppServer()

# Complex text analysis endpoint
app.Post("/api/analyze", func oRequest, oResponse {
    cText = oRequest.Body()
    
    # Leverage Softanza's rich text processing
    oText = new stzText(cText)
    
    aAnalysis = [
        :statistics = [
            :characters = oText.NumberOfChars(),
            :words = oText.NumberOfWords(),
            :sentences = oText.NumberOfSentences(),
            :paragraphs = oText.NumberOfParagraphs()
        ],
        :structure = [
            :headings = oText.Headings(),
            :quotes = oText.QuotedSubStrings(),
            :urls = oText.URLs(),
            :emails = oText.EmailAddresses()
        ],
        :linguistic = [
            :language = oText.Language(),
            :readability = oText.ReadabilityScore(),
            :sentiment = oText.SentimentAnalysis(),  # If NLP loaded
            :keywords = oText.Keywords()
        ]
    ]
    
    oResponse.Json(aAnalysis)
})

app.Start(8080)
#ERR Error (R3) : Calling Function without definition: uv_defaulloop
# Calling Function without definition: uv_defaulloop

pf()
