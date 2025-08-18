load "../stzbase.ring"


/*--- Example 1: Basic file operations
*/
pr()
	o1 = new stzReactive()
	fs = new stzReactiveFileSystem(o1)
	
	# Read a file
	fs.ReadFile("test.txt", func(content) {
		? "File content: " + content
	}, func(error) {
		? "Error: " + error
	})
	
	# Write a file
	fs.WriteFile("output.txt", "Hello World", func(result) {
		? result
	}, func(error) {
		? "Write error: " + error
	})
pf()

/*--- Example 2: File watching
	
	watcher = fs.WatchFile("config.txt", func(event) {
		? "File changed: " + event.type + " at " + event.path
	}, func(error) {
		? "Watch error: " + error
	})

/*--- Example 3: Directory operations
	
	fs.ListDirectory("/home/user", func(entries) {
		for entry in entries
			? entry.name + " (" + entry.type + ")"
		next
	}, func(error) {
		? "List error: " + error
	})

/*--- Example 4: Chaining operations
	
	operations = [
		["type" = "read", "path" = "input.txt"],
		["type" = "write", "path" = "backup.txt", "content" = ""],
		["type" = "delete", "path" = "temp.txt"]
	]
	
	utils = new stzReactiveFileUtils()
	utils.Init(engine)
	utils.ChainOperations(operations, func(results) {
		? "All operations completed"
		for result in results
			? result
		next
	}, func(error) {
		? "Chain error: " + error
	})

/*--- Example 5: File streaming for large files
	
	streamer = fs.StreamFile("large_file.dat", 8192, func(chunk) {
		? "Received chunk: " + chunk.size + " bytes at offset " + chunk.offset
		# Process chunk.data here
	}, func() {
		? "File streaming completed"
	}, func(error) {
		? "Stream error: " + error
	})
