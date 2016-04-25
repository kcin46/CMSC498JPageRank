require 'net/http'
require 'json'
require_relative "SubredditInfo.rb"
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

end

def print_subs_info(subreddits)
	subreddits.values.each{
		|sub|
		puts "subreddit name: #{sub.name} links: #{sub.posts}"
	}
end

def split_work(num,subreddits)
	jobs = []
	subreddits.values.each_slice(num){
		|arr_of_subs|
		
		job = []
		arr_of_subs.each{
			|sub|
			sub_hash = Hash.new
			sub_hash["sub_name"] = sub.name
			sub_hash["links"] = sub.posts
			job<<sub_hash
		}
		jobs << job
	}
	puts JSON.generate(jobs)	
end
def main 
	subreddits = get_top_100_unique()
	find_not_finished(subreddits)
	split_work(25,subreddits)
end
main()