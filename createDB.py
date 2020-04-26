import sqlite3




conn = sqlite3.connect('mbm.db')
c = conn.cursor()
mypath = "target/surefire-reports/"
data = {
	"project": "",
	"time": 0,
	"tests": 0,
	"failed": 0,
	"errors": 0,
	"skipped": 0,
	"ekstazi": False
}


# Create table
c.execute("CREATE TABLE projects(project text, timeing real, tests int, failed int, error int, skipped int, mode string)")

exit()