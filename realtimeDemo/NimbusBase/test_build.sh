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
    app/nimbusbase.coffee \
    app/set.coffee \
    app/async_counter.coffee \
    app/Nimbus.model.general_sync.coffee \
    app/Nimbus.model.local.coffee \
    adaptors/Nimble.Model.Dropbox.coffee \
    adaptors/Nimbus.Auth.Dropbox_auth.coffee \
    Client/Nimbus.Client.Dropbox.coffee \
    Client/Nimbus.Binary.Dropbox.coffee \
    Client/Nimbus.Client.GDrive.coffee \
    Client/Nimbus.Binary.GDrive.coffee \
    adaptors/Nimbus.Model.GDrive.coffee \
    adaptors/Nimbus.Auth.GDrive.coffee \
    adaptors/Nimbus.Auth.GDrive_oauth2.coffee \
    adaptors/Nimbus.Auth.Multi.coffee \
    app/initialize.coffee \
    framework_adaptors/backbone_adp.coffee \
    framework_adaptors/angular_adp.coffee \
    analytics/base64.coffee \
    analytics/tracking.mixpanel.coffee

echo "Compressing..."
uglifyjs -o allcomp.js all.js

# combine files
cp allcomp.js $JS_OUTPUT
cp $JS_OUTPUT template/js/lib/$JS_OUTPUT

echo "Done"
exit $SUCCESS
