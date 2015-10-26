#!/usr/bin/perl
$ARGC = @ARGV;
if($ARGC < 2){
    &useage;
    exit;
}
else{
    $rf =0;$in = 0;
    for($k = 0; $k < @ARGV; $k++){
	if(@ARGV[$k] eq "-ref"){
	    $k++;
	    $name = @ARGV[$k];
	    $i=0;
	    $rf = 1;
	    &load;
	    $max[$i] = $c;
	}
	elsif(@ARGV[$k] eq "-in"){
	    $k++;
	    $name = @ARGV[$k];
	    $i = 1;
	    $in = 1;
	    &load;
	    $max[$i] = $c;
	}
	elsif(@ARGV[$k] eq "-lab"){
	    $k++;
	    $lab = @ARGV[$k];
	}
	elsif(@ARGV[$k] eq "-pa"){
	    $k++;
	    $pa = @ARGV[$k];
	}
	elsif(@ARGV[$k] eq "-pb"){
	    $k++;
	    $pb = @ARGV[$k];
	}
    }
}

if($rf != 0 && $in != 0){
    &makeans;
    &run;
}
#print "AEER:\t$AEER\n";
#pod#%
#   サブルーチン
#cut#%

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
    $c=0;
    open(FH, "< $name");
    while($line = <FH>){
	chomp($line);
	@A=split(/\t/,$line);
	if( $i==0 && $A[2] ne "bg" ){	
	    $start[$c]=$A[0];
	    $end[$c] = $A[1];
	    $label[$c]=$A[2];
	    #$frame += int(($end[$c] - $start[$c]) * 100);
	    #print "$start[$c]\t$end[$c]\t$label[$c]\n";
	    #print int(($end[$c] - $start[$c]) * 100) . "\n$label[$c]\n";
	    $c++;
	}
	elsif($i==1 && $A[2] ne "bg"){
	    $res[0][$c]=$A[0];
	    $res[1][$c]=$A[1];
	    #$A[0] = $A[0] *10000;
	    #$A[1] = $A[1] *10000;
	    $res[2][$c]=$A[2];
	    #$res[3][$c]=$A[3];
	    #print "$res[0][$c] $res[1][$c] $res[2][$c]\n";
	    $c++;
	}
    }
#print "$frame\n";
    close(FH);
}


sub makeans{
    $c=0;
    for($i=0;$i<$max[0];$i++){
	$tf = int($end[$i] * 100 + 0.5) - int($start[$i] * 100 - 0.5); 
	for($j=0; $j <= $tf; $j++){
	    $ans[0][$c] = int($start[$i] * 100) / 100 + $j / 100;
	    $ans[1][$c] = int($start[$i] * 100) / 100 + ($j + 1) / 100;
	    $ans[2][$c] = $label[$i];
	    #print "$ans[0][$c] $ans[1][$c] $ans[2][$c]\n";
	    $c++;
	}
    }
    $events = $max[0];
    $max[0] = $c;
    print "$max[0]\n";
    #print $events;
}

sub run{
    $I = 0; $Im = 0; $D = 0; $Dm = 0;$S = 0; $Sm = 0;
    $P = 0; $Pm = 0; $R = 0; $Rm = 0;$C = 0;
    $F = 0; $Fm = 0; $A = 0; $Am = 0;

    for($i=0; $i < $max[0];$i++){
	for($j = 0;$j < $max[1]; $j++){
	    if($ans[0][$i] == $res[0][$j] || $ans[0][$i] eq $res[0][$j]){
		if($ans[2][$i] eq $res[2][$j]){
		    print "$i,$j \t $C $ans[0][$i] \t$ans[2][$i]\n";
		    $C++;
		}
		else{
		    $S++;
		}
		$j = $max[1];
		break;
	    }
	}
    }

    $E = $max[1];
    $GT = $max[0];
    print "$E\n";
    $I = $E - $S - $C;
    if($I < 0){
	$I = 0;
    }
    $Im = $E - $C;
    $D = $max[0] - $C;
    $Dm = $max[0] - $C;

    $Sm = $Dm;
    if($Im < $Dm){
	$Sm = $Im;
    }

    if($E != 0){
	$P = $C / $E * 100;
	$Pm = $P;
    }

    $R = $C / $GT * 100;
    $Rm = $R;

    if(($R + $P) != 0){
	$F = 2 * $R * $P / ($R + $P);
	$Fm = $F;
    }

    $A = ($I + $D + $S) / $GT;
    $Am = ($Im + $Dm + $Sm) / $GT;

    print"FILE , Type ,  pa,  pb, NREF, Ndet,  C,  I,  S,  D,  P,  R,  F,  AEER\n";
    print "$lab, USUAL, $pa, $pb, $GT, $E, $C, $I, $S, $D, $P, $R, $F, $A\n";
    print "$lab, IEEE, $pa, $pb, $GT, $E, $C, $Im, $Sm, $Dm, $Pm, $Rm, $Fm, $Am\n";

}

