class SubredditInfo
	attr_accessor "name" , "posts"
	def initialize(name, posts)
		@name = name	
		@posts = posts	
	end
	def add_post(link)
		@posts << link
	end
end