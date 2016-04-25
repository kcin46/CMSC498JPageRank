class SubredditInfo
	attr_accessor "name" , "posts", "posts_map"
	def initialize(name, posts)
		@name = name	
		@posts = posts
		@posts_map = Hash.new ()	
	end
	def add_post(link)
		@posts << link
	end

end