# Gmail Observer

manybots-gmail is a Manybots Observer that allows you to import your emails from your Gmail accounts, including Google Apps, into your local Manybots.

On Manybots, your emails will look like this:
john@manybots.com received an email from Super Fan - You guys are awesome.

They'll be tagged with the Gmail labels they belong to.

## Installation instructions

### Setup the gem

You need the latest version of Manybots Local running on your system. Open your Terminal and `cd` into its' directory.

First, require the gem: edit your `Gemfile`, add the following, and run `bundle install`

```
gem 'manybots-gmail', :git => 'git://github.com/manybots/manybots-gmail.git'
gem 'gmail', :git => 'git://github.com/webcracy/gmail.git'
```


Second, run the manybots-gmail install generator (mind the underscore):

```
rails g manybots_gmail:install
bundle exec rake db:migrate
```


### Restart and go!

Restart your server and you'll see the Gmail Observer in your `/apps` catalogue. Go to the app, sign-in to your Gmail account and start importing your commits into Manybots.