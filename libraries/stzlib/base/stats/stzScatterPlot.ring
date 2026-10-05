
#-----------------------#
#  SCATTER CHART CLASS  #
#-----------------------#

class stzScatterChart from stzScatterPlot

# Draws points given as [ h, v ] pairs on two axes: as text for a terminal, as SVG, or as a PNG picture.
#
# The points come as pairs, as two lists named H and V (or X and Y), or as labelled points. ToString
# draws a circle per point on ticked axes with the letters X and Y at the axis ends, and switches to
# the Ring renderer when the dashed grid or the point labels are on; ToSVG and ToPNG draw one circle
# per point and carry the coordinates and nothing else, so the grid, labels, letters, axis switches
# and point character do not reach pixels. The axis letters read the opposite of the usual way (X on
# the vertical axis), the text picture writes one x tick label per point so many points make them
# collide, and the pixel picture draws no x tick labels at all; see the warnings. Gallery:
# doc/gallery/stzScatterPlot/clusters.png (two clusters of 40 points) and negative.png (points
# around the origin), each with its script, seen wrong by stzlib-docs visual pass (a model reading
# the PNG), 2026-10-05, not a person because the horizontal axis carries no numbers; terminal.txt is
# the text picture of the clusters, read as text and judged wrong because the x tick labels run
# together.
#
#   receiver   o1 = new stzScatterPlot([ [ 1, 4 ], [ 2, 9 ], [ 3, 6 ] ])
#   example    ? @@( o1.HValues() )
#              #--> [ 1, 2, 3 ]
#              ? @@( o1.PointLabels() )
#              #--> [ "P1", "P2", "P3" ]
#   see        stzBarPlot, stzHistogram
class stzScatterPlot from stzObject

	@anHValues = []
	@anVValues = []
	@acPointLabels = []

	@bShowHAxis = 1
	@bShowVAxis = 1
	@bShowGrid = 0
	@bShowLabels = 0

	# V and H letters at the end of the axes
	@bShowHLetter = 0
	@bShowVLetter = 0

	# Console defaults
	@nMaxWidth = 42 
	@nMaxHeight = 12 
	@nHAxisHeight = 2

	@cPointChar = "●"
	@cVerticalGridChar = "⁞"
	@cHorizontalGridChar = "-"

	@cHTickChar = "┬"
	@cHTickChar2 = "┼"
	@cVTickChar = "┤"

	# Axis and drawing characters
	@cHAxisChar = "─"
	@cVAxisChar = "│"
	@cOriginChar = "╰"
	@cHArrowChar = "►"
	@cVArrowChar = "▲"

	@nHMin = 0
	@nHMax = 0
	@nVMin = 0
	@nVMax = 0

	@nWidth = 0
	@nHeight = 0
	@acCanvas = []

	# Builds a scatter plot from [ h, v ] pairs, from H and V lists or from labelled points; raises an error for other data.
	#
	#   paDataSet   The points: [ [ 1, 4 ], [ 2, 9 ] ], or [ :H = [ 1, 2 ], :V = [ 4, 9 ] ] (the
	#               keys may be :X and :Y), or [ :a = [ 1, 4 ], :b = [ 2, 9 ] ] where each key
	#               labels a point
	#   returns     nothing; the plot is built
	#   note        pairs and the H/V form label the points P1, P2 ... and the other form keeps the
	#               keys
	#   warning     An empty list raises "H and V values must all be numbers!" and a pair holding
	#               text raises "Invalid data format!"
	#   see         HValues, VValues, PointLabels
	def init(paDataSet)
		if NOT isList(paDataSet)
			StzRaise("Can't create stzScatterChart! paDataSet must be a list.")
		ok

		if IsListOfPairs(paDataSet) and len(paDataSet) > 0 and IsListOfNumbers(paDataSet[1])
			@anHValues = []
			@anVValues = []
			@acPointLabels = []

			_nDataSetLen_ = len(paDataSet)
			for i = 1 to _nDataSetLen_
				if len(paDataSet[i]) >= 2
					@anHValues + paDataSet[i][1]
					@anVValues + paDataSet[i][2]
					@acPointLabels + ("P" + i)
				ok
			next

		but IsHashList(paDataSet)
			_oHash_ = new stzHashList(paDataSet)
			_aKeys_ = _oHash_.Keys()

			if len(_aKeys_) = 2 and (_aKeys_[1] = "H" or _aKeys_[1] = :H or _aKeys_[1] = "X" or _aKeys_[1] = :X) and 
			   (_aKeys_[2] = "V" or _aKeys_[2] = :V or _aKeys_[2] = "Y" or _aKeys_[2] = :Y)
				
				if _aKeys_[1] = "H" or _aKeys_[1] = :H
					@anHValues = paDataSet[:H]
				else
					@anHValues = paDataSet[:X]
				ok
				
				if _aKeys_[2] = "V" or _aKeys_[2] = :V
					@anVValues = paDataSet[:V]
				else
					@anVValues = paDataSet[:Y]
				ok

				if len(@anHValues) != len(@anVValues)
					StzRaise("H and V value arrays must have same length!")
				ok

				@acPointLabels = []
				_nHValuesLen_3 = len(@anHValues)
				for i = 1 to _nHValuesLen_3
					@acPointLabels + ("P" + i)
				next

			else
				@anHValues = []
				@anVValues = []
				@acPointLabels = _oHash_.Keys()

				_aValues_ = _oHash_.Values()
				_nValuesLen_ = len(_aValues_)
				for i = 1 to _nValuesLen_
					if isList(_aValues_[i]) and len(_aValues_[i]) >= 2
						@anHValues + _aValues_[i][1]
						@anVValues + _aValues_[i][2]
					ok
				next
			ok

		else
			StzRaise("Invalid data format! Use [[h1,v1], [h2,v2]] or hashlist format.")
		ok

		if NOT (IsListOfNumbers(@anHValues) and IsListOfNumbers(@anVValues))
			StzRaise("H and V values must all be numbers!")
		ok

		_calculateRanges()

		@bShowHLetter = 1
		@bShowVLetter = 1

	# Draws the points on a new canvas with axes and tick values and answers it, so the plot can become SVG or PNG.
	#
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, :Color
	#               = , :Background = , :Grid = , :Min = , :Max = ]
	#   returns     an stzCanvas holding the picture
	#   note        without a Font option the picture has no text
	#   warning     Only the coordinates carry over to pixels, so the grid, the labels, the letters,
	#               the axis switches and the point character set on this object do not
	#   see         ToSVG, ToPNG
	#@ aka  -- the PIXEL tiers (GR6c) -------------------------------------------- The same points, drawn instead of typed. ToSVG() needs no GPU.
	def ToCanvasQ(paOptions)
		_aPts_ = []
		_nL_ = len(@anHValues)
		for _i_ = 1 to _nL_
			_aPts_ + [ @anHValues[_i_], @anVValues[_i_] ]
		next
		return StzPlotCanvasQ(:Scatter, _aPts_, @acPointLabels, paOptions)

	# Returns the scatter plot as SVG text, with one circle per point and no graphics device needed.
	#
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, ... ],
	#               as for ToCanvasQ
	#   returns     the SVG document as a string
	#   note        the default size is 900 by 500 and text needs a Font
	#   see         ToCanvasQ, ToPNG
	def ToSVG(paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToSVG()
		_oCv_.Free()
		return _cOut_

	# Draws the scatter plot on the graphics device and returns the PNG bytes, writing them to a file when a path is given.
	#
	#   pcPath      The file to write, or an empty text to write none
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, ... ],
	#               as for ToCanvasQ
	#   returns     the PNG bytes as a string, empty when no device is available
	#   see         ToSVG, ToCanvasQ
	def ToPNG(pcPath, paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToPNG(pcPath)
		_oCv_.Free()
		return _cOut_

	# Returns the horizontal coordinate of every point, in order.
	#
	#   returns    a list of numbers
	#   note       the values read from the first number of each pair
	#   see        VValues, PointLabels
	#@ aka  Primary methods with V/H semantics
	def HValues()
		return @anHValues
		
		def XValues()  # Alias
			return This.HValues()

	# Returns the vertical coordinate of every point, in order.
	#
	#   returns    a list of numbers
	#   note       the values read from the second number of each pair
	#   see        HValues, PointLabels
	def VValues()
		return @anVValues
		
		def YValues()  # Alias
			return This.VValues()

	# Returns the label of every point, in order.
	#
	#   returns    a list of text
	#   note       P1, P2 ... unless the points were given with keys
	#   see        HValues, AddLabels
	def PointLabels()
		return @acPointLabels

	# Shows or hides the horizontal axis: its line, ticks, value labels and arrow.
	#
	#   bShow      1 to show the axis, 0 to hide it
	#   returns    nothing; the plot changes
	#   note       the points stay where they were
	#   see        WithoutHAxis, SetVAxis, SetHVAxis
	def SetHAxis(bShow)
		@bShowHAxis = bShow
		
		# Shows or hides the horizontal axis, under the X name.
		#
		#   bShow      1 to show the axis, 0 to hide it
		#   returns    nothing; the plot changes
		#   see        SetHAxis
		def SetXAxis(bShow)  # Alias
			This.SetHAxis(bShow)

		# Hides the horizontal axis, with its ticks and value labels.
		#
		#   returns    nothing; the plot changes
		#   see        SetHAxis, WithoutVAxis
		def WithoutHAxis()
			@bShowHAxis = 0
			
		# Hides the horizontal axis, under the X name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHAxis
		def WithoutXAxis()  # Alias
			This.WithoutHAxis()

	# Shows or hides the vertical axis: its line, ticks, value labels and arrow.
	#
	#   bShow      1 to show the axis, 0 to hide it
	#   returns    nothing; the plot changes
	#   note       the points stay where they were
	#   see        WithoutVAxis, SetHAxis, SetHVAxis
	def SetVAxis(bShow)
		@bShowVAxis = bShow
		
		# Shows or hides the vertical axis, under the Y name.
		#
		#   bShow      1 to show the axis, 0 to hide it
		#   returns    nothing; the plot changes
		#   see        SetVAxis
		def SetYAxis(bShow)  # Alias
			This.SetVAxis(bShow)

		# Hides the vertical axis, with its ticks and value labels.
		#
		#   returns    nothing; the plot changes
		#   see        SetVAxis, WithoutHAxis
		def WithoutVAxis()
			@bShowVAxis = 0
			
		# Hides the vertical axis, under the Y name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutVAxis
		def WithoutYAxis()  # Alias
			This.WithoutVAxis()

	# Shows or hides both axes together.
	#
	#   bShow      1 to show both axes, 0 to hide both
	#   returns    nothing; the plot changes
	#   note       with 0 only the points remain
	#   see        SetHAxis, SetVAxis, WithoutHVAxis
	def SetHVAxis(bShow)
		@bShowHAxis = bShow
		@bShowVAxis = bShow

		# Shows or hides both axes together, in the V then H word order.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def SetVHAxis(bShow)
			This.SetHVAxis(bShow)

		# Shows or hides both axes together, under the Axes spelling.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def SetHVAxes(bShow)
			This.SetHVAxis(bShow)

		# Shows or hides both axes together, under the Axes spelling and the V then H word order.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def SetVHAxes(bShow)
			This.SetHVAxis(bShow)
			
		# Shows or hides both axes together, under the X and Y names.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		#@ aka  X/Y aliases
		def SetXYAxis(bShow)
			This.SetHVAxis(bShow)
			
		# Shows or hides both axes together, under the Y and X names.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def SetYXAxis(bShow)
			This.SetHVAxis(bShow)
			
		# Shows or hides both axes together, under the X and Y names and the Axes spelling.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetXYAxis
		def SetXYAxes(bShow)
			This.SetHVAxis(bShow)
			
		# Shows or hides both axes together, under the Y and X names and the Axes spelling.
		#
		#   bShow      1 to show both axes, 0 to hide both
		#   returns    nothing; the plot changes
		#   see        SetXYAxis
		def SetYXAxes(bShow)
			This.SetHVAxis(bShow)

		# Hides both axes, leaving only the points.
		#
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def WithoutHVAxis()
			This.SetHVAxis(0)

		# Hides both axes, in the V then H word order.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutVHAxis()
			This.SetHVAxis(0)
			
		# Hides both axes, under the X and Y names.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutXYAxis()  # Alias
			This.SetHVAxis(0)

		# Hides both axes, under the Y and X names.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutYXAxis()  # Alias
			This.SetHVAxis(0)

	# Shows or hides the two letters at the axis ends: X above the vertical axis and Y at the end of the horizontal axis.
	#
	#   bShow      1 to show both letters, 0 to hide both
	#   returns    nothing; the plot changes
	#   note       a letter only appears while its axis is shown
	#   warning    The letters read the opposite of the usual way: X marks the vertical axis and Y
	#              the horizontal one, although the horizontal values are called H or X
	#   see        WithoutHVLetters, SetHLetter, SetVLetter
	def SetHVLetters(bShow)
		@bShowHLetter = bShow
		@bShowVLetter = bShow

		# Shows or hides the two axis letters, in the V then H word order.
		#
		#   bShow      1 to show both letters, 0 to hide both
		#   returns    nothing; the plot changes
		#   warning    The letters read X on the vertical axis and Y on the horizontal one
		#   see        SetHVLetters
		def SetVH(bShow)
			This.SetHVLetters(bShow)
			
		# Shows or hides the two axis letters, under the X and Y names.
		#
		#   bShow      1 to show both letters, 0 to hide both
		#   returns    nothing; the plot changes
		#   warning    The letters read X on the vertical axis and Y on the horizontal one
		#   see        SetHVLetters
		def SetXYLetters(bShow)  # Alias
			This.SetHVLetters(bShow)

		# Shows or hides the two axis letters, under the shortest X and Y name.
		#
		#   bShow      1 to show both letters, 0 to hide both
		#   returns    nothing; the plot changes
		#   warning    The letters read X on the vertical axis and Y on the horizontal one
		#   see        SetHVLetters
		def SetXY(bShow)  # Alias
			This.SetHVLetters(bShow)

		# Hides the two axis letters, leaving the axes.
		#
		#   returns    nothing; the plot changes
		#   see        SetHVLetters
		def WithoutHV()
			This.SetHVLetters(0)
			
		# Hides the two axis letters, under the X and Y names.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHV
		def WithoutXY()  # Alias
			This.SetHVLetters(0)

		# Hides the two axis letters, leaving the axes.
		#
		#   returns    nothing; the plot changes
		#   see        SetHVLetters
		def WithoutHVLetters()
			This.SetHVLetters(0)
			
		# Hides the two axis letters, under the X and Y names.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVLetters
		def WithoutXYLetters()  # Alias
			This.SetHVLetters(0)

	# Shows or hides the letter ending the horizontal axis, which reads Y, though ToString hides it only with the vertical letter.
	#
	#   bShow      1 to show the letter, 0 to hide it
	#   returns    nothing; the plot changes only with the grid or labels on
	#   note       the letter needs the horizontal axis shown
	#   warning    ToString treats the two letters as one switch and drops them only when both are
	#              off, while ToStringInRing, used when the grid or point labels are on, obeys each
	#              one
	#   see        SetVLetter, SetHVLetters
	def SetHLetter(bShow)
		@bShowHLetter = bShow

		# Shows or hides the letter at the end of the horizontal axis, under the one-letter name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the vertical letter is hidden too
		#   see        SetHLetter
		def SetH(bShow)
			@bShowHLetter = bShow
			
		# Shows or hides the letter at the end of the horizontal axis, under the X name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the vertical letter is hidden too
		#   see        SetHLetter
		def SetXLetter(bShow)  # Alias
			@bShowHLetter = bShow

		# Shows or hides the letter at the end of the horizontal axis, under the shortest X name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the vertical letter is hidden too
		#   see        SetHLetter
		def SetX(bShow)  # Alias
			@bShowHLetter = bShow

		# Hides the letter at the end of the horizontal axis, which ToString still draws while the vertical letter is on.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        SetHLetter, WithoutV
		def WithoutH()
			@bShowHLetter = 0
			
		# Hides the letter at the end of the horizontal axis, under the X name.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        WithoutH
		def WithoutX()  # Alias
			@bShowHLetter = 0

		# Hides the letter at the end of the horizontal axis, which ToString still draws while the vertical letter is on.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        SetHLetter
		def WithoutHLetter()
			@bShowHLetter = 0
			
		# Hides the letter at the end of the horizontal axis, under the X name.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        WithoutHLetter
		def WithoutXLetter()  # Alias
			@bShowHLetter = 0

	# Shows or hides the letter above the vertical axis, which reads X, but ToString removes it only when the horizontal letter is hidden too.
	#
	#   bShow      1 to show the letter, 0 to hide it
	#   returns    nothing; the plot changes only with the grid or labels on
	#   note       the letter needs the vertical axis shown
	#   warning    ToString treats the two letters as one switch and drops them only when both are
	#              off, while ToStringInRing, used when the grid or point labels are on, obeys each
	#              one
	#   see        SetHLetter, SetHVLetters
	def SetVLetter(bShow)
		@bShowVLetter = bShow

		# Shows or hides the letter above the vertical axis, under the one-letter name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the horizontal letter is hidden too
		#   see        SetVLetter
		def SetV(bShow)
			@bShowVLetter = bShow
			
		# Shows or hides the letter above the vertical axis, under the Y name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the horizontal letter is hidden too
		#   see        SetVLetter
		def SetYLetter(bShow)  # Alias
			@bShowVLetter = bShow

		# Shows or hides the letter above the vertical axis, under the shortest Y name.
		#
		#   bShow      1 to show the letter, 0 to hide it
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes it only when the horizontal letter is hidden too
		#   see        SetVLetter
		def SetY(bShow)  # Alias
			@bShowVLetter = bShow

		# Hides the letter above the vertical axis, which ToString still draws while the horizontal letter is on.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        SetVLetter, WithoutH
		def WithoutV()
			@bShowVLetter = 0
			
		# Hides the letter above the vertical axis, under the Y name.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        WithoutV
		def WithoutY()  # Alias
			@bShowVLetter = 0

		# Hides the letter above the vertical axis, which ToString still draws while the horizontal letter is on.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        SetVLetter
		def WithoutVLetter()
			@bShowVLetter = 0
			
		# Hides the letter above the vertical axis, under the Y name.
		#
		#   returns    nothing; the plot changes only with the grid or labels on
		#   warning    ToString removes the letters only when both are hidden
		#   see        WithoutVLetter
		def WithoutYLetter()  # Alias
			@bShowVLetter = 0

	# Shows or hides dashed guide lines running from each point to the axes.
	#
	#   bShow      1 to draw the guides, 0 to hide them
	#   returns    nothing; the plot changes
	#   note       the guides pass through the points, not through the ticks, and drawing them
	#              switches to the Ring renderer
	#   see        AddGrid, WithoutGrid
	def SetGrid(bShow)
		@bShowGrid = bShow

		# Draws dashed guide lines from each point to the axes.
		#
		#   returns    nothing; the plot changes
		#   see        SetGrid
		def AddGrid()
			@bShowGrid = 1

		# Removes the guide lines.
		#
		#   returns    nothing; the plot changes
		#   see        SetGrid
		def WithoutGrid()
			@bShowGrid = 0

	# Shows or hides the label written beside each point.
	#
	#   bShow      1 to write the labels, 0 to hide them
	#   returns    nothing; the plot changes
	#   note       drawing them switches to the Ring renderer and the labels are P1, P2 ... unless
	#              the points had keys
	#   see        AddLabels, PointLabels
	def SetLabels(bShow)
		@bShowLabels = bShow

		# Writes each point's label beside it.
		#
		#   returns    nothing; the plot changes
		#   see        SetLabels
		def AddLabels()
			@bShowLabels = 1

		# Stops writing the label beside each point.
		#
		#   returns    nothing; the plot changes
		#   see        SetLabels
		def WithoutLabels()
			@bShowLabels = 0

	# Sets the character each point is drawn with; raises an error for anything but a single character.
	#
	#   c          The single character for a point
	#   returns    nothing; the plot changes
	#   note       the default is a filled circle
	#   warning    Raises "c must be a char." for a longer text or a non-text
	#   see        PointChar
	def SetPointChar(c)
		if NOT (isString(c) and IsChar(c))
			StzRaise("c must be a char.")
		ok
		@cPointChar = c

		# Returns the character each point is drawn with.
		#
		#   returns    a text of one character
		#   see        SetPointChar
		def PointChar()
			return @cPointChar

	# Sets the most columns and rows the picture may use; the points are spread over that area.
	#
	#   nWidth     The most columns, raised to 40 when smaller
	#   nHeight    The most rows, raised to 10 when smaller
	#   returns    nothing; the plot changes
	#   note       the defaults are 42 and 12 and a non-number raises "nWidth and nHeight must be
	#              numbers."
	#   see        SetWidth, SetHeight
	def SetMaxSize(nWidth, nHeight)
		if NOT (isNumber(nWidth) and isNumber(nHeight))
			StzRaise("nWidth and nHeight must be numbers.")
		ok
		@nMaxWidth = max([40, nWidth])
		@nMaxHeight = max([10, nHeight])

	# Sets the most columns the picture may use.
	#
	#   nWidth     The most columns, raised to 50 when smaller
	#   returns    nothing; the plot changes
	#   note       the minimum is 50 here but 40 in SetMaxSize and a non-number raises an error
	#   see        SetMaxSize, SetHeight
	def SetWidth(nWidth)
		if NOT isNumber(nWidth)
			StzRaise("nWidth must be a number.")
		ok
		@nMaxWidth = max([50, nWidth])

	# Sets the most rows the picture may use.
	#
	#   nHeight    The most rows, raised to 10 when smaller
	#   returns    nothing; the plot changes
	#   note       a non-number raises an error
	#   see        SetMaxSize, SetWidth
	def SetHeight(nHeight)
		if NOT isNumber(nHeight)
			StzRaise("nHeight must be a number.")
		ok
		@nMaxHeight = max([10, nHeight])

	# Prints the scatter plot as text on the console.
	#
	#   returns    nothing; the plot is printed
	#   see        ToString
	def Show()
		? This.ToString()

	# Returns the scatter plot as text, with a circle for each point, ticked axes and the axis letters.
	#
	#   returns    a multi-line string
	#   note       it hands over to the Ring renderer when the grid or the point labels are on
	#   warning    Raises an error when the engine cannot render the plot
	#   see        Show, ToStringInRing, ToSVG
	#@ aka  THE PICTURE, rendered by the engine.
	def ToString()
		if @bShowGrid or (@bShowLabels and len(@acPointLabels) > 0)
			return This.ToStringInRing()
		ok

		_aOpts_ = [
			@nMaxWidth, @nMaxHeight, @nHAxisHeight, 2,
			iff(@bShowHAxis, 1, 0), iff(@bShowVAxis, 1, 0),
			iff(@bShowHLetter or @bShowVLetter, 1, 0),
		# THE CHARACTERS THE CALLER CHOSE, as codepoints on the end of the options.
		# They were dropped when this renderer moved to the engine: SetBarChar and
		# its siblings went on setting an attribute nothing read any more, so they
		# silently did nothing. The Ring renderer below still honoured them, which
		# is how the parity guard would have caught it -- had any case set one.
			StzCharCode(@cPointChar)
		]

		_cOut_ = StzEnginePlotScatter(@anHValues, @anVValues, _aOpts_)
		if NOT isString(_cOut_) or _cOut_ = ""
			StzRaise("stzScatterPlot: the engine could not render this plot.")
		ok
		return _cOut_

	# Returns the scatter plot as text drawn by the Ring code the engine renderer was ported from.
	#
	#   returns    a multi-line string
	#   note       it draws the grid and the point labels, which the engine renderer does not
	#   see        ToString
	#@ aka  The Ring renderer this was ported from, kept so the guard can prove the two agree character for character -- and still used for grid and point labels.
	def ToStringInRing()
		_oLayout_ = _calculateLayout()
		_initCanvas()

		if @bShowGrid
			_drawCoordinateGrid(_oLayout_)
		ok

		if @bShowVAxis
			_drawVAxis(_oLayout_)
		ok

		if @bShowHAxis
			_drawHAxis(_oLayout_)
		ok

		_drawPoints(_oLayout_)

		if @bShowLabels
			_drawPointLabels(_oLayout_)
		ok

		return _finalizeCanvas()

	def _calculateRanges()
		if len(@anHValues) = 0 or len(@anVValues) = 0
			@nHMin = 0
			@nHMax = 10
			@nVMin = 0
			@nVMax = 10
			return
		ok

		@nHMin = min(@anHValues)
		@nHMax = max(@anHValues)
		@nVMin = min(@anVValues)
		@nVMax = max(@anVValues)

		if _areAllIntegers(@anHValues)
			@nHMin = floor(@nHMin)
			@nHMax = ceil(@nHMax)
		ok
		if _areAllIntegers(@anVValues)
			@nVMin = floor(@nVMin)
			@nVMax = ceil(@nVMax)
		ok

	def _areAllIntegers(anList)
		_nAnList1Len_ = len(anList)
		for _iLoopAnList1_ = 1 to _nAnList1Len_
			_n_ = anList[_iLoopAnList1_]
			if NOT isNumber(_n_) or floor(_n_) != _n_
				return 0
			ok
		next
		return 1

	# WHERE A VALUE LANDS, with the degenerate span handled ONCE.
	#
	# Every one of these mappings used to be written inline, eight times, and each
	# divided by (max - min). A plot whose points all share one X -- or a plot of a
	# SINGLE POINT -- has a span of zero there, so it crashed with "Can't divide by
	# zero" rather than drawing the one place every point belongs.
	#
	# A zero span means every value maps to the same slot, which is the start of the
	# axis. That is what these return, and it is why they are methods now: eight
	# copies of a guard is eight chances to forget it.
	def _ColOfH(nH, nStartCol, nPlotWidth)
		if @nHMax = @nHMin
			return nStartCol
		ok
		return nStartCol + floor((nH - @nHMin) * (nPlotWidth - 1) / (@nHMax - @nHMin))

	def _RowOfV(nV, nEndRow, nPlotHeight)
		if @nVMax = @nVMin
			return nEndRow
		ok
		return nEndRow - floor((nV - @nVMin) * (nPlotHeight - 1) / (@nVMax - @nVMin))

	def _calculateLayout()
		# Calculate dynamic V-axis width based on actual labels
		_nDynamicVAxisWidth_ = 0
		if @bShowVAxis
			_aUniqueV_ = U(@anVValues)
			# NOT `new stzList(x).Sorted()`: Ring binds that as
		# `new stzList( x.Sorted() )`, so Sorted() is called on the RAW LIST
		# and its result is handed to the constructor, which then rejects it
		# with "paList must be a list". The object has to be built first.
		_oSortL_ = new stzList(_aUniqueV_)
		_aUniqueV_ = _oSortL_.Sorted()
			_nMaxVLabelLen_ = 0
			_nUniqueV2Len_ = len(_aUniqueV_)
			for _iLoopUniqueV2_ = 1 to _nUniqueV2Len_
				_nV_ = _aUniqueV_[_iLoopUniqueV2_]
				_cLabel_ = _formatValue(_nV_)
				_cLabel_ = Trim(_cLabel_)
				if len(_cLabel_) > _nMaxVLabelLen_
					_nMaxVLabelLen_ = len(_cLabel_)
				ok
			next
			# V-axis width = max label length + space + tick mark + small buffer
			_nDynamicVAxisWidth_ = _nMaxVLabelLen_ + 3
			# Ensure minimum width for readability
			_nDynamicVAxisWidth_ = max([4, _nDynamicVAxisWidth_])
		ok

		# Calculate available space for the plot area
		_nVAxisSpace_ = _nDynamicVAxisWidth_
		_nHAxisSpace_ = iff(@bShowHAxis, @nHAxisHeight, 0)
		
		# Reserve space for arrow character
		_nTopMargin_ = 1    # For vertical arrow
		
		# Calculate right margin based on longest label
		_nLenPointLabels_ = len(@acPointLabels)
		_nRightMargin_ = 2  # Default minimum
		if @bShowLabels
		    _nMaxLabelLen_ = 0
		    for i = 1 to _nLenPointLabels_
				_nLenLabel_ = len(@acPointLabels[i])
		        if _nLenLabel_ > _nMaxLabelLen_
		            _nMaxLabelLen_ = _nLenLabel_
		        ok
		    next
		    _nRightMargin_ = _nMaxLabelLen_ + 3  # Label length + spacing + buffer
		ok

		# Calculate plot dimensions with proper margins
		_nPlotWidth_ = @nMaxWidth - _nVAxisSpace_ - _nRightMargin_
		_nPlotHeight_ = @nMaxHeight - _nHAxisSpace_ - _nTopMargin_
		
		# Ensure minimum plot area
		_nPlotWidth_ = max([20, _nPlotWidth_])
		_nPlotHeight_ = max([8, _nPlotHeight_])
		
		# Calculate positions
		_nVAxisCol_ = _nVAxisSpace_
		_nPlotStartCol_ = _nVAxisCol_ + 1
		_nPlotEndCol_ = _nPlotStartCol_ + _nPlotWidth_ - 1
		
		_nPlotStartRow_ = _nTopMargin_ + 1
		_nHAxisRow_ = _nPlotStartRow_ + _nPlotHeight_
		_nPlotEndRow_ = _nHAxisRow_ - 1
		
		# Total canvas dimensions
		_nTotalWidth_ = _nPlotEndCol_ + _nRightMargin_
		_nTotalHeight_ = _nHAxisRow_ + _nHAxisSpace_
		
		# Set instance variables
		@nWidth = _nTotalWidth_
		@nHeight = _nTotalHeight_

		_oLayout_ = new stzHashList([])
		_oLayout_.AddPair([:plot_start_col, _nPlotStartCol_])
		_oLayout_.AddPair([:plot_end_col, _nPlotEndCol_])
		_oLayout_.AddPair([:plot_start_row, _nPlotStartRow_])
		_oLayout_.AddPair([:plot_end_row, _nPlotEndRow_])
		_oLayout_.AddPair([:plot_width, _nPlotWidth_])
		_oLayout_.AddPair([:plot_height, _nPlotHeight_])
		_oLayout_.AddPair([:v_axis_col, _nVAxisCol_])
		_oLayout_.AddPair([:h_axis_row, _nHAxisRow_])
		_oLayout_.AddPair([:total_width, _nTotalWidth_])
		_oLayout_.AddPair([:total_height, _nTotalHeight_])

		return _oLayout_

	def _drawCoordinateGrid(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		# Draw grid lines only from axis to each data point
		_nHValuesLen_2 = len(@anHValues)
		for i = 1 to _nHValuesLen_2
			_nH_ = @anHValues[i]
			_nV_ = @anVValues[i]
			
			# Calculate point position
			_nCol_ = This._ColOfH(_nH_, _nStartCol_, _nPlotWidth_)
			_nRow_ = This._RowOfV(_nV_, _nEndRow_, _nPlotHeight_)
			
			# Draw horizontal line from V-axis to point
			for j = _nStartCol_ to _nCol_
				if @acCanvas[_nRow_][j] = " "
					@acCanvas[_nRow_][j] = @cHorizontalGridChar
				ok
			next
			
			# Draw vertical line from H-axis to point
			for j = _nRow_ to _nEndRow_
				if @acCanvas[j][_nCol_] = " "
					@acCanvas[j][_nCol_] = @cVerticalGridChar
				ok
			next
		next

	def _drawVAxis(_oLayout_)
		if NOT @bShowVAxis
			return
		ok
		
		_nAxisCol_ = _oLayout_[:v_axis_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nHAxisRow_ = _oLayout_[:h_axis_row]
		_nPlotHeight_ = _oLayout_[:plot_height]

		# Draw vertical line
		for i = _nStartRow_ to _nEndRow_
			if i >= 1 and i <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[i])
				@acCanvas[i][_nAxisCol_] = @cVAxisChar
			ok
		next

		# Draw arrow at top
		if _nStartRow_ - 1 >= 1 and _nStartRow_ - 1 <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[_nStartRow_ - 1])
			@acCanvas[_nStartRow_ - 1][_nAxisCol_] = @cVArrowChar
		ok

		# Draw origin (only if H-axis is also visible)
		if @bShowHAxis and _nHAxisRow_ >= 1 and _nHAxisRow_ <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[_nHAxisRow_])
			@acCanvas[_nHAxisRow_][_nAxisCol_] = @cOriginChar
		ok

		# Always draw V-axis labels when V-axis is visible
		_aUniqueV_ = U(@anVValues)
		# NOT `new stzList(x).Sorted()`: Ring binds that as
		# `new stzList( x.Sorted() )`, so Sorted() is called on the RAW LIST
		# and its result is handed to the constructor, which then rejects it
		# with "paList must be a list". The object has to be built first.
		_oSortL_ = new stzList(_aUniqueV_)
		_aUniqueV_ = _oSortL_.Sorted()
		_nUniqueV1Len_ = len(_aUniqueV_)
		for _iLoopUniqueV1_ = 1 to _nUniqueV1Len_
			_nV_ = _aUniqueV_[_iLoopUniqueV1_]
			_nRow_ = This._RowOfV(_nV_, _nEndRow_, _nPlotHeight_)
			if _nRow_ >= _nStartRow_ and _nRow_ <= _nEndRow_
				_cLabel_ = _formatValue(_nV_)
				_cLabel_ = Trim(_cLabel_)
				_nLabelLen_ = len(_cLabel_)
				_nLabelStart_ = _nAxisCol_ - _nLabelLen_ - 1  # Add space before tick mark
				if _nLabelStart_ >= 1
					for j = 1 to _nLabelLen_
						@acCanvas[_nRow_][_nLabelStart_ + j - 1] = _cLabel_[j]
					next
					@acCanvas[_nRow_][_nAxisCol_] = @cVTickChar
				ok
			ok
		next

	def _drawHAxis(_oLayout_)
		if NOT @bShowHAxis
			return
		ok
		
		_nAxisRow_ = _oLayout_[:h_axis_row]
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nVAxisCol_ = _oLayout_[:v_axis_col]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nTotalWidth_ = _oLayout_[:total_width]

		# Draw horizontal line
		if _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas)
			for i = _nStartCol_ to _nEndCol_
				if i >= 1 and i <= _nTotalWidth_
					@acCanvas[_nAxisRow_][i] = @cHAxisChar
				ok
			next
		ok

		# Draw arrow at end
		if _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas) and _nEndCol_ + 1 >= 1 and _nEndCol_ + 1 <= _nTotalWidth_
			@acCanvas[_nAxisRow_][_nEndCol_ + 1] = @cHArrowChar
		ok

		# Draw origin
		if @bShowVAxis and _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas) and _nVAxisCol_ >= 1 and _nVAxisCol_ <= _nTotalWidth_
			@acCanvas[_nAxisRow_][_nVAxisCol_] = @cOriginChar
		ok

		# Always draw H-axis labels when H-axis is visible
		_aUniqueH_ = U(@anHValues)
		# NOT `new stzList(x).Sorted()`: Ring binds that as
		# `new stzList( x.Sorted() )`, so Sorted() is called on the RAW LIST
		# and its result is handed to the constructor, which then rejects it
		# with "paList must be a list". The object has to be built first.
		_oSortL_ = new stzList(_aUniqueH_)
		_aUniqueH_ = _oSortL_.Sorted()
		_nUniqueH1Len_ = len(_aUniqueH_)
		for _iLoopUniqueH1_ = 1 to _nUniqueH1Len_
			_nH_ = _aUniqueH_[_iLoopUniqueH1_]
			_nCol_ = This._ColOfH(_nH_, _nStartCol_, _nPlotWidth_)
			if _nCol_ >= _nStartCol_ and _nCol_ <= _nEndCol_
				_cLabel_ = _formatValue(_nH_)
				_nLabelLen_ = len(_cLabel_)
				_nLabelStart_ = _nCol_ - floor(_nLabelLen_ / 2)
				
				# Draw tick mark
				if _nCol_ >= 1 and _nCol_ <= _nTotalWidth_
					@acCanvas[_nAxisRow_][_nCol_] = @cHTickChar
				ok
				
				# Draw label below axis (always when axis is visible)
				if _nAxisRow_ + 1 >= 1 and _nAxisRow_ + 1 <= len(@acCanvas) and
				   _nLabelStart_ >= 1 and _nLabelStart_ + _nLabelLen_ - 1 <= _nTotalWidth_
					for j = 1 to _nLabelLen_
						@acCanvas[_nAxisRow_ + 1][_nLabelStart_ + j - 1] = _cLabel_[j]
					next
				ok
			ok
		next

	def _formatValue(nValue)
		if _areAllIntegers(@anHValues) and _areAllIntegers(@anVValues)
			return "" + floor(nValue)
		else
			return "" + RoundN(nValue, 1)
		ok

	def _drawPoints(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		_nHValuesLen_ = len(@anHValues)
		for i = 1 to _nHValuesLen_
			_nH_ = @anHValues[i]
			_nV_ = @anVValues[i]

			# Calculate point position
			if @nHMax = @nHMin
				_nCol_ = _nStartCol_ + floor(_nPlotWidth_ / 2)
			else
				_nCol_ = This._ColOfH(_nH_, _nStartCol_, _nPlotWidth_)
			ok
			
			if @nVMax = @nVMin
				_nRow_ = _nStartRow_ + floor(_nPlotHeight_ / 2)
			else
				_nRow_ = This._RowOfV(_nV_, _nEndRow_, _nPlotHeight_)
			ok
			
			# Ensure point is within bounds
			_nCol_ = max([_nStartCol_, min([_nEndCol_, _nCol_])])
			_nRow_ = max([_nStartRow_, min([_nEndRow_, _nRow_])])
			
			# Draw the point
			if _nRow_ >= 1 and _nRow_ <= len(@acCanvas) and _nCol_ >= 1 and _nCol_ <= len(@acCanvas[_nRow_])
				@acCanvas[_nRow_][_nCol_] = @cPointChar
			ok
		next

	def _drawPointLabels(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		_nLenHVal_ = len(@anHValues)
		_nLenLabels_ = len(@acPointLabels)

		for i = 1 to _nLenHVal_
			if i <= _nLenLabels_
				_nH_ = @anHValues[i]
				_nV_ = @anVValues[i]
				_cLabel_ = " " + Capitalise(@acPointLabels[i])

				# Calculate point position (same as in _drawPoints)
				if @nHMax = @nHMin
					_nCol_ = _nStartCol_ + floor(_nPlotWidth_ / 2)
				else
					_nCol_ = This._ColOfH(_nH_, _nStartCol_, _nPlotWidth_)
				ok
				
				if @nVMax = @nVMin
					_nRow_ = _nStartRow_ + floor(_nPlotHeight_ / 2)
				else
					_nRow_ = This._RowOfV(_nV_, _nEndRow_, _nPlotHeight_)
				ok

				# Position label right next to the point (1 space to the right)
				_nLabelCol_ = _nCol_ + 1
				_nLabelRow_ = _nRow_

				# Check bounds and draw label
				_nLenLabel_ = len(_cLabel_)

				if _nLabelRow_ >= 1 and _nLabelRow_ <= @nHeight and 
				   _nLabelCol_ >= 1 and _nLabelCol_ + _nLenLabel_ - 1 <= @nWidth
					for j = 1 to _nLenLabel_
						if _nLabelCol_ + j - 1 <= @nWidth
							@acCanvas[_nLabelRow_][_nLabelCol_ + j - 1] = _cLabel_[j]
						ok
					next
				ok
			ok
		next

	def _initCanvas()
		@acCanvas = []
		for i = 1 to @nHeight
			_aRow_ = []
			for j = 1 to @nWidth
				_aRow_ + " "
			next
			@acCanvas + _aRow_
		next

	def _finalizeCanvas()
		_cResult_ = ""
		_nLenCanvas_ = len(@acCanvas)
		for i = 1 to _nLenCanvas_
			_cLine_ = ""
			_nLenCurrent_ = len(@acCanvas[i])
			for j = 1 to _nLenCurrent_
				_cLine_ += @acCanvas[i][j]
			next
			_cResult_ += _cLine_ + nl
		next

		# Remove unnecessary empty lines
		_oTempStr_ = new stzString(_cResult_)
		if @bShowVAxis = 0
			_nPos_ = _oTempStr_.FindFirst(char(10))
			_oTempStr_.RemoveSection(1, _nPos_)
		ok

		_anPos_ = _oTempStr_.FindAll(char(10))
		if len(_anPos_) > 0
			_nPos_ = _anPos_[len(_anPos_)-1]
			_oTempStr_.RemoveSection(_nPos_, _oTempStr_.NumberOfChars())
		ok

		# Adjust markers when grid is active
		if @bShowGrid
			_oTempStr_.ReplaceMany([@cHTickChar, @cVTickChar], @cHTickChar2)
		ok

		# Add H and V letters if required (showing as X/Y for backward compatibility)

		if @bShowHLetter and @bShowHAxis
			# Place X letter at the end of horizontal axis
			# @split, NOT split. RING'S BARE split() TRIMS THE LEADING WHITESPACE
			# OF THE FIRST PIECE, so decomposing the canvas this way silently pulled
			# row one back to column 1 -- and row one is the row carrying the
			# vertical arrow. That is why the arrow never stood over its own axis
			# while every row below it kept its indent, and why indenting the arrow
			# from a known column could not fix it: the damage happened here, after
			# the drawing was already correct.
			_cResult_ = _oTempStr_.Content()
			_acLines_ = @split(_cResult_, nl)
			
			# THE Y LETTER IS PLACED ONCE, by the Replace below, which also extends
			# the axis to make room for it. A second append here gave every scatter
			# plot TWO Y labels -- the same duplication the X letter had.
			
			_cResult_ = ""
			_nLinesLen_4 = len(_acLines_)
			for i = 1 to _nLinesLen_4
				_cResult_ += _acLines_[i]
				if i < len(_acLines_)
					_cResult_ += nl
				ok
			next
			_oTempStr_ = new stzString(_cResult_)
			# Place Y letter at the end of horizontal axis
			_oTempStr_.Replace(@cHArrowChar, @cHAxisChar + @cHAxisChar + @cHArrowChar + " Y")
		ok

		if @bShowVLetter and @bShowVAxis
			# Place X letter at the top of vertical axis
			_cResult_ = _oTempStr_.Content()
			_acLines_ = @split(_cResult_, nl)
			
			# THE X LETTER IS PLACED ONCE, further down, on the ASSEMBLED string.
			#
			# A second block used to prepend it here as well, so every scatter plot
			# carried TWO X rows -- indented differently, because this one measured
			# the arrow inside the line array while the other measured it in the
			# finished text. One letter, one place.
			
			_cResult_ = ""
			_nLinesLen_ = len(_acLines_)
			for i = 1 to _nLinesLen_
				_cResult_ += _acLines_[i]
				if i < len(_acLines_)
					_cResult_ += nl
				ok
			next
			_oTempStr_ = new stzString(_cResult_)
			# Place X letter at the end of vertical axis
			_nPos_ = _oTempStr_.FindFirst(@cVArrowChar)
			_oTempStr_.InsertAt(1, RepeatChar(" ", _nPos_-1) + "X" + char(10))

			_oTempStr_.Replace(@cVArrowChar, @cVArrowChar + char(10) + RepeatChar(" ", _nPos_-1) + @cVAxisChar)
		ok


		_cResult_ = _oTempStr_.Content()
		return _cResult_
