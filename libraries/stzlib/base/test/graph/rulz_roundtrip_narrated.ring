# .stzrulz ROUND-TRIP -- a graph's rules, written down and read back.
#
# The point of a file format is that what comes back is what went in. This
# proves it for all three rule types, field by field, and pins the three
# defects that had kept the format from ever running:
#
#   @aRules       -- the format wrote to an attribute the class never
#                    declared, so exporting raised R24 on line one.
#   the case-fold -- Ring's `=` on strings is CASE-SENSITIVE, so a rule
#                    typed `validation` never matched the :Validation store
#                    and vanished without a word.
#   load pcPath   -- Ring's load is a COMPILE-TIME directive, so
#                    LoadRuleFunctionsFrom() reported success while
#                    defining nothing at all.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a graph carries rules of every type --"

oG = new stzGraph("acme")

oG._AddUniqueRule([
	:name = "no_self_loop",   :type = :constraint,
	:function = ConstraintFunc_NoSelfLoop(),  :params = [],
	:message = "A node may not point at itself", :severity = :error
])

oG._AddUniqueRule([
	:name = "transitivity",   :type = :derivation,
	:function = DerivationFunc_Transitivity(),
	:params = [ :relation = "reports_to" ],
	:message = "Reporting is transitive", :severity = :info
])

oG._AddUniqueRule([
	:name = "is_acyclic",     :type = :validation,
	:function = ValidationFunc_IsAcyclic(),   :params = [],
	:message = "The chart must be acyclic",   :severity = :warning
])

chk("all three rules are held", oG.NumberOfRules() = 3)
chk("... each filed under its own type",
	len(oG.RulesSummary()[:Constraint]) = 1 and
	len(oG.RulesSummary()[:Derivation]) = 1 and
	len(oG.RulesSummary()[:Validation]) = 1)
chk("Rules() READS the typed stores -- it is not a fourth store",
	len(oG.Rules()) = 3)

? ""
? "-- Scene 2: written down, and read back into a FRESH graph --"

oG.SaveToStzRulz("_rt_probe.stzrulz")
chk("the file is really on disk", fexists("_rt_probe.stzrulz"))

oFresh = new stzGraph("fresh")
chk("a fresh graph starts with no rules", oFresh.NumberOfRules() = 0)

oFresh.LoadFromStzRulz("_rt_probe.stzrulz")
chk("every rule came back", oFresh.NumberOfRules() = 3)
chk("... still filed under the right type",
	oFresh.RulesSummary()[:Constraint][1] = "no_self_loop" and
	oFresh.RulesSummary()[:Derivation][1] = "transitivity" and
	oFresh.RulesSummary()[:Validation][1] = "is_acyclic")

? ""
? "-- Scene 3: field by field, the rule is the SAME rule --"

aBack = oFresh.Rules()
aOrig = oG.Rules()

bSame = TRUE
_n_ = len(aOrig)
for i = 1 to _n_
	if aBack[i][:name] != aOrig[i][:name]  bSame = FALSE  ok
	if StzLower("" + aBack[i][:type]) != StzLower("" + aOrig[i][:type])  bSame = FALSE  ok
	if StzLower("" + aBack[i][:severity]) != StzLower("" + aOrig[i][:severity])  bSame = FALSE  ok
	if aBack[i][:message] != aOrig[i][:message]  bSame = FALSE  ok
next
chk("name, type, severity and message all survive", bSame)

# The file stores a function by NAME; loading resolves the name back to the
# real function object -- not a string that merely looks like one.
chk("the FUNCTION survives as a callable, not a name",
	oFresh._GetFunctionName(aBack[1][:function]) = "ConstraintFunc_NoSelfLoop")
chk("... for each type in turn",
	oFresh._GetFunctionName(aBack[2][:function]) = "DerivationFunc_Transitivity" and
	oFresh._GetFunctionName(aBack[3][:function]) = "ValidationFunc_IsAcyclic")
chk("the resolved function IS the original object",
	aBack[1][:function] = ConstraintFunc_NoSelfLoop())

chk("params survive too", aBack[2][:params][:relation] = "reports_to")

? ""
? "-- Scene 4: what the format REFUSES --"

# A rule type Ring never heard of is a malformed file. _AddUniqueRule alone
# would simply not route it and the rule would go missing in silence, so the
# parser says so instead.
write("_rt_bad.stzrulz", "rules" + NL + NL +
	"    rule mystery" + NL +
	"        type: telepathy" + NL +
	"        severity: error" + NL)

bRaised = 0
try
	oBad = new stzGraph("bad")
	oBad.LoadFromStzRulz("_rt_bad.stzrulz")
catch
	bRaised = 1
done
chk("an unknown rule type REFUSES loudly (never a silent drop)", bRaised = 1)

bMissing = 0
try
	oMiss = new stzGraph("miss")
	oMiss.LoadFromStzRulz("_no_such_file.stzrulz")
catch
	bMissing = 1
done
chk("a missing file refuses too", bMissing = 1)

? ""
? "-- Scene 5: a name is unique WITHIN its type --"

oDup = new stzGraph("dup")
oDup._AddUniqueRule([ :name = "r1", :type = :constraint,
	:function = ConstraintFunc_NoSelfLoop(), :params = [],
	:message = "first", :severity = :error ])
oDup._AddUniqueRule([ :name = "r1", :type = :constraint,
	:function = ConstraintFunc_NoCycles(), :params = [],
	:message = "second", :severity = :error ])
chk("the same name twice in one type is refused", oDup.NumberOfRules() = 1)
chk("... and the FIRST one stands", oDup.Rules()[1][:message] = "first")

oDup._AddUniqueRule([ :name = "r1", :type = :validation,
	:function = ValidationFunc_IsAcyclic(), :params = [],
	:message = "a validation may share the name", :severity = :info ])
chk("but the same name under ANOTHER type is a different rule",
	oDup.NumberOfRules() = 2)

remove("_rt_probe.stzrulz")
remove("_rt_bad.stzrulz")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
