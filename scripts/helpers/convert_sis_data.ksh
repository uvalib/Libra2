#
# converts a CSV of SIS data (from Xiaoming) to a text file we can load
#

INFILE=data/sis_query.txt
OUTFILE=data/sis_data.txt
rm -fr $OUTFILE > /dev/null 2>&1

if [ ! -f $INFILE ]; then
   echo "ERROR: $INFILE is missing or not readable, aborting"
   exit 1
fi

echo "Processing $INFILE..."

cat $INFILE | grep "libra-oa" | sed -e 's/^\| //g' | sed -e 's/ \| /\|/g' | sed -e 's/ *\|$//' | tr -d " " > $OUTFILE

echo "Created $OUTFILE successfully"

#
# end of file
#
