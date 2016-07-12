# *****BEGIN USER-DEFINED LIST SECTION*****
# Add urls and associated names to the array.
## One line per blocklist in the following format
##      ["<blocklist_name>"]="<blocklist_url>"
## as obtained from https://www.iblocklist.com/lists.php using the p2p file format and gz archive format

declare -A blocklists=(
    ["tbgprimarythreats"]="http://list.iblocklist.com/?list=ijfqtofzixtwayqovmxn&fileformat=p2p&archiveformat=gz"
    ["bluetacklevel1"]="http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz"
    ["badpeers"]="http://list.iblocklist.com/?list=bt_templist&fileformat=p2p&archiveformat=gz"
    ["cn"]="http://list.iblocklist.com/?list=cn&fileformat=p2p&archiveformat=gz"
    ["ru"]="http://list.iblocklist.com/?list=ru&fileformat=p2p&archiveformat=gz"
)

# *****END USER-DEFINED LIST SECTION*****
