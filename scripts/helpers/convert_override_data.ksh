#
# converts a CSV of SIS data (from Xiaoming) to a text file we can load
#

INFILE=data/Proquest_Migration_NoEmbargo.csv
OUTFILE=data/embargo_override.txt
rm -fr $OUTFILE > /dev/null 2>&1

if [ ! -f $INFILE ]; then
   echo "ERROR: $INFILE is missing or not readable, aborting"
   exit 1
fi

echo "Processing $INFILE..."

cat $INFILE | grep "libra-oa" | tr "\r" "\n" | awk -F, '{printf "%s|open||\n", $2}' > $OUTFILE

echo "Created $OUTFILE successfully"

#
# end of file
#
