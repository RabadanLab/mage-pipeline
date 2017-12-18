package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"os"

	yaml "gopkg.in/yaml.v2"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}
func main() {
	type Config struct {
		Rootdir  string
		Projdir  string
		Metafile string
		Gtffile  string
		Reffasta string
		Refindex string
		Kallisto string
	}

	// Read yaml
	configData, err := ioutil.ReadFile("config.yaml")
	check(err)

	t := Config{}
	err = yaml.Unmarshal(configData, &t)
	check(err)

	fmt.Printf("--- t:\n%v\n\n", t)

	makeTmpl, err := ioutil.ReadFile("Makefile.tmpl")
	check(err)

	tmpl, err := template.New("test").Parse(string(makeTmpl))
	check(err)

	err = tmpl.Execute(os.Stdout, t)
	check(err)
}
