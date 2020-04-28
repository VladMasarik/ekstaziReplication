import xml.etree.ElementTree as ET

def addEkstazi():


    pomFile = "pom.xml"
    build = None

    # set default namespace
    tree = ET.parse(pomFile) # POM folder
    root = tree.getroot()


    ns = {"mvn":root.tag.split("}")[0][1:]}

    ET.register_namespace('',ns["mvn"])

    # re-parse the pom file
    tree = ET.parse(pomFile) # POM folder
    root = tree.getroot()

    # find plugins element
    build = root.find("mvn:build",ns)
    if build is None:
        build = ET.Element("build")
        root.append(build)
    
    plugins = root.find("mvn:build/mvn:plugins",ns)
    if plugins is None:
        plugins = ET.Element("plugins")
        build.append(plugins)


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
    tree.write(pomFile) # POM folder


addEkstazi()