#
# Combines the DOI redirect files from libra ETD and libra OC into a single file per the Bob's desires.
#

SRC_NAME=L1_to_L2_doi.txt

LIBRA_ETD_DIR=~/Sandboxes/libra2
LIBRA_OC_DIR=~/Sandboxes/libra-oc

ETD_INFILE=$LIBRA_ETD_DIR/data/$SRC_NAME
OC_INFILE=$LIBRA_OC_DIR/data/$SRC_NAME

OUTFILE=~/Downloads/L1_to_L2_doi.txt
rm -f $OUTFILE > /dev/null 2>&1

for f in $ETD_INFILE $OC_INFILE; do
   if [ ! -r $f ]; then
      echo "ERROR: $f does not exist or is not readable, aborting"
      exit 1
   fi
done

for f in $ETD_INFILE $OC_INFILE; do
   COUNT=$(wc -l $f | awk '{print $1}')
   echo "Combining $COUNT records from $f"
done

cat $ETD_INFILE $OC_INFILE | sort > $OUTFILE
echo "Results in $OUTFILE"
exit 0

#
# end of file
#
