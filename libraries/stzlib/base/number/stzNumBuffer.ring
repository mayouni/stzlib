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


class stzNumBuffer from stzObject

	@pBuf = ""

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

	  #-- the handle, and the honest burden ------------------------------

	def Handle()
		return @pBuf

	# Ring has no destructors, so this is not optional for a large buffer.
	def Free()
		if @pBuf != ""
			StzEngineNumBufFree(@pBuf)
			@pBuf = ""
		ok

	def IsFreed()
		return @pBuf = ""

	def Resize(pnSize)
		This.Free()
		@pBuf = StzEngineNumBufNew(pnSize)
		return This

	  #-- reads ----------------------------------------------------------

	def NumberOfItems()
		return StzEngineNumBufLen(@pBuf)

		def Size()
			return This.NumberOfItems()

		def Count()
			return This.NumberOfItems()

	def IsEmpty()
		return This.NumberOfItems() = 0

	def Item(n)
		return StzEngineNumBufGet(@pBuf, n)

		def NthItem(n)
			return This.Item(n)

	# The materialised VIEW -- one crossing, taken when you actually want to look.
	def ToList()
		return StzEngineNumBufToList(@pBuf)

		def Content()
			return This.ToList()

	# THE RETURN LEG. stzListOfNumbers.ToStzNumBuffer() brings numbers in; this
	# takes them back out to the list tier, where the eleven hundred list methods
	# live. Both directions are one crossing, and both are written at the call site
	# so the tier you are in is visible rather than guessed at.
	#
	# The buffer is NOT freed here: it is still yours, and Ring has no destructors
	# to decide otherwise. Free it when you are done with it.
	def ToStzListOfNumbers()
		return new stzListOfNumbers(This.ToList())

		def ToListOfNumbers()
			return This.ToStzListOfNumbers()

	def ToStzList()
		return new stzList(This.ToList())

	def Copy()
		_o_ = new stzNumBuffer([])
		_o_.Free()
		_o_._SetHandle( StzEngineNumBufClone(@pBuf) )
		return _o_

	def _SetHandle(p)
		@pBuf = p

	  #-- writes: each is a full pass over resident memory, no crossing ----

	def SetItem(n, v)
		StzEngineNumBufSet(@pBuf, n, v)
		return This

	def FillWith(v)
		StzEngineNumBufFill(@pBuf, v)
		return This

		def FillWithQ(v)
			return This.FillWith(v)

	def RangeFrom(pnStart, pnStep)
		StzEngineNumBufRange(@pBuf, pnStart, pnStep)
		return This

		def RangeFromQ(pnStart, pnStep)
			return This.RangeFrom(pnStart, pnStep)

	def AddScalar(v)
		StzEngineNumBufAddScalar(@pBuf, v)
		return This

		def AddScalarQ(v)
			return This.AddScalar(v)

	def Scale(v)
		StzEngineNumBufScale(@pBuf, v)
		return This

		def ScaleQ(v)
			return This.Scale(v)

	# elementwise against another buffer of the SAME length; a mismatch is refused
	# rather than half-applied
	def AddBuffer(poOther)
		if StzEngineNumBufAdd(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def AddBufferQ(poOther)
			return This.AddBuffer(poOther)

	def SubtractBuffer(poOther)
		if StzEngineNumBufSub(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def SubtractBufferQ(poOther)
			return This.SubtractBuffer(poOther)

	def MultiplyBuffer(poOther)
		if StzEngineNumBufMul(@pBuf, poOther.Handle()) = 0
			StzRaise("stzNumBuffer: the two buffers must have the same length.")
		ok
		return This

		def MultiplyBufferQ(poOther)
			return This.MultiplyBuffer(poOther)

	  #-- reductions: a scalar out, nothing marshalled ---------------------

	# Summed with NEUMAIER COMPENSATION. A naive total loses the low bits of every
	# addend once it grows large relative to them -- add 1e16 and then a thousand
	# 1.0s and the naive answer is still 1e16. This carries the lost part along.
	def Sum()
		return StzEngineNumBufSum(@pBuf)

	def Mean()
		return StzEngineNumBufMean(@pBuf)

		def Average()
			return This.Mean()

	def Min()
		return StzEngineNumBufMin(@pBuf)

	def Max()
		return StzEngineNumBufMax(@pBuf)

	def Dot(poOther)
		return StzEngineNumBufDot(@pBuf, poOther.Handle())

		def DotProduct(poOther)
			return This.Dot(poOther)

	# the convention is NAMED, as everywhere else since phase 0 -- and it is asked
	# of stats.zig rather than decided here
	def VarianceSample()
		return StzEngineNumBufVariance(@pBuf, 1)

	def VariancePopulation()
		return StzEngineNumBufVariance(@pBuf, 0)

	def Variance()
		return This.VarianceSample()

	def StddevSample()
		return StzEngineNumBufStdDev(@pBuf, 1)

	def StddevPopulation()
		return StzEngineNumBufStdDev(@pBuf, 0)

	def Stddev()
		return This.StddevSample()

		def StandardDeviation()
			return This.Stddev()

	def Show()
		? "stzNumBuffer(" + This.NumberOfItems() + " numbers, engine-resident)"
