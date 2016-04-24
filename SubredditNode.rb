class SubredditNode
	attr_accessor "name" , "neighbors"
	def initialize(name, neighbors)
		@name = name	
		@neighbors = neighbors	
	end
end