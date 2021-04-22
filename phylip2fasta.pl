#!/usr/bin/env perl

#===============================================================================
=pod

=head1

         FILE: phylip2fasta.pl

        USAGE: ./phylip2fasta.pl phylip.file > fasta.file

  DESCRIPTION:  Convert phylip to fasta.
                Reads from file or from stdin, writes to
                file or stdout.

      OPTIONS: Optional options

               -i,--infile      input phylip file
               -o,--outfile     output fasta file
               -I,--interleaved input is interleaved
               -S,--sequential  input is sequential
               -s,--shortid     seqid is 10 chars long
               -h,--help        show help

 REQUIREMENTS: BioPerl

         BUGS:BioPerl::AlignIO::phylip.pm contains a bug (see below).

        NOTES: BioPerl::AlignIO::phylip does not handle strict
               phylip format correctly if there are spaces in
               sequence labels. Beware of input/ouptut errors!

       AUTHOR: Johan Nylander (nylander) <johan.nylander@nrm.se>

      COMPANY: NRM/NBIS

      VERSION: 0.3

      CREATED: 2004

     REVISION: 9 Apr 2021

=cut
#===============================================================================

use strict;
use warnings;
use Bio::AlignIO;
use Bio::SimpleAlign;
use Getopt::Long;

exec('perldoc', $0) unless (@ARGV);

my $infile         = q{};
my $outfile        = q{};
my $shortid        = 0;
my $longid         = 1;
my $interleaved    = 0;
my $interleavedset = 0;
my $I              = 0;
my $S              = 0;
my $VERBOSE        = 0;
my $in;
my $out;

GetOptions(
    "infile=s"      => \$infile,
    "outfile=s"     => \$outfile,
    "I|interleaved" => \$I,
    "S|sequential"  => \$S,
    "s|shortid"     => \$shortid,
    "verbose!"      => \$VERBOSE,
    "help"          => sub { exec("perldoc", $0); exit(0); },
);

if ($I) {
    $interleaved = 1;
    $interleavedset = 1;
}
if ($S) {
    $interleaved = 0;
    $interleavedset = 1;
}
if ($shortid) {
    $longid = 0;
}

if ($infile) {
    if ($interleavedset) {
        $in = Bio::AlignIO->new(
            -format => 'phylip',
            -interleaved => $interleaved,
            -longid => $longid,
            -file => $infile
        );
    }
    else {
        $in = Bio::AlignIO->new(
            -format => 'phylip',
            -longid => $longid,
            -file => $infile
        );

    }
}
else {
    if ($interleavedset) {
        $in = Bio::AlignIO->newFh(
            -format => 'phylip',
            -interleaved => $interleaved,
            -longid => $longid,
            -fh => \*ARGV
        );
    }
    else {
        $in = Bio::AlignIO->newFh(
            -format => 'phylip',
            -longid => $longid,
            -fh => \*ARGV
        );
    }
}

if ($outfile) {
    $out = Bio::AlignIO->new(
        -format => 'fasta',
        -displayname_flat => 1,
        -file => ">$outfile"
    );
}
else {
    $out = Bio::AlignIO->new(
        -format => 'fasta',
        -displayname_flat => 1,
        -fh => \*STDOUT
    );
}

if ($infile) {
    while (my $aln = $in->next_aln()) {
        $out->write_aln($aln);
    }
}
else {
    while (my $aln = <$in>) {
        $out->write_aln($aln);
    }
}

__DATA__
  3 30
Taxon00001A-CGTTTCCACAGCATTATGG
Taxon00002C-CTTCACAAATCAATATTGA
Taxon00003T-AGGTATTGGGCTTGGTTCG
GCTCGATGA
GCTAGTGCA
CAGGGGACA

