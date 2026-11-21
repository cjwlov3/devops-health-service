import json
import unittest
from http.server import HTTPServer
from threading import Thread
from urllib.request import urlopen

from app import HealthHandler


class HealthEndpointTest(unittest.TestCase):
    def test_health_returns_ok(self):
        with HTTPServer(("127.0.0.1", 0), HealthHandler) as server:
            worker = Thread(target=server.serve_forever)
            worker.start()

            try:
                url = f"http://127.0.0.1:{server.server_port}/health"
                with urlopen(url, timeout=5) as response:
                    self.assertEqual(response.status, 200)
                    self.assertEqual(json.load(response), {"status": "ok"})
            finally:
                server.shutdown()
                worker.join()
