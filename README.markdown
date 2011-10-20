
rss-feed
============

`rss-feed` is a command line program written in perl that allows you to create BO.LT pages (bolts), for every link in an RSS feed.

The first step to really using `rss-feed` is to get your token (Access Token):

  1. log into BO.LT (its free to create an account) 
  2. go to the [API App Settings section on the Settings page](https://bo.lt/app/settings#api-app-form). 
  3. provide an application name (anything will do, for example rss-feed)
  4. save your application
  5. click *Generate an access token for your App*

BO.LT
=====

[BO.LT](http://bo.lt/) is a Page Sharing Service. 

When you put a page on BO.LT it is copied along with its assets onto our servers and deployed to our edge network.

A page on the BO.LT network is referred to as a bolt

A bolt:

  - can be easily shared on a number of networks (Facebook, Twitter, etc)
  - can have a descriptive url, that people will notice (e.g. http://mary.bo.lt/flying_pigs)
  - allows you to add your comment on the page itself (so even if its re-tweeted your comments aren't lost)
  - allows you to automatically put your identity and link back to your site on the page
  - supports an intutive in-browser editor that can modify the live page.
  - doesn't change when the original site changes its page.
  - is fast as it runs on an edge network
  - will appear in your showcase of bolts as well as other showcases on BO.LT (e.g. [Reddit Feed](http://reddit.bo.lt))
  - has segmented view metrics
  - can be setup to autmatically integrate your metrics provider


Documentation on the BO.LT api can be found [here](http://dev.bo.lt)

