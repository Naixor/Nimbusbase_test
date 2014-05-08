window.debug = true

Nimbus.Auth.setup("GDrive", "424243246254-n6b2v8j4j09723ktif41ln247n75pnts.apps.googleusercontent.com", "https://www.googleapis.com/auth/drive", "unit_test")

Test = Nimbus.Model.setup("test", [ "at1", "at2"])

#window.debug = true
#Nimbus.Auth.setup("Dropbox", "q5yx30gr8mcvq4f", "qy64qphr70lwui5", "unit_test")
#Test = Nimbus.Model.setup("test", [ "at1", "at2"])

exports = this
exports.Test = Test