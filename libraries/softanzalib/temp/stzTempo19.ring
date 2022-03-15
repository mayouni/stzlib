load "softanzalib.ring"
/*
oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType()
? oList.ItemsAreAllEmptyLists()


/*
		AreAll		Type+IsFunction
		ItemsAreAllUnaryLists() --> TRUE/FALSE

		//Items( Are(:List), And(:IsUnary) )

		Have		Same+Function+RegardlessOfFunction
		ItemsHaveSameValueRegardlessOfType() --> TRUE/FALSE

		//Items( Have( Same(:Value) ), RegardlessOf(:Type) ) -> Implicit And

		Include		Type+IsFunction+RegardlessOfFunction
		ItemsIncludeUnaryLists() --> TRUE/FALSE
		ItemsIncludeNumbersRegardlessOfType() --> TRUE/FALSE

	Items	ThatAre		Type+IsFunction
		ItemsThatAreUnaryLists() --> LIST
	
		Having		Same+Function+RegardlessOfFunction
		ItemsHavingSameValueRegardlessOfType() --> LIST

		Including	Type+IsFunction+RegardlessOfFunction
		ItemsIncludingUnaryLists() --> LIST
		ItemsIncludingNumbersRegardlessOfType() --> LIST
*/



