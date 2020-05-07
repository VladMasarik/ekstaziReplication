import xml.etree.ElementTree as ET

def addEkstazi():


    buildFile = "build.xml"
    build = None

    # set default namespace
    tree = ET.parse(buildFile) # POM folder
    root = tree.getroot()

    ns = {"mvn":root.tag.split("}")[0][1:]}
    

    ET.register_namespace('',ns["mvn"])

    for tag in root.findall("target"):
        if tag.get("name") == "test": # junit.run
            targetTag = tag
            break


    ekstazi = root.find("ekstazi:select",ns)
    # for t in targetTag:
    #     print(t.tag)
    #     if t.tag == "{{antlib:org.ekstazi.ant}}select":
    #         print(t)
    #         ekstazi = t


    ekstazi.set("skipme", "true")
    
    # tree.write(buildFile) # POM folder



addEkstazi()