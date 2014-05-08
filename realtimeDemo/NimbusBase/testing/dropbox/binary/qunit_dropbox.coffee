module( "Dropbox Binary Test" )

#test if you can create an file 
asyncTest("Auto Login(12s)",()->
    Nimbus.Auth.set_app_ready(()->
        # __utils__.echo(Nimbus.Auth.authorized())

        if(!Nimbus.Auth.authorized())
            Nimbus.Auth.authorize("Dropbox")
            # return
        equal(Nimbus.Auth.authorized(),true,"have  been  login")
        
        start()
        return
    )
)

asyncTest("Upload binary file(10s)",()->

    finput = document.getElementById("file_upload")  
    window.f1 = finput.files[0];  

    Nimbus.Binary.upload_file(window.f1,(file)->
        window.f2 = file

        Nimbus.Client.Dropbox.getMetadataList("/" + window.f1.name, 
        (data)->
            deepEqual(1,1,"have  been  added") 
            start()
        ,(err)->
            deepEqual(0,1,"have  been  added")
            start()
        )
    )
)

 
test("delete this binary file(10s)",()->
    stop()  
    setTimeout(()->
        Nimbus.Binary.delete_file(window.f2)
        binary.find(window.f2.id).destroy()  
    ,5000)
    
    setTimeout(()-> 
        Nimbus.Client.Dropbox.getMetadataList("/" + window.f1.name, 
        (data)->
            deepEqual(data.is_deleted,true,"have  been  deleted") 
            start()
        ,(err)->
            deepEqual(0,1,"have  been  deleted")
            start()
        )
    ,10000) 
)

 