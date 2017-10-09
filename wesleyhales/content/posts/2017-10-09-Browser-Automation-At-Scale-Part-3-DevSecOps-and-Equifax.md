---
author: "Wesley Hales"
date: 2017-10-09
layout: blog
title: Browser Automation At Scale - DevSecOps and the Equifax Breach 
tags: [devsecops, secops, automation, chrome, rasp, equifax]
preview: This third installment of Browser Automation at Scale covers how we can jump from performance data to security scanning and data with ease. 
---

If you’ve been following along in [Part 1](http://wesleyhales.com/posts/2017-08-07-Browser-Automation-At-Scale-Part-1/) and [Part 2](http://wesleyhales.com/posts/2017-09-03-Browser-Automation-At-Scale-Part-2/), you already have the basic framework to implement a globally distributed Browser Automation Network. Now, we can easily write a few lines of JavaScript and augment it to create a sophisticated security scanner that will fly under the radar of most security tools and check for application level vulnerabilities - exactly like the one found at Equifax.com a few weeks back. This article covers how to run a scanner that could’ve prevented the Equifax breach if deployed in a [DevSecOps](http://www.devsecops.org/) mindset.

In the Web Performance world, you have two types of tests that allow for metrics gathering: Synthetic and Real User. The goal of Synthetic testing is to monitor the user experience in a web browser, from any geography, continuously and in an automated fashion. This is done by having a crafted script navigate through the app in a manner that simulates a real user, and ensuring the performance measurements of those actions are within target goals. This level of monitoring is critical to operations for detecting issues at runtime, experimental features, or how assets are being delivered to the browser.

Real User Monitoring gives a more accurate view of what users actually experienced on your site by taking live performance samples during the user session. This data is gathered from the same browser APIs that Synthetic tests use, but it’s actual data from a live user in the wild dealing with all sorts of variables that synthetic testing cannot recreate. This perf data is sent through an XHR request back to a web server and is used for key business decisions within the enterprise (it’s critical to the executive team). In short, Synthetic testing analytics is used in Ops and RUM data is used at the business level.

In cyber security, data is gathered and used almost exactly the same way. You have Synthetic testing to scan applications for vulnerabilities and you have Real User (or Attacker) Monitoring for analyzing browser signals that can be used to fingerprint attack groups and to create new JavaScript or browser based countermeasures. Real Attacker Monitoring or RAM data will be analyzed offline to identify where the attack is coming from and steps for mitigation will be determined by the organization’s security team (I’ll cover this topic in depth in a later article). 

Unlike performance data, which can be tied to actual revenue, attack data does not get the same executive-level visibility unless of course, there’s been a breach. 

In the past year, the Struts framework has received some bad press due to the libraries that were included in older versions of the project.  For example, [all but one ](http://struts.apache.org/announce.html)of the project’s official 2017 announcements contained a security vulnerability.

The unfortunate thing is that every open source project (like Struts) depends on standard utility libraries that allow project authors to not have to reinvent the wheel. E.g. Object serialization, parsing, and so on. Dependency (or 3rd party) vulnerabilities like this will continue to rise and be a thorn in the side of every organization on the web.

The attack vector utilized in Equifax’s case is a massive industry wide problem for older web applications that are no longer maintained, or newer ones that are simply unaware that a known vulnerability exists. 

### Security is Everyone’s Responsibility

If you’re not familiar with the concepts of DevSecOps, take 5 minutes and read the [manifesto](http://www.zdnet.com/article/devsecops-what-it-is-and-how-it-can-help-you-innovate-in-cybersecurity/). Here’s a quick blurb from the third paragraph:

"We won't simply rely on scanners and reports to make code better. We will attack products and services like an outsider to help you defend what you've created. We will learn the loopholes, look for weaknesses, and we will work with you to provide remediation actions instead of long lists of problems for you to solve on your own."

There are many types of tools, scanners, and commercial products that try to watch, block or detect attacks within enterprise web applications:

1. Web Application Firewall - HTTP Header inspection
2. Automation Detection - Browser Signals
3. Inline Commercial Solutions (Application and Network Security)

I’m sure most readers of this article already work for a company that implements one of the above. For those that don’t have an enterprise level security solution in place, [nginx+modsecurity](https://github.com/theonemule/docker-waf) in front of your origin is a great place to start for a WAF. From there add the [owasp core ruleset configuration](https://www.netnea.com/cms/apache-tutorial-7_including-modsecurity-core-rules/) and you have a product that most companies offer as an enterprise level WAF solution.

To launch our attack on the enterprise, we’re going to need a few pieces of information before getting started.

* **Gather a List of Web Applications**
    * Knowing the entire list of web applications is a gruesome task for some enterprises due to geographic growth, siloed business units, marketing campaigns and ownership through acquisitions - along with rogue environments that were stood up by a no longer employed, 10x developer a few years back. 
    * For this article, the scope of my analysis is all web applications indexed by Google. I performed a search for all sites that use the well known Struts .action or .do file extension. e.g. "filetype:action doupload" or “filetype: do”
* **Understand Potential Vulnerabilities**
    * After you create the site list, you should document the framework and versions of each web application. This is especially important for older deployments that have long been out of mind. This list will allow you to compare and keep tabs on vulnerabilities as [they’re announced](https://nvd.nist.gov/vuln/data-feeds) by each [project](http://struts.apache.org/announce.html#a20170905) and version. 
* **Create the Attack**
    * With a headline breach, it’s fairly easy to find the specific [source code](http://blog.talosintelligence.com/2017/03/apache-0-day-exploited.html) that is vulnerable and how to replicate the attack. Tools like metasploit and github can yield attack reproduction code based on the CVE and other tools like Shodan or Censys might also come in handy if the application can be identified by [banner](https://en.wikipedia.org/wiki/Banner_grabbing) or ports.
* **Know Your Current Security Stack**
    * Which (if any) commercial products and/or Open Source tools are currently deployed to protect your Web Applications? Do you need to whitelist your attack scanner with the security team? Since we’re attacking from the front door, I don’t really consider this task a "must do". If you stick with the DevSecOps ideals, the goal is to fly under the radar of your current security stack. I’m pretty sure that attackers will not ask your security team to whitelist them.
* **Remediation Steps**
    * In the case of the Struts exploit, you must patch the code or upgrade to a new version of the framework - expensive options for many companies. The official solution provided by Apache suggested either upgrading to a patched version or switching to a different multipart parse implementation. An upgrade can be a long process that involves backups, testing, and server reboots.
    * You could also use a WAF to block the explicit attack header by creating a rule to detect the malicious header - time consuming and can be expensive with false positives. This tuning would typically take weeks and analyzing each header and parsing for the pattern has a specific cost based on the size of the header and your RPS (requests per second).
    * With the right combination of inspecting application dependencies for known vulnerabilities, HTTP level header analysis, and runtime monitoring of the APIs that are implicitly exposed in a web browser, applications can safely be protected from adversaries. Finding the right combination can be challenging and it’s a challenge that I enjoy. Feel free to reach out to me directly at [wesley@tcell.io](mailto:wesley@tcell.io) if you’d like to discuss.

### Step 1 - The Target

For this example, I’m going to use the [Struts showcase application](http://apache.mirrors.tds.net/struts/2.5.10/) to run my scanner against. You can also find a list of Struts target sites through Google by searching for the following [pattern](https://www.google.com/search?q=filetype%3Aaction+doupload). There are roughly 700 sites that could possibly be affected by this vulnerability and to my surprise, running this scanner on the first few results shows that they are in fact vulnerable. This also speaks to how massive vulnerabilities like this are and seven months after the initial announcement are still exposed through a public web server.

![image alt text](/images/posts/2017-10-09/image_0.png)

If you wanted to harvest all of Google’s search results in an automated fashion, you can run the following JavaScript from Chrome’s developer tools:

var nodesArray = [].slice.call(document.querySelectorAll("h3.r a"));(nodesArray.forEach(function(item){console.log('\'' + item.href + '\',')}))

This will produce the URL’s of each target so they can be easily pasted in the [list of sites](https://github.com/wesleyhales/site_runner/blob/scanner/model/AllSites.js) to scan.

![image alt text](/images/posts/2017-10-09/image_1.png)

### Step 2 - Attack Setup

There are multiple ways to launch [this type of attack](https://cwiki.apache.org/confluence/display/WW/S2-046) since it’s just a matter of adding data to a header and sending a POST request. In short, the payload of this attack is sent through an HTTP header to an API that uses the Jakarta Multipart parser. You might also use cURL, metasploit or some other tool that can send an HTTP request with the attack header. Here I’m using Chrome for a few reasons:

1. I’m loading the page and executing JavaScript in a real web browser. This already checks the box on many commercial security tools who are asking "Is this a real user or a bot?"
2. I’m using the browser’s XHR implementation to make the attack request. This gives me implicit access to cookies and any other request signing that needs to happen from a security standpoint.
3. It’s easy to maintain this (along with many other tests) as a single test script that can be executed with a suite.

See source code [here](https://github.com/wesleyhales/site_runner/blob/scanner/selenium/crawl-search.js).

![image alt text](/images/posts/2017-10-09/image_2.png)

First, the above script opens a web page and looks for all the forms in the DOM. This is part of the scanning for susceptible targets within the web app. For each form action URL found, we launch the attack through an XHR request. 

If the target is vulnerable, the report JSON data will be stored and shown in the scanning overview:

![image alt text](/images/posts/2017-10-09/image_3.png)

If this grid of scanners were running on a regular basis when new vulnerabilities are [released](https://nvd.nist.gov/vuln/data-feeds), then we’d have a bit more visibility into how vulnerable our web apps really are. In the case of breaches like Equifax, it may be that the enterprise already knows about the vulnerability and merely did not prioritize the effort to patch the problem or it was simply a process issue. With a tool like this, which can help security teams cut down on time to assess vulns in the wild, priority and process will be flattened for issues found on your live production sites.

## Shout Outs

Thanks to [Clarence Chio](https://www.linkedin.com/in/cchio) and [Boris Chen](https://www.linkedin.com/in/boris-chen-4b118a1/) for their valuable review and feedback.


<br/>
<br/>