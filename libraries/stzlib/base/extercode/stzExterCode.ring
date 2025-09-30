load "stzExterCodeTransFuncs.ring"


#------------------#
#  THE MAIN CLASS  #
#------------------#

class stzExterCode

	@cTempDir = "extertemp"

    # Configuring supported languages with full paths
    @aLanguages = [

        :python = [
            :Name = "Python",
            :Type = "interpreted",
            :Extension = ".py",
            :Runtime = "python",
            :AlternateRuntimes = ["python3", "py"],
            :ResultFile = "pyresult.txt",
            :CustomPath = "D:/python/python-3.13.7/python.exe",  # Replace with your Python path
            :TransFunc = $cPyToRingTransFunc,
            :Cleanup = 0
        ],

        :R = [
            :Name = "R",
            :Type = "interpreted",
            :Extension = ".R",
            :Runtime = "Rscript",
            :AlternateRuntimes = ["R"],
            :ResultFile = "rresult.txt",
            :CustomPath = "D:/R/R-4.5.1/bin/Rscript.exe",  # Replace with your R path
            :TransFunc = $cRToRingTransFunc,
            :Cleanup = 0
        ],

        :julia = [
            :Name = "Julia",
            :Type = "interpreted",
            :Extension = ".jl",
            :Runtime = "julia",
            :AlternateRuntimes = [],
            :ResultFile = "jlresult.txt",
            :CustomPath = "D:/Julia/Julia-1.11.7/bin/julia.exe",  # Replace with your Julia path
            :TransFunc = $cJuliaToRingTransFunc,
            :Cleanup = 0
        ],

        :C = [
            :Name = "C",
            :Type = "compiled",
            :Extension = ".c",
            :Runtime = "gcc",
            :CompilerFlags = "-o temp_c",
            :ExecutableName = "temp_c",
            :AlternateRuntimes = [],
            :ResultFile = "cresult.txt",
            :CustomPath = "D:/mingw64/bin/gcc.exe",  # Replace with your Go path
            :TransFunc = $cCToRingTransFunc,
            :Cleanup = 0,
            :CaptureBuildErrors = 1
        ],

        :prolog = [
            :Name = "SWI-Prolog",
            :Type = "interpreted",
            :Extension = ".pl",
            :Runtime = "swipl",
            :AlternateRuntimes = ["prolog"],
            :ResultFile = "plresult.txt",
            :CustomPath = "D:/Prolog/swipl-9.9.9/bin/swipl.exe",  # Update to your actual path
            :TransFunc = $cPrologToRingTransFunc,
            :Cleanup = 0,
            :ExtraArgs = "-q -g main -t halt"   # Quiet mode, call main/0, halt after execution
        ],

	:NodeJS = [
	    :Name = "NodeJS",
	    :Type = "interpreted",
	    :Extension = ".njs",
	    :Runtime = "node",
	    :AlternateRuntimes = ["nodejs"],
	    :ResultFile = "jsresult.txt",
	    :CustomPath = "D:/nodejs/nodejs-22.20/node.exe",  # Replace with your Node.js path
	    :TransFunc = $cJSToRingTransFunc,
	    :Cleanup = 0
	]

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
	
	    @cLanguage = lower(cLang)
	    
	    # Create temp directory if it doesn't exist
	    if NOT isdir(@cTempDir)
	        system("mkdir " + @cTempDir)
	    ok
	    
	    @cSourceFile = @cTempDir + "/" + "temp" + @aLanguages[@cLanguage][:extension]
	    @cResultFile = @cTempDir + "/" + @aLanguages[@cLanguage][:ResultFile]
	    @cLogFile = @cTempDir + "/" + "log.txt"

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
	
	    # Get extra args if they exist
	    cExtraArgs = ""
	    if @aLanguages[@cLanguage][:ExtraArgs] != NULL
	        cExtraArgs = " " + @aLanguages[@cLanguage][:ExtraArgs]
	    ok
	
	    cScriptFile = @cTempDir + "/" + "run" + @cLanguage
	
	    if isWindows()
	        cScriptFile += ".bat"
	        cScriptContent = "@echo off" + NL
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
	                                 "if %ERRORLEVEL% EQU 0 " + @aLanguages[@cLanguage][:ExecutableName] + ".exe >> " + @cLogFile + " 2>&1" + NL
	            else
	                cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	            ok
	        else
	            # Interpreted languages - include extra args
	            cScriptContent += cRuntime + cExtraArgs + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	        ok
	
	        cScriptContent += "exit %ERRORLEVEL%"
	
	    else
	        cScriptFile += ".sh"
	        cScriptContent = "#!/bin/bash" + NL
	
	        if @aLanguages[@cLanguage][:Type] = "compiled"
	            if @cLanguage = "c"
	                cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
	                                 "if [ $? -eq 0 ]; then ./" + @aLanguages[@cLanguage][:ExecutableName] + " >> " + @cLogFile + " 2>&1; fi" + NL
	            else
	                cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
	            ok
	        else
	            # Interpreted languages - include extra args
	            cScriptContent += cRuntime + cExtraArgs + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
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
        bResult = @aLanguages[@cLanguage][:Cleanup]
        return isNumber(bResult) and bResult = 1

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
            ? "Eval error: " + cCatchError + NL
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
        @cLogFile = @cTempDir + "/" + cFileName

    def LogFile()
        return This.ReadFile(@cLogFile)

    def Log()
        return This.LogFile()

    def Code()
        if NOT fexists(@cSourceFile)
            return ""
        ok
        return This.ReadFile(@cSourceFile)

    #====== PRIVATE METHODS ======#

    def WriteToFile(cFile, cContent)
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

        return NL + cTransFunc + '
# Main code
print("Python script starting...")
' + @cCode + '
print("Data before transformation:", ' + @cResultVar + ')
transformed = transform_to_ring(' + @cResultVar + ')
print("Data after transformation:", transformed)
with open("' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '", "w") as f:
    f.write(transformed)
print("Data written to file")
'

    #---------------------
    but @cLanguage = "r"
    #---------------------

        return cTransFunc + '
# Main code
cat("R script starting...\n")
' + @cCode + '
transformed <- transform_to_ring(' + @cResultVar + ')
writeLines(transformed, "' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '")
cat("Data written to file\n")
'

    #-------------------------
    but @cLanguage = "julia"
    #-------------------------

        return cTransFunc + '
# Main code
println("Julia script starting...")
' + @cCode + '
transformed = transform_to_ring(' + @cResultVar + ')
println("Data before transformation: ", ' + @cResultVar + ')
println("Data after transformation: ", transformed)
open("' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '", "w") do f
    write(f, transformed)
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
        transform_to_ring(res, "' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '");
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
        cMainPredicate = "compute_result"  # default
        
        if substr(@cCode, "compute_result(") > 0
            cMainPredicate = "compute_result"
        but substr(@cCode, "get_factorials(") > 0
            cMainPredicate = "get_factorials"
        but substr(@cCode, "res(") > 0
            cMainPredicate = "res"
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
    transform_to_ring(Res, "' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '"),
    writeln("Data written to file").
'

    #------------------------------
    but @cLanguage = "nodejs"
    #------------------------------
    
        return cTransFunc + '
// Main code
console.log("NodeJS script starting...");
' + @cCode + '
console.log("Data before transformation:", ' + @cResultVar + ');
const transformed = transform_to_ring(' + @cResultVar + ');
console.log("Data after transformation:", transformed);
require("fs").writeFileSync("' + @cTempDir + '/' + @aLanguages[@cLanguage][:ResultFile] + '", transformed);
console.log("Data written to file");
'

    #------
    else
    #------

        stzraise("Not implemented yet for this language!")
    ok
