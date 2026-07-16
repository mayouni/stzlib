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

	# Total events ever emitted on the channel (monotonic -- the signal an
	# event-driven consumer polls to detect new work).
	def EventCount(pcName)
		return stzengine_reactive_event_count("" + pcName)

	def SubscriberCount(pcName)
		return stzengine_reactive_sub_count("" + pcName)

	# The most recent payload emitted on the channel ("" if none).
	def LastEvent(pcName)
		return stzengine_reactive_last_event("" + pcName)

	def NumberOfChannels()
		return stzengine_reactive_channel_count()

	def DestroyChannel(pcName)
		return stzengine_reactive_destroy_channel("" + pcName)

	# Wipe every channel (test isolation -- the bus is process-global).
	def ClearAll()
		stzengine_reactive_clear_all()
		return This
