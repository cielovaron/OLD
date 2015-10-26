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
	"\t -thr threshold(s) \n".
	"\t -pen penalty \n" .
	"\t -type [0 - 2]\n" .
	"\t \t 0: Log likelihood \t *Default\n" . 
	"\t \t 1: Likelihood ratio \n" .
	"\t \t 2: Log Likelihood ratio \n" .
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
$thr[0] = "";
$thr[1] = "";
$thr_num=0;
$type = 0;
$pen = 0;
$dynamic = 0;
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
    elsif(@ARGV[$i] eq "-thr"){
	$i++;
	$thr[$thr_num] = @ARGV[$i];
	$thr_num++;
    }
    elsif(@ARGV[$i] eq "-pen"){
	$i++;
	$pen = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-type"){
	$i++;
	$type = @ARGV[$i];
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
	$filename= $inDir . "/" . $filenum . "." . $event . ".rec";
	#print "$filename\n";
	$framenum = &GetLikeValue;
    }

    &MakeRatio;

    for($i=0;$i<$enum;$i++){
	$mave[$i] = 0.0;
	&MovingAverage;
	if($thr[0] eq "" ){
	    print $eventname[$i] . "\t" . $mave[$i] . "\n";
	}	
    }
    if($thr[0] eq ""){
	$bgt = $mave[$bgid];
	$thr[0] = $bgt;
	$dynamic = 1;
	$et = $bgt;
    }

    if($thr_num < 2 || $thr[1] eq "v"){
	$dynamic = 1;
    }
    if($outCSV ne ""){
	&MakeCSV;
    }
    if($type == 0){
	$ed = &EventDetection_0;
    }
    else{
	$ed = &EventDetection_1;
    }
    #&FrameDetection;
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

	    if($type ==  0 || $type == 2){
		$temp = $tlike[1];
	    }
	    elsif($type == 1 || $type == 3){
		$temp = exp($tlike[1]);
	    }

	    $elike[$i][$j] = $temp;;
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
    if($j != 0){
	$eave[$i] = $sum / $j;
    }
    else{
	$eava[$i] = 0;
    }
    $emax[$i] = $max;	
    return $j;
}

#######################################
sub MakeRatio{
    for($j=0; $j < $framenum; $j++){
	
	$tsum = 0;
	$tmax = -1000;
	if($type == 1 || $type == 2 ){
	    for($i=0;$i<$enum;$i++){
		$tsum += $elike[$i][$j];
	    }
	}
	elsif($type == 0){
	    $tsum = 1;
	}
	for($i=0;$i<$enum;$i++){
	    $rlike[$i][$j] = $elike[$i][$j]/$tsum;
	}
    }
}
#######################################
sub MovingAverage{
    for($j=0; $j < $framenum; $j++){
	$sum = 0;
	$d = 0;
	for($k= $j - $ma / 2;$k <= $j + $ma/2 && $k < $framenum;$k++){
	    if($k >=0 ){
		$sum += $rlike[$i][$k];
		$d++;
	    }
	}
	$mlike[$i][$j] = $sum / $d;		
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
sub EventDetection_0{
    open(OUT ,"> $eResult");
    open(OUTf ,"> $fResult");

    $tpen = $pen;
    $x=0;
    $csf = 0; $cs = 0; $ce = 0;
    for($i = 0; $i < $framenum-1; $i++){
	#print "$mlike[$bgid][$i] < $thr[0]\n";
	if($mlike[$bgid][$i] < $thr[0]){
	    #print "$mlike[$bgid][$i] < - > $thr[0]\n";
	    $tpen -= abs($thr[0] - $mlike[$bgid][$i]) * 100;
	    if($csf == 0){
		$cs = $i;
	    }
	    $csf++;
	}
	else{
	    $tpen = $pen;
	}

	if($tpen < 0){
	    #print "$i :\t$tpen \n";
	    $vad_start = $cs;
	    $tpen = $pen;
	    $flag = 0;
	    $cef = 0;
	    for($j = $vad_start +1; $j < $framenum; $j++){
		if($mlike[$bgid][$j] > $thr[0]){
		    $tpen -= abs($mlike[$bgid][$j] - $thr[0]) * 100;
		    if($cef == 0){
			$ce = $j;
		    }
		    $cef++;
		}
		else{
		    $tpen = $pen;
		    $cef = 0;
		}

		if($tpen < 0){
		    $flag++;
		    $i = $ce+1;
		    $vad_end = $ce;
		    $j = $framenum;
		}
	    }

	    if($flag == 0){
		$vad_end = $framenum;
		$i = $framenum;

	    }

	    #print "$vad_start < - > $vad_end\n";
	    #print $vad_start / 100 . " " . $vad_end / 100 . "\n";
	    $tpen = $pen;

	    for($j=0; $j < $enum; $j++){
		if($j != $bgid){
		    $csf = 0;
		    $cs = $vad_start;
		    $ce=$vad_end;
		    for($k = $vad_start; $k < $vad_end; $k++){
			if($dynamic == 1){
			    $thr[1] = $mlike[$bgid][$k];
			}
			if($mlike[$j][$k] > $thr[1]){
			    #Start Detect
			    $epen = $pen;
			    $cef = 0; $cs = $k;
			    $bsum = $mlike[$bgid][$k];
			    $esum = $mlike[$j][$k];
			    for($l = $k+1; $l <= $vad_end; $l++){
				$bsum += $mlike[$bgid][$l];
				$esum += $mlike[$j][$l];
				if($dynamic == 1){
				    $thr[1] = $mlike[$bgid][$l];
				}

				if($mlike[$j][$l] < $thr[1]){
				    $epen -= abs($thr[1] - $mlike[$j][$l]) * 100;
				    if($cef == 0){
					$ce = $l;
				    }
				    $cef++;
				}
				else{
				    $epen = $pen;
				    $cef == 0;
				}

				if($epen < 0 || $l == $vad_end){
				    if($l == $vad_end){
					$ce = $vad_end;
				    }
				    if($bsum < $esum && ($ce - $cs) > ($vad_end - $vad_start) / 10){
					#print $cs . "\t" . $ce . "\t" . $eventname[$j] . "\n";
					#print $k . "\t" . $l . "\t" . $eventname[$j] . "\n";
					print OUT $cs/100 . "\t" . $ce/100 . "\t" . $eventname[$j] . "\n";
					for($m=$cs; $m < $ce; $m++){
					    print OUTf $m/100 . "\t" . ($m+1)/100 . "\t" . $eventname[$j] . "\n";
					}
				    }
				    $l = $vad_end+1;
				    $k = $ce;
				}
			    }
			}
		    }
		}
	    }
	}
    }

    close(OUT);
    close(OUTf);
    return $x;
}

###################################################
sub EventDetection_1{
    open(OUT ,"> $eResult");
    open(OUTf ,"> $fResult");

    $tpen = $pen;
    $x=0;
    $csf = 0; $cs = 0; $ce = 0;
    for($i = 0; $i < $framenum-1; $i++){
	#print "$mlike[$bgid][$i] < $thr[0]\n";
	if($mlike[$bgid][$i] < $thr[0]){
	    #print "$mlike[$bgid][$i] < - > $thr[0]\n";
	    $tpen -= abs($thr[0] - $mlike[$bgid][$i]) * 100;
	    if($csf == 0){
		$cs = $i;
	    }
	    $csf++;
	}
	else{
	    $tpen = $pen;
	}

	if($tpen < 0){
	    #print "$i :\t$tpen \n";
	    $vad_start = $cs;
	    $tpen = $pen;
	    $flag = 0;
	    $cef = 0;
	    for($j = $vad_start +1; $j < $framenum; $j++){
		if($mlike[$bgid][$j] > $thr[0]){
		    $tpen -= abs($mlike[$bgid][$j] - $thr[0]) * 100;
		    if($cef == 0){
			$ce = $j;
		    }
		    $cef++;
		}
		else{
		    $tpen = $pen;
		    $cef = 0;
		}

		if($tpen < 0){
		    $flag++;
		    $i = $ce+1;
		    $vad_end = $ce;
		    $j = $framenum;
		}
	    }

	    if($flag == 0){
		$vad_end = $framenum;
		$i = $framenum;

	    }

	    #print "$vad_start < - > $vad_end\n";
	    #print $vad_start / 100 . " " . $vad_end / 100 . "\n";
	    $tpen = $pen;

	    for($j=0; $j < $enum; $j++){
		if($j != $bgid){
		    $csf = 0;
		    $cs = $vad_start;
		    $ce=$vad_end;
		    for($k = $vad_start; $k < $vad_end; $k++){
			if($dynamic == 1){
			    $thr[1] = $mlike[$bgid][$k];
			}
			if($mlike[$j][$k] > $thr[1]){
			    #Start Detect
			    $epen = $pen;
			    $cef = 0; $cs = $k;
			    $bsum = $mlike[$bgid][$k];
			    $esum = $mlike[$j][$k];
			    for($l = $k+1; $l <= $vad_end; $l++){
				$bsum += $mlike[$bgid][$l];
				$esum += $mlike[$j][$l];
				if($dynamic == 1){
				    $thr[1] = $mlike[$bgid][$l];
				}

				if($mlike[$j][$l] < $thr[1]){
				    $epen -= abs($thr[1] - $mlike[$j][$l]) * 100;
				    if($cef == 0){
					$ce = $l;
				    }
				    $cef++;
				}
				else{
				    $epen = $pen;
				    $cef == 0;
				}

				if($epen < 0 || $l == $vad_end){
				    if($l == $vad_end){
					$ce = $vad_end;
				    }
				    if($bsum < $esum && ($ce - $cs) > ($vad_end - $vad_start) / 10){
					#print $cs . "\t" . $ce . "\t" . $eventname[$j] . "\n";
					#print $k . "\t" . $l . "\t" . $eventname[$j] . "\n";
					print OUT $cs/100 . "\t" . $ce/100 . "\t" . $eventname[$j] . "\n";
					for($m=$cs; $m < $ce; $m++){
					    print OUTf $m/100 . "\t" . ($m+1)/100 . "\t" . $eventname[$j] . "\n";
					}
				    }
				    $l = $vad_end+1;
				    $k = $ce;
				}
			    }
			}
		    }
		}
	    }
	}
    }
    
    close(OUT);
    close(OUTf);
    return $x;
}
