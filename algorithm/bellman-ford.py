# Authors
# Stanko Krtalic Rusendic - 0036463148
# Tamara Milisa - 0036485913
# Petar Podbreznicki - 0036485789
# Marin Maskarin - 0036488957
# Filip Zivkovic - 0036495836
# Fran Kosec - 0036465847

# Implementation of Bellman-Ford algorithm

import sys
import getopt
from operator import itemgetter

class Graph:
    # A graph contains vertices and edges
    def __init__(self):
        self.vertices = 0
        self.edges = []

    # Count all the vertices in the graph
    def count_vertices(self):
        vertices = []
        for node_1, node_2, weight in self.edges:
            vertices.extend([node_1, node_2])
        self.vertices = len(set(vertices))

    # Add an edge to the graph
    def add_edge(self, node_1, node_2, weight):
        self.edges.append([node_1, node_2, weight])
        self.count_vertices()

    # Print distances
    def print_state(self, distance):
        print("Vertex   Distance from Source")
        for i in range(self.vertices):
            if distance[i] == float('Inf'):
                print("%d \t\t %s" % (i, 'Inf'))
            else:
                print("%d \t\t %d" % (i, distance[i]))

    # Print the whole graph
    def print_graph(self):
        print('Node 1  Node 2  Weight')
        for node_1, node_2, weight in sorted(self.edges, key=itemgetter(0)):
            print("  %d \t %d \t %d" % (node_1, node_2, weight))

    # The main algorithm.
    def bellman_ford(self, source):
        negative_cycle = False
        # Print the whole graph
        self.print_graph()

        # Set source vertex distance to 0 and all others to Inf
        print('\nSet source vertex distance to 0 and all others to Inf')
        distance = [float('Inf')] * self.vertices
        distance[source] = 0

        for i in range(self.vertices - 1):
            # Update distance value and parent index of the adjacent vertices of
            # the picked vertex.
            print('\nPass %d' % (i+1))
            for node_1, node_2, weight in self.edges:
                if distance[node_1] != float("Inf") and distance[node_1] + weight < distance[node_2]:
                    distance[node_2] = distance[node_1] + weight
                    print('\nFound a shorter distance from node %d to node %d via node %d' % (source, node_2, node_1))
                    self.print_state(distance)

        # Check for negative-weight cycles. If we get a shorter path than before,
        # a cycle exists. This is the len(self.vertices)th loop
        for node_1, node_2, weight in self.edges:
            if distance[node_1] != float("Inf") and distance[node_1] + weight < distance[node_2]:
                negative_cycle = True

        print('\nPass %d' % (self.vertices))
        if negative_cycle:
            print("Graph contains a negative weight cycle.")
        else:
            print("Negative cycle not found.")
            print('\nFinal solution:')
            self.print_state(distance)

# Print the correct command line usage
def usage():
    print('bellman-ford.py -f <inputfile> -s <source>')

# Parse the input parameters, C-like style
def parse_command_line_arguments():
    # Catch input arguments
    try:
        options, arguments = getopt.getopt(sys.argv[1:], 'hf:s:', ['help', 'file=', 'source='])
    except getopt.GetoptError as error:
        print(error)
        sys.exit(2)
    # Put input arguments in variables
    for option, argument in options:
        if option in ('-h', '--help'):
            usage()
            sys.exit()
        elif option in ('-f', '--file'):
            inputfile = argument
        elif option in ('-s', '--source'):
            source = int(argument)
    # Check if both input arguments exist
    try:
        inputfile
        source
    except NameError:
        print('A parameter is missing.')
        usage()
        sys.exit(2)

    return inputfile,source

# Parse the input file
def parse_file(file):
    input_array = []
    file = open(file, 'r')
    for line in file:
        split_line = line.strip('\n').split(' ')
        input_array.append(list(map(int, split_line[:3])))
        if split_line[3] == 'n':
            input_array.append(list(map(int, [split_line[1], split_line[0], split_line[2]])))
    file.close()
    return input_array

# Main method
def main():
    inputfile,source = parse_command_line_arguments()
    input_array = parse_file(inputfile)

    graph = Graph()

    for node_1, node_2, weight in input_array:
        graph.add_edge(node_1, node_2, weight)

    graph.bellman_ford(source)

    sys.exit()

if __name__ == "__main__":
    main()
