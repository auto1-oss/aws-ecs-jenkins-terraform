package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
)

var listenAddr string = ":80"

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	http.HandleFunc("/", rootHandler)

	err := http.ListenAndServe(listenAddr, logRequest(http.DefaultServeMux))
	if err != nil {
		log.Fatal(err)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	ip := r.Header.Get("x-forwarded-for")
	if ip == "" {
		ip, _, _ = net.SplitHostPort(r.RemoteAddr)
	}
	fmt.Fprintf(w, "Hello, your IP is: %s\n", ip)
}

func logRequest(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s %s %s\n", r.RemoteAddr, r.Method, r.Host, r.URL, r.UserAgent())
		handler.ServeHTTP(w, r)
	})
}
