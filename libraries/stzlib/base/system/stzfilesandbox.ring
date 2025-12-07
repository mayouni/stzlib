#================================#
#  stzFileSandbox CLASS        #
#================================#

# Purpose: Provides isolated sandbox environment for safe file system operations
# with automatic change tracking, user approval, and rollback capabilities

func StzFileSandboxQ(cRootPath)
    return new stzFileSandbox(cRootPath)

class stzFileSandbox from stzObject
    
    @cRootPath
    @cSandboxPath
    @aFileSnapshot
    @bAutoApprove
    @cOriginalDir
    
    def init(cRootPath)
        if CheckParams()
            if NOT (isString(cRootPath) and cRootPath != "")
                StzRaise("Incorrect param! cRootPath must be non-empty string.")
            ok
        ok
        
        @cRootPath = cRootPath
        @bAutoApprove = FALSE
        @cOriginalDir = currentdir()
        @aFileSnapshot = []
        @cSandboxPath = ""
        
        # Create root if doesn't exist
        if NOT isdir(@cRootPath)
            QMkdir(@cRootPath)
        ok
    
    #==================#
    #  CONFIGURATION   #
    #==================#
    
    def SetAutoApprove(b)
        if CheckParams()
            if NOT (isNumber(b) and (b = 0 or b = 1))
                StzRaise("Incorrect param! b must be 0 or 1.")
            ok
        ok
        @bAutoApprove = b
        return This
    
    def AutoApprove()
        return @bAutoApprove
    
    #==================#
    #  Sandbox OPS   #
    #==================#
    
    def Create()
        # Generate unique Sandbox path
        cTimestamp = "" + clock()
        @cSandboxPath = @cRootPath + "/ws_" + cTimestamp
        
        QMkdir(@cSandboxPath)
        
        return @cSandboxPath
    
        def CreateQ()
            This.Create()
            return This
    
    def Path()
        return @cSandboxPath
    
    def Exists()
        return @cSandboxPath != "" and isdir(@cSandboxPath)
    
    #==================#
    #  FILE OPERATIONS #
    #==================#
    
    def CopyFile(cSourceFile)
        return This.CopyFiles([cSourceFile])
    
    def CopyFiles(acFiles)
        if CheckParams()
            if NOT (isList(acFiles) and IsListOfStrings(acFiles))
                StzRaise("Incorrect param! acFiles must be list of strings.")
            ok
        ok
        
        if @cSandboxPath = ""
            StzRaise("Sandbox not created! Call Create() first.")
        ok
        
	    # Copy files to sandbox root (flat structure)
	    for cFile in acFiles
	        # Extract filename only
	        nLastSlash = 0
	        for i = len(cFile) to 1 step -1
	            if cFile[i] = "/" or cFile[i] = "\"
	                nLastSlash = i
	                exit
	            ok
	        next
	        
	        cFileName = cFile
	        if nLastSlash > 0
	            cFileName = right(cFile, len(cFile) - nLastSlash)
	        ok
	        
	        cDest = @cSandboxPath + "/" + cFileName
	        CopyFileContent(cFile, cDest)
	    next
	    
	    @aFileSnapshot = This.GetSnapshot()
	    return This
    
    def CopyFolder(cSourceFolder)
        if CheckParams()
            if NOT (isString(cSourceFolder) and cSourceFolder != "")
                StzRaise("Incorrect param! cSourceFolder must be non-empty string.")
            ok
        ok
        
        if NOT isdir(cSourceFolder)
            StzRaise("Source folder does not exist: " + cSourceFolder)
        ok
        
        # Get all files recursively
        acFiles = This.GetAllFilesIn(cSourceFolder)
        
        return This.CopyFiles(acFiles)
    
    #==================#
    #  CHANGE TRACKING #
    #==================#
    
    def GetSnapshot()
        if @cSandboxPath = ""
            return []
        ok
        
        aSnapshot = []
        aToProcess = [@cSandboxPath]
        
        while len(aToProcess) > 0
            cCurrentPath = aToProcess[1]
            del(aToProcess, 1)
            
            _aList_ = @dir(cCurrentPath)
            nLen = len(_aList_)
            
            for i = 1 to nLen
                if _aList_[i][2] = 0  # File
                    cFileName = _aList_[i][1]
                    cFullPath = cCurrentPath + "/" + cFileName
                    cRelativePath = substr(cFullPath, len(@cSandboxPath) + 2)
                    
                    aSnapshot + [
                        cRelativePath,
                        len(cFullPath),
                        filemtime(cFullPath)
                    ]
                    
                but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
                    aToProcess + (cCurrentPath + "/" + _aList_[i][1])
                ok
            next
        end
        
        return aSnapshot
    
    def DetectChanges()
        aAfterSnapshot = This.GetSnapshot()
        
        aCreated = []
        aModified = []
        aDeleted = []
        
        # Find created and modified files
        for aFileAfter in aAfterSnapshot
            cFileName = aFileAfter[1]
            bFound = FALSE
            
            for aFileBefore in @aFileSnapshot
                if aFileBefore[1] = cFileName
                    bFound = TRUE
                    # Check if modified (size or time changed)
                    if aFileBefore[2] != aFileAfter[2] or aFileBefore[3] != aFileAfter[3]
                        aModified + cFileName
                    ok
                    exit
                ok
            next
            
            if NOT bFound
                aCreated + cFileName
            ok
        next
        
        # Find deleted files
        for aFileBefore in @aFileSnapshot
            cFileName = aFileBefore[1]
            bFound = FALSE
            
            for aFileAfter in aAfterSnapshot
                if aFileAfter[1] = cFileName
                    bFound = TRUE
                    exit
                ok
            next
            
            if NOT bFound
                aDeleted + cFileName
            ok
        next
        
        return [
            :created = aCreated,
            :modified = aModified,
            :deleted = aDeleted
        ]
    
    #==================#
    #  USER APPROVAL   #
    #==================#
    
    def RequestApproval(aChanges)
        if @bAutoApprove
            return TRUE
        ok
        
        ? "╔═════════════════════════════════════╗"
        ? "║   REVIEW CHANGES BEFORE APPLYING    ║"
        ? "╚═════════════════════════════════════╝"
        ? ""
        ? "Sandbox: " + @cSandboxPath
        ? ""
        
        nTotalChanges = len(aChanges[:created]) + len(aChanges[:modified]) + len(aChanges[:deleted])
        
        if nTotalChanges = 0
            ? "⚠  No file changes detected"
        else
            if len(aChanges[:created]) > 0
                ? "✓ Files created (" + len(aChanges[:created]) + "):"
                for cFile in aChanges[:created]
                    ? "  + " + cFile
                next
                ? ""
            ok
            
            if len(aChanges[:modified]) > 0
                ? "✓ Files modified (" + len(aChanges[:modified]) + "):"
                for cFile in aChanges[:modified]
                    ? "  * " + cFile
                next
                ? ""
            ok
            
            if len(aChanges[:deleted]) > 0
                ? "✓ Files deleted (" + len(aChanges[:deleted]) + "):"
                for cFile in aChanges[:deleted]
                    ? "  - " + cFile
                next
                ? ""
            ok
        ok
        
        ? "─────────────────────────────────────────────"
        ? "Options:"
        ? "  Y = Yes, Apply changes"
        ? "  N = No, Discard changes"
        ? "  I = Inspect Sandbox"
        ? ""
        ? "Your choice (Y/N/I): "
        give cAnswer
        ? ""
        
        if lower(cAnswer) = "i"
            This.ShowSandboxTree(@cSandboxPath, "", 0)
            ? ""
            ? "Press Enter to continue..."
            give cDummy
            return This.RequestApproval(aChanges)
        ok
        
        if lower(cAnswer) != "y" and lower(cAnswer) != "n"
            ? "Invalid choice. Please enter y, n, or i"
            return This.RequestApproval(aChanges)
        ok
        
        return lower(cAnswer) = "y"
    
    def ShowSandboxTree(cPath, cPrefix, nLevel)
        aList = dir(cPath)
        nLen = len(aList)
        
        for i = 1 to nLen
            if aList[i][1] = "." or aList[i][1] = ".."
                loop
            ok
            
            bIsLast = (i = nLen)
            cIcon = iff(bIsLast, "└── ", "├── ")
            
            if aList[i][2] = 1  # Directory
                ? cPrefix + cIcon + "📁 " + aList[i][1]
                cNewPrefix = cPrefix + iff(bIsLast, "    ", "│   ")
                This.ShowSandboxTree(cPath + "/" + aList[i][1], cNewPrefix, nLevel + 1)
            else  # File
                ? cPrefix + cIcon + "📄 " + aList[i][1]
            ok
        next
    
    #==================#
    #  APPLY CHANGES   #
    #==================#
    
    def ApplyChanges(aChanges, cTargetPath)
        if CheckParams()
            if NOT (isString(cTargetPath) and cTargetPath != "")
                StzRaise("Incorrect param! cTargetPath must be non-empty string.")
            ok
        ok
        
        # Apply created files
        for cFile in aChanges[:created]
            cSrc = @cSandboxPath + "/" + cFile
            cDest = cTargetPath + "/" + cFile
            if fexists(cSrc)
                CopyFileContent(cSrc, cDest)
            ok
        next
        
        # Apply modified files
        for cFile in aChanges[:modified]
            cSrc = @cSandboxPath + "/" + cFile
            cDest = cTargetPath + "/" + cFile
            if fexists(cSrc)
                CopyFileContent(cSrc, cDest)
            ok
        next
        
        # Apply deleted files
        for cFile in aChanges[:deleted]
            cDest = cTargetPath + "/" + cFile
            if fexists(cDest)
                @FileDelete(cDest)
            ok
        next
        
        return This
    
    #==================#
    #  CLEANUP         #
    #==================#
    
    def Cleanup()
        if @cSandboxPath != "" and isdir(@cSandboxPath)
            _oQDir_ = new QDir()
            _oQDir_.setPath(@cSandboxPath)
            _oQDir_.removeRecursively()
            @cSandboxPath = ""
        ok
        
        return This
    
    def CleanupQ()
        This.Cleanup()
        return This
    
    #==================#
    #  HELPERS         #
    #==================#
    
    PRIVATE
    
    def GetAllFilesIn(cFolder)
        acFiles = []
        aToProcess = [cFolder]
        
        while len(aToProcess) > 0
            cCurrentPath = aToProcess[1]
            del(aToProcess, 1)
            
            _aList_ = @dir(cCurrentPath)
            nLen = len(_aList_)
            
            for i = 1 to nLen
                if _aList_[i][2] = 0  # File
                    acFiles + (cCurrentPath + "/" + _aList_[i][1])
                but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
                    aToProcess + (cCurrentPath + "/" + _aList_[i][1])
                ok
            next
        end
        
        return acFiles
