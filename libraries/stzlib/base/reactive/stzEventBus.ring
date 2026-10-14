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

# Gives access to the engine's process-wide event bus: named channels, subscribers, and payloads emitted to them.
#
# Channels live in the engine and are global to the process, so an emitter and an agent host in the
# same process communicate through two handles on one bus. An agent supervised on a channel has its
# perceive-and-act loop driven by emitted events and not only by a timer. Emit counts the event and
# keeps the payload even with no subscriber and answers how many were delivered. A consumer polls
# EventCount to detect new work; because DestroyChannel and ClearAll restart the count, it compares
# ChannelGeneration, which never repeats, to notice a channel that was remade. ClearAll resets
# channels other code may be watching.
#
#   receiver   o1 = StzEventBus() o1.ClearAll() o1.Channel("orders") nSub = o1.Subscribe("orders")
#   example    ? o1.SubscriberCount("orders")
#              #--> 1
#              ? o1.Emit("orders", "burger")
#              #--> 1
#              ? o1.EventCount("orders")
#              #--> 1
#              ? o1.LastEvent("orders")
#              #--> burger
#              ? o1.Unsubscribe(nSub)
#              #--> 0
#              ? o1.Emit("orders", "tajine")
#              #--> 0
#              ? o1.EventCount("orders")
#              #--> 2
#              ? o1.EventCount("nowhere")
#              #--> -2
#   see        stzAgentHost, stzPerfSentinel, stzReactiveTask
class stzEventBus from stzObject

	# Builds a handle on the engine's process-wide event bus; the handle holds no state of its own.
	#
	#   returns    nothing; the object is built
	#   note       StzEventBus builds the same object; two handles in one process see the same
	#              channels
	#   see        Channel, Emit
	def init()
	# Declares a channel by name, doing nothing if it already exists.
	#
	#   pcName     the name of the channel, such as orders
	#   returns    the bus itself, so calls chain
	#   note       Subscribe and Emit also declare a channel they are given
	#   see        HasChannel, Emit, Subscribe
	#@ aka  stateless: the bus lives in the engine (process-global channels)
	def Channel(pcName)
		stzengine_reactive_create_channel("" + pcName)
		return This

	# TRUE if a channel with a name exists.
	#
	#   pcName     the name of the channel
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a channel exists from its first declaration until DestroyChannel or ClearAll
	#   see        Channel, NumberOfChannels
	def HasChannel(pcName)
		# a channel exists once created; sub_count is -1 / event_count works
		return stzengine_reactive_event_count("" + pcName) >= 0

	# Subscribes to a channel, declaring it if needed, and returns the subscriber's id.
	#
	#   pcName     the name of the channel
	#   returns    a number above 0, the subscriber id
	#   note       ids are unique and rise; the same caller may subscribe twice and is then two
	#              subscribers
	#   see        Unsubscribe, SubscriberCount, Emit
	#@ aka  Subscribe to a channel (auto-declares it). Returns a subscriber id (>0) or a negative error.
	def Subscribe(pcName)
		stzengine_reactive_create_channel("" + pcName)
		return stzengine_reactive_subscribe("" + pcName)

	# Removes a subscriber by its id.
	#
	#   nSubId     the id Subscribe gave
	#   returns    0 when removed; -2 for an id that is not subscribed, including one already
	#              removed
	#   see        Subscribe, SubscriberCount
	def Unsubscribe(nSubId)
		return stzengine_reactive_unsubscribe(nSubId)

	# Publishes a payload on a channel, declaring it if needed.
	#
	#   pcName     the name of the channel
	#   pcData     the payload, turned into text
	#   returns    how many subscribers it was delivered to; 0 when there are none
	#   note       the event is counted and kept as the last event even when nobody is subscribed
	#   see        EventCount, LastEvent, Subscribe
	#@ aka  Emit a payload on a channel (auto-declares it). Returns how many subscribers it was delivered to.
	def Emit(pcName, pcData)
		stzengine_reactive_create_channel("" + pcName)
		return stzengine_reactive_emit("" + pcName, "" + pcData)

	# Returns how many events were emitted on a channel since it was created.
	#
	#   pcName     the name of the channel
	#   returns    a number; -2 for a channel that does not exist
	#   note       it rises while the channel lives but DestroyChannel and ClearAll put it back to 0
	#              or remove it, so a consumer that only tests for a bigger number than last time
	#              must treat a smaller one as a new channel and compare ChannelGeneration
	#   see        LastEvent, ChannelGeneration
	#@ aka  Total events emitted on the channel SINCE IT WAS CREATED -- the signal an event-driven consumer polls to detect new work.
	def EventCount(pcName)
		return stzengine_reactive_event_count("" + pcName)

	# Returns how many subscribers a channel has.
	#
	#   pcName     the name of the channel
	#   returns    a number; -2 for a channel that does not exist
	#   see        Subscribe, Unsubscribe
	def SubscriberCount(pcName)
		return stzengine_reactive_sub_count("" + pcName)

	# Returns the most recent payload emitted on a channel.
	#
	#   pcName     the name of the channel
	#   returns    the payload as text; an empty text when none was emitted or the channel does not
	#              exist
	#   note       a number emitted is read back as text, 42 as 42
	#   see        EventCount, Emit
	#@ aka  The most recent payload emitted on the channel ("" if none).
	def LastEvent(pcName)
		return stzengine_reactive_last_event("" + pcName)

	# Returns which incarnation of a name a channel is, a number that never repeats in the process.
	#
	#   pcName     the name of the channel
	#   returns    a number above 0; -2 when no channel has the name
	#   note       a channel destroyed and declared again has a different generation, which is exact
	#              where a falling count can be missed
	#   see        EventCount, DestroyChannel
	#@ aka  WHICH channel currently holds this name -- a number unique to this process, or -2 when no channel does.
	def ChannelGeneration(pcName)
		return stzengine_reactive_channel_generation("" + pcName)

	# Returns how many channels exist.
	#
	#   returns    a number
	#   note       the bus is process-wide, so channels made by other parts of the process count
	#   see        HasChannel, ClearAll
	def NumberOfChannels()
		return stzengine_reactive_channel_count()

	# Removes a channel and its subscribers.
	#
	#   pcName     the name of the channel
	#   returns    0 when removed; -2 for a channel that does not exist
	#   note       its event count restarts from 0 if it is declared again
	#   see        ClearAll, ChannelGeneration
	def DestroyChannel(pcName)
		return stzengine_reactive_destroy_channel("" + pcName)

	# Removes every channel in the process.
	#
	#   returns    the bus itself, so calls chain
	#   note       useful for test isolation, but it resets channels that other parts of the process
	#              are watching
	#   see        DestroyChannel, NumberOfChannels
	#@ aka  Wipe every channel.
	def ClearAll()
		stzengine_reactive_clear_all()
		return This
