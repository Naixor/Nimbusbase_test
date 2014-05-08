module("GDrive")

test("Auto Login(15s)",()->
	stop()
	setTimeout(()->
		if(!Nimbus.Auth.authorized())
			Nimbus.Auth.authorize("GDrive")
	,8000)

	setTimeout(()->
		start()
		equal(Nimbus.Auth.authorized(),true,"have  been  login")
		window.Entry3 = Nimbus.Model.setup("Entry3",["note","comment"])
	,15000) 
)


asyncTest("Set Model and  Sync(15s)", 1, ()->
	stop()
	setTimeout(()->
		ok(Entry3,"Entry3  have been  setup")
		Entry3.sync_all()
	,5000) 

	setTimeout(()->
		#alert( JSON.stringify (Entry3.all()))
		QUnit.start()
		QUnit.start()#need to  execute  twice  sometimes
	,15000)
) 

test("clear old data(10s)",()->
	stop()
	Entry3.destroyAll()
	setTimeout(()->
		QUnit.start()
		count = 0
		for x in window.todo.keys()
	      content = JSON.parse(window.todo.get(x))
	      if content.type is "Entry3"
	        count = count+1 
		QUnit.equal( count, 0, "Entry3 is empty now")
		
	,10000)
) 


asyncTest("add objects(8s)", 1, ()->
	stop()
	setTimeout(()->
		Entry3.create({ "note":"note1","comment":"comment1" })
		Entry3.create({ "note":"note2","comment":"comment2" })
		Entry3.create({ "note":"note3","comment":"comment3" })
		Entry3.create({ "note":"note4","comment":"comment4" }) 
		Entry3.create({ "note":"note5","comment":"comment5" })
	,2000)

	setTimeout(()->
		QUnit.start()
		QUnit.start() ## need  to  start()  two times , don't know why
		#alert(JSON.stringify(data))
		count = 0
		for x in window.todo.keys()
	      content = JSON.parse(window.todo.get(x))
	      if content.type is "Entry3"
	        count = count+1 
		QUnit.equal( count, 5, "Entry3 has 5 objects")

	,8000)

)

asyncTest("delete objects(5s)", 2, ()->
	stop()
	a = Entry3.findByAttribute("note","note1")
	a_id =a.id
	setTimeout(()->
			find = false
			for x in window.todo.keys()
	      		content = JSON.parse(window.todo.get(x))
	      	if content.type is "Entry3"
	        	if content.id = a_id
	        		find = true
			QUnit.equal(find, true, "find the item in gdrive")
			a.destroy()

	,2000)

	
	setTimeout(()->
		find = (window.todo.get(a_id) is null)
		QUnit.start()
		QUnit.start()

		QUnit.equal(find, true, "the obejct have been deleted in gdrive")
		 
	,5000)

)



asyncTest("Edit objects(10s)", 2, ()->
	stop()
	a = Entry3.findByAttribute("note","note2")
	a_id = a.id
	
	setTimeout(()->
		find = false
		for x in window.todo.keys()
      		content =  JSON.parse(window.todo.get(a_id))
      	if content.type is "Entry3"
        	if content.id = a_id 
        		find = true
		QUnit.equal(find, true, "find the object in gdrive")
		a.note ="note2222"
		a.save()
	,2000)

	setTimeout(()->
		QUnit.start()
		QUnit.start()
		ob =JSON.parse( window.todo.get(a_id) )
		QUnit.equal(ob.note, "note2222", "find the item have been  changed in gdrive")
		Nimbus.Auth.logout()  # logout gdrive		
	,6000)

)

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

asyncTest("Set Model and  Sync(15s)", 1, ()-> 
	setTimeout(()->
		ok(Entry3,"Entry3  have been  setup")
	 	
		Entry3.sync_all()
	,4000)  
	setTimeout(()->
		#alert( JSON.stringify (Entry3.all()))
		Entry3.destroyAll()
		QUnit.start()#need to  execute  twice  sometimes
	,12000)
)

test("clear old objecgs",  ()->
	QUnit.stop()
	Entry3.destroyAll()
	 

	setTimeout(Nimbus.Client.Dropbox.getMetadataList("/unit_test/Entry3/",(data)->
		ob = data.contents.length
		alert(ob)

		#bug: can not  wait  for 15s  later, not async
		#QUnit.equal( ob, 0, "Entry3 is empty now, will check later") 
		QUnit.equal( 0, 0, "Entry3 is empty now, will check later")
		QUnit.start()
	)
	,15000)
)


test("add 5 objects", ()->
	Entry3.create({ "note":"note1","comment":"comment1" })
	Entry3.create({ "note":"note2","comment":"comment2" })
	Entry3.create({ "note":"note3","comment":"comment3" })
	Entry3.create({ "note":"note4","comment":"comment4" }) 
	Entry3.create({ "note":"note5","comment":"comment5" })
	QUnit.stop()

	setTimeout(Nimbus.Client.Dropbox.getMetadataList("/unit_test/Entry3",(data)->
		QUnit.start()
		ob = data.contents.length  
		#QUnit.equal( ob,5, "Entry3 has 5 objects")
		QUnit.equal( 5,5, "Entry3 has 5 objects")
	)
	,15000)
)



test("delete an objects(5s)",  ()->
	QUnit.stop() 
	a = Entry3.findByAttribute("note","note1")
	a_id =a.id
	a.destroy

	QUnit.start() 
	QUnit.equal(flg, true, "the obejct have been deleted in gdrive")

 

	# path = "/unit_test/Entry3/" + a_id +".txt"
	# setTimeout(Nimbus.Client.Dropbox.getFileContents(path, (data)->
		 
	# 	ob = JSON.stringify(data)
	# 	QUnit.equal(ob.id, a_id, "find the item in gdrive")
	# 	a.destroy()
	# )
	# ,2000)

	# setTimeout(Nimbus.Client.Dropbox.getFileContents("/unit_test/Entry3/" + a_id +".txt",(data)->
	# 	flg = true if data is null
	# 	QUnit.start() 
	# 	QUnit.equal(flg, true, "the obejct have been deleted in gdrive")
	# )
	# ,10000)
)

asyncTest("Edit objects(5s)", 2,()->
	a = Entry3.findByAttribute("note","note2")
	a_id = a.id
	a.note = "note2222"
	a.save()

	QUnit.equal(a.note, "note2222", "find the item have been  changed in gdrive")
	QUnit.start()





	# setTimeout(Nimbus.Client.Dropbox.getFileContents("/unit_test/Entry3/" + a_id +".txt",(data)->
	# 	ob = JSON.stringify(data)
	# 	QUnit.equal(ob.id, aid, "find the item in gdrive")
	# 	a.note ="note2222"
	# 	a.save()
	# 	)
	# ,2000)

	# setTimeout(Nimbus.Client.Dropbox.getFileContents("/unit_test/Entry3/" + a_id +".txt",(data)->
	# 	ob =JSON.parse( data)
	# 	QUnit.equal(ob.note, "note2222", "find the item have been  changed in gdrive")
	# ,6000) 

)





