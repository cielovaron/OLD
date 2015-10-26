#!/usr/bin/perl
$rf=0;
$if=0;
$lb = 0;
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
    elsif(@ARGV[$i] eq "-lab"){
	$i++;
	$name = @ARGV[$i];
	$lb=1;
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

if($if == 0 || $rf == 0 || $lb == 0){
    &useage;
}
else
{
    &OutDisplay;
}

sub useage{
    print "入力パラメータが不足しています。\n";
    print "perl EB2.pl \n";
    print "\t -ref [Refference label] * required\n";
    print "\t -in [input label] * required \n";
    print "\t -lab [targe filename] * required \n";
    print "\t -pa [pa info] * opt \n";
    print "\t -pb [pb info] * opt\n";
}

sub LoadRef{
    $c=0;
    open(FH, "< $ref");
    while( $line = <FH> ){
	chomp($line);
	@A=split(/ /, $line);
	$ref[0][$c] = int($A[0]*1000)/1000;
	$ref[1][$c] = int($A[1]*1000)/1000;
	$ref[2][$c] = $A[2];
	if($A[2] ne "bg"){
	    $c++;
	}
    }   
    $GT = $c; 
}

sub LoadInp{
    $c=0;
    open(FH, "< $input");
    while( $line = <FH> ){
	chomp($line);
	@A=split(/ /, $line);
	$input[0][$c] = $A[0];
	$input[1][$c] = $A[1];
	$input[2][$c] = $A[2];
	#print "$input[0][$c] $input[1][$c] $input[2][$c]\n";
	if($A[2] ne "bg"){
	    $c++;
	}
	#$c++;
    }
    $E=$c; 
}

sub OutDisplay{
    $Con = 0;$Coff = 0;$Son = 0;$Soff = 0;
    $Ion = 0;$Ioff = 0; $Don = 0; $Doff = 0;
    $Nref = $GT;$Ndet = $E;
    $Pon = 0; $Poff = 0; $Ron = 0; $Roff = 0; $Fon = 0; $Foff = 0;$AEERon = 0; $AEERoff=0;
    $P_on = 0; $P_off = 0; $R_on = 0; $R_off = 0; $F_on = 0; $F_off = 0;$AEER_on = 0; $AEER_off=0;
    
    
    for($i=0;$i<$GT; $i++){
	for($j=0;$j<$E; $j++){
	    if(abs($ref[0][$i] - $input[0][$j]) <= 0.1){
		if($ref[2][$i] eq $input[2][$j]){
		    $Con++;
		}
		else
		{
		    $Son++;
		}
		if(abs($ref[1][$i] - $input[1][$j]) <= ($ref[1][$i]-$ref[0][$i])/2){
		    if($ref[2][$i] eq $input[2][$j]){
			$Coff++;
		    }
		    else
		    {
			$Soff++;
		    }
		}
		break;
	    }
	}
    }
    
    $Ion = $E - $Son - $Con;
    $Ioff = $E - $Soff - $Coff;
    $Don = $GT - $Con;
    $Doff = $GT - $Coff;
    
    $I_on = $E - $Con;
    $I_off= $E - $Coff;
    $D_on = $GT - $Con;
    $D_off = $GT - $Coff;
    if($I_on < $D_on){
	$S_on = $I_on;
    }
    else{
	$S_on = $D_on;
    }
    if($I_off < $D_off){
	$S_off = $I_off;
    }
    else{
	$S_off = $D_off;
    }

    if($E != 0){
	$Pon = $Con / $E * 100;
	$Poff = $Coff / $E * 100;
	$P_on = $Con / $E * 100;
	$P_off = $Coff / $E * 100;
    }

    $Ron = $Con / $GT * 100;
    $Roff = $Coff / $GT * 100;
    $R_on = $Con / $GT * 100;
    $R_off = $Coff / $GT * 100;

    if(($Ron + $Pon) != 0){
	$Fon = 2 * $Ron * $Pon / ($Ron + $Pon);
    }

    if(($Roff + $Poff) != 0){
	$Foff = 2 * $Roff * $Poff / ($Roff + $Poff);
    }

    if(($R_on + $P_on) != 0){
	$F_on = 2 * $R_on * $P_on / ($R_on + $P_on);
    }

    if(($R_off + $P_off) != 0){
	$F_off = 2 * $R_off * $P_off / ($R_off + $P_off);
    }

    $AEERon = ($Ion + $Don + $Son) / $GT;
    $AEERoff = ($Ioff + $Doff + $Soff) / $GT;
    $AEER_on = ($I_on + $D_on + $S_on) / $GT;
    $AEER_off = ($I_off + $D_off + $S_off) / $GT;
    
    #Display style
    #print "FILE , Type ,  pa,  pb,  NREF,  Ndet,  Con,  Ion,  Son,  Don,  Pon,  Ron,  Fon,  AEERon,  Coff,  Ioff,  Soff,  Doff,  Poff,  Roff,  Foff,  AEERoff\n";
    print "$name, USUAL, $pa, $pb, $Nref, $Ndet, $Con, $Ion, $Son, $Don, $Pon, $Ron, $Fon, $AEERon, $Coff, $Ioff, $Soff, $Doff, $Poff, $Roff, $Foff, $AEERoff\n";
    print "$name, IEEE, $pa, $pb, $Nref, $Ndet, $Con, $I_on, $S_on, $D_on, $P_on, $R_on, $F_on, $AEER_on, $Coff, $I_off, $S_off, $D_off, $P_off, $R_off, $F_off, $AEER_off\n";
    
}
