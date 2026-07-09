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

    def Init(cLang)

        if NOT This.IsLanguageSupported(cLang)
            stzraise("Language '" + cLang + "' is not supported")
        ok

        @cLanguage = StzLower(cLang)
        @cSourceFile = "temp" + @aLanguages[@cLanguage][:extension]
        @cResultFile = @aLanguages[@cLanguage][:ResultFile]

    def IsLanguageSupported(cLang)
        return HasKey(@aLanguages, StzLower(cLang))

    def SetRuntimePath(cPath)
        # Set custom runtime path for the language
	if HasKey(@aLanguages, @cLanguage) and
	   HasKey(@aLanguages[@cLanguage], :CustomPath)

        	@aLanguages[@cLanguage][:CustomPath] = cPath
	else
		StzRaise("Can't set the path! This path does not exist: @aLanguages[@cLanguage][:CustomPath].")
	ok

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
	        _cScriptContent_ = "@echo off" + NL
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
	                                 "if %ERRORLEVEL% EQU 0 " + @aLanguages[@cLanguage][:ExecutableName] + ".exe >> " + @cLogFile + " 2>&1" + NL
	            else
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	            ok
	        else
	            # Interpreted languages - include extra args
	            _cScriptContent_ += _cRuntime_ + _cExtraArgs_ + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	        ok
	
	        _cScriptContent_ += "exit %ERRORLEVEL%"
	
	    else
	        _cScriptFile_ += ".sh"
	        _cScriptContent_ = "#!/bin/bash" + NL
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
	                                 "if [ $? -eq 0 ]; then ./" + @aLanguages[@cLanguage][:ExecutableName] + " >> " + @cLogFile + " 2>&1; fi" + NL
	            else
	                _cScriptContent_ += _cRuntime_ + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	            ok
	        else
	            # Interpreted languages - include extra args
	            _cScriptContent_ += _cRuntime_ + _cExtraArgs_ + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
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
		
		#< @FunctionAlternativeForms
	
	    	def Run()
	       		This.Execute()
	
		def Exec()
		        This.Execute()
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

    	def Cleanup()
        	This.CleanupFiles()

    def CleanupRequired()
        _bResult_ = @aLanguages[@cLanguage][:Cleanup]
        return isNumber(_bResult_) and _bResult_ = 1

    def LastCallDuration()
        if len(@aCallTrace) > 0
            return @aCallTrace[len(@aCallTrace)][:duration]
        end
        return 0

    	def Duration()
        	return LastCallDuration()

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

        _cContent_ = This.ReadFile(@cResultFile)

        if _cContent_ = ""
            return ""
        ok

        try
	    _cContent_ = StzReplace(_cContent_, "\n", NL)
            _cCode_ = '_result_ = ' + _cContent_

            eval(_cCode_)

            if CleanupRequired()
                This.CleanupFiles()
            ok

            return _result_

        catch
            ? "Eval error: " + cCatchError + NL
            ? "Log content: " + This.Log()
            return _cContent_

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
        return This.ReadFile(@cLogFile)

    def Log()
        return This.LogFile()

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

    def WriteToFile(cFile, _cContent_)
        _fp_ = fopen(cFile, "w")
        fwrite(_fp_, _cContent_)
        fclose(_fp_)

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

    def PrepareSourceCode()
	if NOT HasPath(@aLanguages, [@cLanguage, :TransFunc])
		StzRaise("Incorrect format! Can't access the path @aLanguages[@cLanguage][:TransFunc].")
	ok

        _cTransFunc_ = @aLanguages[@cLanguage][:TransFunc]

	#-------------------------
         if @cLanguage = "python"
	#-------------------------

            return NL + _cTransFunc_ + '
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
    if StzFindFirst(@cCode, "compute_result(") > 0
        _cMainPredicate_ = "compute_result"
    but StzFindFirst(@cCode, "get_factorials(") > 0
        _cMainPredicate_ = "get_factorials"
    but StzFindFirst(@cCode, "res(") > 0
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
    ' + cMainPredicate + '(Res),
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
