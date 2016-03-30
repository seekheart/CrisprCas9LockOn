#!/usr/bin/perl
#@AUTHORS - Mike Tung, Meryl Stav
use warnings;
use strict;
use feature qw(say);
use Bio::SeqIO;
use Getopt::Long;
use Pod::Usage;


#Make Options
my $fastaFile;
my $cas9;
my $guideFile;
my $usage = "\n$0\n
Options     Description
-fasta      Fasta File to search
-cas9       Specify Strain(s) Cas9 to Use
-guide      Guide RNA File
-help       Show this message
";

GetOptions(
	"fasta=s"       =>      \$fastaFile,
	"cas9=s"        =>      \$cas9,
	"guide=s"      =>      \$guideFile,
	"help"              =>      sub{pod2usage($usage);},
	  ) or die "$usage";

unless($fastaFile and $cas9 and $guideFile){
	die "Error!!\n$usage"
}

#Subroutines
sub processFasta{
	my ($fasta) = @_;
	my @sequence = ();

#make bioseqIO object to house fasta then get_sequence()
	my $seqIn = Bio::SeqIO->new(   -file => $fasta,
			-format => 'Fasta');
#process the seq object
	while (my $seq = $seqIn->next_seq()){
		@sequence = split("", $seq->seq()) ;
	}
	my $seq = join('', @sequence);
	return $seq;
}

sub reverseComplement{
	my ($seq) = @_;
	my @sequence = split("", $seq);
	my @newSeq = ();
	foreach my $nucleotide (@sequence){
		chomp $nucleotide;
		if ($nucleotide eq "A"){
			push @newSeq, "T";
		}
		elsif($nucleotide eq "T"){
			push @newSeq, "A";
		}
		elsif($nucleotide eq "C"){
			push @newSeq, "G";
		}
		else{
			push @newSeq, "C";
		}
	}
	@newSeq = reverse(@newSeq);
	return @newSeq;
}

sub main{
	#load the sequence to be analyzed
	my $sequence = processFasta($fastaFile);

	#Hash of Cas9 Variants and their respective PAM Sites
	my %cas9 = (    "SP"		=> 	("NGG"),
			"SP D1135E"	=> 	("NGG", "NAG"),
			"SP VRER"	=> 	("NGCG"),
			"SP EQR"	=> 	("NGAG"),
			"SP VQR"	=> 	("NGAN", "NGNG"),
			"SA"		=> 	("NNGRRT", "NNGRR", "NNGRRN"),
			"NM"		=> 	("NNNNGATT"),
			"ST"		=> 	("NNAGAAW"),
			"TD"		=> 	("NAAAAC"),
		   );

	#IUPAC Nucleotide Code
	my %code = (
			"A"	=>	"A",
			"C"	=>	"C",
			"G"	=>	"G",
			"T"	=>	"T",
			"R"	=>	"[AG]",
			"Y"	=>	"[CT]",
			"S"	=>	"[CG]",
			"W"	=>	"[AT]",
			"K"	=>	"[GT]",
			"M"	=>	"[AC]",
			"B"	=>	"[CGT]",
			"D"	=>	"[AGT]",
			"H"	=>	"[ACT]",
			"V"	=>	"[ACG]",
			"N"	=>	"[AGCT]",
		   );

	#Process the sGRNA file in to array of guides
	my @guides;
	open(my $fh, "<", $guideFile) or die "Couldn't Open File!";
	while (<$fh>) {
		chomp;
		push @guides, join("", $_);
	}

	#make an array of rev complemented guide RNAs
	my @targets = ();
	my $tmp;
	foreach my $sgRNA (@guides){
		chomp $sgRNA;
		$tmp = join("", reverseComplement($sgRNA));
		push @targets, $tmp;
	}

	 # say join("\n", @guides); #sanity check
	 # say join("\n",@targets); #sanity check

	 #Check the fasta for possible hits (+ strand)
	 my $pos = 0;

	 foreach my $target (@targets){
	 	$pos = 0;
	 	 foreach (split /($target)/i  => $sequence){
	 	 	say "Sequence Found at pos: $pos" if uc eq uc $sequence;
	 	 	$pos += length;
	 	 }}


}


###TODO###
# Check Fasta sequence for location of Crispr/Cas9
# Function to look for hybrid sites of guides and check PAM

#run
main();
