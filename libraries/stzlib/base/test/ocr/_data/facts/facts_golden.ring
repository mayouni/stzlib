# facts_golden.ring -- written by _rig/screenshot_facts_golden.py: the rows of facts_page.html and the
# WCAG luminance of the colours they were PAINTED with. [ text, fg luminance, bg luminance ("" = no
# single colour), CSS px, fg as painted, bg as painted ]

func StzFactsGolden()
	return [
		[ "Overdue balance", 0.318547, 1.000000, 16, "#999999", "#ffffff" ],
		[ "Account summary", 0.033105, 1.000000, 16, "#333333", "#ffffff" ],
		[ "Save changes", 1.000000, 0.114416, 16, "#ffffff", "#0b57d0" ],
		[ "Cancel", 0.123561, 0.893336, 14, "#5f6368", "#f1f3f4" ],
		[ "Last updated 3 minutes ago", 0.347648, 1.000000, 12, "#9aa0a6", "#ffffff" ],
		[ "Error: card declined", 0.169992, 1.000000, 14, "#d93025", "#ffffff" ],
		[ "Dark mode heading", 0.821159, 0.015222, 20, "#e8eaed", "#202124" ],
		[ "Muted label on dark", 0.123561, 0.015222, 14, "#5f6368", "#202124" ],
		[ "Warning banner", 0.026166, 0.698766, 16, "#3c2a00", "#fdd663" ],
		[ "Link to settings", 0.183073, 1.000000, 16, "#1a73e8", "#ffffff" ],
		[ "Placeholder text", 0.530360, 1.000000, 16, "#bdc1c6", "#ffffff" ],
		[ "Over a gradient", 1.000000, "", 18, "#ffffff", "linear-gradient(90deg, #0b57d0, #fbbc04)" ],
		[ "Large title", 0.015222, 1.000000, 32, "#202124", "#ffffff" ],
		[ "Tiny footnote", 0.123561, 1.000000, 10, "#5f6368", "#ffffff" ],
		[ "Payment received", 0.159181, 0.874649, 14, "#188038", "#e6f4ea" ],
		[ "Disabled button", 0.347648, 0.893336, 14, "#9aa0a6", "#f1f3f4" ]
	]

func StzFactsGoldenTexture()
	return [
		[ "Text on stripes", 0.015222, "", 18, "#202124", "repeating-linear-gradient(90deg, #ffffff 0 8px, #8ab4f8 8px 16px)" ],
		[ "Caption on a checkerboard", 0.015222, "", 16, "#202124", "repeating-conic-gradient(#ffffff 0 25%, #a8c7fa 0 50%) 0 0 / 16px 16px" ],
		[ "A gradient that runs under the whole line", 1.000000, "", 18, "#ffffff", "linear-gradient(90deg, #0b57d0, #fbbc04)" ]
	]

# the box-kind picture: [ text, em (px), top of its row ] -- each row drawn at a known size
func StzFactsGoldenBoxKind()
	return [
		[ "esc", 16, 30 ],
		[ "esc", 24, 100 ],
		[ "esc", 32, 170 ],
		[ "esc", 48, 240 ],
		[ "Hxgp", 16, 310 ],
		[ "Hxgp", 24, 380 ],
		[ "Hxgp", 32, 450 ],
		[ "Hxgp", 48, 520 ]
	]
