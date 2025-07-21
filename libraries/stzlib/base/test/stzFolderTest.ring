# ================================== #
#  SOFTANZA FOLDER CLASS - TESTS     #
# ================================== #

load "../stzbase.ring"

/*--- Basic Folder Creation and Information

pr()

o1 = new stzFolder("C:\MyTestFolder")
o1 {

    # Display basic folder information
    
    Show()
    #--> Folder: MyTestFolder
    #    Path: C:\MyTestFolder
    #    Absolute path: C:\MyTestFolder
    #    Entries count: 0

}

pf()

/*--- Getting Folder Names and Paths

pr()

o1 = new stzFolder("/home/user/documents")
o1 {

    # Various ways to get folder information
    
    ? Name()
    #--> documents
    
    ? Name()  # Same as Name()
    #--> documents
    
    ? Path()
    #--> /home/user/documents
    
    ? AbsolutePath()
    #--> /home/user/documents
    
    ? CanonicalPath()
    #--> /home/user/documents

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Creating Folders and Directories

pr()

o1 = new stzFolder("C:\TestArea")
o1 {

    # Create a single directory
    
    ? Create("NewFolder")
    #--> TRUE (if successful)
    
    # Alternative naming
   	?  mkdir("AnotherFolder")	#--> TRUE
    ? CreateDir("ThirdFolder")	#--> TRUE
    
    # Create full path with subdirectories
    ? CreatePath("Level1\Level2\Level3")	#--> TRUE
    ? MakePath("Deep\Path\Structure")		#--> TRUE

}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Navigation and Path Changes

pr()

o1 = new stzFolder("C:\")
o1 {

    # Navigate to different directories
    
    ? Path()
    #--> C:/
    
    ChangeTo("Windows")
    ? Path()
    #--> C:/Windows
    
    GoUp()
    ? Path()
    #--> C:/
    
    MoveTo("Users")
    ? Path()
    #--> C:/Users

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Listing Directory Contents

pr()

o1 = new stzFolder("C:\Windows")
o1 {

    # Get all entries
    
    ? "Total entries: " + Count()
    #--> Total entries: 116
    
    aFiles = Files()
    ? "Files count: " + len(aFiles)
    #--> Files count: 32
    
    aFolders = Folders()
    ? "Folders count: " + len(aFolders)
    #--> Folders count: 86
    
    # Get files by extension
    aTxtFiles = FilesByExtension(".txt")
    ? "Text files: " + len(aTxtFiles)
    #--> Text files: 1

}

pf()
#--> Executed in almost 0 second(s) in Ring 1.22

/*--- File and Folder Existence Checking
*/
pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {

    # Check if paths and files exist
    
    ? Exists("")  # Check if current folder exists
    #--> TRUE
    
    ? PathExists("drivers")  # Check subfolder
    #--> TRUE
    
    ? Exists("notepad.exe")  # Check file
    #--> TRUE
    
    ? Exists("NonExistentFolder")
    #--> FALSE

}

pf()

/*--- Folder Status and Properties

pr()

o1 = new stzFolder("C:\Program Files")
o1 {

    # Check folder properties
    
    ? IsAbsolute()
    #--> TRUE
    
    ? IsReadable()
    #--> TRUE
    
    ? IsRoot()
    #--> FALSE
    
    ? IsEmpty()
    #--> FALSE
    
    ? HasFiles()
    #--> TRUE
    
    ? HasFolders()
    #--> TRUE

}

pf()

/*--- Filtering and Pattern Matching

pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {

    # Find files matching patterns
    
    aExeFiles = FindFiles("*.exe")
    ? "Executable files: " + len(aExeFiles)
    #--> Executable files: 234
    
    aDllFiles = Search("*.dll")
    ? "DLL files: " + len(aDllFiles)
    #--> DLL files: 1847
    
    # Find folders matching pattern
    aSystemFolders = FindFolders("*system*")
    ? "System folders: " + len(aSystemFolders)
    #--> System folders: 3

}

pf()

/*--- File and Folder Operations

pr()

o1 = new stzFolder("C:\TestArea")
o1 {

    # Create test files and folders first
    Create("TestFolder1")
    Create("TestFolder2")
    
    # Rename operations
    Rename("TestFolder1", "RenamedFolder")
    #--> TRUE
    
    # Remove operations
    Remove("TestFolder2")
    #--> TRUE
    
    RemoveDir("RenamedFolder")
    #--> TRUE

}

pf()

/*--- Working with File Paths

pr()

o1 = new stzFolder("C:\Users\John\Documents")
o1 {

    # Get various path formats for files
    
    ? FilePath("report.pdf")
    #--> C:\Users\John\Documents\report.pdf
    
    ? AbsoluteFilePath("data.xlsx")
    #--> C:\Users\John\Documents\data.xlsx
    
    ? RelativeFilePath("C:\Users\John\Documents\Projects\file.txt")
    #--> Projects\file.txt

}

pf()

/*--- Static Path Utilities

pr()

o1 = new stzFolder("")
o1 {

    # Get system paths
    
    ? CurrentPath()
    #--> C:\CurrentWorkingDirectory
    
    ? HomePath()
    #--> C:\Users\CurrentUser
    
    ? TempPath()
    #--> C:\Users\CurrentUser\AppData\Local\Temp
    
    ? RootPath()
    #--> C:\
    
    # Path manipulation
    ? CleanPath("C:\Users\..\Windows\System32")
    #--> C:\Windows\System32
    
    ? PathSeparator()
    #--> \ (on Windows) or / (on Unix)

}

pf()

/*--- Comprehensive Folder Information

pr()

o1 = new stzFolder("C:\Program Files\Microsoft Office")
o1 {

    # Get detailed folder information
    
    aInfo = Info()
    ? "Folder Information:"
    ? "=================="
    ? "Name: " + aInfo[:Name]
    ? "Path: " + aInfo[:Path]
    ? "Absolute: " + aInfo[:AbsolutePath]
    ? "Canonical: " + aInfo[:CanonicalPath]
    ? "Count: " + aInfo[:Count]
    ? "Is Absolute: " + aInfo[:IsAbsolute]
    ? "Is Readable: " + aInfo[:IsReadable]
    ? "Is Root: " + aInfo[:IsRoot]
    ? "Exists: " + aInfo[:Exists]

}

pf()

/*--- Tree View Display

pr()

o1 = new stzFolder("C:\SmallTestFolder")
o1 {

    # Display folder structure as tree
    
    TreeView()
    #--> 📁 SmallTestFolder
    #      📄 file1.txt
    #      📄 file2.doc
    #      📁 SubFolder1
    #        📄 nested.pdf
    #        📁 DeepFolder
    #          📄 deep.txt
    #      📁 SubFolder2
    #        📄 another.xlsx

}

pf()

/*--- Advanced Filtering and Sorting

pr()

o1 = new stzFolder("C:\Windows")
o1 {

    # Set custom filters
    
    SetFilters(["*.exe", "*.dll"])
    aFiltered = AllFiles()
    ? "Filtered files: " + len(aFiltered)
    #--> Filtered files: 156
    
    # Work with hidden files
    aHidden = HiddenFiles()
    ? "Hidden files: " + len(aHidden)
    #--> Hidden files: 12
    
    # Clear filters
    SetFilters([])

}

pf()

/*--- Folder Copying and Cloning

pr()

o1 = new stzFolder("C:\OriginalFolder")
o1 {

    # Create a copy reference to the same folder
    
    o2 = Copy()
    ? "Original path: " + Path()
    #--> Original path: C:\OriginalFolder
    
    ? "Copy path: " + o2.Path()
    #--> Copy path: C:\OriginalFolder
    
    # Both objects point to the same folder but are independent
    o2.ChangeTo("DifferentFolder")
    ? "Original still: " + Path()
    #--> Original still: C:\OriginalFolder
    
    ? "Copy changed to: " + o2.Path()
    #--> Copy changed to: C:\DifferentFolder

}

pf()

/*--- Path Format Conversions

pr()

o1 = new stzFolder("")
o1 {

    # Convert between path formats
    
    cWinPath = "C:\\Users\\John\\Documents"
    cUnixPath = "C:/Users/John/Documents"
    
    ? FromNativeSeparators(cWinPath)
    #--> C:/Users/John/Documents
    
    ? ToNativeSeparators(cUnixPath)
    #--> C:\Users\John\Documents (on Windows)
    
    # Check path types
    ? IsAbsolutePathXT("C:\Windows")
    #--> TRUE
    
    ? IsRelativePathXT("Documents\Files")
    #--> TRUE

}

pf()

/*--- Pattern Matching for Files

pr()

o1 = new stzFolder("C:\TestFiles")
o1 {

    # Test file pattern matching
    
    ? Match("*.txt", "readme.txt")
    #--> TRUE
    
    ? FileMatches("report.*", "report.pdf")
    #--> TRUE
    
    ? Matches("temp*", "temporary.log")
    #--> TRUE
    
    ? Match("*.exe", "document.pdf")
    #--> FALSE

}

pf()

/*--- Current Directory Management

pr()

o1 = new stzFolder("")
o1 {

    # Manage current working directory
    
    cOriginal = CurrentPath()
    ? "Current: " + cOriginal
    #--> Current: C:\CurrentWorkingDir
    
    SetCurrentPath("C:\Windows")
    ? "Changed to: " + CurrentPath()
    #--> Changed to: C:\Windows
    
    # Restore original
    SetCurrentPath(cOriginal)
    ? "Restored to: " + CurrentPath()
    #--> Restored to: C:\CurrentWorkingDir

}

pf()

/*--- Folder State Verification

pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {

    # Various ways to check folder state
    
    ? "Is folder: " + IsFolder()
    #--> Is folder: TRUE
    
    ? "Is a directory: " + IsADir()
    #--> Is a directory: TRUE
    
    ? "Has content: " + HasContent()
    #--> Has content: TRUE
    
    ? "Not empty: " + NotEmpty()
    #--> Not empty: TRUE
    
    ? "Contains files: " + ContainsFiles()
    #--> Contains files: TRUE
    
    ? "Contains subdirs: " + ContainsSubDirs()
    #--> Contains subdirs: TRUE

}

pf()

/*--- Fluent Interface Usage

pr()

o1 = new stzFolder("C:\TestArea")
o1 {

    # Chain operations using fluent interface
    
    SetPath("C:\Windows").
    SetFilters(["*.log"]).
    SetCurrentPath(Path()).
    Refresh().
    Show()
    
    #--> Folder: Windows
    #    Path: C:\Windows
    #    Absolute path: C:\Windows
    #    Entries count: 234

}

pf()

/*--- Multiple File Type Search

pr()

o1 = new stzFolder("C:\Users\Documents")
o1 {

    # Search for multiple file types
    
    aDocFiles = FilesByExtension("doc")
    aPdfFiles = FilesByType(".pdf")  # Alternative name
    aTxtFiles = FilesByExtension(".txt")
    
    ? "Word documents: " + len(aDocFiles)
    #--> Word documents: 15
    
    ? "PDF files: " + len(aPdfFiles)
    #--> PDF files: 8
    
    ? "Text files: " + len(aTxtFiles)
    #--> Text files: 23

}

pf()

/*--- Advanced Directory Operations

pr()

o1 = new stzFolder("C:\TempTest")
o1 {

    # Complex directory operations
    
# Create nested structure
    CreatePath("Level1\Level2\Level3")
    CreatePath("ProjectA\Docs\Reports")
    CreatePath("ProjectA\Code\Source")
    
    # Navigate and create files in different locations
    ChangeTo("Level1\Level2")
    Create("SubLevel")
    
    # Go back to root and show structure
    SetPath("C:\TempTest")
    TreeView()
    #--> 📁 TempTest
    #      📁 Level1
    #        📁 Level2
    #          📁 Level3
    #          📁 SubLevel
    #      📁 ProjectA
    #        📁 Docs
    #          📁 Reports
    #        📁 Code
    #          📁 Source
    
    # Clean up - remove all created directories
    RemoveRecursively()
    #--> TRUE

}

pf()

/*--- Recursive Directory Removal

pr()

o1 = new stzFolder("C:\DeepTestFolder")
o1 {

    # Create complex nested structure
    CreatePath("A\B\C\D\E")
    CreatePath("X\Y\Z")
    CreatePath("Root\Branch1\Leaf1")
    CreatePath("Root\Branch2\Leaf2")
    
    ? "Created structure with " + Count() + " entries"
    #--> Created structure with 3 entries
    
    # Remove everything recursively
    DeleteAll()  # Same as RemoveRecursively()
    #--> TRUE
    
    ? "After cleanup: " + Exists("")
    #--> After cleanup: FALSE

}

pf()

/*--- Working with Different Path Formats

pr()

o1 = new stzFolder("")
o1 {

    # Test various path scenarios
    
    aTestPaths = [
        "C:\Windows\System32",
        "/home/user/documents",
        ".\relative\path",
        "..\parent\folder",
        "~/Desktop",
        "simple_folder"
    ]
    
    for cPath in aTestPaths
        ? "Path: " + cPath
        ? "  Is Absolute: " + IsAbsolutePathXT(cPath)
        ? "  Is Relative: " + IsRelativePathXT(cPath) 
        ? "  Clean Path: " + CleanPath(cPath)
        ? "---"
    next

}

pf()

/*--- Folder Comparison and Utilities

pr()

o1 = new stzFolder("C:\Windows")
o2 = new stzFolder("C:\Program Files")

? "Comparing two folders:"
? "====================="

o1 {
    ? "Folder 1: " + Name() + " (" + Count() + " entries)"
}

o2 {
    ? "Folder 2: " + Name() + " (" + Count() + " entries)"
}

# Clone and modify
o3 = o1.Clone()
o3.SetPath("C:\Users")

o3 {
    ? "Cloned folder changed to: " + Name() + " (" + Count() + " entries)"
}

pf()

/*--- Error Handling and Edge Cases

pr()

o1 = new stzFolder("C:\NonExistentFolder")
o1 {

    # Test operations on non-existent folder
    
    ? "Folder exists: " + Exists("")
    #--> Folder exists: FALSE
    
    ? "Count: " + Count()
    #--> Count: 0
    
    ? "Is readable: " + IsReadable()
    #--> Is readable: FALSE
    
    ? "Is empty: " + IsEmpty()
    #--> Is empty: TRUE
    
    # Try to create it
    if Create(".")
        ? "Successfully created folder"
        Show()
    else
        ? "Failed to create folder"
    end

}

pf()

/*--- Advanced File System Operations

pr()

o1 = new stzFolder("C:\TestOperations")
o1 {

    # Ensure clean start
    if Exists("")
        RemoveRecursively()
    end
    
    # Create the base folder
    CreatePath(".")
    
    # Create test structure
    Create("Folder1")
    Create("Folder2") 
    Create("EmptyFolder")
    
    # Simulate file creation (would need actual file operations)
    # For demonstration, we'll work with folder operations only
    
    ChangeTo("Folder1")
    Create("SubA")
    Create("SubB")
    
    Up()  # Go back to TestOperations
    
    ? "Structure created:"
    TreeView()
    
    # Test folder properties
    ? "Folder1 has subfolders: " + 
      new stzFolder(FilePath("Folder1")).HasFolders()
    #--> Folder1 has subfolders: TRUE
    
    ? "EmptyFolder is empty: " + 
      new stzFolder(FilePath("EmptyFolder")).IsEmpty()
    #--> EmptyFolder is empty: TRUE
    
    # Cleanup
    RemoveAll()

}

pf()

/*--- Cross-Platform Path Handling

pr()

o1 = new stzFolder("")
o1 {

    # Test path separator handling
    
    ? "Current separator: '" + chr(PathSeparator()) + "'"
    
    # Test conversion between formats
    cMixedPath = "C:/Windows\System32/drivers"
    ? "Mixed path: " + cMixedPath
    ? "To native: " + ToNativeSeparators(cMixedPath)
    ? "From native: " + FromNativeSeparators(cMixedPath)
    
    # Path cleaning examples
    aMesyPaths = [
        "C:\Users\..\Windows",
        "/home/user/../user/documents",
        ".\folder\.\subfolder\..",
        "C:\Windows\System32\..\System"
    ]
    
    ? "Path cleaning examples:"
    for cPath in aMesyPaths
        ? "  " + cPath + " -> " + CleanPath(cPath)
    next

}

pf()

/*--- Final Integration Test

pr()

? "Final Integration Test"
? "====================="

o1 = new stzFolder("C:\IntegrationTest")
o1 {

    # Complete workflow test
    
    # 1. Setup
    if Exists("")
        RemoveRecursively()
    end
    
    CreatePath(".")
    ? "✓ Base folder created"
    
    # 2. Structure creation
    CreatePath("Projects\WebApp\Frontend")
    CreatePath("Projects\WebApp\Backend")
    CreatePath("Projects\MobileApp\iOS")
    CreatePath("Projects\MobileApp\Android")
    CreatePath("Documentation\API")
    CreatePath("Documentation\User")
    
    ? "✓ Project structure created"
    
    # 3. Navigation and inspection
    ? "Total entries in root: " + Count()
    
    ChangeTo("Projects")
    ? "Entries in Projects: " + Count()
    
    SetPath(AbsolutePath() + "\WebApp")  
    ? "Entries in WebApp: " + Count()
    
    # 4. Display final structure
    SetPath("C:\IntegrationTest")
    ? "Final project structure:"
    TreeView()
    
    # 5. Information summary
    aInfo = Info()
    ? "Integration test completed successfully!"
    ? "Base path: " + aInfo[:AbsolutePath]
    ? "Total structure entries: " + aInfo[:Count]
    
    # 6. Cleanup
    RemoveRecursively()
    ? "✓ Cleanup completed"

}

pf()
