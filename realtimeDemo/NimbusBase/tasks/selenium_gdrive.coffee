webdriver = require('selenium-webdriver');

driver = new webdriver.Builder().withCapabilities(webdriver.Capabilities.chrome()).build()

driver.get('http://localhost:8000');
driver.findElement(webdriver.By.name('Button1')).click()

# wait for login 
driver.wait(()-> 
	driver.getTitle().then((title)->
		console.log(title) 
		#assertEquals('Sign in - Google Accounts', driver.getTitle()); 
		driver.findElement(webdriver.By.name("Email")).sendKeys("release@nimbusbase.com")
		driver.findElement(webdriver.By.name("Passwd")).sendKeys("freethecloud2013")
		driver.findElement(webdriver.By.name("signIn")).click().then(()->
			driver.wait(()->
				driver.findElement(webdriver.By.id("submit_approve_access")).click()
			,10000).then(
				driver.wait(()->
					driver.findElement(webdriver.By.name('Start')).click()
				,4000)
			)
		)
	)
,10000)
#driver.quit();