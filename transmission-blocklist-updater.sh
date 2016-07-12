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

# Source the user-defined blocklists file
if [[ -f $TRANSMISSION_HOME/urls.sh ]]; then
    source $TRANSMISSION_HOME/urls.sh
else
    echo "User-defined URL file for blocklists is missing. Please create one at $TRANSMISSION_HOME/urls.sh. Exiting..."
    exit 1
fi

declare -i sz=${#blocklists[@]} flag=0
# Make sure we actually defined something.
if [ $sz -lt 1 ]; then
    echo "There are no blocklist url's defined!"
    exit 2
fi

# Move into blocklists dir.
builtin cd "${TRANSMISSION_HOME}/blocklists"
# Purge all old/stale/existing blocklists
rm -f ./*

echo "Updating Blocklists..."

# Traverse url[] array and download lists to list[] name.
for list_name in "${!blocklists[@]}"; do
  wget -q "${blocklists[$list_name]}" -O "${list_name}.gz"
  if [ $? -ne 0 ]; then
    echo "Error retrieving '${list_name}' blocklist!"
    rm -f "${list_name}.gz"
    continue
  else 
    echo "'${list_name}' blocklist archive downloaded"
  fi

  # Make sure we can unzip the file.
  gunzip "${list_name}.gz" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    (( flag++ ))
    echo ".... Blocklist ${list_name} updated."
  else
    rm -f "${list_name}.gz"
    echo ".... Blocklist ${list_name} NOT updated!"
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
