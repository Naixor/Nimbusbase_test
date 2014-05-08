#setup up auth and an app
Nimbus.Auth.setup("Dropbox", "lejn01o1njs1elo", "2f02rqbnn08u8at", "unit_test")
#if not Nimbus.Auth.authorized()
#  Nimbus.Auth.authorize()

module( "Dropbox Client Test" )
#test if you can create an file
asyncTest "putFileContents", ->
  expect( 2 );

  Nimbus.Client.Dropbox.putFileContents( "/#{ Nimbus.Auth.app_name }"+"/test/test1.txt", "test one two three", (resp)-> 
    log("resp", resp)
    start()
    console.log("putFileContents", resp)
    
    ok not resp.error?, "no error exists"
    ok resp.path is '/unit_test/test/test1.txt', "putFileContents has the correct path"
    
  )  

#get that file  
asyncTest "getFileContents", ->
  expect( 2 );

  Nimbus.Client.Dropbox.getFileContents( "/#{ Nimbus.Auth.app_name }"+"/test/test1.txt", (resp)-> 
    log("resp", resp)
    start()
    console.log("getFileContents", resp)
    
    ok not resp.error?, "no error exists"
    ok resp is "test one two three", "getFileContents correct content"
    
  )  
  
#get metadata for that directory and look for that file
asyncTest "getMetadataList", ->
  expect( 2 );

  #test if you can create an file
  Nimbus.Client.Dropbox.getMetadataList( "/#{ Nimbus.Auth.app_name }"+"/test/", (resp)-> 
    log("resp", resp)
    start()
    console.log("metadata", resp)
    
    window.resp = resp
    console.log("PATH", resp.contents[0].path)
    
    ok not resp.error?, "no error exists"
    ok resp.contents[0].path is "/unit_test/test/test1.txt", "getMetadataList has the correct path"
    
  )  
  
#delete that file
asyncTest "deletePath", ->
  expect( 2 );

  #test if you can create an file
  Nimbus.Client.Dropbox.deletePath( "/#{ Nimbus.Auth.app_name }"+"/test/test1.txt", (resp)-> 
    log("resp", resp)
    start()
    console.log("deletePath", resp)
    
    ok not resp.error?, "no error exists"
    ok resp.path is '/unit_test/test/test1.txt', "putFileContents has the correct path"
  )  
  
#wrte tests for model level stuff, local add delete, and most importantly, sync