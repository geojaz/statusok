# On-Call

Production software should be monitored.
Some monitoring events are so important that
on-call engineers should be alerted immediately
so they may respond.

This article covers the mechanics of on-call at
[Chain](https://chain.com) (now [Interstellar](https://interstellar.com))
for our product [Sequence](https://dashboard.seq.com/docs)
and what it feels like to be an engineer with an on-call rotation.

## Canaries

I have heard the term "canary" used two different ways in the industry:

1. production software itself,
   rolled out to a percentage of production machines and users
2. separate software,
   continuously testing the production software from the outside

When I use "canary" in this article, I mean the second way.

The canaries test critical parts of our software,
an API-based SaaS product for teams.

One canary tests the entire surface area of the API
to ensure our core product is working.

Another canary tests the onboarding flow
to ensure new users can sign up, create a team, create a ledger,
invite team members, and that team members can accept their invites.

## Monitoring

[Runscope](https://www.runscope.com).

## Alerting

PagerDuty

## On-Call Schedule

## WiFi

[Verizon Jetpack](https://www.verizonwireless.com/internet-devices/verizon-jetpack-mifi-7730l/)
