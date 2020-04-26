#!/bin/bash


set -x

# "validator" "retrofit" "cucumber-jvm" "joda-time" "bval" 
declare -a names=("functor") # did not put more tests in here... that is why the DB is so empty

TRUNK="trunk"
TARGET="target"
SUREFIRE="surefire-reports"
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
# projectName, type of measure
count() {
	python3 "$COUNT" "$1" "$(pwd)" "$TIME" "$2"
}

# In case there are multiple sub projects, it counts them all
# type of measure
countSubProjects() {
	for i in $(ls -d */) # list current directories
	do
		pushd ${i%%/} # access $i and cut out the last '/'
		if [[ -d "$TARGET" ]]; then
			pushd $TARGET
			if [ -d "$SUREFIRE" ]; then
				popd # Target POP
    			count ${i%%/} "$1"
				popd # i%% POP
				continue
			fi
			popd # Target POP
		fi
    	popd # i%% POP
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
# projectName, type of measure
testAndCount() {
		if [ -d "$TARGET" ]; then
			pushd $TARGET
			if [ -d "$SUREFIRE" ]; then
				popd
				mvn clean > /dev/null
				timeTest
				count "$1" "$2"
				mvn clean > /dev/null
				exit 0
			fi
			popd
		fi
		mvn clean > /dev/null
		timeTest
		countSubProjects "$2"
		mvn clean > /dev/null
}


# ASSUMPTIONS
# - all the project are in the 21st revision

for project in "${names[@]}" 
do
	pushd "$project"


	if [[ -d "$TRUNK" ]]; then # Case for SVN
	    LOG=$(svn info)
		declare -a revisions

		for temp in {1..10} # get to last revision ############## RETURN BACK TO 20, I put it to 5 only to try it out faster!
		do	    
			svn update -r PREV
			revisions+=($(svn info --show-item revision))
		done



		echo "# # # # # # # # # Starting to test project $project" >> $LOGPATH

		for (( index=${#revisions[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back because revisions were added incrementally
			pushd "trunk"
		    svn cleanup --remove-unversioned # good god, if I do a revert it somehow does not delete the shitty branches before
			svn revert -R "." # piece of shit svn, I have to revert everything back, before I can get back to the update
		    svn update -r "${revisions[index]}"
			svn cleanup --remove-unversioned # see previous cleanup, so I have to do this twice
			LOG=$(mvn test-compile)


			if [[ "$?" -ne 0 ]] ; then
				echo "$LOG" >> $LOGPATH
				echo "failed to Compile!  SKIPPING project and LOGGING"
				continue
			fi

			testAndCount "$project" "baseTime"




		    # Ekstazi
		    python3 "$ADDEX"
			
		    # stopSavingDependencies

			# mvn test-compile > /dev/null # Download deps and create "target directories"
	 
		    # testAndCount "$project" "ekstaziAE" # Run AE


		    # startSavingDependencies

			
			mvn test-compile > /dev/null # create "target directories"

		    testAndCount "$project" "ekstaziAEC" # Run AEC

		    # stopSavingDependencies

			



			popd # TRUNK

		    
		done




	else #Case for GIT
		LOG=$(git status)

		hashes=($(git log --format=format:%H -n 21)) # print hashes and create an array




		firstCommit=(${hashes[0]}) # create an array from first element



		hashes=($(echo "${hashes[@]/$firstCommit}")) # echo hashes wuthout the first commit, then save it as an array. The first hash is 21st one, so we dont want that 


		echo "# # # # # # # # # Starting to test project $project" >> $LOGPATH

		for (( index=${#hashes[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back

		    git checkout --force "${hashes[index]}"
		    git clean -d -x -f # delete untracted files and folder
			LOG=$(mvn test-compile)


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