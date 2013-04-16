package Bio::EnsEMBL::Compara::Production::EPOanchors::LoadAnchorSequence;



use strict;
use warnings;
use Data::Dumper;
use Bio::EnsEMBL::Hive::Process;
use Bio::EnsEMBL::Registry;

use base ('Bio::EnsEMBL::Compara::RunnableDB::BaseRunnable');

sub fetch_input {
	my ($self) = @_;
	my $trimmed_anchor_mlssid = $self->param('input_method_link_species_set_id');
	my $anchor_id = $self->param('anchor_id');
	my $anchor_align_adaptor = $self->compara_dba()->get_adaptor("AnchorAlign"); 
	my $dnafrag_adaptor = $self->compara_dba()->get_adaptor("DnaFrag");
	my $anchors = $anchor_align_adaptor->fetch_all_by_anchor_id_and_mlss_id($anchor_id, $trimmed_anchor_mlssid);
	my @anchor;
	foreach my $anchor_align_id(keys %$anchors){
		my($df_id,$anc_start,$anc_end,$df_strand)=($anchors->{$anchor_align_id}->{'dnafrag_id'},
							$anchors->{$anchor_align_id}->{'dnafrag_start'},
							$anchors->{$anchor_align_id}->{'dnafrag_end'},
							$anchors->{$anchor_align_id}->{'dnafrag_strand'});
		my $dnafrag = $dnafrag_adaptor->fetch_by_dbID($df_id);
		my ($df_start,$df_end)=($dnafrag->start,$dnafrag->end);
		my ($max_anc_seq_size, $min_anc_seq_size) = ($self->param('max_anchor_seq_len'), $self->param('min_anchor_seq_len'));
		my $mid_size = $max_anc_seq_size / 2;
		$anc_start -= $mid_size + 1;
		$anc_end += $mid_size - 1;
		$anc_start = $anc_start < $df_start ? $df_start : $anc_start;
		$anc_end = $anc_end > $df_end ? $df_end : $anc_end;
		my $anc_seq = $dnafrag->slice->sub_Slice($anc_start,$anc_end,$df_strand)->seq;
		my @NS=$anc_seq=~/(N)/g;
		my $ns=join("",@NS);
		my $ratio = 0;
		if($ns){
			$ratio = length($ns)/length($anc_seq);
		}
		if($ratio < 0.2) {
			push(@anchor, [$anchor_id, $df_id, $anc_start, $anc_end, $df_strand, $trimmed_anchor_mlssid, $anc_seq]); 
		}
	}
	$self->param('anchor', \@anchor);
}

sub write_output {
	my ($self) = @_;
	my $anchor_seq_adaptor = $self->compara_dba()->get_adaptor("AnchorSeq");
	foreach my $this_anchor(@{ $self->param('anchor') }){
		$anchor_seq_adaptor->store( @{ $this_anchor } );
	}
}

1;


