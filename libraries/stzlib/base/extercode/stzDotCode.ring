
#NOTE You should install Graphiz diagram engine to use this class

# Also, you need to specify the path of the dot.exe command line tool
# in a gloabl hashlist you name $aStzLibConfig that you populate like this:
#    $aStzLibConfig = [
#	:DotPath = "...",
#	...
# ]

if Haskey($aStzLibConfig, :DotPath) and $aStzLibConfig[:DotPath] != ""
    $cDotPath = $aStzLibConfig[:DotPath]
else
    $cDotPath = "d:/Graphviz/bin/dot.exe"
ok

$acDotOutputFormats = [
	"bmp", "canon", "cmap", "cmapx", "cmapx_np",
	"dot", "dot_json", "emf", "emfplus", "eps",
	"fig", "gd", "gd2", "gif", "gv", "imap", "imap_np",
	"ismap", "jpe", "jpeg", "jpg", "json", "json0",
	"kitty", "kittyz", "metafile", "pdf", "pic",
	"plain", "plain-ext", "png", "pov", "ps",
	"ps2", "svg", "svg_inline", "svgz", "tif",
	"tiff", "tk", "vrml", "vt", "vt-24bit", "vt-4up",
	"vt-6up", "vt-8up", "wbmp", "webp", "xdot",
	"xdot1.2", "xdot1.4", "xdot_json"
]

$cDefaultDotOutputFormat = "svg"

func DefaultDiagramOutputFormat()
	return $cDefaultDiagramOutputFormat

func StzDotCodeQ()
	return new stzDotCode

	func XDot()
		return new stzDotCode()

	func GraphvizQ()
		return new stzDotCode()


# Turns Graphviz graph text into a picture file by running the dot program, and can open the picture.
#
# You set the graph in the dot language, choose a format (svg by default; png, pdf and about fifty
# others), and Execute writes the graph to a working file in the temp folder and runs dot, leaving
# the picture in the output folder as diagram_ plus a number. The dot program is taken from
# $aStzLibConfig[:DotPath] or from d:/Graphviz/bin/dot.exe, and SetDotPath overrides it. Graphviz
# must be installed. View opens the picture in the program the system associates with it; it was
# read but not run, because it opens a window. Three defects are recorded in the methods:
# SetOutputFormat refuses upper case, SetOutput does not check, and CleanupAll does not delete the
# picture.
#
#   receiver   o1 = new stzDotCode()
#   example    o1.SetCode("digraph G { a -> b; b -> c; }")
#              o1.SetOutputFormat("dot")
#              o1.Execute()
#              ? StzFindFirst("a -> b", o1.ReadFile(o1.OutputFile())) > 0
#              #--> 1
#   see        stzExterCode, stzSystemCall
class stzDotCode from stzObject
	@cDotCode = ""
	@cOutputFormat = $cDefaultDotOutputFormat
	@cDotPath = $cDotPath
	@cTempDotFile = "temp.dot"
	@cLogFile = "dotlog.txt"
	@cOutputDir = "output"
	@bVerbose = 0
	@nStartTime = 0
	@nEndTime = 0
	@cTempDir = "temp"
	@cLastOutputFile = ""
	@bWasExtecutedAtLeastOnce = 0

	# Builds a Graphviz runner and creates its temp and output folders in the current folder.
	#
	#   returns    nothing; the object is built
	#   see        EnsureDirectories, SetCode
	def Init()
		This.EnsureDirectories()

	# Creates the temp folder and the output folder in the current folder when they are missing.
	#
	#   returns    nothing
	#   see        SetTempDir, Init
	def EnsureDirectories()
		CreateFolderIfInexistant(@cTempDir)
		CreateFolderIfInexistant(@cOutputDir)

	# Stores the Graphviz graph text to draw, in memory only.
	#
	#   pcDotCode   the graph in the dot language, such as digraph G { a -> b
	#   returns     nothing
	#   see         Code, Execute
	def SetCode(pcDotCode)
		@cDotCode = pcDotCode

		# Stores the Graphviz graph text to draw, exactly as SetCode does.
		#
		#   pcDotCode   the graph in the dot language
		#   returns     nothing
		#   see         SetCode, Code
		def @(pcDotCode)
			This.SetCode(pcDotCode)

	# Chooses the picture format Execute asks Graphviz for; an empty text or null returns to svg.
	#
	#   _cFormat_   a format name such as svg, png or pdf, in lower case, surrounding spaces being
	#               ignored
	#   returns     nothing
	#   note        the default is svg
	#   warning     raises an error listing the supported formats for any name not in lower case, so
	#               PNG and Svg are refused although the code means to lower-case them
	#   see         OutputFormat, SetOutput
	def SetOutputFormat(_cFormat_)

		_cFormat_ = trim(_cFormat_)
		if _cFormat_ = "" or StzLower(_cFormat_) = 'null'
			_cFormat_ = $cDefaultDotOutputFormat
		else
			if StzFindFirst(_cFormat_, $acDotOutputFormats) = 0
				stzraise("Unsupported output formats! Only these are supported: " + @@($acDotOutputFormats) + ".")
			ok
		ok

		@cOutputFormat = StzLower(_cFormat_)

		# Chooses the picture format Execute asks Graphviz for, with no check of the name.
		#
		#   _cFormat_   a format name, kept in lower case
		#   returns     nothing
		#   note        SetOutputFormat is the checked form
		#   warning     it accepts a name Graphviz does not know, such as docx, and Execute then
		#               fails
		#   see         SetOutputFormat, OutputFormat
		def SetOutput(_cFormat_)
			@cOutputFormat = StzLower(_cFormat_)

	# Sets the folder that holds the working dot file and the log, creating it.
	#
	#   cDir       the folder path, relative to the current folder or absolute
	#   returns    nothing
	#   see        TempDir, EnsureDirectories
	def SetTempDir(cDir)
		@cTempDir = cDir
		This.EnsureDirectories()

	# Returns the folder that holds the working dot file and the log.
	#
	#   returns    a text; temp by default
	#   see        SetTempDir
	def TempDir()
		return @cTempDir

	# Sets the full path of the Graphviz dot program used by Execute.
	#
	#   cPath      the full path of dot.exe
	#   returns    nothing
	#   warning    the path is not checked, so a wrong one shows only when Execute fails
	#   see        Execute
	def SetDotPath(cPath)
		@cDotPath = cPath

	# Turns on or off the report that Execute prints after a run: dot path, format, output file and exit code.
	#
	#   bVerbose   1 to print the report, 0 to keep quiet
	#   returns    nothing
	#   see        IsVerbose, Execute
	def SetVerbose(bVerbose)
		@bVerbose = bVerbose

	# Writes the graph to the temp folder, runs Graphviz on it and leaves the picture in the output folder as diagram_ plus a number.
	#
	#   returns    nothing; read the picture path with OutputFile
	#   note       the file name carries the processor clock, so each run makes a new file and old
	#              ones are kept
	#   warning    with no code set it only clears the temp files and returns; it raises an error
	#              quoting Graphviz when the graph text has a syntax error or dot is missing; the
	#              call waits at most 30 seconds
	#   see        OutputFile, View, Duration, SetOutputFormat
	def Execute()
		This.EnsureDirectories()
		This.Cleanup()
		
		if @cDotCode = ""
			return
		ok
	
		@nStartTime = clock()
	
		# Generate unique filename with timestamp IN OUTPUT FOLDER
		_cTimestamp_ = "" + clock()
		_cOutputFile_ = NormalizePath(@cOutputDir + "/diagram_" + _cTimestamp_ + "." + @cOutputFormat)
		_cTempDotPath_ = NormalizePath(@cTempDir + "/" + @cTempDotFile)
	
		# Store for View() to use
		@cLastOutputFile = _cOutputFile_
	
		# Write dot code to temp file
		This.WriteToFile(_cTempDotPath_, @cDotCode)
	
		# Build arguments list
		_aArgs_ = [
			"-T" + @cOutputFormat,
			_cTempDotPath_,
			"-o",
			_cOutputFile_
		]
	
		# Execute using stzSystemCall
		_oCall_ = new stzSystemCall(@cDotPath)
		_oCall_.SetArgs(_aArgs_)
		_oCall_.HideConsole()
		_oCall_.WithTimeout(30000)
		_oCall_.Run()
	
		@nEndTime = clock()
	
		if @bVerbose
			? "Dot path: " + @cDotPath
			? "Output format: " + @cOutputFormat
			? "Output file: " + _cOutputFile_
			? "Exit code: " + _oCall_.ExitCode()
			if _oCall_.HasError()
				? "Error: " + _oCall_.Error()
			ok
		ok
	
		if NOT _oCall_.Succeeded() or NOT fexists(_cOutputFile_)
			_cError_ = "Graphviz dot command failed."
			if _oCall_.HasError()
				_cError_ += " Error: " + _oCall_.Error()
			ok
			if NOT fexists(_cOutputFile_)
				_cError_ += " Output file not created: " + _cOutputFile_
			ok
			stzraise(_cError_)
		ok
	
		@bWasExtecutedAtLeastOnce = 1

		# Draws the graph, exactly as Execute does.
		#
		#   returns    nothing; read the picture path with OutputFile
		#   warning    same as Execute
		#   see        Execute, OutputFile
		def Run()
			This.Execute()

		# Draws the graph, exactly as Execute does.
		#
		#   returns    nothing; read the picture path with OutputFile
		#   warning    same as Execute
		#   see        Execute, OutputFile
		def Exec()
			This.Execute()

		# Opens the last picture in the program the system associates with its format, drawing it first if nothing was drawn yet.
		#
		#   returns    nothing
		#   warning    not run here: it opens a window on the screen
		#   see        Execute, OutputFile
		def View()
			if NOT @bWasExtecutedAtLeastOnce
				This.Execute()
			ok
		
			if @cLastOutputFile = "" or NOT fexists(@cLastOutputFile)
				stzraise("Output file does not exist: " + @cLastOutputFile)
			ok
			
			_oSysCal_ = new stzSystemCall("cmd.exe")
			_oSysCal_.OpenFile(@cLastOutputFile)

		# Opens the last picture in the associated program, as View does.
		#
		#   returns    nothing
		#   warning    not run here: it opens a window on the screen
		#   see        View
		def Display()
			This.View()

		# Opens the last picture in the associated program, as View does.
		#
		#   returns    nothing
		#   warning    not run here: it opens a window on the screen
		#   see        View
		def Visualise()
			This.View()

	# Draws the graph, then opens the picture in the associated program.
	#
	#   returns    nothing
	#   warning    not run here: it opens a window on the screen
	#   see        Execute, View
	def ExecuteAndView()
		This.Execute()
		This.View()

		# Draws the graph, then opens the picture, exactly as ExecuteAndView does.
		#
		#   returns    nothing
		#   warning    not run here: it opens a window on the screen
		#   see        ExecuteAndView
		def RunAndView()
			This.ExecuteAndView()

		# Draws the graph, then opens the picture, exactly as ExecuteAndView does.
		#
		#   returns    nothing
		#   warning    not run here: it opens a window on the screen
		#   see        ExecuteAndView
		def ExecAndView()
			This.ExecuteAndView()

		def RunXT()
			This.ExecuteAndView()

		def ExecuteXT()
			This.ExecuteAndView()

		def ExecXT()
			This.ExecuteAndView()

	# Returns the path of the picture made by the last run, such as output/diagram_3399.svg.
	#
	#   returns    a text; empty before any run
	#   warning    the number in the name changes at every run
	#   see        Execute, View
	def OutputFile()
		return @cLastOutputFile

	# Returns the picture format that the next run will ask for.
	#
	#   returns    a text; svg by default
	#   see        SetOutputFormat
	def OutputFormat()
		return @cOutputFormat

	# Returns the graph text set for drawing.
	#
	#   returns    a text; empty before SetCode
	#   see        SetCode
	def Code()
		return @cDotCode

	# Returns how long the last run took, in seconds.
	#
	#   returns    a number; 0 before any run
	#   see        Execute
	def Duration()
		if @nEndTime > 0 and @nStartTime > 0
			return (@nEndTime - @nStartTime) / clockspersecond()
		ok
		return 0

	# Returns the text of the log file in the temp folder.
	#
	#   returns    a text; empty when there is no log file
	#   warning    nothing in this class writes that file, so it reads empty after any run
	#   see        Execute
	def Log()
		_cLogPath_ = @cTempDir + "/" + @cLogFile
		if NOT fexists(_cLogPath_)
			return ""
		ok
		return This.ReadFile(_cLogPath_)

	# TRUE if Execute prints its report after each run.
	#
	#   returns    TRUE or FALSE
	#   see        SetVerbose
	def IsVerbose()
		return @bVerbose

	# Deletes the working dot file and the log file from the temp folder; the pictures stay.
	#
	#   returns    nothing
	#   see        CleanupAll, Execute
	def Cleanup()
		try
			_cTempDotPath_ = @cTempDir + "/" + @cTempDotFile
			_cLogPath_ = @cTempDir + "/" + @cLogFile
			
			if fexists(_cTempDotPath_)
				remove(_cTempDotPath_)
			ok
			if fexists(_cLogPath_)
				remove(_cLogPath_)
			ok
		catch
		done

	# Removes the working files only, although it was meant to remove the last picture too.
	#
	#   returns    nothing
	#   warning    the picture stays: the code misspells its output-folder variable, the error is
	#              swallowed, and it looks for diagram.svg rather than the numbered file Execute
	#              makes
	#   see        Cleanup
	def CleanupAll()
		This.Cleanup()
		try
			_cOutputFile_ = @cOutputDire + "/" + "diagram." + @cOutputFormat
			if fexists(_cOutputFile_)
				remove(_cOutputFile_)
			ok
		catch
		done

	# Writes a text to a file, replacing any earlier content.
	#
	#   cFile        the path of the file to write
	#   _cContent_   the text to write
	#   returns      nothing
	#   see          ReadFile
	def WriteToFile(cFile, _cContent_)
		_fp_ = fopen(cFile, "w")
		fwrite(_fp_, _cContent_)
		fclose(_fp_)

	# Returns the whole text of a file.
	#
	#   cFile      the path of the file to read
	#   returns    a text; empty when the file does not exist or cannot be opened
	#   see        WriteToFile
	def ReadFile(cFile)
		if NOT fexists(cFile)
			return ""
		ok
		_fp_ = fopen(cFile, "r")
		if _fp_ = NULL
			return ""
		ok
		_cContent_ = fread(_fp_, fsize(_fp_))
		fclose(_fp_)
		return _cContent_
