#---------------------------------------------------------------------------#
#  STZFOURIER -- a sequence and its frequency content.                      #
#---------------------------------------------------------------------------#
#
# The last breadth item the numeric retro named: until now the library had no
# frequency-domain anything.
#
# -- WHAT IT IS FOR --
#
# A signal in time says WHEN things happened. Its Fourier transform says WHAT
# FREQUENCIES it is made of. The two hold the same information -- Transform()
# and InverseTransform() undo each other exactly -- but questions that are hard
# in one are easy in the other: finding a periodicity, filtering a band,
# convolving two sequences.
#
# -- ANY LENGTH, AND NEVER PADDED BEHIND YOUR BACK --
#
# The classic radix-2 FFT needs a power-of-two length. This one does not: a
# power of two takes radix-2, and every other length takes Bluestein's chirp-z
# algorithm, which rewrites the transform as a convolution and computes THAT
# with a power-of-two FFT. Both are O(n log n).
#
# That matters because the alternative libraries offer is to zero-pad 1000
# samples up to 1024 -- and zero-padding is not the same transform, it is the
# transform OF A DIFFERENT SIGNAL. The spectrum you get back is not the spectrum
# of what you passed in. Here 1000 samples give the 1000-point DFT.
#
# -- THE CONVENTION --
#
# Forward is the unscaled sum with exp(-2*pi*i*j*k/n); inverse carries the
# opposite sign and the 1/n. That is NumPy's convention, deliberately, so a
# spectrum computed here can be compared with one computed there with no fudge
# factor -- which is exactly what the guard does.

func StzFourierQ(paSequence)
	return new stzFourier(paSequence)

func StzFourier(paSequence)
	return new stzFourier(paSequence)

# Holds a sequence of samples and answers what frequencies it is made of: its spectrum, magnitudes, phases, dominant frequency and convolution.
#
# Build one with new stzFourier(aSamples), numbers or [ re, im ] pairs. Any length is transformed
# exactly, with a radix-2 FFT for a power of two and Bluestein's algorithm for the others, and never
# padded. The convention is NumPy's: the forward transform is unscaled, the inverse carries the 1/n.
# The Transform, Magnitudes, Phases and PowerSpectrum answers have one entry per bin; bin 1 holds
# the mean. Content, Real and Imaginary give back the samples. InverseTransform inverts the sequence
# it holds, which is the spectrum when you built the object from one.
#
#   receiver   o1 = new stzFourier([ 1, 2, 3, 4 ])
#   example    ? o1.Count()
#              #--> 4
#              ? @@( o1.Magnitudes() )
#              #--> [ 10, 2.83, 2, 2.83 ]
#              ? o1.DominantBin()
#              #--> 2
#   see        stzPolynomial, stzComplex, stzSequence
class stzFourier from stzObject

	@aReal = []
	@aImag = []

	# Builds a sequence for frequency analysis from a list of numbers, or of [ re, im ] pairs for complex samples.
	#
	#   paSequence   the samples, numbers or [ re, im ] pairs
	#   returns      nothing; the object is built
	#   warning      anything but a list raises "give me a list of numbers (or of [re, im] pairs)",
	#                and a sample of another kind raises an error naming its position
	#   see          Transform, StzFourier
	def init(paSequence)
		if NOT isList(paSequence)
			StzRaise("stzFourier: give me a list of numbers (or of [re, im] pairs).")
		ok

		@aReal = []
		@aImag = []
		_nLen_ = len(paSequence)
		for _i_ = 1 to _nLen_
			_x_ = paSequence[_i_]
			if isList(_x_)
				# a [re, im] pair -- a complex sample
				if len(_x_) != 2
					StzRaise("stzFourier: a complex sample must be [re, im].")
				ok
				@aReal + _x_[1]
				@aImag + _x_[2]
			but isNumber(_x_)
				@aReal + _x_
				@aImag + 0
			else
				StzRaise("stzFourier: sample " + _i_ + " is neither a number nor [re, im].")
			ok
		next

	# Returns the real parts of the samples as a list of numbers.
	#
	#   returns    a list of numbers
	#   note       the imaginary parts are not in it, ask Imaginary; Real is the same method
	#   see        Real, Imaginary
	def Content()
		return @aReal

		# Returns the real parts of the samples as a list of numbers.
		#
		#   returns    a list of numbers
		#   see        Content, Imaginary
		def Real()
			return @aReal

	# Returns the imaginary parts of the samples as a list of numbers, 0 for plain numbers.
	#
	#   returns    a list of numbers
	#   see        Real
	def Imaginary()
		return @aImag

	# Returns how many samples the sequence has.
	#
	#   returns    a number
	#   see        IsRadix2Length
	def Count()
		return len(@aReal)

	# TRUE if the number of samples is a power of two, the case that takes the plain radix-2 path.
	#
	#   returns    TRUE or FALSE; FALSE for an empty sequence
	#   note       informational only: any length is transformed exactly, never padded
	#   see        Count
	#@ aka  TRUE when the length is a power of two, i.e. when the plain radix-2 path applies. Informational only -- Transform() works either way.
	def IsRadix2Length()
		_n_ = len(@aReal)
		if _n_ = 0
			return 0
		ok
		return (_n_ & (_n_ - 1)) = 0

	# Returns the spectrum of the sequence: one [ re, im ] pair per frequency bin, unscaled, with the NumPy sign convention.
	#
	#   returns    a list of [ re, im ] pairs; [ ] for an empty sequence
	#   note       Spectrum and DFT are the same method; a 5-sample sequence gets the 5-point
	#              transform, not a padded one
	#   see        InverseTransform, Magnitudes
	# ---- the transform ---------------------------------------------------
	#@ aka  The spectrum, as a list of [re, im] pairs, one per frequency bin.
	def Transform()
		return This._Fft(0)

		def Spectrum()
			return This.Transform()

		def DFT()
			return This.Transform()

	# Treats the sequence as a spectrum and returns the signal it comes from, as [ re, im ] pairs scaled by 1/n.
	#
	#   returns    a list of [ re, im ] pairs; [ ] for an empty sequence
	#   note       it inverts THIS sequence, not its transform: to round-trip build a new object,
	#              new stzFourier(o.Transform()).InverseTransform() gives back 1 2 3 4 with zero
	#              imaginary parts; InverseDFT is the same method
	#   see        Transform
	#@ aka  Back to the time domain. InverseTransform(Transform()) is the identity.
	def InverseTransform()
		return This._Fft(1)

		def InverseDFT()
			return This.InverseTransform()

	def _Fft(bInverse)
		if len(@aReal) = 0
			return []
		ok
		_aFlat_ = StzEngineFft(@aReal, @aImag, bInverse)
		if NOT isList(_aFlat_) or len(_aFlat_) != 2 * len(@aReal)
			StzRaise("stzFourier: the transform failed on this input.")
		ok
		_aOut_ = []
		_n_ = len(@aReal)
		for _i_ = 1 to _n_
			_aOut_ + [ _aFlat_[(_i_ - 1) * 2 + 1], _aFlat_[(_i_ - 1) * 2 + 2] ]
		next
		return _aOut_

	# Returns the size of each frequency bin, how much of that frequency is present, ignoring phase.
	#
	#   returns    a list of numbers, one per bin
	#   see        Phases, PowerSpectrum
	# ---- reading a spectrum ----------------------------------------------
	#@ aka  EACH OF THESE IS ONE ENGINE CALL, not a transform this class then walks. The readings are what callers actually want -- raw complex bins are rarely the answer -- so they belong to the engine and every language over it, not to a loop written once per binding.
	def Magnitudes()
		return This._Read("mag")

	# Returns the phase angle of each frequency bin, in radians.
	#
	#   returns    a list of numbers, one per bin
	#   see        Magnitudes
	#@ aka  The phase angle of each bin, in radians.
	def Phases()
		return This._Read("phase")

	# Returns the energy of each frequency bin, the square of its size.
	#
	#   returns    a list of numbers, one per bin
	#   see        Magnitudes
	#@ aka  |X_k|^2 -- energy per bin, the quantity Parseval's theorem is about.
	def PowerSpectrum()
		return This._Read("power")

	# Returns the bin, counted from 1, that carries the most energy; bin 1, the mean, and the mirrored second half are left out.
	#
	#   returns    a number from 2; 0 for a sequence of fewer than 2 samples
	#   note       a pure sine of 3 cycles over 16 samples answers 4, because bin 1 is the mean
	#   see        DominantFrequency, PowerSpectrum
	#@ aka  The bin carrying the most energy, 1-based for Ring.
	def DominantBin()
		if len(@aReal) < 2
			return 0
		ok
		return StzEngineFftDominantBin(@aReal, @aImag) + 1

	# Returns the dominant frequency in cycles per sample interval, the dominant bin minus 1 over the number of samples.
	#
	#   returns    a number; 0 for fewer than 2 samples
	#   note       multiply by the sampling rate to get hertz; 3 cycles in 16 samples gives 0.1875
	#   see        DominantBin
	#@ aka  The dominant frequency in cycles per sample-interval; multiply by a sample rate to get Hz.
	def DominantFrequency()
		_nB_ = This.DominantBin()
		if _nB_ = 0
			return 0
		ok
		return (_nB_ - 1) / len(@aReal)

	def _Read(cWhich)
		if len(@aReal) = 0
			return []
		ok
		if cWhich = "mag"
			_aR_ = StzEngineFftMagnitudes(@aReal, @aImag)
		but cWhich = "phase"
			_aR_ = StzEngineFftPhases(@aReal, @aImag)
		else
			_aR_ = StzEngineFftPower(@aReal, @aImag)
		ok
		if NOT isList(_aR_)
			StzRaise("stzFourier: the transform failed on this input.")
		ok
		return _aR_

	# Returns the linear convolution of the real parts with another list of numbers, which is also the product of two polynomials' coefficients.
	#
	#   paOther    the other list of numbers, not empty
	#   returns    a list of numbers, as long as both lists together minus 1
	#   note       an empty list raises "give me a non-empty list of numbers"; ConvolvedWithQ
	#              answers a stzFourier to chain on; 1 2 3 4 convolved with 1 1 is 1 3 5 7 4, up to
	#              rounding
	#   see        Transform
	# ---- convolution -----------------------------------------------------
	#@ aka  The LINEAR convolution of this sequence with another, computed through the transform: O(n log n) rather than the O(n*m) of the direct double loop.
	def ConvolvedWith(paOther)
		if NOT isList(paOther) or len(paOther) = 0
			StzRaise("ConvolvedWith: give me a non-empty list of numbers.")
		ok
		_aR_ = StzEngineConvolveReal(@aReal, paOther)
		if NOT isList(_aR_)
			StzRaise("ConvolvedWith: the convolution failed on this input.")
		ok
		return _aR_

		def ConvolvedWithQ(paOther)
			return new stzFourier(This.ConvolvedWith(paOther))
