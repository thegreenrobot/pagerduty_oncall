pagerduty_oncall
================
How to determine who is on-call using Ruby and the PagerDuty API

Purpose
=======
Our team utilizes an IRC bot to execute a variety of functions but I found that it lacked a function to ask PagerDuty which engineer was on-call right now.  I set out to figure out a way to answer this question.

Libraries
=========
I'm no Ruby expert so when I asked three different developers for their library recommendations I was given three different answers.
* Curb => https://github.com/taf2/curb
* Faraday => https://github.com/lostisland/faraday
* net/http => http://ruby-doc.org/stdlib-2.0.0/libdoc/net/http/rdoc/Net/HTTP.html

Usage
=====
* Change the URL subdomain for your account
* First argument: Your API key (I recommend generating a read-only API key)
* Second argument: The ID of the appropriate service id.

Sample Output
=============
On-Call Engineer: John Smith - john.smith@yourcompany.com - 1112223333

More Information
================
* PagerDuty API documentation => http://developer.pagerduty.com/documentation/rest
* http://support.pagerduty.com/entries/23586358-Determine-Who-Is-On-Call
