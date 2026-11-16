"""Tests upload_images.upload_one against a local mock of the Storage API (no network, no real key).

Usage: python test_upload_images.py
"""
import http.server
import sys
import threading

import upload_images

STORE, SEEN_HEADERS = {}, []


class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        SEEN_HEADERS.append(self.headers)
        name = self.path.rsplit("/", 1)[-1]
        self.rfile.read(int(self.headers.get("Content-Length", 0)))
        if self.headers.get("Authorization") != "Bearer test-key":
            return self._reply(401, b'{"error":"Unauthorized"}')
        if name in STORE:
            return self._reply(400, b'{"statusCode":"409","error":"Duplicate","message":"The resource already exists"}')
        STORE[name] = True
        self._reply(200, b'{"Key":"ok"}')

    def do_DELETE(self):
        import json as _json
        SEEN_HEADERS.append(self.headers)
        names = _json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))["prefixes"]
        if self.headers.get("Authorization") != "Bearer test-key":
            return self._reply(401, b'{"error":"Unauthorized"}')
        gone = [n for n in names if STORE.pop(n, None)]
        self._reply(200, _json.dumps([{"name": n} for n in gone]).encode())

    def _reply(self, code, body):
        self.send_response(code)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


def main():
    server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{server.server_port}"
    failures = []

    def check(name, ok):
        print(("PASS " if ok else "FAIL ") + name)
        if not ok:
            failures.append(name)

    check("new image is uploaded", upload_images.upload_one(base, "test-key", "KIM-0001.png", b"x") == "uploaded")
    check("already uploaded image is skipped, not overwritten",
          upload_images.upload_one(base, "test-key", "KIM-0001.png", b"y") == "exists")
    check("upsert is disabled", SEEN_HEADERS[0].get("x-upsert") == "false")
    try:
        upload_images.upload_one(base, "wrong-key", "KIM-0002.png", b"x")
        check("wrong key raises", False)
    except RuntimeError as e:
        check("wrong key raises without leaking the key", "401" in str(e) and "wrong-key" not in str(e))
    check("webp is sent with its own content type",
          upload_images.upload_one(base, "test-key", "KIM-0001.webp", b"x") == "uploaded"
          and SEEN_HEADERS[-1].get("Content-Type") == "image/webp")
    check("png keeps image/png", SEEN_HEADERS[0].get("Content-Type") == "image/png")
    check("delete removes only existing objects",
          upload_images.delete_many(base, "test-key", ["KIM-0001.png", "NOPE.png"]) == 1 and "KIM-0001.png" not in STORE)
    check("the .webp was not deleted with the .png", "KIM-0001.webp" in STORE)
    try:
        upload_images.delete_many(base, "wrong-key", ["KIM-0001.webp"])
        check("delete with wrong key raises", False)
    except RuntimeError as e:
        check("delete with wrong key raises without leaking the key", "401" in str(e) and "wrong-key" not in str(e))
    server.shutdown()
    print("ALL PASSED" if not failures else "FAILED: " + ", ".join(failures))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
