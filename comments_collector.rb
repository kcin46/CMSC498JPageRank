require 'net/http'
require 'json'
# require_relative "CommentNode.rb"
# require_relative "SubredditNode.rb"
require_relative "SubredditInfo.rb"


def get_json(link)
	json = nil
	begin
		uri = URI(link)
		# puts uri
		res = Net::HTTP.get_response(uri)
		json = JSON.load(res.body)
	rescue
		return get_json(link)
	end 
	return json
end
def get_comments(link,more_ids, comments_text)
	# puts link

	json = get_json(link)

	json[1]["data"]["children"].each{
		|root_comment|

		get_comments_helper(root_comment, comments_text, more_ids)

	}


	 # puts json[1]["data"]["children"][0]["data"]["replies"]["data"]["children"][0]
end


def get_comments_helper (comment, comments_text, more_ids)
	comment_data = comment["data"]
	if(comment_data == nil )
		return 
	end

	if(comment["kind"] != "more")
		comment_text = comment_data["body"]
		comments_text << comment_text
	else
		comment_data["children"].each{
			|more_id|
			more_ids << more_id
		}
	end
	if(comment_data["replies"] !=nil  && comment_data["replies"]["data"] != nil&&comment_data["replies"]["data"]["children"]!=nil ) 
		comment_data["replies"]["data"]["children"].each{
			|reply|
			if(reply["kind"] != "more" )
				get_comments_helper(reply, comments_text,more_ids)
			else
				 reply["data"]["children"].each{
					|reply_id|
					more_ids << reply_id
				}

			end
		}
	end
end

def traverse_more (link,more_ids,comments_text)

	i =0 ;

	total = more_ids.length
	threads = []
	more_ids.each_slice(50) {|a| 
		 t = Thread.new{apply(a,link,more_ids,comments_text)}
		 threads << t
	}	
	threads.each{
		|thread|
		thread.join()
	}

end

def apply(ids,link,more_ids,comments_text)
	ids.each{
		|id|
		link2 = link.dup
		
		link2 = link[0..(link.length-6)]
	
		new_link = link2+id+"/.json"
		
		get_comments(new_link,more_ids,comments_text)
		STDOUT.flush
}
end






def split_by_sub (comments_map,sub_package)
	sub_name = sub_package["sub_name"]
	links = sub_package["links"]
	if(comments_map[sub_name] == nil)
		comments_map[sub_name] = []
	end
	links.each{
		|link|
		comments = []
		more_ids = []
		get_comments(link,more_ids,comments)
		traverse_more(link, more_ids,comments)
		comments_map[sub_name] << comments
	}	
	puts "completed a sub package"
	puts comments_map
	f2 = File.new(sub_name+"_json", "w")
	f2.puts JSON.generate(comments_map)
end
def get_comments_by_sub(sub)
	all_comments = []
	sub.posts.each{
		|link|
	
		more_ids = []
		get_comments(link,more_ids,all_comments)
		traverse_more(link,more_ids,all_comments)

	}
	return all_comments
end

def read_jobs_file(jobs_file)
	file = File.open(jobs_file,"r")
	json_string = ""
	file.each{
		|line|
		json_string += line
	}
	return JSON.load(json_string)
end


def main 
	job_num = ARGV[0]
	jobs_file = ARGV[1]
	if job_num == nil
		raise(ArgumentError, "please provide your assigned job number")
	end
	if jobs_file ==nil
		raise(ArgumentError, "Please provide the jobs file")
	end
	
	json_jobs= read_jobs_file(jobs_file)
	my_job= json_jobs[Integer(job_num)]
	
	comments_map = Hash.new {  }
	# puts "Getting Comments Now"
	f=File.new("jobs_result", "w")
	threads = []
	my_job.each{
		|sub_package|
		t = Thread.new{split_by_sub(comments_map, sub_package)}
		threads << t
	}	
	threads.each{
		|thread|
		thread.join(14400)
	}
	
	results = JSON.generate(comments_map)

	f.puts results




end

main()
# comments = []
# more_ids = []
# link = "https://www.reddit.com/r/mildlyinfuriating/comments/4g82xn/my_provider_censoring_me_on_my_own_phone"
# get_comments(link, more_ids,comments)
# traverse_more(link,more_ids,comments)
# a= JSON.generate({"sub" => "mildlyinfuriating", "comments" => comments})
