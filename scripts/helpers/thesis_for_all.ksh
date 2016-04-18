#
# helper to create a thesis for all users
#

function bomb_if_error {
   if [ "$1" -ne 0 ]; then
      echo "ERROR: $1, aborting"
      exit $1
   fi
}

USER_LIST=/tmp/user_list.$$
rm -fr $USER_LIST > /dev/null 2>&1

# create a list of users
rake libra2:list_all_users > $USER_LIST
res=$?
bomb_if_error $res

for email in $(<$USER_LIST); do

   echo -n "Creating thesis for $email... "
   rake libra2:create_new_thesis $email > /dev/null 2>&1
   #rake libra2:create_new_work $email > /dev/null 2>&1
   res=$?
   bomb_if_error $res
   echo "done"

done

rm -fr $USER_LIST > /dev/null 2>&1
