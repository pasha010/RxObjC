#!/bin/sh

if [ "$OS" == "iOS" ]; then
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$OS -sdk $SDK -destination name=$NAME -configuration DEBUG test
else
  xctool -workspace RxObjc.xcworkspace -scheme AllTests-$OS -sdk $SDK -configuration DEBUG test
fi