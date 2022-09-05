def imadjust(x,a,b,c,d):
    # Similar to imadjust in MATLAB.
    # Converts an image range from [a,b] to [c,d].
    x_a = x < a
    x_b = x > b
    y = x.copy()
    y[x_a] = c
    y[x_b] = d
    return y