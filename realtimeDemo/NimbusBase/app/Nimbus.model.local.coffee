Nimbus.Model.Local = 
  
  classname: "Nimbus.Model.Local"
  
  extended: ->
    @sync @proxy(@saveLocal)
    @fetch @proxy(@loadLocal)
  
  saveLocal: (record,method)->
    
    if !window._indexdb and Nimbus.Auth.app_name
      window._indexdb = new PouchDB(Nimbus.Auth.app_name)

    if !window._indexdb
      result = JSON.stringify(this)
      localStorage[@name] = result
      return
    db = window._indexdb
    self = @
    if record
      _data = 
        _id:record.id
        type : this.name
        data :JSON.stringify(record)
      db.get(record.id,(err,res)->
        if (!err)
          db.remove(res,(e,r)->
            return if method is 'destroy'
            db.put(_data)
          )
        else
          db.put(_data)
      )
    else
      for record in this.records
        _data = 
          _id: key
          type : this.name
          data : JSON.stringify(record)
        db.get(key,(err,res)->
          if !err
            _data._rev = res._rev
          db.put(_data)
        )
    return
    
  loadLocal: (callback)->
    if !window._indexdb and Nimbus.Auth.app_name
      window._indexdb = new PouchDB(Nimbus.Auth.app_name)

    if !window._indexdb
      result = localStorage[@name]
      return  unless result
      result = JSON.parse(result)
      @refresh result
      return

    self = @
    db = window._indexdb
    db.allDocs({include_docs: true}, (err, response)->
      if !err
        rows = response.rows
        result = []
        for one in rows
          doc = one.doc
          if doc['type'] is self.name
            result.push(JSON.parse(doc.data))
        self.refresh(result)
        
        callback() if callback?
    )
    return
