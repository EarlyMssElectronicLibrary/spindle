#!/bin/sh

count=1
for x 
do
  echo "`printf "%2d" $count` `date +%FT%T%z` $x"
  new_name=`echo $x | sed 's!tif$!jpg!'`
  convert $x -colorspace LAB -quality 95% -colorspace RGB /Volumes/EIT_MARGE/color_jpgs/$new_name
  count=$(( $count + 1 ))
done
