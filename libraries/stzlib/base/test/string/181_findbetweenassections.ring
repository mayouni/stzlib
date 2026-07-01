load "../../stzBase.ring"
load "../_narrated.ring"

# FindBetweenAsSections(sub, open, close) and FindAsSectionsXT(sub, :Between=[..])
# locate `sub` between the markers, as [from,to] spans. They must AGREE. (The
# exact spans here depend on how Ring escapes the backslashes in the given string,
# so we assert the two forms are EQUAL rather than pinning literal spans.)
# Archive block #181.

Scenario("Finding a substring between markers, two spellings agree")
	Given('"/♥♥♥\__/\/\__/♥♥♥\__"')
	o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
	Then("FindBetweenAsSections and FindAsSectionsXT(:Between) return the same spans",
		ListEq( o1.FindBetweenAsSections("♥♥♥", "/", "\"),
			o1.FindAsSectionsXT("♥♥♥", :Between = ["/","\"]) ), TRUE)
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
