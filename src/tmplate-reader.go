package main

import (
	yaml "gopkg.in/yaml.v2"
	"html/template"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
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
	config_name := "config.yaml"
	configData, err := ioutil.ReadFile(config_name)
	check(err)

	t := Config{}
	err = yaml.Unmarshal(configData, &t)
	check(err)

	t.Rootdir, _ = expand(t.Rootdir)
	t.Kallisto, _ = expand(t.Kallisto)

	if os.Getenv("MAGEROOT") == "" {
		log.Fatalf("Please set MAGEROOT environmental variable")
	}
	makeTmpl, err := ioutil.ReadFile(filepath.Join(os.Getenv("MAGEROOT"), "src", "Makefile.tmpl"))
	check(err)

	tmpl, err := template.New("test").Parse(string(makeTmpl))
	check(err)

	err = tmpl.Execute(os.Stdout, t)
	check(err)
}
