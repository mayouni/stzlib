# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #5.

load "../../stzBase.ring"


? Q("ring programming languge").UrlEncoded()
#--> ring%20programming%20languge

? Q("ring%20programming%20language").UrlDecoded() + NL
#--> ring programming language

? Q('<div class = "article">This is an article</div>').HtmlEscaped()
#--> &lt;div class = &quot;article&quot;&gt;This is an article&lt;/div&gt;

pf()
# Executed in 0.03 second(s) in Ring 1.21
