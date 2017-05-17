#
# converts a CSV of SIS data (from Xiaoming) to a text file we can load
#

INFILE=data/sis_records.csv
OUTFILE=data/sis_data.txt
TEMPFILE=/tmp/sis.data$$
rm -fr $TEMPFILE > /dev/null 2>&1
rm -fr $OUTFILE > /dev/null 2>&1

if [ ! -f $INFILE ]; then
   echo "ERROR: $INFILE is missing or not readable, aborting"
   exit 1
fi

echo "Processing $INFILE..."

# convert to UTF-8 and change CR characters
iconv -f iso-8859-1 -t utf-8 < data/sis_records.csv | tr "\r" "\n" > $TEMPFILE

# split the fields and extract what we need...
cat $TEMPFILE | awk -F\; '{printf "%s|%s\n", $15, $8}'|grep libra-oa | tr -d "\"" | sort -n > $OUTFILE

rm -fr $TEMPFILE > /dev/null 2>&1
echo "Created $OUTFILE successfully"

#
# end of file
#
