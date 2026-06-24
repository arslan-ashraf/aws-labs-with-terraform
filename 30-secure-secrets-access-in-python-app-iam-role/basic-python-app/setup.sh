#!bin/bash

# the "set" command immediately fails and stops running the commands in 
# a shell script file when errors occur but the type of error which stops 
# the file from running is dependant on the flag given to the "set" command

# with -e immediately exit if any command has a non zero exit code (use $? to see
# exit code of last run command)
# with -u throw an error if any variable is referenced which does not exist
# -o pipeline prevents errors in a pipeline (with "|") from being executed

set -euo pipefail

