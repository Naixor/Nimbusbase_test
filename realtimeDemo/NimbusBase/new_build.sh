#!/bin/bash
# turn off output
set +v

echo "Cleaning old files"
\rm -f all.js
\rm -f allcomp.js
\rm -f nimbus.js

# vars
JS_OUTPUT=nimbus.js
SUCCESS=0

echo "Concatenating JS files"

coffee -j all.js --compile \
    app/first.coffee \
    dropboxjs/000-dropbox.coffee \
    dropboxjs/api_error.coffee \
    dropboxjs/base64.coffee \
    dropboxjs/client.coffee \
    dropboxjs/drivers.coffee \
    dropboxjs/hmac.coffee \
    dropboxjs/oauth.coffee \
    dropboxjs/prod.coffee \
    dropboxjs/pulled_changes.coffee \
    dropboxjs/references.coffee \
    dropboxjs/stat.coffee \
    dropboxjs/user_info.coffee \
    dropboxjs/xhr.coffee \
    dropboxjs/zzz-export.coffee \
    app/nimbusbase.coffee \
    app/set.coffee \
    app/async_counter.coffee \
    app/Nimbus.model.general_sync.coffee \
    app/Nimbus.model.local.coffee \
    app/Nimbus.model.localsync.coffee \
    adaptors/Nimble.Model.Dropbox.coffee \
    adaptors/Nimbus.Auth.Dropbox_auth.coffee \
    realtime/Nimbus.Model.Realtime.coffee \
    Client/Nimbus.Client.Dropbox.coffee \
    Client/Nimbus.Binary.Dropbox.coffee \
    Client/Nimbus.Client.GDrive.coffee \
    Client/Nimbus.Binary.GDrive.coffee \
    adaptors/Nimbus.Model.GDrive.coffee \
    adaptors/Nimbus.Auth.GDrive.coffee \
    adaptors/Nimbus.Auth.Multi.coffee \
    app/initialize.coffee \
    framework_adaptors/backbone_adp.coffee \
    framework_adaptors/angular_adp.coffee \
    analytics/tracking.mixpanel.coffee \
    analytics/tracking.analytics.coffee

echo "Compressing..."
uglifyjs -o allcomp.js all.js

# combine files

cat license.txt >> $JS_OUTPUT
echo "Built on $(date)"
printf "// Built on $(date)" >> $JS_OUTPUT
printf '\n' >> $JS_OUTPUT
cat analytics/base64.js >> $JS_OUTPUT
printf '\n' >> $JS_OUTPUT
cat pouchdb.min.js >> $JS_OUTPUT
printf '\n' >> $JS_OUTPUT
cat allcomp.js >> $JS_OUTPUT


#cp allcomp.js $JS_OUTPUT
cp $JS_OUTPUT template/js/lib/$JS_OUTPUT
cp $JS_OUTPUT testing/localTest/nimbus.js
cp $JS_OUTPUT testing/binary/nimbus.js
cp $JS_OUTPUT testing/gdrive/qunit/nimbus.js
#echo "Done"
exit $SUCCESS
