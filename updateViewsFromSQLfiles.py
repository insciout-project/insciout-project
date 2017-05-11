import sqlite3
import glob, os

# To see the update in SQLStudio, you need to press SHIFT+F5 or click right on the database and select:
# "refresh all database schemas"
# Note:
# In order to see the changes in SQLStudio after Overriding/Replacing a View, you will need to close all tabs in
# SQLStudio Editor which displays that View. Then re-open them and you will see the changes. That is due to a bug.
# REPLACE is used when you want to replace/update existing views.

REPLACE = False
folder_names = glob.glob("./analyses/*/")
conn = sqlite3.connect("./database/InSciOut.sqlite3")
cursor = conn.cursor()

for folder_name in folder_names:
    print "Accessing folder: " + folder_name
    sql_paths = glob.glob(folder_name + "/*.sql")
    for sql_path in sql_paths:
        view_name = os.path.splitext(os.path.basename(sql_path))[0].replace(' ', '_')
        with open(sql_path, 'r') as sql_file:
            sql_query = sql_file.read().replace('\n', '\n')
        view_create = "CREATE VIEW %s AS " % (view_name) + sql_query
        # we could use CREATE VIEW IF NOT EXISTS %s AS, but then we won't be able to say if it happens.
        tb_exists = "SELECT name FROM sqlite_master WHERE type='{}' AND name='{}'".format('view', view_name)
        if not cursor.execute(tb_exists).fetchone() or REPLACE:
            if REPLACE:
                cursor.execute('DROP VIEW {};'.format(view_name))
            try:
                cursor.execute(view_create)
            except Exception as e:
                print "Problem in {}. Will be passed. Details:".format(sql_path)
                print str(e)
        else:
            print "{} already exist and was not replaced (please change the option REPLACE if needed).".format(
                view_name)

conn.commit()
conn.close()
