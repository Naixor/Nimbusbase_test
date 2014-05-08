window.debug = true
 

sync_object = 
  "GDrive":
    "app_id" : "424243246254"
    "key": "424243246254-n6b2v8j4j09723ktif41ln247n75pnts.apps.googleusercontent.com"
    "scope": "https://www.googleapis.com/auth/drive"
    "app_name": "unit_test"
  "Dropbox":
    "key": "q5yx30gr8mcvq4f"
    "secret": "qy64qphr70lwui5"
    "app_name": "unit_test"
  "synchronous": true
  "app_name": "unit_test"

Nimbus.Auth.setup(sync_object)

window.sync_object = sync_object

Nimbus.Auth.set_app_ready ()->
  window.folder_initialize()


#test for the sync
Entry = Nimbus.Model.setup("Entry", ["text", "create_time", "tags"])
window.Entry = Entry

Task = Nimbus.Model.setup("Task", ["text", "done"])
window.Task = Task

window.test_insert = (x) ->
  for x in [1..x]
    a = """<img width="100" height="70" src="http://tctechcrunch2011.files.wordpress.com/2013/08/iphone5-with-tablet.png?w=100&amp;h=70&amp;crop=1" class="attachment-tc-carousel-river-thumb wp-post-image" alt="iphone5 with tablet" style="float: left; margin: 0 10px 7px 0;" /><p><a target="_blank" href="https://www.snapette.com/">Snapette</a>, a fashion app for local designer shopping, has been acquired by the comparison shopping and daily deals website <a target="_blank" href="http://www.pricegrabber.com/">PriceGrabber</a> for an undisclosed sum. This is PriceGrabber&#8217;s first acquisition since it was founded in 1999.</p>
<p>While PriceGrabber is a massive e-commerce aggregate in the same vein as <a target="_blank" href="http://www.pricerunner.co.uk/">PriceRunner</a> and <a target="_blank" href="http://www.getprice.com/">GetPrice</a> and distributes its virtual catalogue to about 400 publisher partners, Snapette has kept its focus relatively small and local since it <a href="http://techcrunch.com/2011/08/16/live-from-500-startups-demo-day-mcclures-second-batch-of-startups-unleashed/">debuted at 500 Startups&#8217; Demo Day</a> in 2011. The app aims to be the Yelp of fashion, a space within the local app scene that remains relatively undisturbed, by partnering directly with brands and retailers to give consumers a view of their local shopping scene.</p>
<p>Snapette, which will continue to operate independently of PriceGrabber, has gained access to a much larger retailer pool than its current 200 affiliates with this deal. PriceGrabber, on the other hand, is becoming more aggressive about its external growth opportunities, President Jeff Goldstein told us.</p>
<p>The field of daily deals and price comparison sites is broad and unvaried; a number of deals sites are just zombie aggregates at this point. It seems that PriceGrabber is hoping to break ahead of the pack by thinking more creatively.</p>
<p>It is Snapette&#8217;s presence in mobile, local shopping, and fashion that made it particularly attractive as an acquisition, Goldstein said. Although PriceGrabber does work with a number of clothing retailers, it has not focused on building out a differentiated user experience for the category, for which PriceGrabber&#8217;s one-size-fits-all approach is not ideal.</p>
<p>&#8220;They have this great distribution with shoppers as well as with retailers,&#8221; Snapette co-founder and CEO Sarah Paiji told us. &#8220;The hope is that we can drive more traffic to our app by leveraging their large audience base. But also we&#8217;re complementary to them in that they&#8217;re still a traditional e-commerce company 100%. All of the revenue today comes from web. We bring nice capabilities in mobile and local.&#8221;</p>
<p>In the coming weeks Snapette will be launching in-app commerce, Paiji said. Although the app was initially fully focused on driving users into stores, she said that people don&#8217;t tend to think about their channels separately: a user just five blocks away from a store would rather buy on mobile if they&#8217;re already in the app. While Snapette has monetized on in-app brand storefronts, commerce will enable them to take a cut on sales, too.</p>
<p>At the same time, that ability to drive consumers into stores — because that&#8217;s really what local is about — is a big part of what Snapette offers PriceGrabber.</p>
<p>&#8220;Local means a lot of things. People being out on mobile devices and doing research while shopping, location based offers, the ability to source local inventory,&#8221; Goldstein said. &#8220;We were really enthusiastic about the opportunity to partner with Snapette because they have a really interesting, and we think unique, platform that connects local retailers to consumers. And that&#8217;s really at the heart of it and what&#8217;s most interesting about them to us. Because we think that is the natural evolution of our business at least on the local side of things, and we see Snapette as giving us a running start into this space.&#8221;</p>
<br />  <a rel="nofollow" href="http://feeds.wordpress.com/1.0/gocomments/tctechcrunch2011.wordpress.com/863904/"></a> <div class="feedflare">
<a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:2mJPEYqXBVI"><img src="http://feeds.feedburner.com/~ff/Techcrunch?d=2mJPEYqXBVI" border="0"></img></a> <a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:7Q72WNTAKBA"><img src="http://feeds.feedburner.com/~ff/Techcrunch?d=7Q72WNTAKBA" border="0"></img></a> <a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:yIl2AUoC8zA"><img src="http://feeds.feedburner.com/~ff/Techcrunch?d=yIl2AUoC8zA" border="0"></img></a> <a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:-BTjWOF_DHI"><img src="http://feeds.feedburner.com/~ff/Techcrunch?i=onpOrnEQTNQ:j8ZiTWk9Gzk:-BTjWOF_DHI" border="0"></img></a> <a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:D7DqB2pKExk"><img src="http://feeds.feedburner.com/~ff/Techcrunch?i=onpOrnEQTNQ:j8ZiTWk9Gzk:D7DqB2pKExk" border="0"></img></a> <a href="http://feeds.feedburner.com/~ff/Techcrunch?a=onpOrnEQTNQ:j8ZiTWk9Gzk:qj6IDK7rITs"><img src="http://feeds.feedburner.com/~ff/Techcrunch?d=qj6IDK7rITs" border="0"></img></a>
</div><img src="http://feeds.feedburner.com/~r/Techcrunch/~4/onpOrnEQTNQ" height="1" width="1"/>"""    
    Task.create({ "text":a, "done":false })