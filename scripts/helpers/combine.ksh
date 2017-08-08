#
# Combines the DOI redirect files from libra ETD and libra OC into a single file per the Bob's desires.
#

SRC_NAME=L1_to_L2_doi.txt

LIBRA_ETD_DIR=~/Sandboxes/libra2
LIBRA_OC_DIR=~/Sandboxes/libra-oc

ETD_INFILE=$LIBRA_ETD_DIR/data/$SRC_NAME
OC_INFILE=$LIBRA_OC_DIR/data/$SRC_NAME

DATAVERSE_FILE=/tmp/dataverse_urls
rm -f $DATAVERSE_FILE > /dev/null 2>&1

cat > $DATAVERSE_FILE <<XXEND
libra-oa:6715 doi:10.18130/V3/HDBXVY
libra-oa:8239 doi:10.18130/V3/LWPBIY
libra-oa:7509 doi:10.18130/V3/XZ2YLD
libra-oa:3500 doi:10.18130/V3/HOOJSE
libra-oa:3272 doi:10.18130/V3/NEPGOL
libra-oa:2781 doi:10.18130/V3/QAIK3R
libra-oa:2638 doi:10.18130/V3/2IVQ9Z
XXEND

OUTFILE=~/Downloads/L1_to_L2_doi.txt
rm -f $OUTFILE > /dev/null 2>&1

for f in $ETD_INFILE $OC_INFILE; do
   if [ ! -r $f ]; then
      echo "ERROR: $f does not exist or is not readable, aborting"
      exit 1
   fi
done

for f in $ETD_INFILE $OC_INFILE $DATAVERSE_FILE; do
   COUNT=$(wc -l $f | awk '{print $1}')
   echo "Combining $COUNT records from $f"
done

cat $ETD_INFILE $OC_INFILE $DATAVERSE_FILE | sort > $OUTFILE
echo "Results in $OUTFILE"
exit 0

#
# end of file
#
