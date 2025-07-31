# Intelligent Folder Navigation in Softanza

## The Natural Way to Work with Folders

In Softanza, folder navigation follows a simple but powerful principle: **your mental location follows your actions**. When you perform an operation in a folder, the system intelligently updates your current position to reflect where you just worked. This eliminates the cognitive overhead of manually tracking your location while keeping your workflow natural and intuitive.

## How It Works

Think of it like working in a real office. When you walk to the filing cabinet to create a new folder, you're naturally "at" the filing cabinet afterward. Softanza's `stzFolder` class works the same way:

```ring
# Create a folder object starting at your project root

oFolder = new stzFolder("/my-project")

# Your current location

? oFolder.CurrentPath()  
#--> "/my-project/"

# Create a documentation folder

oFolder.CreateFolder("docs")

# Notice how your mental location has shifted

? oFolder.CurrentPath()  
#--> "/my-project/docs/"

# Create a file - it goes in your current location (docs)

oFolder.CreateFile("README.md", "# Project Documentation")

# Create another folder structure

oFolder.CreateFolder("assets/images")

# You're now mentally "in" the assets folder

? oFolder.CurrentPath()  
#--> "/my-project/assets/"
```

This behavior reflects how we naturally think: when we perform an action somewhere, that becomes our new "here."

## Batch Mode: When You Want to Stay Put

Sometimes you need to perform multiple operations across different locations without losing your mental position. This is where **Batch Mode** shines:

```ring
# You're working in your main project folder

oFolder = new stzFolder("/my-project")
? oFolder.CurrentPath()  
#--> "/my-project/"

# Enter batch mode for multiple operations
oFolder.SetBatchMode(TRUE)

# Create various folders without moving your mental location

oFolder.CreateFolders([
	"temp/cache",
	"logs/debug",
	"config/themes",
	"docs/changelog.md",
	"# Changes"
])

# Your mental location hasn't changed!

? oFolder.CurrentPath()  
#--> "/my-project/"

# Exit batch mode

oFolder.SetBatchMode(FALSE)

# Now normal behavior resumes
oFolder.CreateFolder("src")
? oFolder.CurrentPath()  
#--> "/my-project/src/"
```

## The Philosophy Behind It

This design respects how programmers actually think. You don't want to manually navigate like you're clicking through a file explorer. Instead, you want to focus on **what you're building** and **where it should go**, while the system intelligently keeps track of your context.

```ring
# Setting up a web project structure
oFolder = new stzFolder("/webapp")
oFolder {
	# Normal mode: each action updates your mental location

	CreateFolder("public/css")      # Now in: /webapp/public/
	CreateFile("styles.css", "...")  # Creates: /webapp/public/css/styles.css

	# Move to JavaScript area  

	CreateFolder("js")               # Now in: /webapp/public/js/
	CreateFile("app.js", "...")      # Creates: /webapp/public/js/app.js

	# Go back to root for server setup
	GoHome()                         # Back to: /webapp
	CreateFolder("server/routes")    # Now in: /webapp/server
}
```

> **Note**: Using Ring’s declarative object style with { and } eliminates the need to repeat oFolder. multiple times, creating a smoother and more expressive experience—much like a builder designing the rooms and furnishings of a home.

## Batch Mode in Practice

Batch mode is particularly powerful for initialization scripts, cleanup operations, or any workflow where you're orchestrating multiple changes across your folder structure:

```ring
def InitializeProject(cProjectPath)
    oFolder = new stzFolder(cProjectPath)
    
    # Stay mentally at the project root while creating structure
    oFolder.SetBatchMode(TRUE)
    
    # Create the entire folder structure

    oFolder.CreateFolders([
	"src/components",
	"src/utils",
	"tests/unit",
	"tests/integration",
	"docs/api",
	"config/environments"
	])
    
    # Create initial files

    oFolder.CreateFiles([
	"README.md", "# " + cProjectPath,
	"src/main.ring", "# Main application",
	"tests/test_runner.ring",
	"# Test suite"
	])
    
    oFolder.SetBatchMode(FALSE)
    
    # You're still at the project root, ready for the next phase

    ? "Project initialized at: " + oFolder.CurrentPath()

```

## The Result: Natural, Effortless Navigation

With this approach, you spend less mental energy tracking where you are and more energy focused on what you're building. The system becomes an extension of your intent, automatically maintaining context as you work.

Your code reads naturally, your mental model stays clear, and your folder operations feel as intuitive as thinking about them.