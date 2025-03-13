from flask import Flask, send_file, request, render_template, redirect
from pymongo import MongoClient
import os

app = Flask(__name__)

MONGO_CONNECTION_STRING = os.getenv("MONGO_CONN")
client = MongoClient(MONGO_CONNECTION_STRING)
db = client.mymongodb
collection = db.entries

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        name = request.form.get("name")
        message = request.form.get("message")

        if name and message:
            collection.insert_one({"name": name, "message": message})
        
        return redirect("/")

    # Fetch all entries from MongoDB
    entries = collection.find()
    return render_template("index.html", entries=entries)


@app.route("/wizexercise")
def serve_wizexercise():
    try:
        return send_file("wizexercise.txt", as_attachment=False)
    except Exception as e:
        return f"Error reading file: {str(e)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
