import xml.etree.ElementTree as ET

def addEkstazi():


    buildFile = "build.xml"
    build = None

    # set default namespace
    tree = ET.parse(buildFile) # POM folder
    root = tree.getroot()
    root.set("xmlns:ekstazi", "antlib:org.ekstazi.ant") # add the NS definition in the root


    for tag in root.findall("target"):
        if tag.get("name") == "test": # junit.run
            targetTag = tag
            break

    for t in targetTag:
        print(t)
        print(t.tag)

    ekstazi = targetTag.find("select")

    ekstazi.set("skipme", "true")
    
    # tree.write(buildFile) # POM folder



addEkstazi()