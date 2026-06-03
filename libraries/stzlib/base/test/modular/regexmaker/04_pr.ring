# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #4.

load "../../../stzBase.ring"


rx(pat(:URL)) { ? Explain() ? Pattern() }
#-->
# Matches web URLs
# ^https?:\/\/(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$

rx(pat(:URL)) { ? ExplainXT() }
# - `^` and `$`: Start and end of the string.
# - `(https?:\/\/)?`: Optional protocol.
# - `([\da-z\.-]+)`: Domain name.
# - `\.([a-z\.]{2,6})`: Last segment (TLD) like `.com`, `.tn`, etc.
# - `([\/\w \.-]*)*\/?`: Optional path.
# - Matches: `https://example.com`, `domain.co.tn/path`
# - Non-matches: `http:/domain.com`, `.com`, `https://`

pf()
# Executed in almost 0 second(s) in Ring 1.22
