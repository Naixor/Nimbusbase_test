
baseUrl =  "http://www.google-analytics.com/collect?v=1&tid=UA-46950334-1&cid=001"

Nimbus.track.google = 
	data : {
		page_url:""
		app_name:""
		cloudType:""
		email:""
	}
	send_page_tracking : (url)->
		path = baseUrl + "&t=pageview&dp=" + encodeURI(url)
		xhr = new XMLHttpRequest()
		xhr.open("GET",path,true)
		xhr.send(null)
		return


	send_event_tracking : (dom=0, action=0, id=0, value=0)->
		path =  baseUrl + "&t=event&ec=" + encodeURI(dom) + "&ea=" + encodeURI(action)   + "&ev=" + encodeURI(value) + "&el=" + encodeURI(id) 
		xhr =  new XMLHttpRequest()
		xhr.open("GET", path, true)
		xhr.send(null)



	registered_user : ()->
		#send the  page  url
		@data["page_url"]= window.location.href
		@data["app_name"]= Nimbus.Auth.app_name
		@data["cloudType"]= Nimbus.Auth.service


		@send_page_tracking(@data.page_url)

		setTimeout(()->
			count  = 0;
			for i  of  Nimbus.dictModel 
				len = Nimbus.dictModel[i].all().length
				count = count + len
			Nimbus.track.google.data["sum"] = count
			data = Nimbus.track.google.data
			log( "send to gogole analytic :" , data)

			Nimbus.track.google.send_event_tracking(data.app_name,data.email, data.cloudType,data.sum)
			return
		,15000)

		if Nimbus.Auth.service is "Dropbox"
	      Nimbus.Client.Dropbox.getAccountInfo (info)-> 
	        Nimbus.track.google.data["email"] = info.email if info.email?
	        #log( "send to gogole analytic :" + "APP:" + app_name + " user: " + email + " cloud:" +  cloudType)
	        #Nimbus.track.google.send_event_tracking(email,app_name,cloudType)
	        
	    if Nimbus.Auth.service is "GDrive"
	        Nimbus.track.google.data["email"] = Nimbus.Client.GDrive.get_user_email()
	        # Nimbus.track.google.send_event_tracking(email,app_name,cloudType)
	      # Nimbus.Client.GDrive.get_current_user (info)->
	      #   n = info.name 
	      #   Nimbus.track.send_people_request(x)


window.onerror =(msg, url,line)->
	
	# email = Nimbus.track.google.data.email if  Nimbus.track.google.data.email?
	# app_name = Nimbus.track.google.data.app_name if Nimbus.track.google.data.app_name?
	# cloudType = Nimbus.track.google.data.cloudType if Nimbus.track.google.data.cloudType?
	# if  line is  undefined
	# 	line = ""
	error = 
		email :  Nimbus.track.google.data.email
		app_name : Nimbus.track.google.data.app_name
		cloudType : Nimbus.track.google.data.cloudType
		line_ : line
		url_ : url
		msg_ : msg
	
	info = JSON.stringify(error)
	info = info.replace(/"/g,"").replace(/{/g,"").replace(/}/g,"")
	info = encodeURI(info)
	info =  info.replace(/%20/g, "_").replace(/#/g, "_")
	log("got error, send to  google analytic:", encodeURI(info) )
	Nimbus.track.google.send_event_tracking(error.app_name, "error", encodeURI(info), 400)
	