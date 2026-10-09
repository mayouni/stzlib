load "stzextercodetransfuncs.ring"

#TODO Ensure temp script and runtime files are all generated in a temp folder

// Check if we have the value by the User code


/* #WARNING
Configure your own external programs paths in a global variable
named $aStzLibConfig where you store your actual paths for the
external programs needed. For example you would write:

$aStzLibConfig[
	:PythonPath = "c:/python/python.exe",
	:JuliaPath = "c:/julia/julia.exe",
	...
]

When Softanza starts, it checks if this gloabl config exists and
uses it to identify the external tools. Otherwise, you should
change the value of $cPythonPath hereafter with your actual paths.
*/

if Haskey($aStzLibConfig, :PythonPath) and $aStzLibConfig[:PythonPath] != ""
    $cPythonPath = $aStzLibConfig[:PythonPath]
else
   $cPythonPath = "d:/python/python-3.13.7/python.exe"
ok

if Haskey($aStzLibConfig, :RPath) and $aStzLibConfig[:RPath] != ""
    $cRPath = $aStzLibConfig[:RPath]
else
    $cRPath = "d:/r/r-4.5.1/bin/rscript.exe"
ok

if Haskey($aStzLibConfig, :JuliaPath) and $aStzLibConfig[:JuliaPath] != ""
    $cJuliaPath = $aStzLibConfig[:JuliaPath]
else
    $cJuliaPath = "d:/julia/julia-1.11.7/bin/julia.exe"
ok

if Haskey($aStzLibConfig, :CPath) and $aStzLibConfig[:CPath] != ""
    $cCPath = $aStzLibConfig[:CPath]
else
    $cCPath = "d:/mingw64/bin/gcc.exe"
ok

if Haskey($aStzLibConfig, :PrologPath) and $aStzLibConfig[:PrologPath] != ""
    $cPrologPath = $aStzLibConfig[:PrologPath]
else
    $cPrologPath = "d:/prolog/swipl-9.9.9/bin/swipl.exe"
ok

if Haskey($aStzLibConfig, :NodeJsPath) and $aStzLibConfig[:NodeJsPath] != ""
    $cNodeJsPath = $aStzLibConfig[:NodeJsPath]
else
    $cNodeJsPath = "d:/nodejs/nodejs-22.20/node.exe"
ok

#------------------#
#  THE MAIN CLASS  #
#------------------#

# Runs a snippet of another language and brings its answer back as a Ring value, through a result file.
#
# Supports python, r, julia, c, prolog and nodejs, found by the paths in $aStzLibConfig or by
# SetRuntimePath. You set the code, which must assign its answer to a variable named res, and
# Execute wraps it with a translator, runs it with the language's program in the current folder, and
# writes the answer as Ring text; Result reads that text back and evaluates it, so a number, a text
# and nested lists cross the boundary. Output and errors of the program go to a log file. Limits
# seen on this machine: the R translator is rejected by R 4.5.1, and the run script is started by
# its bare name, which fails where NoDefaultCurrentDirectoryInExePath is 1. julia, c and prolog were
# not run, their programs being absent.
#
#   receiver   o1 = new stzExterCode("nodejs")
#   example    o1.SetCode("var res = [1, 2, 3].reduce((a, b) => a + b, 0);")
#              o1.Execute()
#              ? o1.Result()
#              #--> 6
#   see        stzDotCode, stzSystemCall
class stzExterCode from stzObject
    # Configuring supported languages with full paths
    @aLanguages = [

        :python = [
            :Name = "python",
            :Type = "interpreted",
            :Extension = ".py",
            :Runtime = "python",
            :AlternateRuntimes = ["python3", "py"],
            :ResultFile = "pyresult.txt",
            :CustomPath = $cPythonPath,
            :TransFunc = $cPyToRingTransFunc,
            :Cleanup = 0,
	    :ExtraArgs = ""
        ],

        :R = [
            :Name = "r",
            :Type = "interpreted",
            :Extension = ".R",
            :Runtime = "Rscript",
            :AlternateRuntimes = ["r"],
            :ResultFile = "rresult.txt",
            :CustomPath = $cRPath,
            :TransFunc = $cRToRingTransFunc,
            :Cleanup = 0,
	    :ExtraArgs = ""
        ],

        :julia = [
            :Name = "julia",
            :Type = "interpreted",
            :Extension = ".jl",
            :Runtime = "julia",
            :AlternateRuntimes = [],
            :ResultFile = "jlresult.txt",
            :CustomPath = $cJuliaPath,
            :TransFunc = $cJuliaToRingTransFunc,
            :Cleanup = 0,
	    :ExtraArgs = ""
        ],

        :C = [
            :Name = "c",
            :Type = "compiled",
            :Extension = ".c",
            :Runtime = "gcc",
            :CompilerFlags = "-o temp_c",
            :ExecutableName = "temp_c",
            :AlternateRuntimes = [],
            :ResultFile = "cresult.txt",
            :CustomPath = $cCPath,
            :TransFunc = $cCToRingTransFunc,
            :Cleanup = 0,
            :CaptureBuildErrors = 1,
	    :ExtraArgs = ""
        ],

        :prolog = [
            :Name = "swi-Prolog",
            :Type = "interpreted",
            :Extension = ".pl",
            :Runtime = "swipl",
            :AlternateRuntimes = ["prolog"],
            :ResultFile = "plresult.txt",
            :CustomPath = $cPrologPath,
            :TransFunc = $cPrologToRingTransFunc,
            :Cleanup = 0,
            :ExtraArgs = "-q -g main -t halt"   # Quiet mode, call main/0, halt after execution
        ],

	:NodeJS = [
	    :Name = "nodejs",
	    :Type = "interpreted",
	    :Extension = ".njs",
	    :Runtime = "node",
	    :AlternateRuntimes = ["nodejs"],
	    :ResultFile = "jsresult.txt",
	    :CustomPath = $cNodeJsPath,
	    :TransFunc = $cJSToRingTransFunc,
	    :Cleanup = 0,
            :ExtraArgs = ""
	],

    ]

    # Other attributes
    @aCallTrace = []
    @cLanguage = ""
    @cCode = ""
    @cSourceFile = ""  # Auto-named like 'temp.py', 'temp.go', etc.
    @cLogFile = "log.txt"
    @cResultFile = ""  # Set from @aLanguages[@cLanguage][:ResultFile]
    @cResultVar = "res"  # Configurable with SetResVar()
    @nStartTime = 0
    @nEndTime = 0
    @bVerbose = 0  # Toggle with SetVerbose()

    # Builds a runner for one external language: python, r, julia, c, prolog or nodejs, in any letter case.
    #
    #   cLang      the language name
    #   returns    nothing; the object is built
    #   warning    raises error Language 'x' is not supported for any other name
    #   see        IsLanguageSupported, SetCode
    def Init(cLang)

        if NOT This.IsLanguageSupported(cLang)
            stzraise("Language '" + cLang + "' is not supported")
        ok

        @cLanguage = StzLower(cLang)
        @cSourceFile = "temp" + @aLanguages[@cLanguage][:extension]
        @cResultFile = @aLanguages[@cLanguage][:ResultFile]

    # TRUE if the runner knows the language, whatever the letter case.
    #
    #   cLang      the language name to test
    #   returns    TRUE or FALSE
    #   see        Init
    def IsLanguageSupported(cLang)
        return HasKey(@aLanguages, StzLower(cLang))

    # Sets the program that runs this object's language, in place of the configured path such as d:/nodejs/nodejs-22.20/node.exe.
    #
    #   cPath      the full path of the interpreter or compiler
    #   returns    nothing
    #   note       the path is used inside a batch file unquoted, so a folder name with a space
    #              breaks the run (use the short 8.3 form)
    #   warning    the path is not checked, so a wrong one shows only when Execute fails
    #   see        RuntimePath, Execute
    def SetRuntimePath(cPath)
        # Set custom runtime path for the language
	if HasKey(@aLanguages, @cLanguage) and
	   HasKey(@aLanguages[@cLanguage], :CustomPath)

        	@aLanguages[@cLanguage][:CustomPath] = cPath
	else
		StzRaise("Can't set the path! This path does not exist: @aLanguages[@cLanguage][:CustomPath].")
	ok

    # Stores the source text to run, in memory only; nothing is written to disk until Prepare or Execute.
    #
    #   cNewCode   the program text in the external language, which must assign its answer to the
    #              result variable
    #   returns    nothing
    #   see        Code, SetResultVar, Execute
    def SetCode(cNewCode)
        @cCode = cNewCode

    # Stores the source text to run, in memory only, exactly as SetCode does.
    #
    #   cNewCode   the program text in the external language
    #   returns    nothing
    #   see        SetCode, Code
    def @(cNewCode)
        @cCode = cNewCode

    # Turns on or off the report that Execute prints after a run: command, log, working folder and file checks.
    #
    #   bVerbose   1 to print the report, 0 to keep quiet
    #   returns    nothing
    #   see        IsVerbose, Execute
    def SetVerbose(bVerbose)
        @bVerbose = bVerbose

    # Chooses the name of the variable that your external code must fill with its answer; res unless changed.
    #
    #   cResVar    the variable name in the external language, an empty text being ignored
    #   returns    nothing
    #   see        ResultVar, SetCode
    def SetResultVar(cResVar)
        if NOT cResVar = ""
            @cResultVar = cResVar
        ok

    # Deletes the files of an earlier run, then writes the source file: the translator, your code and the lines that save the answer.
    #
    #   returns    nothing
    #   see        PrepareSourceCode, Execute, Code
    def Prepare()
		This.Cleanup()
        This.WriteToFile(@cSourceFile, This.PrepareSourceCode())

	# Writes the source, runs it with the language's program in the current folder and records the run; the answer is then read with Result.
	#
	#   returns    nothing; the answer is kept in a result file
	#   note       files are created in the current folder: temp plus the language's extension, a
	#              run script, the result file and log.txt
	#   warning    it runs real code with a real program, so run only code you trust; with no code
	#              set it writes the source and returns without running; it raises an error naming
	#              the log when the program produced no result file, which a syntax error in your
	#              code or a missing program also causes; the run script is started by its bare
	#              name, so where the environment variable NoDefaultCurrentDirectoryInExePath is 1
	#              the command shell refuses it and the log is missing; the R translator is itself
	#              rejected by R 4.5.1, so the language r always fails
	#   see        Result, Log, CallTrace, Duration
	def Execute()
	    This.Prepare()
	
	    if @cCode = ""
	        return
	    end
	
	    if NOT fexists(@cSourceFile)
	        stzraise("Source file '" + @cSourceFile + "' not found!")
	    ok
	
	    @nStartTime = clock()
	
	    _cRuntime_ = @aLanguages[@cLanguage][:CustomPath]
	    if _cRuntime_ = ""
	        _cRuntime_ = @aLanguages[@cLanguage][:Runtime]
	    ok
	
	    # Get extra args if they exist
	    _cExtraArgs_ = ""

	    if HasKey(@aLanguages, @cLanguage) and
	   	HasKey(@aLanguages[@cLanguage], :ExtraArgs)

        		_cExtraArgs_ = " " + @aLanguages[@cLanguage][:ExtraArgs]
	    else
		StzRaise("Can't set the path! This path does not exist: @aLanguages[@cLanguage][:ExtraArgs].")
	    ok
	
	    _cScriptFile_ = "run" + @cLanguage
	
	    if isWindows()
	        _cScriptFile_ += ".bat"
	        _cScriptContent_ = "@echo off" + char(10)
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10) +
	                                 "if %ERRORLEVEL% EQU 0 " + @aLanguages[@cLanguage][:ExecutableName] + ".exe >> " + @cLogFile + " 2>&1" + char(10)
	            else
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10)
	            ok
	        else
	            # Interpreted languages - include extra args
	            _cScriptContent_ += _cRuntime_ + _cExtraArgs_ + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10)
	        ok
	
	        _cScriptContent_ += "exit %ERRORLEVEL%"
	
	    else
	        _cScriptFile_ += ".sh"
	        _cScriptContent_ = "#!/bin/bash" + char(10)
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10) +
	                                 "if [ $? -eq 0 ]; then ./" + @aLanguages[@cLanguage][:ExecutableName] + " >> " + @cLogFile + " 2>&1; fi" + char(10)
	            else
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10)
	            ok
	        else
	            # Interpreted languages - include extra args
	            _cScriptContent_ += _cRuntime_ + _cExtraArgs_ + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + char(10)
	        ok
	
	        _cScriptContent_ += "exit $?"
	    ok
	
	    This.WriteToFile(_cScriptFile_, _cScriptContent_)
	
	    _cCmd_ = _cScriptFile_
	    _oSysCall_ = new stzSystemCall(_cCmd_)
	    _oSysCall_.DontCaptureOutput()
	    _oSysCall_.Run()
	
	    @nEndTime = clock()
	
	    _cLog_ = This.ReadFile(@cLogFile)
	
	    if _cLog_ = NULL
	        _cLog_ = "Log file '" + @cLogFile + "' not found or unreadable"
	    ok
	
	    This.RecordExecution(_cLog_, 0)
	
	    if @bVerbose
	        ? "Command: " + _cCmd_
	        ? "Log: " + _cLog_
	        ? "Working Directory: " + currentdir()
	        ? "Source File Exists: " + fexists(@cSourceFile)
	        ? "Result File Exists: " + fexists(@cResultFile)
	    ok
	
	    if NOT fexists(@cResultFile)
	        stzraise("Result file '" + @cResultFile + "' not created. Log: " + _cLog_)
	    ok
	
	    if fexists(_cScriptFile_)
	        remove(_cScriptFile_)
	    ok
		
	    	# Writes the source and runs it, exactly as Execute does.
	    	#
	    	#   returns    nothing; the answer is kept in a result file
	    	#   warning    same as Execute
	    	#   see        Execute, Result
		#< @FunctionAlternativeForms
	    	def Run()
	       		This.Execute()
	
		# Writes the source and runs it, exactly as Execute does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same as Execute
		#   see        Execute, Result
		def Exec()
		        This.Execute()
    # Deletes the source file, the result file and the log file of this object from the current folder.
    #
    #   returns    nothing
    #   note       the run script is deleted by Execute itself
    #   warning    a file that is not there is skipped without an error
    #   see        Cleanup, CleanupRequired
		#>
    def CleanupFiles()
	# TODO: does this cover cleaning compiled languages files?

        try
            remove(@cSourceFile)
            remove(@cResultFile)
            remove(@cLogFile)
        catch
            stzraise(cError)
        done

    	# Deletes the source file, the result file and the log file of this object, as CleanupFiles does.
    	#
    	#   returns    nothing
    	#   see        CleanupFiles
    	def Cleanup()
        	This.CleanupFiles()

    # TRUE if the language's settings ask for the files to be deleted once Result has read them.
    #
    #   returns    TRUE or FALSE; FALSE for all six languages as shipped
    #   see        CleanupFiles, Result
    def CleanupRequired()
        _bResult_ = @aLanguages[@cLanguage][:Cleanup]
        return isNumber(_bResult_) and _bResult_ = 1

    # Returns how long the last run took, in seconds.
    #
    #   returns    a number; 0 before any run
    #   see        Duration, CallTrace
    def LastCallDuration()
        if len(@aCallTrace) > 0
            return @aCallTrace[len(@aCallTrace)][:duration]
        end
        return 0

    	# Returns how long the last run took, in seconds.
    	#
    	#   returns    a number; 0 before any run
    	#   see        LastCallDuration, CallTrace
    	def Duration()
        	return LastCallDuration()

    # Returns the history of runs made by this object, oldest first.
    #
    #   returns    a list of hash lists with language, timestamp, duration, log, exitcode and mode
    #   warning    the exit code is always recorded as 0, even for a run that failed
    #   see        Trace, LastCallDuration
    def CallTrace()
        return @aCallTrace

    	# Returns the history of runs made by this object, oldest first.
    	#
    	#   returns    a list of hash lists with language, timestamp, duration, log, exitcode and
    	#              mode
    	#   warning    same as CallTrace
    	#   see        CallTrace
    	def Trace()
       	 	return @aCallTrace

    # Reads the answer the external code saved and turns it into a Ring value: a number, a text or a list.
    #
    #   returns    the value; an empty text when the result file is empty
    #   warning    the files are deleted afterwards only if CleanupRequired is TRUE
    #   see        it evaluates the text of the result file as Ring code, so only run external code
    #              you trust; it raises an error quoting the log when the result file does not
    #              exist; when the text cannot be evaluated it prints Eval error and returns the raw
    #              text
    def Result()

        if NOT fexists(@cResultFile)

            stzraise("File does not exist!" + char(10) + char(10) +
                     "Log content (from " + @cLanguage + " console): " + char(10) +
                     "------------------" + ring_copy("-", len(@cLanguage)) + "----------" + char(10) + char(10) +
                     This.Log() + char(10) + char(10) +
                     "------------------------" + char(10) +
                     "End of log file content.")
        ok

        _cContent_ = This.ReadFile(@cResultFile)

        if _cContent_ = ""
            return ""
        ok

        try
	    _cContent_ = StzReplace(_cContent_, "\n", char(10))
            _cCode_ = '_result_ = ' + _cContent_

            eval(_cCode_)

            if CleanupRequired()
                This.CleanupFiles()
            ok

            return _result_

        catch
            ? "Eval error: " + cCatchError + char(10)
            ? "Log content: " + This.Log()
            return _cContent_

        done

    # Returns the name of the file that holds the answer, such as jsresult.txt for nodejs.
    #
    #   returns    a text
    #   see        Result, ResultVar
    def FileName()
        return @cResultFile

    # Returns the name of the variable the external code must assign its answer to.
    #
    #   returns    a text; res by default
    #   see        SetResultVar
    def ResultVar()
        return @cResultVar

    # Returns the program that runs this object's language, such as d:/nodejs/nodejs-22.20/node.exe.
    #
    #   returns    a text
    #   see        SetRuntimePath
    def RuntimePath()
        return @aLanguages[@cLanguage][:CustomPath]

    # TRUE if Execute prints its report after each run.
    #
    #   returns    TRUE or FALSE
    #   see        SetVerbose
    def IsVerbose()
        return @bVerbose

    # Sets the name of the file that receives the program's printed output and errors; the default is log.txt.
    #
    #   cFileName   the file name, in the current folder
    #   returns     nothing
    #   see         LogFile, Execute
    def SetLogFile(cFileName)
        @cLogFile = cFileName

    # Returns the text the program printed during the last run, errors included.
    #
    #   returns    a text; empty when there is no log file
    #   see        Log, SetLogFile
    def LogFile()
        return This.ReadFile(@cLogFile)

    def Log()
        return This.LogFile()

    # Returns the source text you set, or, when none is set, the text of the source file on disk.
    #
    #   returns    a text; empty when neither exists
    #   warning    it returns your own code, not the wrapped source that is written to disk
    #   see        SetCode, PrepareSourceCode
    def Code()
        # In-memory source-of-truth. The source file is only written
        # at Prepare()/Execute() time; until then @cCode is canonical.
        if @cCode != ""
            return @cCode
        ok
        if fexists(@cSourceFile)
            return This.ReadFile(@cSourceFile)
        ok
        return ""

    #====== PRIVATE METHODS ======#

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
            return NULL
        ok
        _fp_ = fopen(cFile, "r")
        if _fp_ = NULL
            return NULL
        end
        _cContent_ = fread(_fp_, fsize(_fp_))
        fclose(_fp_)
        return _cContent_

    # Returns the command line that would start the source file, for example the program path followed by temp.njs.
    #
    #   returns    a text
    #   warning    Execute does not use it and builds its own run script
    #   see        Execute, RuntimePath
    def BuildCommand()

        # Not used with batch approach, kept for compatibility

	if HasPath(@aLanguages, [@cLanguage, :type]) and 
           @aLanguages[@cLanguage][:type] = "interpreted"

            _cCmd_ = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile

            if HasPath(@aLanguages, [@cLanguage, :customPath])
                _cCmd_ = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
            ok

            return _cCmd_

        but HasPath(@aLanguages, [@cLanguage, :type]) and
	    @aLanguages[@cLanguage][:type] = "compiled"

	    _cCmd_ = @aLanguages[@cLanguage][:Runtime] + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile
            return _cCmd_
        ok

        stzraise("Unsupported language type for " + @cLanguage)

    # Appends one entry to the call trace, taking the duration from the clocks of the last run.
    #
    #   _cLog_      the text printed by the run to keep in the entry
    #   nExitCode   the exit code to keep in the entry
    #   returns     nothing
    #   see         CallTrace
    def RecordExecution(_cLog_, nExitCode)
	if NOT HasPath(@aLanguages, [@clanguage, :type])
		StzRaise("Incorrect format! Can't access the path @aLanguages[@clanguage][:type].")
	ok

        _cMode_ = @aLanguages[@cLanguage][:type]

        if _cMode_ != "interpreted" and _cMode_ != "compiled"
            stzraise("Incorrect language type! Must be 'interpreted' or 'compiled'.")
        ok

        @aCallTrace + [
            :Language = @cLanguage,
            :Timestamp = StzTimeStamp(),
            :Duration = (@nEndTime - @nStartTime) / clockspersecond(),
            :Log = _cLog_,
            :Exitcode = nExitCode,
            :Mode = _cMode_
        ]

    # Returns the full program text that would be run: the translator, your code and the lines that save the answer.
    #
    #   returns    a text
    #   warning    for prolog it looks for a predicate named compute_result, get_factorials or res
    #              and calls the first one it finds
    #   see        Prepare, Code
    def PrepareSourceCode()
	if NOT HasPath(@aLanguages, [@cLanguage, :TransFunc])
		StzRaise("Incorrect format! Can't access the path @aLanguages[@cLanguage][:TransFunc].")
	ok

        _cTransFunc_ = @aLanguages[@cLanguage][:TransFunc]

	#-------------------------
         if @cLanguage = "python"
	#-------------------------

            return char(10) + _cTransFunc_ + '
# Main code
print("Python script starting...")
' + @cCode + '
print("Data before transformation:", ' + @cResultVar + ')
_transformed_ = transform_to_ring(' + @cResultVar + ')
print("Data after transformation:", _transformed_)
with open("' + @cResultFile + '", "w") as f:
    f.write(_transformed_)
print("Data written to file")
'

	#---------------------
         but @cLanguage = "r"
	#---------------------

            return _cTransFunc_ + '
# Main code
cat("R script starting...\n")
' + @cCode + '
_transformed_ <- transform_to_ring(' + @cResultVar + ')
writeLines(_transformed_, "' + @cResultFile + '")
cat("Data written to file\n")
'

	#-------------------------
         but @cLanguage = "julia"
	#-------------------------

            return _cTransFunc_ + '
# Main code
println("Julia script starting...")
' + @cCode + '
_transformed_ = transform_to_ring(' + @cResultVar + ')
println("Data before transformation: ", ' + @cResultVar + ')
println("Data after transformation: ", _transformed_)
open("' + @cResultFile + '", "w") do f
    write(f, _transformed_)
end
println("Data written to file")
'

	#---------------------
	 but @cLanguage = "c"
	#---------------------

    return $cCToRingTransFunc + '

int main() {
    printf("C program starting...\\n");
' + @cCode + '
    if (res != NULL) {
        transform_to_ring(res, "' + @cResultFile + '");
        printf("Data written to file.\\n");
        free_value(res);
        free(res);
    }
    return 0;
}
'

	#---------------------------
   	 but @cLanguage = "prolog"
	#---------------------------

    # Extract the main computation predicate name from user code
    # Look for a predicate that takes one argument and is likely the main one
    _cMainPredicate_ = "compute_result"  # default
    
    # Try to find a predicate definition in the code
    if StzFindFirst("compute_result(", @cCode) > 0
        _cMainPredicate_ = "compute_result"
    but StzFindFirst("get_factorials(", @cCode) > 0
        _cMainPredicate_ = "get_factorials"
    but StzFindFirst("res(", @cCode) > 0
        _cMainPredicate_ = "res"
    ok

    return '
' + $cPrologToRingTransFunc + '

:- use_module(library(lists)).
:- use_module(library(apply)).

% User predicates
' + @cCode + '

% Main predicate
main :-
    writeln("SWI-Prolog program starting..."),
    ' + _cMainPredicate_ + '(Res),
    writeln("Transforming result..."),
    transform_to_ring(Res, "' + @cResultFile + '"),
    writeln("Data written to file").
'

	#------------------------------
	but @cLanguage = "nodejs"
	#------------------------------
	
	    return _cTransFunc_ + '
// Main code
console.log("NodeJS script starting...");
' + @cCode + '
console.log("Data before transformation:", ' + @cResultVar + ');
const _transformed_ = transform_to_ring(' + @cResultVar + ');
console.log("Data after transformation:", _transformed_);
require("fs").writeFileSync("' + @cResultFile + '", _transformed_);
console.log("Data written to file");
'

	#------
          else
	#------

            stzraise("Not implemented yet for this language!")
        ok
