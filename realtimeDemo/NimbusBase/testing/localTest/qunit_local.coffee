module("Local")
test("check the data model inherited correctly", ()->
  QUnit.equal( Entry.classname, "Nimbus.Model.LocalSync", "The class inherited correctly")
) 

test("check the data is being saved to localstorage", ()->
  Entry.destroyAll()
  Entry.create({ "text":"one two three" })
  localstorage_entry = JSON.parse(localStorage["Entry"])
  QUnit.equal( localstorage_entry[0].id, Entry.first().id, "The entry is there in localhost")
  QUnit.equal( localstorage_entry[0].text, Entry.first().text, "The text is equal")
)