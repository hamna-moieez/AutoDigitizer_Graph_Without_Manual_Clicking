# AutoDigitizer_Graph_Without_Manual_Clicking

A digitizer tool for automatic extraction of graphical information and its conversion to digitized form.

## Approach
* Axis segmentation
  * finding x-axis and y-axis using horizontal and vertical sobel filters
* Label recognition
  * Auto-detecting label numbers with OCR
* Assign values
  * Assign data values to the ends of x-axis and y-axis by finding label box center
* Symbol recognition
  * user manually circles the targeted symbol 
  * extract the symbol from the drawing area 
  * slightly erode the selected symbol, 
  * erode plot with extracted symbol
* Line recognition
 `* crop image to remove tick marks
  * find linearly spaced columns at desired resolution
  * threshold and search for nonzero values along each column




## Demo

### Linear Line Graph
-------------------------------------------------------------------
![alttext](Demo/LinearLineGraph.gif?raw=true "LinearLineGraph")

### Linear triangle Graph
--------------------------------------------------------------------
![alttext](Demo/LinearTriangleGraph.gif?raw=true "LinearLineGraph")
 
