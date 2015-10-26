#!/usr/bin/perl
if(@ARGV == 0){
    &how2use;
    exit;
}
sub how2use{
    print "labels.pl \n" .
	"\t -in input dir \n".
	"\t -list listfile \n" .
	"\t -out export dir \n".
	"\t -num number of scripts \n" .
	"\t -com component of gmm \n".
	"\t -thr threshold \n".
	"\t -pen penalty \n" .
	"\t -ma Moving average \n" .
	"\t -f frame result \n" .
	"\t -e event result \n" ;
}
######################################
$fResult = "frame.txt";
$eResult = "event.txt";
$inDir = "";
$outDir = ".";
$list = "";
$outCSV = ".";
$ma = 0;
$thr = "";
$pen = 0;
######################################
for($i=0;$i<@ARGV;$i++){
    if(@ARGV[$i] eq "-in"){
	$i++;
	$inDir = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-list"){
	$i++;
	$listfile = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-out"){
	$i++;
	$outDir = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-num"){
	$i++;
	$filenum = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-com"){
	$i++;
	$com = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-thr"){
	$i++;
	$thr = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-pen"){
	$i++;
	$pen = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-ma"){
	$i++;
	$ma = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-f"){
	$i++;
	$fResult = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-e"){
	$i++;
	$eResult = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-h"){
	&how2use;
	if(@ARGV == 1){
	    exit;
	}
    }
    elsif(@ARGV[$i] eq "-csv"){
	$i++;
	$outCSV = @ARGV[$i];
    }
}
######################################
#Main 
######################################
if($inDir ne "" && $listfile ne ""){
    $enum = &GetEventName;
    for($i=0;$i<$enum;$i++){
	$event = $eventname[$i];
	$filename= $inDir . "/script" . $filenum . ".mfc." . $com . "." . $event . ".rec";
	#print "$filename\n";
	$framenum = &GetLikeValue;
    }
    
    &BLikeValue;

    for($i=0;$i<$enum;$i++){
	$mave[$i] = 0.0;
	&MovingAverage;
	if($thr eq "" ){
	    print $eventname[$i] . "\t" . $mave[$i] . "\n";
	}	
    }
    if($thr eq ""){
	$thr = $mave[$bgid];
    }
    if($outCSV ne ""){
	&MakeCSV;
    }
    $ed = &EventDetection;
    &FrameDetection;
}


######################################
# Functions
######################################
sub GetEventName{
    open (IN, "< $listfile");
    $i=0;
    while($line = <IN>){
	chomp($line);
	$eventname[$i] = $line;
	
	if($line eq "bg"){
	    $bgid = $i;
	}
	$i++;
    }
    close(IN);
    return $i;
}

#######################################
sub GetLikeValue{
    open(IN, "$filename");
    $s=0;
    $j=0;
    $sum=0;
    $max=-1000;
    while($line = <IN>){
	chomp($line);
	if($s > 1 && $line ne "." ){
	    @tlike=split(/$event/, $line);
	    $elike[$i][$j] = $tlike[1];
	    #print "$tlike[1]\n";
	    $sum += $tlike[1];
	    if($max < $tlike[1]){
		$max = $tlike[1];
	    }
	    $j++;
	}
	$s++;
    }
    close(IN);
    $eave[$i] = $sum / $j;
    $emax[$i] = $max;	
    return $j;
}

sub BLikeValue{
    for($i=0;$i<$framenum;$i++){
	$fsum[$i] = 0;
	for($j=0;$j<$enum;$j++){
	    $fsum[$i] += $elike[$j][$i];
	    #print "$elike[$j][$i] ,\t";
	}
	for($j=0;$j<$enum;$j++){
	    $blike[$j][$i] = $elike[$j][$i] / $fsum[$i];
	    #print "$blike[$j][$i] ,\t";
	}
	#print "\n";
    }	
}

#######################################
sub MovingAverage{
    for($j=0; $j < $framenum; $j++){
	$sum = 0;
	$d = 0;
	for($k= $j - $ma / 2;$k <= $j + $ma/2 && $k < $framenum;$k++){
	    if($k >=0 ){
		$sum += $blike[$i][$k];
		$d++;
	    }
	    else{
		$sum += $blike[$i][0];
		$d++;
	    }
	}
	$mlike[$i][$j] = 1-$sum / $d;		
	$mave[$i] += $mlike[$i][$j] / $framenum;
    }
}

#######################################
sub MakeCSV{
    open(OUT , "> $outCSV");
    print OUT ",";
    for($j=0;$j<$enum;$j++){
	print OUT $eventname[$j] . ",";
    }
    print OUT "\n";
    for($i=0;$i<$framenum;$i++){
	print OUT $i . ",";
	for($j=0;$j<$enum;$j++){	
	    print OUT $mlike[$j][$i] . ",";	
	}
	print OUT "\n";
    }
    close(OUT);
}
#######################################
sub EventDetection{
    open(OUT ,"> $eResult");
    $tpen = $pen;
    $x=0;
    for($i=0;$i<$framenum;$i++){
	if($mlike[$bgid][$i] < $thr){
	    #Event Start point
	    $tpen -= $thr*100 - $mlike[$bgid][$i]*100;
	    #$tpen--;
	    #print "A $tpen ". 100*$thr. " - " . 100*$mlike[$bgid][$i] ."\n";
	    if($tpen < 0){
		$start = $i;
		$tpen = $pen;
		#$tpen--;
		$bsum = $mlike[$bgid][$i];
		$flag = 0;

		for($j=$start+1;$j<$framenum;$j++){
		    $bsum += $mlike[$bgid][$j];
		    if($mlike[$bgid][$j] > $thr){
			#print "$mlike[$bgid][$j] \n";
			$tpen -= $mlike[$bgid][$j]*100 - $thr*100;
			#$tpen--;
			#print "\tB $tpen ". 100*$thr. " - " . 100*$mlike[$bgid][$i] ."\n";
			
			if($tpen < 0){
			    #When tpen is minus, it is the end point of event
			    $i = $j;
			    $end = $j;
			    $j = $framenum;
			    $flag++;
			}
		    }
		    else{
			$tpen += $mlike[$bgid][$i]*100 - $thr*100;
			#$tpen++;
			if($tpen > $pen){
			    $tpen = $pen;
			}
		    }
		}
		#for on j
		if($flag == 0){
		    $end = $framenum;
		    $i = $framenum;
		}
		# Detection start
		#print $start/100 . " " . $end/100 . " " . $eventname[$bgid] . " $bsum\n";
		for($j = 0; $j < $enum; $j++){
		    if($j != $bgid){
			$sum[$j] = 0;
			for($k = $start; $k <= $end; $k++){
			    $sum[$j] += $mlike[$j][$k];
			}

			if($sum[$j] > $bsum){
			    print OUT $start/100 . "\t" . $end/100 . "\t" . $eventname[$j] . "\t$sum[$j]\n";
			    #print $start/100 . " " . $end/100 . " " . $eventname[$j] . " $sum[$j]\n";
			    $out[$x][0] = $start/100;
			    $out[$x][1] = $end/100;
			    $out[$x][2] = $eventname[$j];
			    $x++;
			}
		    }
		}
		$tpen = $pen;
	    }
	}
	else{
	    #$tpen++;
	    $tpen += $mlike[$bgid][$i] - $thr;
	    if($tpen > $pen){
		$tpen = $pen;
	    }
	}
    }
    close(OUT);
    return $x;
}

sub FrameDetection{
    open(OUT ,"> $fResult");
    #for($i=0;$i<$framenum;$i++){
	#if($mlike[$bgid][$i] < $thr){
	    #$start = $i / 100;
	    #$end = ($i + 1) /100;
	    #for($j=0;$j<$enum;$j++){

		#if($mlike[$j][$i] > $mlike[$bgid][$i] && $bgid != $j){
		    #print $start. " " . $end . " " . $eventname[$j] . "\n";
		 #   print OUT $start . "\t" . $end . "\t" . $eventname[$j] . "\n";
		#}
	    #}
	#}
    #}
    for($i=0;$i<$x;$i++){
	$num = 100*($out[$i][1] - $out[$i][0]);
	$ofs = $out[$i][0] * 100;
	for($j=0;$j<$num;$j++){
	    $start = ($ofs + $j)/100;
	    $end = ($ofs + $j + 1)/100;
	    print OUT $start . "\t" . $end . "\t" . $out[$i][2] . "\n";
	}
    }
    close(OUT);
}
