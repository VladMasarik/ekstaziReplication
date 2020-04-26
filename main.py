import xml.etree.ElementTree as ET
from enum import Enum
from git import Repo
import pysvn
import subprocess, shlex, os

# reportFolder = "/home/vmasarik/git/net/trunk/target/surefire-reports/"
# reportFile = "TEST-org.apache.commons.net.ftp.VladTest.xml"

reportFolder = "~/git/net/trunk/"
cloningFolder = "~/git/"
svnClient = pysvn.Client()

if os.getcwd() != "~/git":
	print("Current dir", os.getcwd())
	print("Not in ~/git; run python3 exReplic/main.py")
	exit()


def addEkstazi(pomFolder):


	pomFile = "pom.xml"

	# set default namespace
	tree = ET.parse(pomFolder+pomFile)
	root = tree.getroot()


	ns = {"mvn":root.tag.split("}")[0][1:]}

	ET.register_namespace('',ns["mvn"])

	# re-parse the pom file
	tree = ET.parse(pomFolder+pomFile)
	root = tree.getroot()

	# find plugins element
	plugins = root.find("mvn:build/mvn:plugins",ns)

	# Create plugin element
	plugin = ET.Element("plugin")
	groupId = ET.Element("groupId")
	groupId.text = "org.ekstazi"
	artifactId = ET.Element("artifactId")
	artifactId.text = "ekstazi-maven-plugin"
	version = ET.Element("version")
	version.text = "5.3.0"
	executions = ET.Element("executions")
	execution = ET.Element("execution")
	id = ET.Element("id")
	id.text = "ekstazi"
	goals = ET.Element("goals")
	goal = ET.Element("goal")
	goal.text = "select"

	goals.append(goal)
	execution.append(id)
	execution.append(goals)
	executions.append(execution)
	plugin.append(executions)
	plugin.append(version)
	plugin.append(artifactId)
	plugin.append(groupId)

	plugins.append(plugin)



	# write the changes
	tree.write(pomFolder+pomFile)



# GIT returns Repo object
# SVN returns Revision object
def cloneProject(project):
	if project.vcs == Vcs.GIT:
		return Repo.clone_from(project.repo, cloningFolder + project.name)

	elif (project.vcs == Vcs.SVN):
		return svnClient.checkout(project.repo, cloningFolder + project.name)




def switchRevision(project,repo = None):
	if project.vcs == Vcs.GIT:
		repo.head.reset(commit=project.revision,working_tree=True)

	elif (project.vcs == Vcs.SVN):
		rev = pysvn.Revision(pysvn.opt_revision_kind.number, project.revision)
		svnClient.update(cloningFolder + project.name, revision=rev)




# Execute a bash command and return its output
def cmd(shellCommand):
    proc = subprocess.Popen(shlex.split(shellCommand), stdout=subprocess.PIPE)
    return proc.communicate()[0].decode("utf-8")


# Only for MVN
def solveDependencies(project):
	if project.vcs == Vcs.GIT:
		os.chdir(cloningFolder + project.name)

	elif (project.vcs == Vcs.SVN):
		os.chdir(cloningFolder + project.name + "/trunk")

	print(cmd("mvn dependency:resolve"))


# only for MVN
def runTests(project):
	if project.vcs == Vcs.GIT:
		os.chdir(cloningFolder + project.name)

	elif (project.vcs == Vcs.SVN):
		os.chdir(cloningFolder + project.name + "/trunk")

	print(cmd("mvn test"))




def findFailedTests():
	pass

def cleanCompilation():
	pass




class Vcs(Enum):
	GIT = 1
	SVN = 2

class Management(Enum):
	MVN = 1
	ANT = 2



class ResearchProject():
	def __init__(self, repo, vcs, revision, previousRevisions, mng):
		self.repo = repo
		self.vcs = vcs
		self.name = repo.split("/")[-1]
		self.revision = revision
		self.previousRevisions = previousRevisions
		self.mng = mng
		













# testP = ResearchProject("https://github.com/dsoprea/PySvn", Vcs.GIT, "0c222a9a49b25d1fcfbc170ab9bc54288efe7f49", 15)
# rep = cloneProject(testP)
# switchRevision(project,repo)



# testP = ResearchProject("https://svn.apache.org/repos/asf/bval", Vcs.SVN, 1598345, 20, Management.MVN)
# cloneProject(testP)
# switchRevision(testP)





projects = [
	ResearchProject("https://github.com/cucumber/cucumber-jvm", Vcs.GIT, "5df09f85", 20, Management.MVN),					# 1 TEST failed CHECKOUT
	ResearchProject("https://github.com/JodaOrg/joda-time", Vcs.GIT, "f17223a4", 20, Management.MVN), 						# 2 Test failures CHECKOUT
	ResearchProject("https://github.com/square/retrofit", Vcs.GIT, "810bb53e", 20, Management.MVN),							# 3 WORKS!
	ResearchProject("https://svn.apache.org/repos/asf/commons/proper/validator", Vcs.SVN, 1610469, 20, Management.MVN), 		# 4 WORKS!
	ResearchProject("https://svn.apache.org/repos/asf/bval", Vcs.SVN, 1598345, 20, Management.MVN),						# 5 Not Downloaded ???? I did download it, but why was it not there in the first place??
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/jxpath", Vcs.SVN, 1564371, 13, Management.ANT), 				# 6 Cloning problem CHECKOUT
	# ResearchProject("https://github.com/graphhopper/graphhopper",Vcs.GIT,"0e0e311c",20,Management.MVN),						# 7 CAnnot resolve dependencies CHECKOUT
	# ResearchProject("https://svn.apache.org/repos/asf/river/jtsk", Vcs.SVN, 1520131, 19, Management.ANT), 					# 8
	ResearchProject("https://svn.apache.org/repos/asf/commons/proper/functor", Vcs.SVN, 1541713, 20, Management.MVN), 		# 9 WORKS!
	# ResearchProject("https://svn.apache.org/repos/asf/empire-db", Vcs.SVN, 1562914, 20, Management.MVN), 					# 10 WORKS!
	# ResearchProject("https://github.com/apetresc/JFreeChart", Vcs.GIT, 3070, 20, Management.MVN), 							# 11  GIT DOES NOT know revision 3070
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/collections", Vcs.SVN, 1567759, 20, Management.MVN), 	# 12 WORKS
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/lang", Vcs.SVN, 1568639, 20, Management.MVN), 			# 13 MVN reports build fail, but it seems only tests are failing. ANT does not build at all though
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/configuration", Vcs.SVN, 1571738, 16, Management.MVN), 	# 14 Test failures CHECKOUT
	# ResearchProject("https://svn.apache.org/repos/asf/pdfbox", Vcs.SVN, 1582785, 20, Management.MVN), 						# 15 Failed on dependencies
	# ResearchProject("https://github.com/goldmansachs/gs-collections", Vcs.GIT, "6270110e", 20, Management.MVN), 			# 16 WORKS!
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/net", Vcs.SVN, 1584216, 19, Management.MVN), 			# 17 Test fail == the skip year error
	# ResearchProject("https://github.com/google/closure-compiler", Vcs.GIT, "65401150", 20, Management.MVN), 				# 18 Test Fail == the stack overflow error
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/dbcp", Vcs.SVN, 1573792, 16, Management.MVN), 			# 19 Works!
	# ResearchProject("https://svn.apache.org/repos/asf/logging/log4j", Vcs.SVN, 1567108, 19, Management.MVN), 				# 20 Works!
	# ResearchProject("https://git.eclipse.org/r/p/jgit/jgit", Vcs.GIT, "bf33a6ee", 20, Management.MVN), 						# 21 WORKS! 
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/io", Vcs.SVN, 1603493, 20, Management.MVN), 			# 22 Works!
	# ResearchProject("https://svn.apache.org/repos/asf/ant/ivy/core", Vcs.SVN, 1558740, 18, Management.ANT), 				# 23  ANT AND IVY have same 'core' endings so they would fight
	# ResearchProject("https://github.com/jenkinsci/jenkins", Vcs.GIT, "c826a014", 20, Management.MVN), 					# 24 BUT CAREFUL ONLY "LIGHT" version or something
	# ResearchProject("https://svn.apache.org/repos/asf/commons/proper/math", Vcs.SVN, 1573523, 20, Management.MVN), 			# 25 Crashed after cloning
	# ResearchProject("https://svn.apache.org/repos/asf/ant/core", Vcs.SVN, 1570454, 20, Management.ANT), 						# 26 Testing reported build fail, but only test errors and failures seem to be present
	# ResearchProject("https://svn.apache.org/repos/asf/continuum", Vcs.SVN, 1534878, 20, Management.MVN),  					# 27 Build failure
	# ResearchProject("https://github.com/google/guava", Vcs.GIT ,"af2232f5" ,16 , Management.MVN), 							# 28 Build failure
	# ResearchProject("https://git-wip-us.apache.org/repos/asf/camel", Vcs.GIT ,"f6114d52" ,20 , Management.MVN ), 			# 29  CAREFUL ONLY CORE
	# ResearchProject("https://git.eclipse.org/r/jetty/org.eclipse.jetty.project.git", Vcs.GIT ,"0f70f288" ,20 , Management.MVN ),# 30 Build failure
	# ResearchProject("https://github.com/apache/hadoop-common", Vcs.GIT ,"f3043f97" ,20 , Management.MVN ), 				# 31     CAREFUL ONLY CORE
	# ResearchProject("https://svn.apache.org/repos/asf/zookeeper", Vcs.SVN ,1605517 ,19 , Management.ANT ), 					# 32 Seems to have failed on dependencies; repo2 does not seem to exist, but repo1 is, but it requires https; Execute failed: java.io.IOException: Cannot run program "autoreconf" (in directory "/home/vmasarik/git/zookeeper/trunk/src/c"): error=2, No such file
]



for p in projects:

	# print("Cloning project", p.name)
	# repository = cloneProject(p)

	
	print("Switching revision on project", p.name)
	
	if p.vcs == Vcs.GIT:
		repository = Repo(p.name)
	else:
		repository = None


	switchRevision(p, repository)

	# if p.mng == Management.ANT:
		# continue

	# print("Solving dependencies on project", p.name)
	# solveDependencies(p) SEEMS like running tests is goog enough
	# runTests(p)

	# input("Press Enter to continue...")


exit()



###### This is the main loop


# if findFailedTests() is not None:
# 	print("project XYZ has failed tests, skipping")
# 	# continue

# cleanCompilation()

# addEkstazi()



# ##### Did not solve more than this...


# runTests()

