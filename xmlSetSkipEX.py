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

    ekstazi = None
    for t in targetTag:
        if t.tag == "{{antlib:org.ekstazi.ant}}select":
            ekstazi = t


    ekstazi.set("skipme", "true")
    
    # tree.write(buildFile) # POM folder



addEkstazi()