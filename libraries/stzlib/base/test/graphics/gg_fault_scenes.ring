# THE FAULT TREE SCENES, AS FUNCTIONS TWO FILES SHARE (DN17).
#
# The catalogue renders them; the gate holds them to their rules and
# checks their numbers. Functions only: loading this file draws nothing.

# A PUMP THAT FAILS TO START. Either the motor is seized, or there is no
# power -- and there is no power only when the mains are out AND the
# battery is flat. Top = 1 - (1 - 0.1 x 0.2)(1 - 0.05) = 0.069; the cut
# sets are { seized } and { mains, battery }.
func StzFaultScene01(paOpt)
	_o_ = new stzFaultTree("pump")
	_o_.AddTop("top", "Pump fails to start")
	_o_.AddEvent("power", "No power")
	_o_.AddBasicXT("seized", "Motor seized", 0.05)
	_o_.AddBasicXT("mains", "Mains out", 0.1)
	_o_.AddBasicXT("battery", "Battery flat", 0.2)
	_o_.Develop("top", :Or, [ "power", "seized" ])
	_o_.Develop("power", :And, [ "mains", "battery" ])
	_o_.ToCanvasXT(paOpt)
	return _o_

# A REPEATED EVENT. The same sensor fault sits under both branches, so
# the gate arithmetic -- which assumes independence -- overstates the
# top: 1 - (1 - 0.02)(1 - 0.03) = 0.0494, where the cut sets
# { sensor, valve } and { sensor, relay } give the exact 0.044.
func StzFaultScene02(paOpt)
	_o_ = new stzFaultTree("repeated")
	_o_.AddTop("top", "Tank overflows")
	_o_.AddEvent("fill", "Fill not stopped")
	_o_.AddEvent("alarm", "Alarm not raised")
	_o_.AddBasicXT("sensor", "Level sensor stuck", 0.1)
	_o_.AddBasicXT("valve", "Valve fails open", 0.2)
	_o_.AddBasicXT("relay", "Relay welded", 0.3)
	_o_.Develop("top", :Or, [ "fill", "alarm" ])
	_o_.Develop("fill", :And, [ "sensor", "valve" ])
	_o_.Develop("alarm", :And, [ "sensor", "relay" ])
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE WITNESS: one of each mistake. Two top events; a gate with one
# input; a basic event with no probability; an intermediate event with
# no gate; a cause among its own effects. And two things that are NOT
# mistakes and every rule must leave alone: an undeveloped event that
# says so, and a note, which is not of the tree.
func StzFaultSceneWitness(paOpt)
	_o_ = new stzFaultTree("witness")
	_o_.AddTop("t1", "Line stops")
	_o_.AddTop("t2", "Second top")
	_o_.AddEvent("jam", "Jam")
	_o_.AddEvent("bare", "Undeveloped, unsaid")
	_o_.AddBasic("dust", "Dust")
	_o_.AddBasicXT("wear", "Belt worn", 0.02)
	_o_.AddUndeveloped("operator", "Operator absent")
	_o_.AddNote("n1", "draft of 2026-09-09")
	_o_.Develop("t1", :Or, [ "jam", "bare", "operator" ])
	# the jam is caused by the dust, the wear -- and by the line stopping
	_o_.Develop("jam", :And, [ "dust", "wear", "t1" ])
	_o_.Develop("t2", :Or, [ "wear" ])
	_o_.ToCanvasXT(paOpt)
	return _o_
