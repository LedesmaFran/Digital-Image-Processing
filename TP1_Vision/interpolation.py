import numpy as np

def bilinear_interpolation(img_in, target_size):
    # Expand an image (img_in) to a target_size via bilinear interpolation.

    # Input image parameters
    width_in, height_in = np.shape(img_in)
    
    # Output image and parameters
    width_out = target_size[0]
    height_out = target_size[1]
    img_out = np.zeros(target_size)

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


def bicubic_interpolation(img_in, target_size, a):
    # Expand an image (img_in) to a target_size via bicubic interpolation using coefficient a for bicubic kernel.
    
    # Input image parameters
    width_in, height_in = np.shape(img_in)
  
    # Pad the input image
    img_in = padding(img_in)
  
    # Output image
    height_out = target_size[1]
    width_out = target_size[0]
    img_out = np.zeros(target_size)
  
    for i in range(height_out):
        for j in range(width_out):

            # Getting the coordinates of the nearby values in input space
            x, y = j * (width_in/width_out) + 2, i * (height_in/height_out) + 2

            x1 = 1 + x - np.floor(x)
            x2 = x - np.floor(x)
            x3 = np.floor(x) + 1 - x
            x4 = np.floor(x) + 2 - x

            y1 = 1 + y - np.floor(y)
            y2 = y - np.floor(y)
            y3 = np.floor(y) + 1 - y
            y4 = np.floor(y) + 2 - y

            # Considering all nearby 16 values
            mat_l = np.matrix([[W(x1, a), W(x2, a), W(x3, a), W(x4, a)]])
            
            mat_m = np.matrix([[img_in[int(x-x1)][int(y-y1)], img_in[int(x-x1)][int(y-y2)], img_in[int(x-x1)][int(y+y3)], img_in[int(x-x1)][int(y+y4)]],
                               [img_in[int(x-x2)][int(y-y1)], img_in[int(x-x2)][int(y-y2)], img_in[int(x-x2)][int(y+y3)], img_in[int(x-x2)][int(y+y4)]],
                               [img_in[int(x+x3)][int(y-y1)], img_in[int(x+x3)][int(y-y2)], img_in[int(x+x3)][int(y+y3)], img_in[int(x+x3)][int(y+y4)]],
                               [img_in[int(x+x4)][int(y-y1)], img_in[int(x+x4)][int(y-y2)],  img_in[int(x+x4)][int(y+y3)], img_in[int(x+x4)][int(y+y4)]]])
            
            mat_r = np.matrix([[W(y1, a)], [W(y2, a)], [W(y3, a)], [W(y4, a)]])
                
            img_out[j][i] = np.dot(np.dot(mat_l, mat_m), mat_r)
  
    return img_out


# Bicubic interpolation kernel
def W(x, a):

    if (abs(x) >= 0) & (abs(x) <= 1):
        return (a+2)*(abs(x)**3)-(a+3)*(abs(x)**2)+1
        
    elif (abs(x) > 1) & (abs(x) <= 2):
        return a*(abs(x)**3)-(5*a)*(abs(x)**2)+(8*a)*abs(x)-4*a
    return 0


# Padding for input image in bicubic interpolation
def padding(img):

    width, height = np.shape(img)

    padded_img = np.zeros((width+4,height+4))
    
    padded_img[2:width+2, 2:height+2] = img

    #Pad the first/last two col and row
    padded_img[0:2, 2:height+2] = img[0:1, :]
    padded_img[2:width+2, height+2:height+4] = img[:, height-1:height]
    padded_img[width+2:width+4, 2:height+2] = img[width-1:width, :]
    padded_img[2:width+2, :2] = img[:, 0:1]
    
    #Pad the missing eight points
    padded_img[0:2, 0:2] = img[0, 0]
    padded_img[0:2][height+2:height+4] = img[0, height-1]
    padded_img[width+2:width+4, height+2:height+4] = img[width-1, height-1]
    padded_img[width+2:width+4, 0:2] = img[width-1, 0]
    return padded_img