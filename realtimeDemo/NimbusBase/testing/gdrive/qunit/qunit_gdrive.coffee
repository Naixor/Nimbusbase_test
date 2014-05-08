module("GDrive")
test("Auto Login(15s)",()->
	stop()
	Nimbus.Auth.set_app_ready(()->
		start()
		equal(Nimbus.Auth.authorized(),true,"have  been  login")
	)
	return
)

asyncTest("Set Model and  Sync(15s)", 1, ()->
	window.Entry3 = Nimbus.Model.setup("Entry3",["note","comment"])

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
		QUnit.equal( Entry3.all().length, 0, "Entry3 is empty now")
		
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
		QUnit.equal( Entry3.all().length, 5, "Entry3 has 5 objects")

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
      			continue if !content
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
      		content =  JSON.parse(window.todo.get(x))
      		continue if !content
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

