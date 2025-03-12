from flask import Flask, send_file

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route("/wizexercise")
def serve_wizexercise():
    try:
        return send_file("wizexercise.txt", as_attachment=False)
    except Exception as e:
        return f"Error reading file: {str(e)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
