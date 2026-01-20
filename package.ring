aPackageInfo = [
	:name = "The stzlib Package",
	:description = "Our stzlib package using the Ring programming language",
	:folder = "stzlib",
	:developer = "Mansour Ayouni",
	:email = "kalidianow@gmail.com",
	:license = "MIT License",
	:version = "0.9",
	:ringversion = "1.25",
	:versions = 	[
		[
			:version = "0.9",
			:branch = "master"
		]
	],
	:libs = [
		[
			:name = "ringqt",
			:version = "1.0",
			:providerusername = "ringpackages"
		],
		[
			:name = "stdlib",
			:version = "1.0",
			:providerusername = "ringpackages"
		]
	],
	:files = [
		"main.ring",
		"setup.ring",
		"uninstall.ring",
		"LICENSE",
		"README.md",
	],
	:ringfolderfiles = 	[
		"bin/load/stzlib.ring",
		"libraries/stzlib.zip"

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
