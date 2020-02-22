#!/bin/bash


set -x


declare -a names=("retrofit" "validator")

TRUNK="trunk"
TARGET="target"
COUNT="/home/vmasarik/git/exReplic/count.py"
ADDEX="/home/vmasarik/git/exReplic/addEkstazi.py"
TIME=""
LOG=""
LOGPATH="/home/vmasarik/git/log.txt"

# measures testing time
timeTest() {
	TIME="$((/usr/bin/time -f %e mvn test > /dev/null) 2>&1)" # trash the stdOUT, catch the error, and send that to TIME
}



# executes counting script
count() {
	python3 "$COUNT" "$1" $(pwd) "$TIME" "$2"
}

# In case there are multiple sub projects, it counts them all
countSubProjects() {
	for i in $(ls -d */)
	do
		pushd ${i%%/} # access $i and cut out the last '/'
		if [[ -d "$TARGET" ]]; then
    		count ${i%%/} "$1"
		fi
    	popd
	done

}

startSavingDependencies() {
	mv "$HOME/.ekstazirc.old" "$HOME/.ekstazirc" 
}

stopSavingDependencies() {
	mv "$HOME/.ekstazirc" "$HOME/.ekstazirc.old" 
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
	    pushd "trunk"
	else #Case for GIT
		LOG=$(git status)
	fi


	# Download deps and create "target directories"
	mvn test-compile > /dev/null


	if [[ "$?" -ne 0 ]] ; then
		echo $LOG >> $LOGPATH
		echo "failed to Compile!  SKIPPING project and LOGGING"
		continue
	fi

	testAndCount "$project" "baseTime"




	# Case for SVN
	if [[ -d "$TRUNK" ]]; then 
	    popd # TRUNK
	fi





# NOW WITH EKSTAZI 
	if [[ -d "$TRUNK" ]]; then
	    svn info
	    pushd "trunk"

	    python3 "$ADDEX"
		
		mvn test-compile > /dev/null # Download deps and create "target directories"
 
	    testAndCount "$project" "ekstaziAE" # Run AE


	    startSavingDependencies

		
		mvn test-compile > /dev/null # create "target directories"

	    testAndCount "$project" "ekstaziAEC" # Run AEC

	    stopSavingDependencies

	   	mvn ekstazi:clean # quite probably delete this because it will interfier with further testing by deleting the dependencies


		popd # TRUNK

	    
	    # svn update -r PREV
	    svn info

	else
		git status

	    python3 "$ADDEX"
	    
		mvn test-compile > /dev/null # Download deps and create "target directories"
 
	    testAndCount "$project" "ekstaziAE" # Run AE


	    startSavingDependencies

		
		mvn test-compile > /dev/null # create "target directories"

	    testAndCount "$project" "ekstaziAEC" # Run AEC

	    stopSavingDependencies

	   	mvn ekstazi:clean # quite probably delete this because it will interfier with further testing by deleting the dependencies

	    # git checkout HEAD~
	    git status

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