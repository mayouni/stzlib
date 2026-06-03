# Narrative
# --------
# Real-world example: Simulating a download progress
#
# Extracted from stzreactivetimertest.ring, block #6.

load "../../stzBase.ring"


# This example shows how timers can simulate real-world async operations
# like file downloads, data processing, or any long-running task

pr()

# Simulating a file download with progress updates...

# Run the download simulation
ds = new DownloadSimulator()
ds.StartDownload()

pf()

func UpdateProgress()
    ds.nProgress += 20
    
    if ds.nProgress <= 100
        cProgressBar = ""
        nFilledBars = floor(ds.nProgress / 10)
        nEmptyBars = 10 - nFilledBars
        
        for i = 1 to nFilledBars
            cProgressBar += "█"
        next

        for i = 1 to nEmptyBars  
            cProgressBar += "░"
        next
        
        ? "Progress: [" + cProgressBar + "] " + ds.nProgress + "%"
    ok

func CompleteDownload()
    ds.oReactive.StopTimer(ds.cProgressId)

    ? NL + "✔ Download completed successfully!"
    ? "File " + ds.cFileName + " is ready to use."

    ds.oReactive.Stop()

class DownloadSimulator
    nProgress = 0
    cDownloadId = ""
    cProgressId = ""
    oReactive = NULL
    cFileName = "large-file.zip"
    
    def Init()
        oReactive = new stzReactive()
        nProgress = 0
        cFileName = "large-file.zip"
        
    def StartDownload()
        ? "🔽 Starting download of " + cFileName + "..." + NL

        ? "Progress: [----------] 0%"
        
        oReactive {
            cProgressId = RunEvery(:UpdateProgress, 500)
            RunAfter(:CompleteDownload, 5000)
            
            Start()
        }

#--> Output:
# 🔽 Starting download of large-file.zip...

# Progress: [----------] 0%
# Progress: [██░░░░░░░░] 20%
# Progress: [████░░░░░░] 40%
# Progress: [██████░░░░] 60%
# Progress: [████████░░] 80%
# Progress: [██████████] 100%

# ✔ Download completed successfully!
# File large-file.zip is ready to use.

# Executed in 5.02 second(s) in Ring 1.23

#=======================================#
#  CRITICAL: NEVER USE Sleep() IN Rs{}  #
#=======================================#

# This example demonstrates why Sleep() blocks reactive systems
# and shows the correct timer-based approach
