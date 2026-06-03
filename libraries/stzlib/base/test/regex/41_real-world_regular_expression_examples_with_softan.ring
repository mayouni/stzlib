# Narrative
# --------
# #  Real-World Regular Expression Examples with Softanza  #
#
# Extracted from stzRegexTest.ring, block #41.

load "../../stzBase.ring"

#--------------------------------------------------------#

#-- URL Validation and Parsing

pr()

o1 = new stzRegex("https?://[\w\-.]+(:\d+)?(/[\w\-./?%&=]*)?")
urlText = "Visit https://example.com:8080/path?param=1#section or http://sub.domain.net"

# Basic URL detection

? o1.Match(urlText) + NL
#--> TRUE

# Extract URL components using named groups

o1.SetPattern("(?<protocol>https?)://(?<domain>[\w\-.]+)(?<port>:\d+)?(?<path>/[\w\-./?%&=]*)?")

if o1.Match(urlText) and o1.HasNames()
    ? @@NL(o1.CaptureXT()) + NL
ok
#--> [
#	[ "protocol", "https" ],
#	[ "domain", "example.com" ],
#	[ "port", ":8080" ],
#	[ "path", "/path?param=1" ]
# ]

# Validate specific URL types

o1.SetPattern("^https://.*\.gov$")

# Check a URL of a government site (will match)

? o1.Match("https://whitehouse.gov")
#--> TRUE

# Now we provide a commercial URL (won't match)

? o1.Match("https://example.com")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

#-- Phone Number Processing

pr()

o1 = new stzRegex("")

cPhoneText = "Call me at +1 (555) 123-4567 or 555.123.8901 or 5551234567"

# Match various phone formats

o1.SetPattern("(\+\d{1,3}[-. ])?\(?\d{3}\)?[-. ]?\d{3}[-. ]?\d{4}")

# Phone number detection

? o1.Match(cPhoneText)
#--> TRUE

# Format phone numbers consistently

o1.SetPattern("(?<country>\+\d{1,3}[-. ])?(?:\(?(?<area>\d{3})\)?[-. ]?)(?<prefix>\d{3})[-. ]?(?<line>\d{4})")

if o1.Match(cPhoneText) and o1.HasGroups()
    ? @@NL( o1.CaptureXT() )
ok
#--> [
#	[ "country", "+1 " ],
#	[ "area", "555" ],
#	[ "prefix", "123" ],
#	[ "line", "4567" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
