#!/usr/bin/env python3
"""
server.py
Simple HTTP server for transactions with CRUD operations
Supports string IDs (like T0001) instead of numeric indexes
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os

DATA_FILE = "data/transactions.json"


def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {}  # use dict instead of list


def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)


class MyHandler(BaseHTTPRequestHandler):

    # Utility: Send JSON response
    def send_json(self, status, data):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    # Utility: Extract ID from /transactions/T0001
    def get_id_from_path(self):
        parts = self.path.strip("/").split("/")
        if len(parts) == 2 and parts[0] == "transactions":
            return parts[1]  # now returns string IDs like "T0001"
        return None

    def do_GET(self):
        if self.path == "/":
            self.send_json(200, {"message": "API is running"})

        elif self.path == "/transactions":
            data = load_data()
            self.send_json(200, data)

        elif self.path.startswith("/transactions/"):
            transaction_id = self.get_id_from_path()
            if transaction_id is None:
                self.send_json(400, {"error": "Invalid ID"})
                return

            data = load_data()
            if transaction_id in data:
                self.send_json(200, data[transaction_id])
            else:
                self.send_json(404, {"error": "Transaction not found"})

        else:
            self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path == "/transactions":
            content_length = int(self.headers["Content-Length"])
            body = self.rfile.read(content_length)
            new_transaction = json.loads(body.decode())

            if "id" not in new_transaction:
                self.send_json(400, {"error": "Transaction must have an 'id'"})
                return

            data = load_data()
            transaction_id = new_transaction["id"]

            if transaction_id in data:
                self.send_json(400, {"error": "Transaction with this ID already exists"})
                return

            data[transaction_id] = new_transaction
            save_data(data)

            self.send_json(201, {"message": "Transaction added", "id": transaction_id})
        else:
            self.send_json(404, {"error": "Not found"})

    def do_PUT(self):
        if self.path.startswith("/transactions/"):
            transaction_id = self.get_id_from_path()
            if transaction_id is None:
                self.send_json(400, {"error": "Invalid ID"})
                return

            content_length = int(self.headers["Content-Length"])
            body = self.rfile.read(content_length)
            updated_transaction = json.loads(body.decode())

            data = load_data()
            if transaction_id in data:
                data[transaction_id] = updated_transaction
                save_data(data)
                self.send_json(200, {"message": "Transaction updated"})
            else:
                self.send_json(404, {"error": "Transaction not found"})
        else:
            self.send_json(404, {"error": "Not found"})

    def do_DELETE(self):
        if self.path.startswith("/transactions/"):
            transaction_id = self.get_id_from_path()
            if transaction_id is None:
                self.send_json(400, {"error": "Invalid ID"})
                return

            data = load_data()
            if transaction_id in data:
                deleted = data.pop(transaction_id)
                save_data(data)
                self.send_json(200, {"message": "Transaction deleted", "deleted": deleted})
            else:
                self.send_json(404, {"error": "Transaction not found"})
        else:
            self.send_json(404, {"error": "Not found"})


def run():
    server = HTTPServer(("", 8000), MyHandler)
    print("Server running at http://localhost:8000")
    server.serve_forever()


if __name__ == "__main__":
    run()
