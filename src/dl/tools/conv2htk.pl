#!/usr/bin/perl

$input = @ARGV[0];
$output= @ARGV[1];

&gettime;
&export;

sub gettime{
	$c=0;
	$i=0;
	open(FH, "< $input");
	while( $line = <FH> ){
		chomp($line);
		if($i > 1 && $line ne "."){
			chomp($line);
			@A=split(/ /, $line);
			$start[$c] = int($A[0] / 10000) / 1000;
			$end[$c] = int($A[1] / 10000) / 1000;
			$label[$c] = $A[2];
			if($A[2] ne "bg" ){
				#print "$start[$c] $end[$c] $label[$c]\n";
				$c++;
			}
		}
		$i++;
	}    
}

sub export{
	open(FH, "> $output");
	for($i=0;$i<$c;$i++){
		#print "$start[$i]\t$end[$i]\t$label[$i]\n";
		print FH "$start[$i]\t$end[$i]\t$label[$i]\n";
	}
	close(FH);
}