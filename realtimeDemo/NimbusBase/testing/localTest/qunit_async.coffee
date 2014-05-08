module("Local")
test("check the data model inherited correctly", ()->
  QUnit.equal( Entry.classname, "Nimbus.Model.Local", "The class inherited correctly")
) 

asyncTest("check the data is being saved to localstorage", ()->
  Entry.destroyAll()
  a = Entry.create({ "text":"one two three" })
  
  ok(window._indexdb?, "indexDb creation passed")
  console.log(a.id)
  
  #wait till it's created in the database
  setTimeout(()->
    window._indexdb.get((a.id), (e, r) ->
      console.log(r)
      data = JSON.parse(r.data)
      ok(data.text is "one two three", "data retrieval from indexDb is right")
      
      start()
    )
  , 1000)
)