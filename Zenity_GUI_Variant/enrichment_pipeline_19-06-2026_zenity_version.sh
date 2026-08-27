#!/usr/bin/env bash

# ---------------- CONFIG ----------------
title="DOMINOANN  v1.0"
font="big"

body_lines=(
  "Data Ontology Mapping Integration for Non-model organism Annotation"
  "ICMR-NIRT 2026"
)
# ----------------------------------------

draw_banner() {
  clear
  cols=$(tput cols)

  printf "%*s\n" "$cols" "" | tr ' ' '='
  echo

  figlet -f "$font" "$title" | while IFS= read -r line; do
    pad=$(( (cols - ${#line}) / 2 ))
    (( pad < 0 )) && pad=0
    printf "%*s%s\n" "$pad" "" "$line"
  done

  echo

  for line in "${body_lines[@]}"; do
    pad=$(( (cols - ${#line}) / 2 ))
    (( pad < 0 )) && pad=0
    printf "%*s%s\n" "$pad" "" "$line"
  done

  echo
  printf "%*s\n" "$cols" "" | tr ' ' '='
}

# -------- Welcome screen --------
printf "\e[36m\033[1m"
draw_banner

# Optional pause for resize
sleep 1

# Freeze UI permanently
trap - SIGWINCH

printf "\033[0m\e[0m"
printf "\n\n"

# Checking package installation:

declare -A conda_map

conda_map["r-base"]="conda install -y conda-forge::r-base"
conda_map["clusterProfiler"]="conda install -y bioconda::bioconductor-clusterprofiler"
conda_map["ggplot2"]="conda install -y conda-forge::r-ggplot2"
conda_map["enrichplot"]="conda install -y bioconda::bioconductor-enrichplot"
conda_map["ggridges"]="conda install -y conda-forge::r-ggridges"
conda_map["AnnotationForge"]="conda install bioconda::bioconductor-annotationforge"
conda_map["biomaRt"]="conda install bioconda::bioconductor-biomart"
conda_map["BiocManager"]="conda install conda-forge::r-biocmanager"

printf "\033[1m\e[31m\nAfter ensuring all the required packages are installed successfully, the pipeline can be used for analysis.\n\033[0m\e[0m"
printf "\033[0m\e[0m\nSingle-line installation command:\n\033[1m\e[32mconda create -n enrichment_tools tsnyder::figlet r-base r-ggplot2 r-ggridges r-rcolorbrewer r-biocmanager bioconductor-clusterprofiler bioconductor-biomart bioconductor-annotationforge bioconductor-enrichplot -y\n\033[0m\nAfter successful run using above command, don't forget to activate the environment using, \n\033[1m\e[32mconda activate enrichment_tools\n\033[0m\n"


printf "\n\e[36m\033[1mUsers can try the below commands highlighted in green to install only the missing packages. (or) can try the above single-installation command to install all packages at once inside a dedicated conda environment\033[0m\n\n\n "

missing=0

for pkg in "${!conda_map[@]}"; do

    if [[ "$pkg" == "r-base" ]]; then
        # Special check for R binary
        if command -v R >/dev/null 2>&1; then
            printf "\nPackage '%s' is installed.\n" "$pkg"
        else
            printf "\033[1m\e[31m\nPackage '%s' is NOT installed.\n" "$pkg"
            printf "Install using:\n"
            printf "\033[1m\e[32m%s\n\033[0m\n" "${conda_map[$pkg]}"
            missing=1
        fi

    else
        # Regular R package check
        if Rscript --vanilla -e "if (!('$pkg' %in% rownames(installed.packages()))) quit(status=1)" >/dev/null 2>&1; then
            printf "\nPackage '%s' is installed.\n" "$pkg"
        else
            printf "\033[1m\e[31m\nPackage '%s' is NOT installed.\n" "$pkg"
            printf "Install using:\n"
            printf "\033[1m\e[32m%s\n\033[0m\n" "${conda_map[$pkg]}"
            missing=1
        fi
    fi

done

if [[ $missing -eq 1 ]]; then
    printf "\n\033[1m\e[31mOne or more required R packages are missing. Exiting...\033[0m\n"
    exit 1
fi

printf "\nAll required R packages are installed.\n"



printf "\e[36m\n\nChoose your organism from the below options:\n\n\e[0m"

while true; do
choice_num=$(zenity --list \
    --title="Select an Option" \
    --column="No" \
    --column="Name" \
    1 "Human(Homo sapiens)"\
    2 "Mouse(Mus musculus)" \
    3 "Rat(Rattus norvegicus)"\
    4 "Fly(Drosophila melanogaster)"\
    5  "Zebrafish(Danio rerio)" \
    6  "Arabidopsis(Arabidopsis thaliana)" \
    7 "Yeast(Saccharomyces cerevisiae)" \
    8  "Worm(Caenorhabditis elegans)" \
    9  "Pig(Sus scrofa)"\
  10  "Bovine(Bos taurus)"\
  11 "Rhesus(Macaca mulatta)"\
  12   "Canine(Canis familiaris)"\
  13  "Chicken(Gallus gallus)"\
  14  "E Coli strain K12(Escherichia coli)"\
  15  "Xenopus(Xenopus laevis)"\
  16  "Chimpanzee(Pan troglodytes)"\
  17  "Anopheles(Anopheles gambiae)"\
  18  "E coli strain Sakai(Escherichia coli)"\
  19  "Malaria(Plasmodium falciparum)"\
  20   "Myxococcus xanthus DK 1622"\
  21  "Others" \
    --print-column=1)

echo "$choice_num"
#choice=("Human(Homo sapiens)" "Mouse(Mus musculus)" "Rat(Rattus norvegicus)" "Fly(Drosophila melanogaster)" "Zebrafish(Danio rerio)" "Arabidopsis(Arabidopsis thaliana)" "Yeast(Saccharomyces cerevisiae)" "Worm(Caenorhabditis elegans)" "Pig(Sus scrofa)" "Bovine(Bos taurus)" "Rhesus(Macaca mulatta)" "Canine(Canis familiaris)" "Chicken(Gallus gallus)" "E Coli strain K12(Escherichia coli)" "Xenopus(Xenopus laevis)" "Chimpanzee(Pan troglodytes)" "Anopheles(Anopheles gambiae)" "E coli strain Sakai(Escherichia coli)" "Malaria(Plasmodium falciparum)" "Myxococcus xanthus DK 1622" "Others")
db_list=("org.Hs.eg.db" "org.Mm.eg.db" "org.Rn.eg.db" "org.Dm.eg.db" "org.Dr.eg.db" "org.At.tair.db" "org.Sc.sgd.db" "org.Ce.eg.db" "org.Ss.eg.db" "org.Bt.eg.db" "org.Mmu.eg.db" "org.Cf.eg.db" "org.Gg.eg.db" "org.EcK12.eg.db" "org.Xl.eg.db" "org.Pt.eg.db" "org.Ag.eg.db" "org.EcSakai.eg.db" "org.Pf.plasmo.db" "org.Mxanthus.db")
#for i in "${!choice[@]}"; do
#printf "%2d) %s\n" $((i+1)) "${choice[$i]}"
#done
#printf "\n\n"
#while true; do
#read -r -e -d $'\n' -p "Enter a number [1-21] :" choice_num
if [[ -z "$choice_num" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi
if [[ "$choice_num" =~ ^[1-9]$|^1[0-9]$|^20 ]] || [[ "$choice_num" == "21" ]]; then
break
else
printf "\033[1m\e[31mERROR:\033[0m \e[0mInvalid response, Enter only valid numbers from [1-21] as input :: \n"
fi
done


if [[ "$choice_num" == "21" ]]; then

printf "\033[1m\e[36mEnsure stable internet connection (internet free from firewall blocks).\n\n\033[0m\e[0m"
printf "\e[36mSteps 1-7 must be run if users don't have SQLite file and only when building customized database for the first time. The source SQLite file generated after step 7 can be used to build database for every other non-model organism found in NCBI\n"
printf "\nSTEP - 1 : \e[0mDownload files using the following command : \n"
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz \n'
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz \n'
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz \n'
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz \n'
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2ensembl.gz \n'
printf '\t\t\t wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz \n'
printf '\t\t\t wget https://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz \n'
printf "STORE ALL DOWNLOADED FILES INSIDE A FOLDER\n\n"

printf "\e[36mSTEP - 2 : \e[0mStart R (version 4.3.3) in linux terminal.\n\n"
printf '\n\e[36mSTEP - 3 : \e[0mInstall R package AnnotationForge (version 1.44.0) :\n if (!require("BiocManager", quietly = TRUE))\n    install.packages("BiocManager")\nBiocManager::install("AnnotationForge")\n'
printf "\n\e[36mSTEP - 4 : \e[0mLoad the library AnnotationForge,\nlibrary(AnnotationForge)"
printf "\n\e[36mSTEP - 5 : \e[0mUsing the downloaded files, build the source SQLite database file using the below command:\n"
printf 'writeFilesToDb <- function(file, file.dir = ".") {\n    require("AnnotationForge", character.only = TRUE,  quietly = TRUE)\n    require("RSQLite", character.only = TRUE, quietly = TRUE)\n    tmp <- file.path(file.dir, file)\n    pfiles <- AnnotationForge:::.primaryFiles()\n    file <- pfiles[file]\n    NCBIcon <- dbConnect(SQLite(), file.path(file.dir, "NCBI.sqlite"))\n    tableName <- sub(".gz","",names(file))\n    AnnotationForge:::.writeToNCBIDB(NCBIcon, tableName, filepath=tmp, file)\n    AnnotationForge:::.setNCBIDateStamp(NCBIcon, tableName)\n    dbDisconnect(NCBIcon)\n}\n\n'
printf '\n\e[36mSTEP - 6 : \e[0mRun the command : \n fls <- dir(".", "^gene.+gz")'
printf '\n\n\e[36mSTEP - 7 : \e[0mRun the command : \n for(i in fls) writeFilesToDb(i)'

printf "\n\e[36mNOTE : The commands used in steps 1-7 will source files through FTP. Therefore, users must ensure stable internet connection (internet free from firewall blocks) while running these steps.\n\n"
printf '\n\nThe SQLite file generated using the above steps will be used to create annotation database for any non-model organism.\n So, ensure that this SQLite file is kept in the current working directory.\e[0m\n'

#printf "\n\n\n\e[32m\033[1m\t Are you constructing the NCBI.sqlite file for the first time : \033[0m"

printf "\n\033[1;33m====================================================================\033[0m\n"
printf "\033[1;31mDISCLAIMER:\033[0m\n"
printf "\033[1mThe NCBI database is updated frequently (often daily).\033[0m\n"
printf "The existing \033[1mNCBI.sqlite\033[0m file may contain outdated records,\n"
printf "which could affect downstream analyses and annotations.\n\n"
printf "To ensure that the latest NCBI information is used, it is\n"
printf "recommended to regenerate the \033[1mNCBI.sqlite\033[0m database periodically.\n\n"
printf "\033[1mChoose one of the following options:\033[0m\n"
printf "  [Y] Regenerate NCBI.sqlite using the latest NCBI database files.\n"
printf "  [N] Reuse the existing NCBI.sqlite file.\n"
printf "\033[1;33m====================================================================\033[0m\n\n"


while true; do
ncbi_sqlite_new=$(zenity  --list \
	--title=" Regenerate NCBI.sqlite " \
	--text=" Do you want to regenerate NCBI.sqlite file : " \
	--radiolist \
    	--column="Select" \
   	--column="Choice" \
    	TRUE "yes" \
   	FALSE "no" \
  	--print-column=2)
if [[ -z "$ncbi_sqlite_new" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please provide a valid input : "
continue
fi

# Handle cancel/close
[ $? -ne 0 ] && exit 1
break
done

echo "$ncbi_sqlite_new"

#while true; do
#read -r -e -d $'\n' -p '(y/n): ' ncbi_sqlite_new;
#if [[ "${ncbi_sqlite_new,,}" == "y" || "${ncbi_sqlite_new,,}" == "n" ]];
#then
#break
#else
#printf "\033[1m\e[31mERROR:\033[0m \e[0mInvalid response, please type (y/n) again: \n"
#fi
#done

if [[ "${ncbi_sqlite_new,,}" == "yes" ]]; then

download() {
local url="$1"
printf "[INFO] Downloading $(basename "$url")"

wget --tries=10 --waitretry=5 --timeout=30 --continue --retry-connrefused --show-progress "$url"

if [[ $? -ne 0 ]]; then
printf "[ERROR] Failed to download $url" >&2
exit 1
fi
}

printf "\n\n Starting to construct the NCBI.sqlite database file... \n"
printf "STEP - 1 : Downloading the files required for building the NCBI.sqlite file from NCBI and Expasy : \n"
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2ensembl.gz
download https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
download https://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz

printf "\n"
printf "STEPS - 2-7 : Starting R in linux terminal. Loading the R package AnnotationForge and generating the NCBI.sqlite common database file for all organisms using the downloaded files.\n"
Rscript --vanilla -e 'suppressPackageStartupMessages(library(AnnotationForge));writeFilesToDb<-function(file,file.dir="."){require("AnnotationForge",character.only=TRUE,quietly=TRUE);require("RSQLite",character.only=TRUE,quietly=TRUE);tmp<-file.path(file.dir,file);pfiles<-AnnotationForge:::.primaryFiles();file<-pfiles[file];NCBIcon<-dbConnect(SQLite(),file.path(file.dir,"NCBI.sqlite"));tableName<-sub(".gz","",names(file));AnnotationForge:::.writeToNCBIDB(NCBIcon,tableName,filepath=tmp,file);AnnotationForge:::.setNCBIDateStamp(NCBIcon,tableName);dbDisconnect(NCBIcon)};pfiles<-AnnotationForge:::.primaryFiles();fls<-intersect(dir(".","^gene.+gz"),names(pfiles));for(f in fls){f_named<-f;names(f_named)<-f;writeFilesToDb(f_named)}'
fi

printf "\n\n"
#while true; do
if [[ "${ncbi_sqlite_new,,}" == "no" ]]; then
if [ -e "NCBI.sqlite" ]; then
printf "\"NCBI.sqlite\" exists. Using the existing database file.\n"
#break
else
printf "\033[1m\e[31mERROR:\033[0m \"NCBI.sqlite\" is missing.\n"
printf "Please keep the file in your current working directory:\n%s\n" "$PWD"
#printf "\"NCBI.sqlite\" is missing.\nPlease keep the file in your current working directory:\n%s\n Your current working directory is : " "$PWD"
exit 1
fi
fi
#done
fi


printf "\nEnrichment analysis pipeline : Gene Ontology and KEGG Pathways\n\n"
printf "This pipeline performs Enrichment Analysis of Differentially Expressed Genes for Model and Non-Model Organisms\n"

while true; do
if [[ "$choice_num" =~ ^[1-9]$|^1[0-9]$|^20 ]]; then
db_name="${db_list[$((choice_num-1))]}"
org_name="${choice[$((choice_num-1))]}"
printf "You selected: $org_name. $db_name database will be installed and used for enrichment analysis."
if Rscript --vanilla -e "if (!('$db_name' %in% rownames(installed.packages()))) quit(status = 1)" >/dev/null 2>&1; then
printf "\nPackage '$db_name' is already installed."
else
printf "\nPackage '$db_name' is not installed.\n Installing package $db_name\n\n"
Rscript --vanilla -e "if (!require('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('$db_name')" >/dev/null 2>&1
if Rscript --vanilla -e "if (!('$db_name' %in% rownames(installed.packages()))) quit(status = 1)" >/dev/null 2>&1; then
printf "\nSuccessfully installed R package : '$db_name'\n"
else
printf "\nPackage '$db_name' is not installed.\n Try installing separately using the below command inside the R environment.\n\n"
printf "if (!require('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('$db_name')\n\n"
exit 1
fi
fi
Rscript --vanilla -e "suppressPackageStartupMessages(library($db_name))"
if [[ $? -eq 0 ]]; then
printf "\nSuccessfully loaded R package: $db_name"
fi
break
elif [[ "$choice_num" == "21" ]]; then
printf "\e[0m\e[36m \n"
while true; do
#read -r -e -d $'\n' -p '(i) Enter scientific name of your non-model organism separated by underscores : ' local_name;

local_name=$(zenity --entry \
    --title="Organism Input" \
    --text="(i) Enter scientific name of your non-model organism separated by underscores :")

if [[ -z "$local_name" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please provide a valid name : "
continue
fi

# Handle cancel/close
[ $? -ne 0 ] && exit 1


echo "$local_name"

printf "\e[0m"
if [[ -z "$local_name" ]];
then
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mInput cannot be blank. Please provide valid name : "
continue
fi
printf "\nNon-Model Organism : $local_name"
printf "\n\e[33m"
#read -r -e -d $'\n' -p 'Is this correct? (y/n) ' name_confirm


name_confirm=$(zenity  --list \
	--title=" Non-Model Organism Name confirmation " \
	--text="Is the Non-Model Organism Name confirm ?  " \
	--radiolist \
    	--column="Select" \
   	 --column="Choice" \
    	TRUE "yes" \
   	FALSE "no" \
  	--print-column=2)

if [[ -z "$name_confirm" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi

# Handle cancel/close
[ $? -ne 0 ] && exit 1


echo "$name_confirm"

printf "\e[0m"
if [[ "${name_confirm,,}" == "yes" ]];
then
if [[ "$local_name" =~ ^[A-Za-z]+_[A-Za-z]+$ ]];
then
name="$local_name"
break
else
printf "\033[1m\e[31mERROR:\033[0m \e[0mThe name of non-model organism must have only genus and species name separated by a single underscore. It should not have more than two words. Enter the name again : "
continue
fi
break
else
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mYour input has not been confirmed. Please enter name of non-model organism again : "
fi
done

while true; do
#read -r -e -d $'\n' -p "Visit https://www.ncbi.nlm.nih.gov/taxonomy, and get the NCBI taxonomy id for $local_name : " tax_id;

tax_id=$(zenity --entry \
    --title="NCBI Taxonomy ID" \
    --text="Visit https://www.ncbi.nlm.nih.gov/taxonomy and enter the NCBI taxonomy ID for $local_name :")

if [[ -z "$tax_id" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please provide a valid taxonomy id : "
continue
fi
# Handle cancel/close
[ $? -ne 0 ] && exit 1


echo "$tax_id"

if [[ "$tax_id" =~ ^[1-9][0-9]*$ ]];
then
printf "\n\e[33m"
#read -r -e -d $'\n' -p 'Is this correct? (y/n) ' name_confirm_tax

name_confirm_tax=$(zenity  --list \
	--title=" Non-Model Organism Taxonomy id confirmation " \
	--text="Is the Non-Model Organism Taxonomy id confirm ?  " \
	--radiolist \
    	--column="Select" \
   	 --column="Choice" \
    	TRUE "yes" \
   	FALSE "no" \
  	--print-column=2)
if [[ -z "$name_confirm_tax" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi

# Handle cancel/close
[ $? -ne 0 ] && exit 1

echo "$name_confirm_tax"

printf "\e[0m"
if [[ "${name_confirm_tax,,}" == "yes" ]];
then
printf "\n\033[1m\e[0m Your input has been confirmed.\n"
break
else
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mYour input has not been confirmed. Please enter the taxonomy id again : "
continue
fi
break
else
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mInvalid input; Enter only non-negative, non-decimal number as input : "
continue
fi
done



printf "\n\n \e[1m\e[31mNext, to build the customised annotation database, users can run the below command by ensuring that,\n\n (i)\t The internet connection is stable and free from firewall blocks, and \n(ii)\t The NCBI.SQLite file is found in the current working directory:\n\n\033[0m\e[0m"
IFS='_' read -r part1 part2 <<< "$local_name"
printf "\nsuppressPackageStartupMessages(library(AnnotationForge)); makeOrgPackageFromNCBI(version = '0.1', author = 'user <user@user.org>', maintainer = 'user <user@user.org>', outputDir = '.', tax_id = '$tax_id', genus = '$part1', species = '$part2', rebuildCache = FALSE)\n"
printf '\nAfter successful run of the above command, the following message will be displayed.\n Creating package in ./org.Modelorganism.eg.db\n'
printf 'The customized database folder will be created in the current working directory, The "org.Modelorganism.eg.db" is replaced with your database name. \n\n'
printf "After this, install the database as an R package using the below command.\n"
printf 'install.packages("./org.Modelorganism.eg.db", repos=NULL)'

printf "\n\n\n\e[32m\033[1m"
while true; do
#read -r -e -d $'\n' -p 'Do you already have pre-constructed customised database for your organism '$local_name' (y/n)? ' pre_construct;

pre_construct=$(zenity --list \
    --title="Custom Database" \
    --text="Do you already have a pre-constructed customised database for your organism $local_name ?" \
    --radiolist \
    --column="Select" \
    --column="Choice" \
    TRUE "yes" \
    FALSE "no" \
    --print-column=2)

if [[ -z "$pre_construct" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi
# Handle cancel/close
[ $? -ne 0 ] && exit 1

echo "$pre_construct"

printf "\033[0m"
if [ "${pre_construct,,}" = "yes" ];
then
#read -r -e -d $'\n' -p 'Paste the name of the pre-constructed database folder here (eg: org.Modelorganism.eg.db):' db_name;

db_name=$(zenity --entry \
    --title="Database Folder" \
    --text="Paste the name of the pre-constructed database folder here\n(eg: org.Modelorganism.eg.db) :")

if [[ -z "$db_name" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please enter valid database name : "
continue
fi

# Handle cancel/close
[ $? -ne 0 ] && exit 1

echo "$db_name"

if [[ "$db_name" =~ /$ || ! "$db_name" =~ ^org\.[^.]+\.eg\.db$ ]]; then
printf "Invalid database name (no trailing slashes allowed and database name should follow the format, \"org.Modelorganism.eg.db\")\n "
continue
elif [[ $db_name == org.*.eg.db ]]; then
if [[ -e "$db_name" ]]; then
printf "\nDatabase exists in the current working directory.\n"
break
else
printf "\nDatabase does not exist or is not found in the current working directory.\n"
fi
fi
fi


if [ "${pre_construct,,}" = "no" ]; then

printf "Building customized organism database for $local_name : \n"

IFS='_' read -r part1 part2 <<< "$local_name"
Rscript --vanilla -e "suppressPackageStartupMessages(library(AnnotationForge)); makeOrgPackageFromNCBI(version = '0.1', author = 'user <user@user.org>', maintainer = 'user <user@user.org>', outputDir = '.', tax_id = '$tax_id', genus = '$part1', species = '$part2', rebuildCache = FALSE)" 2> >(tee error_capture.log >&2) || exit 1
fi
done


while true; do

if [ "${pre_construct,,}" = "no" ]; then
while true; do
read -r -e -d $'\n' -p "Enter name of the customized annotation database : " db_name;
if [ -e "$db_name" ]; then
printf "The $db_name database exists.\n"
break
else
printf "The $db_name database not found. Kindly keep the database folder in the current working directory.\n"
fi
done
fi

if Rscript --vanilla -e "if (!('$db_name' %in% rownames(installed.packages()))) quit(status = 1)" >/dev/null 2>&1; then
printf "\nPackage '$db_name' is already installed."
else
printf "\nPackage '$db_name' is not installed.\n Installing package $db_name\n\n"
Rscript --vanilla -e "install.packages('./$db_name', repos=NULL)"
if Rscript --vanilla -e "if (!('$db_name' %in% rownames(installed.packages()))) quit(status = 1)" >/dev/null 2>&1; then
printf "\nSuccessfully installed R package : '$db_name'\n"
else
printf "\nPackage '$db_name' is not installed.\n Try installing separately using the below command inside the R environment.\n\n"
printf "install.packages('./$db_name', repos=NULL)\n\n"
exit 1
fi
fi
Rscript --vanilla -e "suppressPackageStartupMessages(library(${db_name}))"
if [[ $? -eq 0 ]]; then
printf "\nSuccessfully loaded R package: $db_name"
break
else
printf "\nPackage '$db_name' not found or failed to load. Try again."
fi
done


break
else
printf "\nInvalid selection. Try again : "
fi
done
printf "\n\nYour database name  is : $db_name\n\n"

# Loading our input data : DEG results:
printf "\e[33m"
check_path() {
if [ -e "$1" ]; then
return 0
else
return 1
fi
}
#while true; do
printf "\n"

last_dir="$HOME/"

# Get DEG result file of microRNA from user:
printf "\n\n\e[32mSelect Differential Gene Expression result file you wish to analyze .csv (edgeR/DESeq2; log-fold change, pvalue, padj/FDR) : \e[0m"
while true; do
deg_result_file=$(zenity --file-selection --title="Choose Differential Gene Expression result file you wish to analyze (.csv)" --filename="$last_dir/" --file-filter="CSV | *.csv")
if [[ -z "$deg_result_file" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose a valid file : "
continue
fi
header=$(head -n 1 "$deg_result_file")
if ! echo "$header" | grep -qE '(^|,)("?(log2FoldChange|log2FC|logFC)"?)(,|$)'; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mNeither log2FoldChange nor log2FC nor logFC column found in the input file. Select the correct differential expression .csv results file."
continue
fi
break
done
printf "$deg_result_file"

last_dir=$(dirname "$deg_result_file")

#read -r -e -d $'\n' -p 'Paste the Differential Gene Expression result file you wish to analyze with its absolute path (.csv): ' deg_result_file;
#if [[ "$deg_result_file" != /* ]]; then
#printf "\nPlease provide complete (absolute) path.\n"
#continue
#else
#printf "\e[0m"
#if check_path "$deg_result_file"; then
#if [[ "$deg_result_file" != *.csv ]]; then
#printf "\n\033[1m\e[31mERROR:\033[0m \e[0mThe path does not end with .csv Please enter the complete path again with the DEG result file : \n"
#continue
#fi
#printf "The path exists!\n\n"
#break
#else
#printf "\033[1m\e[31mERROR:\033[0m \e[0mThe path does not exist. Please enter an existing path : \n"
#fi
#fi
#done


printf "\n" "\n"


# Choose chart type for GO and KEGG
#chart=("Dotplot" "Enrichment Map" "Netplot" "Ridgeplot" "All")
printf "Please select the desired chart type from the above options:\n"

while true; do
chart_num=$(zenity --list \
    --title="Select an Option" \
    --column="No" \
    --column="Name" \
    1 "Dotplot"\
    2 "Enrichment Map"  \
    3 "Netplot"\
    4 "Ridgeplot"\
    5  "All" \
      --print-column=1)
if [[ -z "$chart_num" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi
break
done

echo "$chart_num"

#for i in "${!chart[@]}"; do
#printf "%2d) %s\n" $((i+1)) "${chart[$i]}"
#done
printf "\n\n"
#while true; do
#read -r -e -d $'\n' -p "Enter a number [1-5] :" chart_num
if [[ "$chart_num" =~ ^[1-5]$ ]]; then
chart_type="${chart[$((chart_num-1))]}"
#printf "You have choosen Chart Type : $chart_type\n"
#break
#else
#printf "Please select a number from [1-5]\n"
#continue
fi
#done

# Defining three-letter code for KEGG organism from KEGG Pathway database.
kegg_db=("hsa" "mmu" "rno" "dme" "dre" "ath" "sce" "cel" "ssc" "bta" "mcc" "cfa" "gga" "eco" "xla" "ptr" "aga" "ecs" "pfa" "mxa")
kegg_name="${kegg_db[$((choice_num-1))]}"

if [[ "$choice_num" == "21" ]]; then
printf "\e[0m\e[33m \n"
while true; do
printf "Get your organism's three-letter code from this website : https://www.genome.jp/kegg/tables/br08606.html\n"
#read -r -e -d $'\n' -p '(i) Enter three-letter code of your non-model organism : ' kegg_name;

kegg_name=$(zenity --entry \
	--title="Organism's three-letter code from KEGG" \
	--text="Enter three-letter code of your non-model organism : ")
if [[ -z "$kegg_name" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please provide a valid three-letter code : "
continue
fi

	# Handle cancel/close
[ $? -ne 0 ] && exit 1


echo "$db_name"

printf "\e[0m"
if [[ -z "$kegg_name" ]];
then
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mInput cannot be blank. Please provide valid name : "
continue
fi
printf "\nKEGG three-letter code : $kegg_name"
printf "\n\e[33m"
#read -r -e -d $'\n' -p 'Is this correct? (y/n) ' name_confirm


kegg_name_confirm=$(zenity  --list \
	--title=" Three-letter code of your non-model organism from KEGG database" \
	--text="Is the three-letter code of your non-model organism from KEGG database confirm ?  " \
	--radiolist \
    	--column="Select" \
   	 --column="Choice" \
    	TRUE "yes" \
   	FALSE "no" \
  	--print-column=2)

if [[ -z "$kegg_name_confirm" ]]; then
printf "\033[1m\e[31m\nERROR:\033[0m \e[0mInput cannot be blank. Please choose an option : "
continue
fi
# Handle cancel/close
[ $? -ne 0 ] && exit 1


echo "$kegg_name_confirm"


printf "\e[0m"
if [[ "${kegg_name_confirm,,}" == "yes" ]];
then
printf "\n\033[1m\e[0m Your input has been confirmed. \"$kegg_name\" will be used for KEGG pathway enrichment analysis\n"
break
else
printf "\n\033[1m\e[31mERROR:\033[0m \e[0mYour input has not been confirmed. Please enter name of non-model organism again : "
fi
done
fi

# Gene Ontology Enrichment
Rscript --vanilla -e "input <- read.table('$deg_result_file',header=TRUE,row.names=1,sep=','); gene_list <- row.names(input); cat('Gene name list from your DEG result file : \n'); cat(head(gene_list))"


printf "\nChoose appropriate gene type from the below list that match with genes from your DEG result file : \e[32m\033[1m(Choose SYMBOL if DEG results are based on NCBI RefSeq mapping and annotation.)\033[0m \n"
eval $(Rscript --vanilla -e "suppressPackageStartupMessages(library(${db_name})); genetype_list <- keytypes(${db_name}); cat('genes=(', paste0('\"', genetype_list, '\"', collapse=' '), ')')")
for i in "${!genes[@]}"; do printf "%2d) %s\n" $((i+1)) "${genes[$i]}"; done
tot_num="${#genes[@]}"
printf "\n\n"
while true; do
read -r -e -d $'\n' -p "Enter a number [1-$tot_num] :" choice_list
if [[ "$choice_list" =~ ^[0-9]+$ ]] && (( choice_list >= 1 && choice_list <= tot_num )); then
gene_type="${genes[$((choice_list-1))]}"
printf "\nYou have selected : \"$gene_type\". This will be used for gene type conversion during enrichment analysis.\n"
#### Write enrichGO script here ...... ###############

# Create backup folders for Gene Ontology results:
if [[ -d "Gene_Ontology_results" ]]; then
base_folder="Gene_Ontology_Analysis_Backup"
existing_folders=$(find . -maxdepth 1 -type d -name "${base_folder}_*" 2>/dev/null)

if [[ -z "$existing_folders" ]]; then
highest_num=0
else
  highest_num=$(echo "$existing_folders" \
    | sed -E "s|.*/${base_folder}_([0-9]+)$|\1|" \
    | grep -E '^[0-9]+$' \
    | sort -n \
    | tail -n 1)

# In case all folders were malformed and none passed the regex
if [[ -z "$highest_num" ]]; then
highest_num=0
fi
fi

next_num=$((highest_num + 1))
new_folder="${base_folder}_${next_num}"

echo "Folders found from previous analysis results."
echo "Attempting to create a backup folder, '$new_folder' to keep the previously analysed results."
mkdir "$new_folder"
touch testfile && rm testfile || { echo "Cannot create backup folder in $(pwd)"; exit 1; }
fi

if [[ -d "Gene_Ontology_results" ]] && [[ -n "$(ls -A Gene_Ontology_results 2>/dev/null)" ]]; then
mv Gene_Ontology_results/ "$new_folder"
mkdir -p Gene_Ontology_results/
fi
if [[ ! -d "Gene_Ontology_results" ]]; then
mkdir -p Gene_Ontology_results/
fi

cd Gene_Ontology_results
dir_name=$(basename "$deg_result_file")
if [[ ! -d "${dir_name}" ]]; then
mkdir $dir_name
fi
cd $dir_name
# Gene Ontology : Cellular Component
if [[ ! -d "Cellular_Component" ]]; then
mkdir -p Cellular_Component
fi
cd Cellular_Component
result_cc=$(Rscript --vanilla -e "suppressPackageStartupMessages(library(clusterProfiler)); suppressPackageStartupMessages(library(ggplot2)); suppressPackageStartupMessages(library(enrichplot)); suppressPackageStartupMessages(library(ggridges)); suppressPackageStartupMessages(library(${db_name})); input <- read.table('${deg_result_file}', header=TRUE, row.names=1, sep=','); if('log2FoldChange' %in% colnames(input)){original_gene_list <- input[['log2FoldChange']]} else if('log2FC' %in% colnames(input)){original_gene_list <- input[['log2FC']]} else if('logFC' %in% colnames(input)){original_gene_list <- input[['logFC']]} else {stop('Neither log2FoldChange nor log2FC nor logFC column found in the input file.')}; names(original_gene_list) <- row.names(input); gene_list <- sort(na.omit(original_gene_list), decreasing=TRUE); go_result <- tryCatch({ msg <- capture.output({ res <- gseGO(geneList=gene_list, ont='CC', keyType='${gene_type}', pvalueCutoff=0.05, OrgDb=get('${db_name}'), verbose=TRUE, pAdjustMethod='BH', minGSSize=3, maxGSSize=800)}, type='message'); list(result=res, stderr=msg) }, error=function(e){ list(result=FALSE, stderr=FALSE)}); if(isFALSE(is.list(go_result)) || (isFALSE('result' %in% names(go_result)) && isFALSE('stderr' %in% names(go_result))) || (isFALSE(go_result\$result) && isFALSE(go_result\$stderr))) { stop('Gene Enrichment was not performed. Choose the appropriate gene type.\\n') } else { cat('Gene Ontology Enrichment is completed for Cellular Component\\n'); if(nrow(go_result\$result@result)>0){df <- go_result\$result@result; cat(capture.output(head(df)), sep='\\n'); write.table(df, 'Cellular_Component_GO_results.tsv', sep='\\t', quote=FALSE); chart_num <- ${chart_num}; if(chart_num==1){a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Cellular_Component_dotplot.png', width=1500, height=1000, res=140); print(a); dev.off()} else if(chart_num==2){x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Cellular_Component_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off()} else if(chart_num==3){ c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Cellular_Component_netplot.png', width=3500, height=2000, res=200); print(c); dev.off()} else if(chart_num==4){d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Cellular_Component_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} else {a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Cellular_Component_dotplot.png', width=1500, height=2000, res=140); print(a); dev.off(); x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Cellular_Component_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off(); c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Cellular_Component_netplot.png', width=3500, height=2000, res=200); print(c); dev.off(); d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Cellular_Component_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} } else {cat(go_result\$stderr)}}")


if [[ -z "$result_cc" ]]; then
cd ../../../
continue
else
echo "$result_cc" | tail -n 1
printf "\nGene Ontology Enrichment -- \"Cellular Component\" module is completed for the DEG results : \"${dir_name}\".\n"
cd ../
# Gene Ontology : Biological Process
if [[ ! -d "Biological_Process" ]]; then
mkdir -p Biological_Process
fi
cd Biological_Process

result_bp=$(Rscript --vanilla -e "suppressPackageStartupMessages(library(clusterProfiler)); suppressPackageStartupMessages(library(ggplot2)); suppressPackageStartupMessages(library(enrichplot)); suppressPackageStartupMessages(library(ggridges)); suppressPackageStartupMessages(library(${db_name})); input <- read.table('${deg_result_file}', header=TRUE, row.names=1, sep=','); if('log2FoldChange' %in% colnames(input)){original_gene_list <- input[['log2FoldChange']]} else if('log2FC' %in% colnames(input)){original_gene_list <- input[['log2FC']]} else if('logFC' %in% colnames(input)){original_gene_list <- input[['logFC']]} else {stop('Neither log2FoldChange nor log2FC nor logFC column found in the input file.')}; names(original_gene_list) <- row.names(input); gene_list <- sort(na.omit(original_gene_list), decreasing=TRUE); go_result <- tryCatch({ msg <- capture.output({ res <- gseGO(geneList=gene_list, ont='BP', keyType='${gene_type}', pvalueCutoff=0.05, OrgDb=get('${db_name}'), verbose=TRUE, pAdjustMethod='BH', minGSSize=3, maxGSSize=800)}, type='message'); list(result=res, stderr=msg) }, error=function(e){ list(result=FALSE, stderr=FALSE) }); if(isFALSE(is.list(go_result)) || (isFALSE('result' %in% names(go_result)) && isFALSE('stderr' %in% names(go_result))) || (isFALSE(go_result\$result) && isFALSE(go_result\$stderr))) { stop('Gene Enrichment was not performed. Choose the appropriate gene type.\\n') } else { cat('Gene Ontology Enrichment is completed for Biological Process\\n'); if(nrow(go_result\$result@result)>0){df <- go_result\$result@result; cat(capture.output(head(df)), sep='\\n'); write.table(df, 'Biological_Process_GO_results.tsv', sep='\\t', quote=FALSE); chart_num <- ${chart_num}; if(chart_num==1){a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Biological_Process_dotplot.png', width=1500, height=1000, res=140); print(a); dev.off()} else if(chart_num==2){x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Biological_Process_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off()} else if(chart_num==3){c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Biological_Process_netplot.png', width=3500, height=2000, res=200); print(c); dev.off()} else if(chart_num==4){d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Biological_Process_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} else {a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Biological_Process_dotplot.png', width=1500, height=2000, res=140); print(a); dev.off(); x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Biological_Process_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off(); c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Biological_Process_netplot.png', width=3500, height=2000, res=200); print(c); dev.off(); d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Biological_Process_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} } else { cat(go_result\$stderr) }}")
echo "$result_bp" | tail -n 1
printf "\nGene Ontology Enrichment -- \"Biological Process\" module is completed for the DEG results : \"${dir_name}\".\n"
cd ../
# Gene Ontology : Molecular Function
if [[ ! -d "Molecular_Function" ]]; then
mkdir -p Molecular_Function
fi
cd Molecular_Function

result_mf=$(Rscript --vanilla -e "suppressPackageStartupMessages(library(clusterProfiler)); suppressPackageStartupMessages(library(ggplot2)); suppressPackageStartupMessages(library(enrichplot)); suppressPackageStartupMessages(library(ggridges)); suppressPackageStartupMessages(library(${db_name})); input <- read.table('${deg_result_file}', header=TRUE, row.names=1, sep=','); if('log2FoldChange' %in% colnames(input)){original_gene_list <- input[['log2FoldChange']]} else if('log2FC' %in% colnames(input)){original_gene_list <- input[['log2FC']]} else if('logFC' %in% colnames(input)){original_gene_list <- input[['logFC']]} else {stop('Neither log2FoldChange nor log2FC nor logFC column found in the input file.')}; names(original_gene_list) <- row.names(input); gene_list <- sort(na.omit(original_gene_list), decreasing=TRUE); go_result <- tryCatch({ msg <- capture.output({ res <- gseGO(geneList=gene_list, ont='MF', keyType='${gene_type}', pvalueCutoff=0.05, OrgDb=get('${db_name}'), verbose=TRUE, pAdjustMethod='BH', minGSSize=3, maxGSSize=800)}, type='message'); list(result=res, stderr=msg) }, error=function(e){ list(result=FALSE, stderr=FALSE) }); if(isFALSE(is.list(go_result)) || (isFALSE('result' %in% names(go_result)) && isFALSE('stderr' %in% names(go_result))) || (isFALSE(go_result\$result) && isFALSE(go_result\$stderr))) { stop('Gene Enrichment was not performed. Choose the appropriate gene type.\\n') } else { cat('Gene Ontology Enrichment is completed for Molecular Function\\n'); if(nrow(go_result\$result@result)>0) {df <- go_result\$result@result; cat(capture.output(head(df)), sep='\\n'); write.table(df, 'Molecular_Function_GO_results.tsv', sep='\\t', quote=FALSE); chart_num <- ${chart_num}; if(chart_num==1){a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Molecular_Function_dotplot.png', width=1500, height=1500, res=140); print(a); dev.off()} else if(chart_num==2){x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Molecular_Function_enrichmentmap.png', width=1500, height=2000, res=140); print(b); dev.off()} else if(chart_num==3){c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Molecular_Function_netplot.png', width=3500, height=2000, res=200); print(c); dev.off()} else if(chart_num==4){d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Molecular_Function_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} else {a <- dotplot(go_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('GO-Molecular_Function_dotplot.png', width=1500, height=1500, res=140); print(a); dev.off(); x2 <- pairwise_termsim(go_result\$result); b <- emapplot(x2, showCategory=10); png('GO-Molecular_Function_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off(); c <- cnetplot(go_result\$result,foldChange = gene_list,showCategory = 3); png('GO-Molecular_Function_netplot.png', width=3500, height=2000, res=200); print(c); dev.off(); d <- ridgeplot(go_result\$result) + labs(x='enrichment distribution'); png('GO-Molecular_Function_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} } else { cat(go_result\$stderr) }}")

echo "$result_mf" | tail -n 1
printf "\nGene Ontology Enrichment -- \"Molecular Function\" module is completed for the DEG results : \"${dir_name}\".\n"
cd ../
cd ../../

# gseKEGG

# Create backup folders for KEGG results:
if [[ -d "KEGG_results" ]]; then
base_folder="KEGG_Analysis_Backup"
existing_folders=$(find . -maxdepth 1 -type d -name "${base_folder}_*" 2>/dev/null)

if [[ -z "$existing_folders" ]]; then
highest_num=0
else
  highest_num=$(echo "$existing_folders" \
    | sed -E "s|.*/${base_folder}_([0-9]+)$|\1|" \
    | grep -E '^[0-9]+$' \
    | sort -n \
    | tail -n 1)

# In case all folders were malformed and none passed the regex
if [[ -z "$highest_num" ]]; then
highest_num=0
fi
fi

next_num=$((highest_num + 1))
new_folder="${base_folder}_${next_num}"
echo "Folders found from previous analysis results."
echo "Attempting to create a backup folder, '$new_folder' to keep the previously analysed results."
mkdir "$new_folder"
touch testfile && rm testfile || { echo "Cannot create backup folder in $(pwd)"; exit 1; }
fi


if [[ -d "KEGG_results" ]] && [[ -n "$(ls -A KEGG_results 2>/dev/null)" ]]; then
mv KEGG_results/ "$new_folder"
mkdir -p KEGG_results/
fi

if [[ ! -d "KEGG_results" ]]; then
mkdir -p KEGG_results/
fi

cd KEGG_results
if [[ ! -d "${dir_name}" ]]; then
mkdir $dir_name
fi
cd $dir_name

# Prepare input for KEGG. KEGG Analysis
kegg_input=$(Rscript --vanilla -e "suppressPackageStartupMessages(library(clusterProfiler)); suppressPackageStartupMessages(library(ggplot2)); suppressPackageStartupMessages(library(enrichplot)); suppressPackageStartupMessages(library(ggridges)); suppressPackageStartupMessages(library(${db_name})); input <- read.table('${deg_result_file}', header=TRUE, row.names=1, sep=','); if('log2FoldChange' %in% colnames(input)){original_gene_list <- input[['log2FoldChange']]} else if('log2FC' %in% colnames(input)){original_gene_list <- input[['log2FC']]} else if('logFC' %in% colnames(input)){original_gene_list <- input[['logFC']]} else {stop('Neither log2FoldChange nor log2FC nor logFC column found in the input file.')}; names(original_gene_list) <- row.names(input); ids <- bitr(names(original_gene_list), fromType='${gene_type}', toType='ENTREZID', OrgDb=get('${db_name}')); dedup_ids <- ids[!duplicated(ids[c('${gene_type}')]),]; df2 <- input[row.names(input) %in% dedup_ids\$'${gene_type}',]; df2\$Y <- dedup_ids\$ENTREZID; df_clean <- df2[!(df2\$Y %in% df2\$Y[duplicated(df2\$Y) | duplicated(df2\$Y, fromLast = TRUE)]), ]; if('log2FoldChange' %in% colnames(input)){kegg_gene_list <- df_clean\$log2FoldChange} else if('log2FC' %in% colnames(input)){kegg_gene_list <- df_clean\$log2FC} else if('logFC' %in% colnames(input)){kegg_gene_list <- df_clean\$logFC} else {stop('Neither log2FoldChange nor log2FC nor logFC column found in the input file.')}; names(kegg_gene_list) <- df_clean\$Y; kegg_gene_list <- sort(na.omit(kegg_gene_list), decreasing=TRUE); kegg_organism <- '${kegg_name}'; kegg_result <- tryCatch({ msg <- capture.output({ res <- gseKEGG(geneList=kegg_gene_list, organism=kegg_organism, minGSSize=3, maxGSSize=800, pvalueCutoff=0.05, pAdjustMethod='BH', keyType='ncbi-geneid')}, type='message'); list(result=res, stderr=msg) }, error=function(e) {list(result=FALSE, stderr=FALSE)}); if(isFALSE(is.list(kegg_result)) || (isFALSE('result' %in% names(kegg_result)) && isFALSE('stderr' %in% names(kegg_result))) || (isFALSE(kegg_result\$result) && isFALSE(kegg_result\$stderr))) { stop('KEGG Enrichment was not performed. Choose the appropriate gene type.\\n') } else { cat('KEGG Pathway Enrichment is completed.\\n'); if(nrow(kegg_result\$result@result)>0) {df <- kegg_result\$result@result; cat(capture.output(head(df)), sep='\\n'); write.table(df, 'KEGG_results.tsv', sep='\\t', quote=FALSE); chart_num <- ${chart_num}; if(chart_num==1){a <- dotplot(kegg_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('KEGG_enrichment_dotplot.png', width=1500, height=1000, res=140); print(a); dev.off()} else if(chart_num==2){x2 <- pairwise_termsim(kegg_result\$result); b <- emapplot(x2, showCategory=10); png('KEGG_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off()} else if(chart_num==3){c <- cnetplot(kegg_result\$result,foldChange = kegg_gene_list,showCategory = 3); png('KEGG_enrichment_netplot.png', width=3500, height=2000, res=200); print(c); dev.off()} else if(chart_num==4){d <- ridgeplot(kegg_result\$result) + labs(x='enrichment distribution'); png('KEGG_enrichment_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()} else {a <- dotplot(kegg_result\$result, showCategory=10, split='.sign') + facet_grid(.~.sign); png('KEGG_enrichment_dotplot.png', width=1500, height=2000, res=140); print(a); dev.off(); x2 <- pairwise_termsim(kegg_result\$result); b <- emapplot(x2, showCategory=10); png('KEGG_enrichmentmap.png', width=1500, height=1000, res=140); print(b); dev.off(); c <- cnetplot(kegg_result\$result,foldChange = kegg_gene_list,showCategory = 3); png('KEGG_enrichment_netplot.png', width=3500, height=2000, res=200); print(c); dev.off(); d <- ridgeplot(kegg_result\$result) + labs(x='enrichment distribution'); png('KEGG_enrichment_ridgeplot.png', width=1500, height=2000, res=140); print(d); dev.off()}} else {cat(kegg_result\$stderr)}}")


echo "$kegg_input" | tail -n 1
printf "\nKEGG Pathway Enrichment module is completed for the DEG results : \"${dir_name}\".\n"
cd ../
break
fi

else
printf "\nPlease select a number within the available range [1-$tot_num].\n"
fi
done

