
func isDirectory(cDir)
	return dirExists(cDir)

#------------------#
#  THE MAIN CLASS  #
#------------------#

class StzExtCodeXT

	# Configuring supported languages with full paths

	@aLanguages = [

	:python = [
		:Name = "Python",
		:Type = "interpreted",
		:Extension = ".py",
		:Runtime = "python",
		:AlternateRuntimes = ["python3", "py"],
		:ResultFile = "pyresult.txt",
		:CustomPath = "C:\\Python312\\python.exe",  # Replace with your Python path
		:TransFunc = $cPyToRingTransFunc,
		:Cleanup = TRUE
	],

	:R = [
		:Name = "R",
		:Type = "interpreted",
		:Extension = ".R",
		:Runtime = "Rscript",
		:AlternateRuntimes = ["R"],
		:ResultFile = "rresult.txt",
		:CustomPath = "C:\\R\\R-4.4.2\\bin\\Rscript.exe",  # Replace with your R path
		:TransFunc = $cRToRingTransFunc,
		:Cleanup = FALSE
        ],

        :julia = [
		:Name = "Julia",
		:Type = "interpreted",
		:Extension = ".jl",
		:Runtime = "julia",
		:AlternateRuntimes = [],
		:ResultFile = "jlresult.txt",
		:CustomPath = "C:\\Users\\MSI\\.julia\\juliaup\\julia-1.11.3+0.x64.w64.mingw32\\bin\\julia.exe",  # Replace with your Julia path
		:TransFunc = $cJuliaToRingTransFunc,
		:Cleanup = FALSE
	],

	:C = [
		:Name = "C",
		:Type = "compiled",
		:Extension = ".c",
		:Runtime = "gcc",
		:AlternateRuntimes = [],
		:ResultFile = "cresult.txt",
		:CustomPath = "C:\\msys64\\ucrt64\\bin\\gcc.exe",  # Replace with your GCC path
		:TransFunc = $cCToRingTransFunc,
		:Cleanup = FALSE,
		CaptureBuildErrors = TRUE
	],

	:nodejs = [
		:Name = "NodeJS",
		:Type = "interpreted",
		:Extension = ".js",
		:Runtime = "node",
		:AlternateRuntimes = ["nodejs"],
		:ResultFile = "jsresult.txt",
		:CustomPath = "D:\\nodejs\\node.exe",  # Replace with your Node.js path
		:TransFunc = $cNodeJSToRingTransFunc,
		:Cleanup = FALSE
	],

	:prolog = [
		:Name = "SWI-Prolog",
		:Type = "interpreted",
		:Extension = ".pl",
		:Runtime = "swipl",
		:AlternateRuntimes = ["prolog"],
		:ResultFile = "plresult.txt",
		:CustomPath = "D:\\swipl\\bin\\swipl.exe",  # Update to your actual path
		:TransFunc = $cPrologToRingTransFunc,
		:Cleanup = FALSE,
		:ExtraArgs = "-q -g main -t halt"   # Quiet mode, call main/0, halt after execution
	]

	]

	# Other attributes

	@aCallTrace = []
	@cLanguage = ""
	@cCode = ""
	@cSourceFile = ""  # Auto-named like 'temp.py', 'temp.go', etc.
	@cLogFile = "log.txt"
	@cResultFile = ""  # Set from @aLanguages[@cLanguage][:ResultFile]
	@cResultVar = "res"  # Configurable with SetResVar(). Should occur in the user code provided to SetCode()
	@nStartTime = 0
	@nEndTime = 0
	@bVerbose = FALSE  # Toggle with SetVerbose()

	@cTempDir = "temp"  # Default temp directory
	@aCreatedFiles = [] # Track all created files
	@cSessionID = "" # Unique session ID to prevent file conflicts

	  #-------------------------------------------------#
	 #  CREATING AN INSTANCE OF THE EXTERNAL LANGUAGE  #
	#-------------------------------------------------#

	def Init(cLang)

		if NOT This.IsLanguageSupported(cLang)
			stzraise("Language '" + cLang + "' is not supported")
		ok

		@cLanguage = lower(cLang)
		This.GenerateSessionID()

		# Get language-specific file paths

		@cSourceFile = This.GetFilePath("temp" + @aLanguages[@cLanguage][:extension], @cLanguage)
		@cResultFile = This.GetFilePath(@aLanguages[@cLanguage][:ResultFile], @cLanguage)
		@cLogFile = This.GetFilePath("log.txt", @cLanguage)

	def SetTempDir(cDir)

		@cTempDir = cDir

		# Create directory if it doesn't exist

		if NOT isDirectory(@cTempDir)
			system("mkdir " + @cTempDir)
		ok

	def SetLanguageTempDir(cLang, cDir)

		if NOT This.IsLanguageSupported(cLang)
			stzraise("Language '" + cLang + "' is not supported")
		ok

		@aLanguages[lower(cLang)][:TempDir] = cDir

		# Create directory if it doesn't exist

		if NOT isDirectory(cDir)
			system("mkdir " + cDir)
		ok

	def GetTempDir(cLang)

		if cLang = ""
			return @cTempDir

		else
			if NOT This.IsLanguageSupported(cLang)
				stzraise("Language '" + cLang + "' is not supported")
			ok

			cLang = lower(cLang)

			if @aLanguages[cLang][:TempDir] != NULL
				return @aLanguages[cLang][:TempDir]

			else
				return @cTempDir
			ok
		ok

	def GenerateSessionID()
		cChars = "abcdefghijklmnopqrstuvwxyz0123456789"
		cID = ""

		for i = 1 to 8
			cID += cChars[ ARandomNumberBetween(1, len(cChars)) ]
		next

		@cSessionID = cID
		return cID

	def GetFilePath(cFileName, cLang)
		cTempDir = This.GetTempDir(cLang)
    
		# Make sure temp directory exists

		if NOT isDirectory(cTempDir)
			system("mkdir " + cTempDir)
		ok
    
		# If session ID is not set, generate one

		if @cSessionID = ""
			This.GenerateSessionID()
		ok
    
		# Include session ID in the filename

		n = ring_substr1(reverse(cFileName), ".")
		nPos = len(cFileName) - n
		cBaseName = left(cFileName, nPos)

		cExt = right(cFileName, n)
		cNewFileName = cBaseName + "_" + @cSessionID + cExt
    
		# Return full path

		if isWindows()
			return cTempDir + "\\" + cNewFileName
		else
			return cTempDir + "/" + cNewFileName
		ok

	def IsLanguageSupported(cLang)
		return @aLanguages[lower(cLang)] != NULL

	def SetRuntimePath(cPath)
		# Set custom runtime path for the language
		@aLanguages[@cLanguage][:CustomPath] = cPath

	def SetCode(cNewCode)
		@cCode = cNewCode

	def @(cNewCode)
		@cCode = cNewCode

	def SetVerbose(bVerbose)
		@bVerbose = bVerbose

	def SetResultVar(cResVar)
		if NOT cResVar = ""
			@cResultVar = cResVar
		ok

	  #--------------------------------------------------#
	 #  PREPARING THE EXTERNAL SCRIPT AND EXECUTING IT  #
	#--------------------------------------------------#

	def Prepare()
		This.Cleanup()
		This.WriteToFile(@cSourceFile, This.PrepareSourceCode())

	def Execute()
		This.Prepare()

		if @cCode = ""
			return
		end

		if NOT fexists(@cSourceFile)
			stzraise("Source file '" + @cSourceFile + "' not found!")
		ok

		@nStartTime = clock()

		cRuntime = @aLanguages[@cLanguage][:CustomPath]

		if cRuntime = ""
			cRuntime = @aLanguages[@cLanguage][:Runtime]
		ok

		cScriptFile = This.GetFilePath("run", @cLanguage)

		if isWindows()

			cScriptFile += ".bat"
			cScriptContent = "@echo off" + NL

			if @aLanguages[@cLanguage][:Type] = "compiled"

				# For compiled languages (like C)
				# Get the full path to the executable that will be created

				cExePath = This.GetFilePath(@aLanguages[@cLanguage][:ExecutableName], @cLanguage)

				# Set dynamic compiler flags with the correct output path

				cCompilerFlags = "-o " + cExePath
            
				# Compile and run with corrected path references

				cScriptContent += cRuntime + " " + cCompilerFlags + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
				"if %ERRORLEVEL% EQU 0 " + cExePath + " >> " + @cLogFile + " 2>&1" + NL

			else # Interpreted languages (Python, R, Julia, and SWI-Prolog)

				cExtraArgs = ""

				if @aLanguages[@cLanguage][:ExtraArgs] != NULL
					cExtraArgs = @aLanguages[@cLanguage][:ExtraArgs]
				ok

				cScriptContent += cRuntime + " " + cExtraArgs + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
			ok

			cScriptContent += "exit %ERRORLEVEL%"

		else # Other OS then Windows

			cScriptFile += ".sh"
			cScriptContent = "#!/bin/bash" + NL

			if @aLanguages[@cLanguage][:Type] = "compiled"

				# Get the full path to the executable that will be created
				cExePath = This.GetFilePath(@aLanguages[@cLanguage][:ExecutableName], @cLanguage)
            
				# Set dynamic compiler flags with the correct output path
				cCompilerFlags = "-o " + cExePath
            
				# Compile and run with corrected path references
				cScriptContent += cRuntime + " " + cCompilerFlags + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
				"if [ $? -eq 0 ]; then " + cExePath + " >> " + @cLogFile + " 2>&1; fi" + NL

			else

				# Interpreted languages (Python, R, Julia, and SWI-Prolog)
				cScriptContent += cRuntime + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
			ok

			cScriptContent += "exit $?"
		ok

		This.WriteToFile(cScriptFile, cScriptContent)

		cCmd = cScriptFile
		system(cCmd)

		@nEndTime = clock()

		cLog = This.ReadFile(@cLogFile)

		if cLog = NULL
			cLog = "Log file '" + @cLogFile + "' not found or unreadable"
		ok

		This.RecordExecution(cLog, 0)

		if @bVerbose
			? "Command: " + cCmd
			? "Log: " + cLog
			? "Working Directory: " + currentdir()
			? "Source File Exists: " + fexists(@cSourceFile)
			? "Result File Exists: " + fexists(@cResultFile)
		ok

		if NOT fexists(@cResultFile)
			stzraise("Result file '" + @cResultFile + "' not created. Log: " + cLog)
		ok

		if fexists(cScriptFile)
			remove(cScriptFile)
		ok
	
		#< @FunctionAlternativeForms

		def Run()
			This.Execute()

		def Exec()
			This.Execute()

		#>

	def CleanupFiles()

		# Attempt to remove all created files

		aFailedRemovals = []
	    
		for cFile in @aCreatedFiles
			try
				if fexists(cFile)
					remove(cFile)
				ok
			catch
				aFailedRemovals + cFile
			done
		next
	    
		# Special handling for compiled languages - executables

		if @aLanguages[@cLanguage][:Type] = "compiled"

			cExe = @aLanguages[@cLanguage][:ExecutableName]

			cExt = ""
			if isWindows()
				cExt = ".exe"
			ok

			cExeFile = This.GetFilePath(cExe + cExt, @cLanguage)
	        
			try
				if fexists(cExeFile)
					remove(cExeFile)
				ok
			catch
				aFailedRemovals + cExeFile
			done
		ok
	    
		# Report failures

		if len(aFailedRemovals) > 0 and @bVerbose

			? "Warning: Failed to remove some temporary files:"

			for cFile in aFailedRemovals
				? " - " + cFile
			next
		ok
	    
		# Reset the file list

		@aCreatedFiles = []


		def Cleanup()
        		This.CleanupFiles()

	def GetRemainingTempFiles()

		aRemainingFiles = []

		for cFile in @aCreatedFiles
			if fexists(cFile)
				aRemainingFiles + cFile
			ok
		next

		return aRemainingFiles

	def CleanupRequired()
		bResult = @aLanguages[@cLanguage][:Cleanup]
		return isNumber(bResult) and bResult = TRUE

	def LastCallDuration()

		if len(@aCallTrace) > 0
			return @aCallTrace[len(@aCallTrace)][:duration]
		end

		return 0


		def Duration()
			return This.LastCallDuration()

	def CallTrace()
		return @aCallTrace

		def Trace()
			return @aCallTrace

	def Result()

		if NOT fexists(@cResultFile)

			stzraise("File does not exist!" + NL + NL +
			"Log content (from " + @cLanguage + " console): " + NL +
			"------------------" + copy("-", len(@cLanguage)) + "----------" + NL + NL +
			This.Log() + NL + NL +
			"------------------------" + NL +
			"End of log file content.")

		ok

		cContent = This.ReadFile(@cResultFile)

		if cContent = ""
			return ""
		ok

		try
			cContent = ring_substr2(cContent, "\n", NL)
			cCode = 'result = ' + cContent

			eval(cCode)

			if CleanupRequired()
				This.CleanupFiles()
			ok

			return result

		catch
			? "Eval error: " + CatchError() + NL
			? "Log content: " + This.Log()
			return cContent

		done

	def FileName()
		return @cResultFile

	def ResultVar()
		return @cResultVar

	def RuntimePath()
		return @aLanguages[@cLanguage][:CustomPath]

	def IsVerbose()
		return @bVerbose

	def SetLogFile(cFileName)
		@cLogFile = cFileName

	def LogFile()
		return @cLogFile

		def LogFileName()
			return @cLogFile

	def LogFileContent()
		return This.ReadFile(@cLogFile)

		def Log()
			return This.LogFile()

	def Code()
		return @cCode

	def SourceFile()
		return @cSourceFile

	def SourceFileContent()
		if NOT fexists(@cSourceFile)
			return ""
		ok
		return This.ReadFile(@cSourceFile)

	#====== PRIVATE METHODS ======#

	def WriteToFile(cFile, cContent)

		# Track created file

		if NOT ring_find(@aCreatedFiles, cFile)
			@aCreatedFiles + cFile
		ok

		# Create directory if needed

		cSlash = "/"
		if isWindows()
			cSlash = "\\"
		ok

		nLast = len(cFile)
		n = ring_substr1(reverse(cFile), cSlash)
	
		if n > 0
			nLast = len(cFile) - n
		ok

		cDir = left(cFile, nLast)

		if cDir != "" AND NOT isDirectory(cDir)
			system("mkdir " + cDir)
		ok

		# Write the content

		fp = fopen(cFile, "w")
		fwrite(fp, cContent)
		fclose(fp)

	def ReadFile(cFile)
		if NOT fexists(cFile)
			return NULL
		ok

		fp = fopen(cFile, "r")
		if fp = NULL
			return NULL
		end

		cContent = fread(fp, fsize(fp))
		fclose(fp)

		return cContent

	def BuildCommand()

		# Not used with batch approach, kept for compatibility

		if @aLanguages[@cLanguage][:type] = "interpreted"

			cCmd = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile

			if @aLanguages[@cLanguage][:customPath] != ""
				cCmd = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
			ok

			return cCmd

		but @aLanguages[@cLanguage][:type] = "compiled"

			cCmd = @aLanguages[@cLanguage][:Runtime] + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile
			return cCmd
		ok

		stzraise("Unsupported language type for " + @cLanguage)

	def RecordExecution(cLog, nExitCode)

		cMode = @aLanguages[@cLanguage][:type]

		if cMode != "interpreted" and cMode != "compiled"
			stzraise("Incorrect language type! Must be 'interpreted' or 'compiled'.")
		ok

		@aCallTrace + [
			:Language = @cLanguage,
			:Timestamp = TimeStamp(),
			:Duration = (@nEndTime - @nStartTime) / clockspersecond(),
			:Log = cLog,
			:Exitcode = nExitCode,
			:Mode = cMode
		]

	def PrepareSourceCode()

		cTransFunc = @aLanguages[@cLanguage][:TransFunc]

		#-------------------------
		 if @cLanguage = "python"
		#-------------------------

			return $cPyToRingTransFunc + '
# Main code
print("Python script starting...")
' + @cCode + '
print("Data before transformation:", ' + @cResultVar + ')
transformed = transform_to_ring(' + @cResultVar + ')
print("Data after transformation:", transformed)
with open("' + @cResultFile + '", "w") as f:
    f.write(transformed)
print("Data written to file")
'

		#---------------------
		 but @cLanguage = "r"
		#---------------------

			return $cRToRingTransFunc + '

			# Main code
			cat("R script starting...\n")
			' + @cCode + '
			transformed <- transform_to_ring(' + @cResultVar + ')
			writeLines(transformed, "' + @cResultFile + '")
			cat("Data written to file\n")
			'

		#-------------------------
		 but @cLanguage = "julia"
		#-------------------------

			return $cJuliaToRingTransFunc + '

			# Main code
			println("Julia script starting...")
			' + @cCode + '
			transformed = transform_to_ring(' + @cResultVar + ')
			println("Data before transformation: ", ' + @cResultVar + ')
			println("Data after transformation: ", transformed)
			open("' + @cResultFile + '", "w") do f
			    write(f, transformed)
			end
			println("Data written to file")
			'

		#---------------------
		 but @cLanguage = "c"
		#---------------------

			return $cCToRingTransFunc + '

			int main() {
			    printf("C program starting...\n");
			    ' + @cCode + '
			    transform_to_ring(res, "' + @cResultFile + '");
			    printf("Data written to file.\n");
			    return 0;
			}
			'

		#--------------------------
		 but @cLanguage = "nodejs"
		#--------------------------

			return 'const { transform_to_ring, writeResultToFile } = (() => {

			' + $cNodeJSToRingTransFunc + '
			    return { transform_to_ring, writeResultToFile };
			})();
			
			console.log("NodeJS script starting...");
			' + @cCode + '
			console.log("Writing results to file...");
			writeResultToFile(' + @cResultVar + ', "' + @cResultFile + '");
			console.log("Data written to file");
			'

	#---------------------------
   	 but @cLanguage = "prolog"
	#---------------------------

		return '

		:- use_module(library(lists)).
		:- use_module(library(apply)).
		
		' + $cPrologToRingTransFunc + '
		
		' + @cCode + '
		
		% Main predicate called by the runtime
		main :-
		    writeln("SWI-Prolog program starting..."),
		    ' + @cResultVar + '(Result),
		    writeln("Transforming result..."),
		    transform_to_ring(Result, "' + @cResultFile + '"),
		    writeln("Data written to file").
		'

	#------
          else
	#------

            stzraise("Not implemented yet for this language!")
        ok
