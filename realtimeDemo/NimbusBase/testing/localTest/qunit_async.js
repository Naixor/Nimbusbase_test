// Generated by CoffeeScript 1.6.3
module("Local");

test("check the data model inherited correctly", function() {
  return QUnit.equal(Entry.classname, "Nimbus.Model.Local", "The class inherited correctly");
});

asyncTest("check the data is being saved to localstorage", function() {
  var a;
  Entry.destroyAll();
  a = Entry.create({
    "text": "one two three"
  });
  ok(window._indexdb != null, "indexDb creation passed");
  console.log(a.id);
  return setTimeout(function() {
    return window._indexdb.get(a.id, function(e, r) {
      var data;
      console.log(r);
      data = JSON.parse(r.data);
      ok(data.text === "one two three", "data retrieval from indexDb is right");
      return start();
    });
  }, 1000);
});
