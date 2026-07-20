#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZVIRTUALFILESYSTEM         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Phase 2, the FILE specialization of the     #
#                  Virtual System twin. Rehearse file          #
#                  operations in an in-memory tree, generate   #
#                  a narrated UpdatePlan, and commit it to     #
#                  real disk through the ONE bridge -- the     #
#                  engine's file primitives (file.zig). The    #
#                  twin holds no reference to reality; disk    #
#                  changes only on plan.Execute().             #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The intent-named verbs (CreateFile, MoveFile, DeleteFile...) read IDENTICALLY
# to a real file class, but here they only RECORD an operation into the twin.
# The rule of thumb from the VSF doc: the virtual class has every method the
# real class has, plus the rehearsal verbs. Reality is reached exactly once,
# through stzFileSystemBridge, which delegates to StzEngineFile* / StzEngineDir*.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzVirtualFileSystemQ()
	return new stzVirtualFileSystem()

func NewVirtualFileSystem()
	return new stzVirtualFileSystem()

	func VirtualFileSystem()
		return new stzVirtualFileSystem()


  #=================#
 #  STZFILETREE    #
#=================#
#
# The virtual state: a flat map of path -> node. A node is
# [ path, type("file"/"folder"), content, origin("mirrored"/"virtual") ].
# 'origin' distinguishes what was mirrored from reality from what was born in
# the workbench -- the seam the workbox diff needs.

class stzFileTree from stzObject

	@aNodes = []

	def init()

	def _IndexOf(pcPath)
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][1] = pcPath
				return _i_
			ok
		next
		return 0

	def Exists(pcPath)
		return This._IndexOf(pcPath) > 0

	def IsFile(pcPath)
		_i_ = This._IndexOf(pcPath)
		return _i_ > 0 and @aNodes[_i_][2] = "file"

	def IsFolder(pcPath)
		_i_ = This._IndexOf(pcPath)
		return _i_ > 0 and @aNodes[_i_][2] = "folder"

	# Insert or update a file node, PRESERVING an existing node's origin.
	def PutFile(pcPath, pcContent, pcOrigin)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			@aNodes[_i_][2] = "file"
			@aNodes[_i_][3] = pcContent
		else
			@aNodes + [ "" + pcPath, "file", pcContent, "" + pcOrigin ]
		ok

	def PutFolder(pcPath, pcOrigin)
		_i_ = This._IndexOf(pcPath)
		if _i_ = 0
			@aNodes + [ "" + pcPath, "folder", "", "" + pcOrigin ]
		ok

	def Remove(pcPath)
		_aNew_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][1] != pcPath
				_aNew_ + @aNodes[_i_]
			ok
		next
		@aNodes = _aNew_

	def ContentOf(pcPath)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			return @aNodes[_i_][3]
		ok
		return ""

	def SizeOf(pcPath)
		return ring_len(This.ContentOf(pcPath))

	def OriginOf(pcPath)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			return @aNodes[_i_][4]
		ok
		return ""

	def Paths()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_a_ + @aNodes[_i_][1]
		next
		return _a_

	def NumberOfNodes()
		return len(@aNodes)

	# Apply an operation to THIS tree -- the domain hook the generic twin calls.
	def Apply(oOp)
		_t_ = oOp.Type()
		if _t_ = "create_file" or _t_ = "write_file"
			This.PutFile(oOp.Param("path"), oOp.Param("content"), "virtual")
		but _t_ = "create_folder"
			This.PutFolder(oOp.Param("path"), "virtual")
		but _t_ = "delete_file" or _t_ = "delete_folder"
			This.Remove(oOp.Param("path"))
		but _t_ = "copy_file"
			This.PutFile(oOp.Param("to"), This.ContentOf(oOp.Param("from")), "virtual")
		but _t_ = "move_file"
			This.PutFile(oOp.Param("to"), This.ContentOf(oOp.Param("from")), "virtual")
			This.Remove(oOp.Param("from"))
		ok

	def NodesCopy()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_a_ + [ @aNodes[_i_][1], @aNodes[_i_][2], @aNodes[_i_][3], @aNodes[_i_][4] ]
		next
		return _a_

	def SetNodes(paNodes)
		@aNodes = paNodes

	def Clone()
		_o_ = new stzFileTree()
		_o_.SetNodes(This.NodesCopy())
		return _o_

	def TreeView()
		_c_ = ""
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_c_ += "  " + @aNodes[_i_][2] + "  " + @aNodes[_i_][1] +
			       "  [" + @aNodes[_i_][4] + "]" + char(10)
		next
		return _c_

	def Show()
		? "File tree (" + len(@aNodes) + " nodes):"
		? This.TreeView()


  #========================#
 #  STZFILESYSTEMBRIDGE   #
#========================#
#
# iRealityBridge for the file domain. THE ONLY class here that touches disk.
# Every method delegates to the engine's pathIsUsable-screened file primitives.

class stzFileSystemBridge from stzObject

	@cRoot = ""

	def init(pcRoot)
		@cRoot = "" + pcRoot

	def Root()
		return @cRoot

	  #-- read reality (read-only sensing) -------------------

	def RealExists(pcPath)
		return StzEngineFileExists(pcPath) = 1

	def RealContent(pcPath)
		return StzEngineFileRead(pcPath)

	def RealSize(pcPath)
		return StzEngineFileSize(pcPath)

	# Mirror one level of a real directory into a fresh tree (origin=mirrored).
	def CurrentRealityState(pcDir)
		_oTree_ = new stzFileTree()
		_aEntries_ = StzEngineDirListFiles(pcDir)
		if NOT isList(_aEntries_)
			return _oTree_
		ok
		_n_ = len(_aEntries_)
		for _i_ = 1 to _n_
			_cEntry_ = "" + _aEntries_[_i_]
			_cPath_ = _cEntry_
			if StzEngineFileExists(_cEntry_) != 1
				_cPath_ = pcDir + "/" + _cEntry_
			ok
			if StzEngineFileExists(_cPath_) = 1
				_oTree_.PutFile(_cPath_, StzEngineFileRead(_cPath_), "mirrored")
			ok
		next
		return _oTree_

	def Constraints()
		return [ [ "root", @cRoot ] ]

	def Capabilities()
		return [ "create_file", "write_file", "create_folder",
			 "delete_file", "delete_folder", "copy_file", "move_file" ]

	  #-- change reality (the ONE door) ----------------------

	def ExecuteOperation(oOp)
		_t_ = oOp.Type()
		if _t_ = "create_file" or _t_ = "write_file"
			return StzEngineFileWrite(oOp.Param("path"), oOp.Param("content")) = 1
		but _t_ = "create_folder"
			return StzEngineDirCreatePath(oOp.Param("path")) = 1
		but _t_ = "delete_file"
			return StzEngineFileDelete(oOp.Param("path")) = 1
		but _t_ = "delete_folder"
			return StzEngineDirDelete(oOp.Param("path")) = 1
		but _t_ = "copy_file"
			return StzEngineFileCopy(oOp.Param("from"), oOp.Param("to")) = 1
		but _t_ = "move_file"
			if StzEngineFileCopy(oOp.Param("from"), oOp.Param("to")) = 1
				return StzEngineFileDelete(oOp.Param("from")) = 1
			ok
			return FALSE
		ok
		return FALSE

	def VerifyOutcome(oOp)
		_t_ = oOp.Type()
		if _t_ = "create_file" or _t_ = "write_file" or _t_ = "copy_file"
			return This.RealExists(oOp.Param("path")) or This.RealExists(oOp.Param("to"))
		but _t_ = "move_file"
			return This.RealExists(oOp.Param("to")) and NOT This.RealExists(oOp.Param("from"))
		but _t_ = "delete_file" or _t_ = "delete_folder"
			return NOT This.RealExists(oOp.Param("path"))
		ok
		return TRUE


  #========================#
 #  STZVIRTUALFILESYSTEM  #
#========================#
#
# The file twin. Inherits the generic rehearse/plan/commit core from
# stzVirtualSystem and adds the intent-named file verbs (rehearsal-only) plus
# MirrorFrom and free inspection that reads the TWIN, not reality.

class stzVirtualFileSystem from stzVirtualSystem

	def init()
		@oState = new stzFileTree()
		@oBaseState = @oState.Clone()
		@aHistory = []
		@aSnapshots = []
		@oBridge = new stzFileSystemBridge("")
		@cActor = "human"

	  #-- rehearsal verbs (record; touch NOTHING real) -------

	def CreateFile(pcPath, pcContent)
		This.ExecuteOperation(new stzVirtualOperation("create_file",
			[ [ "path", "" + pcPath ], [ "content", "" + pcContent ] ]))
		return This

	def WriteFile(pcPath, pcContent)
		This.ExecuteOperation(new stzVirtualOperation("write_file",
			[ [ "path", "" + pcPath ], [ "content", "" + pcContent ] ]))
		return This

	def CreateFolder(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("create_folder",
			[ [ "path", "" + pcPath ] ]))
		return This

	def DeleteFile(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("delete_file",
			[ [ "path", "" + pcPath ] ]))
		return This

	def DeleteFolder(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("delete_folder",
			[ [ "path", "" + pcPath ] ]))
		return This

	def CopyFile(pcFrom, pcTo)
		This.ExecuteOperation(new stzVirtualOperation("copy_file",
			[ [ "from", "" + pcFrom ], [ "to", "" + pcTo ] ]))
		return This

	def MoveFile(pcFrom, pcTo)
		This.ExecuteOperation(new stzVirtualOperation("move_file",
			[ [ "from", "" + pcFrom ], [ "to", "" + pcTo ] ]))
		return This

	  #-- read reality INTO the twin -------------------------

	# Mirror a single real file (unambiguous).
	def MirrorFile(pcPath)
		if @oBridge.RealExists(pcPath)
			@oState.PutFile(pcPath, @oBridge.RealContent(pcPath), "mirrored")
			@oBaseState = @oState.Clone()
		ok
		return This

	# Mirror one level of a real directory.
	def MirrorFrom(pcDir)
		@oState = @oBridge.CurrentRealityState(pcDir)
		@oBaseState = @oState.Clone()
		return This

	  #-- free inspection (reads the TWIN, not disk) ---------

	def Exists(pcPath)
		return @oState.Exists(pcPath)

	def ContentOf(pcPath)
		return @oState.ContentOf(pcPath)

	def SizeOf(pcPath)
		return @oState.SizeOf(pcPath)

	def OriginOf(pcPath)
		return @oState.OriginOf(pcPath)

	def Paths()
		return @oState.Paths()

	def NumberOfNodes()
		return @oState.NumberOfNodes()

	def TreeView()
		return @oState.TreeView()

	def Show()
		@oState.Show()
