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
	#TODO: All the common features are not abstructed yet. Some of them
	# are duplicated due to semantic differences between classes.

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
	that are required by the SoftanzaLib.

	Planned features of the stzObject class include the following:

	- we can send the name of a method to that object and ask it to try 
	to execute it => ExecuteMethod(cMethod)

	- we can call a method to be executed on a new object
	=> pvtExecuteMethodOn(cMethod,pNewValue)

	- we can sepcify it to be of type Container
	
	- we can tranform its type using: ToString(), ToNumber(), ToObject(), and ToList()

	- we can trace the object lifetime in the runtime using LifeTime()
	=> Tells us how many times the object is called
	=> Maintains the values of the states of the objects created and are live in the program
	=> Gives us an idea of the object scope using Scope()
	=> Gives us an idea of the object interactions with external code

	- we can serialize the state of the object at a given time, or many times, in a string
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
	=>		 :Painter	...
	=>		 :Charter	...
	=>		 :Timer		...
	=>		 ...


*/

  ///////////////////
 //   FUNCTIONS   //
///////////////////

func StzObjectQ(pObject)
	return new stzObject(pObject)

func StzNamedObject(paNamed)
	if CheckParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPairOfStringAndObject())
			StzRaise("Incorrect param type! paNamed must be a pair of string and object.")
		ok
	ok

	oObject = Q(paNamed[2])
	oObject.SetName(paNamed[1])
	return oObject

	func StzNamedObjectQ(paNamed)
		return StzNamedObject(paNamed)

	func StzNamedObjectXTQ(paNamed)
		return StzNamedObject(paNamed)

func StzObjectMethods()
	return Stz(:Object, :Methods)

func StzObjectAttributes()
	return Stz(:Object, :Attributes)

func StzObjectClassName()
	return "stzobject"

	func StzObjectClass()
		return "stzobject"

func IsNotObject(p)
	return NOT isObject(p)

	func @IsNotObject(p)
		return IsNotObject(p)

	func IsNotAnObject(p)
		return IsNotObject(p)

	func @IsNotAnObject(p)
		return IsNotObject(p)

func ObjectVarName(pObject)
	
	if NOT isObject(pObject)
		StzRaise("Incorrect param type! pObject must be an object.")
	ok

	cResult = :@NoName
	if ObjectIsStzObject(pObject)
		cResult = pObject.VarName()
	ok

	return cResult

	func ObjectName(pObject) # Note the difference with classname(pObject)
		return ObjectVarName(pObject)

	func @ObjectVarName(pObject)
		return ObjectVarName(pObject)

	func @ObjectName(pObject)
		return ObjectVarName(pObject)

func ObjectIsNamed(pObject)
	if ObjectVarName(pObject) != :@NoName
		return TRUE
	else
		return FALSE
	ok

	func @ObjectIsNamed(pObject)
		return ObjectIsNamed(pObject)

func ObjectIsUnnamed(pObject)
	return NOT ObjectIsNamed(pObject)

	func @ObjectIsUnnamed(pObject)
		return ObjectIsUnnamed(pObject)

#--

func RingQtClasses()
	#TODO: Update it tp Ring 1.19
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
		:QMedIsAObject,
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
		:QString,
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
		:RingCodeHighlighter,
		:QTextOption # Added in Ring 1.18
		
	]

	return aRingQtClasses

func NumberOfRingQtClasses()
	return len(RingQtClasses())

	func HowManyRingQtClasses()
		return NumberOfRingQtClasses()

func StzClasses()
	aResult = []
	acStzClassesXT = StzClassesXT()
	nLen = len(acStzClassesXT)

	for i = 1 to nLen
		aResult + acStzClassesXT[i][1]
	next

	return aResult

	func StzTypes()
		return StzClasses()

func NumberOfStzClasses()
	return len(StzClasses())

	func HowManyStzClasses()
		return NumberOfStzClasses()

func StzClassesXT()
	#TODO: Update this list!
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
		[ :stzListOfHashLists,		:stzListsOfHashLists	],

		[ :stzAssociativeList, 		:stzAssociativeLists	],
		[ :stzSet, 			:stzSets		],
		[ :stzListOfLists, 		:stzListsOfLists	],

		[ :stzListOfPairs, 		:stzListsOfPairs	],
		[ :stzPair, 			:stzPairs		],
		[ :stzPairOfNumbers, 		:stzPairsOfNumbers	],
		[ :stzPairOfLists,		:stzPairsOfList		],
		
		[ :stzListOfSets, 		:stzListsOfSets		],
		[ :stzTree, 			:stzTrees		],

		[ :stzWalker, 			:stzWalkers		],
		[ :stzTable, 			:stzTables		],
		[ :stzListOfTables,		:stzListsOfTables	],
		[ :stzLocale, 			:stzLocales		],
		
		[ :stzCountry, 			:stzCountries		],
		[ :stzLanguage, 		:stzLanguages		],
		[ :stzScript, 			:stzScripts		],

		[ :stzCurrency, 		:stzCurrencies		],
		[ :stzListParser, 		:stzListsParsers	],
		[ :stzGrid, 			:stzGrids		],
		[ :stzListOfGrids,		:stzListsOfGrids	],

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
		[ :stzNullObject,		:stzNullObjects		],
		[ :stzFalseObject,		:stzFalsebjects		],
		[ :stzTrueObject,		:stzTruebjects		],

		[ :stzExtCode,			:stzExtCodes		],
		
		[ :stzSection,			:stzSections		],

		[ :stzNullObject,		:stzNullObjects		],
		[ :stzTrueObject,		:stzTrueObjects		],
		[ :stzFalseObjects,		:stzFalseObjects	]
	]

	return aStzClassesXT

	func StzTypesXT()
		return StzClassesXT()

	func StzClassesAndTheirPluralForm()
		return StzClassesXT()

	
func PluralOfRingType(cType)
	if CheckParams()
		if NOT IsString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	if NOT IsRingType(cType)
		StzRaise("Incorrect param! cType is not a valid Ring type.")
	ok

	cType = lower(cType)
	acRingTypesXT = RingTypesXT()
	nLen = len(acRingTypesXT)

	cResult = ""
	for i = 1 to nLen
		if acRingTypesXT[i][1] = cType
			cResult = acRingTypesXT[i][2]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Can't get a plural of a Ring type form string!")
	else
		return cResult
	ok

func RingTypesPlurals()
	acResult = []
	aRingTypesXT = RingTypesXT()
	nLen = len(aRingTypesXT)

	for i = 1 to nLen
		acResult + aRingTypesXT[i][2]
	next

	return acResult

	func PluralsOfRingTypes()
		return RingTypesPlurals()

func IsPluralOfRingType(cPlural)
	if CheckParams()
		if NOT IsString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acRingTypesPlurals = RingTypesPlurals()
	nLen = len(acRingTypesPlurals)

	bResult = FALSE

	for i = 1 to nLen
		if acRingTypesPlurals[i] = cPlural
			bResult = TRUE
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func IsRingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsPluralOfARingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsARingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsRingTypeInPlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsARingTypInePlural(cPlural)
		return IsPluralOfRingType(cPlural)
	#--

	func @IsPluralOfRingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsRingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsPluralOfARingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsARingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsRingTypeInPlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsARingTypInePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	#>
	
func RingTypesXT()
	return _aRingTypesXT
	
func PluralToRingType(cPlural)
	if CheckParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acRingTypesXT = RingTypesXT()
	nLen = len(acRingTypesXT)

	cResult = ""

	for i = 1 to nLen
		if acRingTypesXT[i][2] = cPlural
			cResult = acRingTypesXT[i][1]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Plural does not exist or can't be be found!")
	else
		return cResult
	ok

func PluralOfStzClassName(cClass)

	return StzClassesXT()[cClass]

	#< @FunctionAlternativeForms

	func PluralOfStzType(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfStzClass(cClass)
		return PluralOfStzClassName(cClass)

	func StzTypeToPlural(cClass)
		return PluralOfStzClassName(cClass)

	func StzClassNameToPlural(cClass)
		return PluralOfStzClassName(cClass)

	func StzClassToPlural(cClass)
		return PluralOfStzClassName(cClass)

	#--

	func PluralOfThisStzClass(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfThisStzClassName(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfThisStzType(cClass)
		return PluralOfStzClassName(cClass)

	#>

func StzClassesPlurals()
	acResult = []

	acClassesXT = StzClassesXT()
	nLen = len(acClassesXT)

	for i = 1 to nLen
		acResult + acClassesXT[i][2]
	next

	return acResult

	def PluralsOfStzClasses()
		return StzClassesPlurals()

	def PluralsOfStzClassesNames()
		return StzClassesPlurals()

	def StzTypesPlurals()
		return StzClassesPlurals()

	def PluralsOfStzTypes()
		return StzClassesPlurals()

func IsPluralOfAStzType(cPlural)
	if CheckParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acPlurals = StzClassesPlurals()
	nLen = len(acPlurals)

	if find(acPlurals, cPlural) > 0
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func IsPluralOfStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzTypePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfAStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzClassPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfAStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzClassNamePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#--

	func IsStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsAStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#==

	func @IsPluralOfAStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzTypePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfAStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzClassPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfAStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzClassNamePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#--

	func @IsStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsAStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#>

func PluralToStzType(cPlural)
	if CheckParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	
	acTypesXT = StzTypesXT()

	nLen = len(acTypesXT)

	cResult = ""

	for i = 1 to nLen
		if acTypesXT[i][2] = cPlural
			cResult = acTypesXT[i][1]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Not a plural of a stzType or can't find it!")
	ok

	return cResult

	#< @FunctionAlternativeForms

	func PluraltoStzClass(cPlural)
		return PluralToStzType(cPlural)

	func PluraltoStzClassName(cPlural)
		return PluralToStzType(cPlural)

	#>

func IsStzObject(pObject)

	if isObject(pObject) and Q(classname(pObject)).ExistsIn( StzTypes() )
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzObject(pObject)
		return IsStzObject(pObject)

	func @IsStzObject(pObject)
		return IsStzObject(pObject)

	#--

	func IsAStzObject(pObject)
		return IsStzObject(pObject)

	func @IsAStzObject(pObject)
		return IsStzObject(pObject)

	func ObjectIsAStzObject(pObject)
		return IsStzObject(pObject)

	#>

func IsNamedObject(pObject) 
	if isObject(pObject) and @IsStzObject(pObject) and pObject.IsNamed()
		return TRUE

	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func ObjectIsNamedObject(pObject)
		return IsNamedObject(pObject)

	func @IsNamedObject(pObject)
		return IsNamedObject(pObject)

	#--

	func IsANamedObject(pObject)
		return IsNamedObject(pObject)

	func @IsANamedObject(pObject)
		return IsNamedObject(pObject)

	#>

func IsUnnamedObject(pObject)
	return NOT IsNamedObject(pObject)

	#< @FunctionAlternativeForms

	func ObjectIsUnnamedObject()
		return IsUnnamedObject(pObject)

	func @IsUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	#--

	func IsAUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	func @IsAnUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	#>

/* NOTE: The following section of code is generated with
	 stzCodeGenerators and then pasted here
*/

#< @StartOfGenCode >

func IsStzNaturalCode(pObject)
	if isObject(pObject) and classname(pObject) = "stznaturalcode"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	func @IsStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	#--

	func IsAStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	func @IsAStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)


func IsStzChainOfValue(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofvalue"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzchainofvalue(pObject)
		return IsStzchainofvalue(pObject)

	func @IsStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

	#--

	func IsAStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

	func @IsAStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

func IsStzchainofTruth(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainoftruth"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzchainoftruth(pObject)
		return IsStzchainoftruth(pObject)

	func @IsStzchainoftruth(pObject)
		return IsStzchainoftruth(pObject)

	#--

	func IsAStzchainofTruth(pObject)
		return IsStzchainofTruth(pObject)

	func @IsAStzchainofTruth(pObject)
		return IsStzchainofTruth(pObject)

func IsStzChainOfCode(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofcode"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzchainofcode(pObject)
		return IsStzchainofcode(pObject)

	func @IsStzchainofcode(pObject)
		return IsStzchainofcode(pObject)

	#--

	func IsAStzchainofCode(pObject)
		return IsStzchainofCode(pObject)

	func @IsAStzchainofTCode(pObject)
		return IsStzchainofCode(pObject)

func IsStzTransform(pObject)
	if isObject(pObject) and classname(pObject) = "stztransform"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStztransform(pObject)
		return IsStztransform(pObject)

	func @IsStztransform(pObject)
		return IsStztransform(pObject)

	#--

	func IsAStzTransform(pObject)
		return IsStzTransform(pObject)

	func @IsAStzTransform(pObject)
		return IsStzTransform(pObject)

func IsStzDecimalToBinary(pObject)
	if isObject(pObject) and classname(pObject) = "stzdecimaltobinary"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzdecimaltobinary(pObject)
		return IsStzdecimaltobinary(pObject)

	func @IsStzdecimaltobinary(pObject)
		return IsStzdecimaltobinary(pObject)

	#--

	func IsAStzDecimalToBinary(pObject)
		return IsStzDecimalToBinary(pObject)

	func @IsAStzDecimalToBinary(pObject)
		return IsStzDecimalToBinary(pObject)

func IsStzListOfNumbers(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofnumbers"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofnumbers(pObject)
		return IsStzlistofnumbers(pObject)

	func @IsStzlistofnumbers(pObject)
		return IsStzlistofnumbers(pObject)

	#--

	func IsAStzListOfNumbers(pObject)
		return IsStzListOfNumbers(pObject)

	func @IsAStzListOfNumbers(pObject)
		return IsStzListOfNumbers(pObject)

func IsStzListOfUnicodes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofunicodes"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofunicodes(pObject)
		return IsStzlistofunicodes(pObject)

	func @IsStzlistofunicodes(pObject)
		return IsStzlistofunicodes(pObject)

	#--

	func IsAStzListOfUnicodes(pObject)
		return IsStzListOfUnicodes(pObject)

	func @IsAStzListOfUnicodes(pObject)
		return IsStzListOfUnicodes(pObject)

func IsStzBinaryNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzbinarynumber"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzBinaryNumber(pObject)
		return IsStzbinarynumber(pObject)

	func @IsStzbinarynumber(pObject)
		return IsStzbinarynumber(pObject)

	#--

	func IsAStzBinaryNumber(pObject)
		return IsStzBinaryNumber(pObject)

	func @IsAStzBinaryNumber(pObject)
		return IsStzBinaryNumber(pObject)

func IsStzHexNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzhexnumber"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzhexnumber(pObject)
		return IsStzhexnumber(pObject)

	func @IsStzhexnumber(pObject)
		return IsStzhexnumber(pObject)

	#--

	func IsAStzHexNumber(pObject)
		return IsStzHexNumber(pObject)

	func @IsAStzHexNumber(pObject)
		return IsStzHexNumber(pObject)

func IsStzOctalNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzoctalnumber"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzoctalnumber(pObject)
		return IsStzoctalnumber(pObject)

	func @IsStzoctalnumber(pObject)
		return IsStzoctalnumber(pObject)

	#--

	func IsAStzOctalNumber(pObject)
		return IsStzOctalNumber(pObject)

	func @IsAStzOctalNumber(pObject)
		return IsStzOctalNumber(pObject)

func IsStzString(pObject)
	if isObject(pObject) and classname(pObject) = "stzstring"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzstring(pObject)
		return IsStzstring(pObject)

	func @IsStzstring(pObject)
		return IsStzstring(pObject)

	#--

	func IsAStzString(pObject)
		return IsStzString(pObject)

	func @IsAStzString(pObject)
		return IsStzString(pObject)

func IsStzlistOfStrings(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofstrings"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofstrings(pObject)
		return IsStzlistofstrings(pObject)

	func @IsStzlistofstrings(pObject)
		return IsStzlistofstrings(pObject)

	#--

	func IsAStzListOfStrings(pObject)
		return IsStzlistOfStrings(pObject)

	func @IsAStzListOfStrings(pObject)
		return IsStzlistOfStrings(pObject)

func IsStzlistInString(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistinstring"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistinstring(pObject)
		return IsStzlistinstring(pObject)

	func @IsStzlistinstring(pObject)
		return IsStzlistinstring(pObject)

	#--

	func IsAStzListInString(pObject)
		return IsStzlistInString(pObject)

	func @IsAStzListInString(pObject)
		return IsStzlistInString(pObject)

func IsStzListOfBytes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofbytes"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofbytes(pObject)
		return IsStzlistofbytes(pObject)

	func @IsStzlistofbytes(pObject)
		return IsStzlistofbytes(pObject)

	#--

	func IsAStzListOfBytes(pObject)
		return IsStzlistOfBytes(pObject)

	func @IsAStzListOfBytes(pObject)
		return IsStzlistOfBytes(pObject)

func IsStzMultilingualString(pObject)
	if isObject(pObject) and classname(pObject) = "stzmultistring"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzmultilingualstring(pObject)
		return IsStzmultilingualstring(pObject)

	func @IsStzmultilingualstring(pObject)
		return IsStzmultilingualstring(pObject)

	#--

	func IsAStzMultilingualString(pObject)
		return IsStzMultilingualString(pObject)

	func @IsAStzMultilingualString(pObject)
		return IsStzMultilingualString(pObject)

	#==

	func IsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	func ObjectIsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	func @IsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	#--

	func IsAStzMultiString(pObject)
		return IsStzMultilingualString(pObject)

	func @IsAStzMultiString(pObject)
		return IsStzMultilingualString(pObject)

	#>


func IsStzchar(pObject)
	if isObject(pObject) and classname(pObject) = "stzchar"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzchar(pObject)
		return IsStzchar(pObject)

	func @IsStzchar(pObject)
		return IsStzchar(pObject)

	#--

	func IsAStzChar(pObject)
		return IsStzChar(pObject)

	func ObjectIsAStzchar(pObject)
		return IsStzchar(pObject)

	func @IsAStzchar(pObject)
		return IsStzchar(pObject)

func IsStzlistofchars(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofchars"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	func @IsStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	#--

	func IsAStzListOfChars(pObject)
		return IsStzlistofchars(pObject)

	func ObjectIsAStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	func @IsAStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

func IsStzlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzlist"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlist(pObject)
		return IsStzlist(pObject)

	func @IsStzlist(pObject)
		return IsStzlist(pObject)
		
	#--

	func IsAStzList(pObject)
		return IsStzlist(pObject)

	func ObjectIsAStzlist(pObject)
		return IsStzlist(pObject)

	func @IsAStzlist(pObject)
		return IsStzlist(pObject)

func IsStzHashlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzhashlist"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzHashlist(pObject)
		return IsStzHashlist(pObject)

	func @IsStzHashlist(pObject)
		return IsStzHashlist(pObject)

	#--

	func IsAStzHashList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsAStzHashlist(pObject)
		return IsStzHashlist(pObject)

	func @IsAStzHashlist(pObject)
		return IsStzHashlist(pObject)

	#==

	func IsStzAssociativeList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsStzassociativelist(pObject)
		return IsStzHashlist(pObject)

	func @IsStzassociativelist(pObject)
		return IsStzHashlist(pObject)

	#--

	func IsAStzAssociativeList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsAStzAssociativelist(pObject)
		return IsStzHashlist(pObject)

	func @IsAStzAssociativelist(pObject)
		return IsStzHashlist(pObject)

	#>

func IsStzlistofhashlists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofhashlists"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	#--

	func IsAStzListOfHashLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsAStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsAStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	#==

	func IsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	#--

	func IsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	#>


func IsStzset(pObject)
	if isObject(pObject) and classname(pObject) = "stzset"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzset(pObject)
		return IsStzset(pObject)

	func @IsStzset(pObject)
		return IsStzset(pObject)

	#--

	func IsAStzSet(pObject)
		return IsStzSet(pObject)

	func ObjectIsAStzset(pObject)
		return IsStzset(pObject)

	func @IsAStzset(pObject)
		return IsStzset(pObject)

func IsStzlistofsets(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofsets"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofsets(pObject)
		return IsStzlistofsets(pObject)

	func @IsStzlistofsets(pObject)
		return IsStzlistofsets(pObject)

	#--

	func IsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

	func ObjectIsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

	func @IsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

func IsStzlistoflists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistoflists"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistoflists(pObject)
		return IsStzlistoflists(pObject)

	func @IsStzlistoflists(pObject)
		return IsStzlistoflists(pObject)

	#--

	func IsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

	func ObjectIsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

	func @IsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

func IsStzlistofpairs(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofpairs"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlistofpairs(pObject)
		return IsStzlistofpairs(pObject)

	func @IsStzlistofpairs(pObject)
		return IsStzlistofpairs(pObject)

	#--

	func IsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

	func ObjectIsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

	func @IsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

func IsStztree(pObject)
	if isObject(pObject) and classname(pObject) = "stztree"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStztree(pObject)
		return IsStztree(pObject)

	func @IsStztree(pObject)
		return IsStztree(pObject)

	#--

	func IsAStzTree(pObject)
		return IsStzTree(pObject)

	func ObjectIsAStztree(pObject)
		return IsStztree(pObject)

	func @IsAStztree(pObject)
		return IsStztree(pObject)

func IsStzwalker(pObject)
	if isObject(pObject) and classname(pObject) = "stzwalker"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzwalker(pObject)
		return IsStzwalker(pObject)

	func @IsStzwalker(pObject)
		return IsStzwalker(pObject)

	#--

	func IsAStzWalker(pObject)
		return IsStzwalker(pObject)

	func ObjectIsAStzWalker(pObject)
		return IsStzwalker(pObject)

	func @IsAStzWalker(pObject)
		return IsStzwalker(pObject)

func IsStztable(pObject)
	if isObject(pObject) and classname(pObject) = "stztable"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStztable(pObject)
		return IsStztable(pObject)

	func @IsStztable(pObject)
		return IsStztable(pObject)

	#--

	func IsAStzTable(pObject)
		return IsStzTable(pObject)

	func ObjectIsAStzTable(pObject)
		return IsStzTable(pObject)

	func @IsAStzTable(pObject)
		return IsStzTable(pObject)

func IsStzlocale(pObject)
	if isObject(pObject) and classname(pObject) = "stzlocale"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzlocale(pObject)
		return IsStzlocale(pObject)

	func @IsStzlocale(pObject)
		return IsStzlocale(pObject)

	#--

	func IsAStzLocale(pObject)
		return IsStzLocale(pObject)

	func ObjectIsAStzLocale(pObject)
		return IsStzLocale(pObject)

	func @IsAStzLocale(pObject)
		return IsStzLocale(pObject)

func IsStzgrid(pObject)
	if isObject(pObject) and classname(pObject) = "stzgrid"
		return TRUE
	else
		return FALSE
	ok

	func ObjectIsStzgrid(pObject)
		return IsStzgrid(pObject)

	func @IsStzgrid(pObject)
		return IsStzgrid(pObject)

	#--

	func IsAStzGrid(pObject)
		return IsStzGrid(pObject)

	func ObjectIsAStzGrid(pObject)
		return IsStzGrid(pObject)

	func @IsAStzGrid(pObject)
		return IsStzGrid(pObject)

func IsStzNullObject(pObject)
	if isObject(pObject) and classname(pObject) = "stznullobject"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func IsNullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsStzNullObject(pObject)
		return IsTzNullObject(pObject)

	func ObjectIsNullObject(pObject)
		return IsStzNullObject(pObject)

	#--

	func @IsStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func @IsNullObject(pObject)
		return IsStzNullObject(pObject)

	#==

	func IsAStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func IsANullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsStzANullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsANullObject(pObject)
		return IsStzNullObject(pObject)

	#--

	func @IsAStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func @IsANullObject(pObject)
		return IsStzNullObject(pObject)

	#>

func IsStzFalseObject(pObject)
	if isObject(pObject) and classname(pObject) = "stzfalseobject"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func IsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#--

	func @IsStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func @IsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#==

	func IsAStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func IsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsStzAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#--

	func @IsAStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func @IsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#>

func IsStzTrueObject(pObject)
	if isObject(pObject) and classname(pObject) = "stzfalseobject"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func IsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	#--

	func @IsStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func @IsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	#==

	func IsAStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func IsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsStzATrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	#--

	func @IsAStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func @IsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	#>

#< @EndOfGenCode >

func IsQObject(p)
	return StzStringQ( classname(p) ).ExistsIn( RingQtClasses() )

	#< @FunctionAlternativeForms

	func IsQtObject(p)
		return IsQObject(p)

	func ObjectIsQObject(p)
		return IsQObject(p)

	func ObjectisQtObject(p)
		return IsQObject(p)

	#--

	func @IsQObject(p)
		return IsQObject(p)

	func @IsQtObject(p)
		return IsQObject(p)

	func @ObjectIsQObject(p)
		return IsQObject(p)

	func @ObjectisQtObject(p)
		return IsQObject(p)

	#==

	func IsAQObject(p)
		return IsQObject(p)

	func IsAQtObject(p)
		return IsQObject(p)

	func ObjectIsAQObject(p)
		return IsQObject(p)

	func ObjectIsAQtObject(p)
		return IsQObject(p)

	#--

	func @IsAQObject(p)
		return IsQObject(p)

	func @IsAQtObject(p)
		return IsQObject(p)

	func @ObjectIsAQObject(p)
		return IsQObject(p)

	func @ObjectisAQtObject(p)
		return IsQObject(p)

	#>

func ObjectClassName(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectClassName()

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


  ///////////////
 //   CLASS   //
///////////////

class stzObject
	@oObject

	@cVarName = :@NoName

	def init(pObject)

		# Creating an object from an existing object
		if isObject(pObject)
			@oObject = pObject

		# Creating an object from the name of an existing object
		but IsNonNullString(pObject)

			cCode = 'bOk = isObject(' + pObject + ')'
			eval(cCode)
			if NOT bOk
				StzRaise("Can't create a stzObject from the provided string! The string must be a valid object name.")
			ok

			@cVarName = pObject

			cCode = "@oObject = " + pObject
			eval(cCode)

		but IsNullString(pObject)
			StzRaise("Can't create a stzObject from an empty string!")
		
		else
			StzRaise("Type error: you must provide an object or an object varname inside a string!")
		ok

	def Object()
		return @oObject

		def ObjectQ()
			return new stzObject( This )

	def VarName()
		return @cVarName

		#< @FunctionFluentForm

		def VarNameQ()
			return new stzString( This.VarName() )

		#>

		#< @FunctionAlternativeForms

		def ObjectName()
			return This.VarName()

			def ObjectNameQ()
				return This.VarNameQ()

		def Name()
			return This.VarName()

			def NameQ()
				return This.VarNameQ()

		def ObjectVarName()
			return This.VarName()

			def ObjectVarNameQ()
				return This.VarNameQ()

		#>

	def IsUnnamed()
		if This.VarName() = :@NoName
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def IsUnnamedObject()
			return This.IsUnnamed()

		def HasNoName()
			return This.IsUnnamed()

		def IsNotNamed()
			return This.IsUnnamed()

		def IsNotNamedObject()
			return This.IsUnnamed()

		def IsAnUnnamedObject()
			return This.IsUnnamed()

		def IsNotANamedObject()
			return This.IsUnnamed()

		#>

	def IsNamed()
		if This.Name() != :@NoName
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def IsNamedObject()
			return This.IsNamed()

		def HasName()
			return This.IsNamed()

		def HasAName()
			return This.IsNamed()

		def IsANamedObject()
			return This.IsNamed()

		#>

	def SetVarName(pcVarName)
		if isList(pcVarName) and Q(pcVarName).IsToOrAsNamedParams()
			pcVarName = pcVarName[2]
		ok

		if NOT isString(pcVarName)
			StzRaise("Incorrect param type! pcVarName must be a string.")
		ok

		@cVarName = pcVarName

		#< @FunctionAlternativeForms

		def SetVarNameTo(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectVarName(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectVarNameTo(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectName(pcVarName)
			This.SetVarName(pcVarName)

		def SetName(pcVarName)
			This.SetVarName(pcVarName)

		#>

	def Copy()
		return new stzObject( This )

	def ObjectClassName() # Depricated, use ClassName()
		return classname(This)

	def ObjectAttributes() # Depricated, use Attributes() instead
		return ring_attributes(This)

	def ObjectValues()
		aResult = []
		acAttributes = This.ObjectAttributes()
		nLen = len(acAttributes)

		for i = 1 to nLen 
			cCode = "aResult + This." + acAttributes[i]
			eval(cCode)
		next
		return aResult

		def AttributesValues()
			return This.ObjectValues()

	def ObjectAttributesAndValues()
		aResult = Association([
				This.ObjectAttributes(),
				This.ObjectValues()
		])

		return aResult

		def Content() #TODO: Shoud this be like that?
			return This.ObjectAttributesAndValues()

		def AttributesXT()
			return This.ObjectAttributesAndValues()

		def AttributesAndValues()
			return This.ObjectAttributesAndValues()

		def AttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

		def ObjectAttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

	def ObjectMethods() # Depricated, use Methods() instead
		return methods(This.Object())

	  #------------------#
	 #   CHECKING TYPE  #
	#------------------#

	def Type()
		return :Object
		# NOTE: Unlike Ring, Softanza returns the type in lowercase

		def RingType()
			return :Object

	def TypeXT()
		return [ This.Content(), This.Type() ]

	def StzType()
		return :stzObject
		# WARNING: The same function should exist inside each Softanza class
		#--> if we call it on a stzOject we get :stzobject, but if wa call
		#    on an other softanza type, say stzString or stzList for example,
		#    we get, not :stzobject as a resutl, but :stzstring and stzlist!

	def StzTypeXT()
		return [ :stzObject, This.Content() ]

	def IsStzNumber()
		if This.StzType() = :stzNumber
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsAStzNumber()
			return This.IsStzNumber()

		#>

		#< @FunctionPassiveForm

		def IsNotStzNumber()
			return NOT This.IsStzNumber()

		def IsNotAStzNumber()
			return NOT This.IsStzNumber()

		#>
	
	def IsStzString()

		if This.StzType() = :stzString
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsAStzString()
			return This.IsStzString()

		#>

		#< @FunctionPassiveForm

		def IsNotStzString()
			return NOT This.IsStzString()

		def IsNotAStzString()
			return NOT This.IsStzString()

		#>
	
	def IsStzList()
		if This.StzType() = :stzList
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsAStzList()
			return This.IsStzList()

		#>

		#< @FunctionPassiveForm

		def IsNotStzList()
			return NOT This.IsStzList()

		def IsNotAStzList()
			return NOT This.IsStzList()

		#>
	
	def IsStzGrid()
		if This.StzType() = :stzgrid
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsAStzGrid()
			return This.IsStzGrid()

		#>

		#< @FunctionPassiveForm

		def IsNotStzGrid()
			return NOT This.IsStzGrid()

		def IsNotAStzGrid()
			return NOT This.IsStzGrid()

		#>

	def IsStzObject()
		return TRUE

		#< @FunctionAlternativeForm

		def IsAStzObject()
			return TRUE

		#>

		#< @FunctionPassiveForm

		def IsNotStzObject()
			return FALSE
	
		def IsNotAStzObject()
			return This.IsNotAnObject()

		#>

	def HasSameTypeAs(p)
		return isObject(p)

	def HasSameStzTypeAs(p)
		if isObject(p) and Q(p).IsStzType() and
		   Q(p).StzType() = This.StzType()

			return TRUE
		else
			return FALSE
		ok

	def IsOneOfTheseTypes(paTypes)

		/* EXAMPLE

		? Q("2").IsOneOfTheseTypes([ :Number, :String, :List ])
		#--> TRUE

		# can also be written use :Or = ...
		? Q("2").IsOneOfTheseTypes([ :Number, :Or = :String, :Or = :List ])
		#--> TRUE
		*/

		if NOT isList(paTypes)
			StzRaise("Incorrect param type! paTypes must be a list.")
		ok

		for type in paTypes
			if isList(type) and Q(type).IsOrNamedParam()
				type = type[2]
			ok
		next

		bResult = FALSE

		for cType in paTypes

			if cType = "number" or cType = "string" or cType = "list"
				cType = "A" + cType
			but cType = "object"
				cType = "anobject"
			ok

			if (This.IsA(cType) or This.Is(cType))
				bResult = TRUE
				exit
			ok
		next

		return bResult
		
		def IsNotOneOfTheseTypes(paTypes)
			return NOT This.IsOneOfTheseTypes(paTypes)

	def IsEachOneOfTheseTypes(paTypes)
		if NOT isList(paTypes)
			StzRaise("Incorrect param type! paTypes must be a list.")
		ok

		for type in paTypes
			if isList(type) and Q(type).IsOrOrAndNamedParam()
				type = type[2]
			ok
		next

		bResult = TRUE

		for cType in paTypes
			if NOT (This.IsA(cType) or This.Is(cType))
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsNumberOrString()
		content = This.Content()
		if isNumber(content) or isString(content)
			return TRUE
		else
			return FALSE
		ok

		def IsStringOrNumber()
			return This.IsNumberOrString()

	def IsStringOrList()
		content = This.Content()
		if isNumber(content) or isList(content)
			return TRUE
		else
			return FALSE
		ok

		def IsListOrString()
			return This.IsListOrString()

	#==

	def IsFalseObject()
		if This.StzType() = :stzFlaseObject
			return TRUE
		else
			return FALSE
		ok

		#-- @Misspelled

		def IsFalseObejct()
			return This.IsFalseObject()

	def IsTrueObject()
		if This.StzType() = :stzFlaseObject
			return TRUE
		else
			return FALSE
		ok

	def IsNullObject()
		if This.StzType() = :stzNullObject
			return TRUE
		else
			return FALSE
		ok

	def IsAXT(pacStr)
		/* EAMPLE
		? Q("ring").IsA([ :Lowercase, :Latin, :String ])
		*/

		if CheckParams()
			if NOT ( isList(pacStr) and @IsListOfStrings(pacStr) )
				StzRaise("Incorrect param type! pacStr must be a list of strings.")
			ok
		ok

		nLen = len(pacStr)
		if nLen = 0
			return FALSE
		ok

		cType = lower(pacStr[nLen])
		if NOT @IsRingOrStzType(cType)
			StzRaise("Incorrect param value! paStr must contains a Ring or Softanza type at the end.")
		ok

		content = This.Content()

		if isNumber(content)
			obj = new stzNumber(content)

		but isString(content)
			object = new stzString(content)

		but isList(content)
			object = new stzList(content)

		but isObject(content)
			object = new stzObject(content)

		but @IsStzType(cType)
			switch cType
			on stzobject
			on stzlistofobjects
			on stznumber
			on stzlistofnumbers
			on stzlistofunicodes
			on stzbinarynumber
			on stzhexnumber
			on stzoctalnumber
			on stzstring
			on stzsplitter
			on stzmultistring
			on stzmultilingualstring
			on stzstopwords
			on stzlistofstrings
			on stzlistinstring
			on stzlistofbytes
			on stzchar
			on stzunicodenames
			on stzlistofchars
			on stzlist
			on stzhashlist
			on stzlistofhashlists
			on stzassociativelist
			on stzset
			on stzlistoflists
			on stzlistofpairs
			on stzpair
			on stzpairofnumbers
			on stzpairoflists
			on stzlistofsets
			on stztree
			on stzwalker
			on stztable
			on stzlistoftables
			on stzlocale
			on stzcountry
			on stzlanguage
			on stzscript
			on stzcurrency
			on stzlistparser
			on stzgrid
			on stzlistofgrids
			on stzcounter
			on stzdate
			on stztime
			on stzfile
			on stzfolder
	
			on stztextencoding
			on stznaturalcode
			on stzchainofvalue
			on stzchainoftruth
			on stzentity
			on stzlistofentities
			on stztext
			on stzstringart
			on stzconstraints
			on stzccode
			on stznullobject
			on stzfalseobject
			on stztrueobject
			on stzextcode
			on stzsection
			on stznullobject
			on stztrueobject
			on stzfalseobjects
		ok

	def IsA(pcType)
		/* Example

		? Q([ :name = "mio", :age = 12 ]).IsA(:HashList)
		--> TRUE

		? Q("ring").IsA([ :Lowercase, :Latin, :String ])

		*/

		if NOT isString(pcType)
			StzRaise("Incorrect param type! pcType must be a string.")
		ok
		
		pcType = StzStringQ(pcType).InfereType()

		if pcType = "number" or pcType = "string" or pcType = "list"
			pcType = "A" + pcType
		but pcType = "object"
			pcType = "anobject"
		ok

		cCode = 'bResult = This.Is'+ pcType + '()'

		try
			eval(cCode)
			return bResult
		catch
			return FALSE
		done

		#< @FunctionFluentForm

		def IsAQ(pcType)

			if This.IsA(pcType) = TRUE

				if pcType = "number" or pcType = "stznumber"
					return This.ToStzNumber()

				but pcType = "string" or pcType = "stzstring"
					return This.ToStzString()

				but pcType = "char" or pcType = "stzchar"
					return This.ToStzChar()

				but pcType = "list" or pcType = "stzlist"
					return This.ToStzList()

				but pctype = "object" or pcType = "stzobject"
					return This
				ok
			else
				return AFalseObject()
			ok

		#>

		#< @FunctionAlternativeForms

		def IsAn(pcType)
			return This.IsA(pcType)

			def IsAnQ(pcType)
				return This.IsAQ(pcType)

		def AreA(pcType)
			return This.IsA(pcType)

			def AreAQ(pcType)
				return This.IsAQ(pcType)

		def AreAn(pcType)
			return This.IsA(pcType)

			def AreAnQ(pcType)
				return This.IsAQ(pcType)

		#--

		def IsThe(pcType)
			return This.IsA(pcType)

			def IsTheQ(pcType)
				return This.IsAQ(pcType)

		def AreThe(pcType)
			return This.IsA(pcType)

			def AreTheQ(pcType)
				return This.IsAQ(pcType)

		#>

	def Is(pcType)

		if NOT isString(pcType)
			StzRaise("Incorrect param type! pcType must be a string.")
		ok
		
		pcType = StzStringQ(pcType).InfereType()

		if pcType = "number" or pcType = "string" or pcType = "list"
			pcType = "A" + pcType
		but pcType = "object"
			pcType = "anobject"
		ok

		cCode = 'bResult = This.Is'+ pcType + '()'

		try
			eval(cCode)
			return bResult
		catch
			return FALSE
		done

		def IsQ(pcType)
			if This.Is(pcType) = TRUE

				if pcType = "number" or pcType = "stznumber" or
				   pcType = "anumber" or pcType = "astznumber"
					return This.ToStzNumber()

				but pcType = "string" or pcType = "stzstring" or
				    pcType = "astring" or pcType = "astzstring"
					return This.ToStzString()

				but pcType = "char" or pcType = "stzchar" or
				    pcType = "achar" or pcType = "astzchar"
					return This.ToStzChar()

				but pcType = "list" or pcType = "stzlist" or
				    pcType = "alist" or pcType = "astzlist"
					return This.ToStzList()

				but pctype = "object" or pcType = "stzobject" or
				    pctype = "aobject" or pcType = "astzobject" or
				    pcType = "anobject"
					return This
				ok
			else
				return AFalseObject()
			ok

	def Are(pcType)
		/* Example

		? Q([ 10, 2à, 3à ]).Are(:Numbers)

		--> TRUE
		*/
 
		if NOT This.IsAList()
			return FALSE
		ok

		if NOT ( @IsRingTypeInPlural(pcType) or @IsStzTypeInPlural(pcType) )
			StzRaise("Incorrect param type! pcType must be a Ring type or Softanza type in plural.")
		ok

		cCode = 'bResult = This.IsListOf'+ pcType + '()'
		eval(cCode)
		return bResult

		#< @FunctionAlternativeForms

		def AreQ(pcType)
			if This.Are(pcType) = TRUE

				if pcType = "numbers" or pcType = "stznumbers"
					return This.ToStzListOfNumbers()

				but pcType = "strings" or pcType = "stzstrings"
					return This.ToStzListOfStrings()

				but pcType = "chars" or pcType = "stzchars"
					return This.ToStzListOfChars()

				but pcType = "lists" or pcType = "stzlists"
					return This.ToStzListOfLists()

				but pctype = "objects" or pcType = "stzobjects"
					return This.ToStzListOfObjects()
				ok
			else
				return AFalseObject()
			ok

		def AreQM(pcType)
			SetMainObject(This)
			return AreQ(pcType)
			
		#>

		def AreAll(pcType)
			return This.Are(pcType)

			def AreAllQ(pcType)
				return This.AreQ(pcType)

			def AreAllQM(pcType)
				return This.AreQM(pcType)

	def AreBothA(pcType)

		if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
			return AFalseObject()
		ok

		item1 = This.Content()[1]
		item2 = This.Content()[2]
		if isList(item2) and Q(item2).IsAndNamedParam()

			item2 = item2[2]
		ok

		This.UpdateWith([ item1, item2 ])

		return This.IsA(pcType)

		#< @FunctionFluentForm

		def AreBothAQ(pcType)

			if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
				return AFalseObject()
			ok
	
			item1 = This.Content()[1]
			item2 = This.Content()[2]
			if isList(item2) and Q(item2).IsAndNamedParam()
	
				item2 = item2[2]
			ok
	
			This.UpdateWith([ item1, item2 ])

			return This.AreQ(pcType)

		#>

		#< @FunctionAlternativeForms

		def AreBothAn(pcType)
			return This.AreBothA(pcType)

			def AreBothAnQ(pcType)
				return This.AreBothAQ(pcType)

		def AreBoth(pcType)
			return This.AreBothA(pcType)

			def AreBothQ(pcType)
				return This.AreBothAQ(pcType)

		def BothAreA(pcType)
			return This.AreBothA(pcType)

			def BothAreAQ(pcType)
				return This.AreBothAQ(pcType)

		def BothAreAn(pcType)
			return This.AreBothA(pcType)

			def BothAreAnQ(pcType)
				return This.AreBothAQ(pcType)

		def BothAre(pcType)
			return This.AreBothA(pcType)

			def BothAreQ(pcType)
				return This.AreBothAQ(pcType)

		#--

		def AreTwo(pcType)
			return AreBothA(pcType)

			def AreTwoQ(pcType)
				return AreBothAQ(pcType)

		#>

	def WhichQ()
		return This

		def WichQM()
			SetMainObject(This)
			return This

		def Which()
			return This

		def ThatQ()
			return This

			def ThatQM()
				SetMainObject(This)
				return This

		def That()
			return This

	def WhichIsQ()
		return This

		def WhichIsQM()
			SetMainObject(This)
			return This

		def WhichIs()
			return This

		def ThatIsQ()
			return This

			def ThisIsQM()
				SetMainObject(This)
				return This

		def ThatIs()
			return This

	def WhichAreQ()
		return This

		def WhichAreQM()
			SetMainObject(This)
			return This

		def WhichAre()
			return This

		def ThatAreQ()
			return This

			def ThatAreQM()
				SetMainObject(This)
				return This

		def ThatAre()
			return This

	def WhichAreBothQ()
		return This

		def WhichAreBothQM()
			SetMainObject(This)
			return This

		#< @AlternativeForms

		def WhichAreBoth()
			return This

		def ThatAreBothQ()
			return This

			def ThatAreBothQM()
				SetMainObject(This)
				return This

		def ThatAreBoth()
			return This

		#--

		def WhichBothAreQ()
			return This

			def WichBothAreQM()
				SetNamedObject(This)
				return This

		def WhichBothAre()
			return This

		def ThatBothAreQ()
			return This

			def ThatBothAreQM()
				SetMainObject(This)
				return This

		def ThatBothAre()
			return This

		#

	def TheirQ()
		return This

		def TheirQM()
			return MainObject()

		#< @FunctionAlternativeForms

		def Their()
			return This

		def AllTheir()
			return This

			def AllTheirQ()
				return This

		def Its()
			return This

		def ItsQ()
			return This

			def ItsQM()
				SetMainObject(This)
				return This

		def His()
			return This

		def HisQ()
			return This

			def HisQM()
				SetMainObject(This)
				return This

		def Her()
			return This

		def HerQ()
			return This

			def HerQM()
				SetMainObject(This)
				return This

		def My()
			return This

		def MyQ()
			return this

			def MyQM()
				SetMainObject(This)
				return This

		def Your()
			return This

		def YourQ()
			return this

			def YourQM()
				SetMainObject(This)
				return This

		#>

	def Me()
		return This.Content()

		def MeQ()
			return This

			def MeQM()
				SetMainObject(This)
				return This

	def Mine()
		return This

		def MineQ()
			return This

			def MinQM()
				SetMainObject(This)
				return This

	def It()
		return This.Content()

		def ItQ()
			return This

			def ItQM()
				SetMainObject(This)
				return This

	def You()
		return This.Content()

		def YouQ()
			return This

			def YouQM()
				SetMainObject(This)
				return This

	def Yours()
		return This

		def YoursQ()
			return This

			def YoursQM()
				SetMainObject(This)
				return This

	def Him()
		return This.Content()

		def HimQ()
			return This

			def HimQM()
				SetMainObject(This)
				return This

	def Them()
		return This.Content()

		def ThemQ()
			return This

			def ThemQM()
				SetMainObject(This)
				return This

	#==
	
	def IsNotA(pcType)
		return NOT This.IsA(pcType)

		#< @FunctioAlternativeForms

		def IsNotAn(pcType)
			return This.IsNotA(pcType)

		def IsNot(pcType)
			return This.IsNotA(pcType)

		def AreNotA(pcType)
			return This.IsNotA(pcType)

		def AreNotAn(pcType)
			return This.IsNotA(pcType)

		def AreNot(pcType)
			return This.IsNotA(pcType)

		#--

		def AreNotBothA(pcType)
			return This.IsNotA(pcType)

		def AreNotBothAn(pcType)
			return This.IsNotA(pcType)

		def AreNotBoth(pcType)
			return This.IsNotA(pcType)

		def AreBothNotA(pcType)
			return This.IsNotA(pcType)

		def AreBothNotAn(pcType)
			return This.IsNotA(pcType)

		def AreBotheNot(pcType)
			return This.IsNotA(pcType)
		#>

	def IsEitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsOrNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT @BothAreStrings(pcType1, pcType2)
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if This.IsA(pcType1) or This.IsA(pcType2)
			return TRUE
		else
			return FALSE
		ok

		#< @functionAlternativeForms

		def IsEitherAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherA(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreBothEitherA(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherBothAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		#>

	def IsNeitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsNorNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT BothAreStrings(pcType1, pcType2)
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if NOT This.IsA(pcType1) and
		   NOT This.IsA(pcType2)

			return TRUE
		else
			return FALSE
		ok

		#< @functionAlternativeForms

		def IsNeitherAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherA(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreBothNeitherA(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherBothAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		#>

	  #-------------------------#
	 #  CHECKING OBJECT VALUE  #
	#-------------------------#

	def IsEither(pValue1, pValue2)
		if isList(pValue2) and Q(pValue2).IsOrNamedParam()
			pValue2 = pValue2[2]
		ok

		if This.IsAString()
			if BothAreStrings(pValue1, pValue2) and
			   ( This.String() = pValue1 or This.String() = pValue2 )

				return TRUE
			ok

		but This.IsANumber()

			if BothAreNumbers(pValue1, pValue2) and
			   ( This.Number() = pValue1 or This.Number() = pValue2 )
				return TRUE
			ok

		but This.IsAList()
			if isList(pValue1) and isList(pValue2) and
			   ( This.ListQ() = pValue1 or This.ListQ() = pValue2 )
				return TRUE
			ok

		but This.IsAnObject() #TODO
			StzRaise("Feature not implemented yet!")
		ok

		#< @FunctionAlternativeForms

		def AreEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		def BothAreEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		def AreBothEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		#>

	#--

	def IsAnObject()
		return TRUE

		def IsAObject()
			return TRUE

	def IsANumber()
		return FALSE

	def IsAString()
		return FALSE

	def IsAList()
		return FALSE
	
	  #======================================#
	 #  REPEATING THE OBJECT VALUE N TIMES  #
	#======================================#

	def Repeat(n)
		return This.RepeatXT(:InList, n)

		#< @FunctionFluentForm

		def RepeatQ(n)
			return This.RepeatXTQ(:InList, n)

		#>

		#< @FunctionAlternativeForms

		def RepeatNTimes(n)
			return This.Repeat(n)

			def RepeatNTimesQ(n)
				return This.RepeatQ(n)

		def Reproduce(n)
			return This.Repeat(n)

			def ReproduceQ(n)
				This.Reproduce(n)
				return This

		def ReproduceNTimes(n)
			return This.Repeat(n)

			def ReproduceNTimesQ(n)
				This.ReproduceNTimes(n)
				return This

		def CopyNTimes(n)
			return This.Repeat(n)

			def CopyNTimesQ(n)
				This.CopyNTimes(n)
				return This

		#>

	#--

	def Repeated(n)
		aResult = This.Copy().RepeatQ(n).Content()
		return aResult

		#< @FunctionAlternativeForms

		def RepeatedNTimes(n)
			return This.Repeated(n)

		def Reproduced(n)
			return This.Repeated(n)

		def ReproducedNTimes(n)
			return This.Repeated(n)

		def Copied(n)
			return This.Repeated(n)

		def CopiedNTimes(n)
			return This.Repeated(n)

		#>

	  #--------------------------------------#
	 #  REPEATING THE OBJECT VALUE 3 TIMES  #
	#--------------------------------------#

	def Repeat3Times()
		This.RepeatNTimes(3)

		#< @FunctionFluentForm

		def Repeat3TimesQ()
			This.Repeat3Times()
			return This

		#>

		#< @FunctionAlternativeForms

		def Reproduce3Times()
			This.Repeat3Times()

			def Reproduce3TimesQ()
				This.Reproduce3Times()
				return This

		def Copy3Times()
			This.Repeat3Times()

			def Copy3TimesQ()
				This.Copy3Times()
				return This

		#>

	def Repeated3Times()
		return This.Copy().Repeat3TimesQ().Content()

		#< @FunctionAlternativeForms

		def Reproduced3Times()
			return This.Repeated3Times()

		def Copied3Times()
			return This.Repeated3Times()

		#>

	  #-------------------------------------------------------------------#
	 #  REPEATING THE OBJECT VALUE IN A GIVEN CONTAINER OF A GIVEN SIZE  #
	#-------------------------------------------------------------------#

	def RepeatNTimesXT(pnSize, pIn)
		return This.RepeatXT(pIn, pnSize)

		def RepeatedNTimesXT(pnSize, pIn)
			return RepeatNTimesXT(pnSize, pIn)
	
	def RepeatXT(pIn, pnSize)
		/* EXAMPLE
		o1 = new stzNumber(5)
		o1.RepeatXT( :InA = :List, :OfSize = 2 )
		#--> [ 5, 5 ]
		*/

		# Resolving params

		if isList(pIn) and
			( Q(pIn).IsInNamedParam() or
			  Q(pIn).IsInANamedParam() )

			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) and
				Q(pIn).IsOneOfTheseCS([
					:String, :List, :Pair, :ListOfNumbers, :ListOfStrings,
					:ListOfLists, :ListOfPairs, :Grid, :Table, :StzTable,

					:AString, :AList, :APair, :AListOfNumbers, :AListOfStrings,
					:AListOfLists, :AListOfPairs, :AGrid, :ATable, :AStzTable,

					:InString, :InList, :InPair, :InListOfNumbers, :InListOfStrings,
					:InListOfLists, :InListOfPairs, :InGrid, :InTable, :InStzTable,

					:InAString, :InAList, :InAPair, :InAListOfNumbers, :InAListOfStrings,
					:InAListOfLists, :InAListOfPairs, :InAGrid, :InATable, :InAStzTable

				], :CS = FALSE) )

			StzRaise("Incorrect param! pIn must be a string representing one of" +
				 "these Softanza types: :String, :List, :Pair, :ListOfNumbers, :ListOfStrings, " +
				 ":ListOfLists, :ListOfPairs, :Grid, :Table, and :StzTable.")
		ok

		if isList(pnSize) and
			( Q(pnSize).IsOfSizeNamedParam() or
			  Q(pnZise).IsSizeNamedParam() )

			pnSize = pnSize[2]
		ok

		if NOT ( isNumber(pnSize) or (isList(pnSize) and Q(pnSize).IsPairOfNumbers()) )
			StzRaise("Incorrect param type! pnSize must be a number.")
		ok

		# Doing the job

		value = ""
		if This.IsANumber()
			if This.IsInteger()
				value = This.NumericValue()
			else
				value = This.StringValue()
			ok
		else
			value = This.Content()
		ok

		if Q(pIn).IsOneOfThese([ :List, :InList, :AList, :InAList ])
	
			aResult = []
			for i = 1 to pnSize
				aResult + value
			next
			return aResult

		but Q(pIn).IsOneOfThese([ :Pair, :InPair, :APair, :InAPair ])

			aResult = []
			for i = 1 to 2
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
				aResult + Q(value).Stringified()
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

		but Q(pIn).IsOneOfThese([ :StzTable, :InStzTable, :InAStzTable ])

			oResult = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(value)
			return oResult

		else
			StzRaise("Unsupported type of container! Allowed containers you can repeat " +
				 "the value in are: :List, :Pair, :ListOfLists, :ListOfPairs, :String, :Grid, :Table, and :StzTable.")
		ok

		#< @FunctionFluentForm

		def RepeatXTQ(pIn, pnSize)
			if isString(pIn) and pIn = :String
				return new stzString( This.RepeatXT(pIn, pnSize) )

			else
				return new stzList( This.RepeatXT(pIn, pnSize) )
			ok

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

	  #==========================================#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER  #
	#==========================================#

	def ToNumber()
		if This.IsANumber()
			return This.NumericValue()

		but This.IsAString()
			return  0+ This.Content()

		but This.IsAList()
			return This.NumberOfItems()

		else
			StzRaise("Can't cast the object into a number.")
		ok

	  #------------------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER -- EXTENDED  #
	#------------------------------------------------------#

	def ToNumberW(pcCode)

		if isList(pcCode) and Q(pcCode).IsUsingNamedParam()
			pcCode = pcCode[2]
		ok

		if NOT isString(pcCode)
			StzRaise("Incorrect param type! pcCode must be a string.")
		ok

		@number = 0
		if This.IsANumber()
			@number = This.Number()
		ok
		
		cCode = Q(pcCode).
			RemoveTheseBoundsQ('"').
			RemoveThisFirstCharQ("{").
			RemoveThisLastCharQ("}").
			Trimmed()
		
		if NOT Q(cCode).StartsWithOneOfTheseCS([
			"@number =", "@number +=", "@number=", "@number+=" ],
			:CaseSensitive = FALSE )

			StzRaise("Syntax error! pcCode must start with '@number =' or '@number +='.")
		ok

		if Q(cCode).StartsWithEitherCS( "@number=", :Or = "@number =", :CS = FALSE )
			# EXAMPLE
			# ? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }')
			#--> 3

			@list = This.Content()
			@string = This.Content()

			eval(cCode)

		else
			# CASE += is used on a list of items or a string

			# EXAMPLE
			# ? Q([ "Me", "and", "You!" ]).ToNumberXTW('{ @number += len(@item) }')
			#--> 9
			@number = 0

			if This.IsANumber()
				eval(cCode)

			but This.IsAString()
				nLenStr = This.NumberOfChars()
				for @i = 1 to nLenStr
					@char = This.Char(@i)
					eval(cCode)
				next

			but This.IsAList()
				aList = This.List()
				nLenList = len(aList)

				for @i = 1 to nLenList 
					@item = This.Item(@i)
					eval(cCode)
				next
			ok

		ok

		if NOT isNumber(@number)
			StzRaise("Incorrect type! @number must be a number.")
		ok

		return @number

		def ToNumberWQ(pcCode)
			return new stzNumber( This.ToNumberW(pcCode) )

		def ToNumberXT(pcCode)
			return This.ToNumberW(pcCode)

			def ToNumberXTQ(pcCode)
				return new stzNumber( This.ToNumberXT(pcCode) )

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
			StzRaise("Can't cast the object into a number.")
		ok

	  #------------------------------#
	 #     OPERATORS OVERLOADING    #
	#------------------------------#

	/*
		TODO: Operators should adopt same semantics in all classes...
	*/

	def operator(pcOp, pValue)
		
		if pcOp = "="
			return This.IsEqualTo(pValue)
		ok

	  #============================================================#
	 #   FINDING THE FIRST N OCCURRENCES OF A SUBSTRING Or ITEM   #
	#============================================================#

	# TODO: This part is an experimentation of abastraction common features
	# between stzString and stzList in one place, here in stzObject

	# NOTE: I'm not yet decided if this should be generalised. Think about it.

	def FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		anResult = This.FindFirstNOccurrencesSCS(n, pStrOrItem, 1, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def PositionsOfNFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FirstNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NFirstCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FindFirstNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def FindNFirstCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrences(n, pStrOrItem)
		return This.FindFirstNOccurrencesCS(n, pStrOrItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def PositionsOfFirstNOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def PositionsOfNFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FirstN(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def NFirst(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FindFirstN(n, pStrOrItem)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem)

		def FindNFirst(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FirstNOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def NFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#>

	   #--------------------------------------------------------#
	  #  FINDING FIRST N OCCURRENCES OF A SUBSTRING OR ITEM    #
	 #  STARTING AT A GIVEN POSITION -- EXTENDTED             #
	#--------------------------------------------------------#

	def FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		if isList(pStrOrItem) and
		   Q(pStrOrItem).IsOneOfTheseNamedParams([ :Of, :OfSubString, :OfItem ])

			pStrOrItem = pStrOrItem[2]
		ok

		if isList(pnStartingAt) and Q(pnstartingAt).IsStartingAtNamedParam()
			pnStartingAt = pnStartingAt[2]
		ok

		anPos = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		anResult = []
		if len(anPos) > 0
			anResult = Q(anPos).FirstNItemsQR(n, :stzListOfNumbers).AddedToEach(pnStartingAt-1)
		ok

		return anResult

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNFirstOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pnStartingAt, pCaseSensitive)

		def NFirstSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindFirstNSCS(n, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNFirstSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NFirstOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrencesS(n, pcStr, pnStartingAt)
		return This.FindFirstNOccurrencesSCS(n, pcStr, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		def PositionsOfNFirstOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#--

		def FirstNS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		def NFirstS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesCSS(n, pStrOrItem, pnStartingAt)

		#--

		def FindFirstNS(n, pStrOrItem,pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		def FindNFirstS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#--

		def FirstNOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		def NFirstOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#>

	  #---------------------------------------------------#
	 #   FINDING THE LAST N OCCURRENCES OF A SUBSTRING   #
	#---------------------------------------------------#

	def FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		anResult = This.FindLastNOccurrencesSCS(n, pStrOrItem, :StartingAT = 1, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def PositionsOfNLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def LastNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NLastCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FindLastNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def FindNLastCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def LastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrences(n, pStrOrItem)
		return This.FindLastNOccurrencesCS(n, pStrOrItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def PositionsOfLastNOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def PositionsOfNLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def LastN(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def NLast(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def FindLastN(n, pStrOrItem)
			return This.FindLastNOccurrencesCS(n, pStrOrItem)

		def FindNLast(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def LastNOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def NLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#>

	   #------------------------------------------------------------#
	  #  FINDING LAST N OCCURRENCES OF A SUBSTRING/ITEM STARTING   #
	 #  AT A GIVEN POSITION -- EXTENDTED                          #
	#------------------------------------------------------------#

	def FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
		if CheckParams()
			if isList(pStrOrItem) and
			   Q(pStrOrItem).IsOneOfTheseNamedParams([ :Of, :OfSubString ])
	
				pStrOrItem = pStrOrItem[2]
			ok
	
			if isList(pnStartingAt) and Q(pnstartingAt).IsStartingAtNamedParam()
				pnStartingAt = pnStartingAt[2]
			ok
		ok

		anPos = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		anResult = Q(anPos).LastNItemsQR(n, :stzListOfNumbers).AddedToEach(pnStartingAt-1)

		return anResult

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNLastOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pnStartingAt, pCaseSensitive)

		def NLastSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindLastNSCS(n, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNLastSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NLastOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrencesS(n, pcStr, pnStartingAt)
		return This.FindLastNOccurrencesSCS(n, pcStr, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfLastNOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt)

		def PositionsOfNLastOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt)

		#--

		def LastNS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		def NLastS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		#--

		def FindLastSN(n, pStrOrItem,pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		def FindNLastS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		#--

		def LastNOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		def NLastOccurrencesS(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesS(n, pStrOrItem, pnStartingAt, pnStartingAt)

		#>

	  #===========#
	 #   MISC.   #
	#===========#

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

	def ToPointer()
		return object2pointer(This.Object())

	def Stringified()
		return This.Name()
		

	def IfQ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type!")
		ok

		cCode = 'bOk = (' + pcCondition + ')'
		eval(ccode)

		if bOk
			return This
		else
			# An error message is returned:
			#--> Error (R13) : Object is required 
		ok

	def IsSingle()
		if This.IsAList() and This.Size() = 1
			return TRUE
		else
			return FALSE
		ok

	def AndThen()
		return This

		def AndThenQ()
			return This

		def AndQ()
			return This

	def QM()
		return MainObject() # Used in chains of truth

		def AndQM()
			return MainObject() # Used in chains of truth

	def Having()
		return This

		def HavingQ()
			return This

			def HavingQM()
				SetMainObject(This)
				return This.HavingQ()

		def AndHaving()
			return This

		def AndHavingQ()
			return This

			def AndHavingQM()
				SetMainObject(This)
				return This.AndHavingQ()

	
	# Swapping the content of the stzObject with an other stzObject

	def SwapWith(pOtherStzObject)

		if CheckParams()

			if NOT @IsStzObject(pOtherStzObject)
				StzRaise("Incorrect param type! pOtherStzObject must be a stzObject.")
			ok
	
		ok

		oThis = This.Content()
		oOther = pOtherStzObject.Content()

		This.UpdateWith(oOther)
		pOtherStzObject.UpdateWith(oThis)

		def SwapWithQ(pOtherStzObject)
			This.SwapWith(pOtherStzObject)
			return This

		def SwapContentWith(pOtherStzObject)
			This.SwapWith(pOtherStzObject)

			def SwapContentWithQ(pOtherStzObject)
				return This.SwapWithQ(pOtherStzObject)

	def @IsNeither(pcType1, pcType2)
		if CheckParams()
			if isList(pcType1) and Q(pcType1).IsOfTypeNamedParam()
				pcType1 = pcType1[2]
			ok

			if isList(pcType2) and Q(pcType2).IsNorNamedParam()
				pcType2 = pcType2[2]
			ok

			if NOT @BothAreStrings(pcType1, pcType2)
				StzRaise("Incorrect param type! pcType1 and pcType2 must both be strings.")
			ok
		ok

		#TODO: Add other Stz types

		bOfType1 = FALSE
		bOfType2 = FALSE

		if pcType1 = :String or pcType1 = :AString
			bOfTyep1 = This.IsStzString()

		but pcType1 = :Char or pcType1 = :AChar
			bOfType1 = This.IsStzChar()

		but pcType1 = :Number or pcType1 = :ANumber
			bOfType1 = This.IsStzNumber()

		but pcType1 = :List or pcType1 = :AList
			bOfType1 = This.IsStzList()

		but pcType1 = :Object or pcType1 = :AnObject
			bOfType1 = This.IsStzObject()
		ok

		if pcType2 = :String or pcType2 = :AString
			bOfType2 = This.IsStzString()

		but pcType2 = :Char or pcType2 = :AChar
			bOfType2 = This.IsStzChar()

		but pcType2 = :Number or pcType2 = :ANumber
			bOfType2 = This.IsStzNumber()

		but pcType2 = :List or pcType2 = :AList
			bOfType2 = This.IsStzList()

		but pcType2 = :Object or pcType2 = :AnObject
			bOfType2 = This.IsStzObject()
		ok

		if NOT bOfType1 and NOT bOfType2
			return TRUE
		else
			return FALSE
		ok

		def @IsNeitheOfType(pcType1, pcType2)
			return This.IsNeither(pcType1, pcType2)

	#==

	def ToStzChar()
		return new stzChar(This.Content())

	def ToStzString()
		return new stzString(This.Content())

	def ToStzNumber()
		return new stzNumber(This.Content())

	def ToStzList()
		return new stzList(This.Content())

