load "stzlib.ring"

@C = @("C") {
	evtOnItemAdded { ? "Anything you need!" }
}

oLetters = new stzDynamicList([ "A", "B", @C, "D" , @("E") ])

oLetters {
	? "" ? Content()
	AddItem("Z")
	AddActiveItem("W") { aDoWhenAdded = [ :Say, ["I'm added now!"] ]}
	? ""
	ReplaceItem(3, @("X")) //{ aDoWhenAssigned = [ :Say, ["Ho! Assigned."] ]} )

	? "" ? Content()	
}
