awk '{printf "%s:%s\n", $2, $3}'|awk '{printf "%s \\\n", $1}'
