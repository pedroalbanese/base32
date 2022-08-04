package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	b32 "encoding/base32"
)

var (
	col = flag.Int("col", 64, "Columns")
	pad = flag.Bool("nopadding", false, "No padding")
	dec = flag.Bool("dec", false, "Decode instead Encode")
)

func main() {
	flag.Parse()
	if *dec == false && *pad == false {
		data, _ := ioutil.ReadAll(os.Stdin)
		b := strings.TrimSuffix(string(data), "\r\n")
		b = strings.TrimSuffix(b, "\n")
		sEnc := b32.StdEncoding.EncodeToString([]byte(b))
		for _, chunk := range split(sEnc, *col) {
			fmt.Println(chunk)
		}
	} else if *dec && *pad == false {
		data, _ := ioutil.ReadAll(os.Stdin)
		b := strings.TrimSuffix(string(data), "\r\n")
		b = strings.TrimSuffix(b, "\n")
		sDec, _ := b32.StdEncoding.DecodeString(b)
		os.Stdout.Write(sDec)
	}

	if *dec == false && *pad == true {
		data, _ := ioutil.ReadAll(os.Stdin)
		b := strings.TrimSuffix(string(data), "\r\n")
		b = strings.TrimSuffix(b, "\n")
		sEnc := b32.StdEncoding.WithPadding(-1).EncodeToString([]byte(b))
		for _, chunk := range split(sEnc, *col) {
			fmt.Println(chunk)
		}
	} else if *dec && *pad == true {
		data, _ := ioutil.ReadAll(os.Stdin)
		b := strings.TrimSuffix(string(data), "\r\n")
		b = strings.TrimSuffix(b, "\n")
		sDec, _ := b32.StdEncoding.WithPadding(-1).DecodeString(b)
		os.Stdout.Write(sDec)
	}
}

func split(s string, size int) []string {
	ss := make([]string, 0, len(s)/size+1)
	for len(s) > 0 {
		if len(s) < size {
			size = len(s)
		}
		ss, s = append(ss, s[:size]), s[size:]

	}
	return ss
}
