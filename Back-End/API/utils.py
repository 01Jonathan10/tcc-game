def rgb_to_color(rgba):
    return "#{0:02x}{1:02x}{2:02x}".format(int(rgba[0] * 255), int(rgba[1] * 255), int(rgba[2] * 255))
