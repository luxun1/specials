import urllib2
url = "http://store.steampowered.com/search/?specials=1"
website = urllib2.urlopen(url)
print website.read()
