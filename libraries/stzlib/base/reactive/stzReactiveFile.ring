# =============================================================================
# SOFTANZA REACTIVE FILE SYSTEM - Using LibUV for true async operations
# =============================================================================

class stzReactiveFileSystem

	engine = NULL
	
	def Init(engine)
		engine = engine
		
	def ReadFile(filePath, onSuccess, onError)
		task = new stzLibUVFileTask("file_read", filePath, "read", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def WriteFile(filePath, content, onSuccess, onError)
		task = new stzLibUVFileTask("file_write", filePath, "write", content, engine)
		task.Then_(onSuccess) 
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def StatFile(filePath, onSuccess, onError)
		task = new stzLibUVFileTask("file_stat", filePath, "stat", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def DeleteFile(filePath, onSuccess, onError)
		task = new stzLibUVFileTask("file_delete", filePath, "unlink", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def CopyFile(sourcePath, destPath, onSuccess, onError)
		task = new stzLibUVFileTask("file_copy", sourcePath, "copy", destPath, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def MakeDirectory(dirPath, onSuccess, onError)
		task = new stzLibUVFileTask("dir_create", dirPath, "mkdir", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def RemoveDirectory(dirPath, onSuccess, onError)
		task = new stzLibUVFileTask("dir_remove", dirPath, "rmdir", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def ListDirectory(dirPath, onSuccess, onError)
		task = new stzLibUVFileTask("dir_scan", dirPath, "scandir", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def WatchFile(filePath, onChange, onError)
		watcher = new stzLibUVFileWatcher(filePath, onChange, onError, engine)
		engine.AddStream(watcher)
		watcher.Start()
		return watcher

	def PollFile(filePath, interval, onChange, onError)
		poller = new stzLibUVFilePoll(filePath, interval, onChange, onError, engine)
		engine.AddStream(poller)
		poller.Start()
		return poller

	def CopyDirectory(sourcePath, destPath, onProgress, onSuccess, onError)
		copier = new stzDirectoryCopier(sourcePath, destPath, onProgress, onSuccess, onError, engine)
		copier.Execute()
		return copier

	def BackupFile(filePath, backupPath, onSuccess, onError)
		# Create backup with timestamp
		timestamp = string(clock())
		actualBackupPath = backupPath + "_" + timestamp
		return CopyFile(filePath, actualBackupPath, onSuccess, onError)

	def SyncDirectories(source, dest, onProgress, onSuccess, onError)
		syncer = new stzDirectorySyncer(source, dest, onProgress, onSuccess, onError, engine)
		syncer.Execute()
		return syncer

# =============================================================================
# LIBUV-POWERED FILE TASK - True async file operations
# =============================================================================

class stzLibUVFileTask from stzReactiveTask

	filePath = ""
	operation = "read"
	content = NULL
	destPath = NULL  # For copy operations
	fsReq = NULL
	fileHandle = NULL
	mode = 0
	
	def Init(id, path, op, data, engine)
		super.Init(id, NULL, engine)
		filePath = path
		operation = op
		content = data
		if operation = "copy"
			destPath = data
		ok
		mode = 0644  # Default file permissions
		
	def Execute()
		status = "running"
		
		# Create LibUV filesystem request
		fsReq = new_uv_fs_t()
		
		switch operation
		case "read"
			ExecuteRead()
		case "write"
			ExecuteWrite()
		case "stat"
			ExecuteStat()
		case "unlink"
			ExecuteDelete()
		case "copy"
			ExecuteCopy()
		case "mkdir"
			ExecuteMakeDir()
		case "rmdir"
			ExecuteRemoveDir()
		case "scandir"
			ExecuteScanDir()
		end
		
	def ExecuteRead()
		# First open the file
		result = uv_fs_open(engine.myLoop, fsReq, filePath, UV_FS_O_RDONLY, 0, Method(:OnFileOpened))
		if result < 0
			HandleError("Failed to open file for reading")
		ok
		
	def OnFileOpened(req)
		fileHandle = uv_fs_get_result(req)
		if fileHandle < 0
			HandleError("Failed to open file")
			return
		ok
		
		# Get file size first
		statReq = new_uv_fs_t()
		uv_fs_fstat(engine.myLoop, statReq, fileHandle, Method(:OnFileStat))
		
	def OnFileStat(req)
		stat = uv_fs_get_statbuf(req)
		fileSize = uv_fs_stat_get_size(stat)
		
		# Allocate buffer and read file
		buf = space(fileSize)
		bufs = [buf]
		uv_fs_read(engine.myLoop, fsReq, fileHandle, bufs, 1, 0, Method(:OnFileRead))
		
	def OnFileRead(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("Failed to read file")
		else
			# Get the buffer content
			buf = uv_fs_get_ptr(req)
			content = space_to_string(buf, result)
			
			# Close file and complete
			uv_fs_close(engine.myLoop, fsReq, fileHandle, Method(:OnFileReadComplete))
		ok
		
	def OnFileReadComplete(req)
		status = "completed"
		if onComplete != NULL
			call onComplete(content)
		ok
		Cleanup()
		
	def ExecuteWrite()
		# Create/open file for writing
		flags = UV_FS_O_CREAT + UV_FS_O_WRONLY + UV_FS_O_TRUNC
		result = uv_fs_open(engine.myLoop, fsReq, filePath, flags, mode, Method(:OnFileOpenedForWrite))
		if result < 0
			HandleError("Failed to open file for writing")
		ok
		
	def OnFileOpenedForWrite(req)
		fileHandle = uv_fs_get_result(req)
		if fileHandle < 0
			HandleError("Failed to open file for writing")
			return
		ok
		
		# Convert content to buffer and write
		buf = string_to_space(content)
		bufs = [buf]
		uv_fs_write(engine.myLoop, fsReq, fileHandle, bufs, 1, 0, Method(:OnFileWritten))
		
	def OnFileWritten(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("Failed to write file")
		else
			# Close file and complete
			uv_fs_close(engine.myLoop, fsReq, fileHandle, Method(:OnFileWriteComplete))
		ok
		
	def OnFileWriteComplete(req)
		status = "completed"
		result = "File written successfully: " + filePath
		if onComplete != NULL
			call onComplete(result)
		ok
		Cleanup()
		
	def ExecuteStat()
		result = uv_fs_stat(engine.myLoop, fsReq, filePath, Method(:OnStatComplete))
		if result < 0
			HandleError("Failed to stat file")
		ok
		
	def OnStatComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("File stat failed")
		else
			stat = uv_fs_get_statbuf(req)
			fileInfo = new stzReactiveFileInfo()
			fileInfo.size = uv_fs_stat_get_size(stat)
			fileInfo.mtime = uv_fs_stat_get_mtime(stat)
			fileInfo.isFile = uv_fs_stat_is_file(stat)
			fileInfo.isDirectory = uv_fs_stat_is_dir(stat)
			fileInfo.path = filePath
			
			status = "completed"
			if onComplete != NULL
				call onComplete(fileInfo)
			ok
		ok
		Cleanup()
		
	def ExecuteDelete()
		result = uv_fs_unlink(engine.myLoop, fsReq, filePath, Method(:OnDeleteComplete))
		if result < 0
			HandleError("Failed to delete file")
		ok
		
	def OnDeleteComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("File deletion failed")
		else
			status = "completed"
			result = "File deleted successfully: " + filePath
			if onComplete != NULL
				call onComplete(result)
			ok
		ok
		Cleanup()
		
	def ExecuteCopy()
		flags = 0  # Default copy flags
		result = uv_fs_copyfile(engine.myLoop, fsReq, filePath, destPath, flags, Method(:OnCopyComplete))
		if result < 0
			HandleError("Failed to copy file")
		ok
		
	def OnCopyComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("File copy failed")
		else
			status = "completed"
			result = "File copied successfully: " + filePath + " -> " + destPath
			if onComplete != NULL
				call onComplete(result)
			ok
		ok
		Cleanup()
		
	def ExecuteMakeDir()
		result = uv_fs_mkdir(engine.myLoop, fsReq, filePath, mode, Method(:OnMkdirComplete))
		if result < 0
			HandleError("Failed to create directory")
		ok
		
	def OnMkdirComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("Directory creation failed")
		else
			status = "completed"
			result = "Directory created successfully: " + filePath
			if onComplete != NULL
				call onComplete(result)
			ok
		ok
		Cleanup()
		
	def ExecuteRemoveDir()
		result = uv_fs_rmdir(engine.myLoop, fsReq, filePath, Method(:OnRmdirComplete))
		if result < 0
			HandleError("Failed to remove directory")
		ok
		
	def OnRmdirComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("Directory removal failed")
		else
			status = "completed"
			result = "Directory removed successfully: " + filePath
			if onComplete != NULL
				call onComplete(result)
			ok
		ok
		Cleanup()
		
	def ExecuteScanDir()
		flags = 0
		result = uv_fs_scandir(engine.myLoop, fsReq, filePath, flags, Method(:OnScandirComplete))
		if result < 0
			HandleError("Failed to scan directory")
		ok
		
	def OnScandirComplete(req)
		result = uv_fs_get_result(req)
		if result < 0
			HandleError("Directory scan failed")
		else
			# Extract directory entries
			entries = []
			while true
				entry = uv_fs_scandir_next(req)
				if entry = NULL
					exit
				ok
				entryInfo = new stzDirEntry()
				entryInfo.name = uv_dirent_get_name(entry)
				entryInfo.type = uv_dirent_get_type(entry)
				entries + entryInfo
			end
			
			status = "completed"
			if onComplete != NULL
				call onComplete(entries)
			ok
		ok
		Cleanup()
		
	def HandleError(errorMsg)
		status = "error"
		if onError != NULL
			call onError(errorMsg + ": " + filePath)
		ok
		Cleanup()
		
	def Cleanup()
		if fsReq != NULL
			destroy_uv_fs_t(fsReq)
			fsReq = NULL
		ok

# =============================================================================
# FILE INFO STRUCTURE
# =============================================================================

class stzReactiveFileInfo
	path = ""
	size = 0
	mtime = 0
	isFile = false
	isDirectory = false
	
	def GetSizeFormatted()
		if size < 1024
			return string(size) + " bytes"
		but size < 1048576
			return string(size / 1024) + " KB"
		else
			return string(size / 1048576) + " MB"
		ok

class stzDirEntry
	name = ""
	type = 0  # UV_DIRENT_FILE, UV_DIRENT_DIR, etc.
	
	def IsFile()
		return type = UV_DIRENT_FILE
		
	def IsDirectory()
		return type = UV_DIRENT_DIR

# =============================================================================
# LIBUV FILE WATCHER - Real-time file system events
# =============================================================================

class stzLibUVFileWatcher from stzReactiveStream

	filePath = ""
	fsEventHandle = NULL
	changeCallback = NULL
	errorCallback = NULL
	
	def Init(path, onChange, onError, engine)
		super.Init("file_watch_" + path, "libuv", engine)
		filePath = path
		changeCallback = onChange
		errorCallback = onError
		Subscribe(onChange)
		if onError != NULL
			OnError(onError)
		ok
		
	def Start()
		super.Start()
		
		# Create LibUV fs_event handle
		fsEventHandle = new_uv_fs_event_t()
		uv_fs_event_init(engine.myLoop, fsEventHandle)
		
		# Start watching for file changes
		flags = UV_FS_EVENT_WATCH_ENTRY  # Watch the file/directory entry
		result = uv_fs_event_start(fsEventHandle, Method(:OnFileChanged), filePath, flags)
		
		if result < 0
			EmitError("Failed to start file watcher for: " + filePath)
		ok
		
	def OnFileChanged(handle, filename, events, status)
		if status < 0
			EmitError("File watch error: " + string(status))
			return
		ok
		
		# Create event info
		eventInfo = new stzFileChangeEvent()
		eventInfo.path = filePath
		eventInfo.filename = filename
		eventInfo.events = events
		eventInfo.timestamp = clock()
		
		# Determine event type
		if (events & UV_FS_EVENT_RENAME) != 0
			eventInfo.type = "rename"
		but (events & UV_FS_EVENT_CHANGE) != 0
			eventInfo.type = "change"
		else
			eventInfo.type = "unknown"
		ok
		
		# Emit the change event
		Emit(eventInfo)
		
	def Stop()
		super.Stop()
		if fsEventHandle != NULL
			uv_fs_event_stop(fsEventHandle)
		ok
		
	def Cleanup()
		Stop()
		if fsEventHandle != NULL
			destroy_uv_fs_event_t(fsEventHandle)
			fsEventHandle = NULL
		ok

# =============================================================================
# LIBUV FILE POLL - Periodic file monitoring with stat checking
# =============================================================================

class stzLibUVFilePoll from stzReactiveStream

	filePath = ""
	interval = 1000  # milliseconds
	fsPollHandle = NULL
	changeCallback = NULL
	errorCallback = NULL
	lastStat = NULL
	
	def Init(path, intervalMs, onChange, onError, engine)
		super.Init("file_poll_" + path, "libuv", engine)
		filePath = path
		interval = intervalMs
		changeCallback = onChange
		errorCallback = onError
		Subscribe(onChange)
		if onError != NULL
			OnError(onError)
		ok
		
	def Start()
		super.Start()
		
		# Create LibUV fs_poll handle
		fsPollHandle = new_uv_fs_poll_t()
		uv_fs_poll_init(engine.myLoop, fsPollHandle)
		
		# Start polling for file changes
		result = uv_fs_poll_start(fsPollHandle, Method(:OnFilePoll), filePath, interval)
		
		if result < 0
			EmitError("Failed to start file poller for: " + filePath)
		ok
		
	def OnFilePoll(handle, status, prev, curr)
		if status < 0
			EmitError("File poll error: " + string(status))
			return
		ok
		
		# Create change event with detailed stat info
		changeEvent = new stzFilePollEvent()
		changeEvent.path = filePath
		changeEvent.status = status
		changeEvent.timestamp = clock()
		
		if prev != NULL
			changeEvent.previousStat = ExtractStatInfo(prev)
		ok
		
		if curr != NULL
			changeEvent.currentStat = ExtractStatInfo(curr)
		ok
		
		# Determine what changed
		if prev != NULL and curr != NULL
			if uv_fs_stat_get_mtime(prev) != uv_fs_stat_get_mtime(curr)
				changeEvent.changed = "modified"
			but uv_fs_stat_get_size(prev) != uv_fs_stat_get_size(curr)
				changeEvent.changed = "size"
			else
				changeEvent.changed = "other"
			ok
		but curr != NULL and prev = NULL
			changeEvent.changed = "created"
		but curr = NULL and prev != NULL
			changeEvent.changed = "deleted"
		ok
		
		# Emit the poll event
		Emit(changeEvent)
		
	def ExtractStatInfo(stat)
		info = new stzReactiveFileInfo()
		info.size = uv_fs_stat_get_size(stat)
		info.mtime = uv_fs_stat_get_mtime(stat)
		info.isFile = uv_fs_stat_is_file(stat)
		info.isDirectory = uv_fs_stat_is_dir(stat)
		info.path = filePath
		return info
		
	def Stop()
		super.Stop()
		if fsPollHandle != NULL
			uv_fs_poll_stop(fsPollHandle)
		ok
		
	def Cleanup()
		Stop()
		if fsPollHandle != NULL
			destroy_uv_fs_poll_t(fsPollHandle)
			fsPollHandle = NULL
		ok

# =============================================================================
# FILE SYSTEM EVENT STRUCTURES
# =============================================================================

class stzFileChangeEvent
	path = ""
	filename = ""
	type = ""  # "change", "rename", "unknown"
	events = 0
	timestamp = 0

class stzFilePollEvent
	path = ""
	status = 0
	changed = ""  # "created", "deleted", "modified", "size", "other"
	previousStat = NULL
	currentStat = NULL
	timestamp = 0

# =============================================================================
# ENHANCED FILE UTILITIES
# =============================================================================

class stzReactiveFileUtils

	engine = NULL
	
	def Init(engine)
		this.engine = engine

	# Chain multiple file operations
	def ChainOperations(operations, onSuccess, onError)
		chain = new stzFileOperationChain(operations, onSuccess, onError, engine)
		chain.Execute()
		return chain

	# Batch file operations
	def BatchProcess(files, operation, onProgress, onComplete, onError)
		batch = new stzFileBatchProcessor(files, operation, onProgress, onComplete, onError, engine)
		batch.Execute()
		return batch

	# Stream large files in chunks
	def StreamFile(filePath, chunkSize, onChunk, onComplete, onError)
		streamer = new stzFileStreamer(filePath, chunkSize, onChunk, onComplete, onError, engine)
		streamer.Start()
		return streamer

class stzFileOperationChain

	operations = []
	currentIndex = 1
	results = []
	onSuccess = NULL
	onError = NULL
	engine = NULL
	
	def Init(ops, onSuccess, onError, engine)
		operations = ops
		this.onSuccess = onSuccess
		this.onError = onError
		this.engine = engine
		currentIndex = 1
		results = []
		
	def Execute()
		if len(operations) = 0
			if onSuccess != NULL
				call onSuccess(results)
			ok
			return
		ok
		
		ExecuteNext()
		
	def ExecuteNext()
		if currentIndex > len(operations)
			# All operations completed
			if onSuccess != NULL
				call onSuccess(results)
			ok
			return
		ok
		
		op = operations[currentIndex]
		opType = op["type"]
		opPath = op["path"]
		
		switch opType
		case "read"
			task = new stzLibUVFileTask("chain_read", opPath, "read", NULL, engine)
		case "write"
			content = op["content"]
			task = new stzLibUVFileTask("chain_write", opPath, "write", content, engine)
		case "delete"
			task = new stzLibUVFileTask("chain_delete", opPath, "unlink", NULL, engine)
		# Add more operation types as needed
		end
		
		task.Then_(Method(:OnOperationSuccess))
		task.Catch_(Method(:OnOperationError))
		task.Execute()
		
	def OnOperationSuccess(result)
		results + result
		currentIndex++
		ExecuteNext()
		
	def OnOperationError(error)
		if onError != NULL
			call onError(error)
		ok

class stzFileBatchProcessor

	files = []
	operation = ""
	processed = 0
	results = []
	onProgress = NULL
	onComplete = NULL
	onError = NULL
	engine = NULL
	
	def Init(fileList, op, onProgress, onComplete, onError, engine)
		files = fileList
		operation = op
		this.onProgress = onProgress
		this.onComplete = onComplete
		this.onError = onError
		this.engine = engine
		processed = 0
		results = []
		
	def Execute()
		for file in files
			ProcessFile(file)
		next
		
	def ProcessFile(filePath)
		task = new stzLibUVFileTask("batch_" + operation, filePath, operation, NULL, engine)
		task.Then_(Method(:OnFileProcessed))
		task.Catch_(Method(:OnFileError))
		task.Execute()
		
	def OnFileProcessed(result)
		processed++
		results + result
		
		if onProgress != NULL
			progress = new stzBatchProgress()
			progress.processed = processed
			progress.total = len(files)
			progress.percentage = (processed * 100.0) / len(files)
			progress.lastResult = result
			call onProgress(progress)
		ok
		
		# Check if all files are processed
		if processed >= len(files)
			if onComplete != NULL
				call onComplete(results)
			ok
		ok
		
	def OnFileError(error)
		if onError != NULL
			call onError(error)
		ok

class stzBatchProgress
	processed = 0
	total = 0
	percentage = 0.0
	lastResult = NULL

class stzFileStreamer from stzReactiveStream

	filePath = ""
	chunkSize = 4096
	onChunk = NULL
	onComplete = NULL
	onError = NULL
	fileHandle = NULL
	fileSize = 0
	bytesRead = 0
	
	def Init(path, size, onChunk, onComplete, onError, engine)
		super.Init("file_stream_" + path, "libuv", engine)
		filePath = path
		chunkSize = size
		this.onChunk = onChunk
		this.onComplete = onComplete
		this.onError = onError
		Subscribe(onChunk)
		if onError != NULL
			OnError(onError)
		ok
		if onComplete != NULL
			OnComplete(onComplete)
		ok
		
	def Start()
		super.Start()
		
		# Open file for reading
		fsReq = new_uv_fs_t()
		result = uv_fs_open(engine.myLoop, fsReq, filePath, UV_FS_O_RDONLY, 0, Method(:OnFileOpened))
		if result < 0
			EmitError("Failed to open file for streaming")
		ok
		
	def OnFileOpened(req)
		fileHandle = uv_fs_get_result(req)
		if fileHandle < 0
			EmitError("Failed to open file")
			return
		ok
		
		# Get file size
		statReq = new_uv_fs_t()
		uv_fs_fstat(engine.myLoop, statReq, fileHandle, Method(:OnFileStat))
		
	def OnFileStat(req)
		stat = uv_fs_get_statbuf(req)
		fileSize = uv_fs_stat_get_size(stat)
		bytesRead = 0
		
		# Start reading chunks
		ReadNextChunk()
		
	def ReadNextChunk()
		if bytesRead >= fileSize
			# File completely read
			CloseAndComplete()
			return
		ok
		
		# Calculate chunk size for this read
		remainingBytes = fileSize - bytesRead
		currentChunkSize = min(chunkSize, remainingBytes)
		
		# Allocate buffer and read chunk
		buf = space(currentChunkSize)
		bufs = [buf]
		
		fsReq = new_uv_fs_t()
		uv_fs_read(engine.myLoop, fsReq, fileHandle, bufs, 1, bytesRead, Method(:OnChunkRead))
		
	def OnChunkRead(req)
		result = uv_fs_get_result(req)
		if result < 0
			EmitError("Failed to read file chunk")
			return
		ok
		
		# Get chunk data
		buf = uv_fs_get_ptr(req)
		chunkData = space_to_string(buf, result)
		
		# Create chunk info
		chunk = new stzFileChunk()
		chunk.data = chunkData
		chunk.offset = bytesRead
		chunk.size = result
		chunk.isLast = (bytesRead + result >= fileSize)
		
		# Emit chunk
		Emit(chunk)
		
		# Update bytes read
		bytesRead += result
		
		# Continue reading or complete
		if bytesRead < fileSize
			ReadNextChunk()
		else
			CloseAndComplete()
		ok
		
	def CloseAndComplete()
		if fileHandle != NULL
			fsReq = new_uv_fs_t()
			uv_fs_close(engine.myLoop, fsReq, fileHandle, Method(:OnFileClosed))
		else
			Complete()
		ok
		
	def OnFileClosed(req)
		fileHandle = NULL
		Complete()
		
	def Cleanup()
		super.Cleanup()
		if fileHandle != NULL
			fsReq = new_uv_fs_t()
			uv_fs_close(engine.myLoop, fsReq, fileHandle, NULL)
			fileHandle = NULL
		ok
		if fsEventHandle != NULL
			destroy_uv_fs_event_t(fsEventHandle)
			fsEventHandle = NULL
		ok

class stzFileChunk
	data = ""
	offset = 0
	size = 0
	isLast = false

# =============================================================================
# HIGH-LEVEL FILE OPERATIONS
# =============================================================================

# Add these methods to stzReactiveFileSystem for convenience:

class stzDirectoryCopier

	sourcePath = ""
	destPath = ""
	onProgress = NULL
	onSuccess = NULL
	onError = NULL
	engine = NULL
	filesProcessed = 0
	totalFiles = 0
	
	def Init(source, dest, onProgress, onSuccess, onError, engine)
		sourcePath = source
		destPath = dest
		this.onProgress = onProgress
		this.onSuccess = onSuccess
		this.onError = onError
		this.engine = engine
		
	def Execute()
		# First scan source directory to count files
		fs = new stzReactiveFileSystem(engine)
		fs.ListDirectory(sourcePath, Method(:OnSourceScanned), onError)
		
	def OnSourceScanned(entries)
		totalFiles = len(entries)
		filesProcessed = 0
		
		# Create destination directory
		fs = new stzReactiveFileSystem(engine)
		fs.MakeDirectory(destPath, Method(:OnDestCreated), onError)
		
	def OnDestCreated(result)
		# Start copying files
		fs = new stzReactiveFileSystem(engine)
		fs.ListDirectory(sourcePath, Method(:OnReadyToCopy), onError)
		
	def OnReadyToCopy(entries)
		for entry in entries
			if entry.IsFile()
				sourceFile = sourcePath + "/" + entry.name
				destFile = destPath + "/" + entry.name
				fs = new stzReactiveFileSystem(engine)
				fs.CopyFile(sourceFile, destFile, Method(:OnFileCopied), onError)
			ok
		next
		
	def OnFileCopied(result)
		filesProcessed++
		
		if onProgress != NULL
			progress = new stzCopyProgress()
			progress.processed = filesProcessed
			progress.total = totalFiles
			progress.percentage = (filesProcessed * 100.0) / totalFiles
			call onProgress(progress)
		ok
		
		if filesProcessed >= totalFiles
			if onSuccess != NULL
				call onSuccess("Directory copied successfully")
			ok
		ok

# =============================================================================
# COPY PROGRESS TRACKING
# =============================================================================

class stzCopyProgress
	processed = 0
	total = 0
	percentage = 0.0
	currentFile = ""

# =============================================================================
# DIRECTORY SYNCHRONIZER
# =============================================================================

class stzDirectorySyncer

	sourcePath = ""
	destPath = ""
	onProgress = NULL
	onSuccess = NULL
	onError = NULL
	engine = NULL
	sourceFiles = []
	destFiles = []
	toSync = []
	processed = 0
	
	def Init(source, dest, onProgress, onSuccess, onError, engine)
		sourcePath = source
		destPath = dest
		this.onProgress = onProgress
		this.onSuccess = onSuccess
		this.onError = onError
		this.engine = engine
		sourceFiles = []
		destFiles = []
		toSync = []
		processed = 0
		
	def Execute()
		# Scan both directories
		fs = new stzReactiveFileSystem()
		fs.Init(engine)
		fs.ListDirectory(sourcePath, Method(:OnSourceScanned), onError)
		
	def OnSourceScanned(entries)
		sourceFiles = entries
		fs = new stzReactiveFileSystem()
		fs.Init(engine)
		fs.ListDirectory(destPath, Method(:OnDestScanned), Method(:OnDestNotExists))
		
	def OnDestNotExists(error)
		# Destination doesn't exist, create it and copy all
		fs = new stzReactiveFileSystem()
		fs.Init(engine)
		fs.MakeDirectory(destPath, Method(:OnDestCreated), onError)
		
	def OnDestCreated(result)
		destFiles = []
		CompareAndSync()
		
	def OnDestScanned(entries)
		destFiles = entries
		CompareAndSync()
		
	def CompareAndSync()
		toSync = []
		
		# Find files to sync
		for sourceFile in sourceFiles
			if sourceFile.IsFile()
				needsSync = true
				for destFile in destFiles
					if destFile.name = sourceFile.name
						# File exists, check if different
						# For simplicity, we'll sync if names match but could add stat comparison
						needsSync = false
						exit
					ok
				next
				if needsSync
					toSync + sourceFile
				ok
			ok
		next
		
		# Start syncing
		if len(toSync) = 0
			if onSuccess != NULL
				call onSuccess("Directories are in sync")
			ok
		else
			SyncNextFile()
		ok
		
	def SyncNextFile()
		if processed >= len(toSync)
			if onSuccess != NULL
				call onSuccess("Directory sync completed")
			ok
			return
		ok
		
		file = toSync[processed + 1]
		sourceFile = sourcePath + "/" + file.name
		destFile = destPath + "/" + file.name
		
		fs = new stzReactiveFileSystem()
		fs.Init(engine)
		fs.CopyFile(sourceFile, destFile, Method(:OnFileSynced), onError)
		
	def OnFileSynced(result)
		processed++
		
		if onProgress != NULL
			progress = new stzSyncProgress()
			progress.processed = processed
			progress.total = len(toSync)
			progress.percentage = (processed * 100.0) / len(toSync)
			progress.currentFile = toSync[processed].name
			call onProgress(progress)
		ok
		
		SyncNextFile()

class stzSyncProgress
	processed = 0
	total = 0
	percentage = 0.0
	currentFile = ""

# =============================================================================
# REACTIVE FILE SYSTEM FACTORY
# =============================================================================

class stzReactiveFileSystemFactory

	def CreateFileSystem(engine)
		fs = new stzReactiveFileSystemExtended()
		fs.Init(engine)
		return fs
		
	def CreateFileWatcher(path, onChange, onError, engine)
		watcher = new stzLibUVFileWatcher()
		watcher.Init(path, onChange, onError, engine)
		return watcher
		
	def CreateFilePoller(path, interval, onChange, onError, engine)
		poller = new stzLibUVFilePoll()
		poller.Init(path, interval, onChange, onError, engine)
		return poller
		
	def CreateFileStreamer(path, chunkSize, onChunk, onComplete, onError, engine)
		streamer = new stzFileStreamer()
		streamer.Init(path, chunkSize, onChunk, onComplete, onError, engine)
		return streamer
