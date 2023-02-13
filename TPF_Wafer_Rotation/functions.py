import matplotlib.pyplot as plt
import serial
import numpy as np
import cv2
from skimage.transform import hough_line, hough_line_peaks

def compare(images,size=(14,10)):
    fig=plt.figure(figsize=size)
    n_images = len(images)
    i=1
    for key, value in images.items():
        fig.add_subplot(1, n_images, i)
        plt.title(key)
        plt.imshow(value,cmap='gray')
        i+=1

def binary_mask(img, threshold):
    keep = img > threshold
    dump = img < threshold
    mask = img.copy()
    mask[keep] = 255
    mask[dump] = 0
    return mask

def hough_transform(img):
    # Hough transform and lines drawing
    # ---------------------------------
    tested_angles = np.linspace(-np.pi/2,np.pi/2,180)
    hspace, theta, dist = hough_line(img, tested_angles)
    h, q, d = hough_line_peaks(hspace, theta, dist)

    angle_list=[]  #Create an empty list to capture all angles

    origin = np.array((0, img.shape[1]))

    img_lines = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)

    for _, angle, dist in zip(*hough_line_peaks(hspace, theta, dist)):
        y0, y1 = (dist - origin * np.cos(angle)) / np.sin(angle)
        cv2.line(img_lines,(origin[0],int(y0)),(origin[1],int(y1)),(0,0,255),2)
        if angle not in angle_list:
            angle_list.append(angle) #Not for plotting but later calculation of angles
            texto = f'Angle: {np.round((angle*180/np.pi)-90,5)}°'
            print(texto)
    
    return img_lines

def process_in_fpga(img, w, h, baudrate, port):
    result = None
    uart = serial.Serial(port=port, baudrate=baudrate, timeout=15, write_timeout=15)
    uart.set_buffer_size(tx_size=h*w, rx_size=h*w)
    data = img.tobytes()
    try:
        written = uart.write(data)
    except serial.SerialTimeoutException:
        print('Timeout catch')

    rx = uart.read(uart.in_waiting)
    if len(rx) == ((h-4)*(w-4)):
        result = np.frombuffer(rx, dtype=np.uint8).reshape((h-4,w-4))
    else:
        print(f"Didn't get {written} written bytes, got {len(rx)} instead.")
    uart.close()
    return result
