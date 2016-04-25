class SubredditNode
	attr_accessor "name" , "inLinks", "outLinks"
	def initialize(name, inLinks, outLinks)
		@name = name	
		@inLinks = inLinks
		@outLinks = outLinks
	end
	
	def toString()
		puts "Node name is: " + @name + "\n"
		puts "IN-LINKS are :\n"
		iLinks = ""
		@inLinks.each{ |l|
			iLinks = iLinks + l
		}
		puts iLinks
		puts "OUT-LINKS are :\n"
		outL = ""
		@outLinks.each { |l|
			outL = outL + l
		}
		puts outL
	end
end
