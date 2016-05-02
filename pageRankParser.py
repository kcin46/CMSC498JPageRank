import json
from pprint import pprint
import sys
import copy

data = {}


with open(sys.argv[1]) as file:
	data = json.load(file)

backup = copy.deepcopy(data)

total = 0
for k in backup:
#	print "Back up: ",backup[k]
#	print "total prior: ",total
	total = total + backup[k]
#	print "total post: ",total, "\n"

print total


#for key in backup:
#	if(backup[key] == '0/1'):
#		data.pop(key)

backup = copy.deepcopy(data)



sorted_keys = []
while(len(data) != 0):
	max_string = ""
	maX = -1
	for key in data:
		if(data[key]>maX):
			maX = data[key]
			max_string = key
	sorted_keys.append(max_string)
	data.pop(max_string)






#for k in sorted_keys:
#	print k,'\n',backup[k],'\n'
