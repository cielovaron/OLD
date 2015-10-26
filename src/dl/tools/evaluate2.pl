#/usr/bin/perl

$framecsv = "";
$eventcsv = "";

for($i=0;$i<@ARGV;$i++){
    if(@ARGV[$i] eq "-frame"){
	$i++;
	$framecsv = @ARGV[$i];
	#print "$framecsv\n";
    }	
    if(@ARGV[$i] eq "-event"){
	$i++;
	$eventcsv = @ARGV[$i];
	#print "$eventcsv\n";
    }
    if(@ARGV[$i] eq "-kind"){
	$i++;
	$kind = @ARGV[$i];
    }
}

if($framecsv eq "" || $eventcsv eq ""){
    &usage;
    exit;
}

else{
    &getKind;
    &getFrameCSV;
    &getEventCSV;
    &Analyse;
}

sub usage{
    print "perl evaluate.pl \n";
    print "\t -frame [framecsv]\n";
    print "\t -event [eventcsv]\n";
}

sub getKind{
    if($kind == 0){
	$knum = 3;
	$n=0;
	for($k=1; $k <= $knum; $k++){
	    $type[$k-1] = "script0" . $k;
	    #print $type[$k-1] . "\n";
	    $n++;
	}
    }

    if($kind == 1){
	$knum = 3;
	
	for($k=0; $k < $knum; $k++){
	    $snr = 6 - ($k) * 6;
	    $def = "office_snr" . $snr;
	    $type[$n] = $def . "_low";
	    #print $type[$n] . "\n";
	    $n++;
	    $type[$n] = $def . "_med";
	    #print $type[$n] . "\n";
	    $n++;
	    $type[$n] = $def . "_high";
	    #print $type[$n] . "\n";
	    $n++;
	}
    }
    $kinds = $n;
}
sub getFrameCSV{
    open(FH, "< $framecsv");
    $j=0;

    for($i=0;$i<$n;$i++){
	$fmax[$i] = 0;
	$fp[$i] = 0;
    }

    $x=0;
    while($line = <FH>){
	chomp($line);
	@A = split(/\,/ ,$line);
	if($j > 0){
	    #print $line . "\n";
	    for($y=0;$y<$n;$y++){
		if(@A[0] eq $type[$y]){
		    #print @A[0] . " \t" . $type[$y] . "\n";
		    $knum = $y;
		    break;
		}
	    }
	    for($y = 0; $y < @A; $y++){
		$fvalue[$x][$y] = @A[$y];
		#
		#print $value[$x][$y] . " ";
	    }
	    if($fvalue[$x][13] > $fmax[$knum]){
		$fmax[$knum] = $fvalue[$x][13];
		$fp[$knum] = $x;
	    }
	    #print "\n";
	    $x++;
	}
	$j++;
    }
    #for($i=0;$i<$n;$i++){
    #	print "$fp[$i] - $fmax[$i] \n";
    #}
    close(FH);
}

sub getEventCSV{
    open(FH, "< $eventcsv");
    $j=0;

    for($i=0;$i<$n;$i++){
	$emax[$i] = 0;
	$ep[$i] = 0;
    }

    $x=0;
    while($line = <FH>){
	chomp($line);
	@A = split(/\,/ ,$line);
	if($j > 0){
	    #print $line . "\n";
	    for($y=0;$y<$n;$y++){
		if(@A[0] eq $type[$y]){
		    #print @A[0] . " \t" . $type[$y] . "\n";
		    $knum = $y;
		    break;
		}
	    }
	    for($y = 0; $y < @A; $y++){
		$evalue[$x][$y] = @A[$y];
		#
		#print $y . " " . $evalue[$x][$y] . " ";
	    }
	    if($evalue[$x][21] > $emax[$knum]){
		$emax[$knum] = $evalue[$x][21];
		$ep[$knum] = $x;
	    }

	    #print "\n";
	    $x++;
	}
	$j++;
    }
    #for($i=0;$i<$n;$i++){
    #	print "$ep[$i] - $emax[$i] \n";
    #}
    close(FH);
}

sub Analyse{
    $count=0;
    for($i=0;$i<$n;$i++){
	$para[0] = $fvalue[$ep[$i]][2];
	$para[1] = $fvalue[$ep[$i]][3];
	$para[2] = $fvalue[$ep[$i]][4];
	$sum[$i] = 0; $max=0;
	for($j=0;$j<$x;$j++){
	    if($fvalue[$j][2] == $para[0] && $fvalue[$j][3] == $para[1] && $fvalue[$j][4] == $para[2]){
		#print "$fvalue[$j][0] $fvalue[$j][13] $evalue[$j][21]\n";
		$sum[$i] += $evalue[$j][21]
	    }
	} 

	if($max < $sum[$i]){
	    $max = $sum[$i];
	    $pos = $i;
	}
    }

    $i = $pos;
    $para[0] = $evalue[$ep[$i]][2];
    $para[1] = $evalue[$ep[$i]][3];
    $para[2] = $evalue[$ep[$i]][4];
    print "Filename, Kind, Pa, Pb, Pc, Nref, Ndet, Corr, Insert, Sub, Delete, Precision, Recall, F-m, AEEER,Nref, Ndet, Corr, Insert, Sub, Delete, Precision, Recall, F-m, AEEER, Corr, Insert, Sub, Delete, Precision, Recall, F-m, AEEER \n";
    for($j=0;$j<$x;$j++){
	if($fvalue[$j][2] == $para[0] && $fvalue[$j][3] == $para[1] && $fvalue[$j][4] == $para[2]){
	    for($y=0;$y<15;$y++){
		print "$fvalue[$j][$y], ";
	    }
	    for($y=5;$y<23;$y++){
		print "$evalue[$j][$y], ";	
	    }
	    print "\n";
	}
	$count++;
	if($count == $kinds)
	{
	    exit;
	}
    }
}

