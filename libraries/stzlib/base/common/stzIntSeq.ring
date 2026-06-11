#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZINTSEQ                    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Lightweight Ring-side wrapper around the    #
#                  engine IntSeq feature. Holds a handle to a  #
#                  Zig-allocated []i64 backing store; exposes  #
#                  list-shape access (Len, At, First, Last,    #
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

class stzIntSeq

	@pHandle = NULL
	@bOwned  = 1

	def init(pHandle)
		# Accept a raw engine handle (returned by
		# StzEngineIntSeqCreateCycle and friends).
		@pHandle = pHandle

	def Handle()
		return @pHandle

	  #--- Lifecycle ---

	def Release()
		# Free the underlying engine handle. Idempotent: a second
		# Release() is a no-op so wrappers that get borrowed don't
		# double-free.
		if @bOwned and @pHandle != NULL
			StzEngineIntSeqFree(@pHandle)
			@pHandle = NULL
		ok

	def Disown()
		# Caller takes ownership of the handle: this object won't
		# free it. Use when handing the handle off to another wrapper.
		@bOwned = 0

	  #--- Read accessors (all O(1) or O(N) in engine, no Ring loops) ---

	def NumberOfItems()
		return StzEngineIntSeqLen(@pHandle)

		def Count()
			return This.NumberOfItems()

		def Size()
			return This.NumberOfItems()

	# 1-based access to match Ring/Softanza convention; engine is 0-based.
	def At(n)
		if NOT isNumber(n) or n < 1
			return 0
		ok
		return StzEngineIntSeqAt(@pHandle, n - 1)

		def Item(n)
			return This.At(n)

		def Nth(n)
			return This.At(n)

	def First()
		return StzEngineIntSeqFirst(@pHandle)

		def FirstItem()
			return This.First()

	def Last()
		return StzEngineIntSeqLast(@pHandle)

		def LastItem()
			return This.Last()

	  #--- Bulk-query operations (stay in Zig) ---

	def Sum()
		return StzEngineIntSeqSum(@pHandle)

	def Min()
		return StzEngineIntSeqMin(@pHandle)

	def Max()
		return StzEngineIntSeqMax(@pHandle)

	def CountValue(n)
		if NOT isNumber(n)
			return 0
		ok
		return StzEngineIntSeqCountValue(@pHandle, n)

		def CountOccurrencesOf(n)
			return This.CountValue(n)

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
