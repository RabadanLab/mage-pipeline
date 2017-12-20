package main

import (
	"bufio"
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli"
)

// NewApp -> Command -> Run
func main() {
	app := cli.NewApp()

	app.Name = "mage - Multilevel Analysis of Gene Expression"

	app.Usage = "Quantify/Preprocess/Model RNA-seq samples"

	app.Version = "0.1.0"

	app.Commands = []cli.Command{
		{
			Name:    "init",
			Aliases: []string{"i"},
			Usage:   "Create a \"config.yaml\" in a current working directory",
			Action: func(c *cli.Context) error {

				// throw an error if there's already a config file
				if _, err := os.Stat("./config.yaml"); err == nil {
					// exit
					log.Fatalf("config.yaml alreay exists!")
				}

				fmt.Printf("Creating %q in the current working directory\n", "config.yaml")
				configFile, err := os.Create("config.yaml")
				if err != nil {
					return err
				}
				defer configFile.Close()

				w := bufio.NewWriter(configFile)

				lines := []string{
					"rootdir:  # /the/path/to/your/mage/directory",
					"projdir:  # /project/specific/directory",
					"metafile:  # /path/to/your/meta/file",
					"reffasta: # /path/to/reference/fasta ",
					"gtffile:  # /path/to/gtf/file",
					"refindex:  # /path/to/kallisto/index",
					"kallisto:   # /path/to/kallisto/binary"}

				for _, line := range lines {
					fmt.Fprintln(w, line)
				}
				w.Flush()

				return nil
			},
		},
		{
			Name:    "quant",
			Aliases: []string{"q"},
			Usage:   "quantify the expression",
			Action: func(c *cli.Context) error {
				fmt.Println("added task: ", c.Args().First())
				return nil
			},
		},
		{
			Name:    "model",
			Aliases: []string{"m"},
			Usage:   "Create a model",
			Action: func(c *cli.Context) error {
				fmt.Println("Creating a model")
				return nil
			},
		},
	}

	app.Run(os.Args)
}
