Nimbus.angularService = ()->
  all_models = {}
  setup = (name, attrs, sync_callback)->
    store = Nimbus.Model.setup(name, attrs)
    store.sync_all(sync_callback)
    all_models['name'] = store
    store

  makeWatcher = (name)->
    ()->
      localStorage[name]

  {
    # Setup model for client to use
    'setup'  : setup,
    # Used to make $scope.$watch method work
    'makeWatcher' : makeWatcher
  }