import xml.etree.ElementTree as ET

def addEkstazi():


    buildFile = "build.xml"
    build = None

    # set default namespace
    tree = ET.parse(buildFile) # POM folder
    root = tree.getroot()
    root.set("xmlns:ekstazi", "antlib:org.ekstazi.ant") # add the NS definition in the root


    # Wrap existing junit target elements in Ekstazi select:

    # <ekstazi:select>
    # <junit fork="true" ...>
    # ...
    # </junit>
    # </ekstazi:select>


    # <taskdef uri="antlib:org.ekstazi.ant" resource="org/ekstazi/ant/antlib.xml">
    # <classpath path="org.ekstazi.core-5.3.0.jar"/> 
    # <classpath path="org.ekstazi.ant-5.3.0.jar"/> 
    # </taskdef>

    for tag in root.findall("target"):
        if tag.get("name") == "test": # junit.run
            targetTag = tag
            break

    taskDef = ET.Element("taskdef")
    taskDef.set("uri","antlib:org.ekstazi.ant")
    taskDef.set("resource", "org/ekstazi/ant/antlib.xml")

    cpCore = ET.Element("classpath")
    cpCore.set("path", "org.ekstazi.core-5.3.0.jar")
    cpAnt = ET.Element("classpath")
    cpAnt.set("path", "org.ekstazi.ant-5.3.0.jar")

    taskDef.append(cpCore)
    taskDef.append(cpAnt)
    
    targetTag.append(taskDef)


    # Wrap existing junit target elements in Ekstazi select:

    # <ekstazi:select>
    # <junit fork="true" ...>
    # ...
    # </junit>
    # </ekstazi:select>

    ekstazi = ET.Element("ekstazi:select")
    junit = targetTag.find("junit")
    targetTag.remove(junit)
    ekstazi.append(junit)
    targetTag.append(ekstazi)

    
    # exit() # REMOVEE@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # write the changes
    tree.write(buildFile) # POM folder

    # ns = {"mvn":root.tag.split("}")[0][1:]}
    

    # ET.register_namespace('',ns["mvn"])

    # # re-parse the pom file
    # tree = ET.parse(buildFile) # POM folder
    # root = tree.getroot()

    # # find plugins element
    # build = root.find("target")
    # if build is None:
    #     build = ET.Element("build")
    #     root.append(build)
    
    # plugins = root.find("mvn:build/mvn:plugins",ns)
    # if plugins is None:
    #     plugins = ET.Element("plugins")
    #     build.append(plugins)


    # # Create plugin element
    # plugin = ET.Element("plugin")
    # groupId = ET.Element("groupId")
    # groupId.text = "org.ekstazi"
    # artifactId = ET.Element("artifactId")
    # artifactId.text = "ekstazi-maven-plugin"
    # version = ET.Element("version")
    # version.text = "5.3.0"
    # executions = ET.Element("executions")
    # execution = ET.Element("execution")
    # id = ET.Element("id")
    # id.text = "ekstazi"
    # goals = ET.Element("goals")
    # goal = ET.Element("goal")
    # goal.text = "select"

    # goals.append(goal)
    # execution.append(id)
    # execution.append(goals)
    # executions.append(execution)
    # plugin.append(executions)
    # plugin.append(version)
    # plugin.append(artifactId)
    # plugin.append(groupId)

    # plugins.append(plugin)


    # exit() # REMOVEE@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # # write the changes
    # tree.write(buildFile) # POM folder


addEkstazi()