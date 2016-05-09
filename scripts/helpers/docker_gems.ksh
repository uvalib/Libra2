awk '{printf "%s:%s\n", $2, $3}'|sort|awk '{printf "%s \\\n", $1}'
