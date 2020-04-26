import sqlite3
import xml.etree.ElementTree as ET
from os import listdir
from os.path import isfile, join
import os
import argparse




conn = sqlite3.connect('mbm.db')
c = conn.cursor()
mypath = "target/surefire-reports"
data = {
	"project": "",
	"time": 0,
	"tests": 0,
	"failed": 0,
	"errors": 0,
	"skipped": 0,
	"mode": ""
}


def getArgs():
	parser = argparse.ArgumentParser()
	parser.add_argument("projectName")
	parser.add_argument("projectPath")
	parser.add_argument("execTime")
	parser.add_argument("mode")
	args = vars(parser.parse_args())

	print("Arguments =", args)

	return args



def getXMLFiles():
	files = []
	print("current DIR =",os.getcwd())
	dirtyFiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]


	for f in dirtyFiles:
		if f.split(".")[-1] == "xml":
			files.append(f)


	return files


def countFile(data,filePath):

	tree = ET.parse(filePath)
	root = tree.getroot()

	# data["time"] += float(root.get("time")) NO need for this as I get time from `time` command
	data["tests"] += int(root.get("tests"))
	data["errors"] += int(root.get("errors"))
	data["skipped"] += int(root.get("skipped"))
	data["failed"] += int(root.get("failures"))
	return data


def getTime(str):
	return float(str.split("\n")[-1])

args = getArgs()
data["project"] = args["projectName"]
projectPath = args["projectPath"]

data["time"] = getTime(args["execTime"])
data["mode"] = args["mode"]

files = getXMLFiles()




for filePath in files:
	data = countFile(data,projectPath + "/" + mypath + "/" + filePath)

print(data)



# Insert a row of data
c.execute("INSERT INTO projects VALUES (?,?,?,?,?,?,?)",tuple(data.values()))
print("Fetch Note =", c.fetchone())

# Save (commit) the changes
conn.commit()

conn.close()





# t = ('RHAT',)
# c.execute('SELECT * FROM stocks WHERE symbol=?', t)
# print(c.fetchone())

# # Larger example that inserts many records at a time
# purchases = [('2006-03-28', 'BUY', 'IBM', 1000, 45.00),
#              ('2006-04-05', 'BUY', 'MSFT', 1000, 72.00),
#              ('2006-04-06', 'SELL', 'IBM', 500, 53.00),
#             ]
# c.executemany('INSERT INTO stocks VALUES (?,?,?,?,?)', purchases)



# def addEkstazi(pomFolder):


# 	pomFile = "pom.xml"

# 	# set default namespace


# 	ns = {"mvn":root.tag.split("}")[0][1:]}

# 	ET.register_namespace('',ns["mvn"])

# 	# re-parse the pom file
# 	tree = ET.parse(pomFolder+pomFile)
# 	root = tree.getroot()

# 	# find plugins element
# 	plugins = root.find("mvn:build/mvn:plugins",ns)

# 	# Create plugin element
# 	plugin = ET.Element("plugin")
# 	groupId = ET.Element("groupId")
# 	groupId.text = "org.ekstazi"
# 	artifactId = ET.Element("artifactId")
# 	artifactId.text = "ekstazi-maven-plugin"
# 	version = ET.Element("version")
# 	version.text = "5.3.0"
# 	executions = ET.Element("executions")
# 	execution = ET.Element("execution")
# 	id = ET.Element("id")
# 	id.text = "ekstazi"
# 	goals = ET.Element("goals")
# 	goal = ET.Element("goal")
# 	goal.text = "select"

# 	goals.append(goal)
# 	execution.append(id)
# 	execution.append(goals)
# 	executions.append(execution)
# 	plugin.append(executions)
# 	plugin.append(version)
# 	plugin.append(artifactId)
# 	plugin.append(groupId)

# 	plugins.append(plugin)



# 	# write the changes
# 	tree.write(pomFolder+pomFile)
