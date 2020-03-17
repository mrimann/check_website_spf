# check_website_spf - Monitoring Plugin to validate SPF Policy of hosted websites

Goal of this plugin is to monitor proper use of the Sender Policy Framework (SPF) entries in a DNS zone.

It covers the following cases:

- Checks the presence of an SPF policy (by default it's OK to have no published SPF policy at all)
- Optionally alerts on missing SPF policy for a domain, for cases where you want to make sure that the domains **must** have a policy
- Checks the syntactical validity of that policy
- Checks whether the webserver that delivers the website is allowed to send mails from that domain (relevant for mails from e.g. contact forms or shop order confirmations and the like)
- Shows the current SPF policy for a domain

## Requirements
This script wraps around the [PySPF module for Python](https://pypi.org/project/pyspf/) which results in the following requierments:
- Python 2.6 or newer
- several Python dependencies

I suggest installing via the Package repositories of your Operating System. For Ubuntu 18.04 LTS this can be acheived by installing a single package:

```apt-get install python3-spf```

**TODO:** Fix the installation section! It doesn't work out of the box e.g. on a MacBook.

## Configuration (Icinga2):

Clone this repository into the directory where you have all your other plugins, for Icinga on Ubuntu, this is probably `/usr/lib/nagios/plugins` but could be somewhere else on your system:

	cd /usr/lib/nagios/plugins
	git clone https://github.com/mrimann/check_website_spf.git

To add the command check to your Icinga2 installation, first add the following command definition e.g. to `/etc/icinga2/conf.d/commands.conf`:

	# 'check_website_spf' command definition
	object CheckCommand "website_spf" {
		import "plugin-check-command"
		command = [ PluginDir + "/check_website_spf.sh" ]
	
		arguments = {
			"-m" = {
				set_if = "$must_have_spf_policy$"
			}
			"-z" = {
				required = true
				value = "$zone$"
			}
			"-a" = {
				required = true
				value = "$address$"
			}
			"-f" = {
				required = true
				value = "$fqdn$"
			}
		}
	}

Then add a service definition e.g. to `/etc/icinga2/conf.d/services.conf`:

	apply Service for (zone => zoneConfig in host.vars.https_vhosts) {
		import "generic-service"
		display_name = "SPF Policy for " + zoneConfig.domain_name + " IPv4"
		name = display_name

		# only execute this check every 2h
		check_interval = 2h
		retry_interval = 15m

		check_command = "website_spf"

		vars.must_have_spf_policy = zoneConfig.must_have_spf_policy
		vars.zone = zoneConfig.domain_name
		vars.address = host.address
		vars.fqdn = host.name

		vars += zoneConfig

		ignore where zoneConfig.check_website_spf != 1
        ignore where zoneConfig.domain_name == ""
	}

And finally, add a list of the zones to be checked to the hosts definition e.g. `/etc/icinga2/conf.d/hosts.conf`:

    /* SPF Policy Checks -- https://github.com/mrimann/check_website_spf */
    vars.https_vhosts["domain1.tld"] = {
        domain_name = "domain1.tld"
    }
    vars.https_vhosts["domain2.tld"] = {
    }
    vars.https_vhosts["domain3.tld"] = {
        domain_name = "domain3.tld"
        must_have_spf_policy = true
    }

**Explanation**

The above example config will result in the following:

- domain1.tld will be tested for having a valid SPF policy, but in case there's **no** policy at all, that's fine too
- domain2.tld will not get any SPF checks (because "domain_name" is not set - this can be helpful if you e.g. have multiple subdomains like www.foo.tld and blog.foo.tld on the same webserver, only set "domain_name" on the one that should get the SPF check for the primary domain)
- domain3.tld will be tested and create an alert if there's no SPF policy, or if the existing policy is not valid

In the above snippet, replace domain1, domain2 and domain3 with the domain-names to be checked.

**Please adapt the above snippets to your needs!!!** (and refer to the documentation of your monitoring system for further details).


## Configuration (Icinga or Nagios):

I did never run this check in a Nagios or Icinga (v1) based setup and have no config example to share.

Please have a look at e.g. https://github.com/mrimann/check_dnssec_expiry for inspiration and adapt to this check-script. (pull-requests to add examples to this readme are always appreciated).


## Command Line Options:

| Option | Triggers what? | Mandatory? | Default value |
| --- | --- | --- | --- |
| -h | Renders the help / usage information | no | n/a |
| -m | Flag to set "must have an SPF policy", if set, a WARNING is given in case the tested domain does not have an SPF-Policy at all | no | no |
| -z | Sets the zone / domain to validate, e.g. "myhostedwebsite.example.net" | yes | n/a |
| -a | Sets the IP address of the server to check | yes | n/a |
| -f | Sets the FQDN or HELO of the server we're checking | yes | n/a |

## TODO:

Well, it needs some serious testing to be honest - please provide feedback on whether the plugin helped and in which environment you tested it.

### Ideas to improve

- output the read SPF-Policy in the status-output (to make understanding the PySPF result a bit easier to understand)


## How to contribute?

Feel free to [file new issues](https://github.com/mrimann/check_website_spf/issues) if you find a problem or to propose a new feature. If you want to contribute your time and submit an improvement, I'm very eager to look at your pull request!

In case you want to discuss a new feature with me, just send me an [e-mail](mailto:mario@rimann.org).


## License

Licensed under the permissive [MIT license](http://opensource.org/licenses/MIT) - have fun with it!

### Can I use it in commercial projects?

Yes, please! And if you save some of your precious time with it, I'd be very happy if you give something back - be it a warm "Thank you" by mail, spending me a drink at a conference, [send me a post card or some other surprise](http://www.rimann.org/support/) :-)
