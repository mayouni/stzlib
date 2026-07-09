#----------------------------------------------------------#
#  GLOBAL REACTIVE CONSTANTS - Expressive parameter values #
#----------------------------------------------------------#

_DEFAULT_MODE_ = ""
_DEFAULT_ = ""

#--------------------#
#  TIMING CONSTANTS  #
#--------------------#

# Basic time units
_MILLISECOND_ = 1
_SECOND_ = 1000
_MINUTE_ = 60000
_HOUR_ = 3600000

# Expressive delays
_IMMEDIATE_ = 0
_VERY_SHORT_ = 100
_SHORT_DELAY_ = 500
_MEDIUM_DELAY_ = 1000
_LONG_DELAY_ = 3000
_ONE_SECOND_ = 1000

# Timer specific constants
_TIMER_IMMEDIATE_START_ = 0
_TIMER_NO_DELAY_ = 0
_TIMER_DEFAULT_DELAY_ = 0

# Timer check frequency
_CHECK_VERY_FAST_ = 1      # 1ms - high precision timing
_CHECK_FAST_ = 5           # 5ms - responsive UI updates  
_CHECK_NORMAL_ = 10        # 10ms - standard responsive timing
_CHECK_SLOW_ = 50          # 50ms - background tasks
_CHECK_VERY_SLOW_ = 100    # 100ms - low priority monitoring

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
_MS_PER_SECOND_ = 1000
_CLOCKS_TO_MS_MULTIPLIER_ = _MS_PER_SECOND_


#-------------------#
#  STREAM CONSTANTS #
#-------------------#

# Stream Source Types (unified naming)
_STREAM_MANUAL_ = "manual" 
_STREAM_AUTO_ = "auto"
_STREAM_EVENT_ = "event"
_STREAM_TIMER_ = "timer"
_STREAM_HTTP_ = "http"
_STREAM_FILE_ = "file"
_STREAM_UDP_ = "udp"
_STREAM_TCP_ = "tcp"
_STREAM_SIGNAL_ = "signal"
_STREAM_WORKER_ = "worker"
_STREAM_DNS_ = "dns"
_STREAM_LIBUV_ = "libuv"
_STREAM_NETWORK_ = "network"
_STREAM_SENSOR_ = "sensor"

# Alternative stream source names
_STREAM_SOURCE_MANUAL_ = "manual"
_STREAM_SOURCE_LIBUV_ = "libuv" 
_STREAM_SOURCE_TIMER_ = "timer"
_STREAM_SOURCE_FILE_ = "file"
_STREAM_SOURCE_NETWORK_ = "network"
_STREAM_SOURCE_SENSOR_ = "sensor"

_OPTIMISED_FOR_LIBUV_MESSAGES_ = "libuv" 
_OPTIMISED_FOR_TIMER_SOURCE_ = "timer"
_OPTIMISED_FOR_FILE_SOURCE_ = "file"
_OPTIMISED_FOR_NETWORK_SOURCE_ = "network"
_OPTIMISED_FOR_SENSOR_SOURCE_ = "sensor"

_OPTIMIzED_FOR_LIBUV_MESSAGES_ = "libuv" 
_OPTIMIzED_FOR_TIMER_SOURCE_ = "timer"
_OPTIMIzED_FOR_FILE_SOURCE_ = "file"
_OPTIMIzED_FOR_NETWORK_SOURCE_ = "network"
_OPTIMIzED_FOR_SENSOR_SOURCE_ = "sensor"

# Stream States (unified naming)
_STREAM_ACTIVE_ = true
_STREAM_INACTIVE_ = false

_STREAM_COMPLETED_ = "completed"
_STREAM_CONCLUDED_ = "completed"

_STREAM_ERROR_ = "error"

# Alternative stream state names  
_STREAM_STATE_INACTIVE_ = false
_STREAM_STATE_ACTIVE_ = true

_STREAM_STATE_COMPLETED_ = true
_STREAM_STATE_CONCLUDED_ = true

_STREAM_STATE_RUNNING_ = false

# Transform operations
_TRANSFORM_MAP_ = :map
_TRANSFORM_FILTER_ = :filter
_TRANSFORM_REDUCE_ = :reduce
_TRANSFORM_DEBOUNCE_ = :debounce
_TRANSFORM_THROTTLE_ = :throttle
_TRANSFORM_DISTINCT_ = :distinct

# Stream events
_EVENT_DATA_ = :data
_EVENT_ERROR_ = :error
_EVENT_COMPLETE_ = :complete
_EVENT_START_ = :start
_EVENT_STOP_ = :stop

# Buffer strategies
_BUFFER_EXPAND_ = "buffer"
_BUFFER_REJECT_NEWEST_ = "drop" 
_BUFFER_EVICT_OLDEST_ = "latest"
_BUFFER_BLOCK_ = "block"

# Stream processing
_STREAM_ATTR_CHANGES_ = "attribute_changes"
_STREAM_ALL_CHANGES_ = "all"
_STREAM_DISTINCT_CHANGES_ = "distinct"


#-------------------#
#  ENGINE CONSTANTS #
#-------------------#

# Engine States
_ENGINE_STOPPED_ = false
_ENGINE_RUNNING_ = true
_ENGINE_STARTING_ = "starting"
_ENGINE_STOPPING_ = "stopping"

#---------------------#
#  REACTIVE CONSTANTS #
#---------------------#

# Reactive modes
_REACTIVE_ON_ = true
_REACTIVE_OFF_ = false
_BATCH_MODE_ON_ = true
_BATCH_MODE_OFF_ = false

# Watch/Binding behavior
_WATCH_IMMEDIATE_ = true
_WATCH_DEBOUNCED_ = false
_WATCH_ALL_CHANGES_ = true
_WATCH_DISTINCT_ONLY_ = false

# Binding types (BINDING_* variants)
_BINDING_ONE_WAY_ = "oneway"
_BINDING_TWO_WAY_ = "twoway"
_BINDING_AUTO_SYNC_ = true
_BINDING_MANUAL_SYNC_ = false

# Binding types (BIND_* variants)
_BIND_ONE_WAY_ = "oneway"
_BIND_TWO_WAY_ = "twoway"
_BIND_AUTO_SYNC_ = true
_BIND_MANUAL_SYNC_ = false
_BIND_IMMEDIATE_ = true
_BIND_DEFERRED_ = false

# Attribute operations
_ATTR_GET_ = "get"
_ATTR_SET_ = "set"
_ATTR_COMPUTED_ = "computed"
_ATTR_WATCHED_ = "watched"
_ATTR_BOUND_ = "bound"

# Change types
_CHANGE_SET_ = "set"
_CHANGE_COMPUTED_ = "computed"
_CHANGE_BOUND_ = "bound"
_CHANGE_ASYNC_ = "async"
_CHANGE_DETECTED_ = true
_CHANGE_NONE_ = false
_CHANGE_TYPE_VALUE_ = "value"
_CHANGE_TYPE_COMPUTED_ = "computed"
_CHANGE_TYPE_BOUND_ = "bound"

# Batch processing
_BATCH_IMMEDIATE_ = "immediate"
_BATCH_DEFERRED_ = "deferred"
_BATCH_AUTO_FLUSH_ = true
_BATCH_MANUAL_FLUSH_ = false

#--------------------#
#  ASYNC CONSTANTS   #
#--------------------#

# Async states
_ASYNC_SUCCESS_ = "success"
_ASYNC_ERROR_ = "error"
_ASYNC_PENDING_ = "pending"

_ASYNC_COMPLETED_ = "completed"
_ASYNC_CONCLUDED_ = "completed"

_ASYNC_TIMEOUT_ = "timeout"

# Processing modes
PROCESS_SYNC = "sync"
PROCESS_ASYNC = "async"
_EMIT_IMMEDIATE_ = 0
_EMIT_DEBOUNCED_ = "debounced"
_EMIT_THROTTLED_ = "throttled"

#----------------------#
#  ERROR CONSTANTS     #
#----------------------#

# Error handling modes
_ERROR_IGNORE_ = "ignore"
_ERROR_LOG_ = "log"
_ERROR_THROW_ = "throw"
_ERROR_CALLBACK_ = "callback"
_ERROR_DEFAULT_ = _ERROR_LOG_

# Default error messages
_DEFAULT_ERROR_MSG_ = "Function execution failed"
_EMPTY_ERROR_MSG_ = ""

#--------------------------#
#  FUNCTION CALL CONSTANTS #
#--------------------------#

# Function call types
_FUNC_CALL_SYNC_ = "func_call"
_FUNC_CALL_ASYNC_ = "func_call_async"
_FUNC_CALL_CHUNKED_ = "func_call_chunked"

# Parameter limits
_MAX_FUNCTION_PARAMS_ = 10
_NO_PARAMS_ = 0

#---------------------------#
#  REACTIVE OBJECT CONSTANTS #
#---------------------------#

# Object modes
_OBJECT_STANDALONE_ = NULL        # For objects created from scratch
_OBJECT_WRAPPER_ = "wrapper"      # For wrapping existing objects

#-----------------#
#  HTTP CONSTANTS #
#-----------------#

# HTTP Methods
_HTTP_GET_ = "GET"
_HTTP_POST_ = "POST"
_HTTP_PUT_ = "PUT"
_HTTP_DELETE_ = "DELETE"
_HTTP_PATCH_ = "PATCH"
_HTTP_HEAD_ = "HEAD"
_HTTP_OPTIONS_ = "OPTIONS"

# HTTP Status ranges
_HTTP_SUCCESS_MIN_ = 200
_HTTP_SUCCESS_MAX_ = 299
_HTTP_REDIRECT_MIN_ = 300
_HTTP_REDIRECT_MAX_ = 399
_HTTP_CLIENT_ERROR_MIN_ = 400
_HTTP_CLIENT_ERROR_MAX_ = 499
_HTTP_SERVER_ERROR_MIN_ = 500
_HTTP_SERVER_ERROR_MAX_ = 599

# HTTP Headers
_CONTENT_TYPE_JSON_ = "application/json"
_CONTENT_TYPE_FORM_ = "application/x-www-form-urlencoded"
_CONTENT_TYPE_TEXT_ = "text/plain"
_USER_AGENT_REACTIVE_ = "stzReactive/1.0"

# HTTP Responses
_HTTP_RESPONSE_EMPTY_ = ""
_HTTP_RESPONSE_NULL_ = NULL

# HTTP Errors
_HTTP_ERROR_REQUEST_FAILED_ = "HTTP request failed"
_HTTP_ERROR_CURL_INIT_FAILED_ = "Failed to initialize HTTP client"
_HTTP_ERROR_INVALID_RESPONSE_ = "Invalid HTTP response"

# CURL timeouts
_CURL_TIMEOUT_DEFAULT_ = 30
_CURL_CONNECT_TIMEOUT_DEFAULT_ = 10

#-----------------#
#  FILE CONSTANTS #
#-----------------#

# File modes
_FILE_READ_ONLY_ = "r"
_FILE_WRITE_ONLY_ = "w"
_FILE_APPEND_ = "a"
_FILE_READ_WRITE_ = "rw"

# File permissions (readable names for octal values)
_FILE_PERMISSIONS_ = [
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
_ACCESS_MODES_ = [
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
_OPEN_FLAGS_ = [
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
_SYMLINK_FLAGS_ = [
    :DEFAULT = 0,
    :DIR = 1,           # Windows: create directory symlink
    :JUNCTION = 2       # Windows: create junction point
]

# File types
_FILE_TYPES_ = [
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
_WATCH_EVENTS_ = [
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

_UDP_REUSE_ADDR_ON_ = true
_UDP_REUSE_ADDR_OFF_ = false
_UDP_BROADCAST_ON_ = 1
_UDP_BROADCAST_OFF_ = 0
_UDP_MULTICAST_TTL_DEFAULT_ = 1
_UDP_MULTICAST_LOOP_ON_ = 1
_UDP_MULTICAST_LOOP_OFF_ = 0

#-----------------#
#  TCP CONSTANTS  #
#-----------------#

_TCP_DEFAULT_BACKLOG_ = 128
_TCP_DEFAULT_TIMEOUT_ = 30000  # 30 seconds
_TCP_CONNECTED_ = :connected
_TCP_DATA_ = :data
_TCP_CLIENT_CONNECTED_ = :client_connected
_TCP_CLIENT_MODE_ = :client
_TCP_SERVER_MODE_ = :server

#-----------------#
#  SIGNAL VALUES  #
#-----------------#

_SIGNAL_INT_ = 2   # SIGINT
_SIGNAL_TERM_ = 15 # SIGTERM
_SIGNAL_USR1_ = 30 # SIGUSR1
_SIGNAL_USR2_ = 31 # SIGUSR2
_SIGNAL_ONCE_ = :once
_SIGNAL_CONTINUOUS_ = :continuous

# Worker Constants
_WORKER_DEFAULT_POOL_SIZE_ = 4

# DNS Constants
_DNS_RESOLVE_A_ = "A"
_DNS_RESOLVE_AAAA_ = "AAAA"
_DNS_RESOLVE_PTR_ = "PTR"



#--------------------#
#  DEFAULT VALUES    #
#--------------------#

# Stream defaults
_DEFAULT_STREAM_SOURCE_ = _STREAM_MANUAL_
_DEFAULT_TIMER_DELAY_ = _MEDIUM_DELAY_
_DEFAULT_TIMER_CHECK_ = _CHECK_NORMAL_
# PATIENCE_NONE mirrors libuv's uv_run: return as soon as there are no
# active handles (timers). In Ring's synchronous setup model every timer
# is registered before RunLoop() and new ones only appear from inside a
# timer callback (checked in the same iteration), so there is nothing to
# "wait for" once the timer list is empty. The old PATIENCE_NORMAL (50)
# idled 50 x 10ms = 500ms after all work completed -- the bulk of the
# reactive perf regression vs the old Ring-libuv backend.
_DEFAULT_PATIENCE_ = PATIENCE_NONE

# Reactive defaults  
_DEFAULT_REACTIVE_MODE_ = _REACTIVE_ON_
_DEFAULT_BATCH_MODE_ = _BATCH_MODE_OFF_
_DEFAULT_ERROR_HANDLING_ = _ERROR_LOG_
_DEFAULT_ASYNC_MODE_ = PROCESS_ASYNC
_DEFAULT_BINDING_MODE_ = _BINDING_ONE_WAY_
_DEFAULT_WATCH_MODE_ = _WATCH_IMMEDIATE_
_DEFAULT_SYNC_MODE_ = _BINDING_AUTO_SYNC_
