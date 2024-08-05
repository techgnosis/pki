package main

import (
    "net/http"
    "log"
)

func HelloServer(w http.ResponseWriter, req *http.Request) {
    w.Header().Set("Content-Type", "text/plain")
    w.Write([]byte("This is an example server.\n"))
}

func main() {
    http.HandleFunc("/hello", HelloServer)
    err := http.ListenAndServeTLS(":443", "endpoint_cert.pem", "endpoint_private_key.pem", nil)
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}