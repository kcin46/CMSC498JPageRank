require 'net/http'
require 'json'
require_relative "node.rb"

uri = URI("https://www.reddit.com/r/all/top/.json")
params = { :sort => "top", :t=>"month" ,:limit =>100}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
json = JSON.load(res.body)
array_of_posts = json['data']["children"]


def select_random_posts(array_of_posts )
	result = []
	numbers_selected = {}
	30.times{
		
		index = rand(99)
		while(numbers_selected[index] != nil)
			index= rand(99)
		end
		numbers_selected[index] = index
		post =  array_of_posts[index]
		result << post
	}
	return result
end
posts = select_random_posts(array_of_posts)
full_links = []
posts.each{
	|post|
	relative_link= post["data"]["permalink"]
	full_link = "https://www.reddit.com" + relative_link + ".json"
	full_links << full_link
}

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
more_ids =[]
comments = []
link = "https://www.reddit.com/r/videos/comments/4fmy7a/stoners_get_caught_smoking_under_a_parachute"
get_comments(link, more_ids,comments )
traverse_more(link,more_ids,comments)