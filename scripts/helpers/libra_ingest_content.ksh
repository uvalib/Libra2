# define ingest types
INGEST_1=4th_year_thesis
INGEST_2=jefferson_trust
INGEST_3=master_thesis
INGEST_4=doctoral_thesis

# prompt the user to select an option
options=($INGEST_1 $INGEST_2 $INGEST_3 $INGEST_4)
PS3='Select ingest directory: '
select opt in "${options[@]}"
do
    case $opt in
        $INGEST_1|$INGEST_2|$INGEST_3|$INGEST_4)
            break
            ;;
        *) echo invalid option;;
    esac
done

# other attributes
INGEST_DIR=tmp/extract

echo "Starting ingest of $opt content..."

# ingest Libra content
rake libraetd:ingest:legacy_content $INGEST_DIR/$opt

exit $?
