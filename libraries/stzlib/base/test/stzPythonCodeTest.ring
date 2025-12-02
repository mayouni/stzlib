load "../stzbase.ring"

/*---
*/
pr()

# Python code  
Py() { @('res = 2 + 3') Run() ? Result() }  #--> 5

# R code  
R() { @('res = 2 + 3') Run() ? Result() }   #--> 5

pf()
# Executed in 0.87 second(s) in Ring 1.24

/*--- Simple python code

pr()

py() {

# Pyhton code
@('
res = {
    "numbers": [1, 2, 3, 4, 5],
    "mean": sum([1, 2, 3, 4, 5]) / 5
}
')
# end of Python code

# Instructing python to run the code
Execute()

# Instructing Ring to return the result from Python
? @@( Result() )
#--> [
#	[ "numbers", [ 1, 2, 3, 4, 5 ] ],
#	[ "mean", 3 ]
# ]

} # closing brace of the py() object

pf()
# Executed in 0.43 second(s) in Ring 1.24

/*--- Data Analysis with Pandas

pr()

py() {

# Pyhton code
@('
import pandas as pd
import numpy as np

# Create sample data
res = {
    "sales_data": {
            "total_revenue": sum([a*b for a,b in zip([100, 150, 200, 120],
				 [10.5, 8.75, 12.25, 15.00])]),

            "average_price": np.mean([10.5, 8.75, 12.25, 15.00]),
            "best_seller": "C"
    }
}
') # End of Python code

# Back to Ring
Execute()

? @@NL(Result())

} # Closing brace of the py() object

#--> [
#	[
#		"sales_data",
#		[
#			[ "total_revenue", 6612.50 ],
#			[ "average_price", 11.62 ],
#			[ "best_seller", "C" ] ]
#		]
#	]
# ]

pf()
# Executed in 0.77 second(s) in Ring 1.24

/*--- Text Processing with Python and its regex engine

pr()

py() {

# Start of the Python code
@('
from collections import Counter
import re

text = """
Ring is a innovative programming language that can embed Python code.
This makes Ring more powerful and flexible for developers who need
both Ring and Python capabilities in their applications.
"""

res = {
    "text_analysis": {
        "word_count": len(text.split()),
        "char_count": len(text),
        "word_frequency": dict(Counter(re.findall(r"\w+", text.lower()))),
        "sentences": len(re.split(r"[.!?]+", text))
    }
}
') # end of the Python code

# Back to Ring

Execute()

? @@NL(Result())

}
#--> [
#	[
#		"text_analysis",
#		[
#			[ "word_count", 30 ],
#			[ "char_count", 195 ],
#			[
#				"word_frequency",
#				[
#					[ "ring", 3 ],
#					[ "is", 1 ],
#					[ "a", 1 ],
#					[ "innovative", 1 ],
#					[ "programming", 1 ],
#					[ "language", 1 ],
#					[ "that", 1 ],
#					[ "can", 1 ],
#					[ "embed", 1 ],
#					[ "python", 2 ],
#					[ "code", 1 ],
#					[ "this", 1 ],
#					[ "makes", 1 ],
#					[ "more", 1 ],
#					[ "powerful", 1 ],
#					[ "and", 2 ],
#					[ "flexible", 1 ],
#					[ "for", 1 ],
#					[ "developers", 1 ],
#					[ "who", 1 ],
#					[ "need", 1 ],
#					[ "both", 1 ],
#					[ "capabilities", 1 ],
#					[ "in", 1 ],
#					[ "their", 1 ],
#					[ "applications", 1 ]
#				]
#			],
#			[ "sentences", 3 ]
#		]
#	]
# ]


pf()
# Executed in 0.42 second(s) in Ring 1.24

/*--- Python Machine Learning Integration in a Ring program

pr()

py() {

# Start of the python code

@('
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Generate synthetic data
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
clf = RandomForestClassifier(random_state=42)
clf.fit(X_train, y_train)

# Get predictions
predictions = clf.predict(X_test)

res = {
    "accuracy": clf.score(X_test, y_test),
    "feature_importance": clf.feature_importances_.tolist(),
    "predictions": predictions.tolist()
}
') # end of the python code

# Bakc to Ring: run the code and get the result

Execute()
? @@NL(Result())

} # closing brace of the py() object

#--> [
#	[ "accuracy", 0.90 ],
#	[ "feature_importance", [ 0.06, 0.08, 0.35, 0.51 ] ],
#	[ "predictions", [ 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1 ] ]
# ]


pf()
# Executed in 1.87 second(s) in Ring 1.24

/*===== ADVANCED EXAMPLE - COMPARING PERF PYTHON VS SOFTANZA

pr()

py() {

	# --> START OF PYHTON CODE
    	@('

# Function to traverse the list and replace all occurrences of a target item
def traverse_and_replace(lst, target, replacement):
    count = 0
    for i in range(len(lst)):
        if isinstance(lst[i], list):
            # If the element is a sublist, recurse
            count += traverse_and_replace(lst[i], target, replacement)
        elif lst[i] == target:
            # If the element is the target, replace it
            lst[i] = replacement
            count += 1
    return count

deep_list = [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
	]
]

# Step 4: Replace all "♥" with "★" and count the replacements
count = traverse_and_replace(deep_list, "♥", "★")

# Step 5: Set the result
res = {"replacements_made": count}
')
	# <-- END OF PYTHON CODE

	run()
	? result()

}

pf()
# Executed in 0.35 second(s) in Ring 1.24

/*---

pr()

aDeep =  [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
    ]
]

o1 = new stzList(aDeep)
o1.DeepReplace("♥", "★")
? @@NL (o1.Content())

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Face detection with python


#TODO ExterLib

View("face.jpg")

py() { BoxFaceXT("face.jpg", [ :SaveAs = "face2.jpg", :Details = TRUE ]) }

View("face2.jpg")

/*---

View("face.jpg")

py() {

# Python code
@('
import cv2

# Load the pre-trained Haar Cascade classifier
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

# Load image
image = cv2.imread("face.jpg")

# Convert to grayscale for detection
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Detect faces
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

# Process results and draw on image
face_results = []
for i, (x, y, w, h) in enumerate(faces):
    # Draw orange rectangle (BGR format: orange is approximately (0, 165, 255))
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 165, 255), 2)
    
    # Calculate and draw center point
    center_x = int(x + w/2)
    center_y = int(y + h/2)
    cv2.circle(image, (center_x, center_y), 5, (0, 165, 255), 2)
    
    face_results.append({
        "face_id": i + 1,
        "bbox": [int(x), int(y), int(w), int(h)],
        "center": [center_x, center_y]
    })

# Save the annotated image
cv2.imwrite("face2.jpg", image)

res = {
    "total_faces": len(faces),
    "faces": face_results,
    "output_file": "face2.jpg"
}
')
# End of Python code

Execute()
? @@NL(Result())
View("face2.jpg")

}

pf()
# Executed in 5.98 second(s) in Ring 1.24

/*---
*/
pr()

py() {

# Python code
@('
import cv2

# Load the pre-trained Haar Cascade classifiers
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_eye.xml")
smile_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_smile.xml")

# Load image
image = cv2.imread("face-color.jpg")

# Convert to grayscale for detection
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Detect faces
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

# Green color in BGR
green = (0, 255, 0)

# Process results and draw annotations
face_results = []
for i, (x, y, w, h) in enumerate(faces):
    # Draw green rectangle around face
    cv2.rectangle(image, (x, y), (x+w, y+h), green, 2)
    
    # Calculate and draw center point
    center_x = int(x + w/2)
    center_y = int(y + h/2)
    cv2.circle(image, (center_x, center_y), 5, green, 2)
    
    # Add face ID label
    cv2.putText(image, f"Face {i+1}", (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, green, 2)
    
    # Add dimensions label
    cv2.putText(image, f"{w}x{h}", (x, y+h+20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, green, 1)
    
    # Region of interest for eyes and smile detection
    roi_gray = gray[y:y+h, x:x+w]
    roi_color = image[y:y+h, x:x+w]
    
    # Detect eyes within face region
    eyes = eye_cascade.detectMultiScale(roi_gray, scaleFactor=1.1, minNeighbors=10, minSize=(20, 20))
    eye_count = 0
    for (ex, ey, ew, eh) in eyes:
        cv2.rectangle(roi_color, (ex, ey), (ex+ew, ey+eh), green, 1)
        cv2.putText(roi_color, "Eye", (ex, ey-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, green, 1)
        eye_count += 1
    
    # Detect smile within face region
    smiles = smile_cascade.detectMultiScale(roi_gray, scaleFactor=1.8, minNeighbors=20, minSize=(25, 25))
    smile_detected = len(smiles) > 0
    if smile_detected:
        for (sx, sy, sw, sh) in smiles:
            cv2.rectangle(roi_color, (sx, sy), (sx+sw, sy+sh), green, 1)
            cv2.putText(roi_color, "Smile", (sx, sy-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, green, 1)
    
    face_results.append({
        "face_id": i + 1,
        "bbox": [int(x), int(y), int(w), int(h)],
        "center": [center_x, center_y],
        "eyes_detected": eye_count,
        "smile_detected": smile_detected
    })

# Save the annotated image
cv2.imwrite("face-color2.jpg", image)

res = {
    "total_faces": len(faces),
    "faces": face_results,
    "output_file": "face-color2.jpg"
}
')
# End of Python code

Execute()
? @@NL(Result())

? View("face-color2.jpg")

}

pf()
