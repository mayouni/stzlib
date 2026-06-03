# Narrative
# --------
# DOCKER DEPLOYMENT
#
# Extracted from stzsystemcalldatatest.ring, block #18.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Build image
new stzSystemCall(:DockerBuild) {
	SetParam(:tag, "myapp:latest")
	Run()
	? Output()
}

# Run container
Sy = new stzSystemCall(:DockerRun)
Sy {
	SetParam(:image, "myapp:latest")
	Run()
	cContainerId = Output()
	? "Container: " + cContainerId
}

# List running containers
? new stzSystemCall(:DockerPs).Run()

pf()
