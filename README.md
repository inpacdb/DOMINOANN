#DOMINOANN v1.0 (Data Ontology Mapping Integration for Non-model Organism Annotation): A Fully Automated Bash and Zenity GUI-Based Workflow for Customized Functional Enrichment Analysis

DOMINOANN v1.0 is a fully automated bash script and R based pipeline with a Zenity utility based graphical user interface (GUI) for functional enrichment analysis for non model organisms using differentially expressed genes (DEGs) . DOMINOANN performs gene annotation and pathway enrichment analysis using Gene Ontology (GO) and KEGG databases by automatically retrieving organism-specific annotation resources, constructing customized annotation databases and performing functional enrichment analysis. The pipeline additionally generates integrated graphical visualizations within a single workflow. 

Packages Required to run DOMINOANN v1.0

r-base
r-biocmanager
r-ggplot2
r-ggridges
r-rcolorbrewer
bioconductor-annotationforge
bioconductor-biomart
bioconductor-clusterprofiler
bioconductor-enrichplot

This repository contains three variants of the pipeline:
1.	Docker Variant: Runs in an isolated Docker container (recommended for stability) 
2.	Zenity_GUI_Variant and  Runs directly on your host machine (recommended for beginners in command line interface) 
3.	Native_CLI Variant :  Runs directly on your host machine (recommended for modularity and advanced users) 

Option 1: DOCKER VARIANT
Located in the /docker_variant folder.
This version is pre-packaged with all the dependencies required to run the pipeline.
1. Pre-requisites:
•	Docker Desktop
 
2. Setup:
1. To build the docker image for DOMINOANN v1.0: (Please do not rename the Dockerfile, as it is required for the build process.)
cd docker_variant
sudo docker build -t user/enrichment_tools:latest .

2. Run docker image using below command:
sudo docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v "$HOME:$HOME" user/enrichment_tools:latest
3.Running the Pipeline:
Inside the docker container, Navigate to the path where the pipeline scripts are kept and run the pipeline script as usual.
cd  /path_to_docker_variant_folder
bash enrichment_pipeline.sh

Option 2: ZENITY_GUI_VARIANT 
For both Variant,  either single line conda command installation (recommended) or installing individual packages separately using the corresponding conda command can be used. 
Located in the /Zenity_GUI_Variant 
This version runs directly on your OS via a Conda environment.
1. Pre-requisites:
•	Anaconda / Miniconda / 
2. DOMINOANN v1.0 Installation:

1.Single-line installation command using conda:

conda create -n enrichment_tools tsnyder::figlet r-base r-ggplot2 r-ggridges r-rcolorbrewer r-biocmanager bioconductor-clusterprofiler bioconductor-biomart bioconductor-annotationforge bioconductor-enrichplot -y

After successful run using above command, activate the environment using the following command, 

conda activate enrichment_tools

2. Alternatively, you can install the individual packages separately using the corresponding Conda commands.
R-base                 -  “conda install -y conda-forge::r-base"
clusterProfiler     - "conda install -y bioconda::bioconductor-clusterprofiler"
ggplot2                - "conda install -y conda-forge::r-ggplot2"
enrichplot            - "conda install -y bioconda::bioconductor-enrichplot"
ggridges               - "conda install -y conda-forge::r-ggridges"
AnnotationForge  - "conda install bioconda::bioconductor-annotationforge"
biomaRt               - "conda install bioconda::bioconductor-biomart"
BiocManager       - "conda install conda-forge::r-biocmanager"

3. Running the Pipeline:
In the command line Interface on your desktop, activate your conda environment and run the bash script.
conda activate enrichment_tools
cd /Zenity_GUI_Variant 
bash enrichment_pipeline_zenity_version.sh


Option 3: NATIVE_CLI VARIANT 
Located in the /Native_CLI Variant folder.
This version runs directly on your OS via a Conda environment.
Pre-requisites and DOMINOANN v1.0 Installation are same as mentioned under the column of ZENITY_GUI_VARIANT

While Running the Pipeline in the command line interface, activate your conda environment and run the bash script.
conda activate enrichment_tools
cd /Native_CLI Variant
bash enrichment_pipeline.sh

How it works:

•	DOMINOANN v1.0 creates, verifies, and installs the custom database for model organisms. 

•	For non-model organisms, the pipeline creates and installs a custom database using the generated NCBI.sqlite file, the organism name, and the corresponding NCBI Taxonomy ID. 

•	Once the custom annotation database is generated, it performs GO and KEGG enrichment analysis. 

•	With Ontology category ("BP" for Biological Process, "MF" for Molecular Function, "CC" for Cellular Component), pAdjustMethod: "BH" (Benjamini-Hochberg), pvalueCutoff: 0.05 and qvalueCutoff: 0.05, the GO enrichment analysis has been performed. 

•	KEGG pathway enrichment analysis was also performed using the same set of differentially expressed genes. 

Input

The pipeline accepts a comma-separated values (.csv) file containing the Differential Gene Expression (DEG) results, provided with its absolute file path.

Required columns:

- GeneSymbol
- logFC/log2FoldChange/log2FC
- padj

Output Files
The pipeline generates two folders after finishing the analysis.

1)	Gene_Ontology_results
2)	KEGG_results

1) Gene_Ontology_results
Within the Gene_Ontology_results folder, a subfolder is automatically created based on the name of the input DEG file provided in .csv format (e.g., Treatment_vs_control). This folder contains three subfolders corresponding to the three Gene Ontology categories:
•	Biological_Process 
•	Cellular_Component 
•	Molecular_Function 
Each subfolder contains the corresponding functional enrichment analysis results, including the enrichment results in .tsv format and the associated visualization plots. Examples of the files generated within each folder are shown below:

•	Biological_Process_GO_results.tsv 
•	GO-Biological_Process_dotplot.png 
•	GO-Biological_Process_enrichmentmap.png 
•	GO-Biological_Process_netplot.png 
•	GO-Biological_Process_ridgeplot.png 



The same file structure is followed for the Cellular Component and Molecular Function categories, with the respective category names reflected in the filenames.

2) KEGG_results
Within the KEGG_Results folder also,  a subfolder is automatically created based on the name of the input DEG file provided in .csv format (e.g., Treatment_vs_control). This folder contains the functional enrichment analysis results, including the enrichment results in .tsv format and the associated visualization plots as follows :
•	KEGG_results.tsv
•	KEGG_enrichment_dotplot.png  
•	KEGG_enrichmentmap.png
•	KEGG_enrichment_netplot.png
•	KEGG_enrichment_ridgeplot.png

Authors:
Dr. Umashankar Vetrivel, Roja Jayaraman & Infanta Saleth Teresa Eden M Department of Virology and Biotechnology, Bioinformatics Division, Indian Council for Medical Research -National Institute for Research in Tuberculosis (ICMR-NIRT), Chennai, India.

