---
author: "Wesley Hales"
date: 2017-09-01
layout: blog
title: Browser Automation At Scale - Part 2 
tags: [docker swarm, selenium hub, selenium grid, chrome]
preview: The second in a series of posts on synthetic browser testing with docker swarm and selenium. 
---

In [Part 1](/posts/2017-08-07-Browser-Automation-At-Scale-Part-1/), I reviewed the gory details of the foundation required to run synthetic browser testing at scale.
Now that we have a framework for building out our tests, we can move forward with wrapping
our test runner in a web application so that the metrics we care about can be gathered and viewed through a decent UI.

For this example, I'm going to use the Alexa top 12 news sites and execute a test over each one with the latest Chrome web browser. It will
open the page and grab the resource timing information along with a screenshot as shown here:
![](/images/posts/2017-09-03/site_runner.png)
The [demo web application](https://github.com/wesleyhales/site_runner) that we're about to setup will store the above screenshots and timing information in Postgres. 
The screenshots are base64 and a bit large compression wise, but that issue can be conquered at a later date. For now, all we 
care about is to get things running and to scale our tests into every geography with a datacenter that supports CoreOS.
Let's review the core architecture:
![](/images/posts/2017-09-03/swarm_setup.png)

### Setting up site_runner

If you followed along in [Part 1](/posts/2017-08-07-Browser-Automation-At-Scale-Part-1/), you can use your own Docker Swarm infrastructure to run your tests. For this
article, I'm only going to review the simple web application used to run and manage the tests - [site_runner](https://github.com/wesleyhales/site_runner).
If you haven't already, go ahead and clone the repository. You can run this within your local docker environment or 
on another hosted CoreOS instance.

```
git clone git@github.com:wesleyhales/site_runner.git
```

#### Database Setup
Next, we'll setup a Postgres database. This will be used to store all of our test data and screenshots (in JSON format and queryable).
```
docker run -p 5432:5432 --name siterunner_pg -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

Now we need to login to the database and set things up:
```
docker run -it --rm --link siterunner_pg:postgres postgres psql -h postgres -U postgres
```
This command will run the Postgres client and will ask for a password (mysecretpassword).
After successful login, copy and paste the following and hit enter:
```
CREATE DATABASE SITERUNNER;
\c siterunner;
CREATE EXTENSION citext;
  CREATE TABLE timingdata (
    id serial primary key,
    data jsonb,
    image text,
    email citext unique
  );
```

#### Web Application Setup
The site_runner web application is a custom test runner built to give simple reporting and an API for the tests
 that need to be ran. Open a new terminal window and navigate to the repository you cloned at the beginning of this article and run:
 
 ```
 docker build -t wesleyhales/site_runner .
 docker run -p 3000:3000 --link siterunner_pg:postgres -d wesleyhales/site_runner
 ```

This will start your application at http://localhost:3000. Visit the URL and ensure you see a page with a link and some table headers.
There won't be any data to review yet, which brings us to the next step...

The site_runner demo application
uses /delete to clear the database and /startTest to start the tests (pretty simple, right?). startTest requires a query parameter 
for which region you'd like your tests to be ran.  If you followed along in Part 1, you would use sf1-node as your query paramter argument.
For this article, I've added another node in New York, so an HTTP request to the following will kick off your tests in that region:

* http://localhost:3000/startTest?nodeName=ny3-node 

If everything goes as planned, you will see the following response from hitting that URL:
![](/images/posts/2017-09-03/test_response.png)

Let's also get a tail on our web server logs so you can see the messages as each test runs:
```
docker logs -f [your container ID]
```

When each test finishes (and you refresh the page), you'll see the screenshot and some other simple data about when and where the 
test was ran. 
![](/images/posts/2017-09-03/test_result.png)
If tests aren't running, check the Selenium hub [console page](http://165.227.123.79:4444/grid/console) to see how many requests are currently queued. Or stop being lazy and go setup 
everything in [Part 1](/posts/2017-08-07-Browser-Automation-At-Scale-Part-1/) and manage your own testing infrastructure! ;-)


If you're just following along and don't have time to set all this up, you can view a temporary site_runner report [here](http://165.227.123.79:3000/?account=Alexa%20Top%2012%20News).
Hover over the screenshot to get a zoomed in view and examine any visual defects. 
(It would be cool to get [Resemble.js](https://huddle.github.io/Resemble.js/) integrated to handle image analysis and comparison at some point)

If you'd like to change the test sites, you can do so in [this file](https://github.com/wesleyhales/site_runner/blob/master/model/AllSites.js).
Other things you might want to change are the data that is harvested during each page run. Here, in
[siterunner.js](https://github.com/wesleyhales/site_runner/blob/master/selenium/siterunner.js#L55), you can see where 
I've written a few wait commands that eventually execute JavaScript on the page that is loaded. This allows you
to harvest any required metrics or inspect things to see what is being used on the page.

In Part 3, We'll advance our webdriver script to crawl an entire site, add a few more nodes across the globe and look at a few open source and pay for monitoring tools that
 will give us health visibility into our nodes and testing infrastructure. Part 4 will probably go into adding headless Chrome and Firefox to the mix.

Thanks to Andy Davies for the [ResourceTiming waterfall component](https://github.com/andydavies/waterfall)!
<br/>
<br/>