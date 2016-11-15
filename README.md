![alt tag](https://github.com/nsweeting/rockethook/blob/master/rockethook-logo.png?raw=true)

Rockethook is a microservice dedicated to delivering webhooks. Backed by the Crystal Language and Redis, Rockethook can achieve unmatched speeds with little effort. And it all compiles to a small executable that is easy to setup and deploy.

Rough benchmarks on Ubuntu 16.04:

Runtime | RSS | Time | Throughput
--------|-----|------|-------------
Crystal 0.19.2 | 15MB | 5.2 | 19,220 webhooks/sec

## Installation

Prerequisites:

* The latest version of crystal (> 0.19.0).

1. Clone the repo:
    ~~~ sh
    $ git clone https://github.com/nsweeting/rockethook.git
    ~~~
2. Switch to the repo directory:
    ~~~ sh
    $ cd rockethook
    ~~~
3. Build:
    ~~~ sh
    $ make install
    ~~~
4. Add /user/local/bin to your $PATH for access to Rockethoook from the command-line.
    ~~~ sh
    $ echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
    ~~~
    **Ubuntu Desktop note**: Modify your ~/.bashrc instead of ~/.bash_profile.

    **Zsh note**: Modify your ~/.zshrc file instead of ~/.bash_profile.

## Usage

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/nsweeting/rockethook/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [nsweeting](https://github.com/nsweeting) Nicholas Sweeting - creator, maintainer
