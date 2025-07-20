
# stzUrl Class - Comprehensive Test Suite
# Demonstrates all URL manipulation features with didactic progression

load "../stzmax.ring"

#-------------------------------#
#  BASIC OBJECT CREATION        #
#-------------------------------#

/*--- Creating an empty stzUrl object

pr()

o1 = new stzUrl("")

# Empty object should be properly initialized
? o1.IsEmpty()
#--> TRUE

? o1.IsValid()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Creating stzUrl with simple URL string

pr()

o1 = new stzUrl("https://www.google.com")

# Simple URL should parse correctly
? o1.IsValid()
#--> TRUE

? o1.Content()
#--> https://www.google.com

? o1.IsHttps()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22


#-------------------------------#
#  URL COMPONENT EXTRACTION     #
#-------------------------------#

/*--- Working with a complete URL

pr()

o1 = new stzUrl("https://user:pass@api.example.com:8080/v1/users?format=json#profile")

# Extract all URL components
? o1.Scheme()
#--> https

? o1.Host()
#--> api.example.com

? o1.Port()
#--> 8080

? o1.Path()
#--> /v1/users

? o1.Query()
#--> format=json

? o1.Fragment()
#--> profile

? o1.UserName()
#--> user

? o1.Password()
#--> pass

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Further infomation from a URL

pr()

o1 = new stzUrl("ftp://files.example.com/documents/report.pdf")

# Semantic method names for clarity
? o1.Protocol()
#--> ftp

? o1.Domain()
#--> files.example.com

? o1.Server()
#--> files.example.com

? o1.Location()
#--> /documents/report.pdf

? o1.FileName()
#--> report.pdf

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  URL VALIDATION & CHECKING    #
#-------------------------------#

/*--- Testing various URL types

pr()

aUrls = [
	"https://www.google.com",
	"http://localhost:3000",
	"ftp://files.example.com",
	"file:///C:/docs/file.txt",
	"../relative/path",
	"invalid url with spaces"
]

for cUrl in aUrls
	o1 = new stzUrl(cUrl)
	? "URL: " + cUrl
	? "  Valid: " + o1.IsValid()
	? "  Relative: " + o1.IsRelative()
	? "  Local File: " + o1.IsLocalFile()
	? ""
next

#-->
'
URL: https://www.google.com
  Valid: 1
  Relative: 0
  Local File: 0

URL: http://localhost:3000
  Valid: 1
  Relative: 0
  Local File: 0

URL: ftp://files.example.com
  Valid: 1
  Relative: 0
  Local File: 0

URL: file:///C:/docs/file.txt
  Valid: 1
  Relative: 0
  Local File: 1

URL: ../relative/path
  Valid: 1
  Relative: 1
  Local File: 0

URL: invalid url with spaces
  Valid: 1
  Relative: 1
  Local File: 0
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Invalid Urls

pr()

oURL = new stzUrl("")
oURL {
	SetUrl("https://domain with spaces.com")
	? IsValid()
	#--> FALSE

	SetUrl("ht tp://broken-scheme.com" )
	? IsValid()
	#--> FALSE

	SetUrl("https://[malformed-ipv6")
	? IsValid()
	#--> FALSE

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Protocol-specific checks

pr()

o1 = new stzUrl("https://secure.example.com")
? o1.IsHttps()
#--> TRUE

o1 = new stzUrl("http://regular.example.com")
? o1.IsHttp()
#--> TRUE

o1 = new stzUrl("ftp://files.example.com")
? o1.IsFtp()
#--> TRUE

o1 = new stzUrl("file:///local/file.txt")
? o1.IsFileScheme()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  BUILDING URLS STEP BY STEP   #
#-------------------------------#

/*--- Constructor pattern approach

pr()

oURL = new stzUrl("")

oURL {

	SetScheme("https")
	SetHost("api.mysite.com")
	SetPort(443)
	SetPath("/v2/products")
	SetQuery("category=electronics")
	SetFragment("results")

	? Content()
}

#--> https://api.mysite.com:443/v2/products?category=electronics#results

pf()

/*--- Clearing and rebuilding

pr()

o1 = new stzUrl("http://old.example.com/old-path")
o1.Clear()
o1.SetScheme("ftp")
o1.SetHost("files.newsite.com")
o1.SetPath("/downloads")

? o1.Content()
#--> ftp://files.newsite.com/downloads

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  URL MODIFICATION             #
#-------------------------------#

/*--- Modifying existing URLs

pr()

o1 = new stzUrl("http://www.example.com/products")

# Original

? o1.Content()
#--> http://www.example.com/products

# Upgrade to HTTPS

o1.SetScheme("https")
? o1.Content()
#--> https://www.example.com/products

# Add authentication

o1.SetUserName("apiuser")
o1.SetPassword("secret")
? o1.Content()
#--> https://apiuser:secret@www.example.com/products

# Add query parameters

o1.SetQuery("page=1&size=20")
? o1.Content()
#--> https://apiuser:secret@www.example.com/products?page=1&size=20

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  URL RELATIONSHIPS            #
#-------------------------------#

/*--- Parent-child relationships

pr()

oParent = new stzUrl("https://www.example.com/docs/")
oChild = new stzUrl("https://www.example.com/docs/tutorial/")
oSibling = new stzUrl("https://www.example.com/blog/")

? oParent.IsParentOf(oChild)
#-->TRUE

? oParent.IsParentOf(oSibling)
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- URL resolution

pr()

oBase = new stzUrl("https://www.example.com/docs/guide/")
oRelative = new stzUrl("../images/diagram.png")
oResolved = oBase.ResolvedWith(oRelative)

? oResolved.Content()
#--> https://www.example.com/docs/images/diagram.png

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  FILE URL HANDLING            #
#-------------------------------#

/*--- Converting file paths to URLs

pr()

cFilePath = "C:/Users/Documents/report.pdf"
o1 = new stzUrl("")
oFileUrl = o1.FromLocalFile(cFilePath)

# File URL
? oFileUrl.Content()
#--> file:///C:/Users/Documents/report.pdf

?  oFileUrl.IsLocalFile()
#--> TRUE

? oFileUrl.ToLocalFile()
#--> C:/Users/Documents/report.pdf

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  COPYING AND INDEPENDENCE     #
#-------------------------------#

/*--- URL copying preserves independence

pr()

o1 = new stzUrl("https://api.service.com/v1/data")
o2 = o1.Copy()

? o1.Content()
#--> Original: https://api.service.com/v1/data

? o2.Content() + NL
#--> https://api.service.com/v1/data


# Modify copy - original unchanged

o2.SetScheme("http")
o2.SetPath("/v2/data")

? o1.Content()
#--> https://api.service.com/v1/data

? o2.Content()
#--> Modified: http://api.service.com/v2/data

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  PRACTICAL EXAMPLES           #
#-------------------------------#

/*--- API endpoint builder

pr()

oApi = new stzUrl("")
oApi {
	SetScheme("https")
	SetHost("api.github.com")
	SetPath("/repos/microsoft/vscode/issues")
	SetQuery("state=open&labels=bug")

	? Content()
}

#--> https://api.github.com/repos/microsoft/vscode/issues?state=open&labels=bug

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Database connection URL

pr()

oDb = new stzUrl("")
oDb {
	SetScheme("postgresql")
	SetUserName("dbuser")
	SetPassword("dbpass")
	SetHost("localhost")
	SetPort(5432)
	SetPath("/myapp_db")

	? oDb.Content()
}
#--> postgresql://dbuser:dbpass@localhost:5432/myapp_db

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- WebSocket URL conversion

pr()

oHttp = new stzUrl("https://chat.example.com/room/123")

oWs = oHttp.Copy()
oWs { SetScheme("wss") SetPath("/ws/room/123") }

? oHttp.Content()
#--> https://chat.example.com/room/123

? oWs.Content()
#--> wss://chat.example.com/ws/room/123

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  ERROR HANDLING               #
#-------------------------------#

/*---

pr()

o1 = new stzUrl("ht tp://invalid space.com")
? o1.IsValid()
#--> FALSE

? o1.Error()
#--> Relative URLs path component contains ':' before any '/';
# source was "ht tp://invalid space.com";
# path = "ht tp://invalid space.com"


pf()

/*--- Invalid URL handling

pr()

o1 = new stzUrl("ht tp://invalid space.com")
? o1.IsValid()
#--> FALSE

? o1.Error() + NL
#-->
# Relative URL path component contains ':' before any '/';
# source was "ht tp://invalid space.com";
# path = "ht tp://invalid space.com"

#--

o1 = new stzUrl("https://[invalid-bracket")
? o1.IsValid()
#--> FALSE

? o1.Error() + NL
#-->
# Expected ']' to match '[' in hostname;
# source was "https://[invalid-bracket";
# scheme = "https", host = ""

#---

o1 = new stzUrl("://missing-scheme.com")
? o1.IsValid()
#--> FALSE

? o1.Error()
#-->
# Relative URL path component contains ':' before any '/';
# source was "://missing-scheme.com";
# path = "://missing-scheme.com"

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-------------------------------#
#  PERFORMANCE OPTIMIZATION     #
#-------------------------------#

/*--- Reusing URL objects efficiently
*/
pr()

o1 = new stzUrl("")

aEndpoints = [
	["https", "api1.service.com", "/v1/users"],
	["https", "api2.service.com", "/v1/products"],
	["https", "api3.service.com", "/v1/orders"]
]

? "Building multiple URLs:"
for aEndpoint in aEndpoints
	o1.SetScheme(aEndpoint[1])
	o1.SetHost(aEndpoint[2])
	o1.SetPath(aEndpoint[3])
	? "  " + o1.Content()
next
#--> Building multiple URLs:
#  https://api1.service.com/v1/users
#  https://api2.service.com/v1/products
#  https://api3.service.com/v1/orders

pf()
# Executed in almost 0 second(s) in Ring 1.22
