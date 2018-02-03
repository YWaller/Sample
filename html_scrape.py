# -*- coding: utf-8 -*-

import urllib2
#import lxml.etree as et
from bs4 import BeautifulSoup
#import ast
#import json

#This file demonstrates webscraping HTML based pages.

#try: urlopen('http://publicinterestlegal.org/county-list/')
#except urllib2.URLError as e:
#    print e.reason, e.errno
#okay forbidden so they don't want us downloading it bot-wise

#so let's make them think we're a user simple enough
rqpage = urllib2.Request('http://publicinterestlegal.org/county-list/', headers={'User-Agent' : 'Magic Browser'}) 
con = urllib2.urlopen(rqpage)
#print con.read() #make sure it worked

soup = BeautifulSoup(con, 'lxml')
#for sub_heading in soup.find_all('tbody'):
#    print(sub_heading.text)

table = soup.find('tbody')

datasets = []
for row in table.find_all('tr')[0:]:
    dataset = zip((td.get_text() for td in row.find_all('td')))
    datasets.append(dataset)

datasets_one = []
for dataset in datasets:
    datasets_one.append(dataset)
print "ylwaller"
print len(datasets)
print datasets_one
#for dataset in datasets:
#    print str(ast.literal_eval(json.dumps(dataset, encoding='utf-8')))
    

//*[@id="page-container"]/div[2]/div[1]/div[1]/div[1]/div/div/a