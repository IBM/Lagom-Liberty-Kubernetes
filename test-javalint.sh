#!/bin/bash -e

test_failed(){
    echo -e >&2 "\033[0;31m$1 test failed!\033[0m"
    exit 1
}

test_passed(){
    echo -e "\033[0;32m$1 test passed!\033[0m"
}

if java -jar checkstyle-8.8-all.jar -c sun_check.xml message-hub-liberty-integration-api/src/ && java -jar checkstyle-8.8-all.jar -c sun_check.xml message-hub-liberty-integration-impl/src/ ; then
   test_passed "$0"
else
   test_failed "$0"
fi
