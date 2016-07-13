Purpose
=======
Our team utilizes an IRC bot to execute a variety of functions but I found that it lacked a function to ask the PagerDuty API which engineer is on-call right now.  I set out to figure out a way to answer this question.

Libraries
=========
I'm no Ruby expert so when I asked three different developers for their library recommendations I was given three different answers.
* Curb => https://github.com/taf2/curb
* Faraday => https://github.com/lostisland/faraday
* net/http => http://ruby-doc.org/stdlib-2.0.0/libdoc/net/http/rdoc/Net/HTTP.html

Usage
=====
* First argument: Your v2 REST API key (I recommend generating a read-only API key)
* Second argument: The ID of the appropriate service

Sample Output
=============
On-Call Engineer: John Smith. Email(s): john.smith@yourcompany.com, john.smith@gmail.com. Phone Number(s): 1112223333.

More Information
================
* PagerDuty API documentation => https://developer.pagerduty.com/
* http://support.pagerduty.com/entries/23586358-Determine-Who-Is-On-Call
