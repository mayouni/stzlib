#------------------------#
#  UTILITY FUNCTIONS     #
#------------------------#

func PathSeparator()
    if isWindows()
        return "\"
    else
        return "/"
    ok

func fgettime(cFilePath)
    # Simple file time check using file size as proxy
    # In a real implementation, you'd use proper file time functions
    if fexists(cFilePath)
        return clock() # Placeholder - use actual file modification time
    ok
    return 0

