#!/usr/bin/env python3


def get_layers(width, height, data):
    pixels_per_layer = width * height
    n_layers = len(data) // pixels_per_layer
    for i in range(n_layers):
        start = (i * pixels_per_layer)
        end = ((i + 1) * pixels_per_layer)
        layer = data[start:end]
        yield layer


def render_layers(width, height, layers):
    retval = ""
    for y in range(height):
        for x in range(width):
            pos = (y * width) + x
            for layer in layers:
                if layer[pos] == "0":
                    retval += " "
                    break
                elif layer[pos] == "1":
                    retval += "*"
                    break
                elif layer[pos] == "2":
                    continue
            else:
                retval += "?"
        retval += "\n"
    return retval


if __name__ == "__main__":
    data = "123456789012"
    layers = list(get_layers(3, 2, data))

    data = open("8-input.txt").read()
    layers = list(get_layers(25, 6, data))

    zeros = [(layer.count("0"), layer) for layer in layers]
    zeros.sort()
    layer = zeros[0][1]
    #print(zeros[0])
    print(layer.count("1") * layer.count("2"))

    print(render_layers(25, 6, layers))
