#
# wait for a version response that reports the expected (supplied) version
#

#set -x

# validate input paremeters
if [ $# -ne 3 ]; then
   echo "use: $(basename $0) <endpoint> <expected version> <timeout (in seconds)>"
   exit 1
fi

# for clarity
ENDPOINT=$1
shift
EXPECTED_VERSION=$1
shift
TIMEOUT=$1

# verify curl is available
CURL_TOOL=curl
which $CURL_TOOL > /dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "ERROR: $CURL_TOOL is not available in this environment"
   exit 1
fi

# verify awk is available
AWK_TOOL=awk
which $AWK_TOOL > /dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "ERROR: $AWK_TOOL is not available in this environment"
   exit 1
fi

# calculate start and end times
START_TIME=$(date +%s)
END_TIME=$(expr $START_TIME + $TIMEOUT)

# loop until timeout
while true; do

   VERSION=$($CURL_TOOL $ENDPOINT/version 2>/dev/null | $AWK_TOOL -F\" '{print $4}')

   # if we did not get a version, tag as unknown
   if [ -z "$VERSION" ]; then
      VERSION="unknown"
   fi

   # did we get the right version
   if [ "$VERSION" = "$EXPECTED_VERSION" ]; then
      echo "Reported version: $VERSION, done waiting"
      exit 0
   fi

   echo "Reported version: $VERSION, waiting for: $EXPECTED_VERSION"

   # check for timeout
   NOW_TIME=$(date +%s)
   if [ $NOW_TIME -ge $END_TIME ]; then
      echo "ERROR: timed out waiting for correct version to be reportd"
      exit 1
   fi

   sleep 5
done

# never get here

#
# end of file
#
