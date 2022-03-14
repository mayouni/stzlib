
/*
Until(:v).Is("12000").DoThis('{ v += "0" ? v }')
Since(:v).Is("12").DoThis('{ v += "0" ? v }').StopWhen(v).Is("1200000")
*/

aChainInfo = [
	# $cValueInitiator
	:Initiator = :Since,
	# @cVarName
	:VarName = "v",

	:VarDefinedInMemory = :Yes,
	# @pValue
	:ActualValueInMemory = "12",
	# @cType
	:TypeOfAcualValueInMemory = NULL,

	:ValueRecords = [ :timestamp1 = value1, :timestamp2 = value2, :timestamp3 = value3 ]
	# Useful to Was()

	:CriticalValue = "12",
	:TypeOfCrticalValue = NULL,
	:CriticalValueDefinedBy = "Is()",

	# $bRandomPass
	:RandomPass = :Yes, # In case of SometimesWhen()

	# $cOneOrManyLoops
	:OneOrManyLoops = :One, # or :Many
	:NumberOfLoops = NULL, # or 3 in case for i = 1 to 3

	# @bChainStopped
	:ChainStopped = FALSE,
	# @aChainStopInfo
	:ChainStopCause = [ "", "", "" ]

	# @bNegateNext = FALSE
	:NegateNext = FALSE

	# $pStopValue
	:StopValue = "1200000", # Chain must stop when it reaches that value
	# $bRequiresEndPoint
	:RequiresEndPoint = :Yes, # In case of Since()

	# $bExecuteCode
	:ExecuteCode = :No, # To deactivate code execution
	:DoThisCode = '{ v += "0" ? v }',
	:DoThisCodeContainsVar = :Yes # Useful to detect errors in some situations

	:ProcessingSteps = [
		:Step1 = [ :in = value, :modifyier = "", :out = value ],
		:Step2 = [ :in = value, :modifyier = "", :out = value ],
		:Step3 = [ :in = value, :modifyier = "", :out = value ]
	]
]
