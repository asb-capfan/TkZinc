#!/bin/sh
 
TEST="test items widget itemconf"

# execution
#pour Unix stantard
export LD_LIBRARY_PATH=../../../v0.1/lib:$LD_LIBRARY_PATH
#pour MacOS X
export DYLD_LIBRARY_PATH=../../../v0.1/lib:$DYLD_LIBRARY_PATH
 
if ( make 1>&2 )
then
   for test in $TEST
   do
      ./$test
   done
fi
