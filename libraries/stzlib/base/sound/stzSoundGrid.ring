#---------------------------------------------------------------------------#
#  STZSOUNDGRID -- what an analysis RETURNS: numbers, with axes that mean    #
#  something. Never a picture.                                              #
#---------------------------------------------------------------------------#
#
#     oSpec = oSound.ToSpectrum()
#     ? oSpec.Columns() + " bins, " + oSpec.HertzPerColumn() + " Hz apart"
#     ? "loudest at " + oSpec.PeakFrequencyOfRow(1) + " Hz"
#
#     oSg = oSound.ToSpectrogram()
#     ? oSg.Rows() + " windows x " + oSg.Columns() + " bins"
#     oSg.ToCanvas(900, 300).ToSVG()          # the graphics plane draws it
#     oSg.ToPNG("spectrogram.png", 900, 300)
#
# WHY THIS CLASS EXISTS AT ALL, rather than the analysis returning a picture:
# the plan says the analysis output is a DATA MODEL, and that is what makes it
# assertable. "The 1 kHz sine is in the 1 kHz bin" is a claim about numbers a
# guard can check. "The spectrogram looks right" is a claim about nothing.
#
# ONE SHAPE FOR EVERY ANALYSIS. A spectrum is 1 row. A spectrogram is many.
# Onset times are one row of seconds. Same handle, same lifetime, same table --
# so there is one thing to learn and one thing to free.
#
# THE AXES CARRY THEIR MEANING. SecondsPerRow() and HertzPerColumn() come from
# the analysis that produced the grid, so a caller labels an axis without
# recomputing what was already known. For an onset list both are 0: its
# numbers ARE seconds, so there is nothing to scale.
#
# ROWS AND COLUMNS ARE 1-BASED, like every Ring face.

func StzSoundGridQ(pnGridId)
	return new stzSoundGrid(pnGridId)

class stzSoundGrid

	@nGrid = 0

	def init(pnGridId)
		@nGrid = pnGridId

	def GridId()
		return @nGrid

	def Release()
		if @nGrid != 0
			StzEngineSoundGridFree(@nGrid)
			@nGrid = 0
		ok

	def IsEmpty()
		return @nGrid = 0 or StzEngineSoundGridRows(@nGrid) <= 0

	#-- shape and meaning ---------------------------------------------------

	def Rows()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridRows(@nGrid)

	def Columns()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridCols(@nGrid)

	# What one row STEP means in time, for a spectrogram. 0 when a row is not
	# a moment (a spectrum, an onset list).
	def SecondsPerRow()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridXStep(@nGrid)

	# What one column means in frequency. 0 when a column is not a frequency.
	def HertzPerColumn()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridYStep(@nGrid)

	def At(pnRow, pnColumn)
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridAt(@nGrid, pnRow, pnColumn)

	def Max()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridMax(@nGrid)

	# Which column holds the largest value in a row -- "which frequency won".
	def PeakColumnOfRow(pnRow)
		if @nGrid = 0  return -1 ok
		return StzEngineSoundGridArgMaxInRow(@nGrid, pnRow)

	# The same answer in hertz, which is what you actually wanted.
	def PeakFrequencyOfRow(pnRow)
		_c_ = This.PeakColumnOfRow(pnRow)
		if _c_ < 1  return -1 ok
		return (_c_ - 1) * This.HertzPerColumn()

	# One row as a plain Ring list. DATA, so To... is right. It crosses the
	# FFI once per value, so it is for looking at a row, not at a whole
	# spectrogram -- ToCanvas does that without ever building a Ring list.
	def ToList(pnRow)
		_a_ = []
		if @nGrid = 0  return _a_ ok
		_n_ = This.Columns()
		for _i_ = 1 to _n_
			_a_ + StzEngineSoundGridAt(@nGrid, pnRow, _i_)
		next
		return _a_

	# The whole of a one-row grid -- an onset list is exactly this.
	def ToTimesList()
		return This.ToList(1)

	#-- THE GRAPHICS CONVERGENCE -------------------------------------------
	#
	# The sound plane hands a grid of numbers to the graphics plane, which
	# knows how to draw. Neither knows anything about the other's internals:
	# this method speaks only stzCanvas verbs, and stzCanvas has never heard
	# of audio.
	#
	# ONE RECTANGLE PER CELL, because that is what stzCanvas offers -- it has
	# AddRect, AddCircle, AddLine, AddText and no image primitive at all. A
	# full spectrogram would be tens of thousands of rectangles, so the grid
	# is DOWNSAMPLED to the pixel size asked for: each output cell takes the
	# LOUDEST value beneath it, which is the right summary for a spectrogram
	# (a peak that survives is a peak that was there; an average would hide
	# a brief bright partial).
	#
	# Recorded as an SN5 finding: an AddImage on stzCanvas would turn this
	# from thousands of rectangles into one call, and the graphics plane is
	# where that belongs.

	def ToCanvas(pnWidth, pnHeight)
		return This.ToCanvasOf(pnWidth, pnHeight, 120)

	# pnMaxBins caps how much of the spectrum is drawn: nearly all musical
	# energy lives in the bottom fraction of the range, and drawing 2048 bins
	# up to Nyquist wastes most of the picture on silence.
	def ToCanvasOf(pnWidth, pnHeight, pnMaxBins)
		oC = new stzCanvas(pnWidth, pnHeight)
		oC.SetBackground("#0a0e14")
		if This.IsEmpty()  return oC ok

		_rows_ = This.Rows()
		_cols_ = This.Columns()
		if pnMaxBins > 0 and pnMaxBins < _cols_
			_cols_ = pnMaxBins
		ok
		_mx_ = This.Max()
		if _mx_ <= 0  return oC ok

		# how many cells fit, and how many grid values each one covers
		_cw_ = 3                                  # pixels per column of cells
		_ch_ = 3                                  # pixels per row of cells
		_nx_ = floor(pnWidth / _cw_)
		_ny_ = floor(pnHeight / _ch_)
		if _nx_ < 1  _nx_ = 1 ok
		if _ny_ < 1  _ny_ = 1 ok

		for _ix_ = 0 to _nx_ - 1
			_r0_ = floor(_ix_ * _rows_ / _nx_) + 1
			_r1_ = floor((_ix_ + 1) * _rows_ / _nx_)
			if _r1_ < _r0_  _r1_ = _r0_ ok
			for _iy_ = 0 to _ny_ - 1
				# low frequencies at the BOTTOM, as every spectrogram is drawn
				_c0_ = floor((_ny_ - 1 - _iy_) * _cols_ / _ny_) + 1
				_c1_ = floor((_ny_ - _iy_) * _cols_ / _ny_)
				if _c1_ < _c0_  _c1_ = _c0_ ok

				_peak_ = 0
				for _r_ = _r0_ to _r1_
					for _c_ = _c0_ to _c1_
						_v_ = StzEngineSoundGridAt(@nGrid, _r_, _c_)
						if _v_ > _peak_  _peak_ = _v_ ok
					next
				next
				if _peak_ <= 0  loop ok

				# decibels, not amplitude: hearing is logarithmic, and a linear
				# scale shows a bright line and an otherwise black picture
				_db_ = 20 * log10(_peak_ / _mx_)
				if _db_ < -60  loop ok
				_t_ = (_db_ + 60) / 60          # 0 at -60 dB, 1 at the peak
				oC.AddRect(_ix_ * _cw_, _iy_ * _ch_, _cw_, _ch_)
				oC.Fill(This._HeatColor(_t_))
			next
		next
		return oC

	def ToSVG(pnWidth, pnHeight)
		return This.ToCanvas(pnWidth, pnHeight).ToSVG()

	# Write the picture. SVG always works -- it needs no device at all, which
	# is what lets a CI machine draw a spectrogram.
	def ToSVGFile(pcPath, pnWidth, pnHeight)
		write(pcPath, This.ToCanvas(pnWidth, pnHeight).ToSVG())

	# PNG goes through the GPU tier, so it needs a device. SVG does not.
	def ToPNG(pcPath, pnWidth, pnHeight)
		This.ToCanvas(pnWidth, pnHeight).ToPNG(pcPath)

	#-- private -------------------------------------------------------------

	# dark blue -> cyan -> yellow -> white. A ramp that stays legible in
	# print and does not invent structure the way a rainbow does.
	def _HeatColor(pnT)
		_t_ = pnT
		if _t_ < 0  _t_ = 0 ok
		if _t_ > 1  _t_ = 1 ok
		_r_ = 0  _g_ = 0  _b_ = 0
		if _t_ < 0.4
			_u_ = _t_ / 0.4
			_r_ = floor(20 * _u_)
			_g_ = floor(60 + 140 * _u_)
			_b_ = floor(80 + 130 * _u_)
		but _t_ < 0.75
			_u_ = (_t_ - 0.4) / 0.35
			_r_ = floor(20 + 215 * _u_)
			_g_ = floor(200 + 40 * _u_)
			_b_ = floor(210 - 150 * _u_)
		else
			_u_ = (_t_ - 0.75) / 0.25
			_r_ = 235 + floor(20 * _u_)
			_g_ = 240 + floor(15 * _u_)
			_b_ = floor(60 + 195 * _u_)
		ok
		return "#" + This._Hex(_r_) + This._Hex(_g_) + This._Hex(_b_)

	def _Hex(pn)
		_n_ = pn
		if _n_ < 0  _n_ = 0 ok
		if _n_ > 255  _n_ = 255 ok
		_c_ = "0123456789abcdef"
		return substr(_c_, floor(_n_ / 16) + 1, 1) + substr(_c_, (_n_ % 16) + 1, 1)
