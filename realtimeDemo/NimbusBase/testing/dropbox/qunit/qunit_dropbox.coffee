module("Dropbox QUnit")

window.Entry3 = Nimbus.Model.setup("Entry3",["note","comment"])

asyncTest("Auto Login(12s)",()->
	Nimbus.Auth.set_app_ready(()->
		# __utils__.echo(Nimbus.Auth.authorized())

		if(!Nimbus.Auth.authorized())
			Nimbus.Auth.authorize("Dropbox")
			# return
		equal(Nimbus.Auth.authorized(),true,"have  been  login")
		
		Entry3.sync_all(()->
			start()
		)
		return
	)
)
asyncTest("Set Model and  Sync(12s)", 1, ()-> 
	Entry3.sync_all(()->
		ok(Entry3,"Entry3  have been  setup")
		# __utils__.echo('synced: '+JSON.stringify(Entry3.all()))
		start()#need to  execute  twice  sometimes
	)		
)

asyncTest("clear old objects (8s)",  ()->
	Entry3.destroyAll()
	# __utils__.echo('data deleted: '+JSON.stringify(Entry3.all()))
	
	setTimeout(()->
		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			# __utils__.echo("retrieved : "+JSON.stringify(data))
			ob = data.contents.length 
			QUnit.equal( ob, 0, "Entry3 is empty now, will check later")
			start()
		)
	,5000)
)

asyncTest("add 5 objects", ()->
	Entry3.create({ "note":"note1","comment":"comment1" })
	Entry3.create({ "note":"note2","comment":"comment2" })
	Entry3.create({ "note":"note3","comment":"comment3" })
	Entry3.create({ "note":"note4","comment":"comment4" })
	Entry3.create({ "note":"note5","comment":"comment5" })
	
	# __utils__.echo('after added: '+JSON.stringify(Entry3.all()))
	setTimeout(()->
	# 	# __utils__.echo('synced :'+JSON.stringify(Entry3.all()))

		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			# __utils__.echo('data content :'+ JSON.stringify(data.contents))
			
			ob = data.contents.length 
			QUnit.equal( ob, 5, "Entry3 have added 5 objects")
			start()
		)
		return
	,7000)
	return
)


asyncTest("delete an objects(5s)",  ()->
	aa = window.Entry3.findByAttribute("note","note1")
	a_id = aa.id
	 
	path = "/unit_test/Entry3/" + a_id + ".txt"

	testCall2 = ()-> 
		Nimbus.Client.Dropbox.send_request('GET', 'https://api.dropbox.com/1/metadata/sandbox/unit_test/Entry3','',(data)->
			ob = data.contents.length 
			QUnit.equal( ob, 4, "Entry3 is  4 objects  left now")
			# start()
		)
	# stop()
	Nimbus.Client.Dropbox.getFileContents(path, (data)->
		ob = data
		QUnit.equal(ob.id, a_id, "find the item in gdrive")
		aa.destroy()

		# setTimeout(testCall2,5000)
		start()
	)
	return 
)

asyncTest("Edit objects(5s)", 2,()->
	stop()

	aaa = window.Entry3.findByAttribute("note","note2")
	a_id = aaa.id
	path = "/unit_test/Entry3/" + a_id + ".txt"
	
	Nimbus.Client.Dropbox.getFileContents(path, (data)->
		ob = data 
		QUnit.equal(ob.id, a_id, "find the item in dropbox")
		aaa.note ="note2222"
		aaa.save()
		setTimeout(()->
			Nimbus.Client.Dropbox.getFileContents( path, (data)->
				# QUnit.start()
				QUnit.equal(data.note, "note2222", "find the item in gdrive")
				start()
				# Nimbus.Auth.logout()  # logout dropbox
			)
		,4000)
		start()
	)
	return  null 
)

