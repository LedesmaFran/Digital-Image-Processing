import matplotlib.pyplot as plt

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
