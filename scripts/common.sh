#!/bin/sh

if [ "$OS" == "iOS" ]; then
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$1 -sdk $2 -destination name=$3 -configuration DEBUG test
else
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$1 -sdk $2 -configuration DEBUG test
fi