# screenshot_facts.ring -- writes the facts of one screenshot for stzzui's legibility audit
# (zui-audit-facts 1.0, stzzui doc/design/AUDIT-FACTS.md). Measures and never judges: see
# base/ocr/stzScreenshotFacts.ring for what each field is and how it is measured.
#
#   rnxc.exe screenshot_facts.ring <screenshot.png> <scale> <out.facts.json> [lang]
#
#   scale    device pixels per CSS pixel (2 on a typical high-density display): the caller's, never guessed
#   lang     the text's language, "en" when absent
#
# Run from this folder. Prints the number of lines written; exits 1 when it could not write the file.

load "../base/stzBase.ring"

# the arguments after this program's own name, whatever the runner puts before it
aArgs = []
bSeen = 0
nArgs = len(sysargv)
for i = 1 to nArgs
	if bSeen
		add(aArgs, sysargv[i])
	but right(lower(sysargv[i]), 21) = "screenshot_facts.ring"
		bSeen = 1
	ok
next
if len(aArgs) < 3
	? "usage: rnxc.exe screenshot_facts.ring <screenshot.png> <scale> <out.facts.json> [lang]"
	shutdown(1)
ok
cLang = "en"
if len(aArgs) >= 4 cLang = aArgs[4] ok
nScale = 0 + aArgs[2]
nLines = StzWriteScreenshotFacts(aArgs[1], nScale, cLang, aArgs[3])
? "screenshot_facts: " + nLines + " lines -> " + aArgs[3]
if NOT fexists(aArgs[3]) shutdown(1) ok
