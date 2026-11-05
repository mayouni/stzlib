#=====================================================================#
#  STZIMAGE -- an image: pixels behind one engine handle (IM0)       #
#=====================================================================#
/*
	SOFTANZA_IMAGE_INTELLIGENCE.md: the image plane's face. The pixels
	live in the engine (stz_image.dll, engine/src/image.zig) behind a
	gen-keyed handle; this object holds only the number, so a copy of it
	reaches the same pixels -- and a MUTATING verb keeps that one handle
	(the engine moves the result into it), so every copy sees the change.
	That is the engine-wrapper copy law, applied.

	THE FORMS, as everywhere in Softanza:
		oImg.ApplyBlur(2)     CHANGES the image
		oImg.ApplyBlurQ(2)    changes it and returns it, to chain
		oImg.Blurred(2)       returns DATA -- a new stzImage -- and never alters oImg

	A pipeline is written with the Apply forms, never as a chain of ...ed()
	calls (each of those would be a new image, left unreleased):
		oImg { ApplyGrayScale() ApplyThreshold(:otsu) SaveAs("ink.png") }
		oImg.ApplyGrayScaleQ().ApplyThresholdQ(:otsu).SaveAs("ink.png")

	WHAT AN ANALYSIS RETURNS IS A GRID (stzImageGrid), never a picture:
	a histogram is 1 x 256 counts; ToGrid() is the pixels as numbers, and
	converts back without loss (SOFTANZA_VISION_PLAN.md section 3).

	CONVENTIONS ARE OPENCV'S, because OpenCV is the oracle the plane is
	measured against: gray is BT.601 (0.299 R + 0.587 G + 0.114 B),
	bilinear sampling uses half-pixel centres, blur borders reflect
	(REFLECT_101), a threshold keeps what is ABOVE it. Coordinates are
	1-based.

	RELEASE IS EXPLICIT. Ring has no destructor: Release() frees the
	pixels, once, for every copy.
*/

# IM9d: the thresholds of the quality verdicts, chosen on the DEV slice of the golden set alone (SOFTANZA_IMAGE_INTELLIGENCE.md,
# IM9d slice 2) and judged once on a disjoint slice. A picture is BLURRY when its RelativeSharpness is below $nStzBlurBelow
# (dev: defocus blur at sigma 3 and 5 never reached 0.0060, the least sharp original was 0.0107); UNDEREXPOSED when its 99th
# percentile gray level is below $nStzUnderP99 (dev: gain 0.30 and 0.45 never passed 114, the darkest original had 144);
# OVEREXPOSED when at least $nStzOverLight of its pixels are at 250 or above (dev: 90% of gain-2.2 pictures reached 0.109,
# no original passed 0.096). They are knobs a caller may reassign; a verdict is a rule over a number, and the number is Quality().
$nStzBlurBelow = 0.008
$nStzUnderP99 = 128
$nStzOverLight = 0.10
# IM9d slice 3: two pictures are NEAR-DUPLICATES when their perceptual hashes differ in at most $nStzNearDupBits of 64 bits (chosen on the dev pairs: same 0 to 16 bits, different 18 to 42) -- a copy resized, re-encoded, brightened or slightly cropped differs in few bits, another photograph in about half.
$nStzNearDupBits = 17
# ... or, by meaning, when the cosine of their SigLIP2 embeddings is at least $nStzNearDupCosine (chosen on the dev pairs: same 0.886 to 0.999, different 0.290 to 0.773)
$nStzNearDupCosine = 0.83

# The number of bits in which two 16-digit hex hashes (PerceptualHash) differ: 0 for the same picture, about 32 for two unrelated ones.
func StzHashDistance(pcHashA, pcHashB)
	_nBits_ = 0
	for _i_ = 1 to 16
		_nA_ = ascii(pcHashA[_i_])
		_nB_ = ascii(pcHashB[_i_])
		if _nA_ >= 97 _nA_ -= 87 else _nA_ -= 48 ok
		if _nB_ >= 97 _nB_ -= 87 else _nB_ -= 48 ok
		for _k_ = 1 to 4
			if _nA_ % 2 != _nB_ % 2 _nBits_++ ok
			_nA_ = floor(_nA_ / 2)
			_nB_ = floor(_nB_ / 2)
		next
	next
	return _nBits_

func StzImageQ(pImage)
	return new stzImage(pImage)

# A blank image of a size, with 1 (gray), 3 (RGB) or 4 (RGBA) channels, every byte set to pnFill.
func StzImageNew(pnWidth, pnHeight, pnChannels, pnFill)
	return new stzImage(_StzImageMust(StzEngineImageNew(pnWidth, pnHeight, pnChannels, pnFill)))

# An image from raw bytes: rows top-down, pnChannels bytes per pixel, no padding.
func StzImageFromPixels(pnWidth, pnHeight, pnChannels, pcBytes)
	return new stzImage(_StzImageMust(StzEngineImageFromRaw(pnWidth, pnHeight, pnChannels, pcBytes)))

# An image decoded from the bytes of a PNG, JPEG, BMP, GIF, TGA, PSD, baseline TIFF or WebP file, turned upright by the EXIF
# orientation the file carries (a phone's photo is stored as the sensor saw it, with a tag saying how to turn it).
func StzImageFromBytes(pcBytes)
	return new stzImage(_StzImageMust(StzEngineImageDecode(pcBytes)))

# The same, with the pixels as the file stores them: the orientation is recorded (StoredOrientation) and NOT applied.
func StzImageFromBytesRaw(pcBytes)
	return new stzImage(_StzImageMust(StzEngineImageDecodeKeep(pcBytes)))

# An image from a file path with the pixels as the file stores them (StzImageQ turns them upright by EXIF).
func StzImageRawQ(pcPath)
	return new stzImage(_StzImageMust(StzEngineImageLoadKeep("" + pcPath)))

# How many images the engine holds; a guard reads it to prove nothing leaked.
func StzImagesAlive()
	return StzEngineImageLive()

#---------------------------------------------------------------------#
#  GEOMETRY HELPERS (IM2) -- points are [ x, y ], 1-based like every  #
#  Ring face; matrices are nine numbers in the engine's 0-based pixel  #
#  coordinates, ready for ApplyWarp                                     #
#---------------------------------------------------------------------#

# The 3x3 homography taking four points onto four others (OpenCV's getPerspectiveTransform).
func StzPerspectiveMatrix(paFrom, paTo)
	_a_ = StzEngineImagePerspectiveFrom(_StzPointsText(paFrom, -1), _StzPointsText(paTo, -1))
	if len(_a_) != 9
		stzraise("StzPerspectiveMatrix: four points onto four points, no three in a line.")
	ok
	return _a_

# The affine matrix taking three points onto three others (OpenCV's getAffineTransform).
func StzAffineMatrix(paFrom, paTo)
	_a_ = StzEngineImageAffineFrom(_StzPointsText(paFrom, -1), _StzPointsText(paTo, -1))
	if len(_a_) != 9
		stzraise("StzAffineMatrix: three points onto three points, not in a line.")
	ok
	return _a_

# The matrix turning an image CLOCKWISE by pnDegrees about the point (pnX, pnY), 1-based.
func StzRotationMatrix(pnX, pnY, pnDegrees, pnScale)
	return StzEngineImageRotationMatrix(pnX - 1, pnY - 1, -pnDegrees, pnScale)

# The polygon simplified so no dropped point lies farther than pnEpsilon from it (Douglas-Peucker, closed).
func StzApproxPolygon(paPoints, pnEpsilon)
	return StzEngineImageApproxPoly(_StzPointsText(paPoints, 0), pnEpsilon)

# The convex hull of the points, collinear points dropped.
func StzConvexHull(paPoints)
	return StzEngineImageConvexHull(_StzPointsText(paPoints, 0))

# The smallest rectangle, at any angle, holding every point: [ :corners = 4 points, :area ].
func StzMinAreaRect(paPoints)
	_a_ = StzEngineImageMinAreaRect(_StzPointsText(paPoints, 0))
	return [ :corners = [ _a_[1], _a_[2], _a_[3], _a_[4] ], :area = _a_[5][1] ]

# The area of a closed polygon (the shoelace formula), whatever its winding.
func StzPolygonArea(paPoints)
	_n_ = len(paPoints)
	_s_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ + 1
		if _j_ > _n_
			_j_ = 1
		ok
		_s_ += paPoints[_i_][1] * paPoints[_j_][2] - paPoints[_j_][1] * paPoints[_i_][2]
	next
	return fabs(_s_) / 2

# The perimeter of a closed polygon.
func StzPolygonPerimeter(paPoints)
	_n_ = len(paPoints)
	_s_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ + 1
		if _j_ > _n_
			_j_ = 1
		ok
		_s_ += StzPointDistance(paPoints[_i_], paPoints[_j_])
	next
	return _s_

func StzPointDistance(paA, paB)
	return sqrt((paA[1] - paB[1]) * (paA[1] - paB[1]) + (paA[2] - paB[2]) * (paA[2] - paB[2]))

# Four corners in the order top-left, top-right, bottom-right, bottom-left (by x + y and x - y).
func StzOrderedCorners(paFour)
	_aS_ = []
	_aD_ = []
	for _i_ = 1 to 4
		_aS_ + (paFour[_i_][1] + paFour[_i_][2])
		_aD_ + (paFour[_i_][1] - paFour[_i_][2])
	next
	_tl_ = _StzArgOf(_aS_, 0)
	_br_ = _StzArgOf(_aS_, 1)
	_tr_ = _StzArgOf(_aD_, 1)
	_bl_ = _StzArgOf(_aD_, 0)
	return [ paFour[_tl_], paFour[_tr_], paFour[_br_], paFour[_bl_] ]

func _StzArgOf(paNumbers, bMax)
	_n_ = len(paNumbers)
	_k_ = 1
	for _i_ = 2 to _n_
		if (bMax = 1 and paNumbers[_i_] > paNumbers[_k_]) or (bMax = 0 and paNumbers[_i_] < paNumbers[_k_])
			_k_ = _i_
		ok
	next
	return _k_

func _StzPointsText(paPoints, pnShift)
	_c_ = ""
	_n_ = len(paPoints)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += ";"
		ok
		_c_ += "" + (paPoints[_i_][1] + pnShift) + " " + (paPoints[_i_][2] + pnShift)
	next
	return _c_

func _StzMatrix9(paMatrix)
	_a_ = []
	_n_ = len(paMatrix)
	for _i_ = 1 to _n_
		if isList(paMatrix[_i_])
			_m_ = len(paMatrix[_i_])
			for _j_ = 1 to _m_
				_a_ + paMatrix[_i_][_j_]
			next
		else
			_a_ + paMatrix[_i_]
		ok
	next
	if len(_a_) != 9
		stzraise("stzImage: a warp matrix has nine numbers (three rows of three).")
	ok
	return _a_

func _StzImageMust(pnId)
	if pnId = 0
		stzraise("stzImage: " + StzEngineImageLastError())
	ok
	return pnId

# Holds an image -- pixels in the engine, 1, 3 or 4 channels of 0..255 -- and its classical operations.
#
# Build one from a file path, from a file's bytes (StzImageFromBytes), from raw pixels
# (StzImageFromPixels) or blank (StzImageNew). ApplyGrayScale changes the image, ApplyGrayScaleQ
# changes it and returns it to chain, and Grayscaled returns data (a new image) without altering it.
# Every copy of the object reaches the same pixels, and a change made through one is seen by all. An
# analysis returns a stzImageGrid of numbers, never a picture. Release frees the pixels.
#
#   receiver   o1 = StzImageFromPixels(2, 1, 3, char(255) + char(0) + char(0) + char(0) + char(0) + char(255))
#   example    ? @@( o1.Size() )
#              #--> [ 2, 1 ]
#              ? @@( o1.Pixel(1, 1) )
#              #--> [ 255, 0, 0 ]
#              o1.ApplyGrayScale()
#              ? @@( o1.Pixel(1, 1) )
#              #--> [ 76 ]
#              o1.Release()
#   see        stzImageGrid, stzCanvas
class stzImage from stzObject

	@nId = 0

	# Builds the image from a file path, or adopts an engine handle (a number).
	#
	#   pImage     a path to a PNG, JPEG, BMP, GIF, TGA, PSD, baseline TIFF or WebP file, or an engine image handle
	#   returns    nothing; the object is built
	#   warning    a file that cannot be read or decoded raises an error that says why
	def init(pImage)
		if isNumber(pImage)
			@nId = pImage
		else
			@nId = _StzImageMust(StzEngineImageLoad("" + pImage))
		ok

	# Returns the engine handle of the pixels.
	def Handle()
		return @nId

	# Frees the pixels; every copy of the object then holds nothing.
	#
	#   returns    1 when the pixels were freed, 0 when they already were
	def Release()
		_n_ = StzEngineImageFree(@nId)
		@nId = 0
		return _n_

	# TRUE if the object holds no live pixels.
	#
	#   returns    1 or 0
	#   see        Release
	def IsEmpty()
		return StzEngineImageWidth(@nId) = 0

	# Returns the EXIF orientation the file carried, 1 to 8, even when the load applied it.
	#
	# 1 means upright, and is also what a file with no tag says; 6 means the pixels are stored a quarter turn off.
	#
	#   returns    a number 1 to 8, or 0 when the object holds no pixels
	#   see        IsOrientationApplied, StzImageRawQ
	def StoredOrientation()
		return StzEngineImageOrientation(@nId)

	# TRUE if the load turned the pixels upright by the stored orientation.
	#
	# StzImageQ does; StzImageRawQ does not.
	#
	#   returns    1 or 0
	#   see        StoredOrientation
	def IsOrientationApplied()
		return StzEngineImageOrientationApplied(@nId) = 1

	#@ aka  -- 1. WHAT IT IS --------------------------------------------------------

	# Returns the number of pixel columns of the image, 0 when the object holds no pixels.
	#
	#   returns    a number
	#   see        Height, Size
	def Width()
		return StzEngineImageWidth(@nId)

	# Returns the number of pixel rows of the image, 0 when the object holds no pixels.
	#
	#   returns    a number
	#   see        Width, Size
	def Height()
		return StzEngineImageHeight(@nId)

	# Returns [ width, height ].
	def Size()
		return [ StzEngineImageWidth(@nId), StzEngineImageHeight(@nId) ]

	# Returns 1 (gray), 3 (RGB) or 4 (RGBA).
	def Channels()
		return StzEngineImageChannels(@nId)

	# Returns the channel values of one pixel, 1-based coordinates.
	#
	#   returns    a list of 1, 3 or 4 numbers in 0..255
	#   warning    a pixel outside the image raises an error
	def Pixel(pnX, pnY)
		_n_ = StzEngineImageChannels(@nId)
		_a_ = []
		for _k_ = 1 to _n_
			_v_ = StzEngineImageAt(@nId, pnX, pnY, _k_)
			if _v_ < 0
				stzraise("stzImage.Pixel: (" + pnX + ", " + pnY + ") is outside the " +
					This.Width() + " x " + This.Height() + " image.")
			ok
			_a_ + _v_
		next
		return _a_

	# Returns the raw pixel bytes, rows top-down, Channels() bytes per pixel.
	def Pixels()
		return StzEngineImageRaw(@nId)

	#@ aka  -- 2. FILES -------------------------------------------------------------

	# Writes the image to a file whose extension chooses the format: .png or .bmp.
	#
	#   returns    the image itself, so calls chain
	#   note       .jpg and .jpeg are written at quality 90; SaveAsJpeg chooses the quality
	#   warning    another extension raises an error
	def SaveAs(pcPath)
		_c_ = StzLower("" + pcPath)
		if StzRight(_c_, 4) = ".png"
			_StzImageMust(StzEngineImageSavePng(@nId, pcPath))
		but StzRight(_c_, 4) = ".bmp"
			_StzImageMust(StzEngineImageSaveBmp(@nId, pcPath))
		but StzRight(_c_, 4) = ".jpg" or StzRight(_c_, 5) = ".jpeg"
			_StzImageMust(StzEngineImageSaveJpeg(@nId, pcPath, 90))
		else
			stzraise("stzImage.SaveAs: the formats written are .png, .bmp and " +
				".jpg -- not '" + pcPath + "'.")
		ok
		return This

	# Writes the image as JPEG at a quality of 1 to 100; alpha is dropped.
	#
	#   returns    the image itself, so calls chain
	def SaveAsJpeg(pcPath, pnQuality)
		_StzImageMust(StzEngineImageSaveJpeg(@nId, pcPath, pnQuality))
		return This

	# Returns the bytes of the image encoded as JPEG at a quality of 1 to 100.
	def ToJPEG(pnQuality)
		return StzEngineImageToJpeg(@nId, pnQuality)

	# Returns the bytes of the image encoded as PNG.
	def ToPNG()
		return StzEngineImageToPng(@nId)

	# Returns the image as a data URI an HTML page shows inline: "data:image/jpeg;base64,...".
	#
	#   note       encoded in the engine, so the bytes never cross Ring as text; ToPngDataURI is lossless
	def ToJpegDataURI(pnQuality)
		return StzEngineImageToDataUri(@nId, pnQuality)

	# Returns the image as a PNG data URI that an HTML page shows inline.
	#
	#   returns    a text; the encoding is lossless and done in the engine
	#   see        ToJpegDataURI, ToPNG
	def ToPngDataURI()
		return StzEngineImageToDataUri(@nId, 0)

	#@ aka  -- 3. CHANNELS ----------------------------------------------------------

	# Changes the image in place to gray (BT.601), so every copy of the object sees the change.
	#
	#   returns    nothing; use ApplyGrayScaleQ to chain
	#   see        Grayscaled
	def ApplyGrayScale()
		This._Take(StzEngineImageConvert(@nId, 1))

		def ApplyGrayScaleQ()
			This.ApplyGrayScale()
			return This

	# Returns a gray copy (BT.601).
	def Grayscaled()
		return This._New(StzEngineImageConvert(@nId, 1))

	# Returns an RGB copy; a gray image repeats its level in the three channels.
	def Coloured()
		return This._New(StzEngineImageConvert(@nId, 3))

	# Returns an RGBA copy; alpha is 255 where the source had none.
	def WithAlpha()
		return This._New(StzEngineImageConvert(@nId, 4))

	# Changes the image in place to its colour-inverted form, alpha kept, so every copy of the object sees the change.
	#
	#   returns    nothing; use ApplyInversionQ to chain
	#   see        Inverted
	def ApplyInversion()
		This._Take(StzEngineImageInvert(@nId))

		def ApplyInversionQ()
			This.ApplyInversion()
			return This

	# Returns a copy with the colour channels inverted; alpha is kept.
	def Inverted()
		return This._New(StzEngineImageInvert(@nId))

	#@ aka  -- 4. GEOMETRY ----------------------------------------------------------

	# Changes the image in place to the rectangle whose top-left pixel is (pnX, pnY), 1-based.
	#
	#   pnX        the column of the rectangle's top-left pixel
	#   pnY        the row of the rectangle's top-left pixel
	#   pnWidth    the rectangle's size along the columns, in pixels
	#   pnHeight   the rectangle's size along the rows, in pixels
	#   returns    nothing; use ApplyCropQ to chain
	#   warning    a rectangle that leaves the image raises an error
	#   see        Cropped
	def ApplyCrop(pnX, pnY, pnWidth, pnHeight)
		This._Take(StzEngineImageCrop(@nId, pnX, pnY, pnWidth, pnHeight))

		def ApplyCropQ(pnX, pnY, pnWidth, pnHeight)
			This.ApplyCrop(pnX, pnY, pnWidth, pnHeight)
			return This

	# Returns the rectangle whose top-left pixel is (pnX, pnY), 1-based.
	#
	#   warning    a rectangle that leaves the image raises an error
	def Cropped(pnX, pnY, pnWidth, pnHeight)
		return This._New(StzEngineImageCrop(@nId, pnX, pnY, pnWidth, pnHeight))

	# Changes the image in place to its mirror image: :horizontal swaps left and right, :vertical top and bottom.
	#
	#   pcWay      :horizontal (also :horizontally or :x) or :vertical (also :vertically or :y)
	#   returns    nothing; use ApplyFlipQ to chain
	#   warning    any other way raises an error
	#   see        Flipped
	def ApplyFlip(pcWay)
		This._Take(StzEngineImageFlip(@nId, This._Horizontal(pcWay)))

		def ApplyFlipQ(pcWay)
			This.ApplyFlip(pcWay)
			return This

	# Returns a mirrored copy: :horizontal swaps left and right, :vertical top and bottom.
	def Flipped(pcWay)
		return This._New(StzEngineImageFlip(@nId, This._Horizontal(pcWay)))

	def _Horizontal(pcWay)
		_c_ = StzLower("" + pcWay)
		if _c_ = "horizontal" or _c_ = "horizontally" or _c_ = "x"
			return 1
		but _c_ = "vertical" or _c_ = "vertically" or _c_ = "y"
			return 0
		ok
		stzraise("stzImage.Flip: the ways are :horizontal and :vertical, not '" + pcWay + "'.")

	# Changes the image in place by turning it clockwise, exactly for a multiple of 90 degrees.
	#
	# Any other angle turns about the centre on the same canvas, the corners black (ApplyRotationXT fills them).
	#
	#   pnDegrees  the angle in degrees, clockwise
	#   returns    nothing; use ApplyRotationQ to chain
	#   warning    an angle that is not a number raises an error
	#   see        Rotated, ApplyRotationXT
	def ApplyRotation(pnDegrees)
		This._Take(This._Rotate(pnDegrees, 0))

		def ApplyRotationQ(pnDegrees)
			This.ApplyRotation(pnDegrees)
			return This

	# Returns the image turned clockwise as a new image (data), exactly for a multiple of 90 degrees.
	#
	# Any other angle turns about the centre on the same canvas, the corners black (RotatedXT fills them).
	#
	#   pnDegrees  the angle in degrees, clockwise
	#   returns    a new stzImage; the image itself is unchanged
	#   warning    an angle that is not a number raises an error
	#   see        ApplyRotation, RotatedXT
	def Rotated(pnDegrees)
		return This._New(This._Rotate(pnDegrees, 0))

	# Changes the image turned clockwise by any angle, the uncovered corners filled with pnFill.
	def ApplyRotationXT(pnDegrees, pnFill)
		This._Take(This._Rotate(pnDegrees, pnFill))

	# Returns the image turned clockwise by any angle as a new image (data), corners filled with pnFill.
	def RotatedXT(pnDegrees, pnFill)
		return This._New(This._Rotate(pnDegrees, pnFill))

	# a multiple of 90 is an exact quarter turn (the canvas swaps when odd); any other angle
	# turns about the centre on the same canvas (OpenCV's getRotationMatrix2D + warpAffine)
	def _Rotate(pnDegrees, pnFill)
		if NOT isNumber(pnDegrees)
			stzraise("stzImage.Rotate: an angle in degrees, clockwise.")
		ok
		if pnDegrees % 90 = 0
			return StzEngineImageRotate(@nId, pnDegrees / 90)
		ok
		_nW_ = This.Width()
		_nH_ = This.Height()
		_aM_ = StzRotationMatrix((_nW_ + 1) / 2, (_nH_ + 1) / 2, pnDegrees, 1)
		return This._Warp(_aM_, _nW_, _nH_, pnFill)

	# Changes the image in place to the given size, resampled bilinearly.
	#
	#   pnWidth    the new number of pixel columns
	#   pnHeight   the new number of pixel rows
	#   returns    nothing; use ApplyResizeQ to chain
	#   see        Resized, ResizedXT
	def ApplyResize(pnWidth, pnHeight)
		This._Take(StzEngineImageResize(@nId, pnWidth, pnHeight, 1))

		def ApplyResizeQ(pnWidth, pnHeight)
			This.ApplyResize(pnWidth, pnHeight)
			return This

	# Returns a copy resampled bilinearly to the size.
	def Resized(pnWidth, pnHeight)
		return This._New(StzEngineImageResize(@nId, pnWidth, pnHeight, 1))

	# Returns a resampled copy by a named method: :nearest, :bilinear or :area.
	#
	#   note       :area averages exactly what each pixel covers when shrinking, and is bilinear
	#              when growing, as OpenCV's INTER_AREA is
	def ResizedXT(pnWidth, pnHeight, pcMethod)
		_c_ = StzLower("" + pcMethod)
		_n_ = 1
		if _c_ = "nearest"
			_n_ = 0
		but _c_ = "area"
			_n_ = 2
		but _c_ != "bilinear"
			stzraise("stzImage.ResizedXT: the methods are :nearest, :bilinear and :area.")
		ok
		return This._New(StzEngineImageResize(@nId, pnWidth, pnHeight, _n_))

	#@ aka  -- 5. FILTERS AND THRESHOLDS --------------------------------------------

	# Changes the image in place to its Gaussian-blurred form (OpenCV's 8-bit kernel, borders reflected).
	#
	#   pnSigma    the blur's standard deviation, above 0 and at most 100
	#   returns    nothing; use ApplyBlurQ to chain
	#   warning    a sigma outside 0 < sigma <= 100 raises an error
	#   see        Blurred
	def ApplyBlur(pnSigma)
		This._Take(StzEngineImageBlur(@nId, pnSigma))

		def ApplyBlurQ(pnSigma)
			This.ApplyBlur(pnSigma)
			return This

	# Returns a Gaussian-blurred copy (OpenCV's 8-bit kernel, borders reflected).
	#
	#   warning    a sigma outside 0 < sigma <= 100 raises an error
	def Blurred(pnSigma)
		return This._New(StzEngineImageBlur(@nId, pnSigma))

	# Returns Otsu's threshold of the gray levels: where two classes separate best.
	def OtsuThreshold()
		return StzEngineImageOtsu(@nId)

	# Changes the image in place to a one-channel image: 255 where the gray level is above the threshold, 0 elsewhere.
	#
	#   pThreshold   a level 0..255, or :otsu to let the image choose it
	#   returns      nothing; use ApplyThresholdQ to chain
	#   warning      any other value raises an error
	#   see          Thresholded, OtsuThreshold
	def ApplyThreshold(pThreshold)
		This._Take(StzEngineImageThreshold(@nId, This._Level(pThreshold)))

		def ApplyThresholdQ(pThreshold)
			This.ApplyThreshold(pThreshold)
			return This

	# Returns a one-channel copy: 255 where the gray level is ABOVE the threshold, 0 elsewhere.
	#
	#   pThreshold   a level 0..255, or :otsu to let the image choose it
	def Thresholded(pThreshold)
		return This._New(StzEngineImageThreshold(@nId, This._Level(pThreshold)))

	def _Level(pThreshold)
		if isNumber(pThreshold)
			return pThreshold
		ok
		if StzLower("" + pThreshold) = "otsu"
			return StzEngineImageOtsu(@nId)
		ok
		stzraise("stzImage.Threshold: a level 0..255 or :otsu.")

	#@ aka  -- 6. ANALYSES RETURN GRIDS ---------------------------------------------

	# Returns the 1 x 256 grid of pixel counts per gray level (BT.601).
	def Histogram()
		return This.HistogramOf(0)

	# Returns the 1 x 256 grid of counts for one channel; channel 0 is the gray.
	def HistogramOf(pnChannel)
		return new stzImageGrid(_StzImageMust(StzEngineImageHistogram(@nId, pnChannel)),
			"", "level")

	# Returns the gray levels as a grid of Height() rows and Width() columns.
	def ToGrid()
		return This.ToGridOf(0)

	# Returns one channel as a grid of Height() rows and Width() columns; channel 0 is the gray.
	def ToGridOf(pnChannel)
		return new stzImageGrid(_StzImageMust(StzEngineImageToGrid(@nId, pnChannel)),
			"y", "x")

	# Returns the luminance of the text and of its background inside a box, the figures a contrast ratio is built from.
	#
	# It measures and never judges. The box's gray levels are split by Otsu and the side with fewer
	# pixels is the ink; the text is the median of the quarter of the ink farthest from the split, and the
	# background the median of the pixels at least 3 pixels from any ink. Luminance is WCAG 2.x relative
	# luminance (sRGB), 0 for black and 1 for white.
	#
	#   paBox      [ x0, y0, x1, y1 ] in pixels from 0, both ends inside the box -- the box StzOcrModelLinesXT gives
	#   returns    [ :text, :background, :spread, :ink, :bgpixels ]; :spread is the 2nd to 98th percentile range
	#              of the background, :ink and :bgpixels how many pixels each figure stands on. :background
	#              and :spread are "" when no pixel is 3 pixels from ink; [] when the box has one gray level
	#   warning    a box that is not a list of four values raises an error
	#   example    o1 = StzImageNew(40, 20, 3, 255)
	#              o1.ApplyBox([ 11, 6, 12, 6 ], [ 51, 51, 51 ], 3)
	#              aLum = o1.TextLuminanceInBox([ 0, 0, 39, 19 ])
	#              ? aLum[:ink]
	#              #--> 72
	#              ? aLum[:background]
	#              #--> 1
	def TextLuminanceInBox(paBox)
		if NOT (isList(paBox) and len(paBox) = 4)
			stzraise("TextLuminanceInBox: the box is [ x0, y0, x1, y1 ]")
		ok
		_a_ = StzEngineImageTextLuminance(@nId, paBox[1], paBox[2], paBox[3], paBox[4])
		if len(_a_) = 0 return [] ok
		if _a_[5] = 0
			return [ :text = _a_[1], :background = "", :spread = "", :ink = _a_[4], :bgpixels = 0 ]
		ok
		return [ :text = _a_[1], :background = _a_[2], :spread = _a_[3], :ink = _a_[4], :bgpixels = _a_[5] ]

	#@ aka  -- 7. MORPHOLOGY AND SMOOTHING (IM1) --------------------------------------

	# Returns a copy after a morphological operation, as OpenCV's morphologyEx.
	#
	#   pcOp       :erode, :dilate, :open, :close, :gradient, :tophat or :blackhat
	#   pnSize     the kernel's side, odd, 1..255
	#   pcShape    :rect, :cross or :ellipse
	#   note       pixels outside the image are ignored, as OpenCV's default border does
	def Morphed(pcOp, pnSize, pcShape)
		return This._New(This._Morph(pcOp, pnSize, pcShape))

	# Changes the image in place by a morphological operation, as OpenCV's morphologyEx.
	#
	#   pcOp       :erode, :dilate, :open, :close, :gradient, :tophat or :blackhat
	#   pnSize     the kernel's side, odd, 1..255
	#   pcShape    :rect, :cross or :ellipse
	#   returns    nothing; use ApplyMorphologyQ to chain
	#   warning    an unknown operation or shape raises an error
	#   see        Morphed
	def ApplyMorphology(pcOp, pnSize, pcShape)
		This._Take(This._Morph(pcOp, pnSize, pcShape))

		def ApplyMorphologyQ(pcOp, pnSize, pcShape)
			This.ApplyMorphology(pcOp, pnSize, pcShape)
			return This

	def _Morph(pcOp, pnSize, pcShape)
		_acOps_ = [ "erode", "dilate", "open", "close", "gradient", "tophat", "blackhat" ]
		_acShapes_ = [ "rect", "cross", "ellipse" ]
		_nOp_ = ring_find(_acOps_, StzLower("" + pcOp))
		_nSh_ = ring_find(_acShapes_, StzLower("" + pcShape))
		if _nOp_ = 0 or _nSh_ = 0
			stzraise("stzImage.Morph: the operations are :erode, :dilate, :open, :close, " +
				":gradient, :tophat, :blackhat; the shapes :rect, :cross, :ellipse.")
		ok
		return StzEngineImageMorph(@nId, _nOp_ - 1, _nSh_ - 1, pnSize)

	# Returns a copy eroded with a square kernel of the size: dark areas grow.
	def Eroded(pnSize)
		return This.Morphed(:erode, pnSize, :rect)

	# Returns a copy dilated with a square kernel of the size: bright areas grow.
	def Dilated(pnSize)
		return This.Morphed(:dilate, pnSize, :rect)

	# Returns a copy opened (erode then dilate): bright specks smaller than the kernel vanish.
	def Opened(pnSize)
		return This.Morphed(:open, pnSize, :rect)

	# Returns a copy closed (dilate then erode): dark gaps smaller than the kernel fill.
	def Closed(pnSize)
		return This.Morphed(:close, pnSize, :rect)

	# Changes the image in place so each pixel is the median of its window, which removes salt-and-pepper noise.
	#
	#   pnSize     the window's side
	#   returns    nothing; use ApplyMedianFilterQ to chain
	#   note       edges are kept
	#   see        MedianFiltered
	def ApplyMedianFilter(pnSize)
		This._Take(StzEngineImageMedian(@nId, pnSize))

		def ApplyMedianFilterQ(pnSize)
			This.ApplyMedianFilter(pnSize)
			return This

	# Returns a copy where each pixel is the median of its window: removes salt-and-pepper noise, keeps edges.
	def MedianFiltered(pnSize)
		return This._New(StzEngineImageMedian(@nId, pnSize))

	# Changes the image in place to a gray image whose levels are spread over 0..255 by histogram equalisation.
	#
	#   returns    nothing; use ApplyEqualizationQ to chain
	#   see        Equalized
	def ApplyEqualization()
		This._Take(StzEngineImageEqualize(@nId))

		def ApplyEqualizationQ()
			This.ApplyEqualization()
			return This

	# Returns a gray copy whose levels are spread over 0..255 by histogram equalisation.
	def Equalized()
		return This._New(StzEngineImageEqualize(@nId))

	#@ aka  -- 8. EDGES, THRESHOLDS, MATCHING (IM1) -----------------------------------

	# Returns the gray's horizontal Sobel derivative as a grid (signed numbers).
	def SobelX()
		return new stzImageGrid(_StzImageMust(StzEngineImageSobel(@nId, 1, 0, 0)), "y", "x")

	# Returns the gray's vertical Sobel derivative as a grid.
	def SobelY()
		return new stzImageGrid(_StzImageMust(StzEngineImageSobel(@nId, 0, 1, 0)), "y", "x")

	# Returns a derivative grid: pcAxis :x or :y, pcKernel :sobel or :scharr.
	def DerivativeXT(pcAxis, pcKernel)
		_nX_ = 0
		_nY_ = 1
		if StzLower("" + pcAxis) = "x"
			_nX_ = 1
			_nY_ = 0
		ok
		_nS_ = 0
		if StzLower("" + pcKernel) = "scharr"
			_nS_ = 1
		ok
		return new stzImageGrid(_StzImageMust(StzEngineImageSobel(@nId, _nX_, _nY_, _nS_)), "y", "x")

	# Returns the edges found by Canny as a one-channel image (255 on an edge).
	#
	#   pnLow      below it a gradient is never an edge
	#   pnHigh     above it a gradient always is; between, only when joined to a strong one
	def Edges(pnLow, pnHigh)
		return This._New(StzEngineImageCanny(@nId, pnLow, pnHigh, 0))

	# Edges with the exact gradient length (sqrt) instead of OpenCV's default |dx| + |dy|.
	def EdgesL2(pnLow, pnHigh)
		return This._New(StzEngineImageCanny(@nId, pnLow, pnHigh, 1))

	# Returns a copy thresholded against the mean of each pixel's block (uneven light).
	#
	#   pnBlock    the window's side, odd, >= 3
	#   pnC        how far below the local mean a pixel may be and still count as bright
	def AdaptiveThresholded(pnBlock, pnC)
		return This._New(StzEngineImageAdaptiveMean(@nId, pnBlock, pnC))

	# Returns a copy thresholded by Sauvola's rule, the document binarizer: k 0.2, R 128.
	def SauvolaThresholded(pnWindow)
		return This._New(StzEngineImageSauvola(@nId, pnWindow, 0.2, 128))

	def SauvolaThresholdedXT(pnWindow, pnK, pnR)
		return This._New(StzEngineImageSauvola(@nId, pnWindow, pnK, pnR))

	# Changes the image in place to its Canny edges, a one-channel image with 255 on an edge.
	#
	#   pnLow      below it a gradient is never an edge
	#   pnHigh     above it a gradient always is; between, only when joined to a strong one
	#   returns    nothing; use ApplyEdgeDetectionQ to chain
	#   see        Edges
	def ApplyEdgeDetection(pnLow, pnHigh)
		This._Take(StzEngineImageCanny(@nId, pnLow, pnHigh, 0))

		def ApplyEdgeDetectionQ(pnLow, pnHigh)
			This.ApplyEdgeDetection(pnLow, pnHigh)
			return This

	# Changes the image in place by thresholding each pixel against the mean of its block, for uneven light.
	#
	#   pnBlock    the window's side, odd, >= 3
	#   pnC        how far below the local mean a pixel may be and still count as bright
	#   returns    nothing; use ApplyAdaptiveThresholdQ to chain
	#   see        AdaptiveThresholded
	def ApplyAdaptiveThreshold(pnBlock, pnC)
		This._Take(StzEngineImageAdaptiveMean(@nId, pnBlock, pnC))

		def ApplyAdaptiveThresholdQ(pnBlock, pnC)
			This.ApplyAdaptiveThreshold(pnBlock, pnC)
			return This

	# Changes the image in place by Sauvola's rule, the document binarizer, with k 0.2 and R 128.
	#
	#   pnWindow   the window's side
	#   returns    nothing; use ApplySauvolaThresholdQ to chain
	#   see        SauvolaThresholded
	def ApplySauvolaThreshold(pnWindow)
		This._Take(StzEngineImageSauvola(@nId, pnWindow, 0.2, 128))

		def ApplySauvolaThresholdQ(pnWindow)
			This.ApplySauvolaThreshold(pnWindow)
			return This

	# Returns the gray's integral image: a grid of Height()+1 rows by Width()+1 columns of running sums.
	def IntegralGrid()
		return new stzImageGrid(_StzImageMust(StzEngineImageIntegral(@nId)), "y", "x")

	# Returns the normalised correlation of a template at every position, a grid in -1..1.
	def MatchTemplate(oTemplate)
		return new stzImageGrid(_StzImageMust(StzEngineImageMatchTemplate(@nId, oTemplate.Handle())),
			"top", "left")

	# Returns where a template matches best: [ left, top, score ], 1-based.
	def FindTemplate(oTemplate)
		_oG_ = This.MatchTemplate(oTemplate)
		_a_ = _oG_.Peak()
		_oG_.Release()
		return [ _a_[2], _a_[1], _a_[3] ]

	# Returns the connected regions of non-black pixels, each as a hash list.
	#
	#   returns    [ :left, :top, :width, :height, :area, :cx, :cy ] per region, in raster order of
	#              each region's first pixel, coordinates 1-based, 8-connected
	def Components()
		return This.ComponentsXT(8)

	def ComponentsXT(pnConnectivity)
		_n8_ = 0
		if pnConnectivity = 8
			_n8_ = 1
		ok
		_a_ = StzEngineImageComponents(@nId, _n8_)
		if len(_a_) != 2 or _a_[1] = 0
			stzraise("stzImage.Components: " + StzEngineImageLastError())
		ok
		StzEngineImageGridFree(_a_[1])
		_aOut_ = []
		_n_ = StzEngineImageGridRows(_a_[2])
		for _i_ = 1 to _n_
			_aOut_ + [ :left = StzEngineImageGridAt(_a_[2], _i_, 1),
				:top = StzEngineImageGridAt(_a_[2], _i_, 2),
				:width = StzEngineImageGridAt(_a_[2], _i_, 3),
				:height = StzEngineImageGridAt(_a_[2], _i_, 4),
				:area = StzEngineImageGridAt(_a_[2], _i_, 5),
				:cx = StzEngineImageGridAt(_a_[2], _i_, 6),
				:cy = StzEngineImageGridAt(_a_[2], _i_, 7) ]
		next
		StzEngineImageGridFree(_a_[2])
		return _aOut_

	# Returns the label of every pixel (0 for black, 1.. per region) as a grid.
	def ComponentLabels()
		_a_ = StzEngineImageComponents(@nId, 1)
		StzEngineImageGridFree(_a_[2])
		return new stzImageGrid(_StzImageMust(_a_[1]), "y", "x")

	# Returns the gray's 2D Fourier magnitude, zero frequency at the centre, log(1 + |F|).
	def Spectrum()
		return This.SpectrumXT(1, 1)

	def SpectrumXT(bShift, bLog)
		return new stzImageGrid(_StzImageMust(StzEngineImageFft2(@nId, bShift, bLog)),
			"frequency y", "frequency x")

	# Returns how the image differs from another of the same size and channels.
	#
	#   returns    [ :pixels, :max, :mean, :mse ] -- pixels that differ, the largest and the mean
	#              channel difference, the mean squared difference
	#   warning    images of different shapes raise an error
	def DifferenceWith(oOther)
		_a_ = StzEngineImageCompare(@nId, oOther.Handle())
		if len(_a_) != 4
			stzraise("stzImage.DifferenceWith: the two images differ in size or channels.")
		ok
		return [ :pixels = _a_[1], :max = _a_[2], :mean = _a_[3], :mse = _a_[4] ]

	#@ aka  -- 9. GEOMETRY (IM2) ------------------------------------------------------

	# Changes the image to its warp by a 3x3 matrix, onto a canvas of the size.
	#
	#   paMatrix   nine numbers (or three rows of three) in the engine's 0-based pixel coordinates,
	#              as StzPerspectiveMatrix, StzAffineMatrix and StzRotationMatrix return them
	#   note       OpenCV's warpAffine / warpPerspective, pixel for pixel: bilinear, what falls
	#              outside the source is black (ApplyWarpXT chooses the fill)
	def ApplyWarp(paMatrix, pnWidth, pnHeight)
		This._Take(This._Warp(paMatrix, pnWidth, pnHeight, 0))

		def ApplyWarpQ(paMatrix, pnWidth, pnHeight)
			This.ApplyWarp(paMatrix, pnWidth, pnHeight)
			return This

	def ApplyWarpXT(paMatrix, pnWidth, pnHeight, pnFill)
		This._Take(This._Warp(paMatrix, pnWidth, pnHeight, pnFill))

	# Returns the warp by a 3x3 matrix as a new image (data); the image is not changed.
	def Warped(paMatrix, pnWidth, pnHeight)
		return This._New(This._Warp(paMatrix, pnWidth, pnHeight, 0))

	def WarpedXT(paMatrix, pnWidth, pnHeight, pnFill)
		return This._New(This._Warp(paMatrix, pnWidth, pnHeight, pnFill))

	def _Warp(paMatrix, pnWidth, pnHeight, pnFill)
		_m_ = _StzMatrix9(paMatrix)
		_nP_ = 0
		if _m_[7] != 0 or _m_[8] != 0 or _m_[9] != 1
			_nP_ = 1
		ok
		return StzEngineImageWarp(@nId, _nP_, pnWidth, pnHeight, pnFill,
			_m_[1], _m_[2], _m_[3], _m_[4], _m_[5], _m_[6], _m_[7], _m_[8], _m_[9])

	# Returns what is not the background, as a one-channel image (data): 0 for background pixels, 255 elsewhere.
	#
	# The background is the pixels connected to the border whose gray is within the tolerance of the border's median gray.
	#
	#   returns    a new one-channel stzImage
	#   note       the tolerance is MEASURED from the border itself: 3 robust sigmas of its gray, at
	#              least 4 -- ForegroundMaskXT(n) sets it by hand; ForegroundTolerance() says what the
	#              last mask used. A dark object or band not matching the border stays foreground
	#   see        PageCorners, ForegroundMaskXT
	def ForegroundMask()
		return This._New(StzEngineImageForeground(@nId, 0))

	def ForegroundMaskXT(pnTolerance)
		return This._New(StzEngineImageForeground(@nId, pnTolerance))

	# Returns the tolerance the last foreground mask used.
	def ForegroundTolerance()
		return StzEngineImageForegroundTolerance()

	# Returns the outer outline of every bright region, as lists of [ x, y ] points, 1-based.
	#
	#   note       OpenCV's findContours (RETR_EXTERNAL, CHAIN_APPROX_SIMPLE): only the corners of each
	#              outline are kept; a region inside another's hole is not an outer outline
	def Contours()
		return This.ContoursXT(:simple)

	# Contours with every border point (:all) or only the corners (:simple).
	def ContoursXT(pcHow)
		_nS_ = 1
		if StzLower("" + pcHow) = "all"
			_nS_ = 0
		ok
		_a_ = StzEngineImageContours(@nId, _nS_)
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_m_ = len(_a_[_i_])
			for _j_ = 1 to _m_
				_a_[_i_][_j_][1] += 1
				_a_[_i_][_j_][2] += 1
			next
		next
		return _a_

	# Returns the four corners of the page in a photograph, or [ ] when no four-sided bright region stands out.
	#
	# The corners come top-left, top-right, bottom-right, bottom-left, 1-based.
	#
	#   returns    a list of four [ x, y ] points, or []
	#   note       the page is the largest region that is not the background -- the background
	#              being what touches the border and has the border's colour, within a tolerance
	#              measured from the border (ForegroundMask) --
	#              its outline simplified to 2% of its perimeter; it must come down to four corners
	#   see        ApplyPageFlattening, ForegroundMask
	def PageCorners()
		_oB_ = This.ForegroundMask()
		_aC_ = _oB_.Contours()
		_oB_.Release()
		_n_ = len(_aC_)
		if _n_ = 0
			return []
		ok
		_nBest_ = 1
		_nArea_ = 0
		for _i_ = 1 to _n_
			_a_ = StzPolygonArea(_aC_[_i_])
			if _a_ > _nArea_
				_nArea_ = _a_
				_nBest_ = _i_
			ok
		next
		_aQ_ = StzApproxPolygon(_aC_[_nBest_], 0.02 * StzPolygonPerimeter(_aC_[_nBest_]))
		if len(_aQ_) != 4
			return []
		ok
		return StzOrderedCorners(_aQ_)

	# Changes the image to its page, flattened: the corners PageCorners finds are pulled to a rectangle.
	#
	# The rectangle is as wide and as tall as the page's longer edges IN THE PHOTOGRAPH.
	#
	#   returns    nothing; use ApplyPageFlatteningQ to chain
	#   note       a single photograph does not give a page's true proportions: perspective shortens
	#              the far edge, and undoing that needs the camera's focal length. When the page's
	#              size is known (A4, a receipt), say it with ApplyPageFlatteningXT
	#   warning    raises an error when no page is found; ask PageCorners first to decide
	#   see        PageCorners, ApplyPageFlatteningXT
	def ApplyPageFlattening()
		This._Take(This._Flatten(0, 0))

		def ApplyPageFlatteningQ()
			This.ApplyPageFlattening()
			return This

	# Changes the image to its page flattened onto a rectangle of a known size.
	def ApplyPageFlatteningXT(pnWidth, pnHeight)
		This._Take(This._Flatten(pnWidth, pnHeight))

	# Returns the page flattened as a new image (data); the photograph is not changed.
	def FlattenedPage()
		return This._New(This._Flatten(0, 0))

	# Returns the page flattened onto a rectangle of a known size, as a new image (data).
	def FlattenedPageXT(pnWidth, pnHeight)
		return This._New(This._Flatten(pnWidth, pnHeight))

	def _Flatten(pnWidth, pnHeight)
		_aC_ = This.PageCorners()
		if len(_aC_) != 4
			stzraise("stzImage.FlattenedPage: no page found -- no bright four-sided region " +
				"stands out from its background.")
		ok
		_nW_ = StzPointDistance(_aC_[1], _aC_[2])
		_n2_ = StzPointDistance(_aC_[4], _aC_[3])
		if _n2_ > _nW_
			_nW_ = _n2_
		ok
		_nH_ = StzPointDistance(_aC_[1], _aC_[4])
		_n2_ = StzPointDistance(_aC_[2], _aC_[3])
		if _n2_ > _nH_
			_nH_ = _n2_
		ok
		_nW_ = floor(_nW_ + 0.5)
		_nH_ = floor(_nH_ + 0.5)
		if pnWidth > 0 and pnHeight > 0
			_nW_ = pnWidth
			_nH_ = pnHeight
		ok
		_aM_ = StzPerspectiveMatrix(_aC_, [ [ 1, 1 ], [ _nW_, 1 ], [ _nW_, _nH_ ], [ 1, _nH_ ] ])
		return This._Warp(_aM_, _nW_, _nH_, 255)

	#@ aka  -- 10. WHAT IS IN THE PICTURE (IM3: models, through the governed door) -------

	# Returns the five most likely ImageNet labels, best first: [ :label, :score, :index ] each.
	#
	#   note       MobileNetV3-Large (models/vision); every call is recorded in the security ledger
	def Classify()
		return This.ClassifyXT(5)

	def ClassifyXT(pnHowMany)
		_cP_ = _StzVisionModelOrRaise($cStzVisionClassifier, "Classify")
		_a_ = StzEngineNeuralVisionClassify(_cP_, This.Pixels(), This.Width(), This.Height(),
			This.Channels(), pnHowMany, 4)
		if len(_a_) = 0
			_StzVisionFailed("Classify", $cStzVisionClassifier)
		ok
		_aOut_ = []
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_aOut_ + [ :label = _a_[_i_][1], :score = _a_[_i_][2], :index = _a_[_i_][3] ]
		next
		_StzVisionDoor("classify", $cStzVisionClassifier, "best '" + _aOut_[1][:label] + "' " + _aOut_[1][:score])
		return _aOut_

	# Returns the faces found: [ :box = [ x, y, w, h ], :score, :landmarks ] each, 1-based pixels.
	#
	#   note       YuNet at a score of 0.5 or more (chosen on a dev set apart from the golden one, see
	#              stzVision.ring); the five landmarks are the two eyes, the nose tip and the two mouth corners.
	#              It FINDS faces; it never says whose they are (identification is not in the kit)
	def Faces()
		return This.FacesXT($nStzVisionFaceThreshold)

	def FacesXT(pnMinScore)
		_cP_ = _StzVisionModelOrRaise($cStzVisionFaceModel, "Faces")
		_a_ = StzEngineNeuralVisionFaces(_cP_, This.Pixels(), This.Width(), This.Height(),
			This.Channels(), pnMinScore, 0.3, 4)
		_cErr_ = StzEngineNeuralOcrGraphError()
		_aOut_ = []
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_r_ = _a_[_i_]
			_aL_ = []
			for _k_ = 0 to 4
				_aL_ + [ _r_[6 + 2 * _k_] + 1, _r_[7 + 2 * _k_] + 1 ]
			next
			_aOut_ + [ :box = [ _r_[1] + 1, _r_[2] + 1, _r_[3], _r_[4] ], :score = _r_[5], :landmarks = _aL_ ]
		next
		_StzVisionDoor("faces", $cStzVisionFaceModel, "" + len(_aOut_) + " face(s)")
		return _aOut_

	# Returns the objects found: [ :label, :score, :box = [ x, y, w, h ] ] each, 1-based pixels.
	#
	#   note       YOLOX-tiny over the 80 COCO classes (person, car, bus, dog, cup...); a score of
	#              0.3 or more by default
	def Objects()
		return This.ObjectsXT(0.3)

	# Returns the boxes of what words name, found by an open-vocabulary detector (OWL-ViT), best score first.
	#
	# IM9f: a word does not have to be one the object detector was trained on. The first call about a picture
	# runs the 768 x 768 graph (about 0.7 s on the CPU); a second call about the SAME pixels pays only for words
	# it has not seen. The threshold is the WARM RULE (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8, upheld by
	# the court on 952 fresh pairs): the picture's logit-shift field is read first, and on a warm picture -- one
	# where the model says "yes, around here" too generously -- the threshold is raised, which drops the extra
	# boxes around an object it found anyway. FindByWordsXT takes an explicit threshold and applies no rule.
	#
	#   pWords     the words to find -- "a red mug", "traffic cone" -- as a text or a list of them
	#   returns    [ [ :query, :score, :box = [ x, y, w, h ] ] ... ], the box in 1-based pixels like Objects(); at
	#              most 20 boxes per word
	#   see        FindByWordsXT, FindByWordsThreshold, Objects
	def FindByWords(pWords)
		return This.FindByWordsXT(pWords, This.FindByWordsThreshold())

	# Returns the score threshold FindByWords uses for this picture, raised when the picture reads warm.
	#
	# It is $nStzVisionFindScore, raised by $nStzVisionWarmStep when the mean of the picture's 576 logit shifts is
	# at least $nStzVisionWarmShift. Reading the field costs nothing more: it comes from the same graph run.
	#
	#   returns    a number
	#   see        FindByWords, FindByWordsXT
	def FindByWordsThreshold()
		_nThr_ = $nStzVisionFindScore
		if _StzVisionOwlHeads(This)[:meanShift] >= $nStzVisionWarmShift
			_nThr_ += $nStzVisionWarmStep
		ok
		return _nThr_

	def FindByWordsXT(pWords, pnMinScore)
		_aW_ = _StzVisionWordList(pWords)
		if len(_aW_) = 0
			return []
		ok
		_cV_ = _StzVisionModelOrRaise($cStzVisionOwlVision, "FindByWords")
		_cT_ = _StzVisionModelOrRaise($cStzVisionOwlText, "FindByWords")
		_cVocab_ = _StzVisionModelOrRaise($cStzVisionOwlVocab, "FindByWords")
		_cMerges_ = _StzVisionModelOrRaise($cStzVisionOwlMerges, "FindByWords")
		_cQ_ = ""
		_n_ = len(_aW_)
		for _i_ = 1 to _n_
			if _i_ > 1 _cQ_ += char(10) ok
			_cQ_ += _aW_[_i_]
		next
		_a_ = StzEngineNeuralOwlFind(_cV_, _cT_, _cVocab_, _cMerges_, _cQ_, This.Pixels(), This.Width(), This.Height(),
			This.Channels(), pnMinScore, $nStzVisionFindNms, 4)
		_aKept_ = []
		for _i_ = 1 to _n_
			_aKept_ + 0
		next
		_aOut_ = []
		_m_ = len(_a_)
		for _i_ = 1 to _m_
			_r_ = _a_[_i_]
			_q_ = floor(_r_[6])
			if _aKept_[_q_] < $nStzVisionFindMax
				_aKept_[_q_] = _aKept_[_q_] + 1
				_aOut_ + [ :query = _aW_[_q_], :score = _r_[5], :box = [ _r_[1] + 1, _r_[2] + 1, _r_[3], _r_[4] ] ]
			ok
		next
		_StzVisionDoor("find", $cStzVisionOwlVision, "" + len(_aOut_) + " box(es) for " + _n_ + " word(s)")
		return _aOut_

	def ObjectsXT(pnMinScore)
		return This._Objects(pnMinScore, 0)

	# Returns the objects found in the whole image and in four overlapping tiles, merged, at five runs' cost.
	#
	# Small people in a wide street come back: 2 found whole on Times Square, 9 with the tiles.
	#
	#   returns    a list shaped as Objects() returns it
	#   see        Objects, ObjectsXT
	def ObjectsTiled()
		return This._Objects(0.3, 2)

	def _Objects(pnMinScore, pnTiles)
		_cP_ = _StzVisionModelOrRaise($cStzVisionObjectModel, "Objects")
		_a_ = StzEngineNeuralVisionObjects(_cP_, This.Pixels(), This.Width(), This.Height(),
			This.Channels(), pnMinScore, 0.45, 4, pnTiles)
		_aOut_ = []
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_r_ = _a_[_i_]
			_aOut_ + [ :label = _r_[1], :score = _r_[2], :box = [ _r_[3] + 1, _r_[4] + 1, _r_[5], _r_[6] ] ]
		next
		_StzVisionDoor("objects", $cStzVisionObjectModel, "" + len(_aOut_) + " object(s)")
		return _aOut_

	#@ aka  -- 10a2. THE CODES IN A PICTURE (IM9c) ------------------------------------

	# Returns every code the picture holds: [ :kind, :text, :points ] each ([] when there is none).
	#
	#   :kind     "qr", "ean13", "ean8", "upca" or "code128"
	#   :text     the payload: for a QR the bytes of its data (UTF-8 text comes back as it was written); for an EAN-13, EAN-8
	#             or UPC-A the digits printed under the bars, check digit included (an EAN-13 that begins with 0 is a UPC-A and
	#             says so, with its 12 digits); for a Code 128 its data, without the start symbol, the check symbol and the stop
	#   :points   a QR's four corners from the top left, clockwise; a 1D code's two ends of the line it was read along
	#             -- each [ x, y ], 1-based like every Ring face
	#   note      a read is a statement: a QR is accepted only when its Reed-Solomon codes decode, a 1D code only when its own
	#             check digit agrees. A picture with no code answers [], and so does a code too damaged to be read.
	def Codes()
		_a_ = StzEngineImageCodes(@nId)
		_aOut_ = []
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_r_ = _a_[_i_]
			_aP_ = []
			_m_ = len(_r_[3])
			for _k_ = 1 to _m_ step 2
				_aP_ + [ _r_[3][_k_] + 1, _r_[3][_k_ + 1] + 1 ]
			next
			_aOut_ + [ :kind = _r_[1], :text = _r_[2], :points = _aP_ ]
		next
		return _aOut_

	#@ aka  -- 10a3. QUALITY (IM9d) --------------------------------------------------------

	# Returns the variance of the Laplacian of the gray picture, at its own size: OpenCV's cv2.Laplacian(gray, CV_64F, ksize=1).var().
	# High where the edges are sharp, low where they are blurred or there are none; -1 for no pixels.
	def LaplacianVariance()
		return StzEngineImageLaplacianVar(@nId)

	# Returns the sharpness figure of the picture shrunk so that its long side is the given length, never enlarged.
	#
	# The picture is shrunk by area, on its gray, so two pictures of different sizes then compare.
	#
	#   pnLongSide   the length of the long side after the shrink; 0 means the picture's own size
	#   returns      a number, the variance of the Laplacian of the gray
	#   see          Sharpness, RelativeSharpness
	def SharpnessAt(pnLongSide)
		_nW_ = This.Width()
		_nH_ = This.Height()
		_nL_ = _nW_
		if _nH_ > _nL_ _nL_ = _nH_ ok
		if pnLongSide <= 0 or _nL_ <= pnLongSide
			return This.LaplacianVariance()
		ok
		_nS_ = pnLongSide / _nL_
		_nW2_ = floor(_nW_ * _nS_ + 0.5)
		_nH2_ = floor(_nH_ * _nS_ + 0.5)
		if _nW2_ < 1 _nW2_ = 1 ok
		if _nH2_ < 1 _nH2_ = 1 ok
		# the gray FIRST, then the shrink: shrinking the colour and then taking its gray rounds differently (and costs three channels)
		_oG_ = This.Grayscaled()
		_oS_ = _oG_.ResizedXT(_nW2_, _nH2_, :area)
		_oG_.Release()
		_nV_ = _oS_.LaplacianVariance()
		_oS_.Release()
		return _nV_

	# Returns the sharpness the verdicts use: SharpnessAt(512).
	def Sharpness()
		return This.SharpnessAt(512)

	# Returns the sharpness relative to the picture's own contrast: Sharpness() / the variance of its gray (at least 1). A picture made
	# darker or brighter by a gain keeps its value (the Laplacian's variance and the gray's scale by the same square), a blurred one
	# loses it; this is the figure IsBlurry judges.
	def RelativeSharpness()
		_aE_ = This.ExposureStats()
		_nV_ = _aE_[:std] * _aE_[:std]
		if _nV_ < 1 _nV_ = 1 ok
		return This.Sharpness() / _nV_

	# Returns how the picture is exposed, from the histogram of its gray, as [ :mean, :std, :p1, :p99, :dark, :light ].
	#
	# The mean and standard deviation of the gray level, its 1st and 99th percentile level, and the FRACTION of
	# pixels at 5 or below (crushed shadows) and at 250 or above (blown highlights).
	#
	#   returns    a hash list with those six keys; every value is 0 when the histogram holds no pixels
	#   see        Quality, IsUnderexposed, IsOverexposed
	def ExposureStats()
		_oH_ = This.Histogram()
		_aH_ = _oH_.ToList(1)
		_oH_.Release()
		_nN_ = 0
		_nSum_ = 0
		_nSq_ = 0
		_nDark_ = 0
		_nLight_ = 0
		for _i_ = 1 to 256
			_nC_ = _aH_[_i_]
			_nN_ += _nC_
			_nSum_ += (_i_ - 1) * _nC_
			_nSq_ += (_i_ - 1) * (_i_ - 1) * _nC_
			if _i_ - 1 <= 5 _nDark_ += _nC_ ok
			if _i_ - 1 >= 250 _nLight_ += _nC_ ok
		next
		if _nN_ = 0
			return [ :mean = 0, :std = 0, :p1 = 0, :p99 = 0, :dark = 0, :light = 0 ]
		ok
		_nMean_ = _nSum_ / _nN_
		_nVar_ = _nSq_ / _nN_ - _nMean_ * _nMean_
		if _nVar_ < 0 _nVar_ = 0 ok
		# a percentile of a histogram: the first gray level whose cumulative share reaches the fraction
		_nP1_ = -1
		_nP99_ = -1
		_nCum_ = 0
		for _i_ = 1 to 256
			_nCum_ += _aH_[_i_]
			if _nP1_ < 0 and _nCum_ >= 0.01 * _nN_ _nP1_ = _i_ - 1 ok
			if _nP99_ < 0 and _nCum_ >= 0.99 * _nN_ _nP99_ = _i_ - 1 ok
		next
		return [ :mean = _nMean_, :std = sqrt(_nVar_), :p1 = _nP1_, :p99 = _nP99_, :dark = _nDark_ / _nN_, :light = _nLight_ / _nN_ ]

	# Returns the 64-bit perceptual hash of the picture as 16 hex digits (imagehash's phash by definition; see engine/src/image_quality.zig).
	def PerceptualHash()
		return StzEngineImagePHash(@nId)

	# TRUE if the picture is blurred: its RelativeSharpness is below $nStzBlurBelow.
	#
	# It finds DEFOCUS blur; a blur in one direction (motion) leaves detail across it, which an isotropic
	# measure sees, so it is found less often.
	#
	#   returns    1 or 0
	#   see        RelativeSharpness, Quality
	def IsBlurry()
		return This.RelativeSharpness() < $nStzBlurBelow

	# TRUE if even the bright end of the picture is dark: its 99th percentile gray level is below $nStzUnderP99.
	#
	#   returns    1 or 0
	#   see        ExposureStats, IsOverexposed
	def IsUnderexposed()
		_aE_ = This.ExposureStats()
		return _aE_[:p99] < $nStzUnderP99

	# TRUE if much of the picture is blown out: at least $nStzOverLight of its pixels are at 250 or above.
	#
	#   returns    1 or 0
	#   see        ExposureStats, IsUnderexposed
	def IsOverexposed()
		_aE_ = This.ExposureStats()
		return _aE_[:light] >= $nStzOverLight

	# Returns what the three verdicts rest on and what they say, the numbers first.
	#
	# A caller with other thresholds can then judge for itself.
	#
	#   returns    [ :sharpness, :relativeSharpness, :exposure, :isBlurry, :isUnderexposed, :isOverexposed ]; :exposure
	#              is the list ExposureStats returns
	#   see        ExposureStats, IsBlurry, IsUnderexposed, IsOverexposed
	def Quality()
		_aE_ = This.ExposureStats()
		_nSh_ = This.Sharpness()
		_nV_ = _aE_[:std] * _aE_[:std]
		if _nV_ < 1 _nV_ = 1 ok
		_nRs_ = _nSh_ / _nV_
		return [ :sharpness = _nSh_, :relativeSharpness = _nRs_, :exposure = _aE_, :isBlurry = (_nRs_ < $nStzBlurBelow),
			 :isUnderexposed = (_aE_[:p99] < $nStzUnderP99), :isOverexposed = (_aE_[:light] >= $nStzOverLight) ]

	# Returns in how many of 64 bits the two pictures' perceptual hashes differ (0 = the same hash; about 32 = unrelated).
	def HashDistanceTo(poOther)
		return StzHashDistance(This.PerceptualHash(), poOther.PerceptualHash())

	# TRUE if the other picture is a near-duplicate of this one by its hash: at most $nStzNearDupBits bits apart.
	#
	# A copy of a photograph that was resized, re-encoded, brightened or slightly cropped is; a different
	# photograph is not (see IM9d for how often this is right).
	#
	#   poOther    the stzImage to compare with
	#   returns    1 or 0
	#   see        HashDistanceTo, SimilarityToImage
	def IsNearDuplicateOf(poOther)
		return This.HashDistanceTo(poOther) <= $nStzNearDupBits

	# Returns the cosine of the two pictures' SigLIP2 embeddings: 1 for the same content, near 0 for unrelated ones.
	#
	# It is the meaning-level measure (the model of IM5), where HashDistanceTo is the pixel-level one.
	#
	#   poOther    the stzImage to compare with
	#   returns    a number
	#   see        HashDistanceTo, Embedding
	def SimilarityToImage(poOther)
		_aA_ = This.Embedding()
		_aB_ = poOther.Embedding()
		_nDot_ = 0
		_nN_ = len(_aA_)
		for _i_ = 1 to _nN_
			_nDot_ += _aA_[_i_] * _aB_[_i_]
		next
		return _nDot_

	#@ aka  -- 10b. PICTURES AND WORDS IN ONE SPACE (IM5: SigLIP2, see stzImageSearch.ring) --

	# Returns the picture's 768 numbers in the space it shares with texts, L2-normalized.
	#
	#   note       SigLIP2's image tower; the picture is resized to 224 x 224 as PIL resizes it
	def Embedding()
		_cP_ = _StzVisionModelOrRaise($cStzVisionImageEmbedder, "Embedding")
		_a_ = StzEngineNeuralVisionEmbedImage(_cP_, This.Pixels(), This.Width(), This.Height(),
			This.Channels(), 4)
		if len(_a_) = 0
			_StzVisionFailed("Embedding", $cStzVisionImageEmbedder)
		ok
		_StzVisionDoor("embed-image", $cStzVisionImageEmbedder, "" + len(_a_) + " numbers")
		return _a_

	# Returns the caller's labels ranked for this picture: [ :label, :score ] each, best first.
	#
	#   paLabels   any words: [ "a dog", "a cat" ], [ "sunny", "rainy" ], [ "un chien", "un chat" ]
	#   note       zero-shot -- no class list is fixed in advance; each label is put into
	#              "This is a photo of {}." and the score is a cosine, not a probability
	def ClassifyAs(paLabels)
		return _StzVisionRankLabels(This.Embedding(), paLabels, $cStzVisionLabelPrompt)

	# ClassifyAs with the caller's own prompt, where {} stands for the label ("{}" alone: the label as is).
	def ClassifyAsXT(paLabels, pcPrompt)
		return _StzVisionRankLabels(This.Embedding(), paLabels, pcPrompt)

	# Returns how well a text describes the picture: the cosine of their embeddings.
	def SimilarityTo(pcText)
		return StzVisionCosine(This.Embedding(), StzVisionTextEmbedding(pcText))

	#@ aka  -- 10c. WHAT STANDS OUT (IM6: U2-Net-p, see stzVision.ring) ----------------

	# Returns the picture's salient object as a one-channel mask (data): near 255 on the object, near 0 on
	# the background, soft at the edges.
	#
	#   note       U2-Net-p computed as rembg computes it; ForegroundMask() is the classical answer
	#              (what is not the border-coloured background), this one is learned
	def SalientMask()
		_cP_ = _StzVisionModelOrRaise($cStzVisionSaliencyModel, "SalientMask")
		_c_ = StzEngineNeuralVisionSaliency(_cP_, This.Pixels(), This.Width(), This.Height(), This.Channels(), 4)
		if len(_c_) = 0
			_StzVisionFailed("SalientMask", $cStzVisionSaliencyModel)
		ok
		_StzVisionDoor("saliency", $cStzVisionSaliencyModel, "a " + This.Width() + " x " + This.Height() + " mask")
		return StzImageFromPixels(This.Width(), This.Height(), 1, _c_)

	# Changes the image into an RGBA cut-out: the salient object kept, the background made transparent.
	def ApplyBackgroundRemoval()
		_oM_ = This.SalientMask()
		This._Take(StzEngineImageWithMask(@nId, _oM_.Handle()))
		_oM_.Release()

		def ApplyBackgroundRemovalQ()
			This.ApplyBackgroundRemoval()
			return This

	# Returns an RGBA copy with the background made transparent; the image is not changed.
	def BackgroundRemoved()
		_oM_ = This.SalientMask()
		_oR_ = This._New(StzEngineImageWithMask(@nId, _oM_.Handle()))
		_oM_.Release()
		return _oR_

	# Returns how near each pixel is, as a grid of numbers (data): relative inverse depth, larger is nearer.
	#
	# The numbers have no unit; the grid has Height() rows of Width() columns.
	#
	#   returns    a stzImageGrid
	#   note       Depth-Anything-V2-Small (models/vision); ToImageScaled() on the grid shows it, near
	#              white and far black. A relative map ranks distances, it does not measure them
	def DepthMap()
		_cP_ = _StzVisionModelOrRaise($cStzVisionDepthModel, "DepthMap")
		_c_ = StzEngineNeuralVisionDepth(_cP_, This.Pixels(), This.Width(), This.Height(), This.Channels(), 4)
		if len(_c_) = 0
			_StzVisionFailed("DepthMap", $cStzVisionDepthModel)
		ok
		_StzVisionDoor("depth", $cStzVisionDepthModel, "a " + This.Width() + " x " + This.Height() + " map")
		_nG_ = StzEngineImageGridFromF32(This.Height(), This.Width(), _c_)
		if _nG_ = 0
			stzraise("stzImage.DepthMap: the depth map could not be held as a grid")
		ok
		return new stzImageGrid(_nG_, "y", "x")

	#@ aka  -- 10d. THE OBJECT AT A POINT (IM6: MobileSAM, see stzVision.ring) ---------

	# Returns the mask (data) of the object under a point [ x, y ], 1-based: 255 on the object, 0 elsewhere.
	#
	#   note       MobileSAM: the picture is encoded once (about 1.5 s) and kept in the engine, so every
	#              further point or box on the same pixels costs one decode (about 0.07 s)
	def MaskAt(paPoint)
		return This.MaskAtXT(paPoint)[:mask]

	# Returns [ :mask = the mask (a stzImage), :score = the model's own estimate of the mask's IoU ].
	def MaskAtXT(paPoint)
		This._MustHold(paPoint[1], paPoint[2], "MaskAt")
		return This._SamMask("MaskAt", paPoint[1] - 1, paPoint[2] - 1, 0, 0, 1, -1)

	# Returns the mask (data) of the object inside a box [ x, y, w, h ], 1-based.
	def MaskInBox(paBox)
		return This.MaskInBoxXT(paBox)[:mask]

	# Returns [ :mask, :score ] for a box, as MaskAtXT does for a point.
	def MaskInBoxXT(paBox)
		This._MustHold(paBox[1], paBox[2], "MaskInBox")
		return This._SamMask("MaskInBox", paBox[1] - 1, paBox[2] - 1, paBox[1] - 1 + paBox[3], paBox[2] - 1 + paBox[4], 2, 3)

	# Returns an RGBA copy keeping only the object under a point [ x, y ]; the image is not changed.
	def CutOutAt(paPoint)
		_oM_ = This.MaskAt(paPoint)
		_oR_ = This._New(StzEngineImageWithMask(@nId, _oM_.Handle()))
		_oM_.Release()
		return _oR_

	# Changes the image into an RGBA cut-out of the object under a point [ x, y ].
	def ApplyCutOutAt(paPoint)
		_oM_ = This.MaskAt(paPoint)
		This._Take(StzEngineImageWithMask(@nId, _oM_.Handle()))
		_oM_.Release()

		def ApplyCutOutAtQ(paPoint)
			This.ApplyCutOutAt(paPoint)
			return This

	def _MustHold(pnX, pnY, pcFaculty)
		if NOT (isNumber(pnX) and isNumber(pnY) and pnX >= 1 and pnY >= 1 and pnX <= This.Width() and pnY <= This.Height())
			stzraise("stzImage." + pcFaculty + ": the point must be [ x, y ] inside the " + This.Width() + " x " +
				This.Height() + " picture, 1-based.")
		ok

	def _SamMask(pcFaculty, pnX0, pnY0, pnX1, pnY1, pnL0, pnL1)
		_nId_ = _StzVisionSamEmbedding(This, pcFaculty)
		_cD_ = _StzVisionModelOrRaise($cStzVisionSamDecoder, pcFaculty)
		_c_ = StzEngineNeuralVisionSamMask(_cD_, _nId_, pnX0, pnY0, pnX1, pnY1, pnL0, pnL1, 4)
		if len(_c_) = 0
			_StzVisionFailed(pcFaculty, $cStzVisionSamDecoder)
		ok
		_a_ = StzEngineNeuralVisionSamLast()
		_StzVisionDoor("object-at", $cStzVisionSamDecoder, "a " + This.Width() + " x " + This.Height() + " mask")
		return [ :mask = StzImageFromPixels(This.Width(), This.Height(), 1, _c_), :score = _a_[1] ]

	# Changes the image into an RGBA copy whose alpha is a mask's gray (a stzImage of the same size).
	def ApplyMask(poMask)
		This._Take(StzEngineImageWithMask(@nId, poMask.Handle()))

		def ApplyMaskQ(poMask)
			This.ApplyMask(poMask)
			return This

	#@ aka  -- 10e. THE PICTURE IN WORDS (IM7: SmolVLM, see stzVision.ring) ------------

	# Returns what the picture shows, in a few sentences of English.
	#
	#   note       SmolVLM-256M-Instruct: its SigLIP tower reads the picture at 512 x 512 (squeezed to that
	#              square, as its own processor does without tiling) and its decoder writes, greedily, so the
	#              same picture gets the same words. About 2 seconds for the picture and 1 for the words. The
	#              decoder takes the engine's model slot. Every call is recorded in the security ledger
	#   example    ? StzImageQ("cat.jpg").Describe()
	#              #--> The image depicts a close-up view of a cat sitting on a surface, ...
	def Describe()
		return This.DescribeXT("Describe this image.", 96)

	# Returns the model's answer to a request about the picture, at most pnMaxTokens long; an answer cut
	# by that cap ends at its last whole sentence.
	def DescribeXT(pcRequest, pnMaxTokens)
		return _StzVisionVlmSay(This, "" + pcRequest, pnMaxTokens, "describe")

	# Returns a short answer to a question about the picture ("How many dogs are there?").
	def Ask(pcQuestion)
		return _StzVisionVlmSay(This, "" + pcQuestion + " Answer briefly.", 32, "describe")

	#@ aka  -- 10f. A PAGE AS STRUCTURE (IM7: Granite-Docling, see stzVision.ring and stzDocTags.ring) ----

	# Returns what Granite-Docling writes about the picture taken as a document page, as DocTags.
	#
	# DocTags is the page's structure as tags (<section_header_level_1>, <text>, <otsl> ...) with the words between them.
	#
	#   returns    a text of tags
	#   note       the page is resized to 2048 on its long side and cut into 512 x 512 tiles, with one more view
	#              of the whole page; each view is 64 rows for the decoder, which writes greedily, so the same
	#              page gets the same tags. An English model. The views go through the vision tower on the GPU
	#              (engine/src/neural_vit.zig, IM8a: about 0.5 s a view on a free GPU, 2.6 to 3.5 times the CPU
	#              graph and closer to the reference; StzEngineNeuralVisionGpu(0) puts the CPU graph back) and
	#              the words cost 17 to 65 ms a token, more the longer the page's prompt: 30 to 60 seconds for a
	#              page of a few paragraphs and a table. The decoder takes the engine's model slot. Every
	#              call is recorded in the security ledger
	#   example    ? StzImageQ("page.png").DocTags()
	#              #--> <doctag><section_header_level_1><loc_47><loc_36><loc_402><loc_49>Results</section_header_level_1> ...
	def DocTags()
		return _StzVisionDocSay(This, $nStzVisionDocMaxTokens)

	# Returns the page's blocks, in reading order, in the shape StzPdf.Blocks() returns them.
	#
	#   returns    a list of [ :kind, :level, :text, :rows ]; a kind is heading, paragraph, list_item, code,
	#              caption, table (its cells in :rows), page_header or page_footer
	def DocBlocks()
		return StzDocTagsBlocks(This.DocTags())
	#@ aka  -- 11. DRAWING ON THE PICTURE (IM3) -----------------------------------------

	# Changes the image by drawing a rectangle's outline: [ x, y, w, h ] 1-based, a colour, a thickness.
	#
	#   pColor     [ r, g, b ], "#rrggbb" or a name (red, green, blue, yellow, orange, ...)
	def ApplyBox(paBox, pColor, pnThickness)
		_c_ = StzVisionColor(pColor)
		_StzImageMust(StzEngineImageBox(@nId, floor(paBox[1] - 1 + 0.5), floor(paBox[2] - 1 + 0.5),
			floor(paBox[3] + 0.5), floor(paBox[4] + 0.5), _c_[1], _c_[2], _c_[3], pnThickness))

		def ApplyBoxQ(paBox, pColor, pnThickness)
			This.ApplyBox(paBox, pColor, pnThickness)
			return This

	# Changes the image by drawing a filled dot at [ x, y ] (1-based) of a radius.
	def ApplyDot(paPoint, pnRadius, pColor)
		_c_ = StzVisionColor(pColor)
		_StzImageMust(StzEngineImageDot(@nId, paPoint[1] - 1, paPoint[2] - 1, pnRadius, _c_[1], _c_[2], _c_[3]))

		def ApplyDotQ(paPoint, pnRadius, pColor)
			This.ApplyDot(paPoint, pnRadius, pColor)
			return This

	# Changes the image by drawing every box of a list of findings (Faces, Objects), with landmarks as dots.
	def ApplyFindings(paFound, pColor)
		_n_ = len(paFound)
		_nT_ = 2
		if This.Width() > 900
			_nT_ = 3
		ok
		for _i_ = 1 to _n_
			This.ApplyBox(paFound[_i_][:box], pColor, _nT_)
			if HasKey(paFound[_i_], :landmarks)
				_aL_ = paFound[_i_][:landmarks]
				_m_ = len(_aL_)
				for _k_ = 1 to _m_
					This.ApplyDot(_aL_[_k_], _nT_ + 1, :cyan)
				next
			ok
		next

		def ApplyFindingsQ(paFound, pColor)
			This.ApplyFindings(paFound, pColor)
			return This

	#@ aka  -- internals --------------------------------------------------------------

	def _Take(pnNew)
		_StzImageMust(pnNew)
		_StzImageMust(StzEngineImageTake(@nId, pnNew))

	def _New(pnNew)
		return new stzImage(_StzImageMust(pnNew))
