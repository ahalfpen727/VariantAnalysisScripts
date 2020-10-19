#!bin/bash
# How to redirect both stdout and stderr to a file
# The syntax is as follows to redirect both stdout and stderr to a file:
command 2>&1 | tee output.txt

# For example:
find . -iname "*.txt" 2>&1 | tee cmd.log
cat cmd.log
# To append text to end of file use the following syntx:
find . -iname "*.conf" 2>&1 | tee -a cmd.log

# How to combine redirections
# The following command example simply combines input and output redirection. The file resume.txt is checked for spelling mistakes, and the output is redirected to an error log file named err.log:

spell < resume.txt > error.log
