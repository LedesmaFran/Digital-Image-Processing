import matplotlib.pyplot as plt
from matplotlib import colors
import numpy as np
import cv2

def circular_kernel(diameter):
    mid = (diameter - 1) / 2
    distances = np.indices((diameter, diameter)) - np.array([mid, mid])[:, None, None]
    kernel = ((np.linalg.norm(distances, axis=0) - mid) <= 0).astype(np.uint8)
    return kernel