# check_website_spf - Icinga / Nagios Plugin to validate SPF records for hosted websites

Goal of this plugin is to monitor proper use of the Sender Policy Framework (SPF) entries in a DNS zone.

It covers the following cases:

- Checks the presence of an SPF policy
- Checks the syntactical validity of that policy
- Checks whether the webserver that delivers the website is allowed to send mails from that domain (relevant for mails from e.g. contact forms or shop order confirmations and the like)


## Installation (Icinga):

**TODO:** Add documentation

## Installation (Icinga2):

**TODO:** Add documentation

## Command Line Options:

| Option | Triggers what? | Mandatory? | Default value |
| --- | --- | --- | --- |
| -h | Renders the help / usage information | no | n/a |
| -z | Sets the zone / domain to validate, e.g. "myhostedwebsite.example.net" | yes | n/a |
| -a | Sets the IP address of the server to check | yes | n/a |
| -f | Sets the FQDN or HELO of the server we're checking | yes | n/a |

## TODO:

Well, it needs some serious testing to be honest - please provide feedback on whether the plugin helped and in which environment you tested it.


## How to contribute?

Feel free to [file new issues](https://github.com/mrimann/check_website_spf/issues) if you find a problem or to propose a new feature. If you want to contribute your time and submit an improvement, I'm very eager to look at your pull request!

In case you want to discuss a new feature with me, just send me an [e-mail](mailto:mario@rimann.org).


## License

Licensed under the permissive [MIT license](http://opensource.org/licenses/MIT) - have fun with it!

### Can I use it in commercial projects?

Yes, please! And if you save some of your precious time with it, I'd be very happy if you give something back - be it a warm "Thank you" by mail, spending me a drink at a conference, [send me a post card or some other surprise](http://www.rimann.org/support/) :-)
