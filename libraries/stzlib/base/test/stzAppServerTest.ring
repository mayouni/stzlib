
/*--- Basic web application


app = new stzAppServer()

# Simple route
app.Get("/hello", func oRequest, oResponse {
    oResponse.Text("Hello from Softanza!")
})

# JSON API with Softanza string processing
app.Get("/api/process", func oRequest, oResponse {
    cText = oRequest.Query("text")
    if cText = ""
        oResponse.Status(400).Json([:error = "text parameter required"])
        return
    ok
    
    # Use Softanza's powerful string processing
    oStr = new stzString(cText)
    aResult = [
        :original = cText,
        :length = oStr.NumberOfChars(),
        :words = oStr.Words(),
        :reversed = oStr.Reversed(),
        :uppercase = oStr.Uppercased(),
        :character_analysis = oStr.CharsClassification()
    ]
    
    oResponse.Json(aResult)
})

# Start the server
app.Start(3000)


/*--- Advanced computational API
*/
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

