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
		@B = split(/\t/,$line);
		$lstart[$c] = $B[0];
		$lend[$c] = $B[1];
		$label[$c] = $B[2];
		print "$B[0] \n";
		#print "$start[$c] $end[$c] $label[$c]\n";
		$c++;
	}    
}

sub export{
    open(FH, "> $output");
    $x=0;
	for($i=0;$i<$c;$i++){
		#print "$start[$i]\t$end[$i]\t$label[$i]\n";
	    $ofs = $lstart[$i];
	    $tf = int($lend[$i] * 100) - int($lstart[$i] * 100) ;
	    for($j = 0;$j <= $tf;$j++){
		$start = (($ofs + $j / 100) * 100) / 100;
		$end = (($ofs + $j / 100 + 0.01) * 100) / 100;
		print "$start\t$end\t$label[$i] $j\n";
		print FH "$start\t$end\t$label[$i]\n";
		$x++;
	    }
	    
	}
    #print $x . "\n";
	close(FH);
}
