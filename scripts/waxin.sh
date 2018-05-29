#! /usr/bin/env bash

normal=$(tput sgr0)
bold=$(tput bold)
VERSION="$(basename "$0") v1.0"

function usage() {
    welcome
    echo "      $(basename "$0") -i ID -x XML -r REF -t THREADS -m MAXITER [--tmp TMPDIR] [-h] [-v]"
    echo ""
    echo "              -i, --id         ID for project"
    echo "              -x, --xml        PacBio DataSet XML file"
    echo "              -r, --reference  Reference FASTA file"
    echo "              -t, --threads    Threads (Default: 64)"
    echo "              -m, --maxiter    Number of iterations (Default: 3)"
    echo "              --tmp            TMP directory (Default: tmp/)"
    echo ""
    echo "              -h, --help       Show this help text"
    echo "              -v, --version    Show version"
    echo ""
}

function welcome(){
    echo "${bold}"
    echo "      ====================±=======";
    echo "      ${VERSION}         (_)      ";
    echo "      __      ____ ___  ___ _ __  ";
    echo "      \ \ /\ / / _\` \ \/ / | '_ \ ";
    echo "       \ V  V / (_| |>  <| | | | |";
    echo "        \_/\_/ \__,_/_/\_\_|_| |_|";
    echo "      ============================${normal}";
}
# # trap ctrl-c and call ctrl_c()
# trap ctrl_c INT
# function ctrl_c() {
#   echo "** Trapped CTRL-C"
# }

# Mapping
function map() {
    T="$(date +%s)"
    echo "[#] Mapping against $REF ..."
    #command -v pbalign >/dev/null 2>&1 || { echo >&2 "[X] pbalign must be in \$PATH. Aborting."; exit 1; }
    echo ""
    echo "      > pbalign \\ "
    echo "              --nproc ${CPU} \\ "
    echo "              --tmpDir=${TMP} \\ "
    echo "              --unaligned ${UNM} \\ "
    echo "              ${XML} ${REF} ${BAM}"
    # pbalign --nproc $CPU --tmpDir=$TMP --unaligned $UNM $XML $REF $BAM
    T="$(($(date +%s)-T))"
    echo ""
    printf "    => Elapsed : %02dd:%02dh:%02dm:%02ds\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
}

# Variant calling
function call() {
    T="$(date +%s)"
    echo "[#] Calling based on $BAM ..."
    #command -v samtools >/dev/null 2>&1 || { echo >&2 "[X] samtools must be in \$PATH. Aborting."; exit 1; }
    echo ""
    echo "      > samtools faidx $REF"
    # samtools faidx ${REF}
    echo ""
    #command -v variantCaller >/dev/null 2>&1 || { echo >&2 "[X] variantCaller must be in \$PATH. Aborting."; exit 1; }
    echo "      > variantCaller \\ "
    echo "              --referenceFilename=${REF} \\ "
    echo "              --outputFilename=${OUT}.fq \\"
    echo "              --outputFilename=${OUT}.fa \\"
    echo "              --outputFilename=${OUT}.vcf \\"
    echo "              --outputFilename=${OUT}.gff \\"
    echo "              --numWorkers=${CPU} \\"
    echo "              --algorithm=arrow \\"
    echo "              ${BAM}"
    # variantCaller --referenceFilename=$REF --outputFilename=$OUT.fq --outputFilename=$OUT.fa --outputFilename=$OUT.vcf --outputFilename=$OUT.gff --numWorkers=$CPU --algorithm=arrow $BAM
    T="$(($(date +%s)-T))"
    echo ""
    printf "    => Elapsed : %02dd:%02dh:%02dm:%02ds\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
}

# Command line parsing

ID=""
XML=""
REF=""
CPU=64
CNT=3
TMP="tmp/"

while [[ $# -gt 0 ]]
do
    key="${1}"
    case ${key} in
        -i|--id)
            ID="${2}"
            shift # past argument
            shift # past value
            ;;
        -x|--xml)
            XML="${2}"
            shift # past argument
            shift # past value
            ;;
        -r|--reference)
            REF="${2}"
            shift # past argument
            shift # past value
            ;;
        -t|--threads)
            CPU="${2}"
            shift # past argument
            shift # past value
            ;;
        -m|--maxiter)
            CNT="${2}"
            shift # past argument
            shift # past value
            ;;
        --tmp)
            TMP="${2}"
            shift # past argument
            shift # past value
            ;;
        -v|--version)
            echo "${VERSION}"
            exit 1
            ;;
        -h|--help)
            usage
            exit 1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [[ -z $ID || -z $XML || -z $REF || -z $CPU || -z $CNT || -z $TMP ]] ; then
    usage
    exit 1
fi

BAM="${ID}.${ref%.*}bam"
UNM="${ID}.${ref%.*}unmapped.txt"

welcome
echo "${bold}"
printf '%40s\n' | tr ' ' -
echo "[+] Initial mapping"
printf '%40s\n' | tr ' ' -
echo "${normal}"
map
for i in `seq $CNT`; do
    echo "${bold}"
    printf '%40s\n' | tr ' ' -
    echo "[+] ARROW - Iteration ${i} of ${CNT}"
    printf '%40s\n' | tr ' ' -
    echo "${normal}"
    OUT="${ID}.arrow.i${i}"
    call
    REF="${OUT}.fa"
    BAM="${OUT}.bam"
    UNM="${OUT}.unmapped.txt"
    echo ""
    map
done
