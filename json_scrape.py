# -*- coding: utf-8 -*-
import requests

#This is a file that demonstrates json-based webscraping, it is fairly simple.

search_url = 'http://buckets.peterbeshai.com/api/?player=201939&season=2015'
response = requests.get(search_url, headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"})

print 'ylwaller'

#Never trust the data source completely, verify that checkcnt returns the same value for these
'''
checkcnt = 0
for shot in response.json():
    checkcnt += 1
print checkcnt
checkcnt = 0
for shot in response.json():
    if shot["SEASON"] == "2015":
        checkcnt += 1
print checkcnt
for shot in response.json():
    if shot["PLAYER_ID"] == "201939":
        checkcnt += 1
print checkcnt
'''

#simple json extracts
cnt = 0
for shot in response.json():
    if shot["ACTION_TYPE"] == 'Jump Shot':
        cnt+=1
print cnt

cnt2 = 0
for shot in response.json():
    if shot["ACTION_TYPE"] == 'Jump Shot':
        if shot["EVENT_TYPE"] == 'Made Shot':
            cnt2+=1
print cnt2
percentage = (float(cnt2)/float(cnt)) * 100
print "%s%%" % (percentage)
    