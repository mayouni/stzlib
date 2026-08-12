#----------------------------------------------------------#
#  GLOBAL REACTIVE CONSTANTS - Expressive parameter values #
#----------------------------------------------------------#

DEFAULT_MODE = ""
DEFAULT = ""

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
STREAM_UDP = "udp"
STREAM_TCP = "tcp"
STREAM_SIGNAL = "signal"
STREAM_WORKER = "worker"
STREAM_DNS = "dns"
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

OPTIMISED_FOR_LIBUV_MESSAGES = "libuv" 
OPTIMISED_FOR_TIMER_SOURCE = "timer"
OPTIMISED_FOR_FILE_SOURCE = "file"
OPTIMISED_FOR_NETWORK_SOURCE = "network"
OPTIMISED_FOR_SENSOR_SOURCE = "sensor"

OPTIMIzED_FOR_LIBUV_MESSAGES = "libuv" 
OPTIMIzED_FOR_TIMER_SOURCE = "timer"
OPTIMIzED_FOR_FILE_SOURCE = "file"
OPTIMIzED_FOR_NETWORK_SOURCE = "network"
OPTIMIzED_FOR_SENSOR_SOURCE = "sensor"

# Stream States (unified naming)
STREAM_ACTIVE = 1
STREAM_INACTIVE = 0

STREAM_COMPLETED = "completed"
STREAM_CONCLUDED = "completed"

STREAM_ERROR = "error"

# Alternative stream state names  
STREAM_STATE_INACTIVE = 0
STREAM_STATE_ACTIVE = 1

STREAM_STATE_COMPLETED = 1
STREAM_STATE_CONCLUDED = 1

STREAM_STATE_RUNNING = 0

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
BUFFER_EXPAND = "buffer"
BUFFER_REJECT_NEWEST = "drop" 
BUFFER_EVICT_OLDEST = "latest"
BUFFER_BLOCK = "block"

# Stream processing
STREAM_ATTR_CHANGES = "attribute_changes"
STREAM_ALL_CHANGES = "all"
STREAM_DISTINCT_CHANGES = "distinct"


#-------------------#
#  ENGINE CONSTANTS #
#-------------------#

# Engine States
ENGINE_STOPPED = 0
ENGINE_RUNNING = 1
ENGINE_STARTING = "starting"
ENGINE_STOPPING = "stopping"

#---------------------#
#  REACTIVE CONSTANTS #
#---------------------#

# Reactive modes
REACTIVE_ON = 1
REACTIVE_OFF = 0
BATCH_MODE_ON = 1
BATCH_MODE_OFF = 0

# Watch/Binding behavior
WATCH_IMMEDIATE = 1
WATCH_DEBOUNCED = 0
WATCH_ALL_CHANGES = 1
WATCH_DISTINCT_ONLY = 0

# Binding types (BINDING_* variants)
BINDING_ONE_WAY = "oneway"
BINDING_TWO_WAY = "twoway"
BINDING_AUTO_SYNC = 1
BINDING_MANUAL_SYNC = 0

# Binding types (BIND_* variants)
BIND_ONE_WAY = "oneway"
BIND_TWO_WAY = "twoway"
BIND_AUTO_SYNC = 1
BIND_MANUAL_SYNC = 0
BIND_IMMEDIATE = 1
BIND_DEFERRED = 0

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
CHANGE_DETECTED = 1
CHANGE_NONE = 0
CHANGE_TYPE_VALUE = "value"
CHANGE_TYPE_COMPUTED = "computed"
CHANGE_TYPE_BOUND = "bound"

# Batch processing
BATCH_IMMEDIATE = "immediate"
BATCH_DEFERRED = "deferred"
BATCH_AUTO_FLUSH = 1
BATCH_MANUAL_FLUSH = 0

#--------------------#
#  ASYNC CONSTANTS   #
#--------------------#

# Async states
ASYNC_SUCCESS = "success"
ASYNC_ERROR = "error"
ASYNC_PENDING = "pending"

ASYNC_COMPLETED = "completed"
ASYNC_CONCLUDED = "completed"

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

# Default error messages -- the FALLBACK only. Both stzReactiveFunc and
# stzReactiveTask report CatchError(), Ring's real reason, and reach for these
# just when it comes back empty. stzReactiveTask used to send the fixed sentence
# for every failure there is, which is how a class whose every path was broken
# still looked like it was merely failing.
DEFAULT_ERROR_MSG = "Function execution failed"
DEFAULT_TASK_ERROR_MSG = "Task execution failed"
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

# Refusals a reactive function call can report. The param switch used to end
# in an `other` arm that called the function with NO arguments, so passing
# eleven surfaced as R19 "Calling function with LESS number of parameters" --
# the opposite of what the caller had done.
FUNC_ERROR_PARAMS_NOT_LIST = "Reactive call params must be a list"
FUNC_ERROR_TOO_MANY_PARAMS = "Reactive call has too many params:"

#---------------------------#
#  REACTIVE OBJECT CONSTANTS #
#---------------------------#

# Object modes
OBJECT_STANDALONE = ""        # For objects created from scratch
OBJECT_WRAPPER = "wrapper"      # For wrapping existing objects

# Refusals the configuration surface can report. Each used to be a raise from
# somewhere else entirely -- a watcher that failed on the next change, a
# "Bad parameter type!" out of find() on an unrelated set, an R14 from inside
# BindTo -- rather than a refusal naming the call that was wrong.
WATCH_ERROR_NOT_A_FUNCTION    = "Watch callback is not a function"
COMPUTED_ERROR_NOT_A_FUNCTION = "Computed computer is not a function"
COMPUTED_ERROR_DEPS_NOT_LIST  = "Computed dependencies must be a list"
BIND_ERROR_TARGET_NOT_OBJECT  = "Bind target must be a reactive object"

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
HTTP_RESPONSE_NULL = ""

# HTTP Errors
HTTP_ERROR_REQUEST_FAILED = "HTTP request failed"
# A verb the request path cannot issue. It used to become a silent GET.
HTTP_ERROR_UNKNOWN_METHOD = "HTTP method not supported:"

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

#-----------------#
#  UDP CONSTANTS  #
#-----------------#

UDP_REUSE_ADDR_ON = 1
UDP_REUSE_ADDR_OFF = 0
UDP_BROADCAST_ON = 1
UDP_BROADCAST_OFF = 0
UDP_MULTICAST_TTL_DEFAULT = 1
UDP_MULTICAST_LOOP_ON = 1
UDP_MULTICAST_LOOP_OFF = 0

#-----------------#
#  TCP CONSTANTS  #
#-----------------#

TCP_DEFAULT_BACKLOG = 128
TCP_DEFAULT_TIMEOUT = 30000  # 30 seconds
TCP_CONNECTED = :connected
TCP_DATA = :data
TCP_CLIENT_CONNECTED = :client_connected
TCP_CLIENT_MODE = :client
TCP_SERVER_MODE = :server

#-----------------#
#  SIGNAL VALUES  #
#-----------------#

SIGNAL_INT = 2   # SIGINT
SIGNAL_TERM = 15 # SIGTERM
SIGNAL_USR1 = 30 # SIGUSR1
SIGNAL_USR2 = 31 # SIGUSR2
SIGNAL_ONCE = :once
SIGNAL_CONTINUOUS = :continuous

# Worker Constants
WORKER_DEFAULT_POOL_SIZE = 4

# DNS Constants
DNS_RESOLVE_A = "A"
DNS_RESOLVE_AAAA = "AAAA"
DNS_RESOLVE_PTR = "PTR"



#--------------------#
#  DEFAULT VALUES    #
#--------------------#

# Stream defaults
DEFAULT_STREAM_SOURCE = STREAM_MANUAL
DEFAULT_TIMER_DELAY = MEDIUM_DELAY
DEFAULT_TIMER_CHECK = CHECK_NORMAL
# PATIENCE_NONE mirrors libuv's uv_run: return as soon as there are no
# active handles (timers). In Ring's synchronous setup model every timer
# is registered before RunLoop() and new ones only appear from inside a
# timer callback (checked in the same iteration), so there is nothing to
# "wait for" once the timer list is empty. The old PATIENCE_NORMAL (50)
# idled 50 x 10ms = 500ms after all work completed -- the bulk of the
# reactive perf regression vs the old Ring-libuv backend.
DEFAULT_PATIENCE = PATIENCE_NONE

# Reactive defaults  
DEFAULT_REACTIVE_MODE = REACTIVE_ON
DEFAULT_BATCH_MODE = BATCH_MODE_OFF
DEFAULT_ERROR_HANDLING = ERROR_LOG
DEFAULT_ASYNC_MODE = PROCESS_ASYNC
DEFAULT_BINDING_MODE = BINDING_ONE_WAY
DEFAULT_WATCH_MODE = WATCH_IMMEDIATE
DEFAULT_SYNC_MODE = BINDING_AUTO_SYNC

#--------------------------------------------------------------#
#  DETACHED TIMER TABLE (F5, 2026-07-14)                       #
#--------------------------------------------------------------#
# Ring copies objects on EVERY store (assignment, attribute, list
# append) -- only method params and index-calls into a list reach the
# live instance. A reactive OBJECT therefore cannot register a timer
# on "its" system through a stored engine reference (the reference is
# a dead snapshot). The Ring-true cure: one GLOBAL timer table,
# reached by NAME from anywhere, mutated through the index. Every
# running RunLoop drives it alongside its own timers.

# Table records: [ cId, nDueMs, fCallback, aArgs ] -- plain values, no
# timer objects (so no copy-vs-live ambiguity at all). Ring lambdas do
# NOT capture enclosing locals, so aArgs carries the values the
# callback needs at fire time (up to 3, matched by arity).

$aReaxisDetachedTimers = []
$nReaxisDetachedSeq = 0

# Register a detached one-shot timer; returns its id string.
# The failure text an HTTP callback receives. ONE definition for both request
# paths -- the reactor drain and the blocking task -- so the wording cannot
# drift between them. The STATUS is added when one is known; a refused
# connection has none, and none is invented.
func StzHttpFailureText(pnStatus)
	if isNumber(pnStatus) and pnStatus > 0
		return HTTP_ERROR_REQUEST_FAILED + " (status " + pnStatus + ")"
	ok
	return HTTP_ERROR_REQUEST_FAILED

func StzReaxisRunAfter(nDelayMs, fCallback)
	return StzReaxisRunAfterXT(nDelayMs, fCallback, [])

func StzReaxisRunAfterXT(nDelayMs, fCallback, paArgs)
	$nReaxisDetachedSeq++
	_cId_ = "detached_" + $nReaxisDetachedSeq
	$aReaxisDetachedTimers + [ _cId_, StzEngineTimeNowMs() + nDelayMs, fCallback, paArgs ]
	return _cId_

# Stop + remove a detached timer by id (no-op when already gone).
func StzReaxisStopTimer(cId)
	for _i_ = len($aReaxisDetachedTimers) to 1 step -1
		if $aReaxisDetachedTimers[_i_][1] = cId
			del($aReaxisDetachedTimers, _i_)
			exit
		ok
	next

# Fire every due detached timer (called by each RunLoop iteration).
# Returns the number still pending.
func StzReaxisTickDetached()
	_nNow_ = StzEngineTimeNowMs()
	for _i_ = len($aReaxisDetachedTimers) to 1 step -1
		if _nNow_ >= $aReaxisDetachedTimers[_i_][2]
			_f_ = $aReaxisDetachedTimers[_i_][3]
			_aArgs_ = $aReaxisDetachedTimers[_i_][4]
			del($aReaxisDetachedTimers, _i_)
			if islist(_aArgs_) and len(_aArgs_) = 3
				call _f_(_aArgs_[1], _aArgs_[2], _aArgs_[3])
			but islist(_aArgs_) and len(_aArgs_) = 2
				call _f_(_aArgs_[1], _aArgs_[2])
			but islist(_aArgs_) and len(_aArgs_) = 1
				call _f_(_aArgs_[1])
			else
				call _f_()
			ok
		ok
	next
	return len($aReaxisDetachedTimers)
