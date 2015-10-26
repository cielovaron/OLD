#!/usr/bin/perl

$rf=0;
$if=0;
for($i=0; $i < @ARGV; $i++){
	if(@ARGV[$i] eq "-ref"){
		$i++;
		$ref = @ARGV[$i];
		&LoadRef;
		$rf=1;
	}
	elsif(@ARGV[$i] eq "-in"){
		$i++;
		$input=@ARGV[$i];
		&LoadInp;
		$if=1;
	}
	elsif(@ARGV[$i] eq "-pa"){
		$i++;
		$pa=@ARGV[$i];
	}
	elsif(@ARGV[$i] eq "-pb"){
		$i++;
		$pb=@ARGV[$i];
	}
}

if($if == 0 || $rf == 0){
	&useage;
}
else
{
    &calc_rate;
}

sub useage{
	print "入力パラメータが不足しています。\n";
	print "perl EB2.pl \n";
	print "\t -ref [Refference label] * required\n";
	print "\t -in [input label] * required \n";
	print "\t -pa [pa info] * opt \n";
	print "\t -pb [pb info] * opt\n";
}

sub LoadRef{
	$c=0;
	open(FH, "< $ref");
	while( $line = <FH> ){
		chomp($line);
		@A=split(/\t/, $line);
		$ref[0][$c] = int($A[0]*100)/100;
		$ref[1][$c] = int($A[1]*100)/100;
		$ref[2][$c] = $A[2];
		$c++;
	}   
	$GT=$c; 
}

sub LoadInp{
	$c=0;
	open(FH, "< $input");
	while( $line = <FH> ){
		chomp($line);
		@A=split(/\t/, $line);
		$input[0][$c] = $A[0];
		$input[1][$c] = $A[1];
		$input[2][$c] = $A[2];
		#print "$input[0][$c] $input[1][$c] $input[2][$c]\n";
		$c++;
	}
	$enum=$c; 
}

sub calc_rate{
    $PreOn = 0; $RecallOn = 0;
    $PreOff = 0; $RecallOff = 0;
    $FOn = 0; $FOff=0;
    $NCorOn = 0;
    $NCorOff = 0;
    $eps = 0;
    for($i=0;$i<$GT;$i++){
	for($j=0;$j<$enum;$j++){
	    if((abs($input[0][$j] - $ref[0][$i]) <= 0.1) && $ref[2][$i] eq $input[2][$j]){
		$NCorOn++;
		if(abs($input[1][$j] - $ref[1][$i]) <= ($ref[1][$i] - $ref[0][$i]) * 0.5){
		    $NCorOff++;
		    break;
		}
	    }
	}
    }
    
#Compute On-set only
    $NfpOn= $enum - $NCorOn;
    $NfnOn = $GT - $NCorOn;
    if($NfpOn < $NfnOn){
	$NSubsOn = $NfpOn;
    }
    else{
	$NSubsOn = $NfnOn;
    }
    $RecallOn = $NCorOn / ($GT + $eps) * 100;
    if($enum > 0){
	$PreOn = $NCorOn / ($enum + $eps) * 100;
    }
    if(($PreOn + $RecallOn) > 0 ){
	$FOn = $RecallOn * $PreOn * 2 / ($RecallOn + $PreOn + $eps);
    }
    $AeerOn = ($NfpOn + $NfnOn + $NSubsOn ) / ($GT+$eps);
#Compute On-set only
    $NfpOff= $enum - $NCorOff;
    $NfnOff = $GT - $NCorOff;
    if($NfpOff < $NfnOff){
	$NSubsOff = $NfpOff;
    }
    else{
	$NSubsOff = $NfnOff;
    }
    $RecallOff = $NCorOff / ($GT + $eps) * 100;
    if($enum > 0){
	$PreOff = $NCorOff / ($enum + $eps) * 100;
    }
    if(($PreOff + $RecallOff) > 0 ){
	$FOff = $RecallOff * $PreOff * 2 / ($RecallOff + $PreOff + $eps);
    }
    $AeerOff = ($NfpOff + $NfnOff + $NSubsOff ) / ($GT+$eps);
    
    print "$pa, $pb, $AeerOn, $PreOn, $RecallOn, $FOn, ,";
    print "$pa, $pb, $AeerOff, $PreOff, $RecallOff, $FOff,\n";
}

