import math
import random
import argparse
import numpy as np


def regular_dodecahedron(density=1):
    phi = (1 + math.sqrt(5)) / 2  # Golden ratio

    vertices = [
        (x, y, z) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)
    ]  # (±1, ±1, ±1)

    vertices += [
        (0, y * phi, z / phi) for y in (-1, 1) for z in (-1, 1)
    ]  # (0, ±ϕ, ±1/ϕ)

    vertices += [
        (x / phi, 0, z * phi) for x in (-1, 1) for z in (-1, 1)
    ]  # (±1/ϕ, 0, ±ϕ)

    vertices += [
        (x * phi, y / phi, 0) for x in (-1, 1) for y in (-1, 1)
    ]  # (±ϕ, ±1/ϕ, 0)

    # Generate EPS commands
    regular_dodecahedron_commands = ""
    for i in range(len(vertices) - 1):
        for j in range(i + 1, len(vertices)):
            if random.random() < density:
                p1 = vertices[i]
                p2 = vertices[j]
                regular_dodecahedron_commands += f"newpath {100 + 50 * p1[0]} {100 + 50 * p1[1]} moveto {100 + 50 * p2[0]} {100 + 50 * p2[1]} lineto stroke\n"

    return regular_dodecahedron_commands


def tetartoid(a, b, c):
    # Check the conditions
    if not (0 <= a <= b <= c):
        raise ValueError("The conditions 0 <= a <= b <= c must be satisfied")

    n = a**2 * c - b * c**2
    d1 = a**2 - a * b + b**2 + a * c - 2 * b * c
    d2 = a**2 + a * b + b**2 - a * c - 2 * b * c

    if n * d1 * d2 == 0:
        raise ValueError("The condition nd1d2 != 0 must be satisfied")

    vertices = [
        (a, b, c), (-a, -b, c), (-n/d1, -n/d1, n/d1), (-c, -a, b), (-n/d2, n/d2, n/d2)
    ]

    # Generate EPS commands
    tetartoid_commands = ""
    for i in range(len(vertices) - 1):
        for j in range(i + 1, len(vertices)):
            p1 = vertices[i]
            p2 = vertices[j]
            tetartoid_commands += f"newpath {100 + 50 * p1[0]} {100 + 50 * p1[1]} moveto {100 + 50 * p2[0]} {100 + 50 * p2[1]} lineto stroke\n"

    return tetartoid_commands


def pyritohedron(h):
    # Cube vertices
    vertices = [(x, y, z) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)]

    # Additional vertices
    vertices += [(0, y * (1 + h), z * (1 - h**2)) for y in (-1, 1) for z in (-1, 1)]
    vertices += [(x * (1 + h), y * (1 - h**2), 0) for x in (-1, 1) for y in (-1, 1)]
    vertices += [(x * (1 - h**2), 0, z * (1 + h)) for x in (-1, 1) for z in (-1, 1)]

    # Edges
    edges = [(i, j) for i in range(8) for j in range(i+1, 8)]
    edges += [(i, j) for i in range(8, 12) for j in range(i+1, 12)]
    edges += [(i, j) for i in range(8) for j in range(8, 12)]

    pyritohedron_commands = ""
    for edge in edges:
        p1 = vertices[edge[0]]
        p2 = vertices[edge[1]]
        pyritohedron_commands += f"newpath {100 + 50 * p1[0]} {100 + 50 * p1[1]} moveto {100 + 50 * p2[0]} {100 + 50 * p2[1]} lineto stroke\n"

    return pyritohedron_commands


def icosahedron():
    phi = (1 + math.sqrt(5)) / 2  # Golden ratio

    # Vertices
    vertices = [
        (-1, phi, 0), (1, phi, 0), (-1, -phi, 0), (1, -phi, 0),
        (0, -1, phi), (0, 1, phi), (0, -1, -phi), (0, 1, -phi),
        (phi, 0, -1), (phi, 0, 1), (-phi, 0, -1), (-phi, 0, 1)
    ]

    # Edges
    edges = [
        (0, 1), (0, 5), (0, 7), (0, 10), (0, 11),
        (1, 3), (1, 5), (1, 8), (1, 9),
        (2, 3), (2, 4), (2, 6), (2, 10), (2, 11),
        (3, 6), (3, 8),
        (4, 5), (4, 7), (4, 9), (4, 11),
        (5, 7),
        (6, 8), (6, 10),
        (7, 9), (7, 11),
        (8, 9),
        (10, 11)
    ]

    # Generate EPS commands
    icosahedron_commands = ""
    for edge in edges:
        p1 = vertices[edge[0]]
        p2 = vertices[edge[1]]
        icosahedron_commands += f"newpath {100 + 50 * p1[0]} {100 + 50 * p1[1]} moveto {100 + 50 * p2[0]} {100 + 50 * p2[1]} lineto stroke\n"

    return icosahedron_commands


def rotate_x(angle):
    """Return a rotation matrix for a given angle around the x-axis."""
    return np.array([
        [1, 0, 0],
        [0, np.cos(angle), -np.sin(angle)],
        [0, np.sin(angle), np.cos(angle)]
    ])

def rotate_y(angle):
    """Return a rotation matrix for a given angle around the y-axis."""
    return np.array([
        [np.cos(angle), 0, np.sin(angle)],
        [0, 1, 0],
        [-np.sin(angle), 0, np.cos(angle)]
    ])

def cube():
    # Vertices
    vertices = [(x, y, z) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)]

    # Edges
    edges = [
        (0, 1), (0, 2), (0, 4),
        (7, 6), (7, 5), (7, 3),
        (1, 3), (1, 5),
        (2, 6), (2, 3),
        (4, 5), (4, 6)
    ]

    # Rotate the vertices
    rotation = np.dot(rotate_x(np.pi / 2.9), rotate_y(np.pi / 1.6))
    vertices = [np.dot(rotation, vertex) for vertex in vertices]

    # Generate EPS commands
    cube_commands = ""
    for edge in edges:
        p1 = vertices[edge[0]]
        p2 = vertices[edge[1]]
        cube_commands += f"newpath {100 + 50 * p1[0]} {100 + 50 * p1[1]} moveto {100 + 50 * p2[0]} {100 + 50 * p2[1]} lineto stroke\n"

    return cube_commands


def write_to_file(filename, commands, box_width, box_height):
    with open(filename, 'w') as f:
        f.write("%!PS-Adobe-3.0 EPSF-3.0\n")
        f.write(f"%%BoundingBox: 0 0 {box_width} {box_height}\n")
        f.write(commands)
        f.write("\nstroke\n")
        f.write("showpage\n")
    print(f"{filename} saved as {filename}.eps")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate shapes and save as EPS files.')
    parser.add_argument('output_dir', type=str, default=".", help='The directory where the EPS files will be saved.')
    args = parser.parse_args()
    output_dir = args.output_dir

    box_width, box_height = 200, 200

    tetartoid_commands = tetartoid(1,1.5,2)
    write_to_file("shape_0.eps", tetartoid_commands, box_width, box_height)

    regular_dodecahedron_commands = regular_dodecahedron()
    write_to_file("shape_1.eps", regular_dodecahedron_commands, box_width, box_height)

    pyritohedron_commands = pyritohedron(2 / (1 + math.sqrt(5)))
    write_to_file("shape_2.eps", pyritohedron_commands, box_width, box_height)

    icosahedron_commands = icosahedron()
    write_to_file("shape_3.eps", icosahedron_commands, box_width, box_height)

    cube_commands = cube()
    write_to_file("shape_4.eps", cube_commands, box_width, box_height)