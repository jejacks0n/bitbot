Bitbot
======

[![Gem Version](https://img.shields.io/gem/v/bit-bot.svg)](http://badge.fury.io/rb/bit-bot)
[![Build Status](https://img.shields.io/travis/jejacks0n/bitbot.svg)](https://travis-ci.org/jejacks0n/bitbot)
[![Maintainability](https://api.codeclimate.com/v1/badges/7e22d47bd547a055c63e/maintainability)](https://codeclimate.com/github/jejacks0n/bitbot/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/7e22d47bd547a055c63e/test_coverage)](https://codeclimate.com/github/jejacks0n/bitbot/test_coverage)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Bitbot is a lightweight Rack endpoint specifically intended for Slack webhooks. It can be mounted within a Rails app, or
can be run as a standalone Rack app with the `config.ru` provided as an example.

You can write custom responders that take advantage of the logic within your larger application.

Responders have support for custom routing and can utilize [Wit.ai](http://wit.ai) natural language processing.

For more complex responder examples, check out the [bitbot-responders](https://github.com/modeset/bitbot-responders)
project.

## Installation
```ruby
gem "bitbot"
```

### Rails
Bitbot can run fine without Rails, but if you're using Rails, you can run the install generator. The generator will
provide an initializer and mount the rack app within your routes -- be sure to update both the initializer and route if
you change where it's mounted.

```shell
rails generate bitbot:install
```

## Configuration
Bitbot requires being configured, but to simplify the README it's not included here, please check the
[config.ru](https://github.com/modeset/bitbot/blob/master/config.ru) for an example and configuration documentation.

The `config.ru` file is provided as a convenience and only serves as an example -- it is not included with the gem.

You can grab the `config.ru` and run the listener with `rackup`. Or if you've installed the generator, you can test your
setup by starting your rails server and running (based on your configuration and port):

```shell
curl --data 'text=help+me&user_name=tester&channel=none&token=token' \
http://localhost:9292/rack-bitbot-webhook
```

You should get a JSON response back. If you don't, Bitbot is intentionally vague about what could've gone wrong, but the
likely causes are that the token isn't correct, the request isn't a post, or that the username was the same as the bots
(she doesn't respond to herself).


## Setting up Slack
To get all of the configuration tokens and urls, you'll need to go to Slack and add the Incoming Webhooks, and Outgoing
Webhooks integrations. You can get your incoming url, and outgoing token by doing this, which you can then set as
environment variables and load them into your configuration.

When setting up the Outgoing Webhook integration you will need to know where you have configured the Rack endpoint so
you can provide that as the url that will be used.

## Adding Responders
There's a basic DSL for creating responders, which allows you to register help for the various commands, and define
responder routes. Bitbot considers commands to be "routable", and so you can define them using `route`. Here's an
example responder that specifies `category`, `help` and a single `route`. The `category` indicates grouping within the
default help responder, but is somewhat arbitrary in it's meaning should you do something else with it.

```ruby
class MyResponder < Bitbot::Responder
  category 'Greetings'
  help 'hi bot', description: "I'll respond with a greeting"

  route :say_hi_back, /^hi bot/i do
    respond_with("awesome! hi #{message.user_name}.")
  end
end
```

A route must be named, and provide a regexp matcher. Here's another example, but here we capture a value from the
message.

In general a responder route will return a hash that's then sent back to the Slack request but additional messages can
be announced from within the responder. As a general rule you should always use the `respond_with` method in your
responder routes because it can determine if it should return the Hash, or make the announcement itself. You can also
use the `private_message`, or `public_message` helper methods, which always announce and don't return a Hash.

```ruby
route :echo, /^echo (.*)/i do |string|
  respond_with("heard #{message.user_name} say \"#{string}\" in #{message.channel}.")
end
```

### Confirmations
Confirmations are included as a base feature, but need redis to work. Provide your own redis connection in the
configuration and you can add confirmations (and more) to your responders. By default the configuration assumes redis is
running locally, and is available at Redis.current -- otherwise it will try to connect to redis at the standard port.

```ruby
route :say_hi_back?, /^hi bot/i do
  confirm("were you saying hi to me?", "yes") do
    respond_with("awesome! hi #{message.user_name}.")
  end
end
```

### Wit.ai
We think [Wit.ai](http://wit.ai) is pretty rad for a bot setup, but it does take some work to get it trained and working
the way you want. This is part of the fun, and part of the challenge.

To use Wit.ai in your responders, you need to require `wit_ruby` and include the Wit module in your responder. Then you
can define intents, and which route they go to, as well as any entities that are within them. In the most complex form
this would look something like the following.

**Note:** wit_ruby expects `ENV["WIT_AI_TOKEN"]` to be defined. [read more](https://github.com/gching/wit_ruby)

```ruby
class MyResponder < Bitbot::Responder
  include Bitbot::Responder::Wit
  category "Greetings"
  help "hi bot my name is <name>", description: "I'll respond with a greeting"

  intent "greeting", :say_hi_back, entities: { contact: ->(e) { e['value'] } }
  route :say_hi_back, /^hi bot, my name is (.*)/i do |specified_name|
    respond_with("awesome! hi #{specified_name}, I'm bot.")
  end
end
```

Now if you train Wit to understand "Hello, I'm Jeremy Jackson", including the name portion as a `wit/contact` entity, it
will make it through to the responder as the `specified_name` argument to the block. Again, this is a complex thing to
setup and train, so have fun with it. You may also note that the route has a fallback regexp that allows using directly,
even if Wit.ai wasn't able to determine what the intent was.

Worth mentioning, the proc that you see in the `entities` above doesn't need to be specified if all you want is the
value, but if it's a proc it will call the proc with the entity hash. Some entities have complex structures, like
`duration`, where you may want to pull out the seconds, instead of the number of minutes or hours that may have been
provided. In those cases use `duration: ->(e) { e['normalized']['value'] }`, but in our above example, we could've just
used `contact: nil` and the value would be pulled automatically for us.


## Announcing
You can announce any message into any channel on Slack using the bot, for instance in a background job to have something
happen on an action or predefined schedule. You must configure Bitbot's `webhook_url` by setting up an Incoming Webhook
Integration on Slack before this will work however.

```ruby
Bitbot.announce(text: "Hello all!", channel: "#general")
```

You can send private messages if you like as well.

```ruby
Bitbot.announce(text: "Hello you!", channel: "@username")
```

You can also reuse any of the existing responder routes by having the responder handle the route directly. Obviously in
these cases you must provide anything that that responder might expect from the message, which always includes `text`,
and may include common things like `channel` or `user_name`. Since responder routes can be pretty vague, and implement
any number of things, you may have to provide additional information as well.

Since responders can make their own announcements, or return a hash you can use the `Bitbot.announce` method based on
configuration.

```ruby
Bitbot.announce(MyResponder.new.respond_to(text: "Hi bot", channel: "#general", user_name: "system"))
# or
MyResponder.new.respond_to(text: "Hi bot", channel: "#general", user_name: "system")
```

## License
Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)

Copyright 2019 [jejacks0n](https://github.com/jejacks0n)

## Make Code Not War
