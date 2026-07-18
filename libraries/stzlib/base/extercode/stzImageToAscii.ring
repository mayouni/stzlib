#============================================================#
#  stzImgToAscii.ring   →   Maximum simplified version
#  Uses only built-in system() + read()/remove() 
#  Keeps 100% of the features and full chainability
#============================================================#

if Haskey($aStzLibConfig, :Img2AnsiPath) and $aStzLibConfig[:Img2AnsiPath] != ""
    $cImg2AnsiExe = $aStzLibConfig[:Img2AnsiPath]
else
    $cImg2AnsiExe = "../tools/im2ansi/im2ansi.exe"   # works when running from /test
ok

$acFormats = [ "ansi", "ascii", "svg", "html" ]

func StzImgToAsciiQ(pcImagePath)
    return new stzImgToAscii(pcImagePath)

    func ImgToAsciiQ(pcImagePath)
        return StzImgToAsciiQ(pcImagePath)

class stzImgToAscii from stzObject

    @cExe      = $cImg2AnsiExe
    @cImage    = ""
    @cFormat   = "ansi"
    @nHeight   = 30
    @nWidth    = NULL
    @cChars    = NULL      # custom character set
    @nRamp     = 1         # 1-12 for ascii
    @bInvert   = FALSE
    @bNoColor  = FALSE
    @nSeed     = NULL
    @cOutFile  = ""        # user-specified output file
    @cOutDir   = "output"
    @cTempDir  = "temp"
    @cContent  = ""
    @cFile     = ""
    @bRan      = FALSE
    @bVerbose  = FALSE

    def init(pcImage = "")
        if pcImage != "" { This.Image(pcImage) }
        This.EnsureDirs()

    def EnsureDirs()
        dir_create(@cTempDir)
        dir_create(@cOutputDir)

    def Image(pc)          { @cImage = pc ; if NOT fexists(pc) stzraise("Image not found: " + pc) ok ; return This }
    def Format(pc)         { pc=StzLower(pc) ; if StzFindFirst(pc, $acFormats)=0 stzraise("Unsupported format") ok ; @cFormat=pc ; return This }
    def Height(n)          { @nHeight = n ; return This }
    def Width(n)           { @nWidth  = n ; return This }
    def Chars(pc)          { @cChars  = pc ; return This }
    def Ramp(n)            { if n<1 or n>12 stzraise("Ramp 1-12 only") ok ; @nRamp = n ; return This }
    def Invert(b=TRUE)     { @bInvert = b ; return This }
    def NoColor(b=TRUE)    { @bNoColor = b ; return This }
    def Seed(n)            { @nSeed = n ; return This }
    def Verbose(b=TRUE)    { @bVerbose = b ; return This }
    def OutputFile(pc)     { @cOutFile = pc ; return This }

    def Execute()
        This.EnsureDirs()

        if @cImage = "" { stzraise("No image set") }

        _aArgs_     = This.BuildArgs()
        _cArgsStr_  = ""
        _aArgscArgsStrx1_ = _aArgs_ { _cArgsStr_ += _x_ + " " }
        _nArgscArgsStrx1Len_ = len(_aArgscArgsStrx1_)
        for _iLoopArgscArgsStrx1_ = 1 to _nArgscArgsStrx1Len_
        	_x_ = _aArgscArgsStrx1_[_iLoopArgscArgsStrx1_]
        _cArgsStr_  = rtrim(_cArgsStr_," ")

        _cCmd_ = @@(@cExe) + " " + _cArgsStr_

        # ───── Determine output destination ─────
        _cDestFile_ = @cOutFile

        if _cDestFile_ = "" and @cFormat in ["svg","html"]
            _cExt_ = (@cFormat="html" ? "html" : "svg")
            _cDestFile_ = @cOutDir + "/img2ansi_" + clock() + "." + _cExt_
        ok

        if @bVerbose { ? "CMD: " + _cCmd_ ; if _cDestFile_!="" ? " → " + _cDestFile_ ok }

        if _cDestFile_ != ""
            # output to real file
            _cCmd_ += " -o " + @@(_cDestFile_)
            _nExit_ = system(_cCmd_)
            if _nExit_ != 0 or NOT fexists(_cDestFile_)
                stzraise("im2ansi failed (exit " + _nExit_ + ")")
            ok
            @cFile    = _cDestFile_
            @cContent = ""
        else
            # capture stdout (ansi / ascii)
            _cTemp_ = @cTempDir + "/_tmp_" + clock() + ".txt"
            _cCmd_ += " > " + @@(_cTemp_) + " 2>&1"
            _nExit_ = system(_cCmd_)
            if _nExit_ != 0
                _cErr_ = read(_cTemp_)
                remove(_cTemp_)
                stzraise("im2ansi error: " + _cErr_)
            ok
            @cContent = read(_cTemp_)
            remove(_cTemp_)
            @cFile = ""
        ok

        @bRan = TRUE

        def Run()    { This.Execute() }
        def Go()     { This.Execute() }

    def Content()
        if NOT @bRan { This.Execute() }
        if @cContent = "" and @cFile != ""
            @cContent = read(@cFile)
        ok
        return @cContent

    def Show()
        if NOT @bRan { This.Execute() }

        if @cFile != ""
            # open file with OS default viewer
                 if iswindows() { system('start "" ' + @@(@cFile)) }
            elif ismacosx()     { system("open " + @@(@cFile)) }
            elif islinux()      { system("xdg-open " + @@(@cFile)) }
            ok
        else
            ? This.Content()
        ok

        def View()    { This.Show() }
        def Display() { This.Show() }

    def ExecuteAndShow() { This.Execute() ; This.Show() }
        def RunAndView() { This.ExecuteAndShow() }
        def XT()         { This.ExecuteAndShow() }
        def GoXT()       { This.ExecuteAndShow() }

    def OutputFile() { return @cFile }

    private

    def BuildArgs()
        _a_ = [ "-p", @@(@cImage) ]

        if @cFormat != "ansi"   { _a_ + "-f" + @cFormat }
        _a_ + "-s" + @nHeight
        if isNumber(@nWidth)    { _a_ + "-w" + @nWidth }
        if @bInvert             { _a_ + "-i" }
        if @bNoColor            { _a_ + "--no-color" }
        if isNumber(@nSeed)     { _a_ + "--seed" + @nSeed }
        if @cChars != NULL      { _a_ + "-c" + @@(@cChars) }
        if @cFormat = "ascii"   { _a_ + "-r" + @nRamp }

        return _a_
    end
