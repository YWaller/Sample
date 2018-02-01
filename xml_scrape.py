# -*- coding: utf-8 -*-
from lxml import etree
import urllib2

urlstart = "https://www.ncdc.noaa.gov/temp-and-precip/climatological-rankings/download.xml?parameter=tavg&state="
period = "6"
belt = "44" #VA
clim_div = "0" #all
month = "8" #august
year = "2016"
username = "ylwaller"

#lxml apparently cannot parse https so we need urllib2
xmlpage = urllib2.urlopen("%s%s&div=%s&month=%s&periods[]=%s&year=%s" % (urlstart, belt, clim_div, month, period, year))
xmltoparse = xmlpage.read()
xmlpage.close()

parsed = etree.fromstring(xmltoparse)

#for child in parsed:
#    print(child.tag)

#len(parsed)

print username
print parsed[2].findtext('value')
print parsed[2].findtext('twentiethCenturyMean')
print parsed[2].findtext('lowRank')
print parsed[2].findtext('highRank')