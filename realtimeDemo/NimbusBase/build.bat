@echo off
del all.js
del allcomp.js
del nimbus.js

coffee -j all.js --compile app/first.coffee dropboxjs/000-dropbox.coffee dropboxjs/api_error.coffee dropboxjs/base64.coffee dropboxjs/client.coffee dropboxjs/drivers.coffee dropboxjs/hmac.coffee dropboxjs/oauth.coffee dropboxjs/prod.coffee dropboxjs/pulled_changes.coffee dropboxjs/references.coffee dropboxjs/stat.coffee dropboxjs/user_info.coffee dropboxjs/xhr.coffee dropboxjs/zzz-export.coffee app/nimbusbase.coffee app/set.coffee app/async_counter.coffee app/Nimbus.model.general_sync.coffee app/Nimbus.model.local.coffee adaptors/Nimble.Model.Dropbox.coffee adaptors/Nimbus.Auth.Dropbox_auth.coffee Client/Nimbus.Client.Dropbox.coffee Client/Nimbus.Binary.Dropbox.coffee Client/Nimbus.Client.GDrive.coffee Client/Nimbus.Binary.GDrive.coffee  adaptors/Nimbus.Model.GDrive.coffee adaptors/Nimbus.Auth.GDrive.coffee adaptors/Nimbus.Auth.Multi.coffee app/initialize.coffee framework_adaptors/backbone_adp.coffee framework_adaptors/angular_adp.coffee analytics/base64.coffee analytics/tracking.mixpanel.coffee && uglifyjs -o allcomp.js all.js && copy allcomp.js nimbus.js
