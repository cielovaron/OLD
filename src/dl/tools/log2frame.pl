#!/usr/bin/perl

for($i = 0; $i < @ARGV; $i++){
	if($ARGV[$i] eq "-i"){
		$i++;
		$input = @ARGV[$i];
	}
	if($ARGV[$i] eq "-o"){
		$i++;
		$output = @ARGV[$i];
	}
}

&gettime;
&export;

sub gettime{
	$c=0;
	open(FH, "< $input");
	while( $line = <FH> ){
		chomp($line);
		@A=split(/\(/, $line);
		$start[$c] = $c/100;
		$end[$c] = ($c + 1)/100;
		@B=split(/\)/, $A[1]);
		$label[$c] = $B[0];
		#print "$B[0] \n";
		#print "$start[$c] $end[$c] $label[$c]\n";
		$c++;
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
