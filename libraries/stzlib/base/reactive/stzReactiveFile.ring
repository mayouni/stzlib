#----------------------------------------------#
#  REACTIVE FILE SYSTEM - For file operations  #
#----------------------------------------------#

class stzReactiveFileSystem

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def ReadFile(filePath, onSuccess, onError)
		task = new stzFileTask("file_read", filePath, "read", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def WriteFile(filePath, content, onSuccess, onError)
		task = new stzFileTask("file_write", filePath, "write", content, engine)
		task.Then_(onSuccess) 
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def WatchFile(filePath, onChange)
		watcher = new stzFileWatcher(filePath, onChange, engine)
		engine.AddStream(watcher)
		watcher.Start()
		return watcher

class stzFileTask from stzReactiveTask

	filePath = ""
	operation = "read"
	content = NULL
	
	def Init(id, path, op, data, engine)
		super.Init(id, NULL, engine)
		filePath = path
		operation = op
		content = data
		
	def Execute()
		try
			status = "running"
			if operation = "read"
				result = read(filePath)
			else
				write(filePath, content)
				result = "File written successfully"
			ok
			status = "completed"
			if onComplete != NULL
				call onComplete(result)
			ok
		catch
			status = "error"
			if onError != NULL
				call onError("File operation failed")
			ok
		done

class stzFileWatcher from stzReactiveStream

	filePath = ""
	
	def Init(path, changeCallback, engine)
		super.Init("file_watch_" + path, "timer", engine)
		filePath = path
		Subscribe(changeCallback)
		
	def Start()
		super.Start()
		# In real implementation, use LibUV file system events
		# For now, simulate with timer-based polling
		watcher = new stzReactiveTimer("watcher_" + filePath, 1000, Method(:CheckFile), engine)
		engine.AddTimer(watcher)
		watcher.Start()
		
	def CheckFile()
		# Simplified file change detection
		# In real implementation, use proper file system events
		Emit("File changed: " + filePath)
