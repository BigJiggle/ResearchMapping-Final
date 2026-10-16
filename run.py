"""Start Research Map locally:  python run.py   then open http://127.0.0.1:8000"""
import os
import socket
import webbrowser

import uvicorn


def free_port(host: str, start: int) -> int:
    """First port from `start` that nothing is listening on (so a stale server doesn't block startup)."""
    for port in range(start, start + 20):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            if s.connect_ex((host, port)) != 0:
                return port
    raise SystemExit(f"No free port found in {start}-{start + 19}; set PORT to a free one.")


if __name__ == "__main__":
    host = os.environ.get("HOST", "127.0.0.1")
    wanted = int(os.environ.get("PORT", "8000"))
    port = free_port(host, wanted)
    if port != wanted:
        print(f"Port {wanted} is busy; using {port} instead.")
    print(f"Research Map: http://{host}:{port}")
    if os.environ.get("NO_BROWSER") != "1":
        webbrowser.open(f"http://{host}:{port}")
    uvicorn.run("app.main:app", host=host, port=port)
