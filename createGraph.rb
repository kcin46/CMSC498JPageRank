require_relative 'CommentNode'
require_relative 'SubredditNode'
require_relative 'load_comments'
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
	k = 10000
	s = 0.8
	s2 = 0.2
	n = graph.keys.size
	s3 = Rational(s2, n)
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
			if(currNode.inLinks.size == 0)
				updatedVal = 0.0
			end
			currNode.inLinks.each{ |inL|
				iNode = graph[inL]
				inVal = rank[inL]
				updatedVal += Rational(inVal, iNode.outLinks.length).to_f
			}
			
			if(currNode.outLinks.size == 0)
				updatedRank[g] = rank[g] + updatedVal
			else
				updatedRank[g] = updatedVal
			end
		}
			if(rank.eql?(updatedRank))
				puts "Converged"
			end
			rank = updatedRank.clone
	end
	
	rank.keys.each { |k|
		rank[k] = (rank[k] * s) + s3
	}
	
	return rank
end
def Main
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
	total = 0
	ranks.keys.each { |k|
		total = total + ranks[k]
	}
	puts ranks
	puts total
end

def createCSV(ranks, graph)
	f = File.new("ranks.csv","w")
	ranks.keys.each{
		|sub|
		ratio = 0.0
		ratio = graph[sub].inLinks.length/graph[sub].outLinks.length.to_f
		if(graph[sub].outLinks.length == 0)
			ratio = 0.0
		end
		f.puts("#{sub},#{ranks[sub]},#{ratio}")
	}
end
comments =load_all()
res= createGraph(comments)
ranks = pageRank(res)
total = 0
ranks.keys.each { |k|
	total = total + ranks[k]
}
puts JSON.generate(ranks)
puts total
createCSV(ranks, res)
