package main

import (
	"os/user"
	"path/filepath"
	"strings"
)

//mage-quant ~/bin/kallisto_linux-v0.43.0/kallisto ref/Macaca_mulatta.Mmul_8.0.1.cdna.all.kallisto_v0.43.0.idx meta.txt fastqs quant
func expand(path string) (string, error) {

	path = strings.Replace(path, "$HOME", "~", -1)

	if len(path) == 0 || path[0] != '~' {
		return path, nil
	}

	usr, err := user.Current()
	if err != nil {
		return "", err
	}
	return filepath.Join(usr.HomeDir, path[1:]), nil
}

func Map(vs []string, f func(string) string) []string {
	vsm := make([]string, len(vs))
	for i, v := range vs {
		vsm[i] = f(v)
	}
	return vsm
}
