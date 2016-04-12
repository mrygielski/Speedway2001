uses fGraphb,speedtpu,games;

var x,y:integer;
    c: TCar;
    F: file of tcar;

    Xr, Yr, K : Real;
    XX, YY, Kat : integer;
    szybkosc : word;

    f2 : file of integer;
    r2 : integer;

begin
     assign(f,'motorb.car');
     reset(F);
     read(f,c);
     close(F);

     initfgraph;
     newlayer;
     opengfxfile('trybuny.gfx',255,1);
     for x:=0 to 319 do
     for y:=0 to 199 do if getpixel(x,y,1)=31 then if random(1)=0 then putpixel(x,y,random(255),1);
     opengfxfile('stadium2.gfx',31,1);
     line(160,123,160,179,15,1);
     line(213,123,213,179,15,1);
     line(160,137,150,137,15,1);
     line(160,151,150,151,15,1);
     line(160,165,150,165,15,1);

     initnewkeyint;
     xr:=145;yr:=125;
     k:=90;
     szybkosc:=10;
     assign(f2,'enemy\2e.rec');
     reset(f2);
     repeat
       read(f2,xx,yy,kat);


       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat,x,y]<>31 then putpixel(x+xx,y+yy,c[kat,x,y],2);
       for x:= 1 to 15 do
       for y:= 1 to 15 do
       begin
            if (getpixel(x+xx,y+yy,1)=255) and (getpixel(x+xx,y+yy,2)=55) then
            begin
                 delay(100);
            end;
       end;

       movebuf2screen;

       bar(xx,yy,xx+15,yy+15,255,2);


     until eof(f2);
     close(f2);
     setoldkeyint;

     movebuf2screen;




     closefgraph;
end.