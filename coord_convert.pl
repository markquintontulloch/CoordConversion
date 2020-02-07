#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use Path::Class;
use Bio::EnsEMBL::Registry;
use Smart::Comments;

my @regions;
my $regions_file;
my $assembly_from = 'GRCh38';
my $assembly_to = 'GRCh37';
GetOptions(
    "region|r:s{,}" => \@regions,
    "in_file|i:s" => \$regions_file,
    "from|f:s" => \$assembly_from,
    "to|t:s" => \$assembly_to
    );

usage() if !@regions and !$regions_file;
@regions = @{get_regions_from_file( \@regions, $regions_file )} if $regions_file;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
    );
my $slice_adaptor = $registry->get_adaptor( 'human', 'core', 'slice' );

for my $region( @regions ){
    my ( $chr, $start, $end, $strand ) = parse_region( $region );
    my $mapped_segments = get_mapped_segments( $slice_adaptor, $chr, $start, $end, $strand, $assembly_from, $assembly_to );
    if ( !@$mapped_segments ){
	print "Region $chr:$start..$end:$strand of the $assembly_from assembly does not map to the $assembly_to assembly.\n";
	next;
    }
    print "Region $chr:$start..$end:$strand of the $assembly_from assembly maps to the $assembly_to assembly as follows:\n";
    for my $segment( @$mapped_segments ){
	my ( $segment_original_region, $segment_mapped_region ) = get_segment_regions( $segment, $chr, $start, $strand );
	print "\t" . join( "\t", $segment_original_region, '==>', $segment_mapped_region ) . "\n";
    }
}

sub get_mapped_segments{
    my ( $slice_adaptor, $chr, $start, $end, $strand, $assembly_from, $assembly_to ) = @_;
    
    my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $start, $end, $strand, $assembly_from );
    die "Could not retrieve region $chr:$start..$end:$strand from $assembly_from assembly.  Please check that this is a valid region.\n" if !$slice;
    
    return $slice->project( 'chromosome', $assembly_to );
}

sub get_segment_regions{
    my ( $segment, $chr, $start, $strand ) = @_;
 
    my $original_start = $segment->from_start() + ( $start - 1 );
    my $original_end = $segment->from_end() + ( $start - 1 );
    my $segment_slice = $segment->to_Slice();

    my $original_region = $chr . ':' . $original_start . '..' . $original_end . ':' . $strand;
    my $mapped_region = $segment_slice->seq_region_name() . ':' . $segment_slice->start() . '..' . $segment_slice->end() . ':' . $segment_slice->strand();

    return ( $original_region, $mapped_region );
}

sub get_regions_from_file{
    my( $regions, $file ) = @_;

    my $fh = file( $file )->openr;
    while( my $line = $fh->getline ){
	chomp $line;
        $line =~ s/[^\w\-\+\.:]/,/g;
	push @$regions, split(',', $line );
    }
    
    return $regions;
}

sub parse_region{
    my $region = shift;
    
    my ( $chr, $start, $end, $strand ) = $region =~ /^([^:]+):(\d+)\.\.(\d+)((:1|:-1)?)$/;
    die "Could not parse region $region.  Region should be in the format <chr>:<start>..<end>:<strand> (e.g. 1:100..10000:-1)\n" if !$chr;
    ( $start, $end ) = ( $end, $start ) if $start > $end;
    $strand = 1 if !$strand;

    return ( $chr, $start, $end, $strand );
}

sub usage{
    print<<EOF;
    
Map genomic regions from one assembly to another.

Usage: perl coord_convert.pl [options]

Either -r/--region or -i/--in_file (or both) must be specified.  All other arguments are optional.

Options:
    -r/--region    List of one or more regions to convert, separated by single spaces.
                   Regions should be in the following format: <chr>:<start>..<end>:<strand>
		   Strand is optional, and should be specified as either 1 (sense) or -1 (antisense)
		   e.g. --region 1:10000..20000:1 2:100..300:-1 X:350..4000
    -i/--in_file   File containing list of regions in format described above.
                   Regions can be separated by whitespace or any non-alphanumeric delimiter
                   except for '-', ':', '_', or '.'.
    -f/--from      Name of assembly to convert coordinates from (default: GCRh38).
    -t/--to        Name of assembly to convert coordinate to (default: GCRh37).

EOF

    exit(1);
}
