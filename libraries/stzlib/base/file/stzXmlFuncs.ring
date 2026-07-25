#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZXMLFUNCS               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The flat XML helpers -- the same shape stzJsonFuncs has for JSON: reach into a
# document without holding an object. Everything is engine-backed (see
# engine/src/xml.zig), so the parsing is one implementation shared with the XML
# signature code.
#
#   StzXmlIsValid(cXml)                -> TRUE/FALSE
#   StzXmlRoot(cXml)                   -> the root element's local name
#   StzXmlGet(cXml, cPath)             -> the text at that path
#   StzXmlAttr(cXml, cPath, cName)     -> an attribute value
#   StzXmlNamespace(cXml, cPath)       -> the element's namespace URI
#   StzXmlCount(cXml, cPath)           -> how many elements match
#   StzXmlHas(cXml, cPath)             -> TRUE/FALSE
#   StzXmlChildren(cXml, cPath)        -> the child element names, as a list
#   StzXmlPretty(cXml)                 -> the document, indented
#
# THE PATH LANGUAGE is deliberately small -- and it is NOT XPath, because a
# half-XPath invites people to expect the other half:
#
#   "Root/Child/Leaf"   walk down by LOCAL element name
#   "//Leaf"            the first element with that local name, anywhere
#   "Root/Item[2]"      the 2nd matching sibling (1-based)
#
# Elements match by LOCAL NAME on purpose. Real documents disagree about which
# prefix stands for the same namespace, and a path written against one vendor's
# prefix silently breaking on another's is a worse trap than the ambiguity. When
# the namespace matters, ask for it: StzXmlNamespace.
#
# WHAT THIS PARSER REFUSES, and why that is the point: any document carrying a
# DOCTYPE or an ENTITY declaration is rejected outright. That closes XXE and
# entity expansion BY CONSTRUCTION -- the most common way an XML reader turns into
# a file-disclosure primitive. It also means no DTD/XSD validation, no XPath, no
# XSLT, and UTF-8 only. Those are the price of the guarantee.

func StzXmlIsValid(pcXml)
	return StzEngineXmlValid("" + pcXml) = 1

func StzXmlRoot(pcXml)
	return StzEngineXmlRoot("" + pcXml)

func StzXmlGet(pcXml, pcPath)
	return StzEngineXmlText("" + pcXml, "" + pcPath)

func StzXmlAttr(pcXml, pcPath, pcName)
	return StzEngineXmlAttr("" + pcXml, "" + pcPath, "" + pcName)

func StzXmlNamespace(pcXml, pcPath)
	return StzEngineXmlNamespace("" + pcXml, "" + pcPath)

func StzXmlCount(pcXml, pcPath)
	_n_ = StzEngineXmlCount("" + pcXml, "" + pcPath)
	if _n_ < 0
		return 0
	ok
	return _n_

func StzXmlHas(pcXml, pcPath)
	return StzXmlCount(pcXml, pcPath) > 0

func StzXmlChildren(pcXml, pcPath)
	_r_ = StzEngineXmlChildren("" + pcXml, "" + pcPath)
	if _r_ = ""
		return []
	ok
	return StzSplit(_r_, nl)

func StzXmlPretty(pcXml)
	return StzEngineXmlPretty("" + pcXml)

# an integer-valued element ("" or unparsable -> 0)
func StzXmlGetInt(pcXml, pcPath)
	_v_ = ring_trim(StzXmlGet(pcXml, pcPath))
	if _v_ = ""
		return 0
	ok
	return 0 + _v_

# XML-escape a value bound for element content or an attribute
func StzXmlEscape(pcValue)
	_s_ = StzReplace("" + pcValue, "&", "&amp;")
	_s_ = StzReplace(_s_, "<", "&lt;")
	_s_ = StzReplace(_s_, ">", "&gt;")
	_s_ = StzReplace(_s_, '"', "&quot;")
	return StzReplace(_s_, "'", "&apos;")
