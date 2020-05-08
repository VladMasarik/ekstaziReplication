#!/bin/bash

# sed -i -e 's/<ekstazi:select>/<ekstazi:select skipme="true">/' build.xml

set -x
#"functor" "collections" "configuration" "dbcp" "empire-db" "graphhopper" "gs-collections" "io" "jfreechart" "jgit" "lang" "log4j" "net" "pdfbox" "validator" "retrofit" "cucumber-jvm" "joda-time" "bval" "closure-compiler" "jenkins" "org.eclipse.jetty.project.git" "camel" DONE

#   did not test because only core modules need to be tested
# "math" "continuum" "hadoop-common" "guava" problems with building, check it out
declare -a names=( "jtsk" )

TRUNK="trunk"
TARGET="target"
SUREFIRE="surefire-reports"
COUNT="/home/vlad/git/exReplic/count.py"
ADDEX="/home/vlad/git/exReplic/addEkstazi.py"
TIME=""
LOG=""
LOGPATH="/home/vlad/git/log.txt"
EKSTA=0 #if 1 uses ekstazi and puts the output into /home/vlad/git; 0 does not use ekstazi
SUREFIREFOUND=0

# measures testing time
timeTest() {
    if [[ "$EKSTA" -eq 1 ]] ; then
        TIME="$( (/usr/bin/time -f %e mvn test -Dekstazi.parentdir=/home/vlad/git > /dev/null ) 2>&1)"
    else
        TIME="$( (/usr/bin/time -f %e mvn test -Dekstazi.skipme=true > /dev/null ) 2>&1)" # trash the stdOUT, catch the error, and send that to TIME
    fi
}



# executes counting script
# projectName, type of measure
count() {
    python3 "$COUNT" "$1" "$(pwd)" "$TIME" "$2" # 1 = project name; 2 = base or Ekstazi label
}

# In case there are multiple sub projects, it counts them all
# type of measure
countSubProjects() {
    SUREFIREFOUND=0
    for i in $(ls -d */) # list current directories
    do
        pushd ${i%%/} # access $i and cut out the last '/'
        if [[ -d "$TARGET" ]]; then
            pushd $TARGET
            pwd
            ls
            if [ -d "$SUREFIRE" ]; then
                popd # Target POP
                pwd
                ls
                echo "Surefire found!"
                count "$1-sub-${i%%/}" "$2"
                SUREFIREFOUND=1
                popd # i%% POP
                continue
            fi
            popd # Target POP
        fi
        popd # i%% POP
    done
    
    if [[ "$SUREFIREFOUND" -eq 0 ]] ; then
        echo "SUREFIRE NOT FOUND!"
        echo "SUREFIRE NOT FOUND!"
        echo "SUREFIRE NOT FOUND!"
        count "$1-surefireNotFound" "$2"

    fi


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
    # mvn clean > /dev/null
    ant all.clean > /dev/null
    
    # timeTest

    if [[ "$EKSTA" -eq 1 ]] ; then
        mv /home/vlad/git/.ekstazi .
        TIME="$( (/usr/bin/time -f %e ant test > /dev/null ) 2>&1)"
        mv .ekstazi /home/vlad/git
    else
        sed -i -e 's/skipme="false"/skipme="true">/' build.xml
        TIME="$( (/usr/bin/time -f %e ant test > /dev/null ) 2>&1)" # trash the stdOUT, catch the error, and send that to TIME
        sed -i -e 's/skipme="true"/skipme="false">/' build.xml
    fi


    if [ -d "test" ]; then
        pushd "test"
        if [ -d "results" ]; then
            popd
            count "$1" "$2"
        else
            echo "RESULTS NOT FOUND!!!"
            echo "RESULTS NOT FOUND!!!"
            echo "RESULTS NOT FOUND!!!"
            echo "RESULTS NOT FOUND!!!"
            popd
            count "$1-surefireNotFound" "$2"
        fi
    fi
    ant all.clean > /dev/null
}

tryCompilingProject() {

    LOG=$(mvn test-compile) #first to see if it compiles
    if [[ "$?" -ne 0 ]] ; then
        echo "$LOG" >> $LOGPATH
        echo "failed to Compile!  SKIPPING project and LOGGING"
        return 1
    fi
    return 0
}

generateTragetAndSurefireReports() {
    # then to find the surefire reports, at this point if think scraping out would be better
    # make sure ekstazi is not executed
    mvn test -Dekstazi.skipme=true > /dev/null # create "target directories"

}

applyEkstazi() {

    python3 "$ADDEX"
    for fol in $(ls -d */) # list current directories
    do
        pushd ${fol%%/} # access $i and cut out the last '/'
        if [[ -e "pom.xml" ]] ; then
            python3 "$ADDEX"
        fi
        popd
    done
}

# ASSUMPTIONS
# - all the project are in the 21st revision

for project in "${names[@]}" 
do
    pushd "$project"


    if [[ -d "$TRUNK" ]]; then # Case for SVN
        LOG=$(svn info)
        declare -a revisions
        revisions=()

        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$
        # REPLACE TO 20 #$#$#$#$#$#$#$#$#$#$#$

        for temp in {1..5} # get to last revision  
        do	    
            svn update -r PREV --config-option servers:global:http-timeout=100000
            revisions+=($(svn info --show-item revision))
        done



        echo "# # # # # # # # # Starting to test project $project" >> $LOGPATH
        echo "Possibly number of revisions in the Revision variable"
        echo ${#revisions[@]}

        for (( index=${#revisions[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back because revisions were added incrementally
            pushd $TRUNK
            svn cleanup --remove-unversioned --config-option servers:global:http-timeout=100000 # good god, if I do a revert it somehow does not delete the shitty branches before
            svn revert -R "." --config-option servers:global:http-timeout=100000 # piece of shit svn, I have to revert everything back, before I can get back to the update
            svn update -r "${revisions[index]}" --config-option servers:global:http-timeout=100000
            svn cleanup --remove-unversioned --config-option servers:global:http-timeout=100000 # see previous cleanup, so I have to do this twice
            exit 0
            
            # TMP=tryCompiling
            # if [[ "$TMP" -ne 0 ]] ; then
            #     continue
            # fi

            # generateTragetAndSurefireReports



            testAndCount "$project" "baseTime"




            # Ekstazi
            python3 "$ADDEX" # has to go before the first sed
            sed -i -e 's/<ekstazi:select>/<ekstazi:select skipme="false">/' build.xml
            # applyEkstazi

            # generateTragetAndSurefireReports

            EKSTA=1
            testAndCount "$project" "ekstaziAEC" # Run AEC
            EKSTA=0

            popd # TRUNK

            
        done
        pushd $TRUNK
        # mvn ekstazi:clean -Dekstazi.parentdir=/home/vlad/git MAVEN
        rm -rf /home/vlad/git/.ekstazi # ANT
        popd




    else #Case for GIT
        LOG=$(git status)
        hashes=()

        hashes=($(git log --format=format:%H -n 21)) # print hashes and create an array
        firstCommit=(${hashes[0]}) # create an array from first element

        hashes=($(echo "${hashes[@]/$firstCommit}")) # echo hashes wuthout the first commit, then save it as an array. The first hash is 21st one, so we dont want that 


        echo "# # # # # # # # # Starting to test project $project" >> $LOGPATH

        for (( index=${#hashes[@]}-1 ; index>=0 ; index-- )) ; do # loop an array from back

            git checkout --force "${hashes[index]}"
            git clean -d -x -f # delete untracted files and folder

            TMP=tryCompiling
            if [[ "$TMP" -ne 0 ]] ; then
                continue
            fi
            # generateTragetAndSurefireReports




            testAndCount "$project" "baseTime"



            # Ekstazi
            git status

            applyEkstazi
            
            # generateTragetAndSurefireReports

            EKSTA=1
            testAndCount "$project" "ekstaziAEC" # Run AEC
            EKSTA=0
            git status
        done
        mvn ekstazi:clean -Dekstazi.parentdir=/home/vlad/git

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