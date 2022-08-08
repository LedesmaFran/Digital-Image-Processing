import numpy as np

def bilinear_interpolation(img_in, target_size):
    # Expand an image (img_in) to a target_size via bilinear interpolation

    img_out = np.zeros(target_size)
    width_in, height_in = np.shape(img_in)
    
    width_out = target_size[0]
    height_out = target_size[1]

    for i in range(width_out):
        for j in range(height_out):
            # Coordinates of the pixel in input space
            x_in = i  * width_in / width_out
            y_in = j  * height_in / height_out

            # Nearest neighbours coordinates in input space
            x1 = int(np.floor(x_in))
            x2 = x1 + 1
            y1 = int(np.floor(y_in))
            y2 = y1 + 1

            # Sanitize bounds - no need to check for < 0
            x1 = min(x1, width_in - 1)
            x2 = min(x2, width_in - 1)
            y1 = min(y1, height_in - 1)
            y2 = min(y2, height_in - 1)
            

            # Distances between neighbour nodes in input space
            Dy_next = y2 - y_in
            Dy_prev = 1. - Dy_next # because next - prev = 1
            Dx_next = x2 - x_in
            Dx_prev = 1. - Dx_next; # because next - prev = 1
            
            # Interpolate
            img_out[i][j] = Dy_prev * (img_in[x2][y1] * Dx_next + img_in[x2][y2] * Dx_prev) \
            + Dy_next * (img_in[x1][y1] * Dx_next + img_in[x1][y2] * Dx_prev)
            '''
            x1_out = x1*width_out/width_in
            x2_out = x2*width_out/width_in
            y1_out = y1*height_out/height_in
            y2_out = y2*height_out/height_in
            
            img_out[i][j] = (img_in[x1][y1] * (x2_out - i) * (y2_out - j) +
                            img_in[x2][y1]  * (i - x1_out) * (y2_out - j) +
                            img_in[x1][y2] * (x2_out - i) * (j - y1_out) +
                            img_in[x2][y2] * (j - x1_out) * (j - y1_out)
                            ) / ((x2_out - x1_out) * (y2_out - y1_out) + 0.0)
            '''
    return img_out