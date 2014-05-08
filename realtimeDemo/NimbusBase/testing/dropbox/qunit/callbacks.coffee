# callbacks for test
window.qunit_test_result = {}
window.qunit_test_count = {}

# log each test
QUnit.log((details)->
  console.log( "Log: ", details.result, details.message )
  item = {}
  item.name = details.name
  item.result = details.result
  item.message = details.message

  window.qunit_test_result[details.module] = window.qunit_test_result[details.module] or []
  window.qunit_test_result[details.module].push(item)
)

# callback for module
QUnit.moduleDone(( details )->
  console.log( "Finished running: ", details.name, "Failed/total: ", details.failed, details.total );
  window.qunit_test_count[details.name] = details
  window.qunit_test_is_done = true
)

# called when done
QUnit.done = (results)->
   console.log('failed: '+results.failed)
   console.log('passed: '+results.passed)
   console.log('total: '+results.total)

   window.qunit_test_is_done = true
