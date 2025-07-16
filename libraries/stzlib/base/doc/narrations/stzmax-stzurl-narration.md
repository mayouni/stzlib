# Mastering URL Manipulation with stzUrl: A Complete Guide

The `stzUrl` class is part of the **web-wings module** in the MAX layer of the **Softanza library** for Ring. Alongside other web-focused classes like `stzJson` and `stzHtml`, it provides sophisticated URL manipulation capabilities built on top of RingQt's binding of the C++ Qt library. `stzUrl` delivers an intuitive, object-oriented approach to parsing, building, and manipulating URLs with precision and ease.

## Core Concepts

### Object Creation and Validation

Creating URL objects is straightforward:

```ring
# From URL string
o1 = new stzUrl("https://www.google.com")
? o1.IsValid()     #--> TRUE
? o1.Content()     #--> https://www.google.com

# Empty URL object
o1 = new stzUrl("")
? o1.IsEmpty()     #--> TRUE
? o1.IsValid()     #--> FALSE

o1.SetUrl("www.site.com")
? o1.IsValid()	   #--> TRUE
```

The class intelligently validates URLs and provides clear feedback about their structure and validity.

## Component Extraction

`stzUrl` excels at decomposing complex URLs into their constituent parts:

```ring
o1 = new stzUrl("https://user:pass@api.example.com:8080/v1/users?format=json#profile")

? o1.Scheme()      #--> https
? o1.Host()        #--> api.example.com
? o1.Port()        #--> 8080
? o1.Path()        #--> /v1/users
? o1.Query()       #--> format=json
? o1.Fragment()    #--> profile
? o1.UserName()    #--> user
? o1.Password()    #--> pass
```

### Intuitive Method Names

The class provides intuitive method names that make code self-documenting:

```ring
o1 = new stzUrl("ftp://files.example.com/documents/report.pdf")

? o1.Protocol()    #--> ftp
? o1.Domain()      #--> files.example.com
? o1.Server()      #--> files.example.com
? o1.Location()    #--> /documents/report.pdf
? o1.FileName()    #--> report.pdf
```

## URL Types and Validation

The library recognizes various URL types and provides specialized validation:

```ring
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
```
Output:
```
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
```

### Protocol-Specific Checks

Built-in methods for common protocols:

```ring
? StzUrlQ("https://secure.com").IsHttps()        #--> TRUE
? StzUrlQ("http://regular.com").IsHttp()         #--> TRUE
? StzUrlQ("ftp://files.com").IsFtp()             #--> TRUE
? StzUrlQ("file:///local.txt").IsFileScheme()    #--> TRUE
```

> **NOTE**: The `StzUrlQ()` function creates a `stzUrl` object and return it so we can directly call any method on it.

## Building URLs Programmatically

### Step-by-Step Construction

The fluent interface allows elegant URL building:

```ring
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
```

### Modification and Rebuilding

Existing URLs can be easily modified:

```ring
o1 = new stzUrl("http://www.example.com/products")

# Upgrade to HTTPS
o1.SetScheme("https")

# Add authentication
o1.SetUserName("apiuser")
o1.SetPassword("secret")

# Add query parameters
o1.SetQuery("page=1&size=20")

? o1.Content()
#--> https://apiuser:secret@www.example.com/products?page=1&size=20
```

## Advanced Features

### URL Relationships

The library understands hierarchical relationships between URLs:

```ring
oParent = new stzUrl("https://www.example.com/docs/")
oChild = new stzUrl("https://www.example.com/docs/tutorial/")

? oParent.IsParentOf(oChild)    #--> TRUE
```

### URL Resolution

Relative URLs can be resolved against base URLs:

```ring
oBase = new stzUrl("https://www.example.com/docs/guide/")
oRelative = new stzUrl("../images/diagram.png")
oResolved = oBase.ResolvedWith(oRelative)

? oResolved.Content()
#--> https://www.example.com/docs/images/diagram.png
```

### File URL Handling

Seamless conversion between file paths and URLs:

```ring
cFilePath = "C:/Users/Documents/report.pdf"
o1 = new stzUrl("")
oFileUrl = o1.FromLocalFile(cFilePath)

? oFileUrl.Content()        #--> file:///C:/Users/Documents/report.pdf
? oFileUrl.ToLocalFile()    #--> C:/Users/Documents/report.pdf
```

## Practical Applications

### API Endpoint Builder

```ring
oApi = new stzUrl("")
oApi {
    SetScheme("https")
    SetHost("api.github.com")
    SetPath("/repos/microsoft/vscode/issues")
    SetQuery("state=open&labels=bug")
}
#--> https://api.github.com/repos/microsoft/vscode/issues?state=open&labels=bug
```

### Database Connection URLs

```ring
oDb = new stzUrl("")
oDb {
    SetScheme("postgresql")
    SetUserName("dbuser")
    SetPassword("dbpass")
    SetHost("localhost")
    SetPort(5432)
    SetPath("/myapp_db")
}
#--> postgresql://dbuser:dbpass@localhost:5432/myapp_db
```

### WebSocket URL Conversion

```ring
oHttp = new stzUrl("https://chat.example.com/room/123")
oWs = oHttp.Copy()
oWs {
    SetScheme("wss")
    SetPath("/ws/room/123")
}
#--> wss://chat.example.com/ws/room/123
```

## Error Handling and Robustness

The library provides comprehensive error reporting for invalid URLs:

```ring
o1 = new stzUrl("ht tp://invalid space.com")

? o1.IsValid()
#--> FALSE
? o1.Error()

#--> Relative URL's path component contains ':' before any '/'; source was "ht tp://invalid space.com"; path = "ht tp://invalid space.com"
```

Common error scenarios are handled gracefully, with descriptive messages that help developers identify and fix issues quickly.

## Performance and Efficiency

For applications requiring multiple URL manipulations, objects can be reused efficiently:

```ring
o1 = new stzUrl("")
aEndpoints = [
    ["https", "api1.service.com", "/v1/users"],
    ["https", "api2.service.com", "/v1/products"],
    ["https", "api3.service.com", "/v1/orders"]
]

for aEndpoint in aEndpoints
    o1.SetScheme(aEndpoint[1])
    o1.SetHost(aEndpoint[2])
    o1.SetPath(aEndpoint[3])
    ? o1.Content()
next
```
Output:
```
Building multiple URLs:
  https://api1.service.com/v1/users
  https://api2.service.com/v1/products
  https://api3.service.com/v1/orders
```

## Best Practices

1. **Always validate URLs** before processing with `IsValid()`
2. **Use expressive methods** like `Domain()` and `Protocol()` for clarity
3. **Leverage the Copy() method** when creating URL variants
4. **Handle errors gracefully** using the `Error()` method
5. **Reuse objects** for performance in batch operations

## Conclusion

The `stzUrl` class exemplifies the power and elegance of Softanza's web-wings module. By transforming complex URL operations into simple, readable code, it demonstrates how the Softanza library makes professional web development accessible in Ring. Whether building web scrapers, API clients, or file management tools, `stzUrl` provides the precision and flexibility needed for modern applications.