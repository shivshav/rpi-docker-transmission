#!/bin/bash
##
## Update transmission-daemon's blocklist 1/day
##
# Set default variable values.
TRANSMISSION_USER=debian-transmission
TRANSMISSION_GROUP=debian-transmission
TRANSMISSION_HOME=/etc/transmission-daemon

# Replace with configured files if applicable.
[ -f /etc/sysconfig/transmission ] && . /etc/sysconfig/transmission

# Validate configuration path.
if [ ! -d "${TRANSMISSION_HOME}/blocklists" ]; then
    echo "Directory ${TRANSMISSION_HOME}/blocklists does not exist!"
    exit 1
fi

# Validate user account.
id $TRANSMISSION_USER >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "There does not appear to be a user named '$TRANSMISSION_USER'!"
    exit 1
fi

declare -a urls list

# *****BEGIN USER-DEFINED LIST SECTION*****
# Add indexed download urls into the urls[] array.
# Add associated name into the lists[] array at the same index.

list[0]="tbgprimarythreats"
urls[0]="http://list.iblocklist.com/?list=ijfqtofzixtwayqovmxn&fileformat=p2p&archiveformat=gz"

list[1]="bluetacklevel1"
urls[1]="http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz"

list[2]="badpeers"
urls[2]="http://list.iblocklist.com/?list=bt_templist&fileformat=p2p&archiveformat=gz"

list[3]="cn"
urls[3]="http://list.iblocklist.com/?list=cn&fileformat=p2p&archiveformat=gz"

list[4]="ru"
urls[4]="http://list.iblocklist.com/?list=ru&fileformat=p2p&archiveformat=gz"

# *****END USER-DEFINED LIST SECTION*****

declare -i ix=0 sz=${#urls[@]} flag=0
# Make sure we actually defined something.
if [ $sz -lt 1 ]; then
    echo "There are no blocklist url's defined!"
    echo "Hello!"
    exit 2
fi
# Make sure both arrays have same # of indices
if [ $sz -ne ${#list[@]} ]; then
    echo "Index size mismatch between 'list' and 'url' arrays!"
    exit 3
fi

# Move into blocklists dir.
builtin cd "${TRANSMISSION_HOME}/blocklists"
# Purge all old/stale/existing blocklists
rm -f ./*

echo "Updating Blocklists..."

# Traverse url[] array and download lists to list[] name.
for ((; ix < sz; ix++ )); do
  wget -q "${urls[$ix]}" -O "${list[$ix]}.gz"
  if [ $? -ne 0 ]; then
    echo "Error retrieving '${list[$ix]}' blocklist!"
    rm -f "${list[$ix]}.gz"
    continue
  else 
    echo "'${list[$ix]}' blocklist archive downloaded"
  fi

  # Make sure we can unzip the file.
  gunzip "${list[$ix]}.gz" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    (( flag++ ))
    echo ".... Blocklist ${list[$ix]} updated."
  else
    rm -f "${list[$ix]}.gz"
    echo ".... Blocklist ${list[$ix]} NOT updated!"
  fi
done

echo "Done Updating!"

# Don't continue unless we had some success.
[ $flag -eq 0 ] && exit 5

# Make sure files have proper ownership.
#chown $TRANSMISSION_USER:$TRANSMISSION_GROUP ./*

# If the daemon is running, send SIGHUP to enable blocklist reload
declare -i pid=$(pidof -s transmission-daemon)
[ $pid -gt 0 ] && kill -s 1 $pid

exit 0
