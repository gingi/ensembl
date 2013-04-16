#!/software/bin/perl

use warnings;
use strict;
use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Compara::Graph::NewickParser;
use Getopt::Long;

#
# Script to take a full species tree and a set of required species taken from a database
# and prune it to leave only the required species.
#

my $help;
my $url;
my $tree_file;
my $output_taxon_file;
my $output_tree_file;
my $species_set_id;

GetOptions('help'        => \$help,
       'url=s'          => \$url,
       'tree_file=s'       => \$tree_file,
	   'taxon_output_filename=s' => \$output_taxon_file,
	   'njtree_output_filename=s' => \$output_tree_file,
    'species_set_id=i'  => \$species_set_id,
);

if ($help) { usage(); }

my $compara_dba = new Bio::EnsEMBL::Compara::DBSQL::DBAdaptor(-url => $url)
    or die "Must define a url";

if (defined $output_taxon_file) {
    my $species_tree    = $compara_dba->get_SpeciesTreeAdaptor()->create_species_tree();

    open  TF, ">$output_taxon_file" or die "$!";
    print TF $species_tree->newick_format( 'njtree' );
    close TF;
}

if (defined $output_tree_file) {

    my $blength_tree = Bio::EnsEMBL::Compara::Graph::NewickParser::parse_newick_into_tree( `cat $tree_file` );
    my $pruned_tree  = $compara_dba->get_SpeciesTreeAdaptor()->prune_tree( $blength_tree, $species_set_id );

    open FH, ">$output_tree_file" or die "$!";
    print FH $pruned_tree->newick_format('simple') . "\n";
    close FH;
}

sub usage {
  warn "Specifically used in the LowCoverageGenomeAlignment pipeline\n";
  warn "prune_tree.pl [options]\n";
  warn "  -help                          : print this help\n";
  warn "  -url <url>                     : connect to compara at url and use \n";
  warn "  -tree_file <file>              : read in full newick tree from file\n";
  warn "  -taxon_output_filename <file>  : filename to write taxon_ids to\n";
  warn "  -njtree_output_filename <file> : filename to write pruned treee to\n";
  warn "  -species_set_id <int>          : the ID of the species set giving the list of species (all the species, otherwise)\n";
  warn "NOTE: The matching is done on the name\n";
  exit(1);  
}

