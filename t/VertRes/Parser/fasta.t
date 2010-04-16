#!/usr/bin/perl -w
use strict;
use warnings;
use File::Spec;

BEGIN {
    use Test::Most tests => 19;
    
    use_ok('VertRes::Parser::fasta');
}

my $fap = VertRes::Parser::fasta->new();
isa_ok $fap, 'VertRes::Parser::ParserI';
isa_ok $fap, 'VertRes::IO';
isa_ok $fap, 'VertRes::Base';

ok my $rh = $fap->result_holder(), 'result_holder returned something';
is ref($rh), 'ARRAY', 'result_holder returns an array';
is @{$rh}, 0, 'the result_holder starts off empty';

ok ! $fap->next_result, 'next_result returns false when we have no file set';

my $fa_file = File::Spec->catfile('t', 'data', 'ssaha.fa');
ok -e $fa_file, 'file we will test with exists';
$fap->file($fa_file);

# parse the first sequence
$fap->next_result;
is_deeply $rh, ['165', 'AAGGCGTGCGCCACCACGCCCGGCTAATCCCACTCACCCTTGGGGTTCCCCAGAGTTCCCTTTCCCAGTTGGTTCTCAGCTACTTCAGATGTGGGTAAAATCTCTGTGTCACTAGTACACCAGACTGTGGCTCTGTGGCTGGGACCTGCCTTTGGGGATGTGGCCTGGCAGAGACAGAGAAACAGGAAAGTGGGGTTCCTGCAACACTATCTGTCCTTCAAGGGTTCCTCTTCACGTCCCCCGCTAAAAAAAAAAAAGAATTGTTTTCCATCAACCACTGAGTCATTCCAGAATTGGGACCTCCCTTGAGTTTAAACTCATAGAGACAGGAAGAAAAGCATCCTGACACTCAACATTATAACGTTTATCCCGGGTTGGGGGAACAAGGAGGGACTTCACATTGCATAAAAATCAACCCAAGGCCCAGCAAAGGTGCTTGCTTCCAAGCCTGCTGACCTAAATTCAATCCCCTGAGACTCACATGGCAGGAGGAGAAAACCAACCCACACTAGTCTGTCCTTTGACCTCTGCACACACACACACACACACAC'], 'parsed data for first sequence';

# get info on the 4th sequence
is $fap->seq('239'), 'TTAAAATTATATTAAGAACAATCTGACCACCCTAGAATACTTCCAGCCATAAGTCATAAAGATTTATTAATAATACCCATATTTGTAACTGTCCTGTGAGATGTTATCTTCCCTGTACATTAGACAAAATTACCTTTGATTTAAATTAAGAAAAATGATAAGACATAGGCAAAGCAAAGAGTTCAAGAGCAGACAGCTCAACATACAGTGGCAGCTACAATCTGTATGTCCTTCTGTCCCAGGTCCTACTATCTTTCCATTCCATCATCCATAACATTGCTTTCATCTTCCTGCTATTACTTTATTACTCACATTTGTTATATAGTCATAAAGAAAGACCAAGTGCAGGAGCCAGAAAGAACTGTTTTTCTAGAACTCCAAACATGCAACAGCTGCTTACCTGTCTTCACACCACACCCTGATCTTATCAAGATAGCACCAGCTAGAAGTAGATTTTATTTTTAAGGAAACATAGGTCTCTTATATTGAATATGTGCTGTATCATGTAATGACTAATATGACATATCAACTTGAATAGATGAAGAAATGCTGAAGAAATATTAGTGAGCAACACTATTGGGCATATCTGTGGCTATAGTTGAGGTAACTTGAGGGGTTGGTGTGGCAATCTACTGCAGTGGACTCTTTCTGGAATCTATGAGGTGATCCTACTGAGGACTTTTTGTAATGGAGGATATGGAGTCTGAACTGGCTATCTTGAGTAGCCGGGCAATGTTTCCAGTGATGGAGTCCTGTGGACTCTCCAAGCAATCCATACAGATGCTAGGAAAGAACAGCGTTCTCTAAACTCTGACACTGGTGCTCCTTTGGTAAGGACAACTTCCACACATTGAACCCAGAAAGATTGACCTAGTCCCTACAGTGAACATTTACCCATACATTCTAAAGTCTTTGGTGTGGGAAGGTGCTCTGCATGCTACTGAAAGAGAAACCTGGACATCAAGCCATACACAAAACATTAACCTCCAATCTACCCTGCTTGCAAGATGTGCTGGGGCAATGGT', 'seq test when not yet reached';
is $rh->[0], '165', 'using seq doesn\'t change our result holder';
$fap->next_result;
is $rh->[0], '233', 'using seq doesn\'t mess with next_result';

# test sequence_ids
my @ids = $fap->sequence_ids();
my %ids = map { $_ => 1 } @ids;
is $ids{'165'}, 1, 'sequence_ids gave first sequence id';
is $ids{'1510'}, 1, 'sequence_ids gave last sequence id';
is @ids, 50, 'sequence_ids gave all ids';

# parse the last line
while ($fap->next_result) { next; };
is_deeply $rh, ['1510', 'AAAAAAAAAAAAAAAAAAAAGCCAAAAATCCTCTCTGAGATTGTTACTACAGTGGCTAGGGTTAGATCCTGGGTTCTGGCAGCTCTAACAAGCCAAGCCTAGCCATCTACACAATTAATAACAAAGAAAGAAAAACAACATTTGTTTTTCAATGTGACCACATTAGGAAGAGCACGAAAGAATTCCATTGACAACTGTCTGTCACTCACAAGACATTTTGGGGGCTTTGATGTGAGGTTTAGGTTTAAGTAGAGGCCAACAAGATTCACCTAACTAAGCAGACTTGTTCAAGGTGTGGCCCCGTGCATTACCATGGTCTCAGAAACATCTTTCCTGCAAGGTGGTCTATTTTTAGGACAGTGAGAATCTCTTTCCAGGAGACAAGTTCTCATTCTGCCTGGCACCAGGGCCTTCTCCTTTTCCTTCCTAAGAGACCTCTGGGGAAATTCCAACAGCCTGGTAACCAAAATAGGAGTTGGGGGAGGGGCGGGATGAAAAGTCTTTCTTTAGAATGTCTCCATTCCTGCCTTGCTAACCAGGTGGTTATGTTCCCTTGTAAGCTTTTTGATCAAATGACAGACCAAACCTCCACACTGTACCTTTTCTCCATGTGACCTAGCTGTGCTGACCATATTGCTTGGAAATGGCAGATGGTTTCCTGCATTGAGGACCATATTTCATGTACGTCCACTGTGAAAGATACTCTGGTCCCAGACAGAATCAGTTCCAGCTCACTTTACTAACACAAGAACTGAAAAAAAGACACAGAAGAGAGGACAGGATAAAATTACTACATATTGCTCCATTTATCTACTTCTCTGTTCCATTCCTTGTTCTTCACTTGCAGATGTGTGCACCACTAAGAGTTCCAGCATGGTTGTGTCCTTCCAGTGTAAGTGATCTGGCTATGTTTCACTGAGCGTGGTAACGTGGACCTCTGCCTTGCGGTAAAGACACAGTGTTAATGAAGCATGAGCACAGGAGGCTTGCGCCTCACACAGAACAGATTGAATCACCCAGGAATGCTTGCTATAGTTCTGGAATTTTCCTTTCTCATCTCAGTAAGTGTGGTGGTTTGAATAAGAATGGT'], 'parsed data for last sequence';

ok $fap->exists('1350'), 'exists found an existing sequence';
ok ! $fap->exists('fake'), 'exists didn\'t find a fake sequence';

exit;
