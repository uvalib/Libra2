#
# attempts to detect diffs in the libra2 namespace assets
#

DIFF_TOOL=/Applications/DiffMerge.app/Contents/MacOS/DiffMerge

# where to start looking
ROOT_DIR=lib/libra2/app/views

GEM_BASE=/Users/dpg3k/.rvm/gems/ruby-2.3.0
SUFIA_ROOT=$GEM_BASE/bundler/gems/sufia-2d439b3100dd

DIFF_FILE=/tmp/diff-list.$$
rm -fr $DIFF_FILE > /dev/null 2>&1

CMD_FILE=/tmp/diff-cmd.$$
rm -fr $CMD_FILE > /dev/null 2>&1

find $ROOT_DIR -type f > $DIFF_FILE

echo "Using sufia: $SUFIA_ROOT"
echo "Ensure this is current..."
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
         echo "$DIFF_TOOL $location/$part $file" >> $CMD_FILE
      fi

   else
      echo "ERROR: cannot locate source for customized element $file"
   fi

done

lines=$(wc -l $CMD_FILE| awk '{print $1}')
if [ $lines -ne 0 ]; then
   echo "Created diff command file with $lines entries"
   echo $CMD_FILE
else
   echo "No diffs identified"
   rm -fr $CMD_FILE > /dev/null 2>&1
fi

rm -fr $DIFF_FILE > /dev/null 2>&1

