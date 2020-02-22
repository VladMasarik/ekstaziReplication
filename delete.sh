hashes=($(git log --format=format:%H -n 21))




firstCommit=(${hashes[0]})



hashes=($(echo "${hashes[@]/$firstCommit}"))



for (( index=${#hashes[@]}-1 ; index>=0 ; index-- )) ; do
    echo "${hashes[index]}"
done




