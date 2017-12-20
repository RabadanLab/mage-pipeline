package main

import (
	"fmt"
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
			Usage:   "Create a config.yaml",
			Action: func(c *cli.Context) error {
				fmt.Printf("Creating %q in the current working directory\n", "config.yaml")
				// throw an error if there's already a config file
				if _, err := os.Stat("./config.yaml"); err == nil {
					fmt.Println("File already exists!")
				}

				fmt.Printf("Where is your fastq directory? [./fasta]\n")
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
