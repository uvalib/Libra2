#
# attempts to detect diffs in the libra2 namespace assets
#

DIFF_TOOL=/Applications/DiffMerge.app/Contents/MacOS/DiffMerge

# where to start looking
ROOT_DIR=lib/libra2/app/views

GEM_BASE=/Users/dpg3k/.rvm/gems/ruby-2.3.0
SUFIA_ROOT=$GEM_BASE/gems/sufia-7.0.0.beta4
CURATION_CONCERNS_ROOT=$GEM_BASE/gems/curation_concerns-1.0.0

DIFF_FILE=/tmp/diff-list.$$
rm -fr $DIFF_FILE > /dev/null 2>&1

CMD_FILE=/tmp/diff-cmd.$$
rm -fr $CMD_FILE > /dev/null 2>&1

find $ROOT_DIR -type f > $DIFF_FILE

echo "Using sufia:             $SUFIA_ROOT"
echo "Using curation concerns: $CURATION_CONCERNS_ROOT"
echo "Ensure these are current..."
echo ""

lines=$(wc -l $DIFF_FILE| awk '{print $1}')
if [ $lines -eq 0 ]; then
   echo "ERROR: no customized elements located; aborting."
   exit 1
fi

for file in $(<$DIFF_FILE); do
   part=${file#lib/libra2/}
   location=""

   if [ -f $SUFIA_ROOT/$part ]; then
      location=$SUFIA_ROOT
   fi

   if [ -n "$location" ]; then
      diff $location/$part $file > /dev/null 2>&1
      res=$?
      if [ $res -ne 0 ]; then
         echo "$DIFF_TOOL $file $location/$part" >> $CMD_FILE
      fi

   else
      echo "ERROR: cannot locate source for customized element $file"
   fi

done

# do the special cases
echo "$DIFF_TOOL lib/libra2/app/models/concerns/libra2/basic_metadata.rb $CURATION_CONCERNS_ROOT/app/models/concerns/curation_concerns/basic_metadata.rb" >> $CMD_FILE


lines=$(wc -l $CMD_FILE| awk '{print $1}')
if [ $lines -ne 0 ]; then
   echo "Created diff command file with $lines entries"
   echo $CMD_FILE
else
   echo "No diffs identified"
   rm -fr $CMD_FILE > /dev/null 2>&1
fi

rm -fr $DIFF_FILE > /dev/null 2>&1

