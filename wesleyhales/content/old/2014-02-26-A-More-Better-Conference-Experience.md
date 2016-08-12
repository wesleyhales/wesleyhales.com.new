---
author: "Wesley Hales"
date: 2014-02-26
layout: blog
title: A More Better Conference Experience
tags: [devnexus, onslyde, raspberry pi, rpi]
preview: This post explains the details and challenges behind running Onslyde at the Devnexus 2014 conference in Atlanta GA.
previewimage: /images/icons/onslyde.png
---
<br/>
## Overview
I've been working on an open source project called [Onslyde](https://www.onslyde.com/) for almost 2 years. If you want to know the
details behind it you can read articles [here](http://coding.smashingmagazine.com/2013/11/20/reinventing-the-tech-conference-experience/), [here](http://wesleyhales.com/blog/2013/02/25/How-Collective-Wisdom-Shapes-a-Talk/) or [watch a recent interview](http://eventtech.co/2014/01/24/wesley-hales-creator-of-onslyde/).

This year, at [Devnexus 2014](http://devnexus.com/), I wanted to take Onslyde a bit further by offering a way for sponsors to
ask questions throughout the day between sessions. Since this was a trial/experiment I went old school and
didn't create a web interface for reserving sponsored slots. I simply created a [spreadsheet](https://docs.google.com/spreadsheet/ccc?key=0AnSCILK6XyYLdHVEdndSY1VCM2NSOFowNzZrb284a3c&usp=drive_web#gid=0) with speaker name, session title,
and time. Sponsors could then choose a time and I would reserve it on a first-come-first-serve basis.
<br/>
## The Idea

At it's core, Onslyde is a tool that allows people to connect and give their opinion within seconds. Now,
attendees can vote on seeded questions that will allow sponsors to connect to those who are truly interested
in their product or what they have to say.

[<img src="/images/posts/2014-02-26/image_3.jpeg" class="margin10 max-width-50 float-right">](/images/posts/2014-02-26/image_3.jpeg)

I've already written about [the disconnect between speakers and attendees](http://coding.smashingmagazine.com/2013/11/20/reinventing-the-tech-conference-experience/), but what about the disconnect
between sponsors and attendees? After all, these are the companies that shell out massive amounts of cash, setup up
a booth, and wait for attendees to visit them in hopes of gaining a lead, recruiting a new employee, or making a sell.
Why not proactively give them true leads that don't require a stop by the ol' exhibit floor booth?

This all sounds great in theory, but I had no idea how hard this would be to put together and manage throughout
a 2 day conference with around 1200 attendees. So let's look at the details behind the implementation and
challenges that were faced.

* Devnexus had around 30 sponsors this year. This included Red Hat, GitHub, Twilio, and many others. I wanted a
way for them to communicate with attendees who are interested in what they have to say on the screen.

* We started out by allowing each sponsor to ask one question, and then charging a fee for additional questions.
However, and I'm happy about it now, zero paid slots were sold. But almost all the sponsors took advantage of their one free question, so a week before the
conference we ended up giving all the slots away for free.
I quickly learned that trying to sell the empty slots was the wrong approach - mainly because it requires up front sales.
Either myself or someone else would need to try and up sell sponsors on question slots. It was too much selling without proven results.

In hindsight, I should've given sponsors a limit of 10 questions/slots and then found a way to expose the voting
data in a freemium model.
<br/>
## The Hardware

I used a fairly cheap hardware setup powered by Raspberry Pis (or RPi). For around $80, we had a complete Onslyde powered device
that could be placed in any of the rooms. Devnexus had 10 simultaneous tracks, or rooms where someone was speaking, plus
a workshop track. So we needed 10 rooms to be setup with the RPis for live voting.

The hardware setup consisted of the following:

* Raspberry Pi (model B)
* 16GB SD Card
* Edimax wifi USB device
* HDMI to VGA converter dongle
* 3ft VGA cable
* VGA 2 way push-button splitter

[<img src="/images/posts/2014-02-26/image.jpeg" class="margin10 max-width-50 float-left">](/images/posts/2014-02-26/image.jpeg)

The last item in the list above is what caused me a lot of trouble. Ultimately the hardware setup was solid and worked
really well. But physically pushing the button to switch between voting and speakers ready to present was impossible to
handle manually.

Remember we're talking about 10 tracks spread throughout a very large conference center, so after each session the
halls would be packed with people and I was weaving in and out of a stream of attendees trying to get to the next room. I would
have literally needed a volunteer in each room pressing buttons as sessions rotate.

The next section will go over all the challenges I faced, but the main point I want to make here is that it's pretty incredible
to power one of the largest developer conferences in the South East with a $45 piece of hardware and a little bit of open source.
<br/>
## Challenges

* As I just mentioned, the physical aspect of pushing a button to switch video streams limited how many sponsored questions
were actually seen and voted on. The only way around this would be to create a video switcher that would automatically detect the video
current from the speaker and override the secondary Onslyde RPi signal. This is definitely doable and if something doesn't exist that already
handles this case, then I'm assuming it wouldn't be hard to break out the soldering iron and rig something together.

[<img src="/images/posts/2014-02-26/image_9.jpeg" class="margin10 max-width-100 float-left">](/images/posts/2014-02-26/image_9.jpeg)

* The Raspberry Pi's boot to a stripped down Debian based operating system that goes straight into full screen Chromium. The browser then
loads a unique onslyde address with the RPis network interface (wlan0) mac address as a query parameter. This was the most generic
way of identifying the device from my server and keeping track of its location. So, this obviously requires internet access but the conference
center required authentication before making it out to the internet.
Overall the staff at this particular venue were super helpful, so I asked if I could have the 10 mac addresses for the RPis whitelisted. This
would allow them to access the internet without authentication. It was totally doable, but they wanted $200 per mac address to do it! I luckily
talked them into doing it for $200 for all 10, but it's crazy to see the hoops that conference organizers have to jump through at the last minute.

* Working with the A/V team wasn't too much of a challenge, but I had to prepare ahead of time for longer VGA cables. They ran
extra long VGA cables from the projector and the podium to the back of the room. This allowed easy access to each Onslyde device as I ran
in each room switching the projector to the Onslyde screen, and then switching it back 15 minutes later to the presenter.

* One thing that would've been nice is a web UI to handle the scheduling and input of sponsored questions. Since I was trying to prove the
idea, there wasn't much of a reason to invest in the development until I knew it worked. But, if sponsors could come to a page, login,
and see documentation and videos about the advantages of the product, then it would've prevented any doubt and probably would've secured more
 interest and questions.


<br/>
## Conclusion

Overall, I can honestly say that I learned a ton from this experience. We all have these grand ideas of how something should work and
 how cool it will be, but until you get out and actually try it, you have no idea.

Below are [the results](https://www.onslyde.com/#!/analytics?sessionID=555) from one of the polls that was asked during a morning session:
[<img src="/images/posts/2014-02-26/devnexus-voting.png" class="margin10 max-width-100">](/images/posts/2014-02-26/devnexus-voting.png)
You can probably imagine, at this point, what you would do with this data as a sponsor. When each user votes they are required to oauth with their G+
account. So we have names and email addresses that can be contacted after the fact.

My plans for the future are to investigate if this is worth continuing and make the bootable Onslyde Debian image freely available.
Feel free to [review my notes](https://docs.google.com/document/d/1STZ6gzOBLPnUypwHtFGZQY9ME7lYK__DpoQcKFzeLV0/edit#heading=h.hnil29ggb4vc) on the exact hardware I used and how I setup
the devices to boot into full screen Chromium and run Onslyde.

<br/>
<br/>