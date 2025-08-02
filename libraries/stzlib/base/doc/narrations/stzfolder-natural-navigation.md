# Natural Folder Navigation in Softanza

## The Core Principle

In Softanza, **your mental location follows your actions**. When you perform an operation in a folder, the system naturally updates your current position to reflect where you just worked. This eliminates the cognitive overhead of manually tracking your location.

## How It Works

Think of working in a real office. When you walk to the filing cabinet to create a new folder, you're naturally "at" the filing cabinet afterward:

```ring
# Start at your project root
oFolder = new stzFolder("/my-project")
? oFolder.CurrentPath()  
#--> "/my-project/"

# Create a source folder
oFolder.CreateFolder("src")
? oFolder.CurrentPath()  
#--> "/my-project/src/"

# Create a file - it goes in your current location
oFolder.CreateFile("main.ring")

# Create nested folders
oFolder.CreateFolder("components/ui")
? oFolder.CurrentPath()  
#--> "/my-project/src/components/ui/"
```

When you perform an action somewhere, that becomes your new "here."

## Explicit Navigation When Needed

You can always navigate explicitly when required:

```ring
oFolder = new stzFolder("/my-project")

# Explicit navigation methods
oFolder.GoTo("src/components")          # Navigate to specific path
oFolder.GoUp()                          # Move up one level  
oFolder.GoHome()                        # Return to original folder
oFolder.GoBack()                        # Return to previous location

# Check your location
? oFolder.CurrentPath()                 # Current working directory
? oFolder.IsAtHome()                    # Are we at the original folder?

# Navigation history and context
? oFolder.PathHistory()                 # See where you've been
? oFolder.NavigationInfo()              # Complete navigation state
```

### Combining Both Approaches

```ring
oFolder = new stzFolder("/webapp")

# Natural navigation through actions
oFolder.CreateFolder("api/users")       # Now in: /webapp/api/users/
oFolder.CreateFile("controller.ring")   # Creates in current location

# Explicit navigation when needed
oFolder.GoTo("../products")             # Move to: /webapp/api/products/
oFolder.CreateFile("controller.ring")   # Creates in current location

# Use history to return
oFolder.GoBack()                        # Back to: /webapp/api/users/
```

## Natural vs Classical Navigation

Standard Ring file operations, like all other languages, require constant manual path management:

```ring
# Classical Ring - explicit navigation everywhere
chdir("/my-project")
see "Create src directory: " + nl
if not direxists("/my-project/src")
    ? fopen("/my-project/src", "w")  # Using fopen to create directory
ok

chdir("/my-project/src")
write("main.ring", "# Main file")

# Manual navigation for each operation
chdir("/my-project")
if not direxists("/my-project/docs")
    ? fopen("/my-project/docs", "w")  # Create docs directory
ok

chdir("/my-project/docs")
write("README.md", "# Documentation")

# You constantly track location manually
see "Current directory operations complete" + nl
```

Softanza's natural navigation follows your actions:

```ring
# Softanza - location follows intent
oFolder = new stzFolder("/my-project")

oFolder.CreateFolder("src")          # Now in: /my-project/src/
oFolder.CreateFile("main.ring")      # Creates in current location

oFolder.CreateFolder("docs")         # Now in: /my-project/docs/  
oFolder.CreateFile("README.md")      # Creates in current location
```

The key difference: **action first, then navigation** vs. **navigate first, then action**.

## Navigation Patterns by Operation Type

Different operations have intuitive navigation behaviors:

### Creation Operations

```ring
oFolder.CreateFolder("api/routes")     # Navigate TO: /webapp/api/routes/
oFolder.CreateFile("users.ring")       # Navigate TO: /webapp/api/routes/
```

### File Operations

```ring
oFolder.FileRead("data/users.json")    # Navigate TO: /webapp/data/
oFolder.FileCopy("src/app.ring", "backup/app.ring")    # Navigate TO: /webapp/backup/
```

### Deletion Operations

```ring
oFolder.DeleteFolder("old-version")    # Navigate TO: parent folder
oFolder.DeleteFile("temp.log")         # Navigate TO: file's containing folder
```

## Batch Mode: Multiple Operations Without Moving

When you need to perform multiple operations across different locations without losing your mental position:

```ring
oFolder = new stzFolder("/my-project")

# Enter batch mode
oFolder.SetBatchMode(TRUE)

# Create various folders without moving your mental location
oFolder.CreateFolders([
	"temp/cache",
	"logs/debug", 
	"config/themes"
])

oFolder.CreateFiles([
	"docs/changelog.md",
	"src/main.ring"
])

# Your location hasn't changed!
? oFolder.CurrentPath()  
#--> "/my-project/"

# Exit batch mode - natural navigation resumes
oFolder.SetBatchMode(FALSE)
oFolder.CreateFolder("src")
? oFolder.CurrentPath()  
#--> "/my-project/src/"
```

## Practical Example: Project Setup

```ring
# Setting up a web project structure
oFolder = new stzFolder("/webapp")
oFolder {
	CreateFolder("public/css")      # Now in: /webapp/public/css/
	CreateFile("styles.css")        # Creates in current location

	CreateFolder("js")              # Now in: /webapp/public/js/
	CreateFile("app.js")            # Creates in current location

	GoHome()                        # Back to: /webapp/
	CreateFolder("server/routes")   # Now in: /webapp/server/routes/
}
```

## Error Handling and Safety

```ring
# Cannot navigate outside the folder boundary
oFolder.CreateFolder("../system")      # Raises error: "Can't navigate outside the folder!"

# File operations validate existence before navigation
oFolder.FileRead("missing.txt")        # Raises error: "cFile does not exist in the folder."

# Deletion operations handle edge cases gracefully  
oFolder.DeleteFolder("docs")           # Safely navigates to parent after deletion
```

## The Result

You spend less mental energy tracking where you are and more energy focused on what you're building. The system becomes an extension of your intent, automatically maintaining context as you work. Your code reads naturally, your mental model stays clear, and folder operations feel as intuitive as thinking about them.
