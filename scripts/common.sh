#!/bin/sh

R_OS=$1
R_SDK=$2
R_NAME=$3
R_OS_VER=$4

if [ R_OS == "iOS" ]; then
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$R_OS -sdk $R_SDK -destination platform='iOS Simulator, OS=$R_OS_VER,name=$R_NAME' -configuration DEBUG test GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES
else
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$R_OS -sdk $R_SDK -configuration DEBUG test GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES
fi