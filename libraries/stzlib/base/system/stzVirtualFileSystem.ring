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


  #=================#
 #  STZFILETREE    #
#=================#
#
# The virtual state: a flat map of path -> node. A node is
# [ path, type("file"/"folder"), content, origin("mirrored"/"virtual") ].
# 'origin' distinguishes what was mirrored from reality from what was born in
# the workbench -- the seam the workbox diff needs.

# Holds an in-memory tree of files and folders: a flat map of paths to nodes, each with a type, content and origin.
#
# It is the state the file twin changes. A node is [ path, type, content, origin ], the origin being
# mirrored for a node read from the disk and virtual for one born in the twin, which is the seam a
# diff against reality needs. A node keeps its first origin when its content is replaced. Apply is
# the hook the generic twin calls to rehearse an operation, and Clone gives the independent copy a
# snapshot or a rebuild starts from. Paths are matched exactly and the tree is flat: removing a
# folder does not remove the nodes below it. Nothing here touches the disk.
#
#   receiver   o1 = new stzFileTree()
#   example    o1.PutFile("/w/a.txt", "alpha", "virtual")
#              o1.PutFolder("/w", "virtual")
#              ? o1.IsFile("/w/a.txt")
#              #--> 1
#              ? o1.SizeOf("/w/a.txt")
#              #--> 5
#              ? @@( o1.Paths() )
#              #--> [ "/w/a.txt", "/w" ]
#   see        stzVirtualFileSystem, stzFileSystemBridge, stzEnvironmentState
class stzFileTree from stzObject

	@aNodes = []

	# Builds an empty file tree: a flat map of paths to files and folders.
	#
	#   returns    nothing; the tree is built
	#   see        PutFile, Clone
	def init()

	def _IndexOf(pcPath)
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][1] = pcPath
				return _i_
			ok
		next
		return 0

	# TRUE if the tree holds a file or folder at that path.
	#
	#   pcPath     the path, matched exactly and with case
	#   returns    TRUE or FALSE
	#   see        IsFile, IsFolder
	def Exists(pcPath)
		return This._IndexOf(pcPath) > 0

	# TRUE if the tree holds a file at that path.
	#
	#   pcPath     the path, matched exactly
	#   returns    TRUE or FALSE
	#   see        IsFolder, Exists
	def IsFile(pcPath)
		_i_ = This._IndexOf(pcPath)
		return _i_ > 0 and @aNodes[_i_][2] = "file"

	# TRUE if the tree holds a folder at that path.
	#
	#   pcPath     the path, matched exactly
	#   returns    TRUE or FALSE
	#   see        IsFile, Exists
	def IsFolder(pcPath)
		_i_ = This._IndexOf(pcPath)
		return _i_ > 0 and @aNodes[_i_][2] = "folder"

	# Adds a file node or replaces the content of the node at that path.
	#
	#   pcPath      the path
	#   pcContent   the content, as text
	#   pcOrigin    mirrored or virtual, kept only when the node is new
	#   returns     nothing
	#   warning     a node that exists keeps the origin it first had, so a mirrored file stays
	#               mirrored after its content is replaced; a folder at that path becomes a file
	#   see         PutFolder, ContentOf
	#@ aka  Insert or update a file node, PRESERVING an existing node's origin.
	def PutFile(pcPath, pcContent, pcOrigin)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			@aNodes[_i_][2] = "file"
			@aNodes[_i_][3] = pcContent
		else
			@aNodes + [ "" + pcPath, "file", pcContent, "" + pcOrigin ]
		ok

	# Adds a folder node; a path already in the tree changes nothing.
	#
	#   pcPath     the path
	#   pcOrigin   mirrored or virtual
	#   returns    nothing
	#   see        PutFile, IsFolder
	def PutFolder(pcPath, pcOrigin)
		_i_ = This._IndexOf(pcPath)
		if _i_ = 0
			@aNodes + [ "" + pcPath, "folder", "", "" + pcOrigin ]
		ok

	# Removes the node at that path, whatever it is; an absent path changes nothing.
	#
	#   pcPath     the path
	#   returns    nothing
	#   note       nodes below a removed folder stay in the tree
	#   see        PutFile, Exists
	def Remove(pcPath)
		_aNew_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][1] != pcPath
				_aNew_ + @aNodes[_i_]
			ok
		next
		@aNodes = _aNew_

	# Returns the content of a node.
	#
	#   pcPath     the path
	#   returns    a text; an empty text for a folder or an absent path
	#   see        SizeOf, PutFile
	def ContentOf(pcPath)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			return @aNodes[_i_][3]
		ok
		return ""

	# Returns the size of the content of a node, in bytes.
	#
	#   pcPath     the path
	#   returns    a number; 0 for a folder or an absent path
	#   see        ContentOf
	def SizeOf(pcPath)
		return ring_len(This.ContentOf(pcPath))

	# Returns where a node came from.
	#
	#   pcPath     the path
	#   returns    mirrored for one read from reality, virtual for one born in the twin; an empty
	#              text when absent
	#   see        PutFile, Paths
	def OriginOf(pcPath)
		_i_ = This._IndexOf(pcPath)
		if _i_ > 0
			return @aNodes[_i_][4]
		ok
		return ""

	# Returns every path in the tree, in the order added.
	#
	#   returns    a list of text
	#   see        NumberOfNodes, TreeView
	def Paths()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_a_ + @aNodes[_i_][1]
		next
		return _a_

	# Returns how many nodes the tree holds.
	#
	#   returns    a number
	#   see        Paths
	def NumberOfNodes()
		return len(@aNodes)

	# Applies one file operation to the tree: create, write, copy, move, delete a file, create or delete a folder; other types change nothing.
	#
	#   oOp        the stzVirtualOperation to apply
	#   returns    nothing
	#   note       this is the hook the generic twin calls when it rehearses
	#   warning    a copy or move of a path the tree does not hold creates an empty file at the
	#              destination
	#   see        stzVirtualFileSystem, Clone
	#@ aka  Apply an operation to THIS tree -- the domain hook the generic twin calls.
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

	# Returns a copy of the node rows, so a clone does not share them.
	#
	#   returns    a list of [ path, type, content, origin ] rows
	#   see        Clone, SetNodes
	def NodesCopy()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_a_ + [ @aNodes[_i_][1], @aNodes[_i_][2], @aNodes[_i_][3], @aNodes[_i_][4] ]
		next
		return _a_

	# Replaces all the node rows at once.
	#
	#   paNodes    a list of [ path, type, content, origin ] rows, the type file or folder
	#   returns    nothing
	#   see        NodesCopy, Clone
	def SetNodes(paNodes)
		@aNodes = paNodes

	# Returns an independent copy of the tree, which a snapshot or a rebuild starts from.
	#
	#   returns    a new stzFileTree
	#   see        NodesCopy, SetNodes
	def Clone()
		_o_ = new stzFileTree()
		_o_.SetNodes(This.NodesCopy())
		return _o_

	# Returns the tree as text, one line per node with its type, its path and its origin.
	#
	#   returns    a text, several lines
	#   see        Show, Paths
	def TreeView()
		_c_ = ""
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_c_ += "  " + @aNodes[_i_][2] + "  " + @aNodes[_i_][1] +
			       "  [" + @aNodes[_i_][4] + "]" + char(10)
		next
		return _c_

	# Prints the number of nodes and the tree view.
	#
	#   returns    nothing; it prints
	#   see        TreeView
	def Show()
		? "File tree (" + len(@aNodes) + " nodes):"
		? This.TreeView()


  #========================#
 #  STZFILESYSTEMBRIDGE   #
#========================#
#
# iRealityBridge for the file domain. THE ONLY class here that touches disk.
# Every method delegates to the engine's pathIsUsable-screened file primitives.

# Is the one door from the file twin to the real disk: it reads files, and commits file operations.
#
# The reads (RealExists, RealContent, RealSize, CurrentRealityState) change nothing.
# ExecuteOperation is the only call that writes: it creates, writes, copies, moves and deletes real
# files and folders, and answers whether the disk call succeeded. The root given at construction is
# reported by Constraints and does not confine the paths an operation names. Reach ExecuteOperation
# only through an update plan that was narrated and reviewed; VerifyOutcome then checks the disk is
# as asked.
#
#   receiver   o1 = new stzFileSystemBridge("/w")
#   example    ? o1.RealExists("/stz-doc-invented/none.txt")
#              #--> 0
#              ? o1.RealSize("/stz-doc-invented/none.txt")
#              #--> -1
#              ? @@( o1.Constraints() )
#              #--> [ [ "root", "/w" ] ]
#   see        stzVirtualFileSystem, stzFileTree, stzUpdatePlan, stzEnvironmentBridge
class stzFileSystemBridge from stzObject

	@cRoot = ""

	# Builds the bridge to the real disk, the only door by which the file twin reaches reality.
	#
	#   pcRoot     the root folder the bridge reports as its constraint
	#   returns    nothing; the bridge is built
	#   warning    the root is only reported by Constraints: it does not confine the paths an
	#              operation names
	#   see        Root, ExecuteOperation
	def init(pcRoot)
		@cRoot = "" + pcRoot

	# Returns the root folder the bridge was built with.
	#
	#   returns    a text
	#   see        Constraints
	def Root()
		return @cRoot

	# TRUE if a real file exists at that path.
	#
	#   pcPath     the real path
	#   returns    TRUE or FALSE
	#   note       it reads the disk and changes nothing
	#   see        RealContent, RealSize
	#@ aka  -- read reality (read-only sensing) -------------------
	def RealExists(pcPath)
		return StzEngineFileExists(pcPath) = 1

	# Returns the content of a real file.
	#
	#   pcPath     the real path
	#   returns    a text; an empty text when the file is absent
	#   see        RealExists, RealSize
	def RealContent(pcPath)
		return StzEngineFileRead(pcPath)

	# Returns the size of a real file.
	#
	#   pcPath     the real path
	#   returns    a number of bytes; -1 when the file is absent
	#   see        RealContent
	def RealSize(pcPath)
		return StzEngineFileSize(pcPath)

	# Returns a new tree holding the files of one real folder, each with its content and marked as mirrored.
	#
	#   pcDir      the real folder to read, one level only
	#   returns    a stzFileTree; an empty tree when the folder is absent
	#   see        stzVirtualFileSystem, RealContent
	#@ aka  Mirror one level of a real directory into a fresh tree (origin=mirrored).
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

	# Returns the facts that bound what the bridge acts on, which is its root.
	#
	#   returns    a list [ [ root, folder ] ]
	#   see        Root, Capabilities
	def Constraints()
		return [ [ "root", @cRoot ] ]

	# Returns the operation types the bridge can commit.
	#
	#   returns    a list of text: create_file, write_file, create_folder, delete_file,
	#              delete_folder, copy_file, move_file
	#   see        ExecuteOperation, Constraints
	def Capabilities()
		return [ "create_file", "write_file", "create_folder",
			 "delete_file", "delete_folder", "copy_file", "move_file" ]

	# Commits one file operation to the real disk.
	#
	#   oOp        the stzVirtualOperation to commit
	#   returns    TRUE if the disk call succeeded, FALSE if it failed or the type is not a file
	#              operation
	#   note       a move copies the file and then deletes the source
	#   warning    not run on a real folder: it writes and deletes real files, so reach it only
	#              through a plan that was narrated and reviewed; tried only on a scratch folder,
	#              where deleting a folder that still holds a file returned FALSE
	#   see        VerifyOutcome, stzUpdatePlan
	#@ aka  -- change reality (the ONE door) ----------------------
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
			return 0
		ok
		return 0

	# Checks after a commit that the disk is as the operation asked.
	#
	#   oOp        the stzVirtualOperation that was committed
	#   returns    TRUE or FALSE; checked for create, write, copy, move and delete, and always TRUE
	#              for a folder creation
	#   see        ExecuteOperation, RealExists
	def VerifyOutcome(oOp)
		_t_ = oOp.Type()
		if _t_ = "create_file" or _t_ = "write_file" or _t_ = "copy_file"
			return This.RealExists(oOp.Param("path")) or This.RealExists(oOp.Param("to"))
		but _t_ = "move_file"
			return This.RealExists(oOp.Param("to")) and NOT This.RealExists(oOp.Param("from"))
		but _t_ = "delete_file" or _t_ = "delete_folder"
			return NOT This.RealExists(oOp.Param("path"))
		ok
		return 1


  #========================#
 #  STZVIRTUALFILESYSTEM  #
#========================#
#
# The file twin. Inherits the generic rehearse/plan/commit core from
# stzVirtualSystem and adds the intent-named file verbs (rehearsal-only) plus
# MirrorFrom and free inspection that reads the TWIN, not reality.

# Rehearses file and folder changes in memory, so a change can be read, narrated and reviewed before the disk is touched.
#
# The file twin of stzVirtualSystem. CreateFile, WriteFile, CreateFolder, DeleteFile, DeleteFolder,
# CopyFile and MoveFile read like the real file verbs but only record an operation in an in-memory
# tree; Exists, ContentOf, SizeOf, Paths and the other readers answer from the twin, not from the
# disk. MirrorFile and MirrorFrom start a rehearsal from what the disk holds. GenerateUpdatePlan
# turns the rehearsal into a narrated plan, and only executing that plan reaches reality. The twin
# does not check what a verb names: it accepts a copy of a file it does not hold, which the plan's
# Validate then flags against the disk.
#
#   receiver   o1 = new stzVirtualFileSystem()
#   example    o1.CreateFolder("/w")
#              o1.CreateFile("/w/a.txt", "alpha")
#              o1.CopyFile("/w/a.txt", "/w/b.txt")
#              ? o1.Exists("/w/b.txt")
#              #--> 1
#              ? o1.ContentOf("/w/b.txt")
#              #--> alpha
#              ? o1.NumberOfOperations()
#              #--> 3
#   see        stzVirtualSystem, stzFileTree, stzFileSystemBridge, stzUpdatePlan,
#              StzVirtualFileSystemQ
class stzVirtualFileSystem from stzVirtualSystem

	# Builds a file twin with an empty in-memory tree, a bridge to the disk and no history.
	#
	#   returns    nothing; the twin is built
	#   see        MirrorFrom, StzVirtualFileSystemQ
	def init()
		@oState = new stzFileTree()
		@oBaseState = @oState.Clone()
		@aHistory = []
		@aSnapshots = []
		@oBridge = new stzFileSystemBridge("")
		@cActor = "human"

	# Rehearses creating a file with its content; the disk is not touched.
	#
	#   pcPath      the path of the file
	#   pcContent   the content, as text
	#   returns     the twin itself, so calls chain
	#   note        a path that already exists has its content replaced, without an error
	#   see         WriteFile, DeleteFile
	#@ aka  -- rehearsal verbs (record; touch NOTHING real) -------
	def CreateFile(pcPath, pcContent)
		This.ExecuteOperation(new stzVirtualOperation("create_file",
			[ [ "path", "" + pcPath ], [ "content", "" + pcContent ] ]))
		return This

	# Rehearses writing content into a file; the disk is not touched.
	#
	#   pcPath      the path of the file
	#   pcContent   the content, as text
	#   returns     the twin itself, so calls chain
	#   note        it is recorded as a write, so the narration says write rather than create
	#   see         CreateFile, ContentOf
	def WriteFile(pcPath, pcContent)
		This.ExecuteOperation(new stzVirtualOperation("write_file",
			[ [ "path", "" + pcPath ], [ "content", "" + pcContent ] ]))
		return This

	# Rehearses creating a folder; the disk is not touched.
	#
	#   pcPath     the path of the folder
	#   returns    the twin itself, so calls chain
	#   note       the folder that holds it is not required to exist
	#   see        DeleteFolder, Exists
	def CreateFolder(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("create_folder",
			[ [ "path", "" + pcPath ] ]))
		return This

	# Rehearses deleting a file; the disk is not touched.
	#
	#   pcPath     the path of the file
	#   returns    the twin itself, so calls chain
	#   note       an absent path is recorded and changes nothing; the plan flags the delete as
	#              destructive and Validate flags a target absent from the disk
	#   see        CreateFile, GenerateUpdatePlan
	def DeleteFile(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("delete_file",
			[ [ "path", "" + pcPath ] ]))
		return This

	# Rehearses deleting a folder; the disk is not touched.
	#
	#   pcPath     the path of the folder
	#   returns    the twin itself, so calls chain
	#   warning    the files below it stay in the twin; delete them first, as the real folder delete
	#              refuses a folder that is not empty
	#   see        CreateFolder, DeleteFile
	def DeleteFolder(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("delete_folder",
			[ [ "path", "" + pcPath ] ]))
		return This

	# Rehearses copying a file to another path; the disk is not touched.
	#
	#   pcFrom     the path of the file to copy
	#   pcTo       the path of the copy
	#   returns    the twin itself, so calls chain
	#   warning    a source the twin does not hold makes an empty file at the destination, which the
	#              disk would refuse; Validate catches it against the disk
	#   see        MoveFile, ContentOf
	def CopyFile(pcFrom, pcTo)
		This.ExecuteOperation(new stzVirtualOperation("copy_file",
			[ [ "from", "" + pcFrom ], [ "to", "" + pcTo ] ]))
		return This

	# Rehearses moving a file to another path; the disk is not touched.
	#
	#   pcFrom     the path of the file to move
	#   pcTo       the path it moves to
	#   returns    the twin itself, so calls chain
	#   warning    a source the twin does not hold makes an empty file at the destination, which the
	#              disk would refuse; the plan flags a move as removing its source
	#   see        CopyFile, DeleteFile
	def MoveFile(pcFrom, pcTo)
		This.ExecuteOperation(new stzVirtualOperation("move_file",
			[ [ "from", "" + pcFrom ], [ "to", "" + pcTo ] ]))
		return This

	# Reads one real file into the twin, marked as mirrored, so a rehearsal starts from what the disk holds.
	#
	#   pcPath     the real path of the file
	#   returns    the twin itself, so calls chain
	#   note       it reads the disk and changes nothing; the mirrored file is not counted in the
	#              history
	#   warning    an absent file changes nothing
	#   see        MirrorFrom, OriginOf
	#@ aka  -- read reality INTO the twin -------------------------
	def MirrorFile(pcPath)
		if @oBridge.RealExists(pcPath)
			@oState.PutFile(pcPath, @oBridge.RealContent(pcPath), "mirrored")
			@oBaseState = @oState.Clone()
		ok
		return This

	# Replaces the twin tree with the files of one real folder, each marked as mirrored.
	#
	#   pcDir      the real folder to read, one level only
	#   returns    the twin itself, so calls chain
	#   warning    it reads the disk and changes nothing; whatever the twin held before is dropped
	#   see        MirrorFile, stzFileSystemBridge
	#@ aka  Mirror one level of a real directory.
	def MirrorFrom(pcDir)
		@oState = @oBridge.CurrentRealityState(pcDir)
		@oBaseState = @oState.Clone()
		return This

	# TRUE if the twin holds a file or folder at that path.
	#
	#   pcPath     the path
	#   returns    TRUE or FALSE
	#   note       it answers from the twin, not from the disk
	#   see        ContentOf, Paths
	#@ aka  -- free inspection (reads the TWIN, not disk) ---------
	def Exists(pcPath)
		return @oState.Exists(pcPath)

	# Returns the content the twin holds at that path.
	#
	#   pcPath     the path
	#   returns    a text; an empty text for a folder or an absent path
	#   see        SizeOf, Exists
	def ContentOf(pcPath)
		return @oState.ContentOf(pcPath)

	# Returns the size of the content the twin holds at that path, in bytes.
	#
	#   pcPath     the path
	#   returns    a number; 0 for a folder or an absent path
	#   see        ContentOf
	def SizeOf(pcPath)
		return @oState.SizeOf(pcPath)

	# Returns where a path of the twin came from.
	#
	#   pcPath     the path
	#   returns    mirrored for one read from the disk, virtual for one born in the twin; an empty
	#              text when absent
	#   see        MirrorFile, Exists
	def OriginOf(pcPath)
		return @oState.OriginOf(pcPath)

	# Returns every path the twin holds, in the order added.
	#
	#   returns    a list of text
	#   see        NumberOfNodes, TreeView
	def Paths()
		return @oState.Paths()

	# Returns how many files and folders the twin holds.
	#
	#   returns    a number
	#   see        Paths
	def NumberOfNodes()
		return @oState.NumberOfNodes()

	# Returns the twin as text, one line per node with its type, its path and its origin.
	#
	#   returns    a text, several lines
	#   see        Show, Paths
	def TreeView()
		return @oState.TreeView()

	# Prints the number of nodes of the twin and its tree view.
	#
	#   returns    nothing; it prints
	#   see        TreeView
	def Show()
		@oState.Show()
