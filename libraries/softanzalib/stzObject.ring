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

	def StzDataTypes()
		return StzClasses()

	def StzTypes()
		return StzClasses()

func StzClassesXT()
	# Last update: 11 Nov. 2022
	aStzClassesXT = [
		# [ :Singular,			:Plurial		]
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

	func StzDataTypesXT()
		return StzClassesXT()

	func StzTypesXT()
		return StzClassesXT()

	func StzClassesAndTheirPluralForm()
		return StzClassesXT()

func PluralOfStzClassName(cClass)
	return StzClassesXT()[cClass]

func IsStzClass(pcClass)
	return _(pcClass).@.ExistsIn( StzClasses() )

		

func IsStzobject(pObject)
	if isObject(pObject) and _(classname(pObject)).Q.ExistsIn( StzDataTypes() )
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

	  #---------------------------------------------#
	 #   CHECKING TYPE OF OBJECT (VIA CLASSNAME)   #
	#---------------------------------------------#

	def Is(pcType)
		// Example: Is(:StzNumber)

		bResult = FALSE
		if isString(pcType)
			cCode = 'if StzStringQ(This.ObjectClassname()).Lowercased() = "' +
				 StzStringQ(pcType).Lowercased() + '"' + NL +
				'	bResult = TRUE' + NL +
				'ok'
			eval(cCode)
		ok

		return bResult

	  #---------------------------------------------#
	 #   USED BY NATURAL-CODE IN stzChainOfTruth   #
	#---------------------------------------------#

	def IsAnObject()
		return TRUE

		def IsObjekt()
			return TRUE

	def IsA(pcType)

		/* Example

		? _([ :name = "mio", :age = 12 ]).IsA(:HashList)._

		--> TRUE
		*/

		cCode = 'bResult = This.Is'+ pcType + '()'
		
#		try
			eval(cCode)
			return bResult
#		catch
#			return FALSE
#		done

	def Datatype()
		return :Object

	def IsOneOfThese(paList)
		return StzListQ(paList).Contains(This.Object())

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)

	def HasSameTypeAs(p)
		return isObject(p)

	def Stringify()
		return StzListQ( This.Listify() ).ToCode()

		def Stringified()
			return This.Stringify()

	  #---------------------------------------------------------#
	 #  REPRODUCING THE OBJECT IN A CONTAINER OF A GIVEN SIZE  #
	#---------------------------------------------------------#

	def Reproduce(pIn, pnSize)

		/* EXAMPLE
		o1 = new stzNumber(5)
		o1.Reproduce([ :InA = :List, :OfSize = 2 ])
		#--> [ 5, 5 ]
		*/

		if isList(pIn) and
			( Q(pIn).IsInNamedParam() or
			  Q(pIn).IsInANamedParam() )

			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) and
				Q(pIn).IsOneOfTheseCS([
					:String, :List, :ListOfLists,
					:ListOfPairs, :Grid, :Table
				], :CS = FALSE)
			)

			stzRaise("Incorrect param! pIn must be a string representing one of" +
				 "these Softanza types: :String, :List, :ListOfLists, " +
				 ":ListOfPairs, :Grid, and :Table.")
		ok

		if isList(pnSize) and
			( Q(pnSize).IsOfSizeNamedParam() or
			  Q(pnZise).IsSizeNamedParam() )

			pnSize = pnSize[2]
		ok

		if NOT ( isNumber(pnSize) or (isList(pnSize) and Q(pnSize).IsPairOfNumbers()) )
			stzRaise("Incorrect param type! pnSize must be a number.")
		ok

		#-- Doing the job

		value = ""
		if this.IsANumber()
			value = This.Number()
		else
			value = This.Content()
		ok

		if Q(pIn) = :List
	
			aResult = []
			for i = 1 to pnSize
				aResult + value
			next
			return aResult

		but Q(pIn) = :ListOfLists
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value ]
			next
			return aResult

		but Q(pIn) = :ListOfPairs
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value, value ]
			next
			return aResult

		but Q(pIn) = :String

			cResult = ""
			for i = 1 to pnSize
				cResult += value
			next
			return cResult

		but Q(pIn) = :Grid
			aResult = StzGridQ([ pnSize[1], pnSize[2] ]).
					ReplaceAllQ(:With = value).
					Content()

			return aResult

		but Q(pIn) = :Table
			aResult = StzTableQ([ pnSize[1], pnSize[2] ]).Content()
			return aResult
		ok

	  #-----------------------------------------------#
	 #  REPRODUCING THE NUMBER IN A LIST OF N ITEMS  #
	#-----------------------------------------------#

	def ReproduceInList(pnSize)

		/* EXAMPLE

		o1 = new stzNumber(5)
		? o1.ReproducedInList(:OfSize = 3)
		#--> [ 5, 5, 5 ]

		*/

		if isList(pnSize) and Q(pnSize).IsOfSizeNamedParam()
			pnSize = pnSize[2]
		ok

		if NOT isNumber(pnSize)
			stzRaise("Incorrect param type! pnSize must be a number.")
		ok

		aResult = []

		for i = 1 to pnSize
			if This.IsANumber()
				aResult + This.Number()
			else
				aResult + This.Content()
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def ReproduceInListQ(pnSize)
			return new stzList( This.ReproduceInList(pnSize) )

		def ReproduceInListQQ(pnSize) # TODO: Generalize ..QQ() to all functions!
			return new stzListOfNumbers( This.ReproduceInList(pnSize) )

		#>

		#< @FunctionAlternativeForms

		def ReproduceInAList(pnSize)
			return This.ReproduceInList(pnSize)

			#< @FunctionFluentForm
	
			def ReproduceInAListQ(pnSize)
				return new stzList( This.ReproduceInAList(pnSize) )
	
			def ReproduceInAListQQ(pnSize) # TODO: Generalize ..QQ() to all functions!
				return new stzListOfNumbers( This.ReproduceInAList(pnSize) )
	
			#>

		def ReproducedInAList(pnSize)
			return This.ReproduceInList(pnSize)

			#< @FunctionFluentForm
	
			def ReproducedInAListQ(pnSize)
				return new stzList( This.ReproducedInAList(pnSize) )
	
			def ReproducedInAListQQ(pnSize) # TODO: Generalize ..QQ() to all functions!
				return new stzListOfNumbers( This.ReproducedInAList(pnSize) )
	
			#>

		def ReproducedInList(pnSize)
			return This.ReproduceInList(pnSize)

			#< @FunctionFluentForm
	
			def ReproducedInListQ(pnSize)
				return new stzList( This.ReproducedInList(pnSize) )
	
			def ReproducedInListQQ(pnSize)
				return new stzListOfNumbers( This.ReproducedInList(pnSize) )
	
			#>

		#>

	  #------------------------------------#
	 #  REPRODUCING THE NUMBER IN A PAIR  #
	#------------------------------------#

	def ReproduceInAPair()
		return This.ReproduceInAList(:OfSize = 2)

		#< @FunctionFluentForm

		def ReproduceInAPairQ(pnSize)
			return new stzList( This.ReproduceInAPair(pnSize) )

		def ReproduceInAPairQQ(pnSize) # TODO: Generalize ..QQ() to all functions!
			return new stzListOfNumbers( This.ReproduceInAPair(pnSize) )

		#>

		#< @AlternativeForms

		def ReproducedInAPair()
			return This.ReproduceInAPair()

			#< @FunctionFluentForm
	
			def ReproducedInAPairQ()
				return new stzList( This.ReproducedInAPair() )
	
			def ReproducedInAPairQQ() # TODO: Generalize ..QQ() to all functions!
				return new stzListOfNumbers( This.ReproducedInAPair() )
	
			#>

		def ReproduceInPair()
			return This.ReproduceInAPair()

			#< @FunctionFluentForm
	
			def ReproduceInPairQ()
				return new stzList( This.ReproduceInPair() )
	
			def ReproduceInPairQQ() # TODO: Generalize ..QQ() to all functions!
				return new stzListOfNumbers( This.ReproduceInPair() )
	
			#>

		def ReproducedInPair()
			return This.ReproduceInAPair()

			#< @FunctionFluentForm
	
			def ReproducedInPairQ()
				return new stzList( This.ReproducedInPair() )
	
			def ReproducedInPairQQ() # TODO: Generalize ..QQ() to all functions!
				return new stzListOfNumbers( This.ReproducedInPair() )
	
			#>

		#>

	  #------------------------------#
	 #  GETTING N TIMES THE OBJECT  #
	#------------------------------#

	def NTimes(n)
		if This.IsANumber()
			return This.Number() * n

		but This.IsAString()
			cResult = ""
			for i = 1 to n
				cResult += This.Content()
			next
			return cResult

		but This.IsAList() or This.IsAnObject()
			aResult = This.Reproduce( :InA = :List, :OfSize = n )
			return aResult
		ok 
	
	  #-----------#
	 #   MISC.   #
	#-----------#

	def RepeatNtimes(n)
		aResult = []
		for i = 1 to n
			aResult + This.Object()
		next
		return aResult

		def RepeatedNTimes(n)
			return This.RepeatNtimes(n)
