import pandas as pd


def upsert_to_db(df, table_name, connection, replace = False, dup_cols=[],
                 filter_categorical_col=None, filter_continuous_col=None):
    if replace:
        df.to_sql(table_name, connection, if_exists='replace', index=False)
        print "all the rows of " + table_name + " were replaced!"
    else:
        size_before = df.shape[0]
        df = filter_df_from_existing_db(df, table_name, connection, dup_cols=dup_cols,
                                        filter_continuous_col=filter_continuous_col, filter_categorical_col=filter_categorical_col)
        size_after = df.shape[0]
        df.to_sql(table_name, connection, if_exists='append', index=False)
        print 'only %s rows on %s were new and have been added to %s !' % (size_after, size_before, table_name)

def filter_df_from_existing_db(df, tablename, connection, dup_cols=[],
                         filter_continuous_col=None, filter_categorical_col=None):
    """
    Adapted from: https://www.ryanbaumann.com/blog/2016/4/30/python-pandas-tosql-only-insert-new-rows
    Remove rows from a dataframe that already exist in a database
    Required:
        df : dataframe to remove duplicate rows from
        connection: SQLite connection object
        tablename: tablename to check duplicates in
        dup_cols: list or tuple of column names to check for duplicate row values
    Optional:
        filter_continuous_col: the name of the continuous data column for BETWEEEN min/max filter
                               can be either a datetime, int, or float data type
                               useful for restricting the database table size to check
        filter_categorical_col : the name of the categorical data column for Where = value check
                                 Creates an "IN ()" check on the unique values in this column
    Returns
        Unique list of values from dataframe compared to database table
    """
    args = 'SELECT %s FROM %s' %(', '.join(['"{0}"'.format(col) for col in dup_cols]), tablename)
    args_contin_filter, args_cat_filter = None, None
    if filter_continuous_col is not None:
        if df[filter_continuous_col].dtype == 'datetime64[ns]':
            args_contin_filter = """ "%s" BETWEEN Convert(datetime, '%s')
                                          AND Convert(datetime, '%s')""" %(filter_continuous_col,
                              df[filter_continuous_col].min(), df[filter_continuous_col].max())


    if filter_categorical_col is not None:
        args_cat_filter = ' "%s" in(%s)' %(filter_categorical_col,
                          ', '.join(["'{0}'".format(value) for value in df[filter_categorical_col].unique()]))

    if args_contin_filter and args_cat_filter:
        args += ' Where ' + args_contin_filter + ' AND' + args_cat_filter
    elif args_contin_filter:
        args += ' Where ' + args_contin_filter
    elif args_cat_filter:
        args += ' Where ' + args_cat_filter

    df.drop_duplicates(dup_cols, keep='last', inplace=True)
    df = pd.merge(df, pd.read_sql(args, connection), how='left', on=dup_cols, indicator=True)
    df = df[df['_merge'] == 'left_only']
    df.drop(['_merge'], axis=1, inplace=True)
    return df