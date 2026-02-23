# Pricetag

> [!WARNING]
> This is the experimental **go** rewrite of Pricetag. Some features may be broken or not implemented.

**Pricetag** is a CLI-based file tagging tool written in Swift!

## Usage

There are various subcommands that can be used with **pricetag**. Here they are:

```bash
clear <file>                                                                 - Clears all tags from the given file
fileswithtag <tag>                                                           - Lists all files with the given tag
info <file>                                                                  - Lists tags for the given file
listtags                                                                     - Lists available tags
ls                                                                           - Lists the contents of the current directory + icons and tags
newtag <name> <red|orange|yellow|green|blue|purple|black|white>              - Create a new tag with the given name and color
seticon <extension> <icon> <red|orange|yellow|green|blue|purple|black|white> - Sets icon for given file extension (for pricetag ls command)
tag <file> <tag>                                                             - Add the given tag to the given file
untag <file> <tag>                                                           - Removes the given tag from the given file```

## Installation

To install, simply use my **homebrew** formula!

```bash
brew install stikypiston/formulae/pricetag
```
