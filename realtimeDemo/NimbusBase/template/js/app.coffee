window.debug = true
sync_object =
  GDrive:
    key: "477192000959.apps.googleusercontent.com",
    scope: "https://www.googleapis.com/auth/drive"
    app_name: "chopsticks"
  Dropbox:
    key: "q5yx30gr8mcvq4f",
    secret: "qy64qphr70lwui5",
    app_name: "chopsticks"

auth_obj =
  GDrive_auth_button: "GDrive"
  Dropbox_auth_button: "Dropbox"

Nimbus.Auth.setup(sync_object)

# add listener to login button
((auth_obj) ->
  onclick = (name) ->
    ->
      Nimbus.Auth.authorize(name)
      false

  for button_id, auth_name of auth_obj
    document.getElementById(button_id).addEventListener("click",
      onclick(auth_name), false)
)(auth_obj)

# add listener to logout button
document.getElementById("log_out_button").addEventListener("click",
  ->
    Nimbus.Auth.logout()
    document.getElementById("logout_block").classList.add('hidden')
    document.getElementById("login_block").classList.remove('hidden')
  , false
)

set_app_callback = ->
  if Nimbus.Auth.authorized()
    document.getElementById("login_block").classList.add('hidden')
    document.getElementById("logout_block").classList.remove('hidden')

Nimbus.Auth.set_app_ready(set_app_callback)
