require_relative 'CommentNode'
require_relative 'SubredditNode'

def createGraph(comments)
	graph = {}
	
	comments.each { |c|
		#Create a SubredditNode for from or to if need be
		if(!graph.keys.include?(c.from))
			fromNode = SubredditNode.new(c.from, [], [])
			graph[c.from] = fromNode
		else
			fromNode = graph[c.from]
		end

		if(!graph.keys.include?(c.to))
			toNode = SubredditNode.new(c.to, [], [])
			graph[c.to] = toNode
		else
			toNode = graph[c.to]
		end

		fromNode.outLinks << c.to
		toNode.inLinks << c.from
	}
	
	return graph
end

def pageRank(graph)
	rank = {}
	updatedRank = {}
	k = 1
	init_rank = Rational(1, graph.keys.length).to_f

	#Initalizes each node to have 1/n as its rank
	graph.keys.each{ |n|
		rank[n] = init_rank
		updatedRank[n] = Rational(0,1)	
	}
	
	k.times do
		graph.keys.each { |g|
			currNode = graph[g]
			updatedVal = Rational(0, 1)
			currNode.inLinks.each{ |inL|
				iNode = graph[inL]
				inVal = rank[inL]
			updatedVal += Rational(inVal, iNode.outLinks.length).to_f
			}
			#puts "currNode: " + g + "updatedVal: " + updatedVal.to_s
			updatedRank[g] = updatedVal
		}
		if(updatedRank == rank)
			#puts "IT CONVERGED"
			#puts rank
			break
		else
			rank = updatedRank
		end
	end
	
	return rank
end

a = CommentNode.new("","a" ,"b")
b = CommentNode.new("","a", "c") 
c = CommentNode.new("", "d", "a")
d = CommentNode.new("","g" ,"a")
e = CommentNode.new("","d" ,"h")  
f = CommentNode.new("", "b", "d")
g = CommentNode.new("","b","e")  
h = CommentNode.new("", "e", "h")
i = CommentNode.new("","e", "a") 
j = CommentNode.new("", "h", "a")
k = CommentNode.new("","c", "f")
l = CommentNode.new("", "c", "g")
m = CommentNode.new("","f", "a")
comments = [a,b,c,d,e,f,g,h,i,j,k,l,m]
res = createGraph(comments)
ranks = pageRank(res)
puts ranks
