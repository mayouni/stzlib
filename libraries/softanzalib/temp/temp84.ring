load "stzlib.ring"

cURL = "https://www.musixmatch.com/fr/paroles/H%C3%A9di-Jouini/Lioum-Galitli-Zine-Zin"

o1 = new stzString("")
? o1.FromURLQ(cURL).SectionQ(
	o1.FindFirstOccurrence("<p>"),
	o1.FindFirstOccurrence("</p>")
).StringParts(:ByOrientation)

/*

o1 = new stzList([ "a", "b", [1,2,3], "c" ])
? o1.Contains([1,2,3])

o1 = new stzList([1,2,3])
? o1.IsContainedIn([ "a", "b", [1,2,3], "c" ])

