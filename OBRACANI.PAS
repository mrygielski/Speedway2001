{ Rotate Picture }

uses fgraphb;

Type TCar = Array[1..60,1..15,1..15] of byte;

var I,J,N,X,Y:integer;
    R:real;
    A:array[0..900] of byte;
    ii:integer;
    car:^TCar;
    samochod: String;

    xx,yy:integer;
    x1,x2,y1,y2:integer;
    klatka,nrk:byte;

    maxx,maxy:byte;

    F: File of TCar;

const rad = pi/180;

Procedure LoadPaintFile(plik:String);
var f:File;
    b,rx,ry:Byte;
    xx,yy:integer;
    buf:array[1..321] of byte;
    w,d:Word;
begin
     assign(f,plik);
     reset(F,1);
     blockread(f,buf,2,w);
     blockread(f,a,225,w);
     close(F);
end;

begin
  samochod:='motorb';

  initfgraph;
  new(car);
  loadpaintfile(samochod+'.gfx'); {pickup,police,taxi,viper}
  ii:=0;
  bar(0,0,320,200,31,1);

  x1:=320;y1:=200;x2:=0;y2:=0;
  repeat
    R:=(ii)*rad;
    for I:=0 to 14 do for J:=0 to 14 do begin
      X:=Round(Cos(R)*J-Sin(R)*I);
      Y:=Round(Sin(R)*J+Cos(R)*I);
      PutPixel(160+X,100+Y,A[15*I+J],1);

    end;

      {USTALANIE PROSTOK¤CIKA}
      x1:=320;x2:=0; y1:=200;y2:=0;
      for x:=118 to 202 do for y:=58 to 142 do
       if getpixel(x,y,1)<>31 then if x1>x then x1:=x;
      for x:=118 to 202 do for y:=58 to 142 do
       if getpixel(x,y,1)<>31 then if x2<x then x2:=x;

      for x:=118 to 202 do for y:=58 to 142 do
       if getpixel(x,y,1)<>31 then if y1>y then y1:=y;
      for x:=118 to 202 do for y:=58 to 142 do
       if getpixel(x,y,1)<>31 then if y2<y then y2:=y;
      {PROSTOK¤CIK USTALONY}
      if x2-x1>maxx then maxx:=x2-x1;
      if y2-y1>maxy then maxy:=y2-y1;

{    if x2-x1>30 then putpixel(9,9,4,1);
    if y2-y1>30 then putpixel(9,1,4,1);}  {takie tam dziaˆania profilaktyczne}

{    rectangle(x1,y1,x2,y2,0,1);}
    movebuf2screen;
{    rectangle(x1,y1,x2,y2,31,1); }

    ii:=ii+1; klatka:=klatka+1;


    if klatka=6 then
     begin
          klatka:=0; nrk:=nrk+1;
          x1:=x1-1;y1:=y1-1;
          for x:=1 to 15 do for y:=1 to 15 do
           Car^[nrk,x,y]:=getpixel(x1+x,y1+y,1);
          bar(0,0,50,10,15,1);
          outtextxy(0,0,0,1,1,num2str(ii),1);
     end;
  until ii>=361;


  bar(0,0,320,200,10,1);

  klatka:=1;
  repeat
        for x:=1 to 15 do for y:=1 to 15 do if car^[klatka,x,y]<>31 then putpixel(x,y,car^[klatka,x,y],1);
        movebuf2screen;
        bar(1,1,15,15,10,1);
        klatka:=klatka+1;
        if klatka=61 then klatka:=1;
        delay(10);
  until port[$60]=1;

  Assign(F,samochod+'.car');
  ReWrite(F);
  Write(F,Car^);
  Close(F);



  closefgraph;
  freemem(car,sizeof(TCar));
  Writeln('MAXX: ',maxx,#13#10,'MAXY: ',maxy);
end.