# coord_convert.pl

## Description

This script uses the Ensembl Perl API to map regions from one assembly to another.  By default, this mapping is from the GCRh38 assembly to the GCRh37 assembly.  Regions can be specified via the command line, a file containing a list of regions, or both.

## Requirements

In addition to the Ensembl Perl API, the following Perl modules are required:
* Getopt::Long
* Path::Class

## Usage

    perl coord_convert.pl [options]

Either -r/--region or -i/--in_file (or both) must be specified.  All other arguments are optional.

Options:
* -r/--region   List of one or more regions to convert, separated by single spaces.  Strand is optional, and should be specified as either 1 (sense) or -1 (antisense).  Regions should be in the following format: chr:start..end:strand (e.g. --region 1:10000..20000:1 2:100..300:-1 X:350-4000).
* -i/--in_file	File containing list of regions in format described above.  Regions can be separated by whitespace or any non-alphanumeric delimiter except for '-', ':', '_', or '.'.
* -f/--from     Name of assembly to convert coordinates from (default: GCRh38).
* -t/--to       Name of assembly to convert coordinates to (default: GCRh37).