killall python
echo '############################################'
echo 'start binary server fot gdrive'
echo '############################################'

cd testing/gdrive/qunit

echo 'Start gdrive server in binary'
python -m SimpleHTTPServer &
cd ../../..
# start test script suit
node tasks/selenium_gdrive.js 
read -p "Press any key to continue... " -n1 -s

# kill server
killall python


cd testing/gdrive/binary
echo 'Start gdrive server in binary'
python -m SimpleHTTPServer &
cd ../../..
# start test script suit
node tasks/selenium_gdrive_binary.js 

read -p "Press any key to continue... " -n1 -s

# kill server
killall python

echo '############################################'
echo 'start qunit server fot dropbox'
echo '############################################'

cd testing/dropbox/qunit

echo 'Start dropbox server in qunit'
python -m SimpleHTTPServer &
cd ../../..
# start test script suit
node tasks/selenium.js 

read -p "Press any key to continue... " -n1 -s

# kill server
killall python

echo '############################################'
echo 'start binary server fot dropbox'
echo '############################################'

cd testing/dropbox/binary

echo 'Start dropbox server in binary'
python -m SimpleHTTPServer &
cd ../../..
# start test script suit
node tasks/selenium_dropbox.js 

read -p "Press any key to continue... " -n1 -s

# kill server
killall python

echo '############################################'
echo 'start localTest server'
echo '############################################'

cd testing/localTest

echo 'Start dropbox server in binary'
python -m SimpleHTTPServer &
cd ../..
# start test script suit
node tasks/selenium_dropbox.js 

read -p "Press any key to continue... " -n1 -s

# kill server
killall python
