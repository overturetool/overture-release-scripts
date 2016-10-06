#!/usr/bin/env python3

import csv
import datetime
import os
import os.path
import requests


oauth_token = os.getenv("GITHUB_API_TOKEN")
header = {
    'Accept': 'application/vnd.github.full+json',
    'Authorization': 'token ' + oauth_token
}

TITLE = "Overture"
REPO_NAME = "overture"
REPO_OWNER = "overturetool"


def write_issues(response):
    "output a list of issues to csv"
    if not r.status_code == 200:
        raise Exception(r.status_code)
    for issue in r.json():
        print(issue)
        labels = issue['labels']
        for label in labels:
            if label['name'] == "Client Requested":
                csvout.writerow(
                    [issue['number'], issue['title'].encode('utf-8'),
                     issue['body'].encode('utf-8'), issue['created_at'],
                     issue['updated_at']])


def writeMilestone(file, title, url, dueon, template):
    if file is None:
        return

    t = title + " - Release Notes"

    if dueon:
        d = datetime.datetime.strptime(dueon, "%Y-%m-%dT%H:%M:%SZ")
        t += " - {:%d %B %Y}".format(d)

    print(t)
    print("Issues")

    file.write("\n# [" + t + "](" + url + ")\n\n")
    if template is not None:
        with open(template) as f:
            for line in f:
                file.write(line)
    file.write("## Bugfixes\n\n")
    file.write("Please note that the interactive list is at <" + url + ">\n")


def writeIssue(file, state, number, title, url):
    if file is None:
        return

    print(state + " - " + title)
    file.write("* [#" + str(number) + " " + state + " - " + title + "](" + url +
               ")\n")

r = requests.get(
    "http://api.github.com/repos/" + REPO_OWNER + "/" + REPO_NAME + "/milestones?state=closed",
    headers=header)

if not r.status_code == 200:
    raise Exception(r.status_code)

for milestone in r.json():

    version = milestone['title']
    if version.startswith('v'):
        version = version[1:]

    mdname = "ReleaseNotes_" + version + ".md"
    fileM = None
    if os.path.isfile(mdname):
        fileM = None
        continue
    else:
        fileM = open(mdname, "w")
        writeMilestone(fileM, TITLE + " " + version, milestone['html_url'],
                       milestone['due_on'], "ReleaseNotes-template.md")

    ri = requests.get(
        "http://api.github.com/repos/" + REPO_OWNER + "/" + REPO_NAME + "/issues?state=all&milestone=" +
        str(milestone['number']),
        headers=header)
    if not ri.status_code == 200:
        raise Exception(ri.status_code)
    for issue in ri.json():
        writeIssue(fileM, issue['state'], issue['number'], issue['title'],
                   issue['html_url'])
    if fileM is not None:
        fileM.close()
