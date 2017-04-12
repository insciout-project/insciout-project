import sqlite3
# to use if you create the database from a restore file
con = sqlite3.connect('./database/InSciOut.sqlite3')
f = open('./database/dump.sql','r')
str = f.read()
con.executescript(str)
