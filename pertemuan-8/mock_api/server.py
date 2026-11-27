"""REST API lokal untuk Praktikum 8.

Jalankan:  python mock_api/server.py
Base URL:  http://localhost:8080
Data disimpan di mock_api/db.json (persist antar restart).
"""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "db.json")
PORT = 8080

COLLECTIONS = {
    "users": ["name", "email", "city"],
    "admins": ["name", "email", "department"],
}


def load_db():
    with open(DB_PATH, encoding="utf-8") as f:
        return json.load(f)


def save_db(db):
    with open(DB_PATH, "w", encoding="utf-8") as f:
        json.dump(db, f, indent=2, ensure_ascii=False)


class Handler(BaseHTTPRequestHandler):
    server_version = "Praktikum8API/1.0"

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _send(self, status, payload=None):
        body = b"" if payload is None else json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self._cors()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if body:
            self.wfile.write(body)

    def _route(self):
        path = self.path.split("?")[0].strip("/")
        parts = path.split("/") if path else []
        if not parts or parts[0] not in COLLECTIONS:
            return None, None, None
        item_id = None
        if len(parts) > 1:
            try:
                item_id = int(parts[1])
            except ValueError:
                return None, None, None
        return parts[0], item_id, len(parts) > 2

    def _body(self):
        length = int(self.headers.get("Content-Length") or 0)
        if length == 0:
            return {}
        try:
            data = json.loads(self.rfile.read(length).decode("utf-8"))
        except json.JSONDecodeError:
            return None
        return data if isinstance(data, dict) else None

    def do_OPTIONS(self):
        self._send(204)

    def do_GET(self):
        collection, item_id, extra = self._route()
        if collection is None or extra:
            return self._send(404, {"error": "Not found"})
        db = load_db()
        items = db[collection]
        if item_id is None:
            return self._send(200, items)
        item = next((x for x in items if int(x["id"]) == item_id), None)
        if item is None:
            return self._send(404, {"error": f"{collection[:-1]} {item_id} not found"})
        return self._send(200, item)

    def do_POST(self):
        collection, item_id, extra = self._route()
        if collection is None or item_id is not None or extra:
            return self._send(404, {"error": "Not found"})
        data = self._body()
        if data is None or not str(data.get("name", "")).strip():
            return self._send(400, {"error": "Field 'name' wajib diisi"})
        db = load_db()
        items = db[collection]
        new_id = int(data.get("id") or (max((int(x["id"]) for x in items), default=0) + 1))
        item = {"id": new_id}
        for field in COLLECTIONS[collection]:
            item[field] = data.get(field, "")
        items = [x for x in items if int(x["id"]) != new_id]
        items.append(item)
        db[collection] = items
        save_db(db)
        return self._send(201, item)

    def do_PUT(self):
        collection, item_id, extra = self._route()
        if collection is None or item_id is None or extra:
            return self._send(404, {"error": "Not found"})
        data = self._body()
        if data is None:
            return self._send(400, {"error": "Body JSON tidak valid"})
        db = load_db()
        items = db[collection]
        item = next((x for x in items if int(x["id"]) == item_id), None)
        if item is None:
            return self._send(404, {"error": f"{collection[:-1]} {item_id} not found"})
        for field in COLLECTIONS[collection]:
            if field in data:
                item[field] = data[field]
        save_db(db)
        return self._send(200, item)

    def do_PATCH(self):
        return self.do_PUT()

    def do_DELETE(self):
        collection, item_id, extra = self._route()
        if collection is None or item_id is None or extra:
            return self._send(404, {"error": "Not found"})
        db = load_db()
        items = db[collection]
        item = next((x for x in items if int(x["id"]) == item_id), None)
        if item is None:
            return self._send(404, {"error": f"{collection[:-1]} {item_id} not found"})
        db[collection] = [x for x in items if int(x["id"]) != item_id]
        save_db(db)
        return self._send(200, item)

    def log_message(self, fmt, *args):
        print(f"{self.command} {self.path} -> {args[1]}")


if __name__ == "__main__":
    if not os.path.exists(DB_PATH):
        save_db({"users": [], "admins": []})
    print(f"API lokal jalan di http://localhost:{PORT}")
    print("Tekan Ctrl+C untuk berhenti.")
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
