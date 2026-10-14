#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZINTSEQ                    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Lightweight Ring-side wrapper around the    #
#                  engine IntSeq feature. Holds a handle to a  #
#                  Zig-allocated []i64 backing store; exposes  #
#                  list-shape access (Count, At, First, Last,  #
#                  Sum, Min, Max, ToList) via O(1) / O(N)      #
#                  engine calls.                                #
#                                                              #
#                  Purpose: when a Softanza method needs to    #
#                  produce a large numeric sequence, returning #
#                  an stzIntSeq instead of a Ring list keeps   #
#                  the whole pipeline in engine-fast territory #
#                  (no per-item Ring list ops). Callers that   #
#                  truly need a Ring list opt-in via .ToList().#
#                                                              #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#--------------------------------------------------------------#

func StzIntSeqQ(pHandle)
	return new stzIntSeq(pHandle)

# Wraps a sequence of integers held in the engine, so sums, extremes and counts are computed there without building a Ring list.
#
# Obtain one from stzCounter.CountingQ. The sequence stays in the engine: Sum, Min, Max, At and
# CountValue read it directly, and ToList copies it out when a Ring list is needed. Positions count
# from 1. The object owns the engine sequence and Release frees it; Disown hands the ownership away.
#
#   receiver   oC = new stzCounter([ :StartAt = 1, :WhenYouReach = 4, :RestartAt = 0 ]) o1 =
#              oC.CountingQ(10)
#   example    ? o1.NumberOfItems()
#              #--> 10
#              ? o1.Sum()
#              #--> 15
#              ? o1.CountValue(0)
#              #--> 2
#              ? @@( o1.ToList() )
#              #--> [ 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 ]
#   see        stzCounter
class stzIntSeq from stzObject

	@pHandle = ""
	@bOwned  = 1

	# Wraps an engine integer sequence that already exists, taking ownership of it so Release can free it.
	#
	#   pHandle    the engine handle of the integer sequence, as produced by an engine call such as
	#              the one behind CountingQ
	#   returns    nothing; the object is built
	#   see        Release, Disown, Handle
	def init(pHandle)
		# Accept a raw engine handle (returned by
		# StzEngineIntSeqCreateCycle and friends).
		@pHandle = pHandle

	# Returns the engine handle of the sequence, a number that identifies it in the engine.
	#
	#   returns    a number; an empty text once released
	#   see        Release, init
	def Handle()
		return @pHandle

	# Frees the engine sequence, unless the object was told to disown it, and empties the handle.
	#
	#   returns    nothing
	#   note       a disowned object keeps the engine sequence alive, so it stays readable and is
	#              never freed by this object
	#   warning    after Release the sequence reads as empty
	#   see        Disown, Handle
	  #--- Lifecycle ---
	def Release()
		# Free the underlying engine handle. Idempotent: a second
		# Release() is a no-op so wrappers that get borrowed don't
		# double-free.
		if @bOwned and @pHandle != ""
			StzEngineIntSeqFree(@pHandle)
			@pHandle = ""
		ok

	# Tells the object that it no longer owns the engine sequence, so Release will not free it.
	#
	#   returns    nothing
	#   see        Release
	def Disown()
		# Caller takes ownership of the handle: this object won't
		# free it. Use when handing the handle off to another wrapper.
		@bOwned = 0

	# Returns how many numbers the sequence holds.
	#
	#   returns    a number
	#   see        At, ToList
	  #--- Read accessors (all O(1) or O(N) in engine, no Ring loops) ---
	def NumberOfItems()
		return StzEngineIntSeqLen(@pHandle)

		def Count()
			return This.NumberOfItems()

		def Size()
			return This.NumberOfItems()

	# Returns the number at a position, counted from 1; 0 when the position is below 1, beyond the end or not a number.
	#
	#   n          the position of the item, starting at 1
	#   returns    a number
	#   warning    0 is also a real value of a cycle, so At(5) of a short sequence cannot be told
	#              from a stored 0
	#   see        First, Last, ToList
	#@ aka  1-based access to match Ring/Softanza convention; engine is 0-based.
	def At(n)
		if NOT isNumber(n) or n < 1
			return 0
		ok
		return StzEngineIntSeqAt(@pHandle, n - 1)

		def Item(n)
			return This.At(n)

		def Nth(n)
			return This.At(n)

	# Returns the first number of the sequence.
	#
	#   returns    a number
	#   see        Last, At
	def First()
		return StzEngineIntSeqFirst(@pHandle)

		def FirstItem()
			return This.First()

	# Returns the last number of the sequence.
	#
	#   returns    a number
	#   see        First, At
	def Last()
		return StzEngineIntSeqLast(@pHandle)

		def LastItem()
			return This.Last()

	# Returns the total of all the numbers, computed in the engine.
	#
	#   returns    a number
	#   see        Min, Max
	  #--- Bulk-query operations (stay in Zig) ---
	def Sum()
		return StzEngineIntSeqSum(@pHandle)

	# Returns the smallest number of the sequence.
	#
	#   returns    a number
	#   see        Max, Sum
	def Min()
		return StzEngineIntSeqMin(@pHandle)

	# Returns the largest number of the sequence.
	#
	#   returns    a number
	#   see        Min, Sum
	def Max()
		return StzEngineIntSeqMax(@pHandle)

	# Returns how many times a number occurs in the sequence; 0 when it is not a number.
	#
	#   n          the value to count
	#   returns    a number
	#   see        At, ToList
	def CountValue(n)
		if NOT isNumber(n)
			return 0
		ok
		return StzEngineIntSeqCountValue(@pHandle, n)

		def CountOccurrencesOf(n)
			return This.CountValue(n)

	# Returns the whole sequence as a list of numbers, copied out of the engine.
	#
	#   returns    a list of numbers
	#   see        At, NumberOfItems
	  #--- Compatibility: explicit downgrade to a Ring list ---
	def ToList()
		# Opt-in marshalling to a Ring list. This is the slow path
		# (ring_list_adddouble is O(N) per call on Ring 1.26 so the
		# total cost is O(N^2)) and exists only for callers that
		# need a host-native list. Most use cases should call the
		# engine-fast accessors above instead.
		return StzEngineIntSeqToRingList(@pHandle)

		def Content()
			return This.ToList()

		def ToRingList()
			return This.ToList()
