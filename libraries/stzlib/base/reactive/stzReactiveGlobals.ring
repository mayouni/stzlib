#----------------------------------------------------------#
#  GLOBAL REACTIVE CONSTANTS - Expressive parameter values #
#----------------------------------------------------------#

#--------------------#
#  TIMING CONSTANTS  #
#--------------------#

# Basic time units
MILLISECOND = 1
SECOND = 1000
MINUTE = 60000
HOUR = 3600000

# Expressive delays
IMMEDIATE = 0
VERY_SHORT = 100
SHORT_DELAY = 500
MEDIUM_DELAY = 1000
LONG_DELAY = 3000
ONE_SECOND = 1000

# Timer specific constants
TIMER_IMMEDIATE_START = 0
TIMER_NO_DELAY = 0
TIMER_DEFAULT_DELAY = 0

# Timer check frequency
CHECK_VERY_FAST = 1      # 1ms - high precision timing
CHECK_FAST = 5           # 5ms - responsive UI updates  
CHECK_NORMAL = 10        # 10ms - standard responsive timing
CHECK_SLOW = 50          # 50ms - background tasks
CHECK_VERY_SLOW = 100    # 100ms - low priority monitoring

# Timer precision
PRECISION_HIGH = 1       # 1ms precision
PRECISION_NORMAL = 10    # 10ms precision  
PRECISION_LOW = 50       # 50ms precision

# Empty loop patience
PATIENCE_NONE = 0        # Exit immediately when no timers
PATIENCE_SHORT = 10      # Wait 0.1 seconds for new timers
PATIENCE_NORMAL = 50     # Wait 0.5 seconds for new timers  
PATIENCE_LONG = 100      # Wait 1 second for new timers

# Clock conversion
MS_PER_SECOND = 1000
CLOCKS_TO_MS_MULTIPLIER = MS_PER_SECOND

#-----------------#
#  TASK CONSTANTS #
#-----------------#

# Task Status
TASK_PENDING = "pending"
TASK_RUNNING = "running"
TASK_COMPLETED = "completed"
TASK_ERROR = "error"
TASK_CANCELLED = "cancelled"

# HTTP Tasks
HTTP_TASK_GET = "http_get"
HTTP_TASK_POST = "http_post"
HTTP_TASK_PUT = "http_put"
HTTP_TASK_DELETE = "http_delete"

#-------------------#
#  STREAM CONSTANTS #
#-------------------#

# Stream Source Types (unified naming)
STREAM_MANUAL = "manual"
STREAM_AUTO = "auto"
STREAM_EVENT = "event"
STREAM_TIMER = "timer"
STREAM_HTTP = "http"
STREAM_FILE = "file"
STREAM_LIBUV = "libuv"
STREAM_NETWORK = "network"
STREAM_SENSOR = "sensor"

# Alternative stream source names
STREAM_SOURCE_MANUAL = "manual"
STREAM_SOURCE_LIBUV = "libuv" 
STREAM_SOURCE_TIMER = "timer"
STREAM_SOURCE_FILE = "file"
STREAM_SOURCE_NETWORK = "network"
STREAM_SOURCE_SENSOR = "sensor"

# Stream States (unified naming)
STREAM_ACTIVE = true
STREAM_INACTIVE = false
STREAM_COMPLETED = "completed"
STREAM_ERROR = "error"

# Alternative stream state names  
STREAM_STATE_INACTIVE = false
STREAM_STATE_ACTIVE = true
STREAM_STATE_COMPLETED = true
STREAM_STATE_RUNNING = false

# Transform operations
TRANSFORM_MAP = :map
TRANSFORM_FILTER = :filter
TRANSFORM_REDUCE = :reduce
TRANSFORM_DEBOUNCE = :debounce
TRANSFORM_THROTTLE = :throttle
TRANSFORM_DISTINCT = :distinct

# Stream events
EVENT_DATA = :data
EVENT_ERROR = :error
EVENT_COMPLETE = :complete
EVENT_START = :start
EVENT_STOP = :stop

# Buffer strategies
BUFFER_STRATEGY_UNLIMITED = -1
BUFFER_STRATEGY_DROP_OLDEST = :drop_oldest
BUFFER_STRATEGY_DROP_NEWEST = :drop_newest
BUFFER_STRATEGY_BLOCK = :block

# Stream processing
STREAM_ATTR_CHANGES = "attribute_changes"
STREAM_ALL_CHANGES = "all"
STREAM_DISTINCT_CHANGES = "distinct"

#-------------------#
#  ENGINE CONSTANTS #
#-------------------#

# Engine States
ENGINE_STOPPED = false
ENGINE_RUNNING = true
ENGINE_STARTING = "starting"
ENGINE_STOPPING = "stopping"

#---------------------#
#  REACTIVE CONSTANTS #
#---------------------#

# Reactive modes
REACTIVE_ON = true
REACTIVE_OFF = false
BATCH_MODE_ON = true
BATCH_MODE_OFF = false

# Watch/Binding behavior
WATCH_IMMEDIATE = true
WATCH_DEBOUNCED = false
WATCH_ALL_CHANGES = true
WATCH_DISTINCT_ONLY = false

# Binding types (BINDING_* variants)
BINDING_ONE_WAY = "oneway"
BINDING_TWO_WAY = "twoway"
BINDING_AUTO_SYNC = true
BINDING_MANUAL_SYNC = false

# Binding types (BIND_* variants)
BIND_ONE_WAY = "oneway"
BIND_TWO_WAY = "twoway"
BIND_AUTO_SYNC = true
BIND_MANUAL_SYNC = false
BIND_IMMEDIATE = true
BIND_DEFERRED = false

# Attribute operations
ATTR_GET = "get"
ATTR_SET = "set"
ATTR_COMPUTED = "computed"
ATTR_WATCHED = "watched"
ATTR_BOUND = "bound"

# Change types
CHANGE_SET = "set"
CHANGE_COMPUTED = "computed"
CHANGE_BOUND = "bound"
CHANGE_ASYNC = "async"
CHANGE_DETECTED = true
CHANGE_NONE = false
CHANGE_TYPE_VALUE = "value"
CHANGE_TYPE_COMPUTED = "computed"
CHANGE_TYPE_BOUND = "bound"

# Batch processing
BATCH_IMMEDIATE = "immediate"
BATCH_DEFERRED = "deferred"
BATCH_AUTO_FLUSH = true
BATCH_MANUAL_FLUSH = false

#--------------------#
#  ASYNC CONSTANTS   #
#--------------------#

# Async states
ASYNC_SUCCESS = "success"
ASYNC_ERROR = "error"
ASYNC_PENDING = "pending"
ASYNC_COMPLETED = "completed"
ASYNC_TIMEOUT = "timeout"

# Processing modes
PROCESS_SYNC = "sync"
PROCESS_ASYNC = "async"
EMIT_IMMEDIATE = 0
EMIT_DEBOUNCED = "debounced"
EMIT_THROTTLED = "throttled"

#----------------------#
#  ERROR CONSTANTS     #
#----------------------#

# Error handling modes
ERROR_IGNORE = "ignore"
ERROR_LOG = "log"
ERROR_THROW = "throw"
ERROR_CALLBACK = "callback"
ERROR_DEFAULT = ERROR_LOG

# Default error messages
DEFAULT_ERROR_MSG = "Function execution failed"
EMPTY_ERROR_MSG = ""

#--------------------------#
#  FUNCTION CALL CONSTANTS #
#--------------------------#

# Function call types
FUNC_CALL_SYNC = "func_call"
FUNC_CALL_ASYNC = "func_call_async"
FUNC_CALL_CHUNKED = "func_call_chunked"

# Parameter limits
MAX_FUNCTION_PARAMS = 10
NO_PARAMS = 0

#---------------------------#
#  REACTIVE OBJECT CONSTANTS #
#---------------------------#

# Object modes
OBJECT_STANDALONE = NULL        # For objects created from scratch
OBJECT_WRAPPER = "wrapper"      # For wrapping existing objects

#-----------------#
#  HTTP CONSTANTS #
#-----------------#

# HTTP Methods
HTTP_GET = "GET"
HTTP_POST = "POST"
HTTP_PUT = "PUT"
HTTP_DELETE = "DELETE"
HTTP_PATCH = "PATCH"
HTTP_HEAD = "HEAD"
HTTP_OPTIONS = "OPTIONS"

# HTTP Status ranges
HTTP_SUCCESS_MIN = 200
HTTP_SUCCESS_MAX = 299
HTTP_REDIRECT_MIN = 300
HTTP_REDIRECT_MAX = 399
HTTP_CLIENT_ERROR_MIN = 400
HTTP_CLIENT_ERROR_MAX = 499
HTTP_SERVER_ERROR_MIN = 500
HTTP_SERVER_ERROR_MAX = 599

# HTTP Headers
CONTENT_TYPE_JSON = "application/json"
CONTENT_TYPE_FORM = "application/x-www-form-urlencoded"
CONTENT_TYPE_TEXT = "text/plain"
USER_AGENT_REACTIVE = "stzReactive/1.0"

# HTTP Responses
HTTP_RESPONSE_EMPTY = ""
HTTP_RESPONSE_NULL = NULL

# HTTP Errors
HTTP_ERROR_REQUEST_FAILED = "HTTP request failed"
HTTP_ERROR_CURL_INIT_FAILED = "Failed to initialize HTTP client"
HTTP_ERROR_INVALID_RESPONSE = "Invalid HTTP response"

# CURL timeouts
CURL_TIMEOUT_DEFAULT = 30
CURL_CONNECT_TIMEOUT_DEFAULT = 10

#-----------------#
#  FILE CONSTANTS #
#-----------------#

# File modes
FILE_READ_ONLY = "r"
FILE_WRITE_ONLY = "w"
FILE_APPEND = "a"
FILE_READ_WRITE = "rw"

# File permissions (readable names for octal values)
FILE_PERMISSIONS = [
    :READ_ONLY = 292,           # 0444
    :WRITE_ONLY = 146,          # 0222  
    :READ_WRITE = 438,          # 0666
    :EXECUTE_ONLY = 73,         # 0111
    :READ_EXECUTE = 365,        # 0555
    :WRITE_EXECUTE = 219,       # 0333
    :FULL_ACCESS = 511,         # 0777
    :USER_READ_WRITE = 384,     # 0600
    :USER_FULL = 448,           # 0700
    :DEFAULT_FILE = 420,        # 0644
    :DEFAULT_DIR = 493          # 0755
]

# File access modes
ACCESS_MODES = [
    :EXISTS = 0,        # F_OK - file exists
    :READABLE = 4,      # R_OK - readable
    :WRITABLE = 2,      # W_OK - writable  
    :EXECUTABLE = 1,    # X_OK - executable
    :READ_WRITE = 6,    # R_OK | W_OK
    :READ_EXECUTE = 5,  # R_OK | X_OK
    :WRITE_EXECUTE = 3, # W_OK | X_OK
    :ALL_ACCESS = 7     # R_OK | W_OK | X_OK
]

# File open flags
OPEN_FLAGS = [
    :READ_ONLY = 0,
    :WRITE_ONLY = 1,
    :READ_WRITE = 2,
    :CREATE = 64,
    :EXCLUSIVE = 128,
    :TRUNCATE = 512,
    :APPEND = 1024,
    :CREATE_NEW = 192,          # CREATE | EXCLUSIVE
    :WRITE_CREATE = 65,         # WRITE_ONLY | CREATE
    :APPEND_CREATE = 1088       # APPEND | CREATE
]

# Symlink flags
SYMLINK_FLAGS = [
    :DEFAULT = 0,
    :DIR = 1,           # Windows: create directory symlink
    :JUNCTION = 2       # Windows: create junction point
]

# File types
FILE_TYPES = [
    :REGULAR = "file",
    :DIRECTORY = "directory", 
    :SYMLINK = "symlink",
    :BLOCK_DEVICE = "block",
    :CHAR_DEVICE = "char",
    :FIFO = "fifo",
    :SOCKET = "socket",
    :UNKNOWN = "unknown"
]

# Watch events
WATCH_EVENTS = [
    :CHANGE = "change",
    :RENAME = "rename",
    :CREATE = "create",
    :DELETE = "delete",
    :MODIFY = "modify"
]

# Polling intervals
POLL_INTERVALS = [
    :FAST = 100,        # 100ms - very responsive
    :NORMAL = 500,      # 500ms - balanced
    :SLOW = 1000,       # 1s - conservative
    :VERY_SLOW = 5000   # 5s - minimal resource usage
]

#--------------------#
#  DEFAULT VALUES    #
#--------------------#

# Stream defaults
DEFAULT_STREAM_SOURCE = STREAM_MANUAL
DEFAULT_TIMER_DELAY = MEDIUM_DELAY
DEFAULT_TIMER_CHECK = CHECK_NORMAL
DEFAULT_PATIENCE = PATIENCE_NORMAL

# Reactive defaults  
DEFAULT_REACTIVE_MODE = REACTIVE_ON
DEFAULT_BATCH_MODE = BATCH_MODE_OFF
DEFAULT_ERROR_HANDLING = ERROR_LOG
DEFAULT_ASYNC_MODE = PROCESS_ASYNC
DEFAULT_BINDING_MODE = BINDING_ONE_WAY
DEFAULT_WATCH_MODE = WATCH_IMMEDIATE
DEFAULT_SYNC_MODE = BINDING_AUTO_SYNC
