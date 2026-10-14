#------------------------------------------------------------------#
#         SOFTANZA LIBRARY - QML CODE (EXTERNAL RUNTIME)            #
#------------------------------------------------------------------#
#                                                                  #
#  Description : Shells QML markup out to Qt's standalone `qml` /  #
#                `qmlscene` runtime so a Softanza application can  #
#                show a QML view without depending on Qt at the    #
#                library level (no qApp / RingQML binding).        #
#                                                                  #
#                Follows the same shape as stzDotCode (Graphviz):  #
#                  - write source to a temp file under temp/       #
#                  - invoke the runtime as a child process         #
#                  - capture stdout/stderr + exit code + duration  #
#                                                                  #
#                Reach for `XQml()` / `StzQmlCodeQ()` rather than  #
#                Ring's qApp{} binding, which Softanza no longer   #
#                ships against -- the library is engine-only.      #
#                                                                  #
#  Version     : V0.9 (2026-06)                                    #
#  Author      : Mansour Ayouni (kalidianow@gmail.com)             #
#------------------------------------------------------------------#

# Path resolution mirrors stzDotCode: honour $aStzLibConfig[:QmlPath]
# if the user has set it, otherwise fall back to a sensible default.

if HasKey($aStzLibConfig, :QmlPath) and $aStzLibConfig[:QmlPath] != ""
	$cQmlPath = $aStzLibConfig[:QmlPath]
else
	# Common Windows install path for the Qt standalone QML runtime.
	# On POSIX the default is usually just "qml" on PATH.
	$cQmlPath = "qml"
ok

func StzQmlCodeQ()
	return new stzQmlCode

	func XQml()
		return new stzQmlCode()

	func QmlQ()
		return new stzQmlCode()

# Shells a piece of QML out to Qt's standalone qml runtime as a child process, and captures its output and duration.
#
# Write the QML with SetCode, run it with Execute (which writes temp/temp.qml and starts the
# runtime) and read what it printed with Result. It keeps the library free of any Qt binding: the
# runtime is found by the name qml, by $aStzLibConfig[:QmlPath] or by SetQmlPath. It does not read
# an exit code, and IsRuntimeAvailable only checks that a path is configured. Use new stzQmlCode()
# with parentheses so that Init creates the temp folder. A QML view opens a window: the qml runtime
# is not installed on the machine of this documentation run, so Execute was exercised only against a
# path that does not exist.
#
#   receiver   o1 = new stzQmlCode()
#   example    o1.SetCode("import QtQuick 2.0" + char(10) + "Item { }")
#              ? o1.WasExecuted()
#              #--> 0
#              ? o1.TempSourcePath()
#              #--> temp/temp.qml
#   see        stzDotCode, stzExterCode
class stzQmlCode from stzObject

	@cQmlCode    = ""
	@cQmlPath    = $cQmlPath
	@cTempDir    = "temp"
	@cTempFile   = "temp.qml"
	@cLogFile    = "qmllog.txt"
	@nStartTime  = 0
	@nEndTime    = 0
	@nExitCode   = 0
	@cLastOutput = ""
	@bVerbose    = 0
	@bExecutedAtLeastOnce = 0

	# Creates the temp folder in the current folder where the QML source and log will be written, if it is not there.
	#
	#   returns    nothing; the object is built
	#   warning    a paren-less new (the factories StzQmlCodeQ and XQml use it) skips Init, so the
	#              folder is then created only by Execute and EnsureDirectories, and WriteSource
	#              alone raises R35 when it is missing
	#   see        EnsureDirectories, SetCode
	def Init()
		This.EnsureDirectories()

	# Stores the QML source text to run; nothing is written to disk until WriteSource or Execute.
	#
	#   pcQml      the QML markup, a text
	#   returns    nothing
	#   warning    a value that is not text raises an error
	#   see        Source, Execute
	# ----- Setting / reading the QML source -------------------------
	def SetCode(pcQml)
		if NOT isString(pcQml)
			StzRaise("stzQmlCode.SetCode: pcQml must be a string.")
		ok
		@cQmlCode = pcQml

		# Stores the QML source text to run, as the call with the longer name does.
		#
		#   pcQml      the QML markup, a text
		#   returns    nothing
		#   warning    a value that is not text raises an error
		#   see        SetCode, Source
		def @(pcQml)
			This.SetCode(pcQml)

		# Stores the QML source text to run, as SetCode does; it does not return the code.
		#
		#   pcQml      the QML markup, a text
		#   returns    nothing
		#   warning    unlike the Code of the other external-code classes, this one is a setter:
		#              read the text with Source
		#   see        SetCode, Source
		def Code(pcQml)
			This.SetCode(pcQml)

	# Returns the QML source text that was set; empty before SetCode.
	#
	#   returns    a text
	#   see        SetCode
	def Source()
		return @cQmlCode

	# Sets the program that runs the QML, in place of the one found by the name qml or by $aStzLibConfig[:QmlPath].
	#
	#   pcPath     the path of the qml runtime, a non-empty text
	#   returns    nothing
	#   warning    the path is not checked: a wrong one shows only in the log of Execute; an empty
	#              or non-text path raises an error
	#   see        QmlPath, IsRuntimeAvailable
	# ----- Path resolution + sanity --------------------------------
	def SetQmlPath(pcPath)
		if NOT isString(pcPath) or pcPath = ""
			StzRaise("stzQmlCode.SetQmlPath: pcPath must be a non-empty string.")
		ok
		@cQmlPath = pcPath

	# Returns the program that will run the QML.
	#
	#   returns    a text; qml by default
	#   see        SetQmlPath
	def QmlPath()
		return @cQmlPath

	# TRUE if a runtime path is configured.
	#
	#   returns    TRUE or FALSE
	#   warning    it never looks for the program: it answered TRUE for the path C:/nowhere/qml.exe,
	#              which does not exist
	#   see        SetQmlPath, Execute
	def IsRuntimeAvailable()
		# We cannot reliably probe an external binary cross-platform
		# without spawning it; treat a configured non-empty path as
		# available. Callers that need a hard check should run
		# Execute() and inspect ExitCode().
		return @cQmlPath != ""

	# Creates the temp folder in the current folder if it is missing.
	#
	#   returns    nothing
	#   warning    starts the mkdir command through the system call
	#   see        Init, WriteSource
	# ----- Filesystem prep -----------------------------------------
	def EnsureDirectories()
		if NOT isdir(@cTempDir)
			# StzSystemSilentXT mirrors what stzFolder uses.
			if isWindows()
				StzSystemSilentXT("cmd.exe",
					[ "/c", "mkdir", @cTempDir ])
			else
				StzSystemSilentXT("mkdir",
					[ "-p", @cTempDir ])
			ok
		ok

	# Returns where the QML source is written, temp/temp.qml in the current folder.
	#
	#   returns    a text
	#   see        LogPath, WriteSource
	def TempSourcePath()
		return @cTempDir + "/" + @cTempFile

	# Returns where the runtime's output is captured, temp/qmllog.txt in the current folder.
	#
	#   returns    a text
	#   see        TempSourcePath, Log
	def LogPath()
		return @cTempDir + "/" + @cLogFile

	# Writes the QML source to the temp file, replacing what was there.
	#
	#   returns    nothing
	#   warning    raises R35 when the temp folder does not exist; the file is deleted by
	#              CleanupTemp
	#   see        Execute, TempSourcePath
	# ----- Execution -----------------------------------------------
	def WriteSource()
		write(This.TempSourcePath(), @cQmlCode)

	# Writes the QML source, starts the qml runtime on it and captures the output and the time taken.
	#
	#   returns    nothing; read the output with Result
	#   note       not run with a real runtime: the qml runtime is not installed here, so it was run
	#              with the path C:/nowhere/qml.exe, which only produced a path-not-found log
	#   warning    it starts a real program, which for a view opens a window and for a plain script
	#              runs until it ends; the exit code is not read, so a failure shows only as text in
	#              the log; raises an error when no source is set
	#   see        Result, Duration, CleanupTemp
	def Execute()
		if @cQmlCode = ""
			StzRaise("stzQmlCode.Execute: no QML source set.")
		ok
		This.EnsureDirectories()
		This.WriteSource()

		@nStartTime = clock()
		_cCmd_ = '"' + @cQmlPath + '" "' + This.TempSourcePath() + '"' +
		         ' > "' + This.LogPath() + '" 2>&1'
		# Use Softanza's system wrapper rather than Ring's bare system().
		StzSystemSilent(_cCmd_)
		@nEndTime = clock()

		# Capture log + exit code probe.
		if fexists(This.LogPath())
			@cLastOutput = read(This.LogPath())
		else
			@cLastOutput = ""
		ok
		@bExecutedAtLeastOnce = 1

		# Writes the QML source and starts the runtime, as the call with the other name does.
		#
		#   returns    nothing; read the output with Result
		#   note       not run with a real runtime
		#   warning    same warning as Execute
		#   see        Execute, Result
		def Run()
			This.Execute()

		# Writes the QML source and starts the runtime, as the call with the other name does.
		#
		#   returns    nothing; read the output with Result
		#   note       not run with a real runtime
		#   warning    same warning as Execute
		#   see        Execute, Result
		def Exec()
			This.Execute()

	# Returns what the runtime printed during the last run, errors included; empty before a run.
	#
	#   returns    a text
	#   warning    the same text as Log and Trace
	#   see        Log, Execute
	# ----- Result inspection ---------------------------------------
	def Result()
		return @cLastOutput

	# Returns what the runtime printed during the last run, errors included.
	#
	#   returns    a text
	#   warning    the same text as Result and Trace
	#   see        Result, LogPath
	def Log()
		return @cLastOutput

	# Returns what the runtime printed during the last run, errors included.
	#
	#   returns    a text
	#   warning    not a history of runs, unlike Trace in the other external-code classes: it is the
	#              same text as Result
	#   see        Result, Log
	def Trace()
		return @cLastOutput

	# Returns how long the last run took, in seconds; 0 before any run.
	#
	#   returns    a number
	#   see        Execute, WasExecuted
	def Duration()
		if NOT @bExecutedAtLeastOnce
			return 0
		ok
		return (@nEndTime - @nStartTime) / clockspersecond()

	# TRUE if Execute has run at least once.
	#
	#   returns    TRUE or FALSE
	#   see        Execute, Duration
	def WasExecuted()
		return @bExecutedAtLeastOnce

	# Deletes the temp source file and the log file when they exist.
	#
	#   returns    nothing
	#   warning    the temp folder itself stays
	#   see        WriteSource, Execute
	# ----- Cleanup --------------------------------------------------
	def CleanupTemp()
		if fexists(This.TempSourcePath())
			remove(This.TempSourcePath())
		ok
		if fexists(This.LogPath())
			remove(This.LogPath())
		ok
