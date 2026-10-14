#==============================================================#
#  STZNUMBUFFER -- numbers that LIVE in the engine              #
#==============================================================#

/*--- Phase 3 of the numeric foundation: RESIDENCY, the keystone.

THE MEASUREMENT THIS EXISTS FOR. Over 200 000 numbers, a Ring loop computing
mean+variance took 0.04s and the engine took 0.04s -- *no faster* -- because
marshalling the list was the entire cost. The crossing is the price, not the
arithmetic.

So a faster kernel behind a per-call boundary buys nothing, and residency is not
an optimisation of this plane but the precondition for the rest of it. Measured
again with this buffer, same 200 000 numbers:

    five reductions, marshalling each time   0.19s
    one crossing to become resident          ~0
    then the same five reductions            ~0
    ---------------------------------------------
    total                                    0.01s     (19x)

and twenty full elementwise passes over the resident data cost essentially
nothing, where each would otherwise have marshalled the whole list.

THE RULE, stated once because the library has been ambiguous about it before:
**the ENGINE copy is the truth.** `stzList` does the opposite -- Ring owns the
content and the engine handle is a cache invalidated on every write -- and that is
right for a general list. Here the numbers live in the engine and Ring holds a
handle; `ToList()` materialises a VIEW when you actually want to look.

    oBuf = StzNumBufferQ([ 2, 4, 6, 8 ])
    oBuf.Scale(10).AddScalar(1)          # two full passes, no crossing
    oBuf.Sum()                           # a scalar comes back, nothing marshalled
    oBuf.ToList()                        # ...and the view, once, when wanted

ONE HONEST BURDEN: Ring has no destructors, so a buffer holds engine memory until
you `Free()` it. That is the price of owning memory outside the interpreter, and
hiding it would be worse than naming it.

f64 THROUGHOUT. A number that reaches here has left the exact world of phase 1
(rationals, scaled decimals) -- this is the measured, bulk tier, and pretending
otherwise would be the dishonest kind of convenience.
*/

func StzNumBufferQ(pInput)
	return new stzNumBuffer(pInput)

	func StzNumBuffer(pInput)
		return new stzNumBuffer(pInput)

# n items, all zero -- allocated engine-side, never built in Ring
func StzNumBufferOfSizeQ(pnSize)
	_o_ = new stzNumBuffer([])
	_o_.Resize(pnSize)
	return _o_

# 1, 2, 3, ... n WITHOUT ever building the list in Ring: the values are written
# straight into resident memory, so the crossing is a single call.
func StzNumBufferRangeQ(pnCount, pnStart, pnStep)
	_o_ = new stzNumBuffer([])
	_o_.Resize(pnCount)
	_o_.RangeFrom(pnStart, pnStep)
	return _o_


# Holds numbers inside the engine so that bulk passes and reductions cross the Ring boundary once, not once per call.
#
# It is the number helper of stzListOfNumbers (ToStzNumBuffer brings a list in, ToStzListOfNumbers
# takes it back): the engine copy is the truth and Ring only holds a handle. Build one with
# StzNumBufferQ over a list, StzNumBufferOfSizeQ for zeros, or StzNumBufferRangeQ for a sequence.
# Writes (Scale, AddScalar, FillWith, RangeFrom, SetItem and the buffer-with-buffer verbs) change
# the buffer in place and return it, so calls chain; reductions (Sum, Mean, Min, Max, Dot, the
# variances) return a number and marshal nothing; ToList materialises a view when you want to look.
# Values are f64, Sum is compensated, and the variances name their convention (sample divides by
# n-1, population by n). Ring has no destructors: call Free on a large buffer when done. Found
# today: Item, SetItem and Resize with a negative number end the Ring process, an out-of-range
# positive Item answers 0, Dot of two lengths answers 0 where the other buffer verbs raise, and the
# reductions of an empty buffer answer 0.
#
#   receiver   o1 = StzNumBufferQ([ 2, 4, 6, 8 ])
#   example    o1.Scale(10).AddScalar(1)
#              ? @@( o1.ToList() )
#              #--> [ 21, 41, 61, 81 ]
#              ? o1.Sum()
#              #--> 204
#              ? o1.Mean()
#              #--> 51
#   see        stzListOfNumbers, stzNumber, stzList
class stzNumBuffer from stzObject

	@pBuf = ""

	# Builds a buffer of numbers held inside the engine, from a list of numbers or from a size.
	#
	#   pInput     a list of numbers, copied into the engine, or a number n for a buffer of n zeros
	#   returns    nothing; the object is built
	#   note       stzListOfNumbers.ToStzNumBuffer brings a list in; StzNumBufferQ,
	#              StzNumBufferOfSizeQ and StzNumBufferRangeQ build one; the values are f64
	#   warning    the engine memory is held until Free is called: Ring has no destructors
	#   see        Free, ToList, Sum
	def init(pInput)
		if isList(pInput)
			if len(pInput) = 0
				@pBuf = StzEngineNumBufNew(0)
			else
				@pBuf = StzEngineNumBufFromList(pInput)
			ok
		but isNumber(pInput)
			@pBuf = StzEngineNumBufNew(pInput)
		else
			StzRaise("stzNumBuffer: give me a list of numbers, or a size.")
		ok
		if @pBuf = ""
			StzRaise("stzNumBuffer: the engine could not allocate the buffer.")
		ok

	# Returns the engine handle of the buffer, a number.
	#
	#   returns    a number
	#   note       other buffers read it for AddBuffer, SubtractBuffer, MultiplyBuffer and Dot
	#   see        Free, IsFreed
	#@ aka  -- the handle, and the honest burden ------------------------------
	def Handle()
		return @pBuf

	# Releases the engine memory of the buffer.
	#
	#   returns    nothing
	#   note       call it when done with a large buffer; calling it twice is harmless; do not read
	#              the buffer afterwards
	#   see        IsFreed, Resize
	#@ aka  Ring has no destructors, so this is not optional for a large buffer.
	def Free()
		if @pBuf != ""
			StzEngineNumBufFree(@pBuf)
			@pBuf = ""
		ok

	# TRUE if the buffer has been freed.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Free, Handle
	def IsFreed()
		return @pBuf = ""

	# Replaces the buffer by a new one of the given size filled with zeros, losing the numbers it held.
	#
	#   pnSize     the new number of items
	#   returns    the buffer itself, so calls chain
	#   note       the old memory is freed first
	#   warning    a negative size ends the Ring process: it panics inside stz_stats.dll with exit
	#              code 3
	#   see        Free, FillWith
	def Resize(pnSize)
		This.Free()
		@pBuf = StzEngineNumBufNew(pnSize)
		return This

	# Returns how many numbers the buffer holds.
	#
	#   returns    a number
	#   note       Size and Count are the same call
	#   see        IsEmpty, Item
	#@ aka  -- reads ----------------------------------------------------------
	def NumberOfItems()
		return StzEngineNumBufLen(@pBuf)

		def Size()
			return This.NumberOfItems()

		def Count()
			return This.NumberOfItems()

	# TRUE if the buffer holds no number.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems
	def IsEmpty()
		return This.NumberOfItems() = 0

	# Returns the number at a position, counted from 1.
	#
	#   n          the 1-based position
	#   returns    a number
	#   note       NthItem is the same call
	#   warning    a position of 0 or past the end answers 0 without any error, as a stored zero
	#              would; a negative position ends the Ring process (panic in stz_stats.dll, exit
	#              code 3)
	#   see        ToList, SetItem
	def Item(n)
		return StzEngineNumBufGet(@pBuf, n)

		def NthItem(n)
			return This.Item(n)

	# Returns all the numbers as a Ring list, one crossing.
	#
	#   returns    a list of numbers
	#   note       Content is the same call; the buffer is unchanged and not freed
	#   see        ToStzList, ToStzListOfNumbers, Item
	#@ aka  The materialised VIEW -- one crossing, taken when you actually want to look.
	def ToList()
		return StzEngineNumBufToList(@pBuf)

		def Content()
			return This.ToList()

	# Returns the numbers as a stzListOfNumbers, to reach its list methods.
	#
	#   returns    a stzListOfNumbers
	#   note       the buffer stays yours and is not freed; ToListOfNumbers is the same call
	#   see        ToStzList, ToList
	#@ aka  THE RETURN LEG. stzListOfNumbers.ToStzNumBuffer() brings numbers in; this takes them back out to the list tier, where the eleven hundred list methods live. Both directions are one crossing, and both are written at the call site so the tier you are in is visible rather than guessed at.
	def ToStzListOfNumbers()
		return new stzListOfNumbers(This.ToList())

		def ToListOfNumbers()
			return This.ToStzListOfNumbers()

	# Returns the numbers as a stzList.
	#
	#   returns    a stzList
	#   note       the buffer stays yours and is not freed
	#   see        ToStzListOfNumbers, ToList
	def ToStzList()
		return new stzList(This.ToList())

	# Returns an independent buffer holding the same numbers.
	#
	#   returns    a new stzNumBuffer
	#   note       changing the copy leaves the original alone: 99 in the copy, 2 still in the
	#              original
	#   see        Resize, ToList
	def Copy()
		_o_ = new stzNumBuffer([])
		_o_.Free()
		_o_._SetHandle( StzEngineNumBufClone(@pBuf) )
		return _o_

	def _SetHandle(p)
		@pBuf = p

	# Writes a number at a position, in place.
	#
	#   n          the 1-based position
	#   v          the number to write
	#   returns    the buffer itself, so calls chain
	#   note       [ 2, 4, 6, 8 ] with 40 at 2 gives [ 2, 40, 6, 8 ]
	#   warning    a position of 0 or past the end changes nothing and raises no error; a negative
	#              position ends the Ring process
	#   see        Item, FillWith
	#@ aka  -- writes: each is a full pass over resident memory, no crossing ----
	def SetItem(n, v)
		StzEngineNumBufSet(@pBuf, n, v)
		return This

	# Sets every item to one number, in place.
	#
	#   v          the number to write everywhere
	#   returns    the buffer itself, so calls chain
	#   note       FillWithQ is the same call
	#   see        RangeFrom, Resize
	def FillWith(v)
		StzEngineNumBufFill(@pBuf, v)
		return This

		def FillWithQ(v)
			return This.FillWith(v)

	# Writes an arithmetic sequence over the buffer, in place.
	#
	#   pnStart    the first number
	#   pnStep     the difference between neighbours
	#   returns    the buffer itself, so calls chain
	#   note       3 items from 10 with step 5 give 10, 15, 20; RangeFromQ is the same call
	#   see        FillWith, AddScalar
	def RangeFrom(pnStart, pnStep)
		StzEngineNumBufRange(@pBuf, pnStart, pnStep)
		return This

		def RangeFromQ(pnStart, pnStep)
			return This.RangeFrom(pnStart, pnStep)

	# Adds one number to every item, in place.
	#
	#   v          the number to add
	#   returns    the buffer itself, so calls chain
	#   note       10, 15, 20 plus 1 give 11, 16, 21; AddScalarQ is the same call
	#   see        Scale, AddBuffer
	def AddScalar(v)
		StzEngineNumBufAddScalar(@pBuf, v)
		return This

		def AddScalarQ(v)
			return This.AddScalar(v)

	# Multiplies every item by one number, in place.
	#
	#   v          the factor
	#   returns    the buffer itself, so calls chain
	#   note       11, 16, 21 times 2 give 22, 32, 42; ScaleQ is the same call
	#   see        AddScalar, MultiplyBuffer
	def Scale(v)
		StzEngineNumBufScale(@pBuf, v)
		return This

		def ScaleQ(v)
			return This.Scale(v)

	# Adds another buffer to this one item by item, in place.
	#
	#   poOther    the other stzNumBuffer, of the same length
	#   returns    the buffer itself, so calls chain
	#   note       1, 2, 3 plus 10, 20, 30 give 11, 22, 33; AddBufferQ is the same call
	#   warning    a buffer of another length raises stzNumBuffer: the two buffers must have the
	#              same length, and nothing is changed
	#   see        SubtractBuffer, MultiplyBuffer, Dot
	#@ aka  elementwise against another buffer of the SAME length; a mismatch is refused rather than half-applied
	def AddBuffer(poOther)
		if StzEngineNumBufAdd(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def AddBufferQ(poOther)
			return This.AddBuffer(poOther)

	# Subtracts another buffer from this one item by item, in place.
	#
	#   poOther    the other stzNumBuffer, of the same length
	#   returns    the buffer itself, so calls chain
	#   note       11, 22, 33 minus 10, 20, 30 give 1, 2, 3; SubtractBufferQ is the same call
	#   warning    a buffer of another length raises stzNumBuffer: the two buffers must have the
	#              same length
	#   see        AddBuffer, MultiplyBuffer
	def SubtractBuffer(poOther)
		if StzEngineNumBufSub(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def SubtractBufferQ(poOther)
			return This.SubtractBuffer(poOther)

	# Multiplies this buffer by another item by item, in place.
	#
	#   poOther    the other stzNumBuffer, of the same length
	#   returns    the buffer itself, so calls chain
	#   note       1, 2, 3 times 10, 20, 30 give 10, 40, 90; MultiplyBufferQ is the same call
	#   warning    a buffer of another length raises stzNumBuffer: the two buffers must have the
	#              same length
	#   see        AddBuffer, Dot
	def MultiplyBuffer(poOther)
		if StzEngineNumBufMul(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def MultiplyBufferQ(poOther)
			return This.MultiplyBuffer(poOther)

	# Returns the sum of all the numbers, with compensation for lost low digits.
	#
	#   returns    a number; 0 for an empty buffer
	#   note       1e16 plus four 1s gives 10000000000000004 where a naive total stays at 1e16
	#   see        Mean, Dot
	#@ aka  -- reductions: a scalar out, nothing marshalled ---------------------
	def Sum()
		return StzEngineNumBufSum(@pBuf)

	# Returns the arithmetic mean of the numbers.
	#
	#   returns    a number; 0 for an empty buffer
	#   note       1, 2, 3, 4 give 2.5; Average is the same call
	#   see        Sum, VariancePopulation
	def Mean()
		return StzEngineNumBufMean(@pBuf)

		def Average()
			return This.Mean()

	# Returns the smallest number.
	#
	#   returns    a number; 0 for an empty buffer
	#   warning    an empty buffer answers 0, which cannot be told from a real zero
	#   see        Max
	def Min()
		return StzEngineNumBufMin(@pBuf)

	# Returns the largest number.
	#
	#   returns    a number; 0 for an empty buffer
	#   warning    an empty buffer answers 0, which cannot be told from a real zero
	#   see        Min
	def Max()
		return StzEngineNumBufMax(@pBuf)

	# Returns the dot product with another buffer, the sum of the products item by item.
	#
	#   poOther    the other stzNumBuffer, of the same length
	#   returns    a number
	#   note       10, 40, 90 with 10, 20, 30 gives 100 + 800 + 2700 = 3600; DotProduct is the same
	#              call
	#   warning    a buffer of another length answers 0 without any error, where AddBuffer raises
	#   see        MultiplyBuffer, Sum
	def Dot(poOther)
		return StzEngineNumBufDot(@pBuf, poOther.Handle())

		def DotProduct(poOther)
			return This.Dot(poOther)

	# Returns the sample variance, dividing by n minus 1.
	#
	#   returns    a number
	#   note       2, 4, 4, 4, 5, 5, 7, 9 give 4.571; Variance is the same call
	#   warning    a buffer of one item or none answers 0 instead of undefined
	#   see        VariancePopulation, StddevSample, Mean
	#@ aka  the convention is NAMED, as everywhere else since phase 0 -- and it is asked of stats.zig rather than decided here
	def VarianceSample()
		return StzEngineNumBufVariance(@pBuf, 1)

	# Returns the population variance, dividing by n.
	#
	#   returns    a number
	#   note       2, 4, 4, 4, 5, 5, 7, 9 give 4
	#   see        VarianceSample, StddevPopulation
	def VariancePopulation()
		return StzEngineNumBufVariance(@pBuf, 0)

	def Variance()
		return This.VarianceSample()

	# Returns the sample standard deviation, the square root of VarianceSample.
	#
	#   returns    a number
	#   note       2, 4, 4, 4, 5, 5, 7, 9 give 2.138; Stddev and StandardDeviation are the same call
	#   warning    a buffer of one item or none answers 0
	#   see        StddevPopulation, VarianceSample
	def StddevSample()
		return StzEngineNumBufStdDev(@pBuf, 1)

	# Returns the population standard deviation, the square root of VariancePopulation.
	#
	#   returns    a number
	#   note       2, 4, 4, 4, 5, 5, 7, 9 give 2
	#   see        StddevSample, VariancePopulation
	def StddevPopulation()
		return StzEngineNumBufStdDev(@pBuf, 0)

	def Stddev()
		return This.StddevSample()

		def StandardDeviation()
			return This.Stddev()

	# Prints one line saying how many numbers the buffer holds.
	#
	#   returns    nothing; it prints
	#   note       it prints stzNumBuffer(8 numbers, engine-resident) and shows no number
	#   see        NumberOfItems, ToList
	def Show()
		? "stzNumBuffer(" + This.NumberOfItems() + " numbers, engine-resident)"
