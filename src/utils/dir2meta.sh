#!/bin/bash

ls "$1" | cat | paste - - | perl -ne 'm/(.*)_R1/; print $1."\t";print $_' | cat <(echo -e "id\tr1\tr2") - | tr '\t' ','
