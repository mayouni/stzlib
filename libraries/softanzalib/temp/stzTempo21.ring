Load "zerolib.ring"



List = Z( [9,3,7,5,6,4,8,2] )

listSize = len(List)

quickSortAlgorithm(List,0,listSize-1)



Func quickSortAlgorithm(List,LB,UB){

	if LB < UB
	
		vlocation = partitionListFunc(List,LB,UB)
		
		quickSortAlgorithm(List,LB,vlocation-1)
		
		quickSortAlgorithm(List,vlocation+1,UB)
	
	ok
	
	}
	
	
	
Func partitionListFunc(List,LB,UB){

	pivotElement = List[0]
	
	StartPosition = LB
	
	EndPosition = UB
	
	while StartPosition < EndPosition
	
	while List[StartPosition] <= pivotElement
	
	StartPosition+=1
	
	end
	
	while List[EndPosition] > pivotElement
	
	EndPosition+=1
	
	end
	
	if StartPosition < EndPosition
	
	List.swap(StartPosition,EndPosition)
	
	ok
	
	end
	
	List.swap(LB,EndPosition)
	
	return EndPosition
	
	}

