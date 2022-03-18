aPackageInfo = [
	:name = "The SoftanzaLib Package",
	:description = "Our SoftanzaLib package using the Ring programming language",
	:folder = "SoftanzaLib",
	:developer = "Mansour Ayouni",
	:email = "kalidianow@gmail.com",
	:license = "MIT License",
	:version = "1.0.6",
	:ringversion = "1.16",
	:versions = 	[
		[
			:version = "1.0.5",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "ringqt",
			:version = "1.0",
			:providerusername = "ringpackages"
		],
		[
			:name = "stdlib",
			:version = "1.0",
			:providerusername = "ringpackages"
		],
		[
			:name = "internetlib",
			:version = "1.0",
			:providerusername = "ringpackages"
		]
	],
	:files = 	[
		"main.ring",
		"setup.ring",
		"uninstall.ring",
		"LICENSE",
		"README.md"
	],
	:ringfolderfiles = 	[
		"bin/load/stzlib.ring",
		"libraries/softanzalib.zip"
	],
	:windowsfiles = 	[

	],
	:linuxfiles = 	[

	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:macosfiles = 	[

	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring setup.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = ""
]
