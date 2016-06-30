#!/usr/bin/env python3

import json
import requests
import os.path

oauth_token=os.getenv("GITHUB_API_TOKEN")
header={'Accept': 'application/vnd.github.full+json','Authorization': 'token '+oauth_token}


def write_issues(response):
    "output a list of issues to csv"
    if not r.status_code == 200:
        raise Exception(r.status_code)
    for issue in r.json():
        print(issue);
        labels = issue['labels']
        for label in labels:
            if label['name'] == "Client Requested":
                csvout.writerow([issue['number'], issue['title'].encode('utf-8'), issue['body'].encode('utf-8'), issue['created_at'], issue['updated_at']])

def write(string):
    print(string)

def writeMilestone(title,url):
    write(title)
    write("Issues")

    file.write("\n# ["+ title+"]("+url+")\n\n")
    file.write("## Issues\n\n")

def writeIssue(state,title,url):
    write(state + " - " + title)
    file.write(" * [" + state + " - "+title+"]("+url+")\n")

r = requests.get("http://api.github.com/repos/overturetool/overture/milestones?state=all", headers=header)

file = open("output.txt", "w")


print(r)

if not r.status_code == 200:
        raise Exception(r.status_code)

for milestone in r.json():
#    print(milestone)
    writeMilestone(milestone['title'],milestone['url'])
#    write(milestone['title'])
#    write(milestone['number'])
#    write(milestone['url']) 

 #   print("Issues:")

    ri = requests.get("http://api.github.com/repos/overturetool/overture/issues?state=all&milestone="+str(milestone['number']), headers=header)
    if not ri.status_code == 200:
        raise Exception(ri.status_code)
    for issue in ri.json():
        writeIssue(issue['state'], issue['title'],issue['url'])
    #write_issues(r)
#file.write("Purchase Amount: %s" % TotalAmount)
file.close()
