All of the scripts are written in Ruby. In order to run the program please use a version of Ruby > 2.0

The results and analysis of the dataset is done by the pageRank.rb file.

In order to compute those results run the following command:
	
	'ruby pageRank.rb'

The script will create a graph using the json files stored in the json_folder, run the scaled PageRank algorithm and output the results in a file called 'ranks.csv'.

The resulting file 'ranks.csv' is a csv where each line represents a subreddit and it's corresponding page rank value. The results are sorted in descending order by PageRank value. 
