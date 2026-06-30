load "../../stzBase.ring"
load "../_narrated.ring"

# Ways to write "N copies of X": @N(n,x) / Three(x) / @3(x) give a LIST; @NXT
# with :InAString joins them. They feed StartsWith / EndsWith(XT), and the fluent
# StartsWithXTQ(..).AndQ().EndsWithXT(..) chain (TRUE iff both hold). Archive #8.

Scenario("Writing N copies and matching prefixes/suffixes")
	Then("@N(3,'.') is a list of three dots", ListEq( @N(3, "."), [ ".", ".", "." ] ), TRUE)
	Then("@NXT(3,'.',:InAList) is the same list", ListEq( @NXT(3, ".", :InAList), [ ".", ".", "." ] ), TRUE)
	Then("@NXT(3,'.',:InAString) joins them", @NXT(3, ".", :InAString), "...")
	Then("Three('.') is a list of three dots", ListEq( Three("."), [ ".", ".", "." ] ), TRUE)
	Then("@3('.') is a list of three dots", ListEq( @3("."), [ ".", ".", "." ] ), TRUE)

	Then("a list starting with three dots", Q([ ".", ".", ".", "Tunis" ]).StartsWith( @3(".") ), TRUE)
	Then("'...Tunis' starts with '...'", Q("...Tunis").StartsWith("..."), TRUE)
	Then("'...Tunis' starts with @3('.')", Q("...Tunis").StartsWithXT( @3(".") ), TRUE)
	Then("'..Tunis..' ends with @2('.')", Q("..Tunis..").EndsWithXT( @2(".") ), TRUE)
	Then("'...Tunis..' starts with @3('.') AND ends with @2('.')",
		Q("...Tunis..").StartsWithXTQ( @3(".") ).AndQ().EndsWithXT( @2(".") ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
