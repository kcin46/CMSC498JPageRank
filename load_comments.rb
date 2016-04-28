require 'json'

f = File.open("AskReddit_json","r")
str = ""
f.each{|line| str+=str+line}
j=JSON.load(str)
post_1 = j["OldSchoolCool"][0]
post_2 = j["OldSchoolCool"][1]
post_3 = j["OldSchoolCool"][2]

post_2.each{
	|comment| 
	if(comment =~ /r\/([a-zA-Z_0-9]+)/)
		m=/r\/([a-zA-Z0-9_]+)/.match(comment)

		puts m[1]
	end
}