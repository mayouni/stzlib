# THE PETRI NET SCENES, AS FUNCTIONS TWO FILES SHARE (DN16).
#
# The catalogue renders them; the gate holds them to their rules and plays
# the token game on them. Functions only: loading this file draws nothing.

# A MUTEX. Two processes and one key: each waits, takes the key to enter
# its critical section, and gives it back on leaving. Sound under every
# rule, and the game shows the exclusion -- with one inside, the other
# cannot enter.
func StzPetriScene01(paOpt)
	_o_ = new stzPetriNet("mutex")
	_o_.AddPlaceXT("w1", "Waiting A", 1)
	_o_.AddPlaceXT("key", "Key", 1)
	_o_.AddPlaceXT("w2", "Waiting B", 1)
	_o_.AddPlace("c1", "Critical A")
	_o_.AddPlace("c2", "Critical B")
	_o_.AddTransition("e1", "Enter A")
	_o_.AddTransition("l1", "Leave A")
	_o_.AddTransition("e2", "Enter B")
	_o_.AddTransition("l2", "Leave B")
	_o_.Arc("w1", "e1")   _o_.Arc("key", "e1")   _o_.Arc("e1", "c1")
	_o_.Arc("c1", "l1")   _o_.Arc("l1", "w1")    _o_.Arc("l1", "key")
	_o_.Arc("w2", "e2")   _o_.Arc("key", "e2")   _o_.Arc("e2", "c2")
	_o_.Arc("c2", "l2")   _o_.Arc("l2", "w2")    _o_.Arc("l2", "key")
	_o_.ToCanvasXT(paOpt)
	return _o_

# A BUFFER WITH WEIGHTS. Five free slots; a producer fills two at a
# time, a consumer empties one. Tokens beyond four read as a number.
func StzPetriScene02(paOpt)
	_o_ = new stzPetriNet("buffer")
	_o_.AddPlaceXT("free", "Free", 5)
	_o_.AddPlace("full", "Full")
	_o_.AddTransition("put", "Put")
	_o_.AddTransition("take", "Take")
	_o_.ArcXT("free", "put", 2)   _o_.ArcXT("put", "full", 2)
	_o_.Arc("full", "take")   _o_.Arc("take", "free")
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE WITNESS: one of each mistake. An arc from a place to a place; a
# transition with no input; one with no output; a place empty forever
# and the transition it starves; and a note, which is not of the net.
func StzPetriSceneWitness(paOpt)
	_o_ = new stzPetriNet("witness")
	_o_.AddPlace("p1", "Never")
	_o_.AddPlace("p2", "Mid")
	_o_.AddPlace("p3", "Sink in")
	_o_.AddPlace("p4", "Stray")
	_o_.AddTransition("t1", "Starved")
	_o_.AddTransition("t0", "Source")
	_o_.AddTransition("t2", "Sink")
	_o_.AddNote("n1", "draft of 2026-09-09")
	_o_.Arc("p1", "t1")   _o_.Arc("t1", "p2")
	_o_.Arc("p2", "p4")
	_o_.Arc("t0", "p3")   _o_.Arc("p3", "t2")
	_o_.ToCanvasXT(paOpt)
	return _o_
