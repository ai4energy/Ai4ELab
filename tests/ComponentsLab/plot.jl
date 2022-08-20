using PlotlyJS, LightGraphs
using  GraphPlot  # for spring_layout

# # Generate a random layout
# G =  LightGraphs.euclidean_graph(200, 2, cutoff=0.125)[1]
# # Position nodes
# pos_x, pos_y = GraphPlot.circular_layout(G)


G₁ = Graph(3) # graph with 3 vertices

# make a triangle
add_edge!(G₁, 1, 2)
add_edge!(G₁, 1, 3)
add_edge!(G₁, 2, 3)

gplot(G₁, nodelabel=1:3)