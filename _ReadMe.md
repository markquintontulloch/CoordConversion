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
* -r/--region
    * List of one or more regions to convert, separated by single spaces
    * Regions should be in the following format:
        * chr:start..end:strand
    * Strand is optional, and should be specified as either 1 (sense) or -1 (antisense)
    * e.g. `--region 1:10000..20000:1 2:100..300:-1 X:350-4000`
* -i/--in_file
    * File containing list of regions in format described above
    * Regions can be separated by whitespace or any non-alphanumeric delimiter except for '-', ':', '_', or '.'
* -f/--from
    * Name of assembly to convert coordinates from (default: GCRh38).
* -t/--to
    * Name of assembly to convert coordinates to (default: GCRh37).

## Alternative to Perl API


### Ensembl Rest API
Coordinate mapping from GRCh38 to GRCh37 can also be achieved using the Ensembl Rest API  by submitting a GET request to the https://rest.ensembl.org server in the following format:
    map/:species/:asm_one/:region/:asm_two

For example, to retrieve the mapping for the antisense strand of the region on chromosome 1, between base positions 25000 and 40000, you would submit the following request:	    

https://rest.ensembl.org/map/human/GRCh38/1:25000..40000:-1/GRCh37

This has the following advantages and disadvantages for the user:
* Advantages
    * Platform independent - user not tied to a specific programming language
    * Separation of client/server concerns
        * User isolated from server-side architecture changes
        * Access to the latest data without updating client-side software
* Disadvantages
    * Less functionality than Perl API
    * Inefficient for data mining
    
