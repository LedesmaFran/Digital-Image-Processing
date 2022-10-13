import matplotlib.pyplot as plt
from matplotlib import colors
import numpy as np
import cv2

def plot_scatter_3d(data,labels):
    r, g, b = cv2.split(data) # Splitting components of image
    xlabel, ylabel, zlabel = labels
    # Creating Figure for 3D plot
    fig = plt.figure(figsize=(10,10))
    axis = fig.add_subplot(1, 1, 1, projection="3d")

    # Normalising list of pixels
    pixel_colors = data.reshape((np.shape(data)[0] * np.shape(data)[1], 3))
    norm = colors.Normalize(vmin=-1.0, vmax=1.0)
    norm.autoscale(pixel_colors)
    pixel_colors = norm(pixel_colors).tolist()

    # Plotting
    axis.scatter(r.flatten(), g.flatten(), b.flatten(), facecolors=pixel_colors, marker=".")
    axis.set_xlabel(xlabel)
    axis.set_ylabel(ylabel)
    axis.set_zlabel(zlabel)
    plt.show()

def segment_fish(image):
    ''' Attempts to segment the clownfish out of the provided image '''

    # Convert the image into HSV
    hsv_image = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)

    # Set the orange range
    light_orange = (1, 190, 200)
    dark_orange = (18, 255, 255)

    # Apply the orange mask 
    mask = cv2.inRange(hsv_image, light_orange, dark_orange)

    # Set a white range
    light_white = (0, 0, 200)
    dark_white = (145, 60, 255)

    # Apply the white mask
    mask_white = cv2.inRange(hsv_image, light_white, dark_white)

    # Combine the two masks
    final_mask = mask + mask_white
    result = cv2.bitwise_and(image, image, mask=final_mask)

    # Clean up the segmentation using a blur
    blur = cv2.GaussianBlur(result, (7, 7), 0)
    return blur