package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
)

//mage-quant ~/bin/kallisto_linux-v0.43.0/kallisto ref/Macaca_mulatta.Mmul_8.0.1.cdna.all.kallisto_v0.43.0.idx meta.txt fastqs quant
func expand(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return path, nil
	}

	usr, err := user.Current()
	if err != nil {
		return "", err
	}
	return filepath.Join(usr.HomeDir, path[1:]), nil
}

func worker(id string, cmd string, jobs <-chan int, results chan<- int) {
	for j := range jobs {
		fmt.Println("worker", id, "started  job", j)
		exec_cmd(cmd)
		fmt.Println("worker", id, "finished job", j)
		results <- j * 2
	}
}
func exec_cmd(cmd string) {

	cmdObj := exec.Command("bash", "-c", cmd)
	stdoutStderr, err := cmdObj.CombinedOutput()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%s\n", stdoutStderr)

}

func checkFile(path string) {
	if _, err := os.Stat(path); err != nil {
		log.Fatal(err.Error())
		log.Fatalf("%s does not exist!", path)
	}
}

func checkDirCreate(path string) {
	// Create a directory if doesn't exist
	if _, err := os.Stat(path); os.IsNotExist(err) {
		err2 := os.Mkdir(path, 0750)
		if err2 != nil {
			log.Fatal(err2)
		}

		fmt.Printf("Creating a directory: %s\n", path)
	}

}

type kallistoArgs struct {
	id                 string
	r1                 string
	r2                 string
	outputDirForSample string
	cmd                string
}

func main() {

	kalBinPtr := flag.String("kal", "kallisto", "Kallisto Binary")
	kalIndexPtr := flag.String("index", "", "Kallisto Index")
	metaPtr := flag.String("meta", "meta.csv", "Meta file (csv)")
	fastqDirPtr := flag.String("fastqdir", "fastqs", "Fastq Directory")
	outputDirPtr := flag.String("outputdir", "quant", "Output Directory")
	dryrunPtr := flag.Bool("dryrun", false, "Dry run")

	flag.Parse()
	// fmt.Println("flags:" , flag.Args())
	// fmt.Println("kal:" , *kalBinPtr)
	// fmt.Println("index:" , *kalIndexPtr)
	// fmt.Println("meta:" , *metaPtr)
	// fmt.Println("fastqdir:" , *fastqDirPtr)
	// fmt.Println("outputdir:" , *outputDirPtr)

	*kalBinPtr, _ = expand(*kalBinPtr)
	*kalIndexPtr, _ = expand(*kalIndexPtr)
	*metaPtr, _ = expand(*metaPtr)

	// Checks if file exists
	checkFile(*kalBinPtr)
	checkFile(*kalIndexPtr)
	checkFile(*metaPtr)

	// Check the directory
	checkFile(*fastqDirPtr)

	// Create a directory if doesn't exist
	checkDirCreate(*outputDirPtr)
	file, err := os.Open(*metaPtr)
	if err != nil {
		log.Fatal("err:", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)

	records, err := reader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

	var samples []kallistoArgs

	for _, record := range records[1:] {
		id := record[0]
		r1 := *fastqDirPtr + "/" + record[1]
		r2 := *fastqDirPtr + "/" + record[2]
		outputDirForSample := *outputDirPtr + "/" + id
		cmd := fmt.Sprintf("%s quant --index=%s --output-dir=%s %s %s", *kalBinPtr, *kalIndexPtr, outputDirForSample, r1, r2)

		s := kallistoArgs{id: id, r1: r1, r2: r2, outputDirForSample: outputDirForSample, cmd: cmd}
		samples = append(samples, s)

	}

	if *dryrunPtr {
		for _, s := range samples {
			fmt.Println(s.cmd)
		}
	} else {
		jobs := make(chan int, 100)
		results := make(chan int, 100)

		for i, s := range samples {
			checkFile(s.r1)
			checkFile(s.r2)
			checkDirCreate(s.outputDirForSample)
			go worker(s.id, s.cmd, jobs, results)

			jobs <- i
		}
		close(jobs)
		for a := 1; a <= len(samples); a++ {
			<-results
		}

	}

}
