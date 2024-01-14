package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"strings"

	b32 "encoding/base32"
)

var (
	col = flag.Int("w", 64, "Wrap lines after N columns")
	dec = flag.Bool("d", false, "Decode instead of Encode")
	pad = flag.Bool("n", false, "No padding")
)

func main() {
	flag.Parse()

	if *col == 0 && len(flag.Args()) > 0 {
		inputFile := flag.Arg(0)

		data, err := ioutil.ReadFile(inputFile)
		if err != nil {
			fmt.Println("Error reading the file:", err)
			os.Exit(1)
		}

		inputData := string(data)

		if *dec == false && *pad == false {
			sEnc := b32.StdEncoding.EncodeToString([]byte(inputData))
			fmt.Println(sEnc)
		} else if *dec == false && *pad == true {
			sEnc := b32.StdEncoding.WithPadding(-1).EncodeToString([]byte(inputData))
			fmt.Println(sEnc)
		}
	} else {
		var inputData string

		if len(flag.Args()) == 0 {
			data, _ := ioutil.ReadAll(os.Stdin)
			inputData = string(data)
		} else {
			inputFile := flag.Arg(0)

			data, err := ioutil.ReadFile(inputFile)
			if err != nil {
				fmt.Println("Error reading the file:", err)
				os.Exit(1)
			}
			inputData = string(data)
		}

		if *col != 0 {
			if *dec == false && *pad == false {
				sEnc := b32.StdEncoding.EncodeToString([]byte(inputData))
				for _, chunk := range split(sEnc, *col) {
					fmt.Println(chunk)
				}
			} else if *dec && *pad == false {
				decoder := b32.NewDecoder(b32.StdEncoding, strings.NewReader(inputData))
				io.Copy(os.Stdout, decoder)
			}

			if *dec == false && *pad == true {
				sEnc := b32.StdEncoding.WithPadding(-1).EncodeToString([]byte(inputData))
				for _, chunk := range split(sEnc, *col) {
					fmt.Println(chunk)
				}
			} else if *dec && *pad == true {
				decoder := b32.NewDecoder(b32.StdEncoding.WithPadding(-1), strings.NewReader(inputData))
				io.Copy(os.Stdout, decoder)
			}
		} else {
			if *dec == false && *pad == false {
				sEnc := b32.StdEncoding.EncodeToString([]byte(inputData))
				fmt.Println(sEnc)
			} else if *dec && *pad == false {
				decoder := b32.NewDecoder(b32.StdEncoding, strings.NewReader(inputData))
				io.Copy(os.Stdout, decoder)
			}

			if *dec == false && *pad == true {
				sEnc := b32.StdEncoding.WithPadding(-1).EncodeToString([]byte(inputData))
				fmt.Println(sEnc)
			} else if *dec && *pad == true {
				decoder := b32.NewDecoder(b32.StdEncoding.WithPadding(-1), strings.NewReader(inputData))
				io.Copy(os.Stdout, decoder)
			}
		}
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
