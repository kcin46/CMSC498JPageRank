class CommentNode
	attr_accessor "text" , "from", "to"
	def initialize(text, from,to)
		@text = text	
		@from = from
		@to = to
	
	end
end