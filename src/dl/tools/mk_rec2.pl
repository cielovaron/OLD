#!/usr/bin/perl
######################################
# $inDir	: Directory for input files
# $listfile : list file is wiretten event names.
######################################
#Preset
$inDir="";
$listfile="";
$filenum="";
$ma=0;
$bgt="";
$bgr=1;
$fResult="frame.txt";
$eResult="event.txt";
######################################
for($i = 0; $i < @ARGV; $i++){
	if($ARGV[$i] eq "-d"){
		$i++;
		$inDir = $ARGV[$i];
		#print "Input File Directory:\t" . $inDir . "\n";			

	}
	elsif($ARGV[$i] eq "-l"){
		$i++;
		$listfile = $ARGV[$i];
		#print "listfile:\t" . $listfile . "\n";			

	}
	elsif($ARGV[$i] eq "-m"){
		$i++;
		$ma = $ARGV[$i];
		#print "Smoothing:\t" . $ma . "\n";			
	}
	elsif($ARGV[$i] eq "-n"){
		$i++;
		$filenum = $ARGV[$i];
		#print "Filename:\tscript" . $filenum . "\n";			
	}
	elsif($ARGV[$i] eq "-bgt"){
		$i++;
		$bgt = $ARGV[$i];
		#print "bgt:\t" . $bgt . "\n";			
	}
	elsif($ARGV[$i] eq "-bgr"){
		$i++;
		$bgr = $ARGV[$i]/100;
		#print "Threthold range:\t" . $bgr . "\n";			
	}
	elsif($ARGV[$i] eq "-c"){
		$i++;

		$com = $ARGV[$i];
		#print "Component:\t" . $com . "\n";			
	}
	elsif($ARGV[$i] eq "-f"){
		$i++;
		$fResult = $ARGV[$i];
		#print "FrameResult:\t" . $fResult . "\n";			
	}
	elsif($ARGV[$i] eq "-e"){
		$i++;
		$eResult = $ARGV[$i];
		#print "EventResult:\t" . $eResult . "\n";			
	}
}
######################################
#usage
######################################
if(@ARGV == 0){
	print "-bgr: accept range for detection on loglikelihood \n";
	print "-bgt: threthold for Background sound likehood \n";
	print "-c: Component of gmm*\n";
	print "-d: input directory*\n";
	print "-e: EventBased result\n";
	print "-f: framebased result\n";
	print "-l: list file*\n";
	print "-m: Smoothing parameter\n";
	print "-n: File number, ex) 01, 02 ... *\n";
	exit;
}

######################################
# Program starts from here
######################################
#Read Event list : Return number is the total event number

$enum = &GetEventName;
for($i=0;$i<$enum;$i++){
	$event = $eventname[$i];
	
	$filename= $inDir . "/script" . $filenum . ".mfc." . $com . "." . $event . ".rec";
	#print $filename . "\n";
	$framenum = &GetLikeValue;
}
#
for($x = 0; $x < $enum; $x++){
	$mave[$x] = 0;
	&MovingAverage;
	if($bgt eq ""){
	    print $eventname[$x] . "\t" . $mave[$x] . "\n";
	}
}
&MakeCSV;

if($bgt eq ""){
	$bgt = $mave[$bgid];
}

&FrameDetection;
&EventDetection;

#######################################
# Sub lootine is defined here
#######################################
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
	my $s=0;
	my $j=0;
	my $sum=0;
	my $max=-1000;
	while($line = <IN>){
		chomp($line);
		if($s > 1 && $line != "." ){
			my @tlike=split(/$event/, $line);
			$elike[$i][$j] = $tlike[1];
			$sum += $tlike[1];
			if($max < $tlike[1]){
				$max = $tlike[1];
			}
			$j++;
		}
		$s++;
	}
	close(IN);
	$eave[$i] = $sum/$j;
	$emax[$i] = $max;
	
	return $j;
}

#######################################
sub MakeCSV{
	open(OUT , "> log.csv");
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
sub MovingAverage{
	for(my $i=0; $i < $framenum; $i++){
		$sum = 0;
		$d = 0;

		for(my $j = $i - $ma; $j <= $i + $ma && $j < $framenum; $j++){
			if($j >=0 ){
				$sum += $elike[$x][$j];
				$d++;
			}
		}
		$mlike[$x][$i] = $sum / $d;
		if($i > 0){
			$dif[$x][$i] = $mlike[$x][$i] - $mlike[$x][$i-1];
		}
		else{
			$dif[$x][0] = 0;
		}
		$mave[$x] += $mlike[$x][$i]/$framenum;
	}
}
#######################################
sub FrameDetection{
	open(OUT ,"> $fResult");
	for(my$i = 0; $i < $framenum; $i++){
		if($mlike[$bgid][$i] < $bgt){
			for(my $j = 0; $j < $enum;$j++){
				if($j != $bgid && $mlike[$j][$i] > $mlike[$bgid][$i] * $bgr){
					$start=$i/100;
					$end=($i+1)/100;
					print OUT $start . "\t" . $end . "\t" . $eventname[$j] . "\n";
				}
			}
		}
	}
	close(OUT);
}

sub EventDetection{
	open(OUT ,"> $eResult");
	for(my $i=0; $i < $framenum-1;$i++){
		#無音区間の検出
		if($mlike[$bgid][$i] < $bgt){
			$start = $i;
			$end =-1;
			$bsum = 0;
			$flag = 0;
			for(my $j = $i;$j<$i+10;$j++){
				$bsum += $mlike[$bgid][$j];
			}
			for(my $j = $i + 10; $j < $framenum ;$j++){
				$bsum += $mlike[$bgid][$j];
				if($mlike[$bgid][$j] > $bgt){
					$end = $j;
					$i = $j;
					$j = $framenum;
					#print "$start $end\n";
					$flag++;
				}
			}
			if($end < 0){
				$end = $framenum;
				$i = $framenum;
			}
			$term = $end - $start;
			
			#print $start / 100 . "\t->\t" . $end / 100 . "\t = \t " . $term . "\t". $bsum ."\n";
			for(my $j = 0; $j < $enum; $j++){
				if($j != $bgid){
					$sum[$j] = 0;
					for(my $k = $start; $k <= $end; $k++){
						$sum[$j] += $mlike[$j][$k];
					}
					#print $eventname[$j] . "\t" . $sum[$j] ."\n";
					if($sum[$j] > $bsum * $bgr){
						#print $eventname[$j] . "\t" . $sum[$j] ."\n";
						print OUT $start/100 . "\t" . $end/100 . "\t" . $eventname[$j] . "\n"; 
					}
				}
			}
			#print "\n";
		}
	}
	close(OUT);
}
