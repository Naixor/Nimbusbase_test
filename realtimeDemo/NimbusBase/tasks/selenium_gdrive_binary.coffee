webdriver = require('selenium-webdriver');

driver = new webdriver.Builder().withCapabilities(webdriver.Capabilities.chrome()).build()

driver.get('http://localhost:8000').then(()->
  driver.findElement(webdriver.By.name('Button1')).click().then(()->
    driver.getTitle().then((title)->
      console.log(title)  
      #assertEquals('Sign in - Google Accounts', driver.getTitle()); 
      driver.findElement(webdriver.By.name("Email")).sendKeys("release@nimbusbase.com")
      driver.findElement(webdriver.By.name("Passwd")).sendKeys("freethecloud2013")
      driver.findElement(webdriver.By.name("signIn")).click()
      timeout(7000).then(submit_approve_access);
       
    )

  )

)
 
timeout = (ms)->
  d = webdriver.promise.defer();
  start = Date.now();
  setTimeout(()->
    d.fulfill(Date.now() - start);
  , ms);
  return d.promise;


submit_approve_access= (ms)->
  console.log('time: ' + ms + ' ms');
  driver.findElement(webdriver.By.id("submit_approve_access")).click()
  timeout(5000).then(add_update_file);

add_update_file= (ms)->
  console.log('time: ' + ms + ' ms');
  driver.findElement(webdriver.By.id("file_upload")).sendKeys("/Users/Shared/nimbusbase_big.png")
 

 