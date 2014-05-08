echo '############################################'
echo 'start binary server fot gdrive then dropbox'
echo '############################################'

# cd testing/gdrive/qunit

# echo 'Start gdrive server in binary'
# python -m SimpleHTTPServer &
# cd ../../..
# # start test script suit
# node tasks/selenium_gdrive.js 
# # kill server
# # killall python

 
cd testing/gdrive/binary

echo 'Start gdrive server in binary'
python -m SimpleHTTPServer &
cd ../../..
# start test script suit
node tasks/selenium_gdrive_binary.js 
# kill server
# killall python