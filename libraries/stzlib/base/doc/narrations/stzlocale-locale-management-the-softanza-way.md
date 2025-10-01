# Beautiful Code, Global Reach: Locale Management the Softanza Way


The Softanza library for Ring brings a refreshingly intuitive approach to locale management, wrapping Qt's powerful internationalization engine in an API that feels natural and expressive.

## The Core: `stzLocale` object

Softanza's locale management centers around the object-oriented `stzLocale` class, which simplifies dynamic locale configuration. The library offers remarkable flexibility in locale creation using standard IETF language tags, descriptive hash lists, or partial information with smart inference.

Using standard language tags:

```ring
o1 = new stzLocale("ar-TN")
? o1.Abbreviation()  #--> ar_TN
? o1.CountryName()   #--> tunisia
? o1.LanguageName()  #--> arabic
```

Using descriptive hash lists:

```ring
StzLocaleQ([ :Country = :Tunisia ]) {
    ? Abbreviation()   #--> ar_TN
    ? CountryName()    #--> tunisia
}
```

The library intelligently infers missing information. Provide just a language, and it determines the default country:

```ring
o1 = new stzLocale([ :Language = "romanian" ])
? o1.Abbreviation()   #--> ro_RO
? o1.CountryName()    #--> romania
```

Provide only a country:

```ring
o1 = new stzLocale([ :Country = "Niger" ])
? o1.Abbreviation()   #--> fr_NE
? o1.LanguageName()   #--> french
```

## Cultural Calendar Awareness

Different cultures start their week on different days. Softanza correctly handles locale-specific calendar ordering:

```ring
StzLocaleQ([ :Country = :Iran ]) {
    # Iran's week begins on Saturday
    ? NthDayOfWeek(1)             #--> saturday
    ? NativeNthDayOfWeek(1)       #--> شنبه
    ? NativeNthDayOfWeekSymbol(1) #--> د
}

o1 = new stzLocale("en_US")
? o1.FirstDayOfWeek()  #--> sunday
```

## Locale-Aware Text Transformation

The library understands cultural nuances in text formatting. Title case rules vary by language:

```ring
StzLocaleQ([ :Language = :French ]) {
    ? ToTitlecase("in search of lost time")
    #--> In search of lost time  // French style
}

StzLocaleQ([ :Language = :English ]) {
    ? ToTitlecase("in search of lost time")
    #--> In Search Of Lost Time  // English style
}
```

Case conversion respects locale conventions:

```ring
o1 = new stzLocale("en_US")
? o1.ToLowercase("FDMLj")  #--> fdmlj
? o1.ToUppercase("FDMLj")  #--> FDMLJ
```

## Country Phone Codes

International dialing codes are readily available:

```ring
? StzLocaleQ("ar_eg").CountryPhoneCode()  #--> +20
? StzLocaleQ([ :Country = :Niger ]).CountryPhoneCode()  #--> +227
```

## Days and Months in Native Languages

The library excels at providing localized calendar data:

```ring
? NamesOfDaysIn(:Japanese)
#--> [ "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日" ]

? NamesOfDaysIn(:Persian)
#--> [ "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه" ]
```

You can bridge languages elegantly:

```ring
? Association([ NamesOfDaysIn(:English), NamesOfDaysIn(:Japanese) ])
#--> [
#     [ "Sunday", "日曜日" ],
#     [ "Monday", "月曜日" ],
#     ...
#   ]
```

## Comprehensive Currency Information

Currency handling is thorough and culturally aware:

```ring
StzLocaleQ("ar_TN") {
    ? Currency()                #--> Tunisian Dinar
    ? CurrencyXT(:NativeName)   #--> دينار تونسي
    ? CurrencySymbol()          #--> د.ت.‏
    ? CurrencyAbbreviation()    #--> TND
    ? CurrencyFraction()        #--> Millime
    ? CurrencyBase()            #--> 1000
}
```

For complete currency details:

```ring
o1 = new stzLocale("ru_RU")
? o1.CurrencyInfo()
#--> [
#     [ "name", "Russian Ruble" ],
#     [ "nativename", "российский рубль" ],
#     [ "symbol", "₽" ],
#     [ "fractionalunit", "Kopek" ],
#     ...
#   ]
```

## Geo-Linguistic Details

The library provides fine-grained access to geographical and linguistic information in both English and native representations:

```ring
StzLocaleQ("ar_TN") {
    ? CountryName()          #--> tunisia
    ? CountryNativeName()    #--> تونس
    ? LanguageName()         #--> arabic
    ? LanguageNativeName()   #--> العربية
}

StzLocaleQ("fa_IR") {
    ? CountryName()          #--> iran
    ? CountryNativeName()    #--> ايران
    ? LanguageName()         #--> persian
    ? LanguageNativeName()   #--> فارسی
}
```

## Formatting Symbols

The API provides access to locale-specific formatting conventions:

```ring
o1 = new stzLocale("en_US")
? o1.DecimalPoint()      #--> "."
? o1.GroupSeparator()    #--> ","
? o1.Exponential()       #--> e
? o1.NegativeSign()      #--> "-"
? o1.PositiveSign()      #--> "+"
? o1.Percent()           #--> "%"
? o1.amText()            #--> AM
? o1.pmText()            #--> PM
```

## Comparison with Other Frameworks

Softanza's approach to locale management stands out in the landscape of programming tools:

| Feature | Softanza (Ring) | JavaScript (Intl) | Python (Babel/locale) | Java (Locale/ICU) | Ruby (i18n) |
|---------|----------------|-------------------|----------------------|-------------------|-------------|
| **Initialization Style** | Natural language hashes | Constructor codes | Module functions | Static factory methods | YAML config files |
| **Inference** | ✅ Smart defaults (country→lang, lang→country) | ❌ Explicit only | ⚠️ Limited | ❌ Explicit only | ❌ Explicit only |
| **Native Text** | ✅ Built-in (currency, days, months) | ⚠️ Via DisplayNames API | ✅ Via CLDR | ✅ Via ICU | ⚠️ Plugin-dependent |
| **Currency Details** | ✅ Comprehensive (fraction, base, native) | ⚠️ Basic formatting | ✅ Via Babel | ✅ Detailed | ⚠️ Limited |
| **Cultural Calendar** | ✅ Week start, native symbols | ⚠️ Manual calculation | ⚠️ Limited | ✅ Full support | ⚠️ Limited |
| **Syntax Philosophy** | Conversational blocks | Functional chaining | Procedural | Object-oriented | Convention DSL |
| **Query Functions** | ✅ Discovery APIs (e.g., `CountriesforWhichDefaultLanguageIs`) | ❌ None | ❌ None | ❌ None | ❌ None |
| **Readability** | `StzLocaleQ([:Country = :Iran])` | `new Intl.Locale('fa-IR')` | `Locale('fa', 'IR')` | `Locale.forLanguageTag("fa-IR")` | `I18n.locale = :'fa-IR'` |

**Key Differentiators:**

- **Smart Inference**: Softanza uniquely infers missing locale components, reducing boilerplate
- **Discovery APIs**: Query functions like `LanguagesForWhichDefaultCountryIs(:France)` have no equivalent in other frameworks
- **Conversational Syntax**: The `StzLocaleQ` block pattern reads like natural language
- **Comprehensive Currency**: Currency fraction units and base values built-in (most frameworks require additional lookups)
- **Qt Foundation**: Performance and stability inherited from decades of Qt development

## The Softanza Philosophy

What makes Softanza's locale management special is its commitment to three principles:

1. **Efficiency**: Built on Qt, leveraging battle-tested internationalization infrastructure
2. **Beauty**: Expressive syntax that reads like natural language
3. **Practicality**: Comprehensive coverage of real-world locale needs—from currency fractions to native symbols

The result is a library where locale management feels less like wrestling with APIs and more like having a conversation. Whether you need a quick currency symbol or comprehensive cultural information, Softanza provides it through an interface that's both powerful and pleasant to use.