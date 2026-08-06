load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveStream -- WHAT AN OVERFLOW STRATEGY ACTUALLY DOES.
#
# An audit ran the four documented strategies against the same load: four items
# into a buffer of two. Three of them lost data and reported none.
#
# Only :DROP incremented @droppedCount. So a stream on the DEFAULT strategy
# discarded everything past capacity while OverflowStats() answered "dropped 0"
# -- and that count is the one number a caller reads to learn whether data was
# lost. :LATEST under-reported the same way: it evicts the oldest to make room,
# and an evicted item is gone whatever the reason for evicting it.
#
# The class had no assertion suite of any kind; its 22 files are demonstrations.
# This is the first.

pr()

Scenario("Every strategy counts what it loses")

	# The load is identical in each case, so the numbers are comparable: four
	# items into a buffer of two means two are kept and two are lost, whatever
	# the strategy decides to keep.

	Given("four items fed into a buffer of two")

	Then("BUFFER_EXPAND keeps two", KeptUnder(BUFFER_EXPAND), 2)
	Then("...and admits losing two", LostUnder(BUFFER_EXPAND), 2)

	Then("BUFFER_REJECT_NEWEST keeps two", KeptUnder(BUFFER_REJECT_NEWEST), 2)
	Then("...and admits losing two", LostUnder(BUFFER_REJECT_NEWEST), 2)

	Then("BUFFER_EVICT_OLDEST keeps two", KeptUnder(BUFFER_EVICT_OLDEST), 2)
	Then("...and admits losing two", LostUnder(BUFFER_EVICT_OLDEST), 2)

	Then("BUFFER_BLOCK keeps two", KeptUnder(BUFFER_BLOCK), 2)
	Then("...and admits losing two", LostUnder(BUFFER_BLOCK), 2)

	# THE NEGATIVE SIBLING, and the one that makes the eight above mean
	# something: a stream that never overflows must report NO loss. Without it,
	# a counter that simply incremented on every item would pass all of them.
	Given("two items fed into a buffer of two")
	Then("nothing is lost", LostWith(BUFFER_EXPAND, 2, 2), 0)
	Then("...and both are kept", KeptWith(BUFFER_EXPAND, 2, 2), 2)

	# ...and the strategies are not all the same thing wearing four names:
	# EVICT_OLDEST keeps the LAST items fed, REJECT_NEWEST keeps the FIRST.
	Given("the difference between evicting and rejecting")
	Then("evict-oldest ends up holding the last item", HoldsLast(BUFFER_EVICT_OLDEST), TRUE)
	Then("...while reject-newest holds the first", HoldsLast(BUFFER_REJECT_NEWEST), FALSE)
EndScenario()

Scenario("A stream can be spelled the way it sounds")

	# Recieve, RecieveMany and OnRecieved all have i before e, so the obvious
	# name did not exist. The old spellings stay -- someone may have typed them.

	Given("a stream fed through the correctly spelled names")
	Then("Receive reaches the buffer", ReceivedCount(:Correct), 1)
	Then("...and so does the old Recieve", ReceivedCount(:Old), 1)
	# The batch form ends by processing ONE item off the buffer ("Process buffer
	# after batch emission"), so three fed leaves two waiting -- delivered, not
	# lost, which is why droppedCount stays 0. What matters here is that the two
	# spellings do the SAME thing, so they are compared against each other rather
	# than against a number that encodes that quirk.
	Then("ReceiveMany takes a list", ManyCount(:Correct) > 0, TRUE)
	Then("...and both spellings agree exactly", ManyCount(:Correct), ManyCount(:Old))
	Then("...and a batch loses nothing", ManyDropped(:Correct), 0)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

func FedStream(pStrategy, pnBuffer, pnItems)
	_oRs_ = new stzReactiveSystem()
	_oSt_ = _oRs_.CreateStream("probe")
	_oSt_.SetOverflowStrategy(pStrategy, pnBuffer)
	for _i_ = 1 to pnItems
		_oSt_.Receive(_i_)
	next
	return _oSt_.OverflowStats()

func KeptUnder(pStrategy)
	return FedStream(pStrategy, 2, 4)[:currentBuffer]

func LostUnder(pStrategy)
	return FedStream(pStrategy, 2, 4)[:droppedCount]

func KeptWith(pStrategy, pnBuffer, pnItems)
	return FedStream(pStrategy, pnBuffer, pnItems)[:currentBuffer]

func LostWith(pStrategy, pnBuffer, pnItems)
	return FedStream(pStrategy, pnBuffer, pnItems)[:droppedCount]

# Does the buffer end up holding the LAST item fed? Evicting the oldest does;
# rejecting the newest does not.
func HoldsLast(pStrategy)
	_aSeen_ = []
	_oRs_ = new stzReactiveSystem()
	_oSt_ = _oRs_.CreateStream("probe")
	_oSt_.SetOverflowStrategy(pStrategy, 2)
	for _i_ = 1 to 4
		_oSt_.Receive(_i_)
	next
	_oSt_.DrainBuffer()
	return _oSt_.OverflowStats()[:currentBuffer] = 0 and HeldLast(pStrategy)

# Read the buffer directly: the last item fed is 4.
func HeldLast(pStrategy)
	_oRs2_ = new stzReactiveSystem()
	_oSt2_ = _oRs2_.CreateStream("probe2")
	_oSt2_.SetOverflowStrategy(pStrategy, 2)
	for _i_ = 1 to 4
		_oSt2_.Receive(_i_)
	next
	return StzFindFirst(4, _oSt2_.@buffer) > 0

func ReceivedCount(pWhich)
	_oRs3_ = new stzReactiveSystem()
	_oSt3_ = _oRs3_.CreateStream("probe3")
	_oSt3_.SetOverflowStrategy(BUFFER_EXPAND, 10)
	if pWhich = :Correct
		_oSt3_.Receive(1)
	else
		_oSt3_.Recieve(1)
	ok
	return _oSt3_.OverflowStats()[:currentBuffer]

func ManyCount(pWhich)
	_oRs4_ = new stzReactiveSystem()
	_oSt4_ = _oRs4_.CreateStream("probe4")
	_oSt4_.SetOverflowStrategy(BUFFER_EXPAND, 10)
	if pWhich = :Correct
		_oSt4_.ReceiveMany([ 1, 2, 3 ])
	else
		_oSt4_.RecieveMany([ 1, 2, 3 ])
	ok
	return _oSt4_.OverflowStats()[:currentBuffer]

func ManyDropped(pWhich)
	_oRs5_ = new stzReactiveSystem()
	_oSt5_ = _oRs5_.CreateStream("probe5")
	_oSt5_.SetOverflowStrategy(BUFFER_EXPAND, 10)
	if pWhich = :Correct
		_oSt5_.ReceiveMany([ 1, 2, 3 ])
	else
		_oSt5_.RecieveMany([ 1, 2, 3 ])
	ok
	return _oSt5_.OverflowStats()[:droppedCount]
