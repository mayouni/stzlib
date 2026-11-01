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

	THE THREE FORMS, as everywhere in Softanza:
		oImg.Blur(2)          changes the image
		oImg.Blurred(2)       returns a new stzImage, the original untouched
		oImg.BlurQ(2)         changes it and returns it, to chain

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

func StzImageQ(pImage)
	return new stzImage(pImage)

# A blank image of a size, with 1 (gray), 3 (RGB) or 4 (RGBA) channels, every byte set to pnFill.
func StzImageNew(pnWidth, pnHeight, pnChannels, pnFill)
	return new stzImage(_StzImageMust(StzEngineImageNew(pnWidth, pnHeight, pnChannels, pnFill)))

# An image from raw bytes: rows top-down, pnChannels bytes per pixel, no padding.
func StzImageFromPixels(pnWidth, pnHeight, pnChannels, pcBytes)
	return new stzImage(_StzImageMust(StzEngineImageFromRaw(pnWidth, pnHeight, pnChannels, pcBytes)))

# An image decoded from the bytes of a PNG, JPEG, BMP, GIF, TGA or PSD file.
func StzImageFromBytes(pcBytes)
	return new stzImage(_StzImageMust(StzEngineImageDecode(pcBytes)))

# How many images the engine holds; a guard reads it to prove nothing leaked.
func StzImagesAlive()
	return StzEngineImageLive()

func _StzImageMust(pnId)
	if pnId = 0
		stzraise("stzImage: " + StzEngineImageLastError())
	ok
	return pnId

# Holds an image -- pixels in the engine, 1, 3 or 4 channels of 0..255 -- and its classical operations.
#
# Build one from a file path, from a file's bytes (StzImageFromBytes), from raw pixels
# (StzImageFromPixels) or blank (StzImageNew). Each operation has three forms: Grayscale changes the
# image, Grayscaled returns a new one, GrayscaleQ changes it and returns it. Every copy of the object
# reaches the same pixels, and a change made through one is seen by all. An analysis returns a
# stzImageGrid of numbers, never a picture. Release frees the pixels.
#
#   receiver   o1 = StzImageFromPixels(2, 1, 3, char(255) + char(0) + char(0) + char(0) + char(0) + char(255))
#   example    ? @@( o1.Size() )
#              #--> [ 2, 1 ]
#              ? @@( o1.Pixel(1, 1) )
#              #--> [ 255, 0, 0 ]
#              o1.Grayscale()
#              ? @@( o1.Pixel(1, 1) )
#              #--> [ 76 ]
#              o1.Release()
#   see        stzImageGrid, stzCanvas
class stzImage from stzObject

	@nId = 0

	# Builds the image from a file path, or adopts an engine handle (a number).
	#
	#   pImage     a path to a PNG, JPEG, BMP, GIF, TGA or PSD file, or an engine image handle
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

	# TRUE when the object holds no live pixels.
	def IsEmpty()
		return StzEngineImageWidth(@nId) = 0

	#@ aka  -- 1. WHAT IT IS --------------------------------------------------------

	def Width()
		return StzEngineImageWidth(@nId)

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
	#   warning    another extension raises an error; JPEG writing arrives with IM1
	def SaveAs(pcPath)
		_c_ = StzLower("" + pcPath)
		if StzRight(_c_, 4) = ".png"
			_StzImageMust(StzEngineImageSavePng(@nId, pcPath))
		but StzRight(_c_, 4) = ".bmp"
			_StzImageMust(StzEngineImageSaveBmp(@nId, pcPath))
		else
			stzraise("stzImage.SaveAs: the formats written are .png and .bmp " +
				"(JPEG arrives with IM1) -- not '" + pcPath + "'.")
		ok
		return This

	# Returns the bytes of the image encoded as PNG.
	def ToPNG()
		return StzEngineImageToPng(@nId)

	#@ aka  -- 3. CHANNELS ----------------------------------------------------------

	def Grayscale()
		This._Take(StzEngineImageConvert(@nId, 1))

		def GrayscaleQ()
			This.Grayscale()
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

	def Invert()
		This._Take(StzEngineImageInvert(@nId))

		def InvertQ()
			This.Invert()
			return This

	# Returns a copy with the colour channels inverted; alpha is kept.
	def Inverted()
		return This._New(StzEngineImageInvert(@nId))

	#@ aka  -- 4. GEOMETRY ----------------------------------------------------------

	def Crop(pnX, pnY, pnWidth, pnHeight)
		This._Take(StzEngineImageCrop(@nId, pnX, pnY, pnWidth, pnHeight))

		def CropQ(pnX, pnY, pnWidth, pnHeight)
			This.Crop(pnX, pnY, pnWidth, pnHeight)
			return This

	# Returns the rectangle whose top-left pixel is (pnX, pnY), 1-based.
	#
	#   warning    a rectangle that leaves the image raises an error
	def Cropped(pnX, pnY, pnWidth, pnHeight)
		return This._New(StzEngineImageCrop(@nId, pnX, pnY, pnWidth, pnHeight))

	def Flip(pcWay)
		This._Take(StzEngineImageFlip(@nId, This._Horizontal(pcWay)))

		def FlipQ(pcWay)
			This.Flip(pcWay)
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

	def Rotate(pnDegrees)
		This._Take(StzEngineImageRotate(@nId, This._Quarters(pnDegrees)))

		def RotateQ(pnDegrees)
			This.Rotate(pnDegrees)
			return This

	# Returns a copy turned clockwise by a multiple of 90 degrees.
	#
	#   warning    an angle that is not a multiple of 90 raises an error; free angles arrive with
	#              IM2's warps
	def Rotated(pnDegrees)
		return This._New(StzEngineImageRotate(@nId, This._Quarters(pnDegrees)))

	def _Quarters(pnDegrees)
		if NOT isNumber(pnDegrees) or pnDegrees % 90 != 0
			stzraise("stzImage.Rotate: a quarter-turn rotation takes a multiple of 90 " +
				"degrees; free angles arrive with the warps (IM2).")
		ok
		return pnDegrees / 90

	def Resize(pnWidth, pnHeight)
		This._Take(StzEngineImageResize(@nId, pnWidth, pnHeight, 1))

		def ResizeQ(pnWidth, pnHeight)
			This.Resize(pnWidth, pnHeight)
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

	def Blur(pnSigma)
		This._Take(StzEngineImageBlur(@nId, pnSigma))

		def BlurQ(pnSigma)
			This.Blur(pnSigma)
			return This

	# Returns a Gaussian-blurred copy (OpenCV's 8-bit kernel, borders reflected).
	#
	#   warning    a sigma outside 0 < sigma <= 100 raises an error
	def Blurred(pnSigma)
		return This._New(StzEngineImageBlur(@nId, pnSigma))

	# Returns Otsu's threshold of the gray levels: where two classes separate best.
	def OtsuThreshold()
		return StzEngineImageOtsu(@nId)

	def Threshold(pThreshold)
		This._Take(StzEngineImageThreshold(@nId, This._Level(pThreshold)))

		def ThresholdQ(pThreshold)
			This.Threshold(pThreshold)
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

	#@ aka  -- internals --------------------------------------------------------------

	def _Take(pnNew)
		_StzImageMust(pnNew)
		_StzImageMust(StzEngineImageTake(@nId, pnNew))

	def _New(pnNew)
		return new stzImage(_StzImageMust(pnNew))
