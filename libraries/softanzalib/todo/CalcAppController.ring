# Form/Window Controller - Source Code File

load "CalcAppView.ring"

import System.GUI

if IsMainSourceFile() {
	new App {
		StyleFusion()
		openWindow(:CalcAppController)
		exec()
	}
}

class CalcAppController from windowsControllerParent

	oView = new CalcAppView
