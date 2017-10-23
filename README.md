iNaturalist photo download script
=================================
Will Pearse (will.pearse@usu.edu)

Pretty much what it says on the tin. Allows you to _search_
iNaturalist from the command line, as well as _download_ images of
various resolutions.

## Requirements

* Ruby
* Ruby gems:
  * optparse
  * open-uri
  * json
  * nokogiri
  * CSV

...it may be that some of the above gems aren't needed by the script,
but they're in the _requires_ section at the top regardless :p

## Usage

The files should be executable by default. If not, something like
`ruby search.rb --help` or `ruby dwn_pics.rb --help` will give you an
example of how to run each script.

Each script has required variables (the species to download, a file to
save metadata, and an existing folder to save pictures to for
`dwn_pics.rb`). If the script is giving you an error, and it works on
my computer (which it does), then it's probably something you've done,
not me...