
# node-sgc

An node module to read and write [Synergy](http://synergy-project.org/)'s
[configuration file format](http://synergy2.sourceforge.net/configuration.html)

This is pretty much only useful if you're writing
[an interface](https://github.com/1j01/nw-synergy) to Synergy.


## Run

1. Have [Node.js](http://nodejs.org/)

2. Run `npm install` in the project directory

3. Run `npm test` in the project directory


## Usage

Are you writing an interface to Synergy?

Really? Are you sure?

Okay...
I mean, if you *are* writing an interface to Synergy,
then this could be *very helpful*, but chances are
you're only continuing reading this because,
I suppose, it's more conversational than most README documents.

At any rate, there's `SGC.parse` and `SGC.stringify`, mimicking the JSON API.

```javascript
var SGC = require("SGC");
var fs = require("fs");
var config = SGC.parse(fs.readFileSync("synergy-config.sgc", "utf8"));
console.log(config.screens, config.links, config.aliases, config.options);
fs.writeFileSync("synergy-config.sgc", SGC.stringify(config), {encoding: "utf8"}));
```

Both functions may throw errors.

## Metadata Retention (:lock_with_ink_pen:)

It tries to retain your preferred formatting a bit.
It stores the first indentation it finds
in `config.meta.tab` and uses that later if you stringify it.

It also preserves some comments, sometimes in the wrong places.

It can't be perfect. The file changes.

After all, sometimes you *don't* want it to retain a comment,
for example if you change the switch delay, this comment becomes outdated:

	switchDelay = 500 # half of a second


I think it would be awesome if someone started work on
a comprehensive system for loading, modifying, and saving
structured documents
while retaining as much metadata and formatting as possible.


	∑SYN.Act =∑R-*I(CRed+COOP++AUnimit.)*V(Cust.+Info.)*cc

