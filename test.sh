#!/bin/bash


set -x


declare -a names=("validator" "retrofit")

TRUNK="trunk"
TARGET="target"
COUNT="/home/vmasarik/git/exReplic/count.py"
ADDEX="/home/vmasarik/git/exReplic/addEkstazi.py"
TIME=""
LOG=""
LOGPATH="/home/vmasarik/git/log.txt"

# measures testing time
timeTest() {
	TIME="$( (/usr/bin/time -f %e mvn test > /dev/null ) 2>&1)" # trash the stdOUT, catch the error, and send that to TIME
}



# executes counting script
count() {
	python3 "$COUNT" "$1" "$(pwd)" "$TIME" "$2"
}

# In case there are multiple sub projects, it counts them all
countSubProjects() {
	for i in $(ls -d */) # list current directories
	do
		pushd ${i%%/} # access $i and cut out the last '/'
		if [[ -d "$TARGET" ]]; then
    		count ${i%%/} "$1"
		fi
    	popd
	done

}

startSavingDependencies() {
	mv "$HOME/.ekstazirc" "$HOME/.ekstazirc.old" 
}

stopSavingDependencies() {
	mv "$HOME/.ekstazirc.old" "$HOME/.ekstazirc" 
}

# Decide whether to count subprojects
# Also downloads dependencies before testing
# After it is done it cleans up
testAndCount() {
		if [[ -d "$TARGET" ]]; then
    		mvn clean > /dev/null
		    timeTest
		    count "$1" "$2"
		else
    		mvn clean > /dev/null
		    timeTest
		    countSubProjects "$2"
		fi
		mvn clean > /dev/null
}



for project in "${names[@]}" 
do
	pushd "$project"


	if [[ -d "$TRUNK" ]]; then # Case for SVN
	    LOG=$(svn info)
		declare -a revisions

		for temp in {1..20} # get to last revision
		do	    
			svn update -r PREV
			revisions+=($(svn info --show-item revision))
		done




		for (( index=${#revisions[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back
			pushd "trunk"
		    svn update -r "${revisions[index]}"
		    svn cleanup --remove-unversioned
			mvn test-compile > /dev/null


			if [[ "$?" -ne 0 ]] ; then
				echo "$LOG" >> $LOGPATH
				echo "failed to Compile!  SKIPPING project and LOGGING"
				continue
			fi

			testAndCount "$project" "baseTime"




		    # Ekstazi
		    python3 "$ADDEX"
			
		    stopSavingDependencies

			mvn test-compile > /dev/null # Download deps and create "target directories"
	 
		    testAndCount "$project" "ekstaziAE" # Run AE


		    startSavingDependencies

			
			mvn test-compile > /dev/null # create "target directories"

		    testAndCount "$project" "ekstaziAEC" # Run AEC

		    stopSavingDependencies



			popd # TRUNK

		    
		done




	else #Case for GIT
		LOG=$(git status)

		hashes=($(git log --format=format:%H -n 21)) # print hashes




		firstCommit=(${hashes[0]}) # create an array from first element



		hashes=($(echo "${hashes[@]/$firstCommit}")) # echo hashes wuthout the first commit, then save it as an array

		for (( index=${#hashes[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back

		    git checkout --force "${hashes[index]}"
		    git clean -d -x -f # delete untracted files and folder
			mvn test-compile > /dev/null


			if [[ "$?" -ne 0 ]] ; then
				echo "$LOG" >> $LOGPATH
				echo "failed to Compile!  SKIPPING project and LOGGING"
				continue
			fi

			testAndCount "$project" "baseTime"



		    # Ekstazi
			git status

		    python3 "$ADDEX" # add extazi
		    
		    stopSavingDependencies

			mvn test-compile > /dev/null # Download deps and create "target directories"
	 
		    testAndCount "$project" "ekstaziAE" # Run AE


		    startSavingDependencies

			
			mvn test-compile > /dev/null # create "target directories"

		    testAndCount "$project" "ekstaziAEC" # Run AEC

		    stopSavingDependencies


		    # git checkout HEAD~
		    git status
		done

	fi
	
	popd # PROJECT
done








# ## declare an array variable
# declare -a arr=("element1" "element2" "element3")

# ## now loop through the above array
# for i in "${arr[@]}"
# do
#    echo "$i"
#    # or do whatever with individual element of the array
# done