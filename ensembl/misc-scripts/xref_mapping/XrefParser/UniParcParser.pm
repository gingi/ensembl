package XrefParser::UniParcParser;

# Input format looks like:
#
# UPI0001B45C00 71B80D7A684B1F2DEDDA7B5AEE1D029E
# UPI0002473BEA 4542D97F3AB3F7B656ABB941AED3F2BB
# UPI00024743AF A69E7EEE820CA54100AD43E86BE823E4

use strict;
use warnings;
use Carp;
use IO::File;
use base qw( XrefParser::BaseParser );

my $TABLE_NAME = 'checksum_xref';

sub run {
  my ($self, $ref_arg) = @_;
  
  my $source_id    = $ref_arg->{source_id};
  my $species_id   = $ref_arg->{species_id};
  my $files        = $ref_arg->{files};
  my $verbose      = $ref_arg->{verbose};
  
  if((!defined $source_id) or (!defined $species_id) or (!defined $files) ){
    croak "Need to pass source_id, species_id and files as pairs";
  }
  $verbose ||=0;

  my $target_file = $files->[0].'.mysqlinput';
  my $input_fh = $self->get_filehandle($files->[0]);
  if(-f $target_file) {
    print "Target file '${target_file}' already exists; removing\n" if $verbose;
    unlink $target_file;
  }
  my $output_fh = IO::File->new($target_file, 'w');
  
  $self->_transfer_contents($input_fh, $output_fh, $source_id);
  
  close($input_fh);
  close($output_fh);
  
  $self->_load_table($target_file, $verbose);
  
  return;
}

sub _transfer_contents {
  my ($self, $input_fh, $output_fh, $source_id) = @_;
  my $counter = 1;
  while(my $line = <$input_fh>) {
    chomp $line;
    my ($upi, $checksum) = split(/\s+/, $line);
    my @output = ($counter++, $source_id, $upi, $checksum);
    print $output_fh join("\t", @output);
    print $output_fh "\n";
  }
  return;
}

sub _load_table {
  my ($self, $file, $verbose) = @_;
  my $dbh = $self->dbi();
  my ($count) = $dbh->selectrow_array('select count(*) from '.$TABLE_NAME);
  if($count) {
    print "'$TABLE_NAME' has rows; truncating\n" if $verbose;
    $dbh->do('truncate table '.$TABLE_NAME);
  }
  print "Loading data into '$TABLE_NAME' from '$file'\n" if $verbose;
  my $load = sprintf(q{LOAD DATA LOCAL INFILE '%s'INTO TABLE %s}, $file, $TABLE_NAME);
  $dbh->do($load);
  print "Finished loading data into '$TABLE_NAME'\n" if $verbose;
  return;
}

1;