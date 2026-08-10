# base/reactive/stzEventBus.ring
# -----------------------------------------------------------------------------
# R5 (reactor-runtime) -- stzEventBus: the OO surface over the engine event
# bus (engine/src/reactive.zig, stz_reactive.dll). The bus was BUILT + LOADED
# but ORPHANED -- no Ring callers. This wrapper un-orphans it and gives the
# agentic runtime an event source: agents can be supervised ON A CHANNEL
# (stzAgentHost.SuperviseOnEvent) so their perceive-decide-act loop is driven
# by EMITTED EVENTS, not only a fixed timer -- "the perceive-act loop IS an
# event loop."
#
#   oBus = new stzEventBus()
#   oBus.Channel("orders")           # declare a channel
#   oBus.Subscribe("orders")         # -> a subscriber id
#   oBus.Emit("orders", "burger")    # -> number of subscribers delivered to
#   ? oBus.EventCount("orders")      # total events emitted on the channel
#   ? oBus.LastEvent("orders")       # the most recent payload
#
# Channels are engine-global (a process-wide bus), so two stzEventBus handles
# see the same channels -- that is what lets an emitter and an agent host in
# the same process communicate.
# -----------------------------------------------------------------------------

func StzEventBus()
	return new stzEventBus()

class stzEventBus from stzObject

	def init()
		# stateless: the bus lives in the engine (process-global channels)

	# Declare (idempotently) a channel. Returns This for chaining.
	def Channel(pcName)
		stzengine_reactive_create_channel("" + pcName)
		return This

	def HasChannel(pcName)
		# a channel exists once created; sub_count is -1 / event_count works
		return stzengine_reactive_event_count("" + pcName) >= 0

	# Subscribe to a channel (auto-declares it). Returns a subscriber id (>0)
	# or a negative error.
	def Subscribe(pcName)
		stzengine_reactive_create_channel("" + pcName)
		return stzengine_reactive_subscribe("" + pcName)

	def Unsubscribe(nSubId)
		return stzengine_reactive_unsubscribe(nSubId)

	# Emit a payload on a channel (auto-declares it). Returns how many
	# subscribers it was delivered to.
	def Emit(pcName, pcData)
		stzengine_reactive_create_channel("" + pcName)
		return stzengine_reactive_emit("" + pcName, "" + pcData)

	# Total events emitted on the channel SINCE IT WAS CREATED -- the signal an
	# event-driven consumer polls to detect new work.
	#
	# It rises and never falls WHILE THE CHANNEL LIVES, which is not the same
	# as monotonic, and the difference bites. DestroyChannel and ClearAll below
	# put a channel back to zero, so a consumer holding a previous count sees a
	# SMALLER number and, if it only tests for "bigger than last time", decides
	# there is no new work -- for good. A DECREASE means the channel is new and
	# the consumer must re-baseline; stzAgentHost.TickDue does exactly that.
	def EventCount(pcName)
		return stzengine_reactive_event_count("" + pcName)

	def SubscriberCount(pcName)
		return stzengine_reactive_sub_count("" + pcName)

	# The most recent payload emitted on the channel ("" if none).
	def LastEvent(pcName)
		return stzengine_reactive_last_event("" + pcName)

	# WHICH channel currently holds this name -- a number unique to this
	# process, or -2 when no channel does.
	#
	# EventCount alone cannot tell a consumer that a channel was remade: the
	# count restarts at zero, and by the time anyone polls it may already have
	# climbed back above the value they remembered, so "did the number go down"
	# misses it. The generation never repeats and never resets, so comparing it
	# is exact rather than a race. stzAgentHost.TickDue re-baselines on it.
	def ChannelGeneration(pcName)
		return stzengine_reactive_channel_generation("" + pcName)

	def NumberOfChannels()
		return stzengine_reactive_channel_count()

	def DestroyChannel(pcName)
		return stzengine_reactive_destroy_channel("" + pcName)

	# Wipe every channel.
	#
	# Handy for test isolation, and worth saying plainly: the bus is
	# PROCESS-GLOBAL, so this resets channels other parts of the same process
	# are watching, and their event counts restart at zero. See EventCount.
	def ClearAll()
		stzengine_reactive_clear_all()
		return This
