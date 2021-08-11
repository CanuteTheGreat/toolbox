import sys
import time
import hashlib
from urllib.request import urlopen, Request
from pandas import *
import csv

if len(sys.argv) < 2:
	print("Sorry, need a url!")
	exit(1)
else:
	checkurl = sys.argv[1]

url = Request(checkurl,
			headers={'User-Agent': 'Mozilla/5.0'})

# to perform a GET request and load the
# content of the website and store it in a var
response = urlopen(url).read()

# to create the initial hash
currentHash = hashlib.sha224(response).hexdigest()
keeprunning = True

while keeprunning == True:
	try:
		# perform the get request and store it in a var
		response = urlopen(url).read()
		
		# create a hash
		currentHash = hashlib.sha224(response).hexdigest()
		newHash = "null"
		currenturl = -1
		
		# csv file name
		data = read_csv("test.csv")
 
		# converting column data to list
		urls = data['url'].tolist()
		hashes = data['hash'].tolist()

		for link in range(len(urls)):
			if urls[link] == checkurl:
				newHash = hashes[link]
				currenturl = urls[link]

		# check if new hash is same as the previous hash
		if newHash == currentHash:
			print("same hash!")
			keeprunning = False
			break
		# if something changed in the hashes
		else:
			print("something changed")

			if currenturl == -1:
				# this ia a new url
				print("found new url")
				urls.append(checkurl)
				hashes.append(hashlib.sha224(response).hexdigest())
				keeprunning = False
				break
			else:
				# this is an update to an existing url
				print("found update to existing url")
				for link in range(len(urls)):
					if urls[link] == checkurl:
						hashes[link] = hashlib.sha224(response).hexdigest()
						keeprunning = False
						break

			
	# To handle exceptions
	except Exception as e:
		print(traceback.format_exc())
		#print("error:")
		exit(e)

finallist = []
finallist.append("url,hash")
for i in range(len(urls)):
	finallist.append(urls[i] + "," + hashes[i])

with open('test.csv', mode='w') as csv_file:
	csv_writer = csv.writer(csv_file)
	reader = csv.reader(finallist, delimiter=',')
	for row in reader:
		#print('\t'.join(row))
		csv_writer.writerow(row)
