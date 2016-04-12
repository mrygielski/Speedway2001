Program KonVerterTextuRek;
Uses FGraphB;
Var P:Tpaleta;
    pl:String;
Begin
     pl:='start2';
     initfgraph;
     getpal(p);
     loadgif(pl+'.gif',1);
     movebuf2screen;
     ekran2pal(0,0,319,199,p,1);
     setpal(p);
     movebuf2screen;
     SaveAsPaintFile(0,0,319,199,pl+'.gfx',1);
     readln;
     closefgraph;

End.