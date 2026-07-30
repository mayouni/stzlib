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

class stzFourier from stzObject

	@aReal = []
	@aImag = []

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

	def Content()
		return @aReal

		def Real()
			return @aReal

	def Imaginary()
		return @aImag

	def Count()
		return len(@aReal)

	# TRUE when the length is a power of two, i.e. when the plain radix-2 path
	# applies. Informational only -- Transform() works either way.
	def IsRadix2Length()
		_n_ = len(@aReal)
		if _n_ = 0
			return FALSE
		ok
		return (_n_ & (_n_ - 1)) = 0

	# ---- the transform ---------------------------------------------------

	# The spectrum, as a list of [re, im] pairs, one per frequency bin.
	def Transform()
		return This._Fft(FALSE)

		def Spectrum()
			return This.Transform()

		def DFT()
			return This.Transform()

	# Back to the time domain. InverseTransform(Transform()) is the identity.
	def InverseTransform()
		return This._Fft(TRUE)

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

	# ---- reading a spectrum ----------------------------------------------

	# The magnitude |X_k| of each bin -- "how much of this frequency is present".
	# Phase-blind, which is usually what you want when looking for a periodicity.
	def Magnitudes()
		_aS_ = This.Transform()
		_aM_ = []
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			_aM_ + sqrt(_aS_[_i_][1] * _aS_[_i_][1] + _aS_[_i_][2] * _aS_[_i_][2])
		next
		return _aM_

	# The phase angle of each bin, in radians.
	def Phases()
		_aS_ = This.Transform()
		_aP_ = []
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			_aP_ + atan2(_aS_[_i_][2], _aS_[_i_][1])
		next
		return _aP_

	# |X_k|^2 -- energy per bin. The quantity Parseval's theorem is about.
	def PowerSpectrum()
		_aS_ = This.Transform()
		_aW_ = []
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			_aW_ + (_aS_[_i_][1] * _aS_[_i_][1] + _aS_[_i_][2] * _aS_[_i_][2])
		next
		return _aW_

	# The bin carrying the most energy, ignoring bin 0 (which is the mean, not a
	# frequency). 1-based, so bin 1 is DC and the answer is >= 2.
	#
	# For a real signal the spectrum is symmetric -- bin k and bin n-k are a
	# conjugate pair carrying the same magnitude -- so only the first half is
	# searched. Returning n-k instead would name the same frequency by its
	# mirror, which reads as a bug to anyone plotting it.
	def DominantBin()
		_aM_ = This.Magnitudes()
		_n_ = len(_aM_)
		if _n_ < 2
			return 0
		ok
		_nHalf_ = floor(_n_ / 2) + 1
		_nBest_ = 2
		_nMax_ = -1
		for _i_ = 2 to _nHalf_
			if _aM_[_i_] > _nMax_
				_nMax_ = _aM_[_i_]
				_nBest_ = _i_
			ok
		next
		return _nBest_

	# The dominant frequency in cycles per sample-interval. Multiply by a sample
	# rate to get Hz.
	def DominantFrequency()
		_nB_ = This.DominantBin()
		if _nB_ = 0
			return 0
		ok
		return (_nB_ - 1) / len(@aReal)

	# ---- convolution -----------------------------------------------------

	# The LINEAR convolution of this sequence with another, computed through the
	# transform: O(n log n) rather than the O(n*m) of the direct double loop.
	#
	# This is also POLYNOMIAL MULTIPLICATION -- the coefficients of a product are
	# the convolution of the coefficients -- which is why stzPolynomial uses it.
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
