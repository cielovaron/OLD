#!/usr/bin/perl


$ARGC = @ARGV;
if($ARGC < 2){
    &useage;
exit;
}
else{
    $frames=0;
    for($i = 0;$i < 2; $i++){
    $name = @ARGV[$i];
    &load;
    $max[$i] = $c;
    }
}
$para = @ARGV[2];

&makeans;

$AEER = &run;

#print "AEER:\t$AEER\n";
=sub#%
    サブルーチン
=cut#%

    sub useage{
	print "使い方\n";
	print "./FrameByFrame.pl CorrectLabel InputLabel OutputFile\n";
	if($ARGC == 0){
	    print "引数なし$ARGC\n";
	}
	elsif($ARGC < 3){
	    print "入力不十分 $ARGC\n";
	}
}

sub load{
=pod#
    i=0
    正解ラベルの読み出し：
  start:開始位置
  end  :終了位置
 lable:割り当てられているラベル
 
 i=1
 結果ラベルの読み出し：result
 0:start
 1:end
 2:label
 3:log likelihood
=cut#%/

$c=0;
open(FH, "< $name");
while($line = <FH>){
    chomp($line);
    @A=split(/\t/,$line);
    if($i==0 && $A[2] ne "bg" ){	
	$start[$c]=int($A[0] * 100) / 100;
	$end[$c]=int($A[1] * 100) / 100;
	$label[$c]=$A[2];
	$frame += int(($end[$c] - $start[$c]) * 100);
	#print "$start[$c] $end[$c] $label[$c]\n";
	$c++;
    }
    elsif($i==1 && $A[2] ne "bg"){
	$res[0][$c]=$A[0];
	$res[1][$c]=$A[1];
	#$A[0] = $A[0] *10000;
	#$A[1] = $A[1] *10000;
	$res[2][$c]=$A[2];
	$res[3][$c]=$A[3];
	#print "$res[0][$c] $res[1][$c] $res[2][$c] $res[3][$c]\n";
	$c++;
    }	
}
close(FH);
}


sub makeans{
    $c=0;
    for($i=0;$i<$max[0];$i++){
	$tf = int(($end[$i] - $start[$i]) * 100); 
	for($j=0;$j<=$tf;$j++){
	    $ans[0][$c] = $start[$i] + $j / 100;
	    $ans[1][$c] = $start[$i] + ($j+1) / 100;
	    $ans[2][$c] = $label[$i];
	    #print "$ans[0][$c] $ans[1][$c] $ans[$c] <- $start[$i] $end[$i] $label[$i]\n";
	    $c++;
	}
    }
    $events = $max[0];
    $max[0] = $c;
}

sub run{
    $I=0;$D=0;$TS=0;$S=0;$C=0;
    $Nref = $max[0];
    for($i=0;$i<$max[0];$i++){
	for($j=0;$j<$max[1];$j++){
	    if($ans[0][$i] == $res[0][$j] && $ans[2][$i] eq $res[2][$j]){
		$C++;
	    }
	}
    }
    
    $D = $Nref - $C;
    $I = $max[1] - $C;

    if($D < $I){
	$S = $D;
    }
    else{
	$S = $I;
    }
    #print "$C $I $D $S $Nref\n";
    $E = $max[1];
    $G = $Nref;
    if($E == 0){
	$P = 0;
    }
    else{
	$P = $C / $E * 100; 
    }

    $R = $C / $G * 100 ; 

    if($P != 0 || $R != 0){
	$F = 2*$P*$R/($P+$R);
    }
    else{
	$F = 0;
    }
    $AER = ($D + $I + $S) / $Nref;
    #print "Collect:$C\tDeltete:$D\tInsertion:$I\tSubstitutions:$S Total Events:$N\tTotal GT:$frame\n";
    #print "Collect:$C\tEstimated:$E\tGroundTruth:$G\n";
    #print "AER:$AER\tPrecision:$P\tRecall:$R\tF-Measure:$F\n";
    print "$para,$AER,$R,$P,$F\n";
    return ($D + $I + $S)/$G;
}

