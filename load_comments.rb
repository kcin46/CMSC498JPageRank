require 'json'
require_relative "CommentNode.rb"
@count =0

def loadcomments(file_name,sub,subreddits,comment_nodes,map)
	f = File.open(file_name,"r")
	str = ""
	f.each{|line| str+=str+line}
	j=JSON.load(str)
	post_1 = j[sub][0]
	post_2 = j[sub][1]
	post_3 = j[sub][2]

	grab_link = Proc.new {
		|comment| 
		@count+=1
		if(comment =~ /r\/([a-zA-Z_0-9]+)/)
			m=/r\/([a-zA-Z0-9_]+)/.match(comment)
			to_sub = m[1].downcase

			if(subreddits.include?(to_sub) and to_sub!=sub.downcase )
				comment_node= CommentNode.new(comment,sub.downcase,to_sub)
				if(map[sub.downcase] == nil)
					comment_nodes<<comment_node
					map[sub.downcase]= Hash.new
					map[sub.downcase][to_sub] = true
				elsif(map[sub.downcase][to_sub] == nil)
					comment_nodes<<comment_node
					map[sub.downcase][to_sub] = true
				end
			end

		end
	}
	post_1.each{|comment| grab_link.call(comment)}
	post_2.each{|comment| grab_link.call(comment)}
	post_2.each{|comment| grab_link.call(comment)}
	f.close
end
def test_file(file_name, subs)
	f = File.open(file_name, "r")
	str = ""
	f.each{|line| str+=str+line}
	j=JSON.load(str)

	check_exists = Proc.new{|sub| if j[sub] ==nil then puts sub end}
	subs.each{
		|sub|
		check_exists.call(sub)
	}


end

def get_subreddits()
	subreddits= []
	Dir.foreach('./json_files') do |file_name|
		next if file_name == '.' or file_name == '..'
		total_file_path = "./json_files/"+file_name	
		matcher = m=/([a-zA-Z0-9_]+)_json/.match(file_name)
		sub_name = m[1].downcase
		subreddits<<sub_name

	end
	return subreddits
end
def load_all()
	subreddits = get_subreddits
	comment_nodes = []
	map = Hash.new


	Dir.foreach('./json_files') do |file_name|
		next if file_name == '.' or file_name == '..'
		total_file_path = "./json_files/"+file_name	
  		matcher = m=/([a-zA-Z0-9_]+)_json/.match(file_name)
  		sub_name = m[1]
  		loadcomments(total_file_path, sub_name,subreddits,comment_nodes,map)
  	
	end
	return comment_nodes
end

def print_contents(comment_nodes)
	comment_nodes.each{
		|node|
		puts "From: #{node.from} To: #{node.to}"
	}
end
def print_out_edges(comment_nodes)
	visited =[]
	comment_nodes.each{
		|comment_node|
		to = comment_node.to
		if(!visited.include?(to))
			
			visited<<to
		end
	}
	subreddits = get_subreddits()
	subreddits.each{|sub| if(!visited.include?(sub)) then puts sub end}
end

#test_file("./json_files/pics_json", j_0)
# loadcomments("./json_files/RealGirls_json","bicycling")
comment_nodes = load_all()
#print_out_edges(comment_nodes)
# print_out_edges(comment_nodes)