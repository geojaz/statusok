# On-Call

Production software should be monitored.
Some monitoring events are so important that
on-call engineers should be alerted immediately
to triage, coordinate, mitigate, resolve, and follow-up.

This article covers the mechanics of on-call at
[Chain](https://chain.com) (now [Interstellar](https://interstellar.com))
for our product [Sequence](https://dashboard.seq.com/docs)
and what it feels like to be an engineer with an on-call rotation.

## Canaries

I have heard "canary" used two different ways:

1. the initial deploy of production software,
   rolled out to a small number of machines or users
2. separate software,
   continuously testing the production software from the outside

When I use "canary" in this article, I mean the second way.

## What canaries test

The canaries test critical parts of our software,
an API-based SaaS product for teams.

One canary tests the entire surface area of the API
to ensure our core product is working.

Another canary tests the onboarding flow
to ensure new users can sign up, create a team, create a ledger,
invite team members, and that team members can accept their invites.

## Example canary

The onboarding flow canary has a dependency on an email account
because we want to test that the email confirmation code is delivered.
We created a Gmail account with credentials shared in
[1Password](https://1password.com/) and a Google App to access it via API calls:

```
export GMAIL_CLIENT_ID="example"
export GMAIL_CLIENT_SECRET="example"
export GMAIL_CREDENTIAL="example"
```

We wrote the canary as a [Sinatra](http://sinatrarb.com/) app:

```
source 'https://rubygems.org'

ruby '2.5.1'

gem 'google-api-client', '~> 0.8'
gem 'http'
gem 'puma'
gem 'sinatra'
```

We start the Sinatra app with:

```
bundle exec ruby web.rb
```

Every test run of the canary is executed via HTTP request to a `/run` endpoint.

## Monitoring

[Runscope](https://www.runscope.com).

## Alerting

PagerDuty

## On-Call Schedule

## WiFi

[Verizon Jetpack](https://www.verizonwireless.com/internet-devices/verizon-jetpack-mifi-7730l/)
