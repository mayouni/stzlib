#---------------------------------------------------------------------------#
#  STZSOUNDPLOT -- sound made legible: spectrograms, spectra and waveforms   #
#  drawn to be READ, not merely produced.                                    #
#---------------------------------------------------------------------------#
#
#     oP = new stzSoundPlot(900, 380)
#     oP.SetTitle("Aliasing", "harmonics above Nyquist fold back down")
#     oP.DrawSpectrogram(oGrid, 8000)
#     oP.SaveAsPNG("aliasing.png")
#
# WHY A PLOT CLASS AND NOT MORE METHODS ON THE GRID: a grid knows its numbers,
# a canvas knows how to draw, and neither should have to know about axis ticks,
# decibel scales or where a legend goes. This is the third thing -- the one
# that turns data into something a person can read -- and keeping it separate
# is what lets the analysis stay a data model.
#
# ── THE COLOUR RULES THIS CLASS FOLLOWS ──
#
# A spectrogram encodes MAGNITUDE, which is a sequential job, and the rule for
# a sequential ramp is LIGHTNESS MONOTONICITY: every step must be lighter than
# the one before, or the eye invents structure the data does not have. That is
# exactly what is wrong with the old rainbow ("jet") maps still seen in audio
# tools -- they run bright-dark-bright, so a mid-level band reads as an edge.
#
# The ramp here is inferno, and its monotonicity was COMPUTED, not eyeballed:
#
#     step  hex        OKLab L
#        0  #000004     0.048
#        3  #6a176e     0.384
#        6  #dd513a     0.620
#       10  #fcffa4     0.978        every step strictly lighter than the last
#
# Spectra with several series are a CATEGORICAL job instead: fixed hue order,
# never cycled, a legend always present, and the line colour never encodes the
# value -- it identifies which wave you are looking at.
#
# ── AND THE READABILITY RULES ──
#
# Decibels, not amplitude, on every magnitude axis: hearing is logarithmic, and
# a linear scale shows one bright line on an otherwise black picture. Log
# frequency on spectra, because an octave is a doubling and the ear hears
# octaves as equal steps. Recessive gridlines, muted axes, and the ink of a
# label is text-coloured -- never the series colour, which is the mark's job.

func StzSoundPlotQ(pnWidth, pnHeight)
	return new stzSoundPlot(pnWidth, pnHeight)

# Draws a sound's analysis, a spectrogram, spectra or a waveform, as a readable picture on a dark plate, in SVG or PNG.
#
# Create the plate with a width and a height, set the title and the note, call one Draw method with
# the analysis it needs, add markers, then ToSVG, SaveAsSVG or SaveAsPNG. The title and the note are
# read when the Draw method runs, so they must be set before it. The spectrogram uses the inferno
# colour ramp, the spectra a fixed order of hues with a legend, and every magnitude axis is in
# decibels. Reach for it when a number about a sound is not enough: it needs the sound engine for
# the analysis grids, and the PNG needs the graphics device while the SVG does not. Only the first
# two lines of the note are drawn, and DrawSpectra raises for a starting frequency of 0; see the
# warnings. Gallery: doc/gallery/stzSoundPlot/spectrogram.png (a sweep), spectra.png (two tones with
# a marker) and wave.png (beats, with a marker), each with its script, seen right by stzlib-docs
# visual pass (a model reading the PNG), 2026-10-05, not a person; wave.png carries thin dark
# hairlines inside the filled band.
#
#   receiver   o1 = new stzSoundPlot(300, 200)
#   example    o1.SetNote("A short note.")
#              ? @@( o1.ToNoteLines() )
#              #--> [ "A short note." ]
#   see        stzCanvas, stzFont
class stzSoundPlot

	@nW = 900
	@nH = 380
	@oC = NULL
	@oFont = NULL
	@cTitle = ""
	@cSubtitle = ""
	@cNote = ""
	@nL = 64        # plot margins
	@nR = 22
	@nT = 74
	@nB = 62        # tick labels, then room for a note of up to two lines

	# the dark surface set (chart surface, inks, hairlines)
	@cSurface = "#1a1a19"
	@cInk = "#ffffff"
	@cInk2 = "#c3c2b7"
	@cMuted = "#898781"
	@cGrid = "#2c2c2a"

	# categorical hues, dark mode, in FIXED order -- never cycled
	@aSeriesColors = [ "#3987e5", "#d95926", "#199e70", "#c98500", "#d55181" ]

	# How many dB below the loudest cell still gets ink. The default shows a
	# lot; a sound with a genuinely broadband floor (a naive oscillator, a
	# noisy recording) needs a TIGHTER range or the whole picture lights up
	# and the structure you came to see disappears into it.
	@nRangeDb = 70

	# Builds an empty dark plate of a width and a height in pixels, ready for one of the Draw methods, and looks for a system font.
	#
	#   pnWidth    The width of the plate, in pixels
	#   pnHeight   The height of the plate, in pixels
	#   returns    nothing; the plate is built
	#   note       the plot area leaves 64 pixels at the left, 22 at the right, 74 at the top and 62
	#              at the bottom
	#   warning    A non-number or a size outside 1 to 16384 raises the stzCanvas error, and with no
	#              font found the plate is drawn without any text
	#   see        Canvas, DrawSpectrogram
	def init(pnWidth, pnHeight)
		@nW = pnWidth
		@nH = pnHeight
		@oC = new stzCanvas(pnWidth, pnHeight)
		@oC.SetBackground(@cSurface)
		@oFont = This._FindFont()
		if isObject(@oFont)
			@oC.SetFont(@oFont, 12)
		ok

	# Returns the stzCanvas the plate is drawn on, so extra shapes can be added to the picture.
	#
	#   returns    the stzCanvas of the plot
	#   note       a shape added through it shows in the plot only after the canvas's Flush has
	#              posted it
	#   see        ToSVG, SaveAsPNG
	def Canvas()
		return @oC

	# Sets the title and the subtitle written at the top left of the next picture drawn; one called after a Draw method changes nothing.
	#
	#   pcTitle      The title, drawn at 17 pixels in white
	#   pcSubtitle   The subtitle under it, drawn at 12 pixels in grey
	#   returns      nothing; the next picture changes
	#   note         call it before the Draw method and SetTitleQ answers the plot for chaining
	#   see          SetNote
	def SetTitle(pcTitle, pcSubtitle)
		@cTitle = pcTitle
		@cSubtitle = pcSubtitle

	def SetTitleQ(pcTitle, pcSubtitle)
		This.SetTitle(pcTitle, pcSubtitle)
		return This

	# Sets the sentence written under the plot to say what the picture means; one called after a Draw method changes nothing.
	#
	#   pcNote     The sentence, wrapped to the plate width
	#   returns    nothing; the next picture changes
	#   note       call it before the Draw method and SetNoteQ answers the plot for chaining
	#   warning    Only the first two wrapped lines are drawn, the rest are dropped without a
	#              message
	#   see        ToNoteLines, SetTitle
	#@ aka  One line under the plot saying what the picture MEANS. A chart that needs a paragraph of explanation elsewhere is a chart that failed.
	def SetNote(pcNote)
		@cNote = pcNote

	def SetNoteQ(pcNote)
		This.SetNote(pcNote)
		return This

	# Returns the note cut into the lines it will be laid out in, ready to be checked without reading the picture.
	#
	#   returns    a list of text, empty when there is no note
	#   note       the line length follows the plate width at about 5.6 pixels a character
	#   warning    The plot draws only the first two lines of the list
	#   see        SetNote
	#@ aka  The note as it will actually be laid out -- DATA, so To... is right. It exists so a guard can check the wrapping without reading the picture: text reaches the SVG as glyph OUTLINES, not as characters, so there is nothing in the output to read the sentence back out of.
	def ToNoteLines()
		if @cNote = ""  return [] ok
		return This._Wrap(@cNote, This._NoteWidthInChars())

	# Sets how many decibels below the loudest cell of a spectrogram still get ink; a value of zero or less is ignored.
	#
	#   pnDb       The range in decibels
	#   returns    nothing; the next spectrogram changes
	#   note       the default is 70, and a tighter range hides a broadband floor
	#   warning    Only DrawSpectrogram reads it, since DrawSpectra always spans 72 dB
	#   see        DrawSpectrogram
	def SetDynamicRange(pnDb)
		if pnDb > 0  @nRangeDb = pnDb ok

	def SetDynamicRangeQ(pnDb)
		This.SetDynamicRange(pnDb)
		return This

	# Draws the picture on the graphics device and writes it to a PNG file.
	#
	#   pcPath     The file to write
	#   returns    nothing; the file is written
	#   note       use SaveAsSVG on a machine without a GPU
	#   warning    With no graphics device no file is written, and the answer is empty either way
	#   see        SaveAsSVG, ToSVG
	def SaveAsPNG(pcPath)
		@oC.ToPNG(pcPath)

	# Writes the picture to an SVG file, with no graphics device needed.
	#
	#   pcPath     The file to write
	#   returns    nothing; the file is written
	#   note       text reaches the file as glyph outlines, not as characters
	#   see        SaveAsPNG, ToSVG
	def SaveAsSVG(pcPath)
		write(pcPath, @oC.ToSVG())

	# Returns the picture as SVG text, with no graphics device needed.
	#
	#   returns    the SVG document as a string
	#   note       an undrawn plate gives a bare background of about 160 characters
	#   see        SaveAsSVG
	def ToSVG()
		return @oC.ToSVG()

	# Draws a spectrogram from an analysis grid, with time across, frequency up and loudness as brightness, in the inferno colour ramp.
	#
	#   poGrid     The analysis grid of a sound, from its ToSpectrogram
	#   pnMaxHz    The highest frequency to show, or 0 to show them all
	#   returns    nothing; the picture is drawn
	#   note       the time axis ends at the grid's own span (0.96 s for a one second sound), so
	#              give MarkTimeAt that span
	#   warning    A silent or empty grid draws only the title, with no axes
	#   see        SetDynamicRange, MarkTimeAt, SaveAsPNG
	#@ aka  -- THE SPECTROGRAM -----------------------------------------------------
	def DrawSpectrogram(poGrid, pnMaxHz)
		This._Chrome()
		if poGrid.IsEmpty()  return ok

		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		_rows_ = poGrid.Rows()
		_hzPer_ = poGrid.HertzPerColumn()
		_cols_ = poGrid.Columns()
		if pnMaxHz > 0
			_maxc_ = ceil(pnMaxHz / _hzPer_)
			if _maxc_ < _cols_  _cols_ = _maxc_ ok
		ok
		_mx_ = poGrid.Max()
		if _mx_ <= 0  return ok

		_cell_ = 2
		_nx_ = floor(_pw_ / _cell_)
		_ny_ = floor(_ph_ / _cell_)

		for _ix_ = 0 to _nx_ - 1
			_r0_ = floor(_ix_ * _rows_ / _nx_) + 1
			_r1_ = floor((_ix_ + 1) * _rows_ / _nx_)
			if _r1_ < _r0_  _r1_ = _r0_ ok
			for _iy_ = 0 to _ny_ - 1
				_c0_ = floor((_ny_ - 1 - _iy_) * _cols_ / _ny_) + 1
				_c1_ = floor((_ny_ - _iy_) * _cols_ / _ny_)
				if _c1_ < _c0_  _c1_ = _c0_ ok
				_peak_ = 0
				for _r_ = _r0_ to _r1_
					for _c_ = _c0_ to _c1_
						_v_ = poGrid.At(_r_, _c_)
						if _v_ > _peak_  _peak_ = _v_ ok
					next
				next
				if _peak_ <= 0  loop ok
				_db_ = 20 * log10(_peak_ / _mx_)
				if _db_ < -@nRangeDb  loop ok
				_t_ = (_db_ + @nRangeDb) / @nRangeDb
				@oC.AddRect(@nL + _ix_ * _cell_, @nT + _iy_ * _cell_, _cell_, _cell_)
				@oC.Fill(This._Inferno(_t_))
			next
		next

		This._AxisFrame()
		# time ticks
		_secs_ = _rows_ * poGrid.SecondsPerRow()
		_nT_ = 5
		for _i_ = 0 to _nT_
			_x_ = @nL + _i_ * _pw_ / _nT_
			_lab_ = "" + This._Round2(_i_ * _secs_ / _nT_) + "s"
			This._TickX(_x_, _lab_)
		next
		# frequency ticks
		_topHz_ = _cols_ * _hzPer_
		for _i_ = 0 to 4
			_y_ = @nT + _ph_ - _i_ * _ph_ / 4
			This._TickY(_y_, This._HzLabel(_i_ * _topHz_ / 4))
		next
		This._AxisTitles("time", "frequency")
		This._Legend_Sequential()
		This._Footer()

	# Draws one or more spectra as lines on a log frequency axis in decibels, all measured against the loudest point of any of them.
	#
	#   paSeries   The spectra, as pairs [ label, one-row grid ] where the grid comes from a sound's
	#              ToSpectrumOf
	#   pnFromHz   The lowest frequency shown, which must be above 0
	#   pnToHz     The highest frequency shown
	#   returns    nothing; the picture is drawn
	#   note       the first series is drawn on top, a legend appears from two series and the hues
	#              cycle after five
	#   warning    A starting frequency of 0 raises R51 because its logarithm is undefined
	#   see        MarkFrequencyAt, SetTitle
	#@ aka  -- THE SPECTRUM (one or more series) -----------------------------------
	def DrawSpectra(paSeries, pnFromHz, pnToHz)
		This._Chrome()
		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		_lf_ = log10(pnFromHz)
		_lt_ = log10(pnToHz)

		# gridlines at the decade and half-decade marks
		_aTicks_ = [ 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000 ]
		for _i_ = 1 to len(_aTicks_)
			_hz_ = _aTicks_[_i_]
			if _hz_ < pnFromHz or _hz_ > pnToHz  loop ok
			_x_ = @nL + _pw_ * (log10(_hz_) - _lf_) / (_lt_ - _lf_)
			@oC.AddLine(_x_, @nT, _x_, @nT + _ph_)
			@oC.Stroke(@cGrid, 1)
			This._TickX(_x_, This._HzLabel(_hz_))
		next
		# decibel gridlines
		for _db_ = 0 to -72 step -12
			_y_ = @nT + _ph_ * (-_db_) / 72
			@oC.AddLine(@nL, _y_, @nL + _pw_, _y_)
			@oC.Stroke(@cGrid, 1)
			This._TickY(_y_, "" + _db_ + " dB")
		next

		_n_ = len(paSeries)

		# ONE REFERENCE FOR EVERY SERIES. Normalising each curve to its own
		# peak puts them all at 0 dB and quietly destroys the comparison --
		# a filter that BOOSTS by 12 dB then looks identical to one that does
		# not. The loudest point anywhere is 0 dB, and everything is measured
		# against it.
		_mx_ = 0
		for _s_ = 1 to _n_
			_m_ = paSeries[_s_][2].Max()
			if _m_ > _mx_  _mx_ = _m_ ok
		next
		if _mx_ <= 0  return ok

		# LAST TO FIRST, so series 1 ends up on top. The busiest spectrum is
		# usually last in the list and would otherwise bury the simple one
		# the reader is meant to compare it against.
		for _s_ = _n_ to 1 step -1
			_lab_ = paSeries[_s_][1]
			_g_ = paSeries[_s_][2]
			_col_ = @aSeriesColors[((_s_ - 1) % len(@aSeriesColors)) + 1]
			_hzPer_ = _g_.HertzPerColumn()

			# ONE POINT PER PIXEL, holding the loudest bin under it. A 4097-bin
			# spectrum across 830 px is five bins to a pixel: drawn raw the line
			# doubles back on itself, and a harmonic that should be a clean
			# spike turns into fur. Peak-hold keeps the spikes where they are.
			_pxs_ = []
			for _p_ = 0 to floor(_pw_)
				_pxs_ + (-1)
			next
			for _c_ = 2 to _g_.Columns()
				_hz_ = (_c_ - 1) * _hzPer_
				if _hz_ < pnFromHz or _hz_ > pnToHz  loop ok
				_px_ = floor(_pw_ * (log10(_hz_) - _lf_) / (_lt_ - _lf_))
				if _px_ < 0 or _px_ > floor(_pw_)  loop ok
				_v_ = _g_.At(1, _c_)
				if _v_ > _pxs_[_px_ + 1]  _pxs_[_px_ + 1] = _v_ ok
			next

			# AddPolyline wants a FLAT list -- x, y, x, y -- not a list of pairs.
			_pts_ = []
			_lastY_ = 0
			for _p_ = 0 to floor(_pw_)
				_v_ = _pxs_[_p_ + 1]
				if _v_ < 0  loop ok
				if _v_ <= 0  _v_ = 0.0000001 ok
				_db_ = 20 * log10(_v_ / _mx_)
				if _db_ < -72  _db_ = -72 ok
				_y_ = @nT + _ph_ * (-_db_) / 72
				_pts_ + (@nL + _p_)
				_pts_ + _y_
				_lastY_ = _y_
			next
			if len(_pts_) > 3
				@oC.AddPolyline(_pts_)
				@oC.Stroke(_col_, 2)
			ok
		next

		This._Legend_Categorical(paSeries)

		This._AxisFrame()
		This._AxisTitles("frequency", "level")
		This._Footer()

	# Draws the waveform of a sound's first channel as a band between its lowest and highest sample in each pixel column.
	#
	#   poSound    The sound to draw, any object answering Frames, SampleAt and Duration
	#   returns    nothing; the picture is drawn
	#   note       the axis shows the time from 0 to the sound's duration and the amplitude from -1
	#              to 1
	#   warning    A sound of fewer than two frames draws only the title
	#   see        MarkTimeAt, DrawSpectrogram
	#@ aka  -- THE WAVEFORM --------------------------------------------------------
	def DrawWave(poSound)
		This._Chrome()
		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		_mid_ = @nT + _ph_ / 2
		_n_ = poSound.Frames()
		if _n_ < 2  return ok

		# the zero line, and +-1 rails
		@oC.AddLine(@nL, _mid_, @nL + _pw_, _mid_)
		@oC.Stroke(@cGrid, 1)

		# min/max per column: a waveform drawn by sampling every Nth frame
		# LIES -- it misses the peaks between samples and shows a quieter,
		# smoother signal than the one you have
		_cols_ = floor(_pw_)
		for _i_ = 0 to _cols_ - 1
			_f0_ = floor(_i_ * _n_ / _cols_) + 1
			_f1_ = floor((_i_ + 1) * _n_ / _cols_)
			if _f1_ < _f0_  _f1_ = _f0_ ok
			_lo_ = 1  _hi_ = -1
			for _f_ = _f0_ to _f1_
				_v_ = poSound.SampleAt(_f_, 1)
				if _v_ < _lo_  _lo_ = _v_ ok
				if _v_ > _hi_  _hi_ = _v_ ok
			next
			if _lo_ > _hi_  loop ok
			_y0_ = _mid_ - _hi_ * (_ph_ / 2) * 0.94
			_y1_ = _mid_ - _lo_ * (_ph_ / 2) * 0.94
			if _y1_ - _y0_ < 1  _y1_ = _y0_ + 1 ok
			@oC.AddRect(@nL + _i_, _y0_, 1, _y1_ - _y0_)
			@oC.Fill(@aSeriesColors[1])
		next

		This._AxisFrame()
		_secs_ = poSound.Duration()
		for _i_ = 0 to 5
			This._TickX(@nL + _i_ * _pw_ / 5, "" + This._Round2(_i_ * _secs_ / 5) + "s")
		next
		for _i_ = 0 to 2
			_amp_ = 1 - _i_
			This._TickY(_mid_ - _amp_ * (_ph_ / 2) * 0.94, "" + _amp_)
			This._TickY(_mid_ + _amp_ * (_ph_ / 2) * 0.94, "" + (-_amp_))
		next
		This._AxisTitles("time", "amplitude")
		This._Footer()

	# Draws a red vertical line with a label at a moment of the picture, to point at where something happens.
	#
	#   pnSeconds        The moment to mark, in seconds
	#   pnTotalSeconds   The time span the horizontal axis shows
	#   pcLabel          The text written beside the line
	#   returns          nothing; the marker is added
	#   note             call it after the Draw method
	#   warning          A moment past the span is drawn outside the plot area without an error
	#   see              MarkFrequencyAt, DrawWave
	#@ aka  A vertical marker with a label -- for pointing at the moment something happens ("the click is HERE").
	def MarkTimeAt(pnSeconds, pnTotalSeconds, pcLabel)
		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		_x_ = @nL + _pw_ * pnSeconds / pnTotalSeconds
		@oC.AddLine(_x_, @nT, _x_, @nT + _ph_)
		@oC.Stroke("#e34948", 1)
		This._Label(pcLabel, _x_ + 5, @nT + 14, "#e34948")

	# Draws a red vertical line with a label at a frequency on the log axis of DrawSpectra, to point at a corner or a fundamental.
	#
	#   pnHz       The frequency to mark
	#   pnFromHz   The lowest frequency of the axis, as given to DrawSpectra
	#   pnToHz     The highest frequency of the axis, as given to DrawSpectra
	#   pcLabel    The text written beside the line
	#   returns    nothing; the marker is added
	#   note       call it after the Draw method with the same two limits
	#   warning    A frequency outside the axis is skipped without a message
	#   see        MarkTimeAt, DrawSpectra
	#@ aka  The same marker on a LOG frequency axis -- for pointing at a filter's corner, a fundamental, or Nyquist. The from/to must match the DrawSpectra call, because the axis is only as wide as what was drawn on it.
	def MarkFrequencyAt(pnHz, pnFromHz, pnToHz, pcLabel)
		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		if pnHz < pnFromHz or pnHz > pnToHz  return ok
		_lf_ = log10(pnFromHz)
		_x_ = @nL + _pw_ * (log10(pnHz) - _lf_) / (log10(pnToHz) - _lf_)
		@oC.AddLine(_x_, @nT, _x_, @nT + _ph_)
		@oC.Stroke("#e34948", 1)
		This._Label(pcLabel, _x_ + 5, @nT + 14, "#e34948")

	#-- private: chrome -----------------------------------------------------

	def _Chrome()
		if @cTitle != ""
			This._Text(@cTitle, @nL, 26, @cInk, 17)
		ok
		if @cSubtitle != ""
			This._Text(@cSubtitle, @nL, 45, @cInk2, 12)
		ok

	def _AxisFrame()
		_pw_ = @nW - @nL - @nR
		_ph_ = @nH - @nT - @nB
		@oC.AddLine(@nL, @nT + _ph_, @nL + _pw_, @nT + _ph_)
		@oC.Stroke(@cMuted, 1)
		@oC.AddLine(@nL, @nT, @nL, @nT + _ph_)
		@oC.Stroke(@cMuted, 1)

	# Only the Y axis gets a title. "0s ... 2.98s" along the bottom already
	# says "time", and a second label saying it again is the one thing on the
	# plate competing for the footer's space -- which is where the sentence
	# that actually explains the picture lives.
	def _AxisTitles(pcX, pcY)
		This._Text(pcY, 6, @nT - 12, @cMuted, 11)

	def _TickX(pnX, pcLabel)
		_ph_ = @nH - @nT - @nB
		@oC.AddLine(pnX, @nT + _ph_, pnX, @nT + _ph_ + 4)
		@oC.Stroke(@cMuted, 1)
		This._Text(pcLabel, pnX - 12, @nT + _ph_ + 18, @cMuted, 11)

	def _TickY(pnY, pcLabel)
		@oC.AddLine(@nL - 4, pnY, @nL, pnY)
		@oC.Stroke(@cMuted, 1)
		This._Text(pcLabel, 6, pnY + 4, @cMuted, 11)

	# The ramp, shown -- a magnitude picture without its scale is a mood board.
	def _Legend_Sequential()
		_x_ = @nW - @nR - 132
		_y_ = 30
		for _i_ = 0 to 65
			@oC.AddRect(_x_ + _i_ * 2, _y_, 2, 8)
			@oC.Fill(This._Inferno(_i_ / 65))
		next
		This._Text("quiet", _x_, _y_ + 22, @cMuted, 10)
		This._Text("loud", _x_ + 108, _y_ + 22, @cMuted, 10)

	# A legend row, laid out right-to-left from the plot's top-right corner so
	# it never collides with the title. Identity is never colour alone: the
	# swatch carries the hue, the word beside it carries the name -- and the
	# word stays in text ink, because a label wearing the series colour is
	# harder to read and says nothing the swatch has not already said.
	def _Legend_Categorical(paSeries)
		_n_ = len(paSeries)
		if _n_ < 2  return ok
		_x_ = @nW - @nR
		for _s_ = _n_ to 1 step -1
			_lab_ = paSeries[_s_][1]
			_col_ = @aSeriesColors[((_s_ - 1) % len(@aSeriesColors)) + 1]
			_w_ = len(_lab_) * 6 + 12          # swatch + gap + text, estimated
			_x_ -= _w_ + 14
			@oC.AddRect(_x_, 30, 9, 9)
			@oC.Fill(_col_)
			This._Text(_lab_, _x_ + 14, 39, @cInk2, 11)
		next

	# The note WRAPS. The first draft let it run off the right edge and the
	# last four words of the sentence explaining the picture were simply not
	# in the picture -- so the footer measures itself against the plate width
	# instead of hoping.
	def _NoteWidthInChars()
		return floor((@nW - @nL - 8) / 5.6)          # ~5.6 px per char at 11 px

	def _Footer()
		if @cNote = ""  return ok
		_a_ = This.ToNoteLines()
		_n_ = len(_a_)
		if _n_ > 2  _n_ = 2 ok
		for _i_ = 1 to _n_
			This._Text(_a_[_i_], @nL, @nH - 26 + (_i_ - 1) * 15, @cInk2, 11)
		next

	def _Wrap(pcText, pnMax)
		_a_ = []
		_words_ = split(pcText, " ")
		_line_ = ""
		for _i_ = 1 to len(_words_)
			_try_ = _line_
			if _try_ != ""  _try_ += " " ok
			_try_ += _words_[_i_]
			if len(_try_) > pnMax and _line_ != ""
				_a_ + _line_
				_line_ = _words_[_i_]
			else
				_line_ = _try_
			ok
		next
		if _line_ != ""  _a_ + _line_ ok
		return _a_

	# ADD FIRST, THEN STYLE. stzCanvas's SetFont behaves exactly like Fill:
	# with a shape pending it restyles THAT shape, and only otherwise sets the
	# default. Calling SetFont before AddText therefore resizes the PREVIOUS
	# label and leaves this one at the old size -- which is why the first plate
	# came out with a title smaller than its own subtitle.
	def _Text(pcText, pnX, pnY, pColor, pnSize)
		if NOT isObject(@oFont)  return ok
		@oC.AddText(pcText, pnX, pnY)
		@oC.SetFont(@oFont, pnSize)
		@oC.Fill(pColor)

	def _Label(pcText, pnX, pnY, pColor)
		This._Text(pcText, pnX, pnY, pColor, 11)

	#-- private: colour and numbers ----------------------------------------

	# INFERNO, sampled at eleven steps and interpolated. Lightness rises
	# monotonically from 0.048 to 0.978 -- computed, not guessed -- which is
	# the property a sequential ramp must have and a rainbow does not.
	def _Inferno(pnT)
		_t_ = pnT
		if _t_ < 0  _t_ = 0 ok
		if _t_ > 1  _t_ = 1 ok
		_a_ = [
			[  0,   0,   4], [ 22,  11,  57], [ 66,  10, 104], [106,  23, 110],
			[147,  38, 103], [188,  55,  84], [221,  81,  58], [243, 120,  25],
			[252, 165,  10], [246, 215,  70], [252, 255, 164] ]
		_u_ = _t_ * 10
		_i_ = floor(_u_)
		if _i_ > 9  _i_ = 9 ok
		_f_ = _u_ - _i_
		_c0_ = _a_[_i_ + 1]
		_c1_ = _a_[_i_ + 2]
		_r_ = floor(_c0_[1] + (_c1_[1] - _c0_[1]) * _f_)
		_g_ = floor(_c0_[2] + (_c1_[2] - _c0_[2]) * _f_)
		_b_ = floor(_c0_[3] + (_c1_[3] - _c0_[3]) * _f_)
		return "#" + This._Hex(_r_) + This._Hex(_g_) + This._Hex(_b_)

	def _Hex(pn)
		_n_ = pn
		if _n_ < 0  _n_ = 0 ok
		if _n_ > 255  _n_ = 255 ok
		_c_ = "0123456789abcdef"
		return substr(_c_, floor(_n_ / 16) + 1, 1) + substr(_c_, (_n_ % 16) + 1, 1)

	def _HzLabel(pnHz)
		if pnHz >= 1000
			return "" + This._Round1(pnHz / 1000) + "k"
		ok
		return "" + floor(pnHz)

	def _Round1(pn)
		return floor(pn * 10 + 0.5) / 10

	def _Round2(pn)
		return floor(pn * 100 + 0.5) / 100

	def _FindFont()
		_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
		        "C:/Windows/Fonts/Candara.ttf",
		        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
		        "/System/Library/Fonts/Helvetica.ttc" ]
		for _i_ = 1 to len(_a_)
			if fexists(_a_[_i_])
				return new stzFont(_a_[_i_])
			ok
		next
		return NULL
