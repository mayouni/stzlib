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

# Holds what a sound analysis returns, a table of numbers whose axes mean seconds and hertz, never a picture.
#
# A spectrum is one row, a spectrogram has one row for each window and an onset list is one row of
# seconds, all the same handle and the same table, with 1-based rows and columns. The axes carry
# their meaning: SecondsPerRow and HertzPerColumn come from the analysis, and are 0 where a row is
# not a moment or a column not a frequency. Because the output is data it is assertable: a 1000
# hertz sine lies in the bin that contains 1000. ToCanvas hands the grid to the graphics plane as a
# heat map, low frequencies at the bottom, loudest value under each cell, decibels not amplitude;
# ToSVG needs no device and ToPNG uses the graphics device without a window. Release frees the grid.
# Sounds here are rendered to memory and not heard by a person (UNPERCEIVED).
#
#   receiver   oScore = StzSoundScoreQ() oScore.Note(1000, 1) oScore.Tempo(120) oSound =
#              oScore.ToSound() o1 = oSound.ToSpectrum()
#   example    ? o1.Rows()
#              #--> 1
#              ? o1.Columns()
#              #--> 2049
#              ? o1.HertzPerColumn()
#              #--> 11.72
#              ? o1.PeakColumnOfRow(1)
#              #--> 86
#              ? o1.PeakFrequencyOfRow(1)
#              #--> 996.09
#              ? o1.At(1, 86) = o1.Max()
#              #--> 1
#              oSg = oSound.ToSpectrogram()
#              ? oSg.Rows()
#              #--> 81
#              ? left(oSg.ToSVG(300, 120), 4)
#              #--> <svg
#              o1.Release()
#              ? o1.IsEmpty()
#              #--> 1
#   see        stzSound, stzCanvas, stzSoundGraph
class stzSoundGrid

	@nGrid = 0

	# Wraps the engine's table of analysis numbers, taking its handle.
	#
	#   pnGridId   the engine's number for the grid, as a sound's ToSpectrum, ToSpectrogram or
	#              ToOnsets makes it
	#   returns    nothing; the object is built
	#   note       you rarely build one yourself; a spectrum is one row, a spectrogram has a row for
	#              each window, and an onset list is one row of seconds
	#   see        Release, Rows
	def init(pnGridId)
		@nGrid = pnGridId

	# Returns the engine's number for the grid.
	#
	#   returns    a number above 0; 0 after Release
	#   see        Release, IsEmpty
	def GridId()
		return @nGrid

	# Frees the grid in the engine.
	#
	#   returns    nothing; every question answers its empty value afterwards
	#   note       releasing twice does nothing the second time; the sound's own buffer is not
	#              touched
	#   see        IsEmpty, GridId
	def Release()
		if @nGrid != 0
			StzEngineSoundGridFree(@nGrid)
			@nGrid = 0
		ok

	# TRUE if the grid holds no rows.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       it is TRUE after Release
	#   see        Rows, Release
	def IsEmpty()
		return @nGrid = 0 or StzEngineSoundGridRows(@nGrid) <= 0

	# Returns how many rows the grid has.
	#
	#   returns    a number; 0 after Release
	#   note       1 for a spectrum, one for each window for a spectrogram, and 1 for onsets; a 0.9
	#              second sound at 48000 hertz gave 81 windows of 2048 frames moving 512
	#   see        Columns
	#@ aka  -- shape and meaning ---------------------------------------------------
	def Rows()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridRows(@nGrid)

	# Returns how many columns the grid has.
	#
	#   returns    a number; 0 after Release
	#   note       2049 for a spectrum of 4096 frames, 1025 for a spectrogram, and one for each
	#              onset in an onset list
	#   see        Rows, HertzPerColumn
	def Columns()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridCols(@nGrid)

	# Returns what one row step means in time.
	#
	#   returns    a number of seconds; 0 when a row is not a moment
	#   note       512 over 48000, about 0.0107, for a default spectrogram; 0 for a spectrum and for
	#              onsets, whose numbers are already seconds
	#   see        HertzPerColumn, Rows
	#@ aka  What one row STEP means in time, for a spectrogram. 0 when a row is not a moment (a spectrum, an onset list).
	def SecondsPerRow()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridXStep(@nGrid)

	# Returns what one column means in frequency.
	#
	#   returns    a number of hertz; 0 when a column is not a frequency
	#   note       11.72 for a default spectrum and 23.44 for a default spectrogram at 48000 hertz;
	#              0 for onsets
	#   see        SecondsPerRow, PeakFrequencyOfRow
	#@ aka  What one column means in frequency. 0 when a column is not a frequency.
	def HertzPerColumn()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridYStep(@nGrid)

	# Returns the value in one cell.
	#
	#   pnRow      the row, counted from 1
	#   pnColumn   the column, counted from 1
	#   returns    a number, 0 for a cell outside the grid or after Release
	#   note       the values of a spectrum are magnitudes
	#   see        Max, ToList
	def At(pnRow, pnColumn)
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridAt(@nGrid, pnRow, pnColumn)

	# Returns the largest value in the whole grid.
	#
	#   returns    a number; 0 after Release
	#   see        At, PeakColumnOfRow
	def Max()
		if @nGrid = 0  return 0 ok
		return StzEngineSoundGridMax(@nGrid)

	# Returns which column holds the largest value of a row, which frequency won.
	#
	#   pnRow      the row, counted from 1
	#   returns    the column, counted from 1; -1 for a row outside the grid or after Release
	#   note       for a rendered 1000 hertz note it was column 86
	#   see        PeakFrequencyOfRow, At
	#@ aka  Which column holds the largest value in a row -- "which frequency won".
	def PeakColumnOfRow(pnRow)
		if @nGrid = 0  return -1 ok
		return StzEngineSoundGridArgMaxInRow(@nGrid, pnRow)

	# Returns the frequency of the strongest column of a row, in hertz.
	#
	#   pnRow      the row, counted from 1
	#   returns    a number of hertz, the start of the bin; -1 for a row outside the grid or after
	#              Release
	#   note       it is (column - 1) times HertzPerColumn, so a 1000 hertz note reads 996.09, the
	#              bin containing it, and in a spectrogram row 1007.81, since a bin is 23.44 wide
	#              and 1000 divided by it is 42.7
	#   see        PeakColumnOfRow, HertzPerColumn
	#@ aka  The same answer in hertz, which is what you actually wanted.
	def PeakFrequencyOfRow(pnRow)
		_c_ = This.PeakColumnOfRow(pnRow)
		if _c_ < 1  return -1 ok
		return (_c_ - 1) * This.HertzPerColumn()

	# Returns one row as a plain Ring list.
	#
	#   pnRow      the row, counted from 1
	#   returns    a list of numbers, one for each column; [ ] after Release
	#   note       it crosses into the engine once for each value, so use it to look at a row, not
	#              at a whole spectrogram
	#   see        ToTimesList, At
	#@ aka  One row as a plain Ring list. DATA, so To... is right. It crosses the FFI once per value, so it is for looking at a row, not at a whole spectrogram -- ToCanvas does that without ever building a Ring list.
	def ToList(pnRow)
		_a_ = []
		if @nGrid = 0  return _a_ ok
		_n_ = This.Columns()
		for _i_ = 1 to _n_
			_a_ + StzEngineSoundGridAt(@nGrid, pnRow, _i_)
		next
		return _a_

	# Returns the first row, which for an onset list is the list of times.
	#
	#   returns    a list of numbers, in seconds for an onset grid
	#   note       the onset times come from a detector with a window of 2048 frames and are not
	#              exact to the frame
	#   see        ToList
	#@ aka  The whole of a one-row grid -- an onset list is exactly this.
	def ToTimesList()
		return This.ToList(1)

	# Draws the grid as a heat map on a stzCanvas of a given size, with low frequencies at the bottom.
	#
	#   pnWidth    the width in pixels
	#   pnHeight   the height in pixels
	#   returns    a stzCanvas of rectangles, one for each cell of 3 by 3 pixels
	#   note       the grid is reduced to the cells that fit, each taking the loudest value beneath
	#              it; colour runs from dark blue through cyan and yellow to white over 60 decibels
	#              below the peak; only the first 120 columns are drawn; a canvas that is background
	#              alone for an empty or silent grid
	#   see        ToCanvasOf, ToSVG, ToPNG
	#@ aka  -- THE GRAPHICS CONVERGENCE -------------------------------------------
	def ToCanvas(pnWidth, pnHeight)
		return This.ToCanvasOf(pnWidth, pnHeight, 120)

	# Draws the grid as a heat map like ToCanvas, with a chosen number of frequency columns.
	#
	#   pnWidth     the width in pixels
	#   pnHeight    the height in pixels
	#   pnMaxBins   how many columns, from the lowest frequency up, to draw, or 0 for all
	#   returns     a stzCanvas of rectangles, one for each cell of 3 by 3 pixels
	#   note        most musical energy sits in the lowest fraction of the range, so the default of
	#               120 columns covers about 2.8 kilohertz at 48000 hertz
	#   see         ToCanvas, ToSVG
	#@ aka  pnMaxBins caps how much of the spectrum is drawn: nearly all musical energy lives in the bottom fraction of the range, and drawing 2048 bins up to Nyquist wastes most of the picture on silence.
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

	# Draws the heat map as SVG text; no graphics device is needed.
	#
	#   pnWidth    the width in pixels
	#   pnHeight   the height in pixels
	#   returns    the SVG text, starting with <svg
	#   note       the temporary canvas is freed
	#   see        ToSVGFile, ToPNG
	def ToSVG(pnWidth, pnHeight)
		_oCv_ = This.ToCanvas(pnWidth, pnHeight)
		_c_ = _oCv_.ToSVG()
		_oCv_.Free()   # the transient canvas's engine scene goes with it (2026-09-11)
		return _c_

	# Draws the heat map and writes it to an SVG file.
	#
	#   pcPath     the path of the file
	#   pnWidth    the width in pixels
	#   pnHeight   the height in pixels
	#   returns    nothing; the file is written
	#   note       it works on a machine with no graphics device; an existing file is overwritten
	#   see        ToSVG, ToPNG
	#@ aka  Write the picture. SVG always works -- it needs no device at all, which is what lets a CI machine draw a spectrogram.
	def ToSVGFile(pcPath, pnWidth, pnHeight)
		_oCv_ = This.ToCanvas(pnWidth, pnHeight)
		write(pcPath, _oCv_.ToSVG())
		_oCv_.Free()

	# Draws the heat map and writes it to a PNG file through the graphics device.
	#
	#   pcPath     the path of the file
	#   pnWidth    the width in pixels
	#   pnHeight   the height in pixels
	#   returns    nothing; the file is written
	#   note       it needs a graphics device but opens no window; the picture of a 1000 hertz note
	#              showed a bright line at 1000 hertz and its second harmonic, ending where the note
	#              ends
	#   see        ToSVGFile, ToCanvas
	#@ aka  PNG goes through the GPU tier, so it needs a device. SVG does not.
	def ToPNG(pcPath, pnWidth, pnHeight)
		_oCv_ = This.ToCanvas(pnWidth, pnHeight)
		_oCv_.ToPNG(pcPath)
		_oCv_.Free()

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
