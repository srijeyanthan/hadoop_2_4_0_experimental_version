#!/bin/bash

deleted_files=`cat deleted_files.txt`
echo "Deleting following files:"
for f in ${deleted_files}
do
echo "$f"
git rm deleted_files
done
echo ""
echo ""
git commit -m "Automatic removal of files from HDFS that are deleted in Hop"
echo ""
echo "Finished."
exit 0
