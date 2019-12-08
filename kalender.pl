#!/usr/bin/perl

# Nun die dritte Evolutionsstufe: Das Kalenderprogramm in Perl, dass
# jetzt auch die Feiertage selbstaendig berechnen kann.
 
$jahr = $ARGV[0];

my @monat = ("Dezember","Januar","Februar",'M\"arz',"April","Mai",
	     "Juni","Juli","August","September","Oktober",
	     "November", "Dezember");    

my @tim = (31,31,28,31,30,31,30,31,31,30,31,30,31);



my @tag = ("Sonntag","Montag","Dienstag","Mitwoch","Donnerstag",
	  "Freitag","Sonnabend","Sonntag");  
do 'calbook.pl';

$tim[2] = 29 if &gregorian_leap_year($jahr);
  
$reg = 1; # set TeX register counter
$wt = 1;  # calendar always starts on Monday

$start = &kday_on_or_before(&fixed_from_gregorian($jahr,1,1),1);
($year,$month,$day) = &gregorian_from_fixed($start);

($year,$w) = &iso_from_fixed($start);

$t = $day;
$m = $month == 1?1:0;
$tij = $start - &fixed_from_gregorian($jahr-1,12,31);

($year,$wochen) = &iso_from_fixed(&fixed_from_gregorian($jahr,12,28));

#print STDERR "year:$year wochen:$wochen\n";

$tage = &gregorian_date_difference($jahr-1,12,31,$jahr,12,31);
print STDERR "Variablen initialisiert\nLese Feierage\n";

# open (IN, "feiertag.inp") || die "$0: feiertag.inp geht nicht auf:$!";
  
# while(1){
#     $mtag = <IN>;
#     chomp $mtag;
#     $mmonat = <IN>;
#     chomp $mmonat;
#     last unless $mtag>0;
#     $sondertag{"$mtag.$mmonat"} = <IN>;
#     chomp $sondertag{"$mtag.$mmonat"};
# }
# close IN;

&compute_holidays;

print STDERR "Lese persönliche Termine\n";
open(IN, $ARGV[1]) || die "$0: Cannot open $ARGV[1]:$!";

while(1){
    $mtag = <IN>;
    chomp $mtag;
    $mmonat = <IN>;
    chomp $mmonat;
    last unless $mtag>0;
    $memo = <IN>;
    chomp $memo;
    if($memo =~ /\*/){
	$memo = "\\Orange\{$memo\}";
    }
    if($memo =~ /\\dag/){
	$memo = "\\Brown\{$memo\}";
    }

    $memo{"$mtag.$mmonat"} .= "|\\BlueViolet\{$memo\}";
}
close(in);

print STDERR "Erstelle TeX-File\n";

print "\\input kalfor\n\n";
while(1){
    &a(1996);
    &a($w);
    &a($wochen-$w);
    &a($m);
    print "\n";
    for $wt(1..7){
	if($wt==7 || $sondertag{"$t.$m"}){
	    &a('{\Feiertag}');
	}
	else{
	    &a('{\Normaltag}');
	}
	&a($tag[$wt]);
	&a($t);
	&a($tij);
	&a($tage-$tij);
	&a($monat[$m]);
	&a($m);
	my ($nix,$eins,$zwei,$drei) = split /\|/, $memo{"$t.$m"};
	&a($eins);
	&a($zwei);
	&a($drei);
	&a('\Red{'.$sondertag{"$t.$m"}.'}');
	&a("");
	$tij++;
	$t++;
	if($t>$tim[$m]){
	    $m++;
	    if($m==13){
		$m=1;
	    }
	    $t=1;
	}
	print "\n";
    }
    ($year,$w) = &iso_from_fixed(&fixed_from_gregorian($jahr,$m,$t));
    $reg=1;
    print "\\woche\n\n";
    last if $tij>$tage + 31; # Plus Januar des naechsten Jahrs
}
print "\\bye\n";

sub compute_holidays{
    ($year,$month,$day) = &gregorian_from_fixed(&easter($jahr));
    $sondertag{"$day.$month"} = "Ostern";
    ($year,$month,$day) = &gregorian_from_fixed(&easter($jahr)+1);
    $sondertag{"$day.$month"} = "Ostermontag";
    ($year,$month,$day) = &gregorian_from_fixed(&easter($jahr)-2);
    $sondertag{"$day.$month"} = "Karfreitag";

    ($year,$month,$day) = &gregorian_from_fixed(&erster_advent($jahr));
    $sondertag{"$day.$month"} = "1. Advent";
    ($year,$month,$day) = &gregorian_from_fixed(&erster_advent($jahr)+7);
    $sondertag{"$day.$month"} = "2. Advent";
    ($year,$month,$day) = &gregorian_from_fixed(&erster_advent($jahr)+14);
    $sondertag{"$day.$month"} = "3. Advent";
    ($year,$month,$day) = &gregorian_from_fixed(&erster_advent($jahr)+21);
    $sondertag{"$day.$month"} = "4. Advent";


    $sondertag{"24.12"} = "Heilig Abend";
    $sondertag{"25.12"} = "1. Weihnachtstag";
    $sondertag{"26.12"} = "2. Feiertag";
    
    $sondertag{"3.10"} = "Tag d. d. Einheit";
    $sondertag{"1.5"} = "Maifeiertag";
    $memo{"11.11"} .= &color("|Martinstag");
    $sondertag{"31.0"} = "Silvester";
    $sondertag{"1.1"} = "Neujahr";
    $sondertag{"31.12"} = "Silvester";
    $sondertag{"1.13"} = "Neujahr";

    ($year,$month,$day) = &gregorian_from_fixed(&volkstrauertag($jahr));
    $sondertag{"$day.$month"} = "Volkstrauertag";
    
    ($year,$month,$day) = &gregorian_from_fixed(&pentecost($jahr));
    $sondertag{"$day.$month"} = "Pfingsten";
    ($year,$month,$day) = &gregorian_from_fixed(&pentecost($jahr)+1);
    $sondertag{"$day.$month"} = "Pfingstmontag";

    ($year,$month,$day) = &gregorian_from_fixed(&himmelfahrt($jahr));
    $sondertag{"$day.$month"} = "Himmelfahrt";

    ($year,$month,$day) = &gregorian_from_fixed(&rosen_montag($jahr));
    $memo{"$day.$month"} .= &color("|Rosenmontag");
    ($year,$month,$day) = &gregorian_from_fixed(&fastnacht($jahr));
    $memo{"$day.$month"} .= &color("|Fastnacht");
    ($year,$month,$day) = &gregorian_from_fixed(&ascher_mittwoch($jahr));
    $memo{"$day.$month"} .= &color("|Aschermittwoch");

    ($year,$month,$day) = &gregorian_from_fixed(&palmsonntag($jahr));
    $sondertag{"$day.$month"} = "Palmsonntag";

    ($year,$month,$day) = &gregorian_from_fixed(&sommerzeit($jahr));
    $memo{"$day.$month"} .= &color("|Zeitumstellung");
    ($year,$month,$day) = &gregorian_from_fixed(&winterzeit($jahr));
    $memo{"$day.$month"} .= &color("|Zeitumstellung");

    ($year,$month,$day) = &gregorian_from_fixed(&muttertag($jahr));
    $memo{"$day.$month"} .= &color("|Muttertag");

    ($year,$month,$day) = &gregorian_from_fixed(&fronleichnam($jahr));
    $memo{"$day.$month"} .= &color("|Fronleichnam");

    ($year,$month,$day) = &gregorian_from_fixed(&buss_und_bettag($jahr));
    $sondertag{"$day.$month"} = "Bu\\ss- und Bettag";
}




sub a{
    my $s = shift;
    print '\def\reg';
    print chr(97+$reg/10).chr(97+$reg%10);
    $reg ++;

    printf "{$s}";
}

sub color {
    my $memo = shift;

    $memo =~ s/\|/\|\\Maroon\{/;
    return($memo.'}');
}







