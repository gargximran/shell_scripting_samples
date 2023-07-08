while read p; do 
    arrIN=(${p//=/ })
    echo ${arrIN[1]} | gcloud secrets create ${arrIN[0]} --data-file=- --replication-policy="automatic"		
done < "./.env"
