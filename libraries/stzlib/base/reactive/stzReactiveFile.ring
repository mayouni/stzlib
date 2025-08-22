
# SOFTANZA REACTIVE FILE SYSTEM


#------------------------------------------#
#  MAIN CLASS OF THE REACTIVE FILE SYSTEM  #
#------------------------------------------#

class stzReactiveFileSystem

    engine = NULL
    
    def Init(engine)
        this.engine = engine

    # Basic file operations with expressive parameters
    def ReadFile(path, onSuccess, onError)
        task = new stzFileReadTask("file_read", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def WriteFile(path, content, onSuccess, onError)
        task = new stzFileWriteTask("file_write", path, content, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def AppendFile(path, content, onSuccess, onError)
        task = new stzFileAppendTask("file_append", path, content, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def DeleteFile(path, onSuccess, onError)
        task = new stzFileDeleteTask("file_delete", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # Directory operations with expressive permissions
    def CreateDir(path, permissions, onSuccess, onError)
        if permissions = NULL permissions = FILE_PERMISSIONS[:DEFAULT_DIR] ok
        task = new stzDirCreateTask("dir_create", path, permissions, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def RemoveDir(path, onSuccess, onError)
        task = new stzDirRemoveTask("dir_remove", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def ListDir(path, onSuccess, onError)
        task = new stzDirListTask("dir_list", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # File info operations
    def GetStat(path, onSuccess, onError)
        task = new stzFileStatTask("file_stat", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def CopyFile(srcPath, destPath, onSuccess, onError)
        task = new stzFileCopyTask("file_copy", srcPath, destPath, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def RenameFile(oldPath, newPath, onSuccess, onError)
        task = new stzFileRenameTask("file_rename", oldPath, newPath, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # File watching with expressive intervals
    def WatchFile(path, onChange)
        watcherId = "watch_" + string(random(999999))
        watcher = new stzFileWatcher(watcherId, path, onChange, engine)
        watcher.Start()
        engine.AddFileWatcher(watcher)
        return watcher

    def PollFile(path, interval, onChange)
        # Accept symbolic interval names
        if isString(interval)
            switch interval
                on :FAST     interval = POLL_INTERVALS[:FAST]
                on :NORMAL   interval = POLL_INTERVALS[:NORMAL] 
                on :SLOW     interval = POLL_INTERVALS[:SLOW]
                on :VERY_SLOW interval = POLL_INTERVALS[:VERY_SLOW]
                other        interval = POLL_INTERVALS[:NORMAL]
            off
        ok
        
        watcherId = "poll_" + string(random(999999))
        poller = new stzFilePoller(watcherId, path, interval, onChange, engine)
        poller.Start()
        engine.AddFileWatcher(poller)
        return poller

    # Advanced file operations with expressive parameters
    def GetFileStat(path, onSuccess, onError)
        # Returns structured file information
        task = new stzFileFStatTask("file_fstat", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def GetLinkStat(path, onSuccess, onError)
        # Get stats without following symlinks
        task = new stzFileLStatTask("file_lstat", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def CheckAccess(path, accessMode, onSuccess, onError)
        # Accept symbolic access mode names
        if isString(accessMode)
            accessMode = ACCESS_MODES[accessMode]
        ok
        
        task = new stzFileAccessTask("file_access", path, accessMode, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def ChangePermissions(path, permissions, onSuccess, onError)
        # Accept symbolic permission names
        if isString(permissions)
            permissions = FILE_PERMISSIONS[permissions]
        ok
        
        task = new stzFileChmodTask("file_chmod", path, permissions, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def ChangeOwnership(path, uid, gid, onSuccess, onError)
        task = new stzFileChownTask("file_chown", path, uid, gid, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def UpdateFileTime(path, accessTime, modifyTime, onSuccess, onError)
        # Accept "now" as current timestamp
        if accessTime = "now" accessTime = time() ok
        if modifyTime = "now" modifyTime = time() ok
        
        task = new stzFileUtimeTask("file_utime", path, accessTime, modifyTime, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # Link operations with expressive flags
    def CreateHardLink(srcPath, destPath, onSuccess, onError)
        task = new stzFileLinkTask("file_link", srcPath, destPath, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def CreateSymbolicLink(srcPath, destPath, linkType, onSuccess, onError)
        # Accept symbolic link type names
        if linkType = NULL linkType = SYMLINK_FLAGS[:DEFAULT] ok
        if isString(linkType)
            linkType = SYMLINK_FLAGS[linkType]
        ok
        
        task = new stzFileSymlinkTask("file_symlink", srcPath, destPath, linkType, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def ReadLink(linkPath, onSuccess, onError)
        task = new stzFileReadlinkTask("file_readlink", linkPath, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def GetRealPath(path, onSuccess, onError)
        task = new stzFileRealpathTask("file_realpath", path, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # Advanced file descriptor operations
    def SyncFile(fd, onSuccess, onError)
        task = new stzFileFsyncTask("file_fsync", fd, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def SyncFileData(fd, onSuccess, onError)
        task = new stzFileFdatasyncTask("file_fdatasync", fd, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def TruncateFile(fd, size, onSuccess, onError)
        task = new stzFileFtruncateTask("file_ftruncate", fd, size, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    def SendFile(outFd, inFd, offset, length, onSuccess, onError)
        task = new stzFileSendfileTask("file_sendfile", outFd, inFd, offset, length, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # Directory operations
    def CreateTempDir(template, onSuccess, onError)
        if template = NULL template = "/tmp/softanza_XXXXXX" ok
        
        task = new stzDirMkdtempTask("dir_mkdtemp", template, engine)
        task.Then_(onSuccess).Catch_(onError)
        engine.AddTask(task)
        task.Execute()
        return task

    # High-level convenience methods that combine multiple operations
    def EnsureDir(path, permissions, onSuccess, onError)
        # Create directory if it doesn't exist, succeed if it does
        if permissions = NULL permissions = :DEFAULT_DIR ok
        
        this.CheckAccess(path, :EXISTS,
            func(exists) {
                # Directory exists, call success
                if onSuccess != NULL call onSuccess("Directory already exists") ok
            },
            func(err) {
                # Directory doesn't exist, create it
                this.CreateDir(path, permissions, onSuccess, onError)
            }
        )

    def SafeWriteFile(path, content, onSuccess, onError)
        # Write to temporary file first, then rename (atomic write)
        tempPath = path + ".tmp"
        
        this.WriteFile(tempPath, content,
            func(result) {
                this.RenameFile(tempPath, path, onSuccess, onError)
            },
            func(err) {
                # Clean up temp file on error
                this.DeleteFile(tempPath, func(ok_) {}, func(cleanupErr) {})
                if onError != NULL call onError(err) ok
            }
        )

    def IsReadable(path, onSuccess, onError)
        this.CheckAccess(path, :READABLE, onSuccess, onError)

    def IsWritable(path, onSuccess, onError)
        this.CheckAccess(path, :WRITABLE, onSuccess, onError)

    def IsExecutable(path, onSuccess, onError)
        this.CheckAccess(path, :EXECUTABLE, onSuccess, onError)

    def MakeReadOnly(path, onSuccess, onError)
        this.ChangePermissions(path, :READ_ONLY, onSuccess, onError)

    def MakeExecutable(path, onSuccess, onError)
        this.ChangePermissions(path, :USER_FULL, onSuccess, onError)

#----------------------------------------------#
#  FILE OPERATION TASKS - Core implementations #
#----------------------------------------------#

class stzFileTask from stzReactiveTask
    @loop = NULL
    req = NULL
    
    def Init(id, engine)
        super.Init(id, NULL, engine)
        @loop = uv_default_loop()
        req = uv_default_loop()

class stzFileReadTask from stzFileTask
    filePath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        filePath = path
        
    def Execute()
        status = "running"
        
        # Use Ring's built-in file reading as fallback to libuv complexity
        try
            content = read(filePath)
            status = "completed"
            result = content
            if onComplete != NULL
                call onComplete(content)
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("Failed to read file: " + filePath)
            ok
        done

class stzFileWriteTask from stzFileTask
    filePath = ""
    content = ""
    
    def Init(id, path, content, engine)
        super.Init(id, engine)
        filePath = path
        this.content = content
        
    def Execute()
        status = "running"
        
        try
            write(filePath, content)
            status = "completed"
            result = len(content)
            if onComplete != NULL
                call onComplete("File written successfully")
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("Failed to write file: " + filePath)
            ok
        done

class stzFileAppendTask from stzFileTask
    filePath = ""
    content = ""
    
    def Init(id, path, content, engine)
        super.Init(id, engine)
        filePath = path
        this.content = content
        
    def Execute()
        status = "running"
        
        # Open file for appending (create if doesn't exist)
        result = uv_fs_open(@loop, req, filePath, UV_FS_O_CREAT + UV_FS_O_WRONLY + UV_FS_O_APPEND, 420, func {
            file = uv_fs_get_result(req)
            if file < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to open file for appending: " + filePath)
                ok
                return
            ok
            
            # Append content
            buffer = uv_buf_init(content, len(content))
            writeReq = uv_fs_new()
            
            uv_fs_write(@loop, writeReq, file, buffer, 1, -1, func {
                written = uv_fs_get_result(writeReq)
                
                # Close file
                uv_fs_close(@loop, req, file, func {
                    status = "completed"
                    result = written
                    if onComplete != NULL
                        call onComplete(written)
                    ok
                })
                
                uv_fs_req_cleanup(writeReq)
            })
        })


class stzFileDeleteTask from stzFileTask
    filePath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        filePath = path
        
    def Execute()
        status = "running"
        
        # Use libuv unlink for reactive file deletion
        result = uv_fs_unlink(@loop, req, filePath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to delete file: " + filePath + " (Error: " + result + ")")
                ok
            else
                status = "completed"
                result = "File deleted successfully"
                if onComplete != NULL
                    call onComplete("File deleted successfully")
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileCopyTask from stzFileTask
    srcPath = ""
    destPath = ""
    flags = 0
    
    def Init(id, src, dest, engine)
        super.Init(id, engine)
        srcPath = src
        destPath = dest
        flags = 0  # Default copy behavior
        
    def Execute()
        status = "running"
        
        # Use libuv copyfile for reactive file copying
        result = uv_fs_copyfile(@loop, req, srcPath, destPath, flags, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to copy file: " + srcPath + " to " + destPath + " (Error: " + result + ")")
                ok
            else
                status = "completed"
                result = "File copied successfully"
                if onComplete != NULL
                    call onComplete("File copied successfully")
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileRenameTask from stzFileTask
    oldPath = ""
    newPath = ""
    
    def Init(id, old, newname, engine)
        super.Init(id, engine)
        oldPath = old
        newPath = newname
        
    def Execute()
        status = "running"
        
        # Use libuv rename for reactive file renaming
        result = uv_fs_rename(@loop, req, oldPath, newPath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to rename file: " + oldPath + " to " + newPath + " (Error: " + result + ")")
                ok
            else
                status = "completed"
                result = "File renamed successfully"
                if onComplete != NULL
                    call onComplete("File renamed successfully")
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileStatTask from stzFileTask
    filePath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        filePath = path
        
    def Execute()
        status = "running"
        
        # Use libuv stat for reactive file stat retrieval
        result = uv_fs_stat(@loop, req, filePath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to get file stats: " + filePath + " (Error: " + result + ")")
                ok
            else
                # Extract stat information
                statinfo = uv_fs_get_statbuf(req)
                
                status = "completed"
                result = statinfo
                if onComplete != NULL
                    call onComplete(statinfo)
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFStatTask from stzFileTask
    fileDescriptor = 0
    
    def Init(id, fd, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        
    def Execute()
        status = "running"
        result = uv_fs_fstat(@loop, req, fileDescriptor, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to fstat file (Error: " + result + ")")
                ok
            else
                statinfo = uv_fs_get_statbuf(req)
                status = "completed"
                result = statinfo
                if onComplete != NULL call onComplete(statinfo) ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileLStatTask from stzFileTask
    filePath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        filePath = path
        
    def Execute()
        status = "running"
        result = uv_fs_lstat(@loop, req, filePath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to lstat: " + filePath + " (Error: " + result + ")") ok
            else
                statinfo = uv_fs_get_statbuf(req)
                status = "completed"
                result = statinfo
                if onComplete != NULL call onComplete(statinfo) ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileAccessTask from stzFileTask
    filePath = ""
    mode = 0
    
    def Init(id, path, mode, engine)
        super.Init(id, engine)
        filePath = path
        this.mode = mode
        
    def Execute()
        status = "running"
        result = uv_fs_access(@loop, req, filePath, mode, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Access denied: " + filePath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Access granted"
                if onComplete != NULL call onComplete("Access granted") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileChmodTask from stzFileTask
    filePath = ""
    mode = 0
    
    def Init(id, path, mode, engine)
        super.Init(id, engine)
        filePath = path
        this.mode = mode
        
    def Execute()
        status = "running"
        result = uv_fs_chmod(@loop, req, filePath, mode, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to chmod: " + filePath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Permissions changed"
                if onComplete != NULL call onComplete("Permissions changed") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFChmodTask from stzFileTask
    fileDescriptor = 0
    mode = 0
    
    def Init(id, fd, mode, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        this.mode = mode
        
    def Execute()
        status = "running"
        result = uv_fs_fchmod(@loop, req, fileDescriptor, mode, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to fchmod (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Permissions changed"
                if onComplete != NULL call onComplete("Permissions changed") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileUtimeTask from stzFileTask
    filePath = ""
    atime = 0
    mtime = 0
    
    def Init(id, path, atime, mtime, engine)
        super.Init(id, engine)
        filePath = path
        this.atime = atime
        this.mtime = mtime
        
    def Execute()
        status = "running"
        result = uv_fs_utime(@loop, req, filePath, atime, mtime, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to utime: " + filePath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File times updated"
                if onComplete != NULL call onComplete("File times updated") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFUtimeTask from stzFileTask
    fileDescriptor = 0
    atime = 0
    mtime = 0
    
    def Init(id, fd, atime, mtime, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        this.atime = atime
        this.mtime = mtime
        
    def Execute()
        status = "running"
        result = uv_fs_futime(@loop, req, fileDescriptor, atime, mtime, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to futime (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File times updated"
                if onComplete != NULL call onComplete("File times updated") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileLinkTask from stzFileTask
    srcPath = ""
    destPath = ""
    
    def Init(id, src, dest, engine)
        super.Init(id, engine)
        srcPath = src
        destPath = dest
        
    def Execute()
        status = "running"
        result = uv_fs_link(@loop, req, srcPath, destPath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to create link: " + srcPath + " -> " + destPath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Hard link created"
                if onComplete != NULL call onComplete("Hard link created") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileSymlinkTask from stzFileTask
    srcPath = ""
    destPath = ""
    flags = 0
    
    def Init(id, src, dest, flags, engine)
        super.Init(id, engine)
        srcPath = src
        destPath = dest
        this.flags = flags
        
    def Execute()
        status = "running"
        result = uv_fs_symlink(@loop, req, srcPath, destPath, flags, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to create symlink: " + srcPath + " -> " + destPath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Symbolic link created"
                if onComplete != NULL call onComplete("Symbolic link created") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileReadlinkTask from stzFileTask
    linkPath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        linkPath = path
        
    def Execute()
        status = "running"
        result = uv_fs_readlink(@loop, req, linkPath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to readlink: " + linkPath + " (Error: " + result + ")") ok
            else
                linkTarget = uv_fs_get_path(req)
                status = "completed"
                result = linkTarget
                if onComplete != NULL call onComplete(linkTarget) ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileRealpathTask from stzFileTask
    filePath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        filePath = path
        
    def Execute()
        status = "running"
        result = uv_fs_realpath(@loop, req, filePath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to get realpath: " + filePath + " (Error: " + result + ")") ok
            else
                realPath = uv_fs_get_path(req)
                status = "completed"
                result = realPath
                if onComplete != NULL call onComplete(realPath) ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileChownTask from stzFileTask
    filePath = ""
    uid = 0
    gid = 0
    
    def Init(id, path, uid, gid, engine)
        super.Init(id, engine)
        filePath = path
        this.uid = uid
        this.gid = gid
        
    def Execute()
        status = "running"
        result = uv_fs_chown(@loop, req, filePath, uid, gid, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to chown: " + filePath + " (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Ownership changed"
                if onComplete != NULL call onComplete("Ownership changed") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFChownTask from stzFileTask
    fileDescriptor = 0
    uid = 0
    gid = 0
    
    def Init(id, fd, uid, gid, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        this.uid = uid
        this.gid = gid
        
    def Execute()
        status = "running"
        result = uv_fs_fchown(@loop, req, fileDescriptor, uid, gid, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to fchown (Error: " + result + ")") ok
            else
                status = "completed"
                result = "Ownership changed"
                if onComplete != NULL call onComplete("Ownership changed") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFsyncTask from stzFileTask
    fileDescriptor = 0
    
    def Init(id, fd, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        
    def Execute()
        status = "running"
        result = uv_fs_fsync(@loop, req, fileDescriptor, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to fsync (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File synced"
                if onComplete != NULL call onComplete("File synced") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFdatasyncTask from stzFileTask
    fileDescriptor = 0
    
    def Init(id, fd, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        
    def Execute()
        status = "running"
        result = uv_fs_fdatasync(@loop, req, fileDescriptor, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to fdatasync (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File data synced"
                if onComplete != NULL call onComplete("File data synced") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileFtruncateTask from stzFileTask
    fileDescriptor = 0
    offset = 0
    
    def Init(id, fd, offset, engine)
        super.Init(id, engine)
        fileDescriptor = fd
        this.offset = offset
        
    def Execute()
        status = "running"
        result = uv_fs_ftruncate(@loop, req, fileDescriptor, offset, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to ftruncate (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File truncated"
                if onComplete != NULL call onComplete("File truncated") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzFileSendfileTask from stzFileTask
    outFd = 0
    inFd = 0
    inOffset = 0
    length = 0
    
    def Init(id, outFd, inFd, inOffset, length, engine)
        super.Init(id, engine)
        this.outFd = outFd
        this.inFd = inFd
        this.inOffset = inOffset
        this.length = length
        
    def Execute()
        status = "running"
        result = uv_fs_sendfile(@loop, req, outFd, inFd, inOffset, length, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to sendfile (Error: " + result + ")") ok
            else
                status = "completed"
                result = "File transferred (" + result + " bytes)"
                if onComplete != NULL call onComplete("File transferred (" + result + " bytes)") ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzDirMkdtempTask from stzFileTask
    template = ""
    
    def Init(id, tpl, engine)
        super.Init(id, engine)
        template = tpl
        
    def Execute()
        status = "running"
        result = uv_fs_mkdtemp(@loop, req, template, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL call onError("Failed to create temp dir (Error: " + result + ")") ok
            else
                tempPath = uv_fs_get_path(req)
                status = "completed"
                result = tempPath
                if onComplete != NULL call onComplete(tempPath) ok
            ok
            uv_fs_req_cleanup(req)
        })

#---------------------------#
#  FOLDER OPERATIONS TASKS  #
#---------------------------#

class stzDirCreateTask from stzFileTask
    dirPath = ""
    mode = 493
    
    def Init(id, path, mode, engine)
        super.Init(id, engine)
        dirPath = path
        this.mode = mode

    def Execute()
        status = "running"
        
        # Use libuv mkdir for reactive directory creation
        result = uv_fs_mkdir(@loop, req, dirPath, mode, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to create directory: " + dirPath + " (Error: " + result + ")")
                ok
            else
                status = "completed"
                result = "Directory created successfully"
                if onComplete != NULL
                    call onComplete("Directory created successfully")
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzDirRemoveTask from stzFileTask
    dirPath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        dirPath = path

    def Execute()
        status = "running"
        
        # Use libuv rmdir for reactive directory removal
        result = uv_fs_rmdir(@loop, req, dirPath, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to remove directory: " + dirPath + " (Error: " + result + ")")
                ok
            else
                status = "completed"
                result = "Directory removed successfully"
                if onComplete != NULL
                    call onComplete("Directory removed successfully")
                ok
            ok
            uv_fs_req_cleanup(req)
        })

class stzDirListTask from stzFileTask
    dirPath = ""
    
    def Init(id, path, engine)
        super.Init(id, engine)
        dirPath = path
        
    def Execute()
        status = "running"
        
        # Use libuv scandir for reactive directory listing
        result = uv_fs_scandir(@loop, req, dirPath, 0, func {
            result = uv_fs_get_result(req)
            if result < 0
                status = "error"
                if onError != NULL
                    call onError("Failed to list directory: " + dirPath + " (Error: " + result + ")")
                ok
            else
                # Extract directory entries
                entries = []
                while True
                    entry = uv_fs_scandir_next(req)
                    if entry = NULL
                        exit
                    ok
                    add(entries, entry)
                end
                
                status = "completed"
                result = entries
                if onComplete != NULL
                    call onComplete(entries)
                ok
            ok
            uv_fs_req_cleanup(req)
        })

#------------------------------------------#
#  FILE WATCHERS - Event-driven monitoring #
#------------------------------------------#

class stzFileWatcher
    watcherId = ""
    filePath = ""
    onChange = NULL
    engine = NULL
    handle = NULL
    
    def Init(id, path, callback, engine)
        watcherId = id
        filePath = path
        onChange = callback
        this.engine = engine
        
    def Start()
        handle = uv_fs_event_new()
        uv_fs_event_start(handle, func {
            if onChange != NULL
                eventInfo = [:path = filePath, :event = "change"]
                call onChange(eventInfo)
            ok
        }, filePath, 0)
        
    def Stop()
        if handle != NULL
            uv_fs_event_stop(handle)
            handle = NULL
        ok

class stzFilePoller
    watcherId = ""
    filePath = ""
    interval = 1000
    onChange = NULL
    engine = NULL
    handle = NULL
    
    def Init(id, path, interval, callback, engine)
        watcherId = id
        filePath = path
        this.interval = interval
        onChange = callback
        this.engine = engine
        
    def Start()
        handle = uv_fs_poll_new()
        uv_fs_poll_start(handle, func {
            if onChange != NULL
                pollInfo = [:path = filePath, :event = "poll"]
                call onChange(pollInfo)
            ok
        }, filePath, interval)
        
    def Stop()
        if handle != NULL
            uv_fs_poll_stop(handle)
            handle = NULL
        ok
