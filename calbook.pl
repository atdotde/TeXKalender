#!/usr/bin/perl

use POSIX qw(floor);

($sunday,$monday,$tuesday,$wednesday,$thursday,$friday,$saturday) = 0..6;

$gregorian_epoch = 1;

sub gregorian_leap_year{
    
    my $g_year = shift;

    return (($g_year % 4) == 0 and ($g_year % 400) !~ /100|200|300/);
}


sub fixed_from_gregorian{
    
    my ($year,$month,$day) = @_;


    return($gregorian_epoch -1 +365 * ($year-1) + &floor(($year-1)/4) - 
	   &floor(($year-1)/100) + &floor(($year-1)/400)+
	   &floor((367*$month-362)/12) + ($month<=2?0:
					  (&gregorian_leap_year($year)?-1:-2))
	   +$day);
}

sub gregorian_year_from_fixed{
    my $date = shift;


    my $d0 = $date -$gregorian_epoch;

    my $n400 = &floor($d0/146097);
    
    my $d1 = $d0 % 146097;

    my $n100 = &floor($d1 /36524);
    
    my $d2 = $d1 % 36524;

    my $n4 = &floor($d2/1461);

    my $d3 = $d2 % 1461;

    my $n1 = &floor($d3/365);

    my $year = 400 * $n400 + 100 * $n100 + 4 * $n4  + $n1;

    return($n100 == 4 || $n1 == 4? $year : $year+1);
}

sub gregorian_from_fixed{
    my $date = shift;

    my $year = &gregorian_year_from_fixed($date);
    
    my $prior_days = $date-&fixed_from_gregorian($year,1,1);

    my $correction = $date<&fixed_from_gregorian($year,3,1) ?
      0:(&gregorian_leap_year($year)?1:2);
    
    my $month = &floor((12*($prior_days+$correction)+373)/367);

    my $day = $date - &fixed_from_gregorian($year,$month,1)+1;

    return(($year,$month,$day));

}

sub floor{
    return(POSIX::floor(shift));

}	 
			     
sub gregorian_date_difference{
    my ($year1,$month1,$day1,$year2,$month2,$day2) = @_;

    return(&fixed_from_gregorian($year2,$month2,$day2)-
	   &fixed_from_gregorian($year1,$month1,$day1));
}

sub day_number{
    my ($year,$month,$day) = @_;
    
    return(&gregorian_date_difference($year-1,12,31),@_);
}

sub days_remaining{
    my ($year,$month,$day) = @_;

    return(&gregorian_date_difference(@_,$year,12,31));
}

sub day_of_week_from_fixed{
    return(shift() % 7);
}

sub kday_on_or_before{
    my ($date,$k) = @_;

    return($date -&day_of_week_from_fixed($date-$k));
}

sub kday_on_or_after{
    my ($date,$k) = @_;

    return(&kday_on_or_before($date+6,$k));
}

sub kday_nearest{
    my ($date,$k) = @_;

    return(&kday_on_or_before($date+3,$k));
}

sub kday_before{
    my ($date,$k) = @_;

    return(&kday_on_or_before($date-1,$k));
}

sub kday_after{
    my ($date,$k) = @_;

    return(&kday_on_or_before($date+7,$k));
}

sub nth_kday{

    my ($n,$k,@gdate) = @_;

    return($n>0 ? 7 * $n + &kday_before(&fixed_from_gregorian(@gdate),$k) :
	   7 * $n + &kday_after(&fixed_from_gregorian(@gdate),$k));
}

sub heilig_abend{
    my $year = shift;
    
    return(&fixed_from_gregorian($year,12,24));
}

sub erster_advent{
    my $year = shift;

    return(&kday_nearest(&fixed_from_gregorian($year,11,30),$sunday));
}

sub volkstrauertag{
    return(&erster_advent(shift) - 14);
}

sub fixed_from_iso{
    my ($year,$week,$day) = @_;

    return(&nth_kday($week,$sunday,$year-1,12,28)+$day);
}

sub iso_from_fixed{
    my $date = shift;

    my $approx = &gregorian_year_from_fixed($date-3);

    my $year = $date >= &fixed_from_iso($approx+1,1,1)? $approx+1:$approx;

    my $week = &floor(($date-&fixed_from_iso($year,1,1))/7)+1;

    my $day = $date % 7;

    return(($year,$week,$day));
}

sub easter{
    my $gyear = shift;

    my $century = &floor($gyear/100)+1;
    
    my $shifted_epact = (14+11*($gyear % 19) -
			 &floor(3*$century/4)+
			 &floor((5+8*$century)/25)) % 30;

    my $adjusted_epact = $shifted_epact;
    if($shifted_epact == 0 or ($shifted_epact == 1 and 10<($gyear %10))){
	$adjusted_epact++;
    }

    my $paschal_moon = &fixed_from_gregorian($gyear,4,19)-$adjusted_epact;

    return(&kday_after($paschal_moon,$sunday));
}

sub ostermontag{
    return(&easter(shift) + 1);
}

sub karfreitag{
    return(&easter(shift) -2);
}

sub pentecost{
    return(&easter(shift) + 49);
}

sub himmelfahrt{
    return(&easter(shift) + 39);
}

sub rosen_montag{
    return(&easter(shift) - 48);
}
sub fastnacht{
    return(&easter(shift) -47);
}

sub ascher_mittwoch{
    return(&easter(shift) - 46);
}
sub palmsonntag{
    return(&easter(shift) -7);
}

sub daylight_saving_start{
    return(&nth_kday(1, $sunday,shift, 4,1));
}

sub sommerzeit{
    return(&nth_kday(-1,$sunday,shift, 3,31));
}

sub winterzeit{
    return(&nth_kday(-1,$sunday,shift, 10,31));
}


sub print_gregorian{
    my ($year,$month,$day) = &gregorian_from_fixed(shift);

    return("$day.$month.$year");
}

sub muttertag{
    my $year = shift;

    return(&nth_kday(2,$sunday,$year,5,1));
}
	      
sub fronleichnam{
    return(&easter(shift)+60);
}

sub buss_und_bettag{
    return(&erster_advent(shift)-11);
}
