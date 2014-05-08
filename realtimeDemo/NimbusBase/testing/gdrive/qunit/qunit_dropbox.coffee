
module("Dropbox")
asyncTest("Auto Login(12s)",1,()->
	setTimeout(()->
		if(!Nimbus.Auth.authorized())
			Nimbus.Auth.authorize("Dropbox")
	,8000)
	setTimeout(()->
		QUnit.start()
		equal(Nimbus.Auth.authorized(),true,"have  been  login")
		window.Entry3 = Nimbus.Model.setup("Entry3",["note","comment"])
	,9000) 
)

asyncTest("Set Model and  Sync(12s)", 1, ()-> 
	setTimeout(()->
		ok(Entry3,"Entry3  have been  setup")
	 	
		Entry3.sync_all()
	,4000)  
	setTimeout(()->
		#alert( JSON.stringify (Entry3.all()))
		# Entry3.destroyAll()
		QUnit.start()#need to  execute  twice  sometimes
	,12000)
)

test("clear old objecgs (8s)",  ()->
	QUnit.stop()
	Entry3.destroyAll() 

	testCall = ()-> 
		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			ob = data.contents.length 
			QUnit.equal( ob, 0, "Entry3 is empty now, will check later")
			QUnit.start()
		)

	setTimeout(testCall,8000)
)


test("add 5 objects", ()->
	Entry3.create({ "note":"note1","comment":"comment1" })
	Entry3.create({ "note":"note2","comment":"comment2" })
	Entry3.create({ "note":"note3","comment":"comment3" })
	Entry3.create({ "note":"note4","comment":"comment4" }) 
	Entry3.create({ "note":"note5","comment":"comment5" })
	QUnit.stop()

	testCall = ()-> 
		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			ob = data.contents.length 
			QUnit.equal( ob, 5, "Entry3 have added 5 objects")
			QUnit.start()
		)
	setTimeout(testCall,10000)
)



test("delete an objects(5s)",  ()->
	
	aa = window.Entry3.findByAttribute("note","note1")
	a_id = aa.id
	QUnit.stop() 
	 
	path = "/unit_test/Entry3/" + a_id + ".txt"

	testCall = ()->
		Nimbus.Client.Dropbox.getFileContents(path, (data)->
			ob = data
			QUnit.equal(ob.id, a_id, "find the item in gdrive")
			aa.destroy()
		)
	setTimeout(testCall,5000)
 
	testCall2 = ()-> 
		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			ob = data.contents.length 
			QUnit.equal( ob, 4, "Entry3 is  4 objects  left now")
			QUnit.start()
		)
	setTimeout(testCall2,10000)
	return 
)


asyncTest("Edit objects(5s)", 2,()->
	aaa = window.Entry3.findByAttribute("note","note2")
	a_id = aaa.id
	path = "/unit_test/Entry3/" + a_id + ".txt"

	testCall = ()->
		Nimbus.Client.Dropbox.getFileContents(path, (data)->

			ob = data 
			QUnit.equal(ob.id, a_id, "find the item in gdrive")
			aaa.note ="note2222"
			aaa.save()
		)
	setTimeout(testCall,3000)
 

	testCall2 = ()->
		Nimbus.Client.Dropbox.getFileContents( path, (data)->
			QUnit.start()
			QUnit.equal(data.note, "note2222", "find the item in gdrive")
			Nimbus.Auth.logout()  # logout dropbox
		)
	setTimeout(testCall2,8000)
	return  null 

)

