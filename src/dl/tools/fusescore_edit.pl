#!/usr/bin/perl

$d=0;$w=0;
#print "@ARGV\n";
sub use{
    print "-list eventlist \n".
	"-dir directory of rec files \n" .
	"-num filename without \${event}.rec \n" .
	"-w weight \n" .
	"-out out directory\n";
}

for($i=0;$i<@ARGV;$i++){
    if(@ARGV[$i] eq "-dir"){
	$i++;
	$dir_name[$d] = @ARGV[$i];
	$d++;
    }
    elsif(@ARGV[$i] eq "-out"){
	$i++;
	$out_dir = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-list"){
	$i++;
	$listname = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-com"){
	$i++;
	$com = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-w"){
	$i++;
	$weight[$w] = @ARGV[$i];
	$w++;
    }
    elsif(@ARGV[$i] eq "-num"){
	$i++;
	$filenum = @ARGV[$i];
    }
    elsif(@ARGV[$i] eq "-h"){
	&use;
	exit;
    }
}

$enum = &LoadList;
#print "$d\n";

if($w < $d){
    for($i=0;$i<$d;$i++){
	$weight[$i] = 1.0 / $d;
    }
}

for($x=0;$x<$d;$x++){
    #print "$dir_name[$x]\n";
    $did = $x;
    #print "$x/$d\n";
    &LoadLikeValue;
}

for($i=0;$i<$enum;$i++){
    $event = $eventname[$i];
    $filename = $out_dir . "/" . $filenum . "." . $event . ".rec";
    &ExportFile;
}


sub LoadList{
    open(IN, "$listname");
    $i=0;
    while($line = <IN>){
	chomp($line);
	$eventname[$i]=$line;
	#print "$eventname[$i]\n";
	if($line eq "bg"){
	    $bgid = $i;
	}
	$i++;
    }
    close(IN);
    return $i;
}

sub LoadLikeValue{
    for($i=0;$i<$enum;$i++){
	$event = $eventname[$i];
	#64script01.3.3.score.bg.rec
	$filename = $dir_name[$did] . "/" . $filenum . "." . $event . ".rec";
	#system("cat $filename");
	$frames[$did] = &GetLikeValue;
    }
}

sub GetLikeValue{
    $j=0;$s=0;
    open(IN, $filename);
    while($line = <IN>){
	chomp($line);
	if($s > 1 && $line ne "."){
	    @tlike = split(/$event/, $line);
	    #print "$tlike[1]\n";
	    if($did == 0){
		$elike[$i][$j] = 0.0;
	    }
	    $olike[$i][$j][$did] = $tlike[1];
	    $elike[$i][$j] += $weight[$did] * $tlike[1];
	    $j++;
	}
	$s++;
    }
    close(IN);
    return $j;
}

sub ExportFile{
    open(OUT ,"> $filename");
    print OUT "#!MLF!#\n";
    print OUT "\"$filename\"\n";
    for($j=0;$j<$frames[0];$j++){
	$start = $j * 100000;
	$end = ($j + 1 ) * 100000;
	print OUT "$start $end $event $elike[$i][$j] \n";
    }
    print OUT ".\n";
    close(OUT);
}
