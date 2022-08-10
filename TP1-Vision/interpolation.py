import numpy as np

def bilinear_interpolation(img_in, target_size):
    # Expand an image (img_in) to a target_size via bilinear interpolation

    img_out = np.zeros(target_size)
    width_in, height_in = np.shape(img_in)
    
    width_out = target_size[0]
    height_out = target_size[1]

    for i in range(height_out):
        for j in range(width_out):
            # Absolute coordinates of the pixel in input space
            x_in = j * width_in/width_out 
            y_in = i * height_in/height_out 

            # Nearest neighbours coordinates in input space
            x1 = int(np.floor(x_in))
            x2 = x1 + 1
            y1 = int(np.floor(y_in))
            y2 = y1 + 1

            # Sanitize bounds - no need to check for < 0
            x1 = min(x1, width_in - 2)
            x2 = min(x2, width_in - 1)
            y1 = min(y1, height_in - 2)
            y2 = min(y2, height_in - 1)
            
            # Distances between neighbour nodes in input space
            dy2 = y2 - y_in
            dy1 = 1. - dy2 # because next - prev = 1
            dx2 = x2 - x_in
            dx1 = 1. - dx2 # because next - prev = 1
            
            img_out[j][i] = dy1 * (img_in[x1][y2] * dx2 + img_in[x2][y2] * dx1) \
            + dy2 * (img_in[x1][y1] * dx2 + img_in[x2][y1] * dx1)
                
    return img_out