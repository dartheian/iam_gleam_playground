# iam_gleam_playground

```sh
$ docker compose test

$ docker compose up -d

$ http localhost:8000/key
HTTP/1.1 404 Not Found
connection: keep-alive
content-length: 0

$ http PUT localhost:8000/key content=123
HTTP/1.1 200 OK
connection: keep-alive
content-length: 0

$ http localhost:8000/key
HTTP/1.1 200 OK
connection: keep-alive
content-length: 3

123
```
