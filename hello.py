import flask
import os
import pyodbc

from flask import Flask

from opencensus.ext.azure.log_exporter import AzureLogHandler

app = Flask(__name__)

ikey = os.environ.get('IKEY')
if ikey:
    app.logger.addHandler(
        AzureLogHandler(connection_string=f'InstrumentationKey={ikey}'))
    app.logger.info('Loaded ikey for App insights')

# TODO(pbourke): use Azure key vault for this?
server = 'paulsqlserver123.database.windows.net'
database = 'PaulSQLdatabase'
username = 'asystec'
password = ''


@app.route('/')
def root():
    app.logger.info('root called')
    return 'Hello World'


@app.route('/json')
def json():
    app.logger.info('json called')
    app.logger.debug('A debug message')
    app.logger.warning('A warning message')
    app.logger.error('An error message')
    return flask.jsonify({'foo': 1, 'bar': 2})


@app.route('/hello')
def hello():
    app.logger.info('hello called')
    return flask.render_template('hello.html', name='Paul')


@app.route('/path/<path:subpath>')
def show_subpath(subpath):
    # show the subpath after /path/
    return 'Subpath %s' % flask.escape(subpath)


@app.route('/sql')
def sql():
    driver = '{ODBC Driver 17 for SQL server}'
    cnxn = pyodbc.connect('DRIVER=' + driver + ';server=' + server +
                          ';PORT=1433;database=' + database + ';UID=' +
                          username + ';PWD=' + password)
    cursor = cnxn.cursor()
    cursor.execute(
        'SELECT TOP 20 pc.Name as CategoryName, p.name as ProductName '
        'FROM [SalesLT].[ProductCategory] pc JOIN [SalesLT].[Product] p '
        'ON pc.productcategoryid = p.productcategoryid')
    return flask.render_template('sql.html', results=cursor.fetchall())
