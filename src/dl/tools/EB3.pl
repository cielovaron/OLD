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
    &OnSet;
    &OnOffSet;
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

sub OnSet{
    $AEER=0;$Cor=0;$F=0;$P=0;$R=0;$S=0;
    $I=0;$D=0;
    
    for($i=0;$i<$enum;$i++){
	#print "$input[0][$i] $input[1][$i] $input[2][$i] \n";
	$dlf = 0; #Delete flag
	$ext = 0;
	for($j=0;$j<$GT;$j++){
	    $start_f = $ref[0][$j] - 100 / 1000;
	    $start_e = $ref[0][$j] + 100 / 1000;
	    
	    if($input[0][$i] <= $start_e && $input[0][$i] >= $start_f){
		#print "$input[0][$i] $input[1][$i] $input[2][$i] \n";
		#print "\t$start_f <-> $start_e \t$ref[2][$j]\n";
		$ext=1;
		if($input[2][$i] eq $ref[2][$j]){
		    $Cor++; $dlf=1;
		}
		else{
		    $S++;
		}
		$j = $GT;
	    }
	}
	if($ext == 0){
	    $I++;
	}
	elsif($ext==1 && $dlf==0){
	    $D++;
	}
	#print "\t$I $D $S $Cor\n";	
    }

    #if($I < $D){
    #	$S = $I;
    #}
    #else{
    #	$S = $D;
    #}
    if(($enum) != 0){
	$P = $Cor / ($enum) * 100;
    }
    $R = $Cor / $GT * 100;
    if($P != 0 || $R != 0){
	$F = 2 * $P * $R / ($P + $R);
    }
    $AEER = ($I + $S + $D) / $GT;
    # "\n$I $D $S $Cor\n";
    print "$pa, $pb, $AEER, $P, $R, $F, ";
}

sub OnOffSet{
    $AEER=0;$Cor=0;$F=0;$P=0;$R=0;$S=0;
    $I=0;$D=0;
    
    for($i=0;$i<$enum;$i++){
	#print "$input[0][$i] $input[1][$i] $input[2][$i] \n";
	$dlf = 0; #Delete flag
	$ext = 0;
	for($j=0;$j<$GT;$j++){
	    $start_f = $ref[0][$j] - 100 / 1000;
	    $start_e = $ref[0][$j] + 100 / 1000;
	    $dur = ($ref[1][$j] - $ref[0][$j])/2;
	    $end_f = $ref[1][$j] - $dur;
	    $end_e = $ref[1][$j] + $dur;
	    if($input[0][$i] <= $start_e && $input[0][$i] >= $start_f && $input[1][$i] <= $end_e && $input[1][$i] >= $end_f){
		#print "$input[0][$i] $input[1][$i] $input[2][$i] \n";
		#print "\t$start_f <-> $start_e \t$ref[2][$j]\n";
		#print "\t$end_f <-> $end_e \t$ref[2][$j]\n";
		$ext=1;
		if($input[2][$i] eq $ref[2][$j]){
		    $Cor++; $dlf=1;
		}
		else{
		    $S++;
		}
		$j = $GT;
	    }
	}
	if($ext == 0){
	    $I++;
	}
	elsif($ext==1 && $dlf==0){
	    $D++;
	}
	#print "\t$I $D $S $Cor\n";	
    }

    #if($I < $D){
    #	$S = $I;
    #}
    #else{
    #	$S = $D;
    #}
    if(($enum) != 0){
	$P = $Cor / ($enum) * 100;
    }
    $R = $Cor / $GT * 100;
    if($P != 0 || $R != 0){
	$F = 2 * $P * $R / ($P + $R);
    }
    $AEER = ($I + $S + $D) / $GT;
    # "\n$I $D $S $Cor\n";
    print "$pa, $pb, $AEER, $P, $R, $F\n";
}
