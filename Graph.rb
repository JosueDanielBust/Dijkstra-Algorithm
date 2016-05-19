# https://gist.github.com/SauloSilva/732e7982e1d18167a32d
class Graph
	# Create a new object Vertex like Structure with
	# his Name, the near verts, distance and the
	# previous vert
	Vertex = Struct.new(:name, :near, :dist, :prev)

	# Initialize or create an new object of type Graph
	# that get an array of arrays once each contains
	# two verts and a distance of this verts
	# Struct of array => Array[Array[vert1, vert2, dist], Array[...]]
	def initialize(graph)
		# Create the list of vertices into Graph class
		@verts = Hash.new do |key, value|
			key[value] = Vertex.new(value, [], Float::INFINITY)
		end
		# Create the edges or conections for vertice to vertice
		@edges = {}

		# Evaluate each Array into the graph Array (Attribute)
		# Flip-Flop documentation
		# http://ruby-doc.org/core-2.3.1/doc/syntax/control_expressions_rdoc.html#label-Flip-Flop
		graph.each do |(vert1, vert2, dist)|
			@verts[vert1].near << vert2
			@verts[vert2].near << vert1
			@edges[[vert1, vert2]] = @edges[[vert2, vert1]] = dist
		end

		@dijkstra_source = nil
	end

	# Lets do it with Dijkstra Algorithm!
	def dijkstra(source)
		return if @dijkstra_source == source

		# For each vert on @verts assign the weight Infinity and prev null
		queue = @verts.values
		queue.each do |vert|
			vert.dist = Float::INFINITY
			vert.prev = nil
		end

		# Set the distance of the start vertice as 0
		@verts[source].dist = 0

		# Evaluate all vertice on the queue while queue is not empty
		until queue.empty?
			route = queue.min_by {|vertex| vertex.dist}
			break if route.dist == Float::INFINITY

			# Print the trace of each vertex evaluate 
			puts route

			queue.delete(route)
			route.near.each do |v|
				vert = @verts[v]
				if queue.include?(vert)
					alt = route.dist + @edges[[route.name, v]]
					if alt < vert.dist
						vert.dist = alt
						vert.prev = route.name
					end
				end
			end
		end

		@dijkstra_source = source
	end

	# The main of the class...
	# Gets the start point and the final or stop point
	# Return the best and efficient path and the total distance of the path
	def shortest_path(source, target)
		# Call dijkstra!, Create the path array and rename the target variable
		dijkstra(source)
		path = []
		u = target

		while u
			path.unshift(u)
			u = @verts[u].prev
		end

		# Return path and distance of path
		return path, @verts[target].dist
	end
end


# Create the Google Maps Link based on the google url,
# path got it from the dijkstra algorithm and the
# Hash Map of Vertices and coords
def mapLink(path, hash)
	link = "https://www.google.es/maps/dir/"
	path.each { |i|
		link = link + hash[i][0] + "," + hash[i][1] + "/"
	}
	puts link
	launchLink(link)
end

# Launch the link of Google Maps on default browser
# Code got it http://stackoverflow.com/a/14053693
def launchLink(link)
	if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
		system "start #{link}"
	elsif RbConfig::CONFIG['host_os'] =~ /darwin/
		system "open #{link}"
	elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
		system "xdg-open #{link}"
	end
end

# Create the Hash Map for Vertices of each Arc
# Struct of hash => Hash[Arc] = [x, y]
HashVert = Hash.new()
IO.foreach("vert.txt") do |i|
	HashVert[i.split[0].to_i] = [i.split[1], i.split[2]]
end

# Create the Array for the Arcs and his weight
# Struct of Array => Array[Arc1, Arc2, Weight]
ArrArc = Array.new()
IO.foreach("arc.txt") do |i|
	ArrArc.push([i.split[0].to_i, i.split[1].to_i, i.split[2].to_i])
end

# Init execution and calls
# Create a new Graph from the Arcs Array
g = Graph.new( ArrArc )

start, stop = 309026269, 3585942806

path, dist = g.shortest_path(start, stop)

# Exits to console
# 1. Distance or Weight of the path
# 2. Size of the path (Points in the path)
# 3. The best and tiny path for Distance and Weight
puts "Path from #{start} to #{stop} has a distance of #{dist}:"
puts "Path size: " + path.size.to_s
puts "Path: " + path.join(" -> ")
puts ""

# Call the link of Google Maps! or an exception if not is possible
if (path.size < 20)
	#mapLink(path, HashVert)
else
	puts "Exception: The path has more of 20 points, Google not support this petition"
end