Program Konwerter;
Uses FGraphB,speedtpu;
Var x, y: integer;
    pl:String;
Begin
     pl:='start2';
     initfgraph;
     opengfxfile('stadium2.gfx',255,1);
     movebuf2screen;
     for x:=0 to 319 do
     for y:=0 to 199 do if getpixel(x,y,1)=0 then putpixel(x,y,16,1);
     for x:=0 to 319 do
     for y:=0 to 199 do if getpixel(x,y,1)=255 then putpixel(x,y,16,1);
     SaveAsPaintFile(0,0,319,199,'stadiu2.gfx',1);
     readln;
     closefgraph;

End.