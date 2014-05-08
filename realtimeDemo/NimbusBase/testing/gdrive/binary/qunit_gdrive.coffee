
module( "GDrive Binary Test" )
#test if you can create an file
 
test("Auto Login(8s)",()->
    stop()
    Nimbus.Auth.set_app_ready(()->
        equal(Nimbus.Auth.authorized(),true,"have  been  login")
        start()
        return
    )
    return
)

test("Upload binary file(10s)",()->
        stop() 

        setTimeout(()-> 
                finput = document.getElementById("file_upload")  
                window.f1 = finput.files[0];  
                Nimbus.Binary.upload_file(window.f1
                        ,(file)->
                        	window.f2 = file
                ) 
        ,4000) 
        setTimeout(()->
                deepEqual(window.f2.name,f1.name,"have  been  added")
                start()
        ,10000) 
)


test("test add share user (10s)",()->
        stop() 
        window.qunit_get_user =()->
                params = {
                path: "/drive/v2/files/" + window.f2.file_id + "/permissions",
                method: "GET",
                callback:(data)->
                        window.permissionList = JSON.stringify(data); 
                };
                gapi.client.request(params)

       

        setTimeout(()-> 
               Nimbus.Share.add_share_user_real("release@nimbusbase.com",(data)->
                        return window.qunit_get_user() 
                ,window.f2.file_id) 
                #add  user  and  get new permissionList
        ,4000) 
        setTimeout(()->
                notEqual( window.permissionList.indexOf("nimbusbase.com"),-1,"release@nimbusbase.com   get permission")
                start()
        ,10000) 
)


test("delete this binary file(10s)",()->
        stop()  
        setTimeout(()->
                Nimbus.Binary.delete_file(window.f2)
                binary.find(window.f2.id).destroy()
        ,5000) 
        
        setTimeout(()->
                Nimbus.Binary.read_file(window.f2,(data)->
                        window.trashed = data.labels.trashed
                )
        ,9000) 
        setTimeout(()-> 
                deepEqual(window.trashed,true,"have  been  delete")
                Nimbus.Auth.logout()
                start()
        ,12000) 
)


 