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

	#@ aka  -- 7. MORPHOLOGY AND SMOOTHING (IM1) --------------------------------------

	# Returns a copy after a morphological operation, as OpenCV's morphologyEx.
	#
	#   pcOp       :erode, :dilate, :open, :close, :gradient, :tophat or :blackhat
	#   pnSize     the kernel's side, odd, 1..255
	#   pcShape    :rect, :cross or :ellipse
	#   note       pixels outside the image are ignored, as OpenCV's default border does
	def Morphed(pcOp, pnSize, pcShape)
		return This._New(This._Morph(pcOp, pnSize, pcShape))

	def Morph(pcOp, pnSize, pcShape)
		This._Take(This._Morph(pcOp, pnSize, pcShape))

		def MorphQ(pcOp, pnSize, pcShape)
			This.Morph(pcOp, pnSize, pcShape)
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

	def MedianFilter(pnSize)
		This._Take(StzEngineImageMedian(@nId, pnSize))

		def MedianFilterQ(pnSize)
			This.MedianFilter(pnSize)
			return This

	# Returns a copy where each pixel is the median of its window: removes salt-and-pepper noise, keeps edges.
	def MedianFiltered(pnSize)
		return This._New(StzEngineImageMedian(@nId, pnSize))

	def Equalize()
		This._Take(StzEngineImageEqualize(@nId))

		def EqualizeQ()
			This.Equalize()
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

	#@ aka  -- internals --------------------------------------------------------------

	def _Take(pnNew)
		_StzImageMust(pnNew)
		_StzImageMust(StzEngineImageTake(@nId, pnNew))

	def _New(pnNew)
		return new stzImage(_StzImageMust(pnNew))
