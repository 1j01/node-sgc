
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

It tries to retain your preferred formatting,
to the extent of storing the first indentation it finds,
storing it in `config.meta.tab` and using that later if you stringify it.


## TODO

* Ignore comments


	∑SYN.Act =∑R-*I(CRed+COOP++AUnimit.)*V(Cust.+Info.)*cc

