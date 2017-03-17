#!/bin/bash

# Shortcomings:
# This script is based on the Synology Download Station V3 API published at
# http://download.synology.com/download/other/Synology_Download_Station_Official_API_V3.pdf
# but does not take some of it's recommendations, specifically that of checking the location
# of APIs from the query. It assumes these APIs are in fixed locations.

# Usage: syno-dl.sh <DownloadLink> <RelativePathForDestination>

# Where should the downloaded file be saved
DEST=$2
# Possible issue if it contains the & character
URI=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/syno-dl-vars.sh

# Verify API with DM
echo -n "Verifying API ... "
RESULT=`wget -qO - "$SYNO/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.DownloadStation.Task" | grep '"success":true'`

if [ "$RESULT" != "" ]
then
 echo "ok"
 # Authenticate to DM
 echo -n "Authenticating to API ... "
 SID=`wget -qO - "$SYNO/webapi/auth.cgi?api=SYNO.API.Auth&version=2&method=login&account=${USER}&passwd=${PASS}&session=DownloadStation&format=sid" | grep 'sid' | awk -F\" '{print $6}'`
 if [ "$SID" != "" ]
 then
 echo "ok"
 # Session ID obtained in SID
 # Start parsing the file list
 # a line has been read in as $line
 # send this to the Syno DM
 echo -n "Sending task to DM: $URI ... "
 RESULT=`wget -qO - --post-data "api=SYNO.DownloadStation.Task&version=1&method=create&uri=$URI&_sid=$SID&destination=$DEST" "$SYNO/webapi/DownloadStation/task.cgi" grep '"success":true'`
 if [ "$RESULT" != "" ]
 then
 echo "ok"
 else
 echo "fail"
 fi
 # Done. Log out (invalidate SID)
 # Note: Since logging out, don't really care to check the response.
 echo -n "Logging out of API ... "
 wget -qO - "$SYNO/webapi/auth.cgi?api=SYNO.API.Auth&version=1&method=logout&session=DownloadStation" > /dev/null
 echo "done."
 else
 echo "fail"
 fi
else
 echo "fail"
fi
