require 'net/http'
require 'json'
# require_relative "CommentNode.rb"
# require_relative "SubredditNode.rb"
require_relative "SubredditInfo.rb"


def get_json(link)
	json = nil
	begin
		uri = URI(link+"/.json")
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
	more_ids.each_slice(100) {|a| 
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

		new_link = link+"/"+id
	
		get_comments(new_link,more_ids,comments_text)
		STDOUT.flush
}
end

def get_posts(uri,subreddits)
	
	res = Net::HTTP.get_response(uri)
	json = JSON.load(res.body)
	posts = json['data']["children"]
	full_links = []
	
	post_id = nil
	posts.each{
		|post|
		relative_link= post["data"]["permalink"]
		subreddit_name = post["data"]["subreddit"]
		post_id=  post["data"]["name"]
		subreddit = subreddits[subreddit_name]
		full_link = "https://www.reddit.com" + relative_link + ".json"
		if(subreddit == nil && subreddits.keys.length <100)
			subreddits[subreddit_name] = SubredditInfo.new(subreddit_name, [full_link])
			subreddits[subreddit_name].posts_map[post_id] = true
		elsif(subreddits.keys.length <100)
			if(subreddit.posts.length < 3)
				subreddit.posts_map[post_id] = true
				subreddit.add_post(full_link)
				full_links << full_link
			end
		end
		
	}
	return post_id
end

def get_top_100_unique()
	uri = URI("https://www.reddit.com/r/all/top/.json")
	params = { :sort => "top", :t=>"day" ,:limit =>100}
	uri.query = URI.encode_www_form(params)
	subreddits= Hash.new()
	last_post = get_posts(uri,subreddits)

	while(subreddits.values.length < 100)
		STDOUT.flush
		uri = URI("https://www.reddit.com/r/all/top/.json")
		params = { :sort => "top", :t=>"day" ,:limit =>100, :after=>last_post}
		uri.query = URI.encode_www_form(params)
		last_post =get_posts(uri,subreddits)
	end

	return subreddits
end

def add_post(subreddit)
	uri = URI("https://www.reddit.com/r/"+subreddit.name+"/top/.json")
	params = { :sort => "top", :t=>"day" ,:limit =>100}
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)
	json = JSON.load(res.body)
	posts = json['data']["children"]
	posts.each{
		|post|
		relative_link= post["data"]["permalink"]
		full_link = "https://www.reddit.com" + relative_link + ".json"
		post_id=  post["data"]["name"]
		if(subreddit.posts_map[post_id] ==nil)
			subreddit.posts_map[post_id] == nil
			subreddit.posts << full_link
		
		end
		if(subreddit.posts.length >=3)
			return
		end
	}
end

def find_not_finished(subreddits)
	subreddits.values.each{
		|sub|

		if(sub.posts.length<3)
			add_post(sub)
		end

	}
	subreddits.values.each{
		|sub|
		puts "name: #{sub.name} links: #{sub.posts}"
	}
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

def main 
	subreddits = get_top_100_unique()
	find_not_finished(subreddits)
	comments_map = Hash.new ()
	puts "Getting Comments Now"
	subreddits.values.each{
		|sub|
		sub_comments = get_comments_by_sub(sub)
		comments_map[sub.name] = sub_comments
	}

	puts "completed getting comments"
	comments_map.keys.each{
		|sub_name|
		comments = comments_map[sub_name]
		puts "subreddit: #{sub_name}"
		puts comments
		puts "---------------------------------"
	}

end

main()