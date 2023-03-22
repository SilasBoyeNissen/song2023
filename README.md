This script takes two images as input:
(1) one image illustrating the red nematic lines, and
(2) one image containing XY resolution information as metadata.
Both input images are based on the same original image.

The script allows the user to draw two regions of interest (ROIs), thereby dividing the nematic lines into two groups (a red and a blue ROI).

The script outputs:
(1) one histogram showing the lengths (in um) of the nematic lines inside each ROI.
(2) two polar histograms illustrating the angle (in degrees relative to the x-axis) of the nematic lines inside each ROI.
(3) the two drawn ROIs with two numbers separated by a semi-colon next to each nematic line: its length and angle.
(4) one excel file with one row per nematic line and the columns being which ROI the nematic line belongs to (ROI1 or ROI2), the left-most (x1, y1) and right-most (x2, y2) coordinates of the nematic line, its length (in um), and it's angle (in degrees relative to the x-axis).

A screenshot has been uploaded to the output folder to illustrate one example of how the script works.

For questions, please get in touch with silas@nbi.ku.dk.
