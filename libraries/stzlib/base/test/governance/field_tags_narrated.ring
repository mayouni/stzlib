# Field tags -- the weaves W3 sovereignty and W4 privacy as judged tags on
# a world's fields (the constitution plane's ZC4: haro/CHARTER.md D35,
# haro/spike/v25/GRAMMAR.md; COMPASS-KERN-01).
#
# Written BEFORE stzFieldTags.ring (the W discipline: the guard first).
# The rule under test, in the launch prompt's words: a field declared
# personal that reaches an analytics, a log or a model path is refused
# with the article named -- and the regime named in the refusal is the
# declared one, never a default. The escape is the one Zin's weaves give
# each path: a path governed by its safeguards admits the field.
#
# Runs on rnxc (Ring is retired): from this folder,
#   %RINGPP%\bin\rnxc.exe field_tags_narrated.ring
# against a library whose engine is built for Ring++ (the install's, with
# this file and stzFieldTags.ring overlaid: bench/sec_guard.py's recipe).
#
# Ring traps avoided: main code before the first func; locals never named
# like a top-level name; no bare global read inside a function.

load "../../stzBase.ring"

# Rule A: a top-level name a function writes is spelt $name on both sides (the migrated library's rule)
$nPass = 0
$nFail = 0

? "-- Scene 1: the tags are closed, and so are the paths --"
oT = new stzFieldTags("clinic")
oT.Tag("full_name", :personal)
oT.Tag("diagnosis", :confidential)
chk("a field tagged personal says so", oT.TagOf("full_name") = "personal")
chk("a field tagged confidential says so", oT.TagOf("diagnosis") = "confidential")
chk("an untagged field has no tag", oT.TagOf("file_no") = "")
bRaised = 0
try
	oT.Tag("ward", :secret)
catch
	bRaised = 1
done
chk("a tag outside personal and confidential raises", bRaised = 1)
bRaised = 0
try
	oT.MayReach(:cache, ["file_no"])
catch
	bRaised = 1
done
chk("a path outside analytics, log and model raises", bRaised = 1)
chk("the three paths are the closed set", len(oT.Paths()) = 3)

? ""
? "-- Scene 2: a personal field reaching an ungoverned model path is refused, the article named --"
oT.DeclareRegime("gdpr")
chk("an untagged field reaches the model", oT.MayReach(:model, ["file_no", "ward"]) = 1)
chk("...and Why() says nothing was tagged",
	substr(oT.Why(), "allowed: no field of") = 1)
chk("the personal field does not", oT.MayReach(:model, ["file_no", "full_name"]) = 0)
cWhy = oT.Why()
chk("...the refusal names the field and the path",
	substr(cWhy, "refused: 'full_name' is personal and 'model' is an ungoverned path") = 1)
chk("...the weave's rule, in its words",
	substr(cWhy, "W3.3 sovereignty: confidential data does not leave to a model that is not on premise") > 0)
chk("...the article it serves", substr(cWhy, "[Art. 5 organizational_sovereignty;") > 0)
chk("...and the declared regime's own article", substr(cWhy, "gdpr: Chapter V]") > 0)
chk("a confidential field is held the same way", oT.MayReach(:model, ["diagnosis"]) = 0)
# The model path is the one Haro does not judge at the declaring altitude:
# it is this library's and HaroBase's (D35). The refusal carries number
# and article, the Kern lesson adopted here.

? ""
? "-- Scene 3: the same path, governed, admits the field --"
oT.GovernPath(:model, [:on_premise])
chk("on premise, the personal field reaches the model", oT.MayReach(:model, ["full_name"]) = 1)
chk("...and Why() says which safeguard governs it",
	substr(oT.Why(), "allowed: 'full_name' is personal and the model path is governed (on_premise)") = 1)
# Ring's = on two lists is not a guard's equality: length and element are
aSg = oT.SafeguardsOf(:model)
chk("the path's safeguards are readable", len(aSg) = 1 and aSg[1] = "on_premise")
bRaised = 0
try
	oT.GovernPath(:model, [:consent])
catch
	bRaised = 1
done
chk("a safeguard that is not the path's raises", bRaised = 1)

? ""
? "-- Scene 4: a log governed in part refuses, naming what is missing (W4.4) --"
oT.GovernPath(:log, [:retention])
chk("retention alone does not govern a log", oT.MayReach(:log, ["full_name"]) = 0)
cWhy = oT.Why()
chk("...the refusal names the missing safeguard",
	substr(cWhy, "'log' is a path governed in part (redaction missing)") > 0)
chk("...the weave's rule", substr(cWhy, "W4.4 privacy: a log carries no personal datum without a retention limit and redaction") > 0)
chk("...and gdpr's storage limitation", substr(cWhy, "gdpr: Article 5(1)(e)]") > 0)
oT.GovernPath(:log, [:retention, :redaction])
chk("retention and redaction govern it", oT.MayReach(:log, ["full_name"]) = 1)

? ""
? "-- Scene 5: analytics needs consent and anonymisation (W4.2) --"
chk("ungoverned analytics is refused", oT.MayReach(:analytics, ["full_name", "ward"]) = 0)
chk("...with W4.2 and Article 7",
	substr(oT.Why(), "W4.2 privacy: usage over personal data is analytics, which needs consent and anonymisation") > 0 and
	substr(oT.Why(), "gdpr: Article 7]") > 0)
oT.GovernPath(:analytics, [:consent, :anonymisation])
chk("consent and anonymisation govern it", oT.MayReach(:analytics, ["full_name", "ward"]) = 1)

? ""
? "-- Scene 6: the regime is the declared one, never a default --"
oT2 = new stzFieldTags("registry")
oT2.Tag("full_name", :personal)
oT2.MayReach(:model, ["full_name"])
chk("under no regime the refusal says so", substr(oT2.Why(), "no regime declared]") > 0)
oT2.DeclareRegime("niger_2017_28")
oT2.MayReach(:model, ["full_name"])
chk("the regional regime is named by its law", substr(oT2.Why(), "Niger Law 2017-28]") > 0)
oT2.DeclareRegime("ohada")
oT2.MayReach(:model, ["full_name"])
chk("a regime the library has no table for is named as declared",
	substr(oT2.Why(), "regime 'ohada' as declared, which Softanza has no article table for]") > 0)
chk("the regime is readable", oT2.Regime() = "ohada")

? ""
? "-- Scene 7: a refusal is an event, not a silent failure --"
oT3 = new stzFieldTags("clinic")
oT3.Tag("full_name", :personal)
oT3.DeclareRegime("gdpr")
oT3.MayReach(:model, ["full_name"])
oE = oT3.LastEvent()
chk("the refusal built a security event", isObject(oE))
chk("...of the kind data.path.refused", substr(oE.AsLine(), "data.path.refused") > 0)
chk("...carrying the field's descriptor, never a value", substr(oE.AsLine(), "field:full_name") > 0)
oT3.MayReach(:model, ["file_no"])
chk("after an allowed reach there is no event", isNull(oT3.LastEvent()))
oT3.MayReach(:model, ["full_name"])
oLed = StzSecurityLedger(16)
oT3.RecordTo(oLed)
chk("the event enters a ledger", oLed.Count() = 1)
chk("...as a refusal", len(oLed.Refusals()) = 1)

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

# a guard exits with its fail count (stzlib CLAUDE.md, RING-RETIRED-01)
shutdown($nFail)

func chk cLabel, bCond
	if bCond
		$nPass++
		? "  [OK] " + cLabel
	else
		$nFail++
		? "  [FAIL] " + cLabel
	ok
