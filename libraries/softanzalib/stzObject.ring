# 			SOFTANZA LIBRARY (V1.0)
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing softanza objects      #
#	Version		: V1.1.0.6 (March, 2022)			    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#===========================================================================#

/*
	Mainly, this class servers as a parent for the common features
	ot its inherited classes, namely stzNumber, stzString, stzList, etc.
	# TODO: All the common features are not abstructed yet. Some of them
	# are duplicated due to semantic differences between classes.

	a stzObject is created:
		- by providing an exiting Ring object or,
		- by litterally providing the variable name
		  of that object (as a string)

	In the first case, stzObject augments the ring object by some features.

	In the second case, it is required that the variable name of that
	object is provided to the constructor of the class, in a string, like this:

		oPerson = new Person { name = "Kim" }
	
		oStzObj = new stzObject(:oPerson)
	
		class Person name

	The main feature you get by crating a stzObject using its variable name
	is that the object becomes "aware" of its name in the runtime,
	which is impossible with Ring (there is no sutch objectName(obj) function,
	only the name of the class can be provided by className(obj)).

	Hence, you can say:

		? oStzObj.ObjectName()	# --> "oPerson"

	All the meta data provided by Ring to objects are provided by this class:

		o1 = new Person { name = "Ali" age = 32 job = "Developer" }
		
		StzObjectQ( :o1 ) {
		
			? "ID: " + ObjectUID() + NL
		
			? "Object Name: " + ObjectVarName() + NL	# Return "o1"
		
			? "Object class: " + ObjectClassName() + NL
		
			? "Attributes:"
			? ObjectAttributes()
		
			? "Values:"
			? ObjectValues()
		
			? "Attributes and their values:"
			? ObjectAttributesAndValues()
		
			? "Methods:"
			? ObjectMethods()
		
			? "Object listified:"
			? Listify()
		
		}
		
		class Person
			name
			age
			job
		
			def init(cName)
				name = cName
		
			def show()
				? "Name : " + name
				? "Age  : " + age
				? "Job  : " + job


	Also, this class is useful to make several operations on objects
	that are required by the SoftanzaLib framework.

	Planned features of the stzObject class include the following:

	- we can send the name of a method to that object and ask it to try 
	to execute it => ExecuteMethod(cMethod)

	- we can call a method to be executed on a new object
	=> pvtExecuteMethodOn(cMethod,pNewValue)

	- we can sepcify it to be of type Container
	
	- we can tranform its type using: Stringify(), Numberify(), Objectify(), and Listify()

	- we can trace the object lifetime in the runtime using LifeTime()
	=> Tells us how many times the object is called
	=> Maintains the values of the states of the objects created and are live in the program
	=> Gives us an idea of the object scope using Scope()
	=> Gives us an idea of the object interactions with external code

	- we can persist the state of the object at a given time, or many times, in a string
	or text file or binary file or database

	- we can tell it to be instanciated only once using bIsSingleton = TRUE

	- we can define its job in the program by defining its type using cObjectJob
	=> cObjectJob  = :Worker	Performs a task and returs a result
	=> 		 :Observer	Observes the execution of other objects
	=> 		 :Presenter	Presents outputs to the user depending on its platform
	=> 		 :Reader	Reads data and provides it to other objects in native form
	=> 		 :Connector	Connects to data sources and return a connexion object
	=> 		 :Transformer	Transforms between data structures and text formats
	=> 		 :Writer	Writes data in a physical medium (string, text file, image...)
	=> 		 :Organiser	Defines an organization schema of objects (in term of layers and services)
	=> 		 :Calculator	Performs various calculations
	=> 		 :Translator	Translates texts between languages
	=> 		 :Parser	Parses a string
	=>		 :Painter
	=>		 :Charter
	=>		 :Timer

	- we can use any of its methods to be called on ...
*/

  ///////////////////
 //   FUNCTIONS   //
///////////////////

func StzObjectQ(pObject)
	return new stzObject(pObject)

func StzObjectMethods()
	return Stz(:Object, :Methods)

func StzObjectAttributes()
	return Stz(:Object, :Attributes)

func StzObjectClassName()
	return "stzobject"

	func StzObjectClass()
		return "stzobject"

func IsNotObject(pObject)
	return NOT isObject(pObject)

func RingQtClasses()
	# TODO: Update it
	aRingQtClasses = [
		:QAbstractAspect,
		:QAbstractButton,
		:QAbstractCameraController,
		:QAbstractItemView,
		:QAbstractPrintDialog,
		:QAbstractScrollArea,
		:QAbstractSeries,
		:QAbstractSlider,
		:QAbstractSocket,
		:QAbstractSpinBox,
		:QAction,
		:QAllEvents,
		:QApp,
		:QAreaLegendMarker,
		:QAreaSeries,
		:QAspectEngine,
		:QAxBase,
		:QAxObject,
		:QAxWidget,
		:QAxWidget2,
		:QBarCategoryAxis,
		:QBarLegendMarker,
		:QBarSeries,
		:QBarSet,
		:QBitmap,
		:QBluetoothAddress,
		:QBluetoothDeviceDiscoveryAgent,
		:QBluetoothDeviceInfo,
		:QBluetoothHostInfo,
		:QBluetoothLocalDevice,
		:QBluetoothServer,
		:QBluetoothServiceDiscoveryAgent,
		:QBluetoothServiceInfo,
		:QBluetoothSocket,
		:QBluetoothTransferManager,
		:QBluetoothTransferReply,
		:QBluetoothTransferRequest,
		:QBluetoothUuid,
		:QBoxLayout,
		:QBoxPlotLegendMarker,
		:QBoxPlotSeries,
		:QBoxSet,
		:QBrush,
		:QBuffer,
		:QButtonGroup,
		:QByteArray,
		:QCalendarWidget,
		:QCamera,
		:QCameraImageCapture,
		:QCameraLens,
		:QCameraSelector,
		:QCameraViewfinder,
		:QCandlestickLegendMarker,
		:QCandlestickModelMapper,
		:QCandlestickSeries,
		:QCandlestickSet,
		:QCategoryAxis,
		:QChar,
		:QChart,
		:QChartView,
		:QCheckBox,
		:QChildEvent,
		:QClipboard,
		:QColor,
		:QColorDialog,
		:QComboBox,
		:QCompleter,
		:QCompleter2,
		:QCompleter3,
		:QCompleter4,
		:QConeGeometry,
		:QConeMesh,
		:QCoreApplication,
		:QCuboidMesh,
		:QCullFace,
		:QCursor,
		:QCylinderMesh,
		:QDate,
		:QDateEdit,
		:QDateTime,
		:QDateTimeAxis,
		:QDateTimeEdit,
		:QDepthTest,
		:QDesktopServices,
		:QDesktopWidget,
		:QDial,
		:QDialog,
		:QDiffuseSpecularMaterial,
		:QDir,
		:QDirModel,
		:QDockWidget,
		:QDrag,
		:QDragEnterEvent,
		:QDragLeaveEvent,
		:QDragMoveEvent,
		:QDropEvent,
		:QEffect,
		:QEntity,
		:QEvent,
		:QExtrudedTextMesh,
		:QFile,
		:QFile2,
		:QFileDevice,
		:QFileDialog,
		:QFileInfo,
		:QFileSystemModel,
		:QFirstPersonCameraController,
		:QFont,
		:QFontDialog,
		:QFontMetrics,
		:QForwardRenderer,
		:QFrame,
		:QFrame2,
		:QFrame3,
		:QFrameAction,
		:QGeoAddress,
		:QGeoAreaMonitorInfo,
		:QGeoAreaMonitorSource,
		:QGeoCircle,
		:QGeoCoordinate,
		:QGeoPositionInfo,
		:QGeoPositionInfoSource,
		:QGeoRectangle,
		:QGeoSatelliteInfo,
		:QGeoSatelliteInfoSource,
		:QGeoShape,
		:QGoochMaterial,
		:QGradient,
		:QGraphicsScene,
		:QGraphicsVideoItem,
		:QGraphicsView,
		:QGridLayout,
		:QGuiApplication,
		:QHBarModelMapper,
		:QHBoxLayout,
		:QHBoxPlotModelMapper,
		:QHCandlestickModelMapper,
		:QHPieModelMapper,
		:QHXYModelMapper,
		:QHeaderView,
		:QHorizontalBarSeries,
		:QHorizontalPercentBarSeries,
		:QHorizontalStackedBarSeries,
		:QHostAddress,
		:QHostInfo,
		:QIODevice,
		:QIcon,
		:QImage,
		:QInputAspect,
		:QInputDialog,
		:QJsonArray,
		:QJsonDocument,
		:QJsonObject,
		:QJsonParseError,
		:QJsonValue,
		:QKeySequence,
		:QLCDNumber,
		:QLabel,
		:QLayout,
		:QLegend,
		:QLegendMarker,
		:QLineEdit,
		:QLineSeries,
		:QLinearGradient,
		:QListView,
		:QListWidget,
		:QListWidgetItem,
		:QLocale,
		:QLogValueAxis,
		:QLogicAspect,
		:QMainWindow,
		:QMaterial,
		:QMatrix4x4,
		:QMdiArea,
		:QMdiSubWindow,
		:QMediaObject,
		:QMediaPlayer,
		:QMediaPlaylist,
		:QMenu,
		:QMenuBar,
		:QMesh,
		:QMessageBox,
		:QMetalRoughMaterial,
		:QMimeData,
		:QMorphPhongMaterial,
		:QMovie,
		:QMutex,
		:QMutexLocker,
		:QNetworkAccessManager,
		:QNetworkProxy,
		:QNetworkReply,
		:QNetworkRequest,
		:QNmeaPositionInfoSource,
		:QNode,
		:QObject,
		:QObjectPicker,
		:QOpenGLBuffer,
		:QOpenGLContext,
		:QOpenGLDebugLogger,
		:QOpenGLFramebufferObject,
		:QOpenGLFunctions,
		:QOpenGLFunctions_3_2_Core,
		:QOpenGLPaintDevice,
		:QOpenGLShader,
		:QOpenGLShaderProgram,
		:QOpenGLTexture,
		:QOpenGLTimerQuery,
		:QOpenGLVersionProfile,
		:QOpenGLVertexArrayObject,
		:QOpenGLWidget,
		:QOrbitCameraController,
		:QPageSetupDialog,
		:QPaintDevice,
		:QPainter,
		:QPainter2,
		:QPainterPath,
		:QPen,
		:QPerVertexColorMaterial,
		:QPercentBarSeries,
		:QPhongMaterial,
		:QPicture,
		:QPieLegendMarker,
		:QPieSeries,
		:QPieSlice,
		:QPixmap,
		:QPixmap2,
		:QPlainTextEdit,
		:QPlaneMesh,
		:QPoint,
		:QPointF,
		:QPointLight,
		:QPolarChart,
		:QPrintDialog,
		:QPrintPreviewDialog,
		:QPrintPreviewWidget,
		:QPrinter,
		:QPrinterInfo,
		:QProcess,
		:QProgressBar,
		:QPushButton,
		:QQmlEngine,
		:QQmlError,
		:QQuaternion,
		:QQuickView,
		:QQuickWidget,
		:QRadioButton,
		:QRect,
		:QRegion,
		:QRegularExpression,
		:QRegularExpressionMatch,
		:QRegularExpressionMatchIterator,
		:QRenderAspect,
		:QRenderPass,
		:QScatterSeries,
		:QSceneLoader,
		:QScreen,
		:QScrollArea,
		:QScrollBar,
		:QSerialPort,
		:QSerialPortInfo,
		:QSize,
		:QSkyboxEntity,
		:QSlider,
		:QSphereMesh,
		:QSpinBox,
		:QSplashScreen,
		:QSplineSeries,
		:QSplitter,
		:QSqlDatabase,
		:QSqlDriver,
		:QSqlDriverCreatorBase,
		:QSqlError,
		:QSqlField,
		:QSqlIndex,
		:QSqlQuery,
		:QSqlRecord,
		:QStackedBarSeries,
		:QStackedWidget,
		:QStandardPaths,
		:QStatusBar,
		:QString2,
		:QStringList,
		:QStringRef,
		:QSurfaceFormat,
		:QSystemTrayIcon,
		:QTabBar,
		:QTabWidget,
		:QTableView,
		:QTableWidget,
		:QTableWidgetItem,
		:QTcpServer,
		:QTcpSocket,
		:QTechnique,
		:QTest,
		:QText2DEntity,
		:QTextBlock,
		:QTextBrowser,
		:QTextCharFormat,
		:QTextCodec,
		:QTextCursor,
		:QTextDocument,
		:QTextEdit,
		:QTextStream,
		:QTextStream2,
		:QTextStream3,
		:QTextStream4,
		:QTextStream5,
		:QTextToSpeech,
		:QTextureLoader,
		:QTextureMaterial,
		:QThread,
		:QThreadPool,
		:QTime,
		:QTimer,
		:QToolBar,
		:QToolButton,
		:QTorusMesh,
		:QTransform,
		:QTreeView,
		:QTreeWidget,
		:QTreeWidgetItem,
		:QUrl,
		:QUuid,
		:QVBarModelMapper,
		:QVBoxLayout,
		:QVBoxPlotModelMapper,
		:QVCandlestickModelMapper,
		:QVPieModelMapper,
		:QVXYModelMapper,
		:QValueAxis,
		:QVariant,
		:QVariant2,
		:QVariant3,
		:QVariant4,
		:QVariant5,
		:QVariantDouble,
		:QVariantFloat,
		:QVariantInt,
		:QVariantString,
		:QVector2D,
		:QVector3D,
		:QVector4D,
		:QVectorQVoice,
		:QVideoWidget,
		:QVideoWidgetControl,
		:QViewport,
		:QVoice,
		:QWebEnginePage,
		:QWebEngineView,
		:QWebView,
		:QWebView,
		:QWidget,
		:QWindow,
		:QXYLegendMarker,
		:QXYSeries,
		:QXmlStreamAttribute,
		:QXmlStreamAttributes,
		:QXmlStreamEntityDeclaration,
		:QXmlStreamEntityResolver,
		:QXmlStreamNamespaceDeclaration,
		:QXmlStreamNotationDeclaration,
		:QXmlStreamReader,
		:QXmlStreamWriter,
		:Qt3DCamera,
		:Qt3DWindow,
		:RingCodeHighlighter
	]

	return aRingQtClasses

func StzClasses()
	aResult = []

	for aClass in StzClassesXT()
		aResult + aClass[1]
	next

	return aResult

	def StzTypes()
		return StzClasses()

func StzClassesXT()
	# Last update: 11 Nov. 2022
	aStzClassesXT = [
		# [ :Singular,			:Plural			]
		[ :stzObject, 			:stzObjects 		],
		[ :stzListOfObjects, 		:stzListsOfObjects 	],
		[ :stzNumber, 			:stzNumbers		],

		[ :stzListOfNumbers, 		:stzListsOfNumbers	],
		[ :stzListOfUnicodes, 		:stzListsOfUnicodes	],
		[ :stzBinaryNumber, 		:stzBinaryNumbers	],

		[ :stzHexNumber, 		:stzHexNumbers		],
		[ :stzOctalNumber, 		:stzOctalNumbers	],
		[ :stzString, 			:stzStrings		],

		[ :stzSplitter,			:stzSplitters		],
		[ :stzMultiString, 		:stzMultiStrings	],
		[ :stzMultilingualString, 	:stzMultilingualStrings ],
		
		[ :stzStopWords, 		:stzStopWords		],
		[ :stzListOfStrings, 		:stzListsOfStrings	],
		[ :stzListInString, 		:stzListsInStrings	],

		[ :stzListOfBytes, 		:stzListsOfBytes	],
		[ :stzChar, 			:stzChars		],
		[ :stzUnicodeNames, 		:stzUnicodeNames	],

		[ :stzListOfChars, 		:stzListsOfChars	],
		[ :stzList, 			:stzLists		],
		[ :stzHashList, 		:stzHashLists		],

		[ :stzAssociativeList, 		:stzAssociativeLists	],
		[ :stzListOfHashLists, 		:stzListOfHashLists	],
		[ :stzSet, 			:stzSets		],
		[ :stzListOfLists, 		:stzListsOfLists	],
		[ :stzListOfPairs, 		:stzListsOfPairs	],
		[ :stzPair, 			:stzPairs		],
		
		[ :stzListOfSets, 		:stzListsOfSets		],
		[ :stzPairOfLists, 		:stzPairsOfLists	],
		[ :stzTree, 			:stzTrees		],

		[ :stzWalker, 			:stzWalkers		],
		[ :stzTable, 			:stzTables		],
		[ :stzLocale, 			:stzLocales		],
		
		[ :stzCountry, 			:stzCountries		],
		[ :stzLanguage, 		:stzLanguages		],
		[ :stzScript, 			:stzScripts		],

		[ :stzCurrency, 		:stzCurrencies		],
		[ :stzListParser, 		:stzListsParsers	],
		[ :stzGrid, 			:stzGrids		],

		[ :stzCounter, 			:stzCounters		],
		[ :stzDate, 			:stzDates		],
		[ :stzTime, 			:stzTimes		],

		[ :stzFile, 			:stzFiles		],
		[ :stzFolder, 			:stzFolders		],
		[ :stzRunTime, 			:stzRuntimes		],

		[ :stzTextEncoding, 		:stzTextEncodings	],
		[ :stzNaturalCode, 		:stzNaturalCodes	],
		[ :stzChainOfValue, 		:stzChainsOfValues	],

		[ :stzChainOfTruth, 		:stzChainsOfTruth	],
		[ :stzEntity, 			:stzEntities		],
		[ :stzListOfEntities, 		:stzListsOfEntities	],

		[ :stzText, 			:stzTexts		],
		[ :stzStringArt, 		:stzStringArts		],
		[ :stzConstraints, 		:stzConstraints		],
		
		[ :stzCCode, 			:stzCCodes		],
		[ :stzNullObject,		:stzNullObjects		]
	]

	return aStzClassesXT

	func StzTypesXT()
		return StzClassesXT()

	func StzClassesAndTheirPluralForm()
		return StzClassesXT()

func PluralOfStzClassName(cClass)

	return StzClassesXT()[cClass]

	func PluralOfStzType(cClass)
		return PluralOfStzClassName(cClass)

	func StzTypeToPlural(cClass)
		return PluralOfStzClassName(cClass)

	#--

	func PluralOfThisStzClassName(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfThisStzType(cClass)
		return PluralOfStzClassName(cClass)

func PluralToStzType(cPlural)
	oHash = new stzHashList( StzTypesXT() )
	n = oHash.FindFirstValue(cPlural)
	cResult = oHash.NthKey(n)
	return cResult

func IsStzobject(pObject)
	if isObject(pObject) and _(classname(pObject)).Q.ExistsIn( StzTypes() )
		return TRUE
	else
		return FALSE
	ok

/* NOTE: The following section of code is generated with
	 stzCodeGenerators and then pasted here
*/

#< @StartOfGenCode >

func IsStznaturalcode(pObject)
	if isObject(pObject) and classname(pObject) = "stznaturalcode"
		return TRUE
	else
		return FALSE
	ok

func IsStzchainofvalue(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofvalue"
		return TRUE
	else
		return FALSE
	ok

func IsStzchainoftruth(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainoftruth"
		return TRUE
	else
		return FALSE
	ok

func IsStzchainofcode(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofcode"
		return TRUE
	else
		return FALSE
	ok

func IsStztransform(pObject)
	if isObject(pObject) and classname(pObject) = "stztransform"
		return TRUE
	else
		return FALSE
	ok

func IsStznumber(pObject)
	if isObject(pObject) and classname(pObject) = "stznumber"
		return TRUE
	else
		return FALSE
	ok

func IsStzdecimaltobinary(pObject)
	if isObject(pObject) and classname(pObject) = "stzdecimaltobinary"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofnumbers(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofnumbers"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofunicodes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofunicodes"
		return TRUE
	else
		return FALSE
	ok

func IsStzbinarynumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzbinarynumber"
		return TRUE
	else
		return FALSE
	ok

func IsStzhexnumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzhexnumber"
		return TRUE
	else
		return FALSE
	ok

func IsStzoctalnumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzoctalnumber"
		return TRUE
	else
		return FALSE
	ok

func IsStzstring(pObject)
	if isObject(pObject) and classname(pObject) = "stzstring"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofstrings(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofstrings"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistinstring(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistinstring"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofbytes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofbytes"
		return TRUE
	else
		return FALSE
	ok

func IsStzmultilingualstring(pObject)
	if isObject(pObject) and classname(pObject) = "stzmultilingualstring"
		return TRUE
	else
		return FALSE
	ok

func IsStzmultistring(pObject)
	if isObject(pObject) and classname(pObject) = "stzmultistring"
		return TRUE
	else
		return FALSE
	ok

func IsStzchar(pObject)
	if isObject(pObject) and classname(pObject) = "stzchar"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofchars(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofchars"
		return TRUE
	else
		return FALSE
	ok

func IsStzlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzlist"
		return TRUE
	else
		return FALSE
	ok

func IsStzhashlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzhashlist"
		return TRUE
	else
		return FALSE
	ok

func IsStzassociativelist(pObject)
	if isObject(pObject) and classname(pObject) = "stzassociativelist"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofhashlists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofhashlists"
		return TRUE
	else
		return FALSE
	ok

func IsStzset(pObject)
	if isObject(pObject) and classname(pObject) = "stzset"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofsets(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofsets"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistoflists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistoflists"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistofpairs(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofpairs"
		return TRUE
	else
		return FALSE
	ok

func IsStztree(pObject)
	if isObject(pObject) and classname(pObject) = "stztree"
		return TRUE
	else
		return FALSE
	ok

func IsStzlistprovidedasstring(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistprovidedasstring"
		return TRUE
	else
		return FALSE
	ok

func IsStzwalker(pObject)
	if isObject(pObject) and classname(pObject) = "stzwalker"
		return TRUE
	else
		return FALSE
	ok

func IsStztable(pObject)
	if isObject(pObject) and classname(pObject) = "stztable"
		return TRUE
	else
		return FALSE
	ok

func IsStzlocale(pObject)
	if isObject(pObject) and classname(pObject) = "stzlocale"
		return TRUE
	else
		return FALSE
	ok

func IsStzconstraint(pObject)
	if isObject(pObject) and classname(pObject) = "stzconstraint"
		return TRUE
	else
		return FALSE
	ok

#< @EndOfGenCode >

func IsQObject(p)
	return StzStringQ( classname(p) ).ExistsIn( RingQtClasses() )

	#< @FunctionAlternativeForm

	func IsQtObject(p)
		return IsQObject(p)

	#>

func ObjectClassName(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectClassName()

func ObjectUID(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectUID()

func ObjectAttributes(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectAttributes()

func ObjectValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectValues()

func ObjectAttributesAndValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectAttributesAndValues()

func ObjectMethods(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectMethods()

func ObjectToList(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectToList()

func ObjectListify(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectListify()


  ///////////////
 //   CLASS   //
///////////////

class stzObject
	@oObject
	@cObjectVarName

	def init(pObject)

		if isObject(pObject)
			@oObject = pObject

		but IsNonNullString(pObject)

			@cObjectVarName = pObject

			cCode = "@oObject = " + pObject
			eval(cCode)

		but IsNullString(pObject)
			stzRaise("Can't create a stzObject from an empty string!")
		
		else
			stzRaise("Type error: you must provide an object or an object varname inside a string!")
		ok

	def Object()
		return @oObject

	def ObjectVarName()
		return @cObjectVarName

	def ObjectClassName()
		return classname(This)

	def ObjectUID()
		return objectid(This.Object())

	def ObjectAttributes()
		return attributes(This.Object())

	def ObjectValues()
		aResult = []
		for cAttribute in This.ObjectAttributes()
			cCode = "aResult + This.Object()." + cAttribute
			eval(cCode)
		next
		return aResult

	def ObjectAttributesAndValues()
		aResult = []
		i = 0
		for cAttribute in This.ObjectAttributes()
			i++
			aResult + [ cAttribute, This.ObjectValues()[i] ]
		next
		return aResult

		def AttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

		def ObjectAttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

	def ObjectMethods()
		return methods(This.Object())

	def Listify()
		aResult = []

		for cAttribute in This.ObjectAttributes()
			cCode = "aResult + [ cAttribute, This.Object()." + cAttribute + " ]"

			eval(cCode)
		next

		return aResult

	def IsEqualTo(poOtherObject)
		if StzListQ( This.Listify() ).IsEqualTo( StzObjectQ(poOtherObject).Listify() )
			return TRUE
		else
			return FALSE
		ok

	def IsStrictlyEqualTo(poOtherObject)
		if StzListQ( This.Listify() ).IsStrictlyEqualTo( StzObjectQ(poOtherObject).Listify() )
			return TRUE
		else
			return FALSE
		ok

	  #------------------#
	 #   CHECKING TYPE  #
	#------------------#

	def Type()
		return lower ( ring_type( This.Content() ) )

	def IsANumber()
		if This.StzType() = :stzNumber
			return TRUE
		else
			return FALSE
		ok

		def IsNotANumber()
			return NOT return This.IsANumber()
	
	def IsAString()

		if This.StzType() = :stzString
			return TRUE
		else
			return FALSE
		ok

		def IsNotAString()
			return NOT return This.IsAString()
	
	def IsAList()
		if This.StzType() = :stzList
			return TRUE
		else
			return FALSE
		ok

		def IsNotAList()
			return NOT return This.IsAList()
	
	def IsAnObject()
		return TRUE

		def IsObjekt()
			return TRUE

		def IsNotAnObject()
			return FALSE
	
			def IsNotObjeket()
				return This.IsNotAnObject()

	def IsOneOfTheseTypes(paTypes)

		/* EXAMPLE

		? Q("2").IsOneOfTheseTypes([ :Number, :String, :List ])
		#--> TRUE

		# can also be written use :Or = ...
		? Q("2").IsOneOfTheseTypes([ :Number, :Or = :String, :Or = :List ])
		#--> TRUE
		*/

		if NOT isList(paTypes)
			stzRaise("Incorrect param type! paTypes must be a list.")
		ok

		for type in paTypes
			if isList(type) and Q(type).IsOrNamedParam()
				type = type[2]
			ok
		next

		bResult = FALSE

		for cType in paTypes
			if This.IsA(cType)
				bResult = TRUE
				exit
			ok
		next

		return bResult
		
		def IsNotOneOfTheseTypes(paTypes)
			return NOT This.IsOneOfTheseTypes(paTypes)

	def IsEachOneOfTheseTypes(paTypes)
		if NOT isList(paTypes)
			stzRaise("Incorrect param type! paTypes must be a list.")
		ok

		for type in paTypes
			if isList(type) and Q(type).IsOrNamedParam()
				type = type[2]
			ok
		next

		bResult = TRUE

		for cType in paTypes
			if NOT This.IsA(cType)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsA(pcType)

		/* Example

		? _([ :name = "mio", :age = 12 ]).IsA(:HashList)._

		--> TRUE
		*/
		if isList(pcType)
			if Q(pcType).IsListOfStrings()
				return This.IsEachOneOfTheseTypes(pcType)

			else
				return This.IsOneOfTheseTypes(pcType)
			ok
		ok

		if pcType = :Number
			pcType = :ANumber
		but pcType = :String
			pcType = :AString
		but pcType = :List
			pcType = :AList
		but pcType = :Object
			pcType = :AnObject
		ok

		cCode = 'bResult = This.Is'+ pcType + '()'
		
		eval(cCode)
		return bResult

		def IsAn(pcType)
			return This.IsA(pcType)

		def Is(pcType)
			return This.IsA(pcType)

	def IsNotA(pcType)
		return NOT This.IsA(pcType)

		def IsNotAn(pcType)
			return This.IsNotA(pcType)

		def IsNot(pcType)
			return This.IsNotA(pcType)

	def IsEitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsOrNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT BothAreStrings(pcType1, pcType2)
			stzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if This.IsA(pcType1) or This.IsA(pcType2)
			return TRUE
		else
			return FALSE
		ok

		def IsEither(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

	def IsNeitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsNorNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT BothAreStrings(pcType1, pcType2)
			stzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if NOT This.IsA(pcType1) and
		   NOT This.IsA(pcType2)

			return TRUE
		else
			return FALSE
		ok

	def HasSameTypeAs(p)
		return isObject(p)

	def Stringify()
		return StzListQ( This.Listify() ).ToCode()

		def Stringified()
			return This.Stringify()

	  #======================================#
	 #  REPEATING THE OBJECT VALUE N TIMES  #
	#======================================#

	def Repeat(n)
		return This.RepeatXT(:InList, n)

		def RepeatQ(n)
			return This.RepeatXTQ(:InList, n)

		def RepeatNTimes(n)
			return This.Repeat(n)

			def RepeatNTimesQ(n)
				return This.RepeatQ(n)

	def Repeated(n)
		aResult = This.Copy().RepeatQ(n).Content()
		return aResult

		def RepeateNTimes(n)
			return This.Repeated(n)

	  #-------------------------------------------------------------------#
	 #  REPEATING THE OBJECT VALUE IN A GIVEN CONTAINER OF A GIVEN SIZE  #
	#-------------------------------------------------------------------#

	def RepeatXT(pIn, pnSize)

		/* EXAMPLE
		o1 = new stzNumber(5)
		o1.RepeatXT([ :InA = :List, :OfSize = 2 ])
		#--> [ 5, 5 ]
		*/

		# Step 1: Resolving params

		if isList(pIn) and
			( Q(pIn).IsInNamedParam() or
			  Q(pIn).IsInANamedParam() )

			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) and
				Q(pIn).IsOneOfTheseCS([
					:String, :List, :ListOfNumbers, :ListOfStrings,
					:ListOfLists, :ListOfPairs, :Grid, :Table,

					:AString, :AList, :AListOfNumbers, :AListOfStrings,
					:AListOfLists, :AListOfPairs, :AGrid, :ATable,

					:InString, :InList, :InListOfNumbers, :InListOfStrings,
					:InListOfLists, :InListOfPairs, :InGrid, :InTable,

					:InAString, :InAList, :InAListOfNumbers, :InAListOfStrings,
					:InAListOfLists, :InAListOfPairs, :InAGrid, :InATable

				], :CS = FALSE)
			)

			stzRaise("Incorrect param! pIn must be a string representing one of" +
				 "these Softanza types: :String, :List, :ListOfNumbers, :ListOfStrings, " +
				 ":ListOfLists, :ListOfPairs, :Grid, :Table.")
		ok

		if isList(pnSize) and
			( Q(pnSize).IsOfSizeNamedParam() or
			  Q(pnZise).IsSizeNamedParam() )

			pnSize = pnSize[2]
		ok

		if NOT ( isNumber(pnSize) or (isList(pnSize) and Q(pnSize).IsPairOfNumbers()) )
			stzRaise("Incorrect param type! pnSize must be a number.")
		ok

		# Step 1: Doing the job

		value = ""
		if this.IsANumber()
			value = This.Number()
		else
			value = This.Content()
		ok

		if Q(pIn).IsOneOfThese([ :List, :InList, :AList, :InAList ])
	
			aResult = []
			for i = 1 to pnSize
				aResult + value
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :ListOfNumbers, :InListOfNumbers,
					  :AListOfNumbers, :InAListOfNumbers ])

			aResult = []
			for i = 1 to pnSize
				aResult + Q(value).ToNumber()
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :ListOfStrings, :InListOfStrings,
					  :AListOfStrings, :InAListOfStrings ])

			aResult = []
			for i = 1 to pnSize
				aResult + Q(value).ToString()
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :ListOfLists, :InListOfLists,
					  :AListOfLists, :InAListOfLists ])
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value ]
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :ListOfPairs, :InListOfPairs,
					  :AListOfPairs, :InAListOfNPairs ])
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value, value ]
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :String, :InString, :AString, :InAString ])

			cResult = ""
			for i = 1 to pnSize
				cResult += value
			next
			return cResult

		but Q(pIn).IsOneOfThese([ :Grid, :InGrid, :AGrid, :InAGrid ])

			aResult = StzGridQ([ pnSize[1], pnSize[2] ]).
					ReplaceAllQ(:With = value).
					Content()

			return aResult

		but Q(pIn).IsOneOfThese([ :Table, :InTable, :ATable, :InATable ])

			aResult = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(value).Content()
			return aResult

		else
			stzRaise("Unsupported type of container! Allowed containers you can repeat " +
				 "the value in are: :List, :Pair, :ListOfLists, :ListOfPairs, :String, :Grid, and :Table.")
		ok

		#< @FunctionFluentForm

		# RETURNUNG THE OBJECT MODIFIED

		def RepeatXTQ(pIn, pnSize)
			if isString(pIn) and pIn = :String
				return new stzString( This.RepeatXT(pIn, pnSize) )

			else
				return new stzList( This.RepeatXT(pIn, pnSize) )
			ok

		#-- RETURNING A MODIFIED COPY

		def RepeatXTCQ(pIn, pnSize)
			return This.Copy().RepeatXT(pIn, pnSiz)

		#>

	#-- RETURNING THE OUTPUT DATA

	def RepeatedXT(pIn, pnSize)
		return This.Copy().RepeatXT(pIn, pnSize)

	  #----------------------------------------#
	 #  REPEATING THE OBJECT VALUE IN A PAIR  #
	#----------------------------------------#

	def RepeatInPair()
		return This.RepeatXT(:InA = :List, :OfSize = 2)

		#< @FunctionFluentForm

		def RepeatInAPairQ(pnSize)
			return new stzList( This.RepeatInAPair(pnSize) )

		#>

		#< @AlternativeForms

		def RepeatInAPair()
			return This.RepeatInPair()
	
			def RepeatInPairQ()
				return new stzList( This.RepeatInPair() )
	

		def RepeatedInPair()
			return This.RepeatInPair()
	
			def RepeatedInPairQ()
				return new stzList( This.RepeatInPair() )

		def RepeatedInAPair()
			return This.RepeatInPair()

			def RepeatedInAPairQ()
				return new stzList( This.RepeatInPair() )

		#>
/*	
	  #--------------------------------------------------------------#
	 #   REPEATING THE OBJECT VALUE N TIMES (IN A LIST OF N ITEMS)  #
	#--------------------------------------------------------------#

	def RepeatNTimes(n)
		if This.IsANumber()
			anResult = []
			for i = 1 to n
				anResult + This.Number()
			next
			return anResult

		but This.IsAString()
			# Do nothing at this level
			#--> Managed by the same method inside stzString

		else
			aResult = []
			for i = 1 to n
				aResult + This.Content()
			next
			return aResult
		ok

		def RepeatedNTimes(n)
			return This.RepeatNtimes(n)

		def NTimes(n)
			return This.RepeatNtimes(n)
*/
	  #------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER  #
	#------------------------------------------#

	def ToNumber()
		if This.IsANumber()
			return This.NumericValue()

		but This.IsAString()
			return  0+ This.Content()

		but This.IsAList()
			return This.NumberOfItems()

		else
			stzRaise("Can't cast the object into a number.")
		ok

	def ToNumberXT(pcCode)

		if isList(pcCode) and Q(pcCode).IsUsingNamedParam()
			pcCode = pcCode[2]
		ok

		if NOT isString(pcCode)
			stzRaise("Incorrect param type! pcCode must be a string.")
		ok

		@number = 0
		if This.IsANumber()
			@number = This.Number()
		ok
		
		cCode = @@SQ(pcCode).
			RemoveBoundsQ('"').
			RemoveThisFirstCharQ("{").
			RemoveThisLastCharQ("}").
			Trimmed()
		
		if NOT Q(cCode).StartsWithOneOfTheseCS([
			"@number =", "@number +=", "@number=", "@number+=" ],
			:CaseSensitive = FALSE )

			stzRaise("Syntax error! pcCode must start with '@number =' or '@number +='.")
		ok

		if Q(cCode).StartsWithEitherCS( "@number=", :Or = "@number =", :CS = FALSE )
			# EXAMPLE
			# ? Q([ "a", "b", "c" ]).ToNumberXT('{ @number = len(@list) }')
			#--> 3

			@list = This.Content()
			@string = This.Content()

			eval(cCode)
			return @number
		else
			# CASE += is used on a list of items or a sstring

			# EXAMPLE
			# ? Q([ "Me", "and", "You!" ]).ToNumberXT('{ @number += len(@item) }')
			#--> 9
			@number = 0
			//cCode = Q(cCode).ReplaceCSQ("@string", :By = "@item", :CS = FALSE).Content()

			if This.IsANumber()
				eval(cCode)

			but This.IsAString()
				for i = 1 to This.NumberOfChars()
					@char = This.Char(i)
					eval(cCode)
				next
			but This.IsAList()
				for @item in This.List()
					eval(cCode)
				next
			ok

			return @number
		ok

	  #------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A STRING  #
	#------------------------------------------#

	def ToString()
		if This.IsANumber()
			return This.StringValue()

		but This.IsAString()
			return This.Content()

		but This.IsAList()
			return This.NumberOfItems()

		else
			stzRaise("Can't cast the object into a number.")
		ok

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsOneOfThese(paList)
		return StzListQ(paList).Contains(This.Object())

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)

	def Methods()
		return ring_methods(This)

	def Attributes()
		return ring_attributes(This)

	def ClassName()
		return "stzobject"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	def IsText()
		return FALSE
