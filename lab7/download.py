from flask import Flask, send_file

app = Flask(__name__)

@app.route("/<file>")
def downloadFile(file=None):
    path ="/home/mathew/Documents/U3/W2018/comp308/lab7/" + file
    with open(path, 'rb') as f:
        return f.read()



app.run("192.168.2.21")