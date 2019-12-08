# TeXKalender
Ein Wochenkalender mit TeX

Published under GPL 3.0 by Robert C. Helling (helling@atdotde.de)

The creates a personak weekly agenda in TeX. I wrote this for my own use so many things are still quite rough but I have been creating calenders with this code (and its predecessors in GfA Basic and C) since about 1995.

The calendars produced are in German. Replacing the few German words shouldn't be too hard, adopting other conventions like weeks starting on Sunday might be more envolved.

Usage: Fill in dates in a .inp file (like the proviced example2020.inp). Each entry is three lines, the first containing the day (1-31), the second the month (1-12), the third the text for the entry in TeX format. Entries starting with a `*` are birthdays, entries starting with `$\infty$` are marriages and `$\dag$` deaths.
The file has to end with an entry

    0
    0 
    FILEENDE

Then you have to process it in several steps (going via postscript is required to get the colors right, yes all this is a bit legathy). The first argument to kalender.pl is the year:

    ./kalender.pl 2020 example2020.inp > example2020.tex
    tex example2020.tex
    dvips example2020.dvi 
    pstopdf example2020.ps 

All calendrical calculations for holidays like Easter etc are inspired by the wonderful book ["Calendrical Calculations"](https://www.cs.tau.ac.il/~nachum/calendar-book/third-edition/) by Dershowitz and Reingold.
