_$aRegExpPatternsExplanations_ = [

	# Web & Email

	:email = [
		"Matches standard email formats",
	
		"- `^` and `$`: Start and end of the string." + NL +
		"- `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters." + NL +
		"- `@`: Required @ symbol." + NL +
		"- `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens." + NL +
		"- `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters." + NL +
		"- Matches: `user@domain.com`, `user.name+tag@example.co.uk`" + NL +
		"- Non-matches: `@domain.com`, `user@.com`, `user@domain`"
	
	],

	:url = [
		"Matches a standard HTTP or HTTPS URL",
	
		"- `^https?:\/\/`: Start with `http://` or `https://`." + NL +
		"- `(?:[a-zA-Z0-9-]+\.)+`: Domain part (subdomains are optional)." + NL +
		"- `[a-zA-Z]{2,}`: Domain TLD (top-level domain), at least two letters." + NL +
		"- `(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$`: Optional path, query, or fragment." + NL +
		"- Matches: `https://example.com`, `http://domain.co.uk/path?query`" + NL +
		"- Non-matches: `htt://example.com`, `://domain.com`"
	],

	:domain = [
		"Matches domain names with letters, numbers, and hyphens",
	
		"- `^[a-zA-Z0-9]`: Domain must start with a letter or number." + NL +
		"- `[a-zA-Z0-9-]{1,61}`: Allowed characters include letters, numbers, and hyphens, between 1 and 61." + NL +
		"- `[a-zA-Z0-9]`: Domain ends with a letter or number." + NL +
		"- `\.[a-zA-Z]{2,}$`: Domain ends with a valid TLD." + NL +
		"- Matches: `domain.com`, `subdomain.domain.org`" + NL +
		"- Non-matches: `-domain.com`, `domain..com`"
	],

	:ipv4 = [
		"Matches valid IPv4 addresses",
	
		"- `^`: Start of string." + NL +
		"- `(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`: Match numbers 0-255." + NL +
		"- `\.`: Dot separator between octets." + NL +
		"- Pattern repeated 3 times with dots." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `192.168.0.1`, `10.0.0.0`, `255.255.255.255`" + NL +
		"- Non-matches: `256.1.2.3`, `1.2.3`, `300.1.2.3`"
	],

	:ipv6 = [
		"Matches valid IPv6 addresses",
	
		"- `([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}`: Full IPv6 address." + NL +
		"- `([0-9a-fA-F]{1,4}:){1,7}:`: Compressed format with `::`." + NL +
		"- `([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}`: Mixed formats." + NL +
		"- Matches: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`, `fe80::1`" + NL +
		"- Non-matches: `:::1`, `2001:0db8::`"
	],

	:socialHandle = [
		"Matches social media handles",
	
		"- `^`: Start of string." + NL +
		"- `@`: Required @ symbol at start." + NL +
		"- `[a-zA-Z0-9._]{1,30}`: Username with letters, numbers, dots, underscores." + NL +
		"- Maximum length of 30 characters." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `@user123`, `@john.doe`, `@handle_name`" + NL +
		"- Non-matches: `user123`, `@user name`, `@`"
	],

	:slug = [
		"Matches URL-friendly slugs",
	
		"- `^`: Start of string." + NL +
		"- `[a-z0-9]+`: One or more lowercase letters or numbers." + NL +
		"- `(?:-[a-z0-9]+)*`: Optional groups of hyphen followed by alphanumerics." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `my-blog-post`, `article-123`, `hello`" + NL +
		"- Non-matches: `-post`, `Post-Title`, `my--post`"
	],

	# Dates & Times (International)

	:isoDate = [
		"Matches ISO 8601 date format (YYYY-MM-DD)",
	
		"- `^`: Start of string." + NL +
		"- `\d{4}`: Four digits for year." + NL +
		"- `-`: Literal hyphen separator." + NL +
		"- `(0[1-9]|1[0-2])`: Month 01-12." + NL +
		"- `-`: Literal hyphen separator." + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day 01-31." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `2023-12-25`, `2024-01-01`" + NL +
		"- Non-matches: `2023/12/25`, `23-12-25`"
	],

	:isoDateTime = [
		"Matches ISO 8601 datetime format with optional timezone",
	
		"- Starts with ISO date format." + NL +
		"- `T`: Time separator." + NL +
		"- `([01]?[0-9]|2[0-3])`: Hours (00-23)." + NL +
		"- `:[0-5][0-9]:[0-5][0-9]`: Minutes and seconds." + NL +
		"- `(\.[0-9]+)?`: Optional fractional seconds." + NL +
		"- `(Z|[+-][01][0-9]:[0-5][0-9])?`: Optional timezone." + NL +
		"- Matches: `2023-12-25T14:30:00Z`, `2024-01-01T09:00:00+01:00`" + NL +
		"- Non-matches: `2023-12-25 14:30`, `2023-12-25T25:00:00Z`"
	],

	:ddmmyyyy = [
		"Matches dates in DD/MM/YYYY format with various separators",
	
		"- `^`: Start of string." + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)." + NL +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)." + NL +
		"- `(0[1-9]|1[0-2])`: Month (01-12)." + NL +
		"- `[-/.]`: Same separator as above." + NL +
		"- `\d{4}`: Four-digit year." + NL +
		"- Matches: `25/12/2023`, `01-01-2024`, `31.12.2023`" + NL +
		"- Non-matches: `32/12/2023`, `13/13/2023`"
	],

	:mmddyyyy = [
		"Matches dates in MM/DD/YYYY format with various separators",
	
		"- `^`: Start of string." + NL +
		"- `(0[1-9]|1[0-2])`: Month (01-12)." + NL +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)." + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)." + NL +
		"- `[-/.]`: Same separator as above." + NL +
		"- `\d{4}`: Four-digit year." + NL +
		"- Matches: `12/25/2023`, `01-01-2024`, `12.31.2023`" + NL +
		"- Non-matches: `13/25/2023`, `12/32/2023`"
	],

	:time24h = [
		"Matches 24-hour time format (HH:MM)",
	
		"- `^`: Start of string." + NL +
		"- `([01]?[0-9]|2[0-3])`: Hours (0-23)." + NL +
		"- `:`: Time separator." + NL +
		"- `[0-5][0-9]`: Minutes (00-59)." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `23:59`, `00:00`, `14:30`" + NL +
		"- Non-matches: `24:00`, `12:60`, `1:5`"
	],

	# Markdown

	:mdHeader = [
		"Matches Markdown headers",
        
		"- `^`: Start of line." + NL +
		"- `#{1,6}`: 1 to 6 hash symbols." + NL +
		"- `\\s`: Required space." + NL +
		"- `.+`: Header text." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `# Header`, `### Subheader`" + NL +
		"- Non-matches: `#Header`, `####### TooManyHashes`"
	],

	:mdBold = [
		"Matches Markdown bold text",
        
		"- `\\*\\*`: Two asterisks." + NL +
		"- `[^*]+`: Any characters except asterisk." + NL +
		"- `\\*\\*`: Closing asterisks." + NL +
		"- Matches: `**bold text**`, `**important**`" + NL +
		"- Non-matches: `*single*`, `**incomplete`"
	],

	:mdItalic = [
		"Matches Markdown italic text",
 
		"- `\\*`: Single asterisk." + NL +
		"- `[^*]+`: Any characters except asterisk." + NL +
		"- `\\*`: Closing asterisk." + NL +
		"- Matches: `*italic*`, `*emphasized*`" + NL +
		"- Non-matches: `**bold**`, `*incomplete`"
	],

	:mdLink = [
		"Matches Markdown links",

		"- `\\[`: Opening square bracket." + NL +
		"- `([^\\]]+)`: Link text (anything but closing bracket)." + NL +
		"- `\\]`: Closing square bracket." + NL +
		"- `\\(`: Opening parenthesis." + NL +
		"- `([^\\)]+)`: URL (anything but closing parenthesis)." + NL +
		"- `\\)`: Closing parenthesis." + NL +
		"- Matches: `[link](url)`, `[Example](http://example.com)`" + NL +
		"- Non-matches: `[link](`, `[link]`"
	],

	:mdImage = [
		"Matches Markdown images",

		"- `!`: Exclamation mark prefix." + NL +
		"- `\\[`: Opening square bracket." + NL +
		"- `([^\\]]*)`': Alt text (optional, anything but closing bracket)." + NL +
		"- `\\]`: Closing square bracket." + NL +
		"- `\\(`: Opening parenthesis." + NL +
		"- `([^\\)]+)`: Image URL (anything but closing parenthesis)." + NL +
		"- `\\)`: Closing parenthesis." + NL +
		"- Matches: `![alt](image.jpg)`, `![](photo.png)`" + NL +
		"- Non-matches: `[img](pic.jpg)`, `![alt]()`"
	],

	:mdBlockquote = [
		"Matches Markdown blockquotes",

		"- `^`: Start of line." + NL +
		"- `>`: Greater than symbol." + NL +
		"- `\\s`: Required space." + NL +
		"- `.+`: Quoted text." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `> Quote`, `> Multiple words`" + NL +
		"- Non-matches: `>No space`, `Quote>`"
	],

	:mdCodeBlock = [
		"Matches Markdown code blocks",

		"- ```" + char(34) + ": Three backticks opening." + NL +
		"- `[^`]*`: Any characters except backtick." + NL +
		"- ```" + char(34) + ": Three backticks closing." + NL +
		"- Matches: ```code block```, ```multiple" + NL + "lines```" + NL +
		"- Non-matches: ``two ticks``, ````four ticks````"
	],

	:mdInlineCode = [
		"Matches Markdown inline code",

		"- `` ` ``: Single backtick." + NL +
		"- `[^`]+`: Any characters except backtick." + NL +
		"- `` ` ``: Closing backtick." + NL +
		"- Matches: `code`, `var x = 1`" + NL +
		"- Non-matches: ``double``, `unclosed"
	],

	:mdListItem = [
		"Matches Markdown unordered list items",

		"- `^`: Start of line." + NL +
		"- `[-*+]`: Either hyphen, asterisk, or plus sign." + NL +
		"- `\\s`: Required space." + NL +
		"- `.+`: List item text." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `- Item`, `* Point`, `+ Element`" + NL +
		"- Non-matches: `Item-`, `-No space`"
	],

	:mdNumberedList = [
		"Matches Markdown numbered list items",

		"- `^`: Start of line." + NL +
		"- `\\d+`: One or more digits." + NL +
		"- `\\.`: Literal period." + NL +
		"- `\\s`: Required space." + NL +
		"- `.+`: List item text." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `1. First`, `42. Item`" + NL +
		"- Non-matches: `1.No space`, `A. Letter`"
	],

	# YAML Patterns
	
   	:yamlKey = [
		"Matches YAML keys",

		"- `^`: Start of line." + NL +
		"- `[a-zA-Z0-9]+`: At least one alphanumeric character." + NL +
		"- `[a-zA-Z0-9_-]*`: Optional alphanumeric, underscore, or hyphen characters." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `key`, `user123`, `my-key`, `long_key_name`" + NL +
		"- Non-matches: `123`, `-key`, `key:`, `invalid!key`"
	],

	:yamlValue = [
		"Matches YAML values (strings, numbers, booleans, null)",

		"- `^`: Start of line." + NL +
		"- `(`: Start first alternative (quoted strings):" + NL +
		"  - `\\ " + char(34) + "`: Opening quote" + NL +
		"  - `[^\\ " + char(34) + "]*`: Any characters except quotes" + NL +
		"  - `\\ " + char(34) + "`: Closing quote" + NL +
		"- `)`: End first alternative" + NL +
		"- `|`: OR" + NL +
		"- `([0-9]+)`: Second alternative (numbers)" + NL +
		"- `|`: OR" + NL +
		"- `(true|false)|null`: Third alternative (booleans and null)" + NL +
		"- `$`: End of line." + NL +
		"- Matches: `" + char(34) + "hello" + char(34) + "`, `42`, `true`, `false`, `null`" + NL +
		"- Non-matches: `'single quotes'`, `-42`, `True`, `NULL`"
	],

	:yamlMap = [
		"Matches YAML key-value mappings",

		"- `^`: Start of line." + NL +
		"- `[a-zA-Z0-9]+`: Key (at least one alphanumeric character)." + NL +
		"- `:`: Colon separator." + NL +
		"- `[ ]*`: Optional spaces." + NL +
		"- `.+`: Value (any non-empty string)." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `name: John`, `age: 25`, `active: true`" + NL +
		"- Non-matches: `: value`, `key :value`, `key:`, `-key: value`"
	],

	:yamlArray = [
		"Matches YAML array elements (numbers or quoted strings)",

		"- `^`: Start of line." + NL +
		"- `-?[0-9]+`: First alternative (optional negative sign followed by digits)" + NL +
		"- `|`: OR" + NL +
		"- `\\ " + char(34) + "`: Opening quote" + NL +
		"- `[^\\ " + char(34) + "]*`: Any characters except quotes" + NL +
		"- `\\ " + char(34) + "`: Closing quote" + NL +
		"- `$`: End of line." + NL +
		"- Matches: `42`, `-42`, `" + char(34) + "element" + char(34) + "`, `" + char(34) + "item 1" + char(34) + "`" + NL +
		"- Non-matches: `true`, `null`, `'single quotes'`, `plain text`"
	],

	:yamlFrontMatter = [
		"Matches YAML front matter blocks",

		"- `^`: Start of line." + NL +
		"- `---`: Opening delimiter." + NL +
		"- `\\s*\\n`: Optional whitespace and newline." + NL +
		"- `(.*?)`: Non-greedy capture of any characters." + NL +
		"- `\\n---`: Closing delimiter with newline." + NL +
		"- `$`: End of line." + NL +
		"- Matches:" + NL +
		"  ```yaml" + NL +
		"  ---" + NL +
		"  title: Post" + NL +
		"  date: 2024-01-15" + NL +
		"  ---" + NL +
		"  ```" + NL +
		"- Non-matches: `---only start`, `--- no end content`"
	],

	# HTML Patterns

	:htmlComment = [
		"Matches HTML comments",

		"- `<!--`: Comment opening sequence." + NL +
		"- `[\\s\\S]*?`: Any characters including newlines (non-greedy)." + NL +
		"- `-->`: Comment closing sequence." + NL +
		"- Matches: `<!-- comment -->`, `<!-- multi" + NL + "line -->`" + NL +
		"- Non-matches: `<!-- unclosed`, `/* css comment */`"
	],

	:htmlDoctype = [
		"Matches HTML DOCTYPE declarations",

		"- `<!DOCTYPE`: DOCTYPE opening sequence." + NL +
		"- `[^>]*`: Any characters except closing bracket." + NL +
		"- `>`: Closing bracket." + NL +
		"- Matches: `<!DOCTYPE html>`, `<!DOCTYPE HTML PUBLIC>`" + NL +
		"- Non-matches: `<!DOCTYPEhtml>`, `<!DOCTYPE>`"
	],

	:htmlOpenTag = [
		"Matches HTML opening tags with optional attributes",

		"- `<`: Opening angle bracket." + NL +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name." + NL +
		"- `((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\ " + NL + char(34) + NL + ".*?\ " + NL + char(34) + NL + "|'.*?'|[^'\ " + NL + char(34) + NL + "<>\\s]+))?)*)`:" + NL +
		"  Optional attributes with values." + NL +
		"- `\s*/?>`: Optional self-closing slash and closing bracket." + NL +
		"- Matches: `<div>`, `<input type=\ " + NL + char(34) + NL + "text\ " + NL + char(34) + NL + ">`, `<br/>`" + NL +
		"- Non-matches: `<1div>`, `<div`, `</div>`"
	],

	:htmlCloseTag = [
		"Matches HTML closing tags",

		"- `</`: Closing tag opening sequence." + NL +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name." + NL +
		"- `>`: Closing bracket." + NL +
		"- Matches: `</div>`, `</p>`, `</html>`" + NL +
		"- Non-matches: `</1>`, `</>`, `</div`"
	],

	:htmlAttribute = [
		"Matches HTML attributes with optional values",

		"- `\\s+`: Required whitespace." + NL +
		"- `[a-zA-Z][a-zA-Z0-9]*`: Attribute name." + NL +
		"- `(?:\\s*=\\s*`: Optional value assignment." + NL +
		"- `(?:" + char(34) + ".*?" + char(34) + "|'.*?'|[^'" + char(34) + "<>\\s]+))?`: Optional value." + NL +
		"- Matches: `class=" + char(34) + "main" + char(34) + "`, `disabled`, `data-value='123'`" + NL +
		"- Non-matches: `=value`, `123=456`, `class =`"
	],

	:htmlClass = [
		"Matches HTML class attributes",

		"- `\\s+class\\s*=\\s*`: Class attribute declaration." + NL +
		"- `(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "`: Double-quoted value." + NL +
		"- `|'[^']*'`: Single-quoted value." + NL +
		"- `|[^'" + char(34) + "\\s>]+)`: Unquoted value." + NL +
		"- Matches: `class=" + char(34) + "main" + char(34) + "`, `class='header'`, `class=container`" + NL +
		"- Non-matches: `class=`, `class=>`, `class`"
	],

	:htmlId = [
		"Matches HTML id attributes",

		"- `\\s+id\\s*=\\s*`: ID attribute declaration." + NL +
		"- `(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "`: Double-quoted value." + NL +
		"- `|'[^']*'`: Single-quoted value." + NL +
		"- `|[^'" + char(34) + "\\s>]+)`: Unquoted value." + NL +
		"- Matches: `id=" + char(34) + "main" + char(34) + "`, `id='header'`, `id=container`" + NL +
		"- Non-matches: `id=`, `id=>`, `id`"
	],

	:html5Color = [
		"Matches HTML5 color hexadecimal values",
    
		"- `^`: Start of line." + NL +
		"- `#`: Hash symbol." + NL +
		"- `[A-Fa-f0-9]{3,6}`: 3 or 6 hexadecimal characters." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `#fff`, `#000000`, `#12AB3F`" + NL +
		"- Non-matches: `#12`, `#1234567`, `123456`"
	],

	# CSS Patterns
	
	:idSelector = [
		"Matches CSS ID selectors",
	
		"- `^`: Start of string." + NL +
		"- `#`: Hash symbol for ID." + NL +
		"- `([a-zA-Z_][a-zA-Z\\d_-]*)`: Valid ID name." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `#header`, `#nav-bar_1`" + NL +
		"- Non-matches: `#1header`, `.class-name`"
	],

	:classSelector = [
		"Matches CSS class selectors",

		"- `^`: Start of line." + NL +
		"- `\\.`: Dot prefix." + NL +
		"- `([a-zA-Z_]`: Must start with letter or underscore." + NL +
		"- `[a-zA-Z\\d_-]*)`: Can contain letters, digits, underscores, hyphens." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `.container`, `.nav_item`, `.btn-primary`" + NL +
		"- Non-matches: `.1class`, `.`, `.class#id`"
	],

	:attributeSelector = [
		"Matches CSS attribute selectors with optional values",

		"- `\\[\\s*`: Opening bracket with optional whitespace." + NL +
		"- `([a-zA-Z][a-zA-Z0-9-]*)`: Attribute name." + NL +
		"- `\\s*`: Optional whitespace." + NL +
		"- `(?:([*^$|!~]?=)`: Optional operator." + NL +
		"- `\\s*`: Optional whitespace." + NL +
		"- `(?:\\ " + char(34) + "[^\\ " + char(34) + "]*\\ " + char(34) + "|'[^']*'|[^'\\ " + char(34) + "\\s>]+))?`: Optional value." + NL +
		"- `\\s*\\]`: Closing bracket with optional whitespace." + NL +
		"- Matches: `[type]`, `[type=" + char(34) + "text" + char(34) + "]`, `[class^=" + char(34) + "btn-" + char(34) + "]`" + NL +
		"- Non-matches: `[1type]`, `[]`, `[type=]`"
	],

	:hexColor = [
		"Matches CSS hexadecimal color values",

		"- `^`: Start of line." + NL +
		"- `#`: Hash symbol." + NL +
		"- `([a-fA-F\\d]{3}`: Three hex digits." + NL +
		"- `|`: OR." + NL +
		"- `[a-fA-F\\d]{6})`: Six hex digits." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `#fff`, `#000000`, `#1a2b3c`" + NL +
		"- Non-matches: `#1`, `#12345`, `#gggggg`"
	],

	:rgbColor = [
		"Matches CSS RGB and RGBA color values",

		"- `^`: Start of line." + NL +
		"- `rgba?`: 'rgb' with optional 'a'." + NL +
		"- `\\(`: Opening parenthesis." + NL +
		"- `\\s*\\d{1,3}\\s*,`: Red value (0-255)." + NL +
		"- `\\s*\\d{1,3}\\s*,`: Green value (0-255)." + NL +
		"- `\\s*\\d{1,3}`: Blue value (0-255)." + NL +
		"- `(\\s*,\\s*(0|1|0?\\.\\d+))?`: Optional alpha value (0-1)." + NL +
		"- `\\s*\\)`: Closing parenthesis." + NL +
		"- `$`: End of line." + NL +
		"- Matches: `rgb(255,0,0)`, `rgba(255, 0, 0, 0.5)`" + NL +
		"- Non-matches: `rgb(300,0,0)`, `rgba(255,0)`, `rgb()`"
	],

	# Numbers & Currency (International)

	:number = [
		"Matches various number formats including decimals and thousands separators",

		"- `^`: Start of string." + NL +
		"- `-?`: Optional negative sign." + NL +
		"- `(?:\\d+|\\d{1,3}(?:,\\d{3})+)?`: Whole number part with optional thousands separators." + NL +
		"- `(?:\\.\\d+)?`: Optional decimal part." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `1234`, `-123.45`, `1,234,567.89`" + NL +
		"- Non-matches: `123.`, `.123`, `1,23,456`"
	],

	:currencyValue = [
		"Matches currency values formatted with thousand separators and two decimal places.",

		"- `^-?`: Optional negative sign." + NL +
		"- `\\d{1,3}(?:,\\d{3})*`: Matches numbers with optional thousand separators (e.g., `1,000`)." + NL +
		"- `(?:\\.\\d{2})?`: Optional decimal part with exactly two digits." + NL +
		"- Matches: `1,234.56`, `1234.00`, `-1,000.99`." + NL +
		"- Non-matches: `1234.5`, `12,34.00`, `123,456.789`."
	],

	:scientificNotation = [
		"Matches numbers in scientific notation format.",

		"- `^-?`: Optional negative sign." + NL +
		"- `\\d+(?:\\.\\d+)?`: Matches a number with an optional decimal part." + NL +
		"- `(?:e[+-]?\\d+)?`: Optional scientific notation with exponent (e.g., `e+10`)." + NL +
		"- Matches: `1.23e+3`, `-4.56e-7`, `123e5`, `0.001`." + NL +
		"- Non-matches: `1e`, `1.2.3`, `e+2`."
	],

	:percentage = [
		"Matches percentages with optional decimal points.",

		"- `^-?`: Optional negative sign." + NL +
		"- `\\d*\\.?\\d+`: Matches an optional integer or decimal part." + NL +
		"- `%`: Ensures the value ends with a percent symbol." + NL +
		"- Matches: `50%`, `123.45%`, `-0.1%`." + NL +
		"- Non-matches: `50`, `%50`, `123.45`."
	],

	:hexColor = [
		"Matches hexadecimal color codes in 3 or 6 digit formats.",

		"- `^#`: Ensures the value starts with a hash (`#`)." + NL +
		"- `([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})`: Matches either a 6-digit or 3-digit hexadecimal value." + NL +
		"- Matches: `#FFF`, `#ffffff`, `#123abc`." + NL +
		"- Non-matches: `#1234`, `123abc`, `#fffffg`."
	],

	# Contact Information (International)
	
	:phoneE164 = [
		"Matches E.164 international phone number format",
	
		"- `^`: Start of string." + NL +
		"- `\\+`: Required plus sign." + NL +
		"- `[1-9]`: First digit must be 1-9." + NL +
		"- `\\d{1,14}`: 1 to 14 additional digits." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `+12345678901`, `+442071234567`" + NL +
		"- Non-matches: `12345678901`, `+0123456789`"
	],
	
	:phoneGeneral = [
		"Matches various phone number formats",
	
		"- `^`: Start of string." + NL +
		"- `[+]?`: Optional plus sign." + NL +
		"- `[(]?`: Optional opening parenthesis." + NL +
		"- `[0-9]{1,4}`: 1-4 digits for country/area code." + NL +
		"- `[)]?`: Optional closing parenthesis." + NL +
		"- `[-\\s./0-9]*`: Any combination of digits, spaces, hyphens, dots, slashes." + NL +
		"- Matches: `(123) 456-7890`, `+1.234.567.8900`, `123-456-7890`" + NL +
		"- Non-matches: `abc-def-ghij`, `12-3456`"
	],

:postalCode = [
    "Matches postal codes with alphanumeric characters, optional spaces, and hyphens.",
    
    "- `^[A-Z0-9]`: Ensures the code starts with an alphanumeric character." + NL +
    "- `[A-Z0-9\\- ]{0,10}`: Matches up to 10 characters including spaces and hyphens." + NL +
    "- `[A-Z0-9]$`: Ensures the code ends with an alphanumeric character." + NL +
    "- Matches: `12345`, `A1B 2C3`, `123-4567`." + NL +
    "- Non-matches: `12 345`, `-12345`, `123 45 `."
],

:countryCode = [
    "Matches country codes of 2 to 3 uppercase letters.",
    
    "- `^[A-Z]{2,3}$`: Ensures 2 to 3 uppercase alphabetic characters." + NL +
    "- Matches: `US`, `CAN`, `GB`." + NL +
    "- Non-matches: `Us`, `123`, `USA1`."
],

:languageCode = [
    "Matches language codes in `xx-XX` format, where `xx` is a lowercase language code and `XX` is an uppercase country code.",
    
    "- `^[a-z]{2}`: Ensures two lowercase letters for the language code." + NL +
    "- `-[A-Z]{2}`: Ensures a hyphen followed by two uppercase letters for the country code." + NL +
    "- Matches: `en-US`, `fr-CA`, `es-ES`." + NL +
    "- Non-matches: `EN-us`, `english-US`, `us-en`."
],

	# Modern Data Formats
	
	:jwt = [
		"Matches JSON Web Tokens",
	
		"- `^`: Start of string." + NL +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded header." + NL +
		"- `\\.`: Dot separator." + NL +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded payload." + NL +
		"- `\\.`: Dot separator." + NL +
		"- `[A-Za-z0-9-_]*`: Base64url-encoded signature." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U`" + NL +
		"- Non-matches: `abc.def`, `header.payload`"
	],
	
	:uuid = [
		"Matches UUID/GUID format",
	
		"- `^`: Start of string." + NL +
		"- `[0-9a-fA-F]{8}`: First 8 hexadecimal characters." + NL +
		"- `-`: Hyphen separator." + NL +
		"- `[0-9a-fA-F]{4}`: 4 hex characters (repeated 3 times)." + NL +
		"- `-`: Hyphen separator." + NL +
		"- `[0-9a-fA-F]{12}`: Final 12 hex characters." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `123e4567-e89b-12d3-a456-426614174000`" + NL +
		"- Non-matches: `123456-789-123-456`, `not-a-uuid`"
	],

:base64 = [
    "Matches strings encoded in Base64 format.",
    
    "- `^(?:[A-Za-z0-9+/]{4})*`: Matches groups of four Base64 characters (letters, digits, `+`, or `/`)." + NL +
    "- `(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$`: Allows padding with `=` for the last group." + NL +
    "- Matches: `TWFu`, `TWE=`, `TQ==`, `YWJjZA==`." + NL +
    "- Non-matches: `T@W==`, `123`, `ABCD==`."
],

:emoji = [
    "Matches strings composed entirely of emoji characters.",
    
    "- `^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$`: Matches one or more Unicode emoji characters." + NL +
    "- Matches: `😊`, `🎉🎈`, `👩‍🚀🚀`." + NL +
    "- Non-matches: `😊abc`, `123🎉`, `😀_😊`."
],
	
	# API & Request Validation
	
	:apiKey = [
		"Matches API key formats",
	
		"- `^`: Start of string." + NL +
		"- `[A-Za-z0-9_-]{20,}`: At least 20 characters of letters, numbers, underscores, or hyphens." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `abcd1234_xyz-987654321`, `api_key_123456789abcdefghijk`" + NL +
		"- Non-matches: `short_key`, `invalid#key`, `api@key`"
	],
	
	:bearerToken = [
		"Matches Bearer authentication tokens",
	
		"- `^`: Start of string." + NL +
		"- `Bearer\\s+`: 'Bearer' keyword followed by whitespace." + NL +
		"- `[A-Za-z0-9\\-._~+/]+=*`: Base64 URL-safe characters with optional padding." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `Bearer abc123xyz789`, `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`" + NL +
		"- Non-matches: `bearer token`, `Bearer`, `BearerToken123`"
	],
	
	:queryParam = [
		"Matches valid URL query parameter names",
	
		"- `^`: Start of string." + NL +
		"- `[\\w\\-%\\.]+`: One or more word characters, percent signs, or dots." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `page`, `sort-by`, `filter.name`" + NL +
		"- Non-matches: `@param`, `query space`, `param#1`"
	],
	
	:httpMethod = [
		"Matches valid HTTP methods",
	
		"- `^`: Start of string." + NL +
		"- `(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)`: Valid HTTP methods." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `GET`, `POST`, `PUT`" + NL +
		"- Non-matches: `get`, `SEND`, `RETRIEVE`"
	],

:contentType = [
    "Matches HTTP Content-Type headers with optional charset specifications.",
    
    "- `^[\\w\\-\\.\\/]+`: Matches the primary type and subtype (e.g., `application/json`)." + NL +
    "- `(?:\\+[\\w\\-\\.\\/]+)?`: Optionally matches suffix types (e.g., `application/ld+json`)." + NL +
    "- `(?:;\\s*charset=[\\w\\-]+)?$`: Optionally matches charset parameters (e.g., `charset=utf-8`)." + NL +
    "- Matches: `application/json`, `text/html; charset=utf-8`, `application/ld+json`." + NL +
    "- Non-matches: `application`, `text; utf-8`, `image/jpg; charset`."
],

:requestId = [
    "Matches request IDs with a minimum length of 4 characters.",
    
    "- `^[\\w\\-]{4,}$`: Ensures alphanumeric characters, underscores, or hyphens with a minimum length of 4." + NL +
    "- Matches: `abc1`, `1234-5678`, `req_abc`." + NL +
    "- Non-matches: `abc`, `12`, `req!123`."
],

:corsOrigin = [
    "Matches valid CORS origin URLs with optional port numbers.",
    
    "- `^https?://`: Matches URLs starting with `http://` or `https://`." + NL +
    "- `(?:[\\w-]+\\.)+[\\w-]+`: Matches domain names with optional subdomains." + NL +
    "- `(?::\\d{1,5})?$`: Optionally matches port numbers (e.g., `:8080`)." + NL +
    "- Matches: `https://example.com`, `http://sub.example.com:3000`." + NL +
    "- Non-matches: `ftp://example.com`, `http://example`, `https://.com`."
],

#-----------------------------------
	# Data Cleaning
	
	:alphanumeric = [
		"Matches strings containing only letters and numbers",
	
		"- `^`: Start of string." + NL +
		"- `[a-zA-Z0-9]+`: One or more letters or numbers." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `ABC123`, `Test999`, `123abc`" + NL +
		"- Non-matches: `ABC-123`, `Test_999`, `Special!`"
	],

:alphabetic = [
    "Matches strings containing only alphabetic characters (A-Z, a-z).",
    
    "- `^[a-zA-Z]+$`: Ensures the string contains only uppercase and lowercase letters with no spaces or symbols." + NL +
    "- Matches: `Hello`, `abcXYZ`, `Data`." + NL +
    "- Non-matches: `Hello123`, `Data!`, `Hello World`."
],

:numeric = [
    "Matches strings containing only numeric digits (0-9).",
    
    "- `^[0-9]+$`: Ensures the string consists solely of digits." + NL +
    "- Matches: `12345`, `007`, `2023`." + NL +
    "- Non-matches: `12.34`, `123abc`, `1 2 3`."
],

:spaces = [
    "Matches sequences of whitespace characters (spaces, tabs, newlines, and carriage returns).",
    
    "- `[ \\t\\r\\n]+`: Matches one or more spaces, tabs (`\\t`), carriage returns (`\\r`), or newlines (`\\n`)." + NL +
    "- Matches: ` `, `\t\t`, ` \n \t`." + NL +
    "- Non-matches: `abc`, `123`, `a b` (does not match non-whitespace characters)."
],

:trim = [
    "Matches leading and trailing whitespace in a string.",
    
    "- `^\\s+`: Matches leading whitespace at the beginning of the string." + NL +
    "- `|\\s+$`: Matches trailing whitespace at the end of the string." + NL +
    "- Matches: Leading/trailing spaces in `  Hello `, `\tWorld\n `." + NL +
    "- Non-matches: `NoSpacesHere`, `A B` (internal spaces are not matched)."
],

:nonPrintable = [
    "Matches non-printable ASCII characters.",
    
    "- `[\\x00-\\x1F\\x7F-\\x9F]`: Matches ASCII control characters (0x00–0x1F) and additional non-printable characters (0x7F–0x9F)." + NL +
    "- Matches: `\x00` (null), `\x1B` (escape), `\x7F` (delete)." + NL +
    "- Non-matches: `abc`, `123`, `@#$` (printable characters are not matched)."
],

	:multipleSpaces = [
		"Matches sequences of two or more whitespace characters",
	
		"- `{2,}`: Two or more occurrences of the previous pattern." + NL +
		"- Matches: `  `, `   `, multiple spaces/tabs." + NL +
		"- Non-matches: ` ` (single space)"
	],

	# JSON Patterns
	
	:jsonObject = [
		"Matches JSON object structures",
	
		"- `\\{`: Opening brace." + NL +
		"- `(?:\\s*\\\ " + NL + char(34) + NL + "[a-zA-Z0-9_]+\\\ " + NL + char(34) + NL + "\\s*:\\s*`: Key part with quotes and colon." + NL +
		"- `(?:\\\ " + NL + char(34) + NL + "[^\\\ " + NL + char(34) + NL + "]*\\\ " + NL + char(34) + NL + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*`: Various value types." + NL +
		"- `\\s*\\}`: Closing brace with optional whitespace." + NL +
		"- Matches: `{\ " + NL + char(34) + NL + "name\ " + NL + char(34) + NL + ":\ " + NL + char(34) + NL + "value\ " + NL + char(34) + NL + "}`, `{\ " + NL + char(34) + NL + "age\ " + NL + char(34) + NL + ":25}`" + NL +
		"- Non-matches: `{name:value}`, `{\ " + NL + char(34) + NL + "key\ " + NL + char(34) + NL + ":}`, `{\ " + NL + char(34) + NL + "key\ " + NL + char(34) + NL + "}`"
	],
	
	:jsonArray = [
		"Matches JSON array structures",
	
		"- `^`: Start of string." + NL +
		"- `\\[`: Opening bracket." + NL +
		"- `(?:\\s*[^,]+,?\\s*)*`: Array elements separated by commas." + NL +
		"- `\\]`: Closing bracket." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `[1,2,3]`, `[\ " + NL + char(34) + NL + "a\ " + NL + char(34) + NL + ",\ " + NL + char(34) + NL + "b\ " + NL + char(34) + NL + ",\ " + NL + char(34) + NL + "c\ " + NL + char(34) + NL + "]`" + NL +
		"- Non-matches: `[1,2,]`, `[,]`, `[1,,2]`"
	],


:jsonKeyValuePair = [
    "Matches a key-value pair in JSON format.",

    "- `\" + char(34) + "[a-zA-Z0-9_]+\" + char(34) + "`: Matches a JSON key enclosed in double quotes, consisting of alphanumeric characters and underscores." + NL +
    "- `\\s*:\\s*`: Matches the colon `:` separator with optional spaces around it." + NL +
    "- `(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])`: Matches the value, which can be:" + NL +
    "  - A double-quoted string." + NL +
    "  - A single-quoted string." + NL +
    "  - A number (e.g., `123`)." + NL +
    "  - A boolean (`true` or `false`)." + NL +
    "  - `null`." + NL +
    "  - A JSON object (`{}`) or array (`[]`)." + NL +
    "- Matches: `\" + char(34) + "name\" + char(34) + ":\" + char(34) + "John\" + char(34) + "`, `\" + char(34) + "age\" + char(34) + ":30`, `\" + char(34) + "active\" + char(34) + ":true`, `\" + char(34) + "address\" + char(34) + ":{\" + char(34) + "city\" + char(34) + ":\" + char(34) + "Paris\" + char(34) + "}`." + NL +
    "- Non-matches: `name:John`, `\" + char(34) + "key\" + char(34) + ":`, `\" + char(34) + "invalid\" + char(34) + "\" + char(34) + "value\" + char(34) + "`."
],

:geoJSON = [
    "Matches a valid GeoJSON FeatureCollection object.",
    
    "- `^\\{\\s*\" + char(34) + "type\" + char(34) + "\\s*:\\s*\" + char(34) + "FeatureCollection\" + char(34) + "`: Matches the opening of a GeoJSON object with the type `FeatureCollection`." + NL +
    "- `\\s*,\\s*\" + char(34) + "features\" + char(34) + "\\s*:\\s*\\[.*?\\]`: Matches the `features` property containing an array of features." + NL +
    "- `\\s*\\}$`: Matches the closing brace of the GeoJSON object." + NL +
    "- Matches: `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [] }`, `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [{\" + char(34) + "type\" + char(34) + ":\" + char(34) + "Feature\" + char(34) + "}] }`." + NL +
    "- Non-matches: `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "Feature\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [] }`, `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + " }`."
],

	# CSV Patterns

	:csvHeaderRow = [
		"Matches CSV header rows",
	
		"- `^`: Start of string." + NL +
		"- `([^,]*,)*`: Zero or more non-comma characters followed by comma." + NL +
		"- `[^,]*`: Final field without comma." + NL +
		"- `$`: End of string." + NL +
		"- Matches: `name,age,email`, `first,last,address`" + NL +
		"- Non-matches: `name,,age`, `,name,age`"
	],
	
:csvQuotedField = [
    "Matches a quoted field in a CSV file.",
    
    "- `\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "`: Matches any text enclosed within double quotes." + NL +
    "- Matches: `\" + char(34) + "hello\" + char(34) + "`, `\" + char(34) + "123\" + char(34) + "`, `\" + char(34) + "a,b,c\" + char(34) + "`." + NL +
    "- Non-matches: `hello`, `\" + char(34) + "hello` (unclosed quote)."
],

:csvUnquotedField = [
    "Matches an unquoted field in a CSV file.",
    
    "- `[^,\\r\\n]*`: Matches any sequence of characters that does not include a comma, carriage return, or newline." + NL +
    "- Matches: `hello`, `123`, `a b c`." + NL +
    "- Non-matches: `hello,world`, `line1\\nline2`."
],

:csvDelimiter = [
    "Matches a comma as the field delimiter in a CSV file.",
    
    "- `,`: Matches a single comma." + NL +
    "- Matches: `,` in `hello,world`." + NL +
    "- Non-matches: `;`, `\\t`."
],

:csvRowEnding = [
    "Matches the end of a row in a CSV file.",
    
    "- `\\r?`: Matches an optional carriage return (\\r) at the end of a row." + NL +
    "- Matches: `\\r`, `\\n`, or an empty string at the end of a row." + NL +
    "- Non-matches: `\\r\\n` (without \\n)."
],

:csvEscapedQuote = [
    "Matches escaped double quotes within a quoted CSV field.",
    
    "- `\" + char(34) + "\" + char(34) + "`: Matches two consecutive double quotes inside a quoted field." + NL +
    "- Matches: `\" + char(34) + "hello\" + char(34) + "\" + char(34) + "world\" + char(34) + "` (represents `hello\" + char(34) + "world`)." + NL +
    "- Non-matches: `\" + char(34) + "hello\" + char(34) + "world\" + char(34) + "` (no double quotes to escape)."
],

:csvLine = [
    "Matches an entire line of CSV data.",
    
    "- `^(?:(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")|(?:[^,\\\" + char(34) + "]+))`: Matches the first field, which can be quoted or unquoted." + NL +
    "- `(?:,(?:(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")|(?:[^,\\\" + char(34) + "]+)))*`: Matches subsequent fields separated by commas, which can also be quoted or unquoted." + NL +
    "- Matches: `\" + char(34) + "field1\" + char(34) + ",\" + char(34) + "field2\" + char(34) + "`, `field1,field2`, `\" + char(34) + "field,1\" + char(34) + ",field2`." + NL +
    "- Non-matches: `field1,field2,` (trailing comma), `field1 field2` (no delimiter)."
],

:sqlSelectStatement = [
    "Matches SQL SELECT statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `SELECT\\s+`: Matches the SELECT keyword followed by whitespace." + NL +
    "- `.+?\\s+`: Matches selected columns or expressions followed by whitespace." + NL +
    "- `FROM\\s+`: Matches the FROM keyword followed by whitespace." + NL +
    "- `.+?`: Matches table or subquery names." + NL +
    "- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `SELECT * FROM table`, `SELECT name, age FROM users WHERE age > 30`." + NL +
    "- Non-matches: `SELCT *`, `SELECT FROM table`."
],

:sqlInsertStatement = [
    "Matches SQL INSERT statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `INSERT\\s+INTO\\s+`: Matches the INSERT INTO keywords followed by whitespace." + NL +
    "- `.+?\\s+`: Matches the table name followed by whitespace." + NL +
    "- `\\(.+?\\)\\s+`: Matches column names in parentheses followed by whitespace." + NL +
    "- `VALUES\\s+\\(.+?\\)`: Matches the VALUES keyword and a list of values in parentheses." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `INSERT INTO table (id, name) VALUES (1, 'John')`." + NL +
    "- Non-matches: `INSERT table VALUES (1, 'John')`."
],

:sqlUpdateStatement = [
    "Matches SQL UPDATE statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `UPDATE\\s+`: Matches the UPDATE keyword followed by whitespace." + NL +
    "- `.+?\\s+SET\\s+`: Matches the table name and SET keyword followed by whitespace." + NL +
    "- `.+?`: Matches column-value assignments." + NL +
    "- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `UPDATE table SET name='John' WHERE id=1`." + NL +
    "- Non-matches: `UPDATE SET name='John'`."
],

:sqlDeleteStatement = [
    "Matches SQL DELETE statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `DELETE\\s+FROM\\s+`: Matches the DELETE FROM keywords followed by whitespace." + NL +
    "- `.+?`: Matches the table name." + NL +
    "- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `DELETE FROM users WHERE id=1`." + NL +
    "- Non-matches: `DELETE WHERE id=1`, `DELETE FROM`."
],

:sqlCreateTable = [
    "Matches SQL CREATE TABLE statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `CREATE\\s+TABLE\\s+`: Matches the CREATE TABLE keywords followed by whitespace." + NL +
    "- `[\\w]+\\s*\\(.+?\\)`: Matches the table name followed by column definitions in parentheses." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `CREATE TABLE users (id INT, name VARCHAR(100))`." + NL +
    "- Non-matches: `CREATE users`, `TABLE users (id INT)`."
],

:sqlDropTable = [
    "Matches SQL DROP TABLE statements",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `DROP\\s+TABLE\\s+`: Matches the DROP TABLE keywords followed by whitespace." + NL +
    "- `[\\w]+`: Matches the table name." + NL +
    "- `$`: End of line." + NL +
    "- Matches: `DROP TABLE users`." + NL +
    "- Non-matches: `DROP users`, `TABLE DROP users`."
],

:sqlIdentifier = [
    "Matches valid SQL identifiers",

    "- `^[a-zA-Z_][a-zA-Z0-9_]*$`: Matches an identifier starting with a letter or underscore, followed by alphanumeric characters or underscores." + NL +
    "- Matches: `table1`, `_column`, `userName`." + NL +
    "- Non-matches: `1table`, `column-name`, `user.name`."
],

:sqlValue = [
    "Matches SQL values",

    "- `^('(?:[^']|''|\\\\')*'|\\d+|NULL)$`: Matches a single-quoted string, a number, or the NULL keyword." + NL +
    "- Matches: `'John'`, `123`, `NULL`." + NL +
    "- Non-matches: `John`, `''`, `12a`."
],

:sqlOperator = [
    "Matches SQL comparison operators",

    "- `^(=|<>|!=|<|<=|>|>=|LIKE|IN|IS|BETWEEN)$`: Matches valid SQL operators for comparison." + NL +
    "- Matches: `=`, `<>`, `LIKE`, `BETWEEN`." + NL +
    "- Non-matches: `AND`, `OR`, `==`."
],

:sqlJoinClause = [
    "Matches SQL JOIN clauses",

    "- `^\\s*JOIN\\s+`: Matches the JOIN keyword followed by whitespace." + NL +
    "- `.+?\\s+ON\\s+.+?$`: Matches the table being joined and the ON condition." + NL +
    "- Matches: `JOIN orders ON users.id = orders.user_id`." + NL +
    "- Non-matches: `JOIN orders`, `ON users.id = orders.user_id`."
],

	# Regexes for Potential Security Concerns
	
	:sqlInjection = [
		"Detects potential SQL injection patterns",
	
		"- `(?:[\\\ " + NL + char(34) + NL + "';]+.*?)+`: Sequences of quotes or semicolons with following content." + NL +
		"- Matches: `'; DROP TABLE users;--`, `\ " + NL + char(34) + NL + " OR \ " + NL + char(34) + NL + "1\ " + NL + char(34) + NL + "=\ " + NL + char(34) + NL + "1`" + NL +
		"- Non-matches: `normal text`, `user@example.com`" + NL +
		"- Note: This is a basic detection pattern and should be used with other security measures"
	],
	
	:xssInjection = [
		"Detects potential XSS patterns",
	
		"- `<`: Opening angle bracket." + NL +
		"- `[a-zA-Z][a-zA-Z0-9]*`: HTML tag name." + NL +
		"- `[^>]*>`: Tag attributes and closing." + NL +
		"- `.*?`: Content." + NL +
		"- `</[a-zA-Z][a-zA-Z0-9]*>`: Closing tag." + NL +
		"- Matches: `<script>alert('xss')</script>`, `<img src=x onerror=alert(1)>`" + NL +
		"- Non-matches: `<plaintext>`, `normaltext`" + NL +
		"- Note: This is a basic detection pattern and should be used with other security measures"
	],

:emailInjection = [
    "Matches potential email injection attempts in form inputs.",
    
    "- `.*[\\n\\r]+.+@[a-z0-9]+[.][a-z]{2,}.*`: Matches strings containing newline or carriage return characters, followed by an email-like pattern." + NL +
    "- Components:" + NL +
    "  - `.*`: Matches any characters before the injection." + NL +
    "  - `[\\n\\r]+`: Matches one or more newline (`\\n`) or carriage return (`\\r`) characters." + NL +
    "  - `.+@[a-z0-9]+[.][a-z]{2,}`: Matches a basic email address format." + NL +
    "  - `.*`: Matches any characters after the injection." + NL +
    "- Matches: `hello\\nabc@example.com`, `abc\\r\\ndef@domain.com`." + NL +
    "- Non-matches: `hello@example.com` (no newline characters)."
],

:htmlInjection = [
    "Matches potential HTML injection attempts in form inputs.",
    
    "- `<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>`: Matches strings containing HTML-like tags with potential content inside." + NL +
    "- Components:" + NL +
    "  - `<`: Matches the opening angle bracket of an HTML tag." + NL +
    "  - `[^>]*?`: Matches zero or more characters that are not the closing angle bracket, non-greedily." + NL +
    "  - `[^<]*[a-zA-Z0-9]+`: Ensures the tag contains at least one alphanumeric character." + NL +
    "  - `.*`: Matches any additional content inside the tag." + NL +
    "  - `[^<]*?>`: Matches zero or more characters until the closing angle bracket." + NL +
    "- Matches: `<script>alert('XSS')</script>`, `<div>content</div>`." + NL +
    "- Non-matches: `content`, `< >`, `<tag>` (without meaningful content)."
],


	# Ring Language Patterns
	
	:ringString = [
		"Matches Ring string assignments and declarations",
	
		"- `^=?`: Optional assignment operator at start." + NL +
		"- `*`: Optional whitespace." + NL +
		"- `([ " + char(34) + "'].*?[ " + char(34) + "']|[^ ]+)`: Quoted string or word." + NL +
		"- `*$`: Optional whitespace at end." +
		"- Matches: `name = " + char(34) + "John" + char(34) + "`, `str = 'Hello'`" + NL +
		"- Non-matches: `name = `, `= " + char(34) + "unclosed`"
	],

    :ringNumber = [
        "Matches Ring numeric literals",
        
        "- `^`: Start of line." + NL +
        "- `-?`: Optional minus sign." + NL +
        "- `\\d+`: One or more digits." + NL +
        "- `(?:\\.\\d+)?`: Optional decimal part." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `42`, `-17`, `3.14`, `-0.001`" + NL +
        "- Non-matches: `.5`, `1.`, `1e5`"
    ],

    :ringBoolean = [
        "Matches Ring boolean literals",
        
        "- `^`: Start of line." + NL +
        "- `(?:True|False)`: Either 'True' or 'False'." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `True`, `False`" + NL +
        "- Non-matches: `true`, `false`, `TRUE`"
    ],

    :ringVariable = [
        "Matches Ring variable names",
        
        "- `^`: Start of line." + NL +
        "- `[a-zA-Z_]`: First character must be letter or underscore." + NL +
        "- `\\w*`: Following characters can be letters, numbers, or underscores." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `name`, `_count`, `myVar123`" + NL +
        "- Non-matches: `123var`, `my-var`, `$var`"
    ],

	:ringFunction = [
		"Matches Ring function declarations",
	
		"- `^func`: Function declaration keyword." + NL +
		"- `(\w+)`: Function name." + NL +
		"- `\s*\((.*?)\)`: Parameters in parentheses." + NL +
		"- Matches: `func sum(x, y)`, `func hello()`" + NL +
		"- Non-matches: `function test()`, `func()`"
	],

    :ringFunctionCall = [
        "Matches Ring function calls",
        
        "- `^`: Start of line." + NL +
        "- `([a-zA-Z_]\\w*)`: Function name." + NL +
        "- `\\s*\\(`: Opening parenthesis with optional whitespace." + NL +
        "- `(.*?)`: Function arguments." + NL +
        "- `\\)`: Closing parenthesis." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `print()`, `calculate(x,y)`, `func(1,2,3)`" + NL +
        "- Non-matches: `1func()`, `func(`, `func`"
    ],

    :ringMainFunction = [
        "Matches Ring main function declaration",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Func\\s+Main\\s*`: 'Func Main' declaration." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Func Main`, `FUNC MAIN`, `func main`" + NL +
        "- Non-matches: `Func main()`, `Function Main`, `Main`"
    ],

    :ringClass = [
        "Matches Ring class declarations",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Class\\s+`: 'Class' keyword and whitespace." + NL +
        "- `([a-zA-Z_]\\w*)`: Class name." + NL +
        "- `\\s*`: Optional whitespace." + NL +
        "- `(?:from\\s+([a-zA-Z_]\\w*))?`: Optional inheritance." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Class Animal`, `Class Dog from Animal`" + NL +
        "- Non-matches: `class animal`, `Class 1Dog`, `Class Dog from`"
    ],

    :ringClassAttribute = [
        "Matches Ring class attribute declarations",
        
        "- `^`: Start of line." + NL +
        "- `[a-zA-Z_]\\w*`: Attribute name." + NL +
        "- `\\s*=\\s*`: Assignment operator." + NL +
        "- `.*`: Attribute value." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `name = value`, `count = 0`, `items = []`" + NL +
        "- Non-matches: `1var = 2`, `= value`, `name =`"
    ],

    :ringNewObject = [
        "Matches Ring object instantiation",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `New\\s+`: 'New' keyword." + NL +
        "- `([a-zA-Z_]\\w*)`: Class name." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `New Person`, `new Calculator`, `NEW Object`" + NL +
        "- Non-matches: `New`, `New 1Class`, `New()`"
    ],

    :ringObjectAccess = [
        "Matches Ring object access expressions",
        
        "- `^`: Start of line." + NL +
        "- `([a-zA-Z_]\\w*)`: Object name." + NL +
        "- `\\s*{\\s*`: Opening brace with optional whitespace." + NL +
        "- `(.*?)`: Member access expression." + NL +
        "- `\\s*}`: Closing brace with optional whitespace." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `obj{method()}`, `list{item}`, `object{property}`" + NL +
        "- Non-matches: `obj{}`, `{prop}`, `obj{`"
    ],

    :ringLoop = [
        "Matches Ring loop constructs",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `(?:`: Non-capturing group for alternatives:" + NL +
        "  - `for\\s+\\w+\\s*=\\s*\\d+\\s+to\\s+\\d+`: Numeric for loop" + NL +
        "  - `|while\\s+.*`: While loop" + NL +
        "  - `|for\\s+\\w+\\s+in\\s+.*?)`: For-in loop" + NL +
        "- `$`: End of line." + NL +
        "- Matches: `for x = 1 to 10`, `while count > 0`, `for item in list`" + NL +
        "- Non-matches: `for`, `while`, `for x in`"
    ],

    :ringIf = [
        "Matches Ring if statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `if\\s+`: 'if' keyword." + NL +
        "- `.*`: Condition." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `if x > 0`, `IF true`, `if isValid()`" + NL +
        "- Non-matches: `if`, `ifelse`, `if()`"
    ],

    :ringSwitch = [
        "Matches Ring switch statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `switch\\s+`: 'switch' keyword." + NL +
        "- `.*`: Switch expression." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `switch x`, `SWITCH value`, `switch expr()`" + NL +
        "- Non-matches: `switch`, `case x`, `switch()`"
    ],

    :ringCase = [
        "Matches Ring switch case statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `(?:on|off)`: 'on' or 'off' keyword." + NL +
        "- `\\s+`: Required whitespace." + NL +
        "- `.*`: Case value." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `on 1`, `OFF " + char(34) + "text" + char(34) + "`, `on value`" + NL +
        "- Non-matches: `on`, `case 1`, `on()`"
    ],

    :ringList = [
        "Matches Ring list literals",
        
        "- `^`: Start of line." + NL +
        "- `\\[`: Opening bracket." + NL +
        "- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists." + NL +
        "- `\\]`: Closing bracket." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + NL +
        "- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
    ],

    :ringListAccess = [
        "Matches Ring list element access",
        
        "- `^`: Start of line." + NL +
        "- `([a-zA-Z_]\\w*)`: List variable name." + NL +
        "- `\\s*\\[`: Opening bracket." + NL +
        "- `(\\d+|\\w+)`: Numeric or variable index." + NL +
        "- `\\s*\\]`: Closing bracket." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `list[1]`, `array[i]`, `items[index]`" + NL +
        "- Non-matches: `list[]`, `[1]`, `list[1`"
    ],

    :ringHashTable = [
        "Matches Ring hash table literals",
        
        "- `^`: Start of line." + NL +
        "- `\\[\\s*:`: Opening bracket and colon." + NL +
        "- `(?:\\w+\\s*=\\s*[^,\\]]+\\s*,?\\s*)+`: Key-value pairs." + NL +
        "- `\\]`: Closing bracket." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `[:name=" + char(34) + "John" + char(34) + ",age=30]`, `[:key=value]`" + NL +
        "- Non-matches: `[]`, `[:invalid]`, `[:key=]`"
    ],

    :ringComment = [
        "Matches Ring comments",
        
        "- `^`: Start of line." + NL +
        "- `(?:`: Non-capturing group for alternatives:" + NL +
        "  - `#.*`: Single-line hash comment" + NL +
        "  - `//.*`: Single-line double-slash comment" + NL +
        "  - `/\\*[\\s\\S]*?\\*/`: Multi-line comment" + NL +
        "- `$`: End of line." + NL +
        "- Matches: `# comment`, `// note`, `/* multi line */`" + NL +
        "- Non-matches: `/comment`, `/*unclosed`, `#`"
    ],

    :ringSee = [
        "Matches Ring See statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `See\\s+`: 'See' keyword." + NL +
        "- `(?:[" + char(34) + "'].*?[" + char(34) + "']|\\w+)`: String literal or variable." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `See " + char(34) + "Hello" + char(34) + "`, `SEE x`, `see 'text'`" + NL +
        "- Non-matches: `See`, `See()`, `See,`"
    ],

    :ringGive = [
        "Matches Ring Give statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Give\\s+`: 'Give' keyword." + NL +
        "- `\\w+`: Variable name." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Give x`, `GIVE input`, `give variable`" + NL +
        "- Non-matches: `Give`, `Give 1`, `Give()`"
    ],

    :ringLoad = [
        "Matches Ring Load statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Load\\s+`: 'Load' keyword." + NL +
        "- `[" + char(34) + "'].*?[" + char(34) + "']`: Quoted filename." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Load " + char(34) + "file.ring" + char(34) + "`, `LOAD 'module.ring'`" + NL +
        "- Non-matches: `Load`, `Load file`, `Load()`"
    ],

    :ringImport = [
        "Matches Ring Import statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Import\\s+`: 'Import' keyword." + NL +
        "- `[\\w.]+`: Module path." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Import module`, `IMPORT system.lib`, `import std.core`" + NL +
        "- Non-matches: `Import`, `Import.`, `Import()`"
    ],


    :ringOperator = [
        "Matches Ring operators",
        
        "- `^`: Start of line." + NL +
        "- `(?:`: Non-capturing group for alternatives:" + NL +
        "  - `[+\\-*/=%]`: Arithmetic operators" + NL +
        "  - `|==|!=|>=|<=|>|<`: Comparison operators" + NL +
        "  - `|\\+=|-=|\\*=|/=`: Assignment operators" + NL +
        "- `$`: End of line." + NL +
        "- Matches: `+`, `==`, `<=`, `+=`" + NL +
        "- Non-matches: `++`, `=!`, `=>`"
    ],

    :ringLogical = [
        "Matches Ring logical operators",
        
        "- `^`: Start of line." + NL +
        "- `(?:and|or|not)`: Logical operators." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `and`, `or`, `not`" + NL +
        "- Non-matches: `AND`, `Or`, `Not`"
    ],

    :ringExit = [
        "Matches Ring Exit statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `exit`: 'Exit' keyword." + NL +
        "- `(?:\\s+\\d+)?`: Optional exit code." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `exit`, `EXIT 0`, `exit 1`" + NL +
        "- Non-matches: `exit()`, `exit code`, `exit -1`"
    ],

    :ringReturn = [
        "Matches Ring Return statements",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `return`: 'Return' keyword." + NL +
        "- `(?:\\s+.*)?`: Optional return value." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `return`, `RETURN value`, `return 42`" + NL +
        "- Non-matches: `return()`, `return,`, `returns`"
    ],

    :ringPackage = [
        "Matches Ring Package declarations",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Package\\s+`: 'Package' keyword." + NL +
        "- `[\\w.]+`: Package name." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Package myapp`, `PACKAGE system.core`, `package lib.util`" + NL +
        "- Non-matches: `Package`, `Package.`, `Package()`"
    ],

    :ringPrivate = [
        "Matches Ring Private declarations",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Private`: 'Private' keyword." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Private`, `PRIVATE`, `private`" + NL +
        "- Non-matches: `Private()`, `Privates`, `Private var`"
    ],

    :ringBraceEnd = [
        "Matches Ring BraceEnd function declarations",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `func\\s+braceEnd`: 'func braceEnd' declaration." + NL +
        "- `\\s*`: Optional whitespace." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `func braceEnd`, `FUNC BRACEEND`, `Func BraceEnd`" + NL +
        "- Non-matches: `braceEnd`, `func braceEnd()`, `function braceEnd`"
    ],

    :ringEval = [
        "Matches Ring Eval function calls",
        
        "- `^`: Start of line." + NL +
        "- `(?i)`: Case-insensitive matching." + NL +
        "- `Eval\\s*`: 'Eval' keyword." + NL +
        "- `\\(.*?\\)`: Parentheses with expression." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `Eval(1+1)`, `EVAL(x)`, `eval(expression())`" + NL +
        "- Non-matches: `Eval`, `Eval x`, `Evaluate()`"
    ],

	# Python Language Patterns

    :pythonString = [
        "Matches Python string literals",
        
        "- `^`: Start of line." + NL +
        "- `(?:`: Non-capturing group for alternatives:" + NL +
        "  - `[" + char(34) + "]{3}.*?[" + char(34) + "]{3}`: Triple double-quoted strings" + NL +
        "  - `|[" + char(34) + "].*?[" + char(34) + "]`: Double-quoted strings" + NL +
        "  - `|'''.*?'''`: Triple single-quoted strings" + NL +
        "  - `|'.*?'`: Single-quoted strings" + NL +
        "- `$`: End of line." + NL +
        "- Matches: `" + char(34) + "hello" + char(34) + "`, `'world'`, `" + char(34) + char(34) + char(34) + "multiline" + char(34) + char(34) + char(34) + "`, `'''text'''`" + NL +
        "- Non-matches: `" + char(34) + "unclosed`, `''''extra'''`"
    ],

    :pythonNumber = [
        "Matches Python numeric literals",
        
        "- `^`: Start of line." + NL +
        "- `-?`: Optional minus sign." + NL +
        "- `\\d+`: One or more digits." + NL +
        "- `(?:\\.\\d+)?`: Optional decimal part." + NL +
        "- `(?:e[+-]?\\d+)?`: Optional scientific notation." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `42`, `-17`, `3.14`, `1e-10`" + NL +
        "- Non-matches: `.5`, `1.`, `e5`"
    ],

    :pythonBoolean = [
        "Matches Python boolean and None literals",
        
        "- `^`: Start of line." + NL +
        "- `(?:True|False|None)`: Either 'True', 'False', or 'None'." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `True`, `False`, `None`" + NL +
        "- Non-matches: `true`, `false`, `none`, `NULL`"
    ],

    :pythonVariable = [
        "Matches Python variable names",
        
        "- `^`: Start of line." + NL +
        "- `[a-zA-Z_]`: First character must be letter or underscore." + NL +
        "- `\\w*`: Following characters can be letters, numbers, or underscores." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `name`, `_count`, `myVar123`" + NL +
        "- Non-matches: `123var`, `my-var`, `$var`"
    ],

    :pythonFunction = [
        "Matches Python function definitions",
        
        "- `^`: Start of line." + NL +
        "- `def\\s+`: 'def' keyword and whitespace." + NL +
        "- `([a-zA-Z_]\\w*)`: Function name." + NL +
        "- `\\s*\\((.*?)\\)`: Parameter list in parentheses." + NL +
        "- `(?:\\s*->\\s*[\\w\\[\\],\\s]+)?`: Optional return type annotation." + NL +
        "- `:`: Function block start." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `def test():`, `def calc(x, y) -> int:`, `def _init():`" + NL +
        "- Non-matches: `def test`, `def 1func():`, `def()`"
    ],

    :pythonFunctionCall = [
        "Matches Python function calls",
        
        "- `^`: Start of line." + NL +
        "- `([a-zA-Z_]\\w*)`: Function name." + NL +
        "- `\\s*\\((.*?)\\)`: Function arguments in parentheses." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `print()`, `calculate(x, y)`, `func(1, 2, 3)`" + NL +
        "- Non-matches: `1func()`, `func(`, `func`"
    ],

    :pythonLambda = [
        "Matches Python lambda expressions",
        
        "- `^`: Start of line." + NL +
        "- `lambda\\s+`: 'lambda' keyword and whitespace." + NL +
        "- `.*?`: Lambda parameters." + NL +
        "- `:\\s*`: Colon and optional whitespace." + NL +
        "- `.*`: Lambda body." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `lambda x: x*2`, `lambda: True`, `lambda a, b: a+b`" + NL +
        "- Non-matches: `lambda`, `lambda:`, `lambda x`"
    ],

    :pythonClass = [
        "Matches Python class definitions",
        
        "- `^`: Start of line." + NL +
        "- `class\\s+`: 'class' keyword and whitespace." + NL +
        "- `([a-zA-Z_]\\w*)`: Class name." + NL +
        "- `(?:\\((.*?)\\))?`: Optional parent classes." + NL +
        "- `:`: Class block start." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `class Test:`, `class Child(Parent):`, `class MyClass(A, B):`" + NL +
        "- Non-matches: `class Test`, `class 1Test:`, `class:`"
    ],

    :pythonClassMethod = [
        "Matches Python method decorators",
        
        "- `^`: Start of line." + NL +
        "- `@`: Decorator symbol." + NL +
        "- `\\w+`: Decorator name." + NL +
        "- `\\s*`: Optional whitespace." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `@classmethod`, `@staticmethod`, `@property`" + NL +
        "- Non-matches: `@`, `@1method`, `@class method`"
    ],

    :pythonDecorator = [
        "Matches Python decorators",
        
        "- `^`: Start of line." + NL +
        "- `@`: Decorator symbol." + NL +
        "- `[a-zA-Z_]\\w*`: Decorator name." + NL +
        "- `(?:\\((.*?)\\))?`: Optional decorator arguments." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `@decorator`, `@wrap(arg)`, `@auth(user='admin')`" + NL +
        "- Non-matches: `@`, `@1dec`, `@dec(`"
    ],

    :pythonLoop = [
        "Matches Python loop statements",
        
        "- `^`: Start of line." + NL +
        "- `(?:`: Non-capturing group for alternatives:" + NL +
        "  - `for\\s+.*?\\s+in\\s+.*?:`: For loop" + NL +
        "  - `|while\\s+.*?:`: While loop" + NL +
        "- `$`: End of line." + NL +
        "- Matches: `for i in range(10):`, `while True:`, `for x in list:`" + NL +
        "- Non-matches: `for`, `while`, `for in:`"
    ],

    :pythonIf = [
        "Matches Python conditional statements",
        
        "- `^`: Start of line." + NL +
        "- `(?:if|elif|else)`: Conditional keywords." + NL +
        "- `\\s*.*?:`: Condition and colon." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `if x > 0:`, `elif x < 0:`, `else:`" + NL +
        "- Non-matches: `if:`, `else if:`, `if x`"
    ],

    :pythonWith = [
        "Matches Python with statements",
        
        "- `^`: Start of line." + NL +
        "- `with\\s+`: 'with' keyword." + NL +
        "- `.*?\\s+`: Context manager expression." + NL +
        "- `as\\s+`: 'as' keyword." + NL +
        "- `.*?:`: Target variable and colon." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `with open('file.txt') as f:`, `with context() as c:`" + NL +
        "- Non-matches: `with:`, `with as:`, `with open()`"
    ],

    :pythonTry = [
        "Matches Python exception handling statements",
        
        "- `^`: Start of line." + NL +
        "- `(?:try|except|finally|raise)`: Exception keywords." + NL +
        "- `\\s*.*?:`: Optional expression and colon." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `try:`, `except ValueError:`, `finally:`, `raise Exception()`" + NL +
        "- Non-matches: `try`, `except:()`, `raises:`"
    ],

    :pythonList = [
        "Matches Python list literals",
        
        "- `^`: Start of line." + NL +
        "- `\\[`: Opening bracket." + NL +
        "- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists." + NL +
        "- `\\]`: Closing bracket." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + NL +
        "- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
    ],

    :pythonDict = [
        "Matches Python dictionary literals",
        
        "- `^`: Start of line." + NL +
        "- `{`: Opening brace." + NL +
        "- `(?:[^{}]*|{.*?})*`: Dictionary contents, including nested dicts." + NL +
        "- `}`: Closing brace." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `{'a':1}`, `{1:2, 3:4}`, `{}`" + NL +
        "- Non-matches: `{unclosed`, `{:}`, `{{}`"
    ],

    :pythonTuple = [
        "Matches Python tuple literals",
        
        "- `^`: Start of line." + NL +
        "- `\\(`: Opening parenthesis." + NL +
        "- `(?:[^()]*|\\(.*?\\))*`: Tuple contents, including nested tuples." + NL +
        "- `\\)`: Closing parenthesis." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `(1,2)`, `(1,(2,3))`, `()`" + NL +
        "- Non-matches: `(unclosed`, `(,)`, `(()`"
    ],

    :pythonComprehension = [
        "Matches Python list comprehensions",
        
        "- `^`: Start of line." + NL +
        "- `\\[`: Opening bracket." + NL +
        "- `.*?\\s+`: Expression." + NL +
        "- `for\\s+.*?\\s+in\\s+.*?`: For clause." + NL +
        "- `\\]`: Closing bracket." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `[x for x in range(10)]`, `[i*2 for i in list]`" + NL +
        "- Non-matches: `[for in]`, `[x for]`, `[x in y]`"
    ],

    :pythonComment = [
        "Matches Python single-line comments",
        
        "- `^`: Start of line." + NL +
        "- `#`: Comment symbol." + NL +
        "- `.*`: Comment text." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `# comment`, `#note`, `# TODO: fix`" + NL +
        "- Non-matches: `/#comment`, `comment#`, `##`"
    ],

    :pythonDocstring = [
        "Matches Python docstrings",
        
        "- `^`: Start of line." + NL +
        "- `[" + char(34) + "]{3}`: Triple quotes." + NL +
        "- `[\\s\\S]*?`: Any content including newlines." + NL +
        "- `[" + char(34) + "]{3}`: Closing triple quotes." + NL +
        "- `$`: End of line." + NL +
        "- Matches: `" + char(34) + char(34) + char(34) + "Documentation" + char(34) + char(34) + char(34) + "`, `" + char(34) + char(34) + char(34) + "Multi" + NL + "line" + char(34) + char(34) + char(34) + "`" + NL +
        "- Non-matches: `" + char(34) + "doc" + char(34) + "`, `" + char(34) + char(34) + char(34) + "unclosed`"
    ],

    :pythonImport = [
        "Matches Python import statements",
        
        "- `^`: Start of line." + NL +
        "- `(?:import|from)`: 'import' or 'from' keyword." + NL +
        "- `\\s+[\\w.]+`: Module path." + NL +
        "- `(?:\\s+import\\s+`: Optional import clause." + NL +
        "- `(?:\\w+(?:\\s+as\\s+\\w+)?`: Import target with optional alias." + NL +
        "- `(?:\\s*,\\s*\\w+(?:\\s+as\\s+\\w+)?)*|\\*))?`: Multiple imports or star import." + NL +
        "- `\\s*$`: End of line." + NL +
        "- Matches: `import os`, `from sys import path`, `from x import *`" + NL +
        "- Non-matches: `import`, `from`, `import as`"
    ],

	# JavaScript Language Patterns

:jsString = [
    "Matches JavaScript string literals",

    "- `^`: Start of line" + NL +
    "- `(?:`: Non-capturing group for string types" + NL +
    "- `[" + char(34) + "].*?[" + char(34) + "]`: Double-quoted strings" + NL +
    "- `|'.*?'`: Single-quoted strings" + NL +
    "- `|`[\s\S]*?``: Template literals" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `" + char(34) + "hello" + char(34) + "`, `'world'`, ``template``" + NL +
    "- Non-matches: `hello`, `" + char(34) + "unclosed`"
],

:jsNumber = [
    "Matches JavaScript numeric literals",

    "- `^`: Start of line" + NL +
    "- `-?`: Optional negative sign" + NL +
    "- `\d+`: One or more digits" + NL +
    "- `(?:\.\d+)?`: Optional decimal portion" + NL +
    "- `(?:e[+-]?\d+)?`: Optional exponential notation" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `42`, `-3.14`, `1.2e-10`" + NL +
    "- Non-matches: `.`, `1.`, `e10`"
],

:jsBoolean = [
    "Matches JavaScript boolean and null values",

    "- `^`: Start of line" + NL +
    "- `(?:true|false|null|undefined)`: Literal values" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `true`, `false`, `null`, `undefined`" + NL +
    "- Non-matches: `True`, `FALSE`, `Null`"
],

:jsVariable = [
    "Matches JavaScript variable declarations",

    "- `^`: Start of line" + NL +
    "- `(?:var|let|const)`: Declaration keyword" + NL +
    "- `\s+`: Required whitespace" + NL +
    "- `[a-zA-Z_$][\w$]*`: Variable name" + NL +
    "- `(?:\s*=\s*.*)?`: Optional initialization" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `let x`, `const myVar = 42`" + NL +
    "- Non-matches: `x = 5`, `let 1x`"
],

:jsFunction = [
    "Matches JavaScript function declarations",

    "- `^`: Start of line" + NL +
    "- `(?:function\s+([a-zA-Z_$][\w$]*)\s*\((.*?)\)`: Named function" + NL +
    "- `|(?:async\s+)?function\s*\((.*?)\))`: Anonymous function" + NL +
    "- `\s*{`: Opening brace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `function add(a, b) {`, `async function() {`" + NL +
    "- Non-matches: `function`, `function() => {`"
],

:jsArrowFunction = [
    "Matches JavaScript arrow function expressions",

    "- `^`: Start of line" + NL +
    "- `(?:const\s+)?`: Optional const declaration" + NL +
    "- `([a-zA-Z_$][\w$]*)\s*=\s*`: Variable assignment" + NL +
    "- `(?:async\s+)?`: Optional async keyword" + NL +
    "- `\((.*?)\)\s*=>\s*`: Arrow function syntax" + NL +
    "- `(?:{|\S.*)`: Function body" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `const add = (a, b) => {`, `sum = x => x + 1`" + NL +
    "- Non-matches: `=> {}`, `const = () =>`"
],

:jsClass = [
    "Matches JavaScript class declarations",

    "- `^`: Start of line" + NL +
    "- `class\s+`: Class keyword" + NL +
    "- `([a-zA-Z_$][\w$]*)`: Class name" + NL +
    "- `(?:\s+extends\s+([a-zA-Z_$][\w$]*))?`: Optional inheritance" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `class Person`, `class Student extends Person`" + NL +
    "- Non-matches: `class`, `class 1Name`"
],

:jsClassMethod = [
    "Matches JavaScript class method declarations",

    "- `^`: Start of line" + NL +
    "- `(?:async\s+)?`: Optional async keyword" + NL +
    "- `([a-zA-Z_$][\w$]*)`: Method name" + NL +
    "- `\s*\((.*?)\)\s*{`: Parameters and opening brace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `getName() {`, `async calculate(x, y) {`" + NL +
    "- Non-matches: `method`, `123() {`"
],

:jsDecorator = [
    "Matches JavaScript decorators",

    "- `^`: Start of line" + NL +
    "- `@`: Decorator symbol" + NL +
    "- `[a-zA-Z_$][\w$]*`: Decorator name" + NL +
    "- `(?:\((.*?)\))?`: Optional parameters" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `@readonly`, `@validate(true)`" + NL +
    "- Non-matches: `@`, `@123`"
],

:jsLoop = [
    "Matches JavaScript loop statements",

    "- `^`: Start of line" + NL +
    "- `(?:for|while|do)`: Loop keyword" + NL +
    "- `\s*\(.*?\)`: Condition or iteration expression" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `for(let i = 0;i<10;i++)`, `while(true)`" + NL +
    "- Non-matches: `for`, `while`"
],

:jsObject = [
    "Matches JavaScript object literals",

    "- `^`: Start of line" + NL +
    "- `{`: Opening brace" + NL +
    "- `(?:[^{}]*|{.*?})*`: Object content" + NL +
    "- `}`: Closing brace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `{x: 1}`, `{a: {b: 2}}`" + NL +
    "- Non-matches: `{`, `{a:}`"
],

:jsArray = [
    "Matches JavaScript array literals",

    "- `^`: Start of line" + NL +
    "- `\[`: Opening bracket" + NL +
    "- `(?:[^[\]]*|\[.*?\])*`: Array content" + NL +
    "- `\]`: Closing bracket" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `[1,2,3]`, `[[1],[2]]`" + NL +
    "- Non-matches: `[`, `[1,]`"
],

:jsDestructuring = [
    "Matches JavaScript destructuring assignments",

    "- `^`: Start of line" + NL +
    "- `(?:let|const|var)?`: Optional declaration" + NL +
    "- `\s*(?:{[^}]*}|\[[^\]]*\])`: Destructuring pattern" + NL +
    "- `\s*=\s*.*`: Assignment" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `const {x, y} = obj`, `let [a, b] = arr`" + NL +
    "- Non-matches: `{a,b}`, `[x,y]`"
],

:jsComment = [
    "Matches JavaScript comments",

    "- `^`: Start of line" + NL +
    "- `(?://.*|/\*[\s\S]*?\*/)`: Single or multi-line comments" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `//comment`, `/* multi-line */`" + NL +
    "- Non-matches: `/comment`, `/*unclosed`"
],

:jsImport = [
    "Matches JavaScript import statements",

    "- `^`: Start of line" + NL +
    "- `import\s+`: Import keyword" + NL +
    "- `(?:{[^}]*}|\*\s+as\s+\w+|\w+)`: Import specifiers" + NL +
    "- `\s+from\s+`: From keyword" + NL +
    "- `[" + char(34) + "'].*?[" + char(34) + "']`: Module path" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `import {x} from " + char(34) + "mod" + char(34) + "`, `import * as y from 'z'`" + NL +
    "- Non-matches: `import`, `import from`"
],

:jsExport = [
    "Matches JavaScript export statements",

    "- `^`: Start of line" + NL +
    "- `export\s+`: Export keyword" + NL +
    "- `(?:default\s+)?`: Optional default export" + NL +
    "- `(?:class|function|const|let|var)`: Exported declaration" + NL +
    "- `\s+.*`: Export name and body" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `export class X`, `export default function`" + NL +
    "- Non-matches: `export`, `export 123`"
],

	# Visual Basic Language Patterns

:vbString = [
    "Matches Visual Basic string literals",

    "- `^`: Start of line" + NL +
    "- `[" + char(34) + "]`: Opening double quote" + NL +
    "- `.*?`: String content (non-greedy)" + NL +
    "- `[" + char(34) + "]`: Closing double quote" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `" + char(34) + "Hello World" + char(34) + "`, `" + char(34) + "" + char(34) + "`" + NL +
    "- Non-matches: `Hello`, `" + char(34) + "unclosed`"
],

:vbNumber = [
    "Matches Visual Basic numeric literals",

    "- `^`: Start of line" + NL +
    "- `-?`: Optional negative sign" + NL +
    "- `\d+`: One or more digits" + NL +
    "- `(?:\.\d+)?`: Optional decimal portion" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `42`, `-3.14`, `1000`" + NL +
    "- Non-matches: `.`, `1.`, `3.14.15`"
],

:vbBoolean = [
    "Matches Visual Basic boolean literals",

    "- `^`: Start of line" + NL +
    "- `(?:True|False)`: Boolean values" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `True`, `False`" + NL +
    "- Non-matches: `true`, `false`, `TRUE`"
],

:vbVariable = [
    "Matches Visual Basic variable declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + NL +
    "- `\s+`: Required whitespace" + NL +
    "- `([a-zA-Z_]\w*)`: Variable name" + NL +
    "- `\s+As\s+`: Type declaration" + NL +
    "- `\w+`: Variable type" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Dim count As Integer`, `Public name As String`" + NL +
    "- Non-matches: `Dim x`, `Private 1var As Integer`"
],

:vbFunction = [
    "Matches Visual Basic function declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
    "- `Function\s+`: Function keyword" + NL +
    "- `([a-zA-Z_]\w*)`: Function name" + NL +
    "- `\s*\((.*?)\)`: Parameters" + NL +
    "- `\s+As\s+\w+`: Return type" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Function Add(x As Integer, y As Integer) As Integer`" + NL +
    "- Non-matches: `Function`, `Public Function()`"
],

:vbSub = [
    "Matches Visual Basic subroutine declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
    "- `Sub\s+`: Sub keyword" + NL +
    "- `([a-zA-Z_]\w*)`: Subroutine name" + NL +
    "- `\s*\((.*?)\)`: Parameters" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Public Sub Initialize()`, `Private Sub HandleClick(sender As Object)`" + NL +
    "- Non-matches: `Sub`, `Public Sub`"
],

:vbFunctionCall = [
    "Matches Visual Basic function calls",

    "- `^`: Start of line" + NL +
    "- `([a-zA-Z_]\w*)`: Function name" + NL +
    "- `\s*\((.*?)\)`: Function arguments" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Calculate()`, `Add(x, y)`" + NL +
    "- Non-matches: `Call()`, `1Function()`"
],

:vbClass = [
    "Matches Visual Basic class declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
    "- `Class\s+`: Class keyword" + NL +
    "- `([a-zA-Z_]\w*)`: Class name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Public Class Customer`, `Private Class Helper`" + NL +
    "- Non-matches: `Class`, `Public Class 1Name`"
],

:vbInterface = [
    "Matches Visual Basic interface declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
    "- `Interface\s+`: Interface keyword" + NL +
    "- `([a-zA-Z_]\w*)`: Interface name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Public Interface IDisposable`, `Interface IComparable`" + NL +
    "- Non-matches: `Interface`, `Public Interface 1Name`"
],

:vbProperty = [
    "Matches Visual Basic property declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
    "- `Property\s+`: Property keyword" + NL +
    "- `(?:Get|Let|Set)`: Property type" + NL +
    "- `\s+([a-zA-Z_]\w*)`: Property name" + NL +
    "- `\s*\((.*?)\)`: Parameters" + NL +
    "- `\s+As\s+\w+`: Return type" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Property Get Name() As String`, `Public Property Let Value(v As Integer)`" + NL +
    "- Non-matches: `Property`, `Property Get`"
],

:vbLoop = [
    "Matches Visual Basic loop statements",

    "- `^`: Start of line" + NL +
    "- `(?:For|Do|While|For\s+Each)`: Loop keywords" + NL +
    "- `\s+.*`: Loop condition or iteration" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `For i = 1 To 10`, `Do While condition`, `For Each item In collection`" + NL +
    "- Non-matches: `For`, `While`"
],

:vbIf = [
    "Matches Visual Basic if statements",

    "- `^`: Start of line" + NL +
    "- `(?:If|ElseIf|Else)`: Conditional keywords" + NL +
    "- `\s+.*?\s+`: Condition (if applicable)" + NL +
    "- `Then`: Required for If/ElseIf" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `If x > 0 Then`, `ElseIf count = 0 Then`, `Else Then`" + NL +
    "- Non-matches: `If`, `If x > 0`"
],

:vbSelect = [
    "Matches Visual Basic select case statements",

    "- `^`: Start of line" + NL +
    "- `Select\s+Case\s+`: Select Case keywords" + NL +
    "- `.*`: Expression being tested" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Select Case x`, `Select Case day`" + NL +
    "- Non-matches: `Select`, `Case`"
],

:vbTry = [
    "Matches Visual Basic error handling blocks",

    "- `^`: Start of line" + NL +
    "- `(?:Try|Catch|Finally)`: Error handling keywords" + NL +
    "- `\s*`: Optional whitespace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Try`, `Catch`, `Finally`" + NL +
    "- Non-matches: `Try Catch`, `Catch Error`"
],

:vbArray = [
    "Matches Visual Basic array declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + NL +
    "- `\s+([a-zA-Z_]\w*)`: Array name" + NL +
    "- `\s*\(\s*\d*\s*\)`: Array dimensions" + NL +
    "- `\s+As\s+\w+`: Array type" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Dim numbers(10) As Integer`, `Public matrix(,) As Double`" + NL +
    "- Non-matches: `Dim array`, `Private arr() As`"
],

:vbCollection = [
    "Matches Visual Basic collection instantiation",

    "- `^`: Start of line" + NL +
    "- `New\s+`: New keyword" + NL +
    "- `Collection`: Collection type" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `New Collection`" + NL +
    "- Non-matches: `Collection`, `New List`"
],

:vbComment = [
    "Matches Visual Basic single-line comments",

    "- `^`: Start of line" + NL +
    "- `'`: Comment character" + NL +
    "- `.*`: Comment text" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `'This is a comment`, `' Note:`" + NL +
    "- Non-matches: `//comment`, `REM comment`"
],

:vbRemark = [
    "Matches Visual Basic REM comments",

    "- `^`: Start of line" + NL +
    "- `REM\s+`: REM keyword with space" + NL +
    "- `.*`: Comment text" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `REM This is a remark`, `REM Debug code below`" + NL +
    "- Non-matches: `REM`, `'REM comment`"
],

:vbModule = [
    "Matches Visual Basic module declarations",

    "- `^`: Start of line" + NL +
    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
    "- `Module\s+`: Module keyword" + NL +
    "- `([a-zA-Z_]\w*)`: Module name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Module Utils`, `Public Module Constants`" + NL +
    "- Non-matches: `Module`, `Module 1Name`"
],

:vbNamespace = [
    "Matches Visual Basic namespace declarations",

    "- `^`: Start of line" + NL +
    "- `Namespace\s+`: Namespace keyword" + NL +
    "- `[\w.]+`: Namespace path" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Namespace MyApp`, `Namespace System.Data`" + NL +
    "- Non-matches: `Namespace`, `Namespace 1.2`"
],

:vbImports = [
    "Matches Visual Basic imports statements",

    "- `^`: Start of line" + NL +
    "- `Imports\s+`: Imports keyword" + NL +
    "- `[\w.]+`: Imported namespace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Imports System`, `Imports System.Collections.Generic`" + NL +
    "- Non-matches: `Imports`, `Imports 1.System`"
],

:vbReference = [
    "Matches Visual Basic reference declarations",

    "- `^`: Start of line" + NL +
    "- `Reference\s+=\s+`: Reference assignment" + NL +
    "- `.*`: Reference path or name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Reference = System`, `Reference = " + char(34) + "MyLib.dll" + char(34) + "`" + NL +
    "- Non-matches: `Reference`, `Reference ==`"
],

	# Julia Language Patterns

:juliaString = [
    "Matches Julia string literals including triple-quoted, regular, raw, and literal strings",

    "- `^`: Start of line" + NL +
    "- `(?:`: Start non-capturing group for string types" + NL +
    "- `[" + char(34) + "]{3}.*?[" + char(34) + "]{3}`: Triple-quoted strings" + NL +
    "- `|[" + char(34) + "].*?[" + char(34) + "]`: Regular strings" + NL +
    "- `|r[" + char(34) + "].*?[" + char(34) + "]`: Raw strings" + NL +
    "- `|raw[" + char(34) + "].*?[" + char(34) + "])`: Literal strings" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `" + char(34) + "hello" + char(34) + "`, `" + char(34) + char(34) + char(34) + "multiline" + char(34) + char(34) + char(34) + "`, `r" + char(34) + "raw\string" + char(34) + "`" + NL +
    "- Non-matches: `'string'`, `" + char(34) + "unclosed`"
],

:juliaNumber = [
    "Matches Julia numeric literals including integers, floats, and scientific notation",

    "- `^`: Start of line" + NL +
    "- `-?`: Optional negative sign" + NL +
    "- `(?:\\d+(?:\\.\\d*)?|\\.\\d+)`: Integer or decimal number" + NL +
    "- `(?:e[+-]?\\d+)?`: Optional scientific notation" + NL +
    "- `(?:[ff]32|f64)?`: Optional float type suffix" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `42`, `-3.14`, `1.2e-10`, `3.14f32`" + NL +
    "- Non-matches: `.`, `1.`, `e10`"
],

:juliaBoolean = [
    "Matches Julia boolean and special value literals",

    "- `^`: Start of line" + NL +
    "- `(?:true|false|nothing|missing)`: Boolean or special values" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `true`, `false`, `nothing`, `missing`" + NL +
    "- Non-matches: `True`, `NULL`, `nil`"
],

:juliaVariable = [
    "Matches Julia variable identifiers",

    "- `^`: Start of line" + NL +
    "- `[a-zA-Z_]`: First character must be letter or underscore" + NL +
    "- `[\\w!]*`: Followed by word characters or exclamation mark" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `x`, `myVar`, `function!`, `_temp`" + NL +
    "- Non-matches: `1x`, `$var`"
],

:juliaFunction = [
    "Matches Julia function declarations with optional type annotations and where clauses",

    "- `^`: Start of line" + NL +
    "- `function\\s+`: Function keyword" + NL +
    "- `([a-zA-Z_][\\w!]*)`: Function name" + NL +
    "- `\\s*\\(([^)]*?)\\)`: Parameter list" + NL +
    "- `(?:\\s*::\\s*[\\w{}.\\[\\]]+)?`: Optional return type" + NL +
    "- `(?:where\\s+{.*?})?`: Optional where clause" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `function add(x, y)`, `function multiply(x::Int, y::Int)::Int`" + NL +
    "- Non-matches: `function`, `function()`"
],

:juliaFunctionCall = [
    "Matches Julia function calls",

    "- `^`: Start of line" + NL +
    "- `([a-zA-Z_][\\w!]*)`: Function name" + NL +
    "- `\\s*\\((.*?)\\)`: Function arguments" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `println(x)`, `add!(1, 2)`" + NL +
    "- Non-matches: `call x`, `1func()`"
],

:juliaLambda = [
    "Matches Julia lambda expressions and anonymous functions",

    "- `^`: Start of line" + NL +
    "- `(?:[^->]+->|function\\s*\\([^)]*\\))`: Lambda syntax or anonymous function" + NL +
    "- `.*`: Function body" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `x -> x^2`, `function (x) x + 1 end`" + NL +
    "- Non-matches: `->`, `function`"
],

:juliaStruct = [
    "Matches Julia struct declarations with optional mutability and type parameters",

    "- `^`: Start of line" + NL +
    "- `(?:mutable\\s+)?`: Optional mutability" + NL +
    "- `struct\\s+`: Struct keyword" + NL +
    "- `([a-zA-Z_][\\w!]*)`: Struct name" + NL +
    "- `(?:{.*?})?`: Optional type parameters" + NL +
    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `struct Point`, `mutable struct User{T}`" + NL +
    "- Non-matches: `struct`, `struct 1Point`"
],

:juliaAbstract = [
    "Matches Julia abstract type declarations",

    "- `^`: Start of line" + NL +
    "- `abstract\\s+type\\s+`: Abstract type keywords" + NL +
    "- `([a-zA-Z_][\\w!]*)`: Type name" + NL +
    "- `(?:{.*?})?`: Optional type parameters" + NL +
    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `abstract type Number`, `abstract type Array{T} <: AbstractArray`" + NL +
    "- Non-matches: `abstract`, `type Number`"
],

:juliaMacro = [
    "Matches Julia macro invocations",

    "- `^`: Start of line" + NL +
    "- `@`: Macro symbol" + NL +
    "- `[a-zA-Z_][\\w!]*`: Macro name" + NL +
    "- `(?:\\s|$)`: Space or end of line" + NL +
    "- Matches: `@time`, `@async`" + NL +
    "- Non-matches: `@`, `@1macro`"
],

:juliaLoop = [
    "Matches Julia loop constructs",

    "- `^`: Start of line" + NL +
    "- `(?:for\\s+.*?\\s+in\\s+.*?|while\\s+.*?)`: For or while loops" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `for i in 1:10`, `while x < 100`" + NL +
    "- Non-matches: `for`, `while`"
],

:juliaIf = [
    "Matches Julia conditional statements",

    "- `^`: Start of line" + NL +
    "- `(?:if|elseif|else)`: Conditional keywords" + NL +
    "- `\\s*.*?`: Condition (if applicable)" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `if x > 0`, `elseif isempty(arr)`, `else`" + NL +
    "- Non-matches: `ifdef`, `elsif`"
],

:juliaBegin = [
    "Matches Julia begin blocks",

    "- `^`: Start of line" + NL +
    "- `begin`: Begin keyword" + NL +
    "- `\\s*`: Optional whitespace" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `begin`, `begin `" + NL +
    "- Non-matches: `begins`, `begin{`"
],

:juliaTry = [
    "Matches Julia exception handling blocks",

    "- `^`: Start of line" + NL +
    "- `(?:try|catch|finally)`: Exception handling keywords" + NL +
    "- `\\s*.*?`: Optional clause" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `try`, `catch e`, `finally`" + NL +
    "- Non-matches: `trying`, `catch{`"
],

:juliaArray = [
    "Matches Julia array literals",

    "- `^`: Start of line" + NL +
    "- `\\[`: Opening bracket" + NL +
    "- `(?:[^\\[\\]]*|\\[.*?\\])*`: Array elements" + NL +
    "- `\\]`: Closing bracket" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `[1, 2, 3]`, `[[1, 2], [3, 4]]`" + NL +
    "- Non-matches: `[`, `[1,]`"
],

:juliaTuple = [
    "Matches Julia tuple literals",

    "- `^`: Start of line" + NL +
    "- `\\(`: Opening parenthesis" + NL +
    "- `(?:[^()]*|\\(.*?\\))*`: Tuple elements" + NL +
    "- `\\)`: Closing parenthesis" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `(1, 2)`, `(x = 1, y = 2)`" + NL +
    "- Non-matches: `(`, `(1,`"
],

:juliaDict = [
    "Matches Julia dictionary literals",

    "- `^`: Start of line" + NL +
    "- `Dict\\(`: Dict constructor" + NL +
    "- `(?:[^()]*|\\(.*?\\))*`: Dictionary key-value pairs" + NL +
    "- `\\)`: Closing parenthesis" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Dict()`, `Dict(:a => 1, :b => 2)`" + NL +
    "- Non-matches: `Dict`, `Dict[`"
],

:juliaComprehension = [
    "Matches Julia array comprehensions",

    "- `^`: Start of line" + NL +
    "- `\\[`: Opening bracket" + NL +
    "- `.*?\\s+for\\s+.*?\\s+in\\s+.*?`: Comprehension syntax" + NL +
    "- `\\]`: Closing bracket" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `[x^2 for x in 1:10]`, `[i+j for i in 1:3 for j in 1:3]`" + NL +
    "- Non-matches: `[for in]`, `[x for x]`"
],

:juliaComment = [
    "Matches Julia comments (single-line and multi-line)",

    "- `^`: Start of line" + NL +
    "- `#=(?:[^=#]|=(?!#))*=#`: Multi-line comments" + NL +
    "- `|^#.*`: Single-line comments" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `# comment`, `#= multi-line comment =#`" + NL +
    "- Non-matches: `//comment`, `/* comment */`"
],

:juliaDocString = [
    "Matches Julia documentation strings",

    "- `^`: Start of line" + NL +
    "- `[" + char(34) + "]{3}`: Three double quotes" + NL +
    "- `[\\s\\S]*?`: Documentation content" + NL +
    "- `[" + char(34) + "]{3}`: Closing three double quotes" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `" + char(34) + char(34) + char(34) + "Function documentation" + char(34) + char(34) + char(34) + "`" + NL +
    "- Non-matches: `" + char(34) + "doc" + char(34) + "`, `" + char(34) + char(34) + char(34) + "unclosed`"
],

:juliaImport = [
    "Matches Julia import and using statements",

    "- `^`: Start of line" + NL +
    "- `(?:using|import)`: Import keywords" + NL +
    "- `\\s+`: Required whitespace" + NL +
    "- `(?:[\\w.]+`: Module path" + NL +
    "- `(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?`: Optional specific imports" + NL +
    "- `(?:\\s*,\\s*[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?)*)`: Additional imports" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `using LinearAlgebra`, `import Base: show, print`" + NL +
    "- Non-matches: `using`, `import 1.2`"
],

:juliaModule = [
    "Matches Julia module declarations",

    "- `^`: Start of line" + NL +
    "- `module\\s+`: Module keyword" + NL +
    "- `[a-zA-Z_][\\w!]*`: Module name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `module MyModule`, `module Utils`" + NL +
    "- Non-matches: `module`, `module 1Name`"
],

:juliaExport = [
    "Matches Julia export statements",

    "- `^`: Start of line" + NL +
    "- `export\\s+`: Export keyword" + NL +
    "- `(?:[a-zA-Z_][\\w!]*`: First exported name" + NL +
    "- `(?:\\s*,\\s*[a-zA-Z_][\\w!]*)*)`: Additional exported names" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `export foo`, `export foo, bar, baz`" + NL +
    "- Non-matches: `export`, `export 1func`"
],

:juliaTypeParameter = [
    "Matches Julia type parameter declarations",

    "- `^`: Start of line" + NL +
    "- `(?:[a-zA-Z_][\\w!]*)`: Type name" + NL +
    "- `{.*?}`: Type parameters in curly braces" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `Array{T}`, `Dict{K,V}`, `Container{Type}`" + NL +
    "- Non-matches: `T{}`, `Array{}`"
],

:juliaTypeAnnotation = [
    "Matches Julia type annotations",

    "- `^`: Start of line" + NL +
    "- `::`: Type annotation operator" + NL +
    "- `\\s*`: Optional whitespace" + NL +
    "- `[\\w{}.\\[\\]]+`: Type specification" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `::Int`, `::Array{Float64,2}`, `::Dict{String,Any}`" + NL +
    "- Non-matches: `:Int`, `:: `"
],

:juliaBroadcast = [
    "Matches Julia broadcast operators",

    "- `^`: Start of line" + NL +
    "- `\\.`: Dot operator" + NL +
    "- `\\w+`: Function or operator name" + NL +
    "- `$`: End of line" + NL +
    "- Matches: `.+`, `.^`, `.sqrt`" + NL +
    "- Non-matches: `.`, `.@`, `.1`"
],
	# Excel FORMULAT Patterns

:xlsFunctionCall = [
    "Matches an Excel function call",

    "- `^\\s*`: Allows leading whitespace." + NL +
    "- `[A-Z]+`: Matches the function name (uppercase letters)." + NL +
    "- `\\(.*\\)$`: Matches the opening parenthesis, arguments, and closing parenthesis." + NL +
    "- Matches: `SUM(A1:A10)`, ` IF(A1>0, TRUE, FALSE)`." + NL +
    "- Non-matches: `sum(A1:A10)`, `SUM A1:A10`."
],

:xlsCellReference = [
    "Matches a single Excel cell reference",

    "- `^[A-Z]+`: Matches the column (letters A to Z)." + NL +
    "- `\\d+$`: Matches the row (numeric part)." + NL +
    "- Matches: `A1`, `B12`, `ZZ100`." + NL +
    "- Non-matches: `1A`, `ABCD`, `A 1`."
],

:xlsRangeReference = [
    "Matches an Excel range reference",

    "- `^[A-Z]+\\d+`: Matches the start cell of the range." + NL +
    "- `:[A-Z]+\\d+$`: Matches the colon and the end cell of the range." + NL +
    "- Matches: `A1:B10`, `C5:D7`, `Z1:Z100`." + NL +
    "- Non-matches: `A1:B`, `A1-10`, `1A:B2`."
],

:xlsRelativeReference = [
    "Matches a relative Excel cell reference",

    "- `^(?:[A-Z]*\\d+|[A-Z]+\\d*)$`: Matches either column-relative or row-relative references." + NL +
    "- Matches: `A1`, `1`, `A`." + NL +
    "- Non-matches: `$A$1`, `$1`, `$A`."
],

:xlsAbsoluteReference = [
    "Matches an absolute Excel cell reference",

    "- `^\\$[A-Z]+`: Matches the dollar sign and absolute column reference." + NL +
    "- `\\$\\d+$`: Matches the dollar sign and absolute row reference." + NL +
    "- Matches: `$A$1`, `$B$100`." + NL +
    "- Non-matches: `A1`, `1`, `$A1`."
],

:xlsMixedReference = [
    "Matches a mixed Excel cell reference",

    "- `^(?:\\$[A-Z]+\\d+|[A-Z]+\\$\\d+)$`: Matches either absolute column/relative row or relative column/absolute row references." + NL +
    "- Matches: `$A1`, `A$1`, `$B$2`." + NL +
    "- Non-matches: `A1`, `$A$1`, `B2$`."
],

:xlsStringLiteral = [
    "Matches a string literal in Excel",

   "- `^\" + char(34) + " + char(34) + " + char(34) + ".*\" + char(34) + " + char(34) + " + char(34) + "$`: Matches a string enclosed in double quotes." + NL +
   "- Matches: `\" + char(34) + "Hello\" + char(34) + "`, `\" + char(34) + "123\" + char(34) + "`, `\" + char(34) + "A1:B10\" + char(34) + "`." + NL +
    "- Non-matches: `Hello`, `'Hello'`, `\" + char(34) + "Hello`."
],

:xlsNumberLiteral = [
    "Matches a numeric literal in Excel",

    "- `^-?\\d+(\\.\\d+)?$`: Matches an integer or decimal number, optionally negative." + NL +
    "- Matches: `123`, `-45`, `3.14`, `-0.5`." + NL +
    "- Non-matches: `123A`, `3,14`, `.`."
],

:xlsBooleanLiteral = [
    "Matches a boolean literal in Excel",

    "- `^(TRUE|FALSE)$`: Matches the literals TRUE or FALSE (case-sensitive)." + NL +
    "- Matches: `TRUE`, `FALSE`." + NL +
    "- Non-matches: `true`, `false`, `1`."
],

:xlsArithmeticExpression = [
    "Matches an Excel arithmetic expression",

    "- `^.*(?:[+\\-*/^]).*$`: Matches any formula containing arithmetic operators." + NL +
    "- Matches: `A1+A2`, `B1-B2`, `3*4`, `5/2`, `2^3`." + NL +
    "- Non-matches: `A1A2`, `3*`, `*4`."
],

:xlsConditionalExpression = [
    "Matches an Excel conditional expression",

    "- `^.*(?:=|<|>|<>).*$`: Matches any formula containing comparison operators." + NL +
    "- Matches: `A1=A2`, `B1<>C1`, `A1>10`, `5<=6`." + NL +
    "- Non-matches: `A1A2`, `=A1`, `<B2`."
],

:xlsArrayFormula = [
    "Matches an array formula in Excel",

    "- `^\\{.*\\}$`: Matches formulas enclosed in curly braces." + NL +
    "- Matches: `{SUM(A1:A10)}`." + NL +
    "- Non-matches: `SUM(A1:A10)`, `{A1:A10`."
]


]
