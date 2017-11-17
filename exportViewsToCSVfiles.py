import pandas as pd
import sqlite3


def view_to_csv():
    db = sqlite3.connect("./database/InSciOut.sqlite3")
    cursor = db.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='view';")
    tables = cursor.fetchall()
    for table_name in tables:
        print table_name
        table_name = table_name[0]
        table = pd.read_sql_query("SELECT * from %s" % table_name, db)
        table.to_csv('./database/CSVTables/'+table_name + '.csv', index_label='index', encoding='utf-8')


view_to_csv()