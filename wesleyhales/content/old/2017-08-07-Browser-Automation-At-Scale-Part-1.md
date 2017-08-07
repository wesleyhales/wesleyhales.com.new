---
author: "Wesley Hales"
date: 2017-08-07
layout: blog
title: Browser Automation At Scale - Part 1 
tags: [docker swarm, selenium hub, selenium grid, chrome]
preview: The post lays the foundation for a globally distributed network of automated browsers. 
previewimage: /images/icons/onslyde.png
---

#### Docker Swarm and Selenium
Both Docker and Selenium are pretty much household names these days in the world of software engineering. I've been fascinated 
with Docker since its inception and have been using it for side projects and in my day job for a few years now.
I recently came across the need to test a Chrome extension and load a web page while that extension is installed. 
This test would load the page, wait for it to load, check some JS variables and APIs and then spit out a screenshot 
and any needed metrics. In the end, each test would run from multiple geographies and produce a report on performance 
and visual defects to be viewed at any point in time.

Here's the End-to-End Architecture:

* Docker Swarm underlying connectivity across all nodes
* Selenium (Grid) network with single centralized hub for test queuing
* Selenium nodes per geography. Dedicated 4GB (minimum) CoreOS instance for Chrome sessions managed by Selenium. 
* Navigation and Resource timing data along with Screenshots stored in linked postgres DB container.
* Centralized web application to manage test reporting and test data storage. 

For this first installment, we're going to setup Selenium Grid on top of Docker Swarm, run a test and get some visibility into the DOM
and how things work. The connectivity and orchestration will be managed by Swarm and Selenium will open the browser 
(Chrome for this example) and run our tests. 
What I'm about to show you, in this and upcoming installments, is extremely powerful and should only be used for good legitimate browser testing
against sites you own or are responsible for ;-)
I'm going to scale everything back to the simplest
setup possible and we'll expand for world domination in later tutorials.


Other (Headless) browsers such as Firefox, PhantomJS and Headless Chrome can be plugged in or substituted at any time. 
All we need to worry about is to make sure the tests are written using the WebDriver API.   

#### Setup Docker Swarm along with the Selenium Grid, Hub and Node
There are four main components to the underlying testing infrastructure, which I quickly summarize below. The good news
is that there are no configuration files to write and everything is used out of box from the official Docker repositories
of each project. The goal of my setup is to be as disposable as possible. Everything is to be reproducible without any
glue code or unnecessary abstraction layers.

##### Quick Component Summary

* For Docker Swarm information, check out [the docs](https://docs.docker.com/engine/swarm/) for the full rundown. It's the underlying 
networking, provisioning, and orchestration layer for docker containers. 
* [Selenium Grid](http://www.seleniumhq.org/docs/07_selenium_grid.jsp) allows you run your tests on different machines against 
different browsers in parallel. A grid consists of a single hub, and one or more nodes, Hub and Node are the two main elements 
that you come across when creating a grid.
* The [Selenium Hub](https://hub.docker.com/r/selenium/hub/) instance will find an available node that matches the criteria we send in with our test parameters. 
Once it finds a machine that matches a browser version you want to run against, the hub reroutes the test to the desired node.
* The [Selenium Node](https://hub.docker.com/r/selenium/node-chrome/) used for this example is Google Chrome.

#### Swarm and Hub - Machine Setup
The first thing you need to do is login to your favorite hosting provider that can provision CoreOS instances. For the hub
I've been using a 1 processor 2GB CoreOS machine. In my testing, I ran into problems with anything less that 2GB of memory for the hub.

SSH into the newly created instance and run the following:
```
docker swarm init --advertise-addr [your external IP]
docker network create -d overlay selenium-grid
docker service create --network selenium-grid --name hub -p 4444:4444 selenium/hub
```
* Here we're initializing Docker Swarm, the Selenium Grid networking layer and the Selenium Hub Service.
* Using this machine's IP address, visit this url (http://[your ip]:4444/grid/console#) to view the Selenium Grid Console. If you cant see it, 
something is wrong. And debugging this setup is a whole other blog post.
* Leave this terminal window open. We'll be back in a sec.
 
### Selenium Node - Machine Setup
Now we'll setup the first Chrome Node that will connect to the Hub. You'll need to create another CoreOS VM, this time with 
a minimum of 2 processors and 4GB of memory. Also, make a note of the hostname of this machine by using the following command. 
The hostname is normally defined within the hosting provider's UI. If not, you can can change it (if needed) once you SSH into the instance:

```
 hostnamectl
```

Now it's time to join this Node to the Swarm. 
The join command was given to you when you executed docker init above. If you lost it,
run ```docker swarm join-token worker``` from the hub instance again and copy and paste it into this Node instance.
```
docker swarm join --token [token] [ip]:[port]
```
That's it for this machine. Everything else will be orchestrated from the hub (until part two of this series 
where I show you how to install a Chrome extension on the fly)

### Selenium Node - Service Deployment
Go back into the main hub instance from the first step. Let's deploy the Selenium Node Docker service. This will start the 
Selenium Chrome client on the Node machine you just setup. Remember everything will be deployed and managed from the hub.
```
docker service create --network selenium-grid --name selenium-node-chrome-sfo --constraint 'node.hostname==sfo1-node-01' -p 5560:5560 --mount type=bind,src=/dev/shm,dst=/dev/shm -e HUB_PORT_4444_TCP_ADDR=hub -e HUB_PORT_4444_TCP_PORT=4444 -e NODE_MAX_INSTANCES=1 -e NODE_MAX_SESSION=1 --replicas 1 selenium/node-chrome bash -c 'SE_OPTS="-browser applicationName=sfo1-node,browserName=chrome,maxInstances=1 -host $HOSTNAME -port 5560" /opt/bin/entry_point.sh'
```
That's a hefty command and you might be wondering what all of the switched and parameters are for. I'll attempt to break it 
 down for you here: 
 
1) ```node.hostname==sfo1-node-01```

* This is the hostname of the actual CoreOS instance. We're using it to constrain the selenium environment to only run on this CoreOS vm. 
This way, we won't have to worry about other tests running in parallel and messing with memory or CPU usage. This is meant to be a pristine,
white glove environment.
* If you're creating an instance for another region, you'll want to replace 'sfo' above with that region's airport or country code.
  
2) ```SE_OPTS=-browser applicationName=sfo1-node```

* This parameter gives our test script a hook so that it will run on this specific SFO node.

3) ```--name selenium-node-chrome-sfo```

* This is just a name to identify this machine within docker. Should be kept in some kind of naming convention order.

4) ```--mount type=bind,src=/dev/shm,dst=/dev/shm```

* This command forces Docker to use the host's memory. When Chrome continually (or randomly) crashed during test runs, this command seemed to solve the issue.
  
5) ``` -e NODE_MAX_INSTANCES=1 -e NODE_MAX_SESSION=1 --replicas 1```

#### The Test Script

To get started, we'll setup some basic logging so we can see the test execute and hopefully use it for debugging purposes later.
<script src="https://gist.github.com/wesleyhales/ca2b8f8844061b4b4d70c82ecb744ea3.js"></script>

* Server logging basically tells you when the test execution began and when it ended.
* Performance Logging gives us more information around frame navigation. We'll be able to correlate this later with navigation and Resource timing APIs. 
* For all loggin configuration options see https://github.com/SeleniumHQ/selenium/wiki/Logging

In the following snippet, we're adding more criteria for our test and actually sending log messages that we setup earlier to console.log:
<script src="https://gist.github.com/wesleyhales/83d2ae26df603b1b08c74cfbb8c8fee8.js"></script>

* The first few lines specify which node we're going to run this test on. Later we'll parameterize this to handle more regions.
* This is followed by the actual WebDriver initialization and setup. Make sure you add your hub IP address from the first step above.
* Finally you see the console statements for the native WebDriver logging.

And finally, we get to the meat of this exercise:
<script src="https://gist.github.com/wesleyhales/ee1a3d298830d6dbc50fb0a8be6b6a1d.js"></script>

* First we setup the screen size for the browser window and then actually perform the GET request.
* Then we see the driver.wait command. I'm using this a a fail safe to ensure the browser has time to populate the Resource Timing entries for perf measurements.
* Next we take a screenshot and save it to the filesystem.

When this script executes, you'll see all of our logging entries print out to the main terminal window. Since all 
this data is in JSON format, it makes it easy for us to setup a database and store it on each run. In the next article
I'll show you how to wrap this script in a node web application and store the JSON in Postgres (along with the screenshot) on each run.
In Part 3 we'll look at scaling out to support more regions, look at why nodes seem to fail randomly, and how to add multiple
nodes from different hosting providers e.g. AWS, Digital Ocean, etc...


<br/>
<br/>