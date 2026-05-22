pub const SystemCommand = struct {
    name: []const u8,
    windows_cmd: []const u8,
    unix_cmd: []const u8,
    description: []const u8,
    return_type: []const u8,
};

pub const system_commands = [_]SystemCommand{
    .{ .name = "SystemInfo", .windows_cmd = "cmd.exe /c systeminfo", .unix_cmd = "sh -c uname -a && lscpu && free -h", .description = "Display system information (OS version, architecture, kernel)", .return_type = "string" },
    .{ .name = "ListFiles", .windows_cmd = "cmd.exe /c dir /B", .unix_cmd = "ls -1", .description = "List files in current directory (names only)", .return_type = "list" },
    .{ .name = "ListFilesXT", .windows_cmd = "cmd.exe /c dir", .unix_cmd = "ls -la", .description = "List files with details (size, date, permissions)", .return_type = "string" },
    .{ .name = "CopyFile", .windows_cmd = "cmd.exe /c copy {source} {dest}", .unix_cmd = "cp {source} {dest}", .description = "Copy file from source to destination", .return_type = "string" },
    .{ .name = "MoveFile", .windows_cmd = "cmd.exe /c move {source} {dest}", .unix_cmd = "mv {source} {dest}", .description = "Move/rename file", .return_type = "string" },
    .{ .name = "DeleteFile", .windows_cmd = "cmd.exe /c del {file}", .unix_cmd = "rm {file}", .description = "Delete a file", .return_type = "string" },
    .{ .name = "FindFiles", .windows_cmd = "cmd.exe /c dir /S /B {pattern}", .unix_cmd = "find . -name {pattern}", .description = "Search for files matching pattern", .return_type = "list" },
    .{ .name = "CountLines", .windows_cmd = "cmd.exe /c find /C /V \"\" {file}", .unix_cmd = "wc -l {file}", .description = "Count lines in file", .return_type = "number" },
    .{ .name = "WordCount", .windows_cmd = "powershell -Command (Get-Content {file} | Measure-Object -Word).Words", .unix_cmd = "wc -w {file}", .description = "Count words in file", .return_type = "number" },
    .{ .name = "MakeDir", .windows_cmd = "cmd.exe /c mkdir {path}", .unix_cmd = "mkdir -p {path}", .description = "Create directory (and parents if needed)", .return_type = "string" },
    .{ .name = "RemoveDir", .windows_cmd = "cmd.exe /c rmdir /S /Q {path}", .unix_cmd = "rm -rf {path}", .description = "Remove directory and contents", .return_type = "string" },
    .{ .name = "CurrentDir", .windows_cmd = "cmd.exe /c cd", .unix_cmd = "pwd", .description = "Get current working directory", .return_type = "string" },
};
