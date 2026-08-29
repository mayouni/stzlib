# THE FAST FOURIER TRANSFORM -- stzFourier.
#
# The last breadth item the numeric retro named. Until this landed the library had
# no frequency-domain anything.
#
# Three kinds of check, because no one of them is sufficient:
#
#   (1) ANALYTIC answers -- the DFT of an impulse, of a constant, of a sinusoid.
#       These are known without computing anything, so they catch a transform that
#       is subtly the wrong transform.
#   (2) NUMPY (numpy.fft) as a reference oracle, on four signals, following the
#       pattern established by numeric_reference_oracle_narrated.ring. Values live
#       in _numpy_fft_reference.ring; regenerate with the inline command below.
#   (3) IDENTITIES the transform must satisfy -- round trip, Parseval, and the
#       convolution theorem.
#
# Regenerate the reference file with the python one-liner recorded in the commit
# message for this guard (numpy.fft.fft over the same four signals).
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "_numpy_fft_reference.ring"
load "../_narrated.ring"

decimals(10)

Scenario("The analytic transforms come out exactly right")
	# An IMPULSE contains every frequency in equal measure, so its spectrum is flat.
	oD = new stzFourier([1,0,0,0,0,0,0,0])
	Then("the DFT of a delta is flat at 1", FftAllBinsNear(oD.Transform(), 1, 0), TRUE)

	# A CONSTANT never changes, so it has no frequency content above DC: all the
	# energy sits in bin 0, which holds the sum.
	oC = new stzFourier([3,3,3,3,3,3,3,3])
	aC = oC.Transform()
	Then("a constant puts all its energy in bin 0", FftNear(aC[1][1], 24), TRUE)
	Then("...and nothing anywhere else", FftBinsZeroFrom(aC, 2), TRUE)

	# A SINUSOID of frequency 3 in 16 samples lands in bins 3 and 16-3, each with
	# half the amplitude -- the conjugate pair a real signal always produces.
	aSig = []
	for i = 0 to 15
		aSig + cos(2 * 3.14159265358979 * 3 * i / 16)
	next
	oS = new stzFourier(aSig)
	aS = oS.Transform()
	Then("a sinusoid lands in exactly two bins, each carrying n/2",
	     FftNear(aS[4][1], 8) and FftNear(aS[14][1], 8), TRUE)
	Then("...and the dominant bin names its frequency", oS.DominantBin(), 4)
	Then("...as 3/16 of the sample rate", FftNear(oS.DominantFrequency(), 0.1875), TRUE)
EndScenario()

Scenario("The spectrum agrees with numpy.fft, at every length")
	# a power of two: the radix-2 path
	Then("an 8-point spectrum matches numpy",
	     FftMatchesRef(FRefSig_sig8(), FRefRe_sig8(), FRefIm_sig8()) < 0.0000000001, TRUE)

	# 7 is PRIME, so no radix decomposition exists and this is Bluestein
	Then("a 7-point spectrum matches numpy -- a PRIME length",
	     FftMatchesRef(FRefSig_sig7(), FRefRe_sig7(), FRefIm_sig7()) < 0.0000000001, TRUE)

	# 12 is composite but not a power of two -- also Bluestein
	Then("a 12-point spectrum matches numpy",
	     FftMatchesRef(FRefSig_sig12(), FRefRe_sig12(), FRefIm_sig12()) < 0.0000000001, TRUE)
	Then("...and a 13-point one, prime again",
	     FftMatchesRef(FRefSig_sig13(), FRefRe_sig13(), FRefIm_sig13()) < 0.0000000001, TRUE)

	# magnitudes too, since that is what most callers actually read
	Then("the magnitudes match numpy's abs(fft(x))",
	     FftMagMatchesRef(FRefSig_sig12(), FRefMag_sig12()) < 0.0000000001, TRUE)
EndScenario()

Scenario("...and NOTHING IS PADDED BEHIND THE CALLER'S BACK")
	# This is the point of carrying Bluestein at all. The classic radix-2 FFT needs
	# a power-of-two length, and a library that only has that must either refuse a
	# 7-point signal or zero-pad it to 8. ZERO-PADDING IS NOT THE SAME TRANSFORM --
	# it is the transform of a DIFFERENT signal, and the spectrum it returns is not
	# the spectrum of what was passed in.
	aSeven = FRefSig_sig7()
	oSeven = new stzFourier(aSeven)
	Then("a 7-sample signal is not a radix-2 length", oSeven.IsRadix2Length(), FALSE)
	Then("...and it still returns SEVEN bins, not eight", len(oSeven.Transform()), 7)

	# and to make the difference concrete: padding to 8 gives a visibly different
	# spectrum, which is exactly the wrong answer a padding library would hand back
	# NOTE the append: `aSeven + [0]` would NEST the list [0] as a single element
	# rather than concatenating a zero, which is Ring's `+` on two lists.
	aPadded = aSeven
	aPadded + 0
	oPadded = new stzFourier(aPadded)
	aA = oSeven.Magnitudes()
	aB = oPadded.Magnitudes()
	Then("the padded signal's spectrum genuinely differs",
	     fabs(aA[2] - aB[2]) > 0.01, TRUE)
EndScenario()

Scenario("The identities every transform must satisfy")
	# ROUND TRIP. The inverse undoes the forward exactly -- at a power of two...
	aEight = FRefSig_sig8()
	oF8 = new stzFourier(aEight)
	oB8 = new stzFourier(oF8.Transform())
	Then("inverse(forward(x)) is x, at a power of two",
	     FftRoundTripNear(oB8.InverseTransform(), aEight), TRUE)

	# ...and at a prime length, through Bluestein
	aSeven = FRefSig_sig7()
	oF7 = new stzFourier(aSeven)
	oB7 = new stzFourier(oF7.Transform())
	Then("...and at a PRIME length too",
	     FftRoundTripNear(oB7.InverseTransform(), aSeven), TRUE)

	# PARSEVAL. sum|x|^2 == (1/n) sum|X|^2 -- the transform is a scaled isometry.
	# A whole-spectrum check: no single bin can be wrong without breaking it.
	aE = []
	for i = 0 to 19
		aE + (sin(0.6*i) + 0.25*cos(1.7*i))
	next
	oE = new stzFourier(aE)
	nTime = 0
	_aV147_ = aE
	_nV147_ = len(_aV147_)
	for _iV147_ = 1 to _nV147_
		v = _aV147_[_iV147_]
		nTime += v*v
	next
	nFreq = 0
	_aW148_ = oE.PowerSpectrum()
	_nW148_ = len(_aW148_)
	for _iW148_ = 1 to _nW148_
		w = _aW148_[_iW148_]
		nFreq += w
	next
	Then("Parseval holds: energy is conserved (n=20, Bluestein)",
	     FftNear(nTime, nFreq / 20), TRUE)
EndScenario()

Scenario("...and the convolution theorem gives polynomials a faster product")
	# MULTIPLICATION IS A CONVOLUTION: the coefficients of a product are the
	# convolution of the coefficients. So an FFT multiplies polynomials in
	# O(N log N) instead of the double loop's O(n*m).
	Then("FFT convolution matches numpy.convolve",
	     FftConvMatchesRef() < 0.000000001, TRUE)

	# stzPolynomial is the CONSUMER, which is the point: the retro's complaint was
	# capability without customers. Times() keeps the exact double loop for small
	# degrees and switches to the transform above a crossover, and the two routes
	# agree on the same polynomials.
	oP = new stzPolynomial([1,2,3])
	Then("the direct product is exact", @@(oP.Times([4,5])), @@([4,13,22,15]))
	Then("...and the transform route agrees with it",
	     FftListsNear(oP.TimesViaTransform([4,5]), [4,13,22,15]), TRUE)

	# WHY THE DOUBLE LOOP IS KEPT and not merely tolerated: for integer
	# coefficients it is EXACT, while the transform route travels through
	# irrational twiddle factors and returns a few rounding errors away from a
	# whole number. Below the crossover it is both faster and more accurate.
	aDirect = oP.Times([4,5])
	aViaFft = oP.TimesViaTransform([4,5])
	Then("the direct route lands on exact integers",
	     aDirect[2] = 13, TRUE)
	Then("...while the transform route is merely very close",
	     fabs(aViaFft[2] - 13) < 0.000000001, TRUE)

	# a longer product, past the crossover, so Times() itself takes the transform
	aBig1 = []
	aBig2 = []
	for i = 1 to 70
		aBig1 + (i % 7 + 1)
		aBig2 + (i % 5 + 2)
	next
	oBig = new stzPolynomial(aBig1)
	Then("a 70x70 product returns the right length", len(oBig.Times(aBig2)), 139)
	Then("...and agrees with the transform route explicitly",
	     FftListsNear(oBig.Times(aBig2), oBig.TimesViaTransform(aBig2)), TRUE)
EndScenario()

Summary()

#-- helpers (Fft-prefixed: short names collide with library globals) -----------

func FftNear(nX, nY)
	return fabs(nX - nY) < 0.000001

func FftAllBinsNear(paSpec, nRe, nIm)
	_fn_ = len(paSpec)
	for _fi_ = 1 to _fn_
		if fabs(paSpec[_fi_][1] - nRe) > 0.000001
			return FALSE
		ok
		if fabs(paSpec[_fi_][2] - nIm) > 0.000001
			return FALSE
		ok
	next
	return TRUE

func FftBinsZeroFrom(paSpec, nFrom)
	_fn_ = len(paSpec)
	for _fi_ = nFrom to _fn_
		if fabs(paSpec[_fi_][1]) > 0.000001 or fabs(paSpec[_fi_][2]) > 0.000001
			return FALSE
		ok
	next
	return TRUE

# max absolute deviation of our spectrum from numpy's, over both parts
func FftMatchesRef(paSig, paRe, paIm)
	_oF_ = new stzFourier(paSig)
	_aS_ = _oF_.Transform()
	_fm_ = 0
	_fn_ = len(paRe)
	for _fi_ = 1 to _fn_
		_fd_ = fabs(_aS_[_fi_][1] - paRe[_fi_])
		if _fd_ > _fm_
			_fm_ = _fd_
		ok
		_fd_ = fabs(_aS_[_fi_][2] - paIm[_fi_])
		if _fd_ > _fm_
			_fm_ = _fd_
		ok
	next
	return _fm_

func FftMagMatchesRef(paSig, paMag)
	_oF2_ = new stzFourier(paSig)
	_aM_ = _oF2_.Magnitudes()
	_fm2_ = 0
	_fn2_ = len(paMag)
	for _fi2_ = 1 to _fn2_
		_fd2_ = fabs(_aM_[_fi2_] - paMag[_fi2_])
		if _fd2_ > _fm2_
			_fm2_ = _fd2_
		ok
	next
	return _fm2_

func FftConvMatchesRef()
	_oC_ = new stzFourier(FRefConvA())
	_aG_ = _oC_.ConvolvedWith(FRefConvB())
	_aR_ = FRefConv()
	_fm3_ = 0
	_fn3_ = len(_aR_)
	for _fi3_ = 1 to _fn3_
		_fd3_ = fabs(_aG_[_fi3_] - _aR_[_fi3_])
		if _fd3_ > _fm3_
			_fm3_ = _fd3_
		ok
	next
	return _fm3_

# the round trip returns [re, im] pairs; compare the real parts to the input
func FftRoundTripNear(paPairs, paWant)
	_fn4_ = len(paWant)
	for _fi4_ = 1 to _fn4_
		if fabs(paPairs[_fi4_][1] - paWant[_fi4_]) > 0.0000001
			return FALSE
		ok
		if fabs(paPairs[_fi4_][2]) > 0.0000001
			return FALSE
		ok
	next
	return TRUE

func FftListsNear(paA, paB)
	if len(paA) != len(paB)
		return FALSE
	ok
	_fn5_ = len(paA)
	for _fi5_ = 1 to _fn5_
		if fabs(paA[_fi5_] - paB[_fi5_]) > 0.000001
			return FALSE
		ok
	next
	return TRUE
