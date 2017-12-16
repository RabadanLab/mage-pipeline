# mage-pipeline

# Overview

![](assets/pipeline_diagram.png)


# Requirements

* Kallisto : expression quantification
* R
    * packages: tidyverse, jsonlite

# Setup

```
cd mage-pipeline
source setup.sh
```

# Provide the id for each samples

meta.fastq.txt

`src/utils/dir2meta.shi` can be used to make the meta file



## Quantification

### Input for quantification

* GTF file
* Fastq file
* Kallisto index




# System requirements

```
sudo apt-get install libssl-dev           # Install Secure Sockets Layer toolkit
sudo apt install make                     # install make 
sudo apt-get install libcurl4-openssl-dev # Install curl 
sudo apt-get install libxml2-dev          # Instal xml
```

# Installing R

```
# See https://www.r-bloggers.com/how-to-install-r-on-linux-ubuntu-16-04-xenial-xerus/ for more
sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get install r-base r-base-dev
```


# Installing required R packages

```
R

in R,
source("requirements.R")

# this will install tidyverse, stan
```



# Installing Kallisto

```
mkdir -p ~/bin
cd ~/bin
curl -L -O https://github.com/pachterlab/kallisto/releases/download/v0.43.1/kallisto_linux-v0.43.1.tar.gz
tar xzvf kallisto_linux-v0.43.1.tar.gz

```

## Creating a Kallisto index

```
~/bin/kallisto_linux-v0.43.1/kallisto index --index=Macaca_mulatta.Mmul_8.0.1.cdna.all.idx Macaca_mulatta.Mmul_8.0.1.cdna.all.fa
```

# Installing go

```

```

# Go packages

```
go get github.com/urfave/cli
```


