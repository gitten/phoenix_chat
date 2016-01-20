# PhoenixChat

Dependencies:

  Due to the forthcoming dependency on WebRTC and JS based video chat, and since Chrome
  only works with https in this case, we set up a self-signed cert on our local dev 
  environment per this: http://brianflove.com/2014/12/01/self-signed-ssl-certificate-on-mac-yosemite/
  Please see config/dev.exs and customize the hard paths to keyfile and certfile.
  We also set up a dev domain in our dev machine's /etc/hosts file, with the entry:
  127.0.0.1 gtcode.local
  TODO: Fix this

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`gtcode.local:4001`](https://gtcode.local:4001) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
