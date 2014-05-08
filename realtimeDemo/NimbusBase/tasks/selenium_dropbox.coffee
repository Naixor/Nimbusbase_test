webdriver = require('selenium-webdriver');

driver = new webdriver.Builder().withCapabilities(webdriver.Capabilities.chrome()).build()

driver.get('http://localhost:8000');
driver.findElement(webdriver.By.name('Button2')).click()

timeout = (ms)->
	d = webdriver.promise.defer();
	start = Date.now();
	setTimeout(()->
		d.fulfill(Date.now() - start)
	,ms)
	return d.promise;

printElapsed = (ms)->
	console.log('time: ' + ms + ' ms')

timeout(5000).then(()->
	# driver.findElement(webdriver.By.name('Button2')).click()
	console.log('click button')
)

timeout(20000).then(printElapsed)
timeout(25000).then((time)->
	printElapsed(time)
	driver.getTitle().then((title)->
		console.log title
		driver.findElement(webdriver.By.id("login_email")).sendKeys("release@nimbusbase.com")
		driver.findElement(webdriver.By.id("login_password")).sendKeys("freethecloud2013")
	).then(()->
		driver.findElement(webdriver.By.id("login_submit")).click().then(()->
			console.log 'submited'

			# grant access
			driver.findElement(webdriver.By.name("allow_access")).click()
		)
	).then(()->
		driver.findElement(webdriver.By.id("file_upload")).sendKeys("/Users/Shared/nimbusbase_big.png")
	)
)


# driver.quit();
