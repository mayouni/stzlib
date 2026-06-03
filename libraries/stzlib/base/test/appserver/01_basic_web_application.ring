# Narrative
# --------
# Basic web application
#
# Extracted from stzappserverTest.ring, block #1.

load "../../stzBase.ring"

pr()

app = new stzAppServer()

# Simple route
app.Get_("/hello", func oRequest, oResponse {
    oResponse.Text("Hello from Softanza!")
})

# JSON API with Softanza string processing
app.Get_("/api/process", func oRequest, oResponse {
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
#ERR
# Calling Function without definition: uv_defaulloop

pf()
