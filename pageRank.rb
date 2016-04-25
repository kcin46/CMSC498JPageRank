require 'node.rb'

def calculatePageRank(graph)
	rank = {}
	init_rank = Rational
	init_rank = Rational(1, graph.keys.length).to_f
	
	#Initializes each node to have 1/n as rank
	graph.keys.each { |node|
		rank[node] = init_rank
	}
	
	tmp = {}
	while(tmp != rank)
		tmp = rank.clone
		rank.keys.each { |k|
			newRank = 0
			graph[k].each { |neighbor|
				newRank = newRank + Rational(rank[k], graph[neighbor].length)
			}
			rank[k] = newRank	
		}
		puts rank
	end
	
end

g = {}
g[1] = [2,3,4]
g[2] = [1,3]
g[3] = [1,2]
g[4] = [1]

calculatePageRank(g)
