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
    server.shutdown()
    print("ALL PASSED" if not failures else "FAILED: " + ", ".join(failures))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
