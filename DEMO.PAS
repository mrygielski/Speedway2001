uses crt, dos, fgraphb, speedtpu,smix,detect, fxms,games;

var   player1 ,
      player2 ,
      player3 ,
      player4 :string;
      kolor1 ,
      kolor2 ,
      kolor3 ,
      kolor4 : byte;
      animacje_kol : boolean;
      show_fps : boolean;
      szybkosc : byte;
      bieg: byte;
      pozycjay: byte;
      gracz1,gracz2,gracz3,gracz4:string;
      nrtor : byte;

var
    sin_, cos_                          : array[0..360] of real;
    uchwyty                             : array[1..4] of word;
    c                                   : TCar;
    F                                   : file of tcar;
   mx, my : integer;
   p : tpaleta;
   tmouse : byte;
    BaseIO                              : word;
    IRQ, DMA, DMA16                     : byte;
    OldExitProc                         : pointer;
    sound                               : array[0..13] of PSound;

Procedure ObliczanieSinCos;
var x: word;
begin
     for x:=0 to 360 do sin_[x]:=sin(x/57.25);
     for x:=0 to 360 do cos_[x]:=cos(x/57.25);
end;

{prosty debugger i wywalanie ewentualnych bˆ©d¢w na starcie}
Procedure EkranStartowy;
Begin
     Writeln('Starting SPEEDWAY 2001.....');
     Write('Checking XMS driver..... ');
     if xmsinstalled then writeln('OK');
     if not xmsinstalled then begin writeln(#13#10,'You must enable your XMS driver! HIMEM.SYS probably in CONFIG.SYS!');
     Writeln('Just put it into your config.sys file: DEVICE=C:\WINDOWS\HIMEM.SYS');
     Writeln('or: DEVICE=C:\DOS\HIMEM.SYS.');
     halt;
     end;
     Write('Checking free XMS memory..... ',XMemAvail,' Kb.... ');
     If XMemAvail<2000 then begin
        Writeln(#13#10,'For this program you must have minimal 2 Mb XMS memory');
        Writeln('Install more memory!');
        halt;
     end;
     If XMemAvail>=2000 then Writeln('OK!');
     Write('Checking SOUND BLASTER.......');
     If getENV('BLASTER')='' then begin writeln(#13#10'Failed! You must set BLASTER variable in your autoexec.bat file!');
     halt; end;
     If getENV('BLASTER')<>'' then Writeln('Detected!');
     Writeln('SoundBlaster ver. ',SBVersion,' : ',getenv('BLASTER'));
end;



{Wgraj Do XMS motorki}
procedure wgrajdoxms;
var
 i : integer;
begin
     xgetmem(uchwyty[1],sizeof(tcar));
     assign(f,'DATA\motorb.car');
     reset(F);
     read(f,c);
     close(F);
     movetoxms(uchwyty[1],sizeof(tcar),c);
end;

{Wywal z XMS motorki}
procedure wywalzXMS;
begin
     XFreeMem(uchwyty[1]);
end;


procedure OurExitProc; far;
var
   i: byte;
begin
     for i := 0 to 5 do
       if Sound[i] <> nil then FreeSound(Sound[i]);
     ShutdownSharing;
     ExitProc := OldExitProc; {Chain to next exit procedure}
end;

{inicjalizacja d«wi©k¢w i wgrywanie ich do pami©ci}
procedure initsounds;
begin
      GetSettings(BaseIO, IRQ, DMA, DMA16);
      InitSB(BaseIO, IRQ, DMA, DMA16);
      if SixteenBit
        then write(''){16bit}
        else write('');{8 bit}
      if AutoInit
        then {writeln('Auto-initialized')}
        else ;{writeln('Single-cycle');}
      InitMixing;
      InitXMS;
      InitSharing;
      if not(OpenSoundResourceFile('SOUNDS.DAT'))
      then
           begin
                writeln('Sound library file not found!');
                Halt(0);
           end;
      LoadSound(Sound[0], 'DING');
      LoadSound(Sound[1], 'KRZYK1');
      LoadSound(Sound[2], 'KRZYK2');
      LoadSound(Sound[3], 'KRZYK3');
      LoadSound(Sound[4], 'JAZDA');
      LoadSound(Sound[5], 'JAZDA');
      LoadSound(Sound[6], 'JAZDA');
      LoadSound(Sound[7], 'JAZDA');
      LoadSound(Sound[8], 'START');
      LoadSound(Sound[9], 'KRZYK1');
      LoadSound(Sound[10], 'KRZYK2');
      LoadSound(Sound[11], 'KRZYK3');
      LoadSound(Sound[12], 'MUSIC');
      LoadSound(Sound[13], 'CLICK');
      CloseSoundResourceFile;
      OldExitProc := ExitProc;
      ExitProc := @OurExitProc;
end;

{wywalanie d«wi©k¢w z pami©ci}
procedure freesounds;
var i:integer;
begin
      ShutdownMixing;
      ShutdownSB;
      for i := 0 to 13 do FreeSound(Sound[i]);
      ShutdownSharing;
end;




{PONI½EJ WSZYSTKO ZWI¤ZANE Z TRENINGIEM}

Procedure BiegTreningowy;

var x,y:integer;
    Xr, Yr : Real;
    XX, YY, Kat : integer;
    Xr2, Yr2 : Real;
    XX2, YY2, Kat2 : integer;
    Xr3, Yr3 : Real;
    XX3, YY3, Kat3 : integer;
    Xr4, Yr4 : Real;
    XX4, YY4, Kat4 : integer;
    K,K2,K3,K4 : Word;
    gracz1, gracz2, gracz3, gracz4 : string[11];
    f1 : file of integer;
    r1 : integer;
    f2 : file of integer;
    r2 : integer;
    f3 : file of integer;
    r3 : integer;
    f4 : file of integer;
    r4 : integer;
    FPs: FPSCounter;
    status1, status2, status3, status4: string[20];
    czy1,czy2,czy3,czy4: boolean;
    okr1,okr2,okr3,okr4: byte;
    fps_: integer;
    kolorydymu: array[1..3] of byte;
    koniec_biegu: boolean;
    myszx, myszy: word;
    koniec1,koniec2,koniec3,koniec4: boolean;
    poz1,poz2,poz3,poz4,pozycja: byte;


procedure startbiegu;
var czas,r: integer;
begin
     bar(125,70,145,90,22,1);
     bar(170,70,190,90,22,1);
     rectangle(125,70,145,90,15,1);
     rectangle(170,70,190,90,15,1);
     bar(145,70,170,110,22,1);
     rectangle(145,70,170,110,15,1);
     circle(157,77,5,4,1);
     floodfill(157,77,112,1);
     circle(157,90,5,4,1);
     floodfill(157,90,112,1);
     circle(157,103,5,2,1);
     floodfill(157,103,120,1);

     floodfill(157,77,12,1);
     movebuf2screen;

     setcol(0,63,20,0);
     startsound(sound[0],0,false);
     czas:=0;
     repeat
           delay(1);
           czas:=czas+1;
           if czas=200 then setcol(0,0,0,0);
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';

          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=500;
     until czas=500;
     floodfill(157,90,12,1);
     movebuf2screen;
     setcol(0,63,20,0);
     startsound(sound[0],0,false);
     czas:=0;
     repeat
           delay(1);
           czas:=czas+1;
           if czas=200 then setcol(0,0,0,0);
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';
          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=500;
     until czas=500;
     czas:=0;
     randomize;
     r:=random(500);
     repeat
           delay(1);
           czas:=czas+1;
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';
          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=300+r;
     until czas=300+r;
     startsound(sound[0],0,false);
     floodfill(157,103,10,1);
     movebuf2screen;
     setcol(0,0,50,0);
end;

{pokazywanie belki na dole}
procedure ustawtabelke;
procedure tabelka(y : integer);
var
   i : integer;
begin
     for i:= 16 to 31 do
     begin
          line(0,i+y+16,320,i+y+16,47-i,2);
     end;
     line(80,y+32,80,y+48,31,2);
     line(160,y+32,160,y+48,31,2);
     line(240,y+32,240,y+48,31,2);
     outtextxyfnt(5,Y+33,kolor1,6,'TRENING','DATA\small.fn2',norm,2);
     outtextxyfnt(85,Y+33,kolor2,6,'TRENING','DATA\small.fn2',norm,2);
     outtextxyfnt(165,Y+33,kolor3,6,'TRENING','DATA\small.fn2',norm,2);
     outtextxyfnt(245,Y+33,kolor4,6,'TRENING','DATA\small.fn2',norm,2);
end;
var
   x,y : integer;
begin
     if player1='human' then begin xx:=146;yy:=125+((pozycjay-1)*14);xr:=146;yr:=125+((pozycjay-1)*14);kat:=90 div 6;k:=90;end;
       if kolor1=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat,x,y]<>31 then putpixel(x+xx,y+yy,c[kat,x,y],2);
     movebuf2screen;
     y:=170;
     repeat
           y:=y-1;
           tabelka(y);
           movebuf2screen;
           delay(20);
     until y=153;
end;

var graczy:byte;

begin
     show_fps:=false;
     bar(0,0,320,200,0,2);
     outtextxyFNT(110,90,15,8,'WAIT LOADING ...','DATA\SMALL.FN2',bold_italic,2);
     movebuf2screen;
     opengfxfile('GFX\trybuny.gfx',255,1);
     randomize;
     for x:=0 to 319 do
     for y:=0 to 199 do if getpixel(x,y,1)=31 then if random(1)=0 then putpixel(x,y,random(250)+1,1);
     opengfxfile('GFX\stadium1.gfx',31,1);
     line(160,123,160,179,15,1);
     line(213,123,213,179,15,1);
     line(160,137,150,137,15,1);
     line(160,151,150,151,15,1);
     line(160,165,150,165,15,1);
     gracz1:='Tomek';
     kolorydymu[1]:=8{getpixel(160,50,1)};
     kolorydymu[2]:=25{getpixel(50,100,1)};
     kolorydymu[3]:=185{getpixel(300,78,1)};
     status1:='jedzie';
     okr1:=0;
     if show_fps then fps.start;
     filllayer(255,2);
     ustawtabelke;
     startsound(sound[8],8,false);
     windows(0,0,319,184);
     stopsound(8);
     if status1='jedzie' then startsound(sound[4],4,true);
     pozycja:=1;
     poz1:=0;
     koniec_biegu:=false;
     koniec1:=false;
     czy1:=false;
     startbiegu;
     repeat
       myszx:=mousex;myszy:=mousey;

       if show_fps then fps_:=fps.fps;

       if status1='jedzie' then if player1='human' then begin
       xr:=xr+sin_[k]; {gracz1}
       yr:=yr-cos_[k];
       xx:=round(xr);
       yy:=round(yr);
       kat:=round(k / 6);
       end;



       if (xx>100)and(xx<200)and(yy<100) then czy1:=true;
       if (yy>123)and(yy<179)and(xx=160)and czy1 then begin okr1:=okr1+1;czy1:=false;poz1:=pozycja;pozycja:=pozycja+1 end;

       graczy:=0;
       if status1='jedzie' then graczy:=graczy+1;

       if pozycja=graczy+1 then pozycja:=1;

       if kolor1=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat,x,y]<>31 then putpixel(x+xx,y+yy,c[kat,x,y],2);


       if status1='jedzie' then
       for x:= 1 to 15 do {kontrola zderzen z banda - gracz1}
       for y:= 1 to 15 do
         if (getpixel(x+xx,y+yy,1)=16) and (getpixel(x+xx,y+yy,2)=kolor1) then begin
         status1:='banda';windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);end;



       (**** ANIMACJE Kà ****)
       if animacje_kol then
        begin
             if status1='jedzie' then
              begin
                   for x:=1 to 15 do
                   for y:=1 to 15 do
                    if getpixel(x+xx,y+yy,2)=17 then if random(3)=0 then putpixel(x+xx,y+yy,kolorydymu[random(3)+1],1);
              end;
        end;
       (***************************************)




       if show_fps then outtextxyfnt(0,0,14,6,longnum2str(fps_)+' fps','DATA\LITTLE.FN2',norm,2);



       movebuf2screen;delay(szybkosc);

       if show_fps then outtextxyfnt(0,0,255,6,longnum2str(fps_)+' fps','DATA\LITTLE.FN2',norm,2);


       if show_fps then FPS.NextFrame;

       bar(xx,yy,xx+15,yy+15,255,2);

       if status1='jedzie' then if player1='human' then
       if not ((xx>160)and(xx<213)and(yy>123)and(yy<179)and(okr1=0)) then begin
       if keydown[scanof('z')] then k:=k-1;
       if keydown[scanof('x')] then k:=k+1;
       if k>360 then k:=7;
       if k<7 then k:=360;
       end;



       (*Je¾eli wjedzie do boxu to jest wykluczony*)
       if (status1='jedzie') and((xx<=-10)or(yy>200))and(player1='human') then begin stopsound(4);
       status1:='poza torem';windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);end;

       (**************************************************************)

       If (status1='jedzie') and (okr1=4) and ((xx<-10)or(yy>200)) then stopsound(4);
       If (status1='jedzie') and (okr1=4) and ((xx<-10)or(yy>200)) then status1:='koniec';

       if status1<>'jedzie' then if soundplaying(4) then stopsound(4);


       if status1<>'jedzie' then koniec1:=true;

       if (okr1=4)and(player1='human') then status1:='koniec';

       if (okr1=4)and(player1='human') then koniec1:=true;

       if koniec1  then koniec_biegu:=true;

       if poz1=1 then
        begin
         if kolor1=1 then setcol(0,0,0,63);
         if kolor1=4 then setcol(0,63,0,0);
         if kolor1=15 then setcol(0,63,63,63);
         if kolor1=14 then setcol(0,63,63,0);
        end;

     until keydown[1] or koniec_biegu;

     windows(0,0,319,199);

     filllayer(255,2);
     filllayer(0,1);
     opengfxfile('GFX\menu.gfx',255,1);
     openpfile(117,40-20,'GFX\POZYCJA.GFX',255,2);
     openpfile(150,60-10,'GFX\1.GFX',255,2);
     openpfile(150,100-10,'GFX\2.GFX',255,2);
     openpfile(150,140-10,'GFX\3.GFX',255,2);
     openpfile(150,180-10,'GFX\4.GFX',255,2);
     stopsound(4);
     delay(200);
     keydown[1]:=false;
end;

{KONIEC TRENINGU}

{PONI½EJ WSZYSTKO ZWI¤ZANE Z BIEGIEM}

Procedure JedenBieg;

var x,y:integer;
    Xr, Yr : Real;
    XX, YY, Kat : integer;
    Xr2, Yr2 : Real;
    XX2, YY2, Kat2 : integer;
    Xr3, Yr3 : Real;
    XX3, YY3, Kat3 : integer;
    Xr4, Yr4 : Real;
    XX4, YY4, Kat4 : integer;
    K,K2,K3,K4 : Word;
{    gracz1, gracz2, gracz3, gracz4 : string[11];}
    f1 : file of integer;
    r1 : integer;
    f2 : file of integer;
    r2 : integer;
    f3 : file of integer;
    r3 : integer;
    f4 : file of integer;
    r4 : integer;
    FPs: FPSCounter;
    status1, status2, status3, status4: string[20];
    czy1,czy2,czy3,czy4: boolean;
    okr1,okr2,okr3,okr4: byte;
    fps_: integer;
    kolorydymu: array[1..3] of byte;
    koniec_biegu: boolean;
    myszx, myszy: word;
    koniec1,koniec2,koniec3,koniec4: boolean;
    poz1,poz2,poz3,poz4,pozycja: byte;


procedure startbiegu;
var czas,r: integer;
begin
     bar(125,70,145,90,22,1);
     bar(170,70,190,90,22,1);
     rectangle(125,70,145,90,15,1);
     rectangle(170,70,190,90,15,1);
     bar(145,70,170,110,22,1);
     rectangle(145,70,170,110,15,1);
     circle(157,77,5,4,1);
     floodfill(157,77,112,1);
     circle(157,90,5,4,1);
     floodfill(157,90,112,1);
     circle(157,103,5,2,1);
     floodfill(157,103,120,1);

     floodfill(157,77,12,1);
     movebuf2screen;

     setcol(0,63,20,0);
     startsound(sound[0],0,false);
     czas:=0;
     repeat
           delay(1);
           czas:=czas+1;
           if czas=200 then setcol(0,0,0,0);
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';

          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=500;
     until czas=500;
     floodfill(157,90,12,1);
     movebuf2screen;
     setcol(0,63,20,0);
     startsound(sound[0],0,false);
     czas:=0;
     repeat
           delay(1);
           czas:=czas+1;
           if czas=200 then setcol(0,0,0,0);
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';
          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=500;
     until czas=500;
     czas:=0;
     randomize;
     r:=random(500);
     repeat
           delay(1);
           czas:=czas+1;
           if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then status1:='tasma';
           if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then status2:='tasma';
           if player3='human' then if keydown[75] or keydown[77] then status3:='tasma';
           if player4='human' then if keydown[insscan] or keydown[delscan] then status4:='tasma';
          if player1='human' then if keydown[scanof('z')] or keydown[scanof('x')] then
          begin windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player2='human' then if keydown[scanof(',')] or keydown[scanof('.')] then
          begin windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player3='human' then if keydown[75] or keydown[77] then begin
          windows(0,0,319,199);line(161,185,239,199,9,2);line(239,185,161,199,9,2);windows(0,0,319,184);movebuf2screen;end;
          if player4='human' then if keydown[insscan] or keydown[delscan] then begin
          windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184);movebuf2screen;end;
          if keydown[1] then czas:=300+r;
     until czas=300+r;
     startsound(sound[0],0,false);
     floodfill(157,103,10,1);
     movebuf2screen;
     setcol(0,0,50,0);
end;

{pokazywanie belki na dole}
procedure ustawtabelke;
procedure tabelka(y : integer);
var
   i : integer;
begin
     for i:= 16 to 31 do
     begin
          line(0,i+y+16,320,i+y+16,47-i,2);
     end;
     line(80,y+32,80,y+48,31,2);
     line(160,y+32,160,y+48,31,2);
     line(240,y+32,240,y+48,31,2);
     outtextxyfnt(5,Y+33,kolor1,6,gracz1,'DATA\small.fn2',norm,2);
     outtextxyfnt(85,Y+33,kolor2,6,gracz2,'DATA\small.fn2',norm,2);
     outtextxyfnt(165,Y+33,kolor3,6,gracz3,'DATA\small.fn2',norm,2);
     outtextxyfnt(245,Y+33,kolor4,6,gracz4,'DATA\small.fn2',norm,2);
end;
var
   x,y : integer;
begin
     if player1='cpu' then if not eof(f1) then read(f1,xx,yy,kat);
     if player2='cpu' then if not eof(f2) then read(f2,xx2,yy2,kat2);
     if player3='cpu' then if not eof(f3) then read(f3,xx3,yy3,kat3);
     if player4='cpu' then if not eof(f4) then read(f4,xx4,yy4,kat4);
     if player1='human' then begin xx:=146;yy:=125;xr:=146;yr:=125;kat:=90 div 6;k:=90;end;
     if player2='human' then begin xx2:=146;yy2:=125+14;xr2:=146;yr2:=125+14;kat2:=90 div 6;k2:=90;end;
     if player3='human' then begin xx3:=146;yy3:=125+14+14;xr3:=146;yr3:=125+14+14;kat3:=90 div 6;k3:=90;end;
     if player4='human' then begin xx4:=146;yy4:=125+14+14+14;xr4:=146;yr4:=125+14+14+14;kat4:=90 div 6;k4:=90;end;
       if kolor1=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat,x,y]<>31 then putpixel(x+xx,y+yy,c[kat,x,y],2);
       if kolor2=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat2,x,y]<>31 then putpixel(x+xx2,y+yy2,c[kat2,x,y],2);
       if kolor3=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat3,x,y]<>31 then putpixel(x+xx3,y+yy3,c[kat3,x,y],2);
       if kolor4=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat4,x,y]<>31 then putpixel(x+xx4,y+yy4,c[kat4,x,y],2);
     movebuf2screen;
     y:=170;
     repeat
           y:=y-1;
           tabelka(y);
           movebuf2screen;
           delay(20);
     until y=153;
end;

Procedure WylosujAIKomputera;
begin
     randomize;
     x:=random(7);
     if x=0 then x:=1;
     if player1='cpu' then begin
     assign(f1,'ENEMY\1'+chr(ord('a')-1+x)+'.rec');
     reset(f1);
     end;
     x:=random(7);
     if x=0 then x:=1;
     if player2='cpu' then begin
     assign(f2,'ENEMY\2'+chr(ord('a')-1+x)+'.rec');
     reset(f2);
     end;
     x:=random(7);
     if x=0 then x:=1;
     if player3='cpu' then begin
     assign(f3,'ENEMY\3'+chr(ord('a')-1+x)+'.rec');
     reset(f3);
     end;
     x:=random(7);
     if x=0 then x:=1;
     if player4='cpu' then begin
     assign(f4,'ENEMY\4'+chr(ord('a')-1+x)+'.rec');
     reset(f4);
     end;
end;

var graczy:byte;

begin
     bar(0,0,320,200,0,2);
     outtextxyFNT(110,90,15,8,'WAIT LOADING ...','DATA\SMALL.FN2',bold_italic,2);
     movebuf2screen;
     WylosujAIKomputera;
     opengfxfile('GFX\trybuny.gfx',255,1);
     randomize;
     for x:=0 to 319 do
     for y:=0 to 199 do if getpixel(x,y,1)=31 then if random(1)=0 then putpixel(x,y,random(250)+1,1);
     opengfxfile('GFX\stadium'+num2str(nrtor)+'.gfx',31,1);
     line(160,123,160,179,15,1);
     line(213,123,213,179,15,1);
     line(160,137,150,137,15,1);
     line(160,151,150,151,15,1);
     line(160,165,150,165,15,1);
     kolorydymu[1]:=8{getpixel(160,50,1)};
     kolorydymu[2]:=25{getpixel(50,100,1)};
     kolorydymu[3]:=185{getpixel(300,78,1)};
     status1:='jedzie';
     status2:='jedzie';
     status3:='jedzie';
     status4:='jedzie';
     okr1:=0;
     okr2:=0;
     okr3:=0;
     okr4:=0;
     startsound(sound[1],1,true);
     if show_fps then fps.start;
     filllayer(255,2);
     ustawtabelke;
     startsound(sound[8],8,false);
     startsound(sound[8],8,false);
     startsound(sound[8],8,false);
     startsound(sound[8],8,false);
     windows(0,0,319,184);
     stopsound(8);
     stopsound(8);
     stopsound(8);
     stopsound(8);
     if status1='jedzie' then startsound(sound[4],4,true);
     if status2='jedzie' then startsound(sound[5],5,true);
     if status3='jedzie' then startsound(sound[6],6,true);
     if status4='jedzie' then startsound(sound[7],7,true);
     pozycja:=1;
     poz1:=0;
     poz2:=0;
     poz3:=0;
     poz4:=0;
     koniec_biegu:=false;
     koniec1:=false;
     koniec2:=false;
     koniec3:=false;
     koniec4:=false;
     czy1:=false;
     czy2:=false;
     czy3:=false;
     czy4:=false;
     startbiegu;
     repeat
       myszx:=mousex;myszy:=mousey;
       if show_fps then fps_:=fps.fps;

       if status1='jedzie' then if player1='human' then begin
       xr:=xr+sin_[k]; {gracz1}
       yr:=yr-cos_[k];
       xx:=round(xr);
       yy:=round(yr);
       kat:=round(k / 6);
       end;

       if status2='jedzie' then if player2='human' then begin
       xr2:=xr2+sin_[k2]; {gracz2}
       yr2:=yr2-cos_[k2];
       xx2:=round(xr2);
       yy2:=round(yr2);
       kat2:=round(k2 / 6);
       end;

       if status3='jedzie' then if player3='human' then begin
       xr3:=xr3+sin_[k3]; {gracz3}
       yr3:=yr3-cos_[k3];
       xx3:=round(xr3);
       yy3:=round(yr3);
       kat3:=round(k3 / 6);
       end;

       if status4='jedzie' then if player4='human' then begin
       xr4:=xr4+sin_[k4]; {gracz4}
       yr4:=yr4-cos_[k4];
       xx4:=round(xr4);
       yy4:=round(yr4);
       kat4:=round(k4 / 6);
       end;

       if status1='jedzie' then if player1='cpu' then if not eof(f1) then read(f1,xx,yy,kat);
       if status2='jedzie' then if player2='cpu' then if not eof(f2) then read(f2,xx2,yy2,kat2);
       if status3='jedzie' then if player3='cpu' then if not eof(f3) then read(f3,xx3,yy3,kat3);
       if status4='jedzie' then if player4='cpu' then if not eof(f4) then read(f4,xx4,yy4,kat4);

       if (xx>100)and(xx<200)and(yy<100) then czy1:=true;
       if (xx2>100)and(xx2<200)and(yy2<100) then czy2:=true;
       if (xx3>100)and(xx3<200)and(yy3<100) then czy3:=true;
       if (xx4>100)and(xx4<200)and(yy4<100) then czy4:=true;
       if (yy>123)and(yy<179)and(xx=160)and czy1 then begin okr1:=okr1+1;czy1:=false;poz1:=pozycja;pozycja:=pozycja+1 end;
       if (yy2>123)and(yy2<179)and(xx2=160)and czy2 then begin okr2:=okr2+1;czy2:=false;poz2:=pozycja;pozycja:=pozycja+1 end;
       if (yy3>123)and(yy3<179)and(xx3=160)and czy3 then begin okr3:=okr3+1;czy3:=false;poz3:=pozycja;pozycja:=pozycja+1 end;
       if (yy4>123)and(yy4<179)and(xx4=160)and czy4 then begin okr4:=okr4+1;czy4:=false;poz4:=pozycja;pozycja:=pozycja+1 end;


       if kolor1=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor1=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat,x,y]<>31 then putpixel(x+xx,y+yy,c[kat,x,y],2);
       if kolor2=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor2=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat2,x,y]<>31 then putpixel(x+xx2,y+yy2,c[kat2,x,y],2);
       if kolor3=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor3=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat3,x,y]<>31 then putpixel(x+xx3,y+yy3,c[kat3,x,y],2);
       if kolor4=1 then getfromxms(uchwyty[1],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=4 then getfromxms(uchwyty[2],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=15 then getfromxms(uchwyty[3],sizeof(tcar),c); {gracz1-rysuj}
       if kolor4=14 then getfromxms(uchwyty[4],sizeof(tcar),c); {gracz1-rysuj}
       for x:=1 to 15 do
       for y:=1 to 15 do
         if c[kat4,x,y]<>31 then putpixel(x+xx4,y+yy4,c[kat4,x,y],2);


       if status1='jedzie' then
       for x:= 1 to 15 do {kontrola zderzen z banda - gracz1}
       for y:= 1 to 15 do
         if (getpixel(x+xx,y+yy,1)=16) and (getpixel(x+xx,y+yy,2)=kolor1) then begin
         status1:='banda';windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);end;

       if status2='jedzie' then
       for x:= 1 to 15 do {kontrola zderzen z banda - gracz2}
       for y:= 1 to 15 do
         if (getpixel(x+xx2,y+yy2,1)=16) and (getpixel(x+xx2,y+yy2,2)=kolor2) then begin
         status2:='banda';windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184); end;

       if status3='jedzie' then
       for x:= 1 to 15 do {kontrola zderzen z banda - gracz3}
       for y:= 1 to 15 do
         if (getpixel(x+xx3,y+yy3,1)=16) and (getpixel(x+xx3,y+yy3,2)=kolor3) then begin
         status3:='banda';windows(0,0,319,199);line(161,185,239,199,9,2);line(161,199,239,185,9,2);windows(0,0,319,184); end;

       if status4='jedzie' then
       for x:= 1 to 15 do {kontrola zderzen z banda - gracz4}
       for y:= 1 to 15 do
         if (getpixel(x+xx4,y+yy4,1)=16) and (getpixel(x+xx4,y+yy4,2)=kolor4) then begin
         status4:='banda';windows(0,0,319,199);line(241,185,319,199,9,2);line(241,199,319,185,9,2);windows(0,0,319,184); end;

       graczy:=0;
       if (status1<>'banda')and(status1<>'tasma')and(player1='human') then graczy:=graczy+1;
       if (status2<>'banda')and(status2<>'tasma')and(player2='human') then graczy:=graczy+1;
       if (status3<>'banda')and(status3<>'tasma')and(player3='human') then graczy:=graczy+1;
       if (status4<>'banda')and(status4<>'tasma')and(player4='human') then graczy:=graczy+1;
       if (player1='cpu')and(status1='jedzie') then graczy:=graczy+1;
       if (player2='cpu')and(status2='jedzie') then graczy:=graczy+1;
       if (player3='cpu')and(status3='jedzie') then graczy:=graczy+1;
       if (player4='cpu')and(status4='jedzie') then graczy:=graczy+1;

       if pozycja=graczy+1 then pozycja:=1;

       (**** ANIMACJE Kà ****)
       if animacje_kol then
        begin
             if status1='jedzie' then
              begin
                   for x:=1 to 15 do
                   for y:=1 to 15 do
                    if getpixel(x+xx,y+yy,2)=17 then if random(3)=0 then putpixel(x+xx,y+yy,kolorydymu[random(3)+1],1);
              end;
             if status2='jedzie' then
              begin
                   for x:=1 to 15 do
                   for y:=1 to 15 do
                    if getpixel(x+xx2,y+yy2,2)=17 then if random(3)=0 then putpixel(x+xx2,y+yy2,kolorydymu[random(3)+1],1);
              end;
             if status3='jedzie' then
              begin
                   for x:=1 to 15 do
                   for y:=1 to 15 do
                    if getpixel(x+xx3,y+yy3,2)=17 then if random(3)=0 then putpixel(x+xx3,y+yy3,kolorydymu[random(3)+1],1);
              end;
             if status4='jedzie' then
             begin
                   for x:=1 to 15 do
                   for y:=1 to 15 do
                    if getpixel(x+xx4,y+yy4,2)=17 then if random(3)=0 then putpixel(x+xx4,y+yy4,kolorydymu[random(3)+1],1);
              end;
        end;
       (***************************************)




       if show_fps then outtextxyfnt(0,0,14,6,num2str(fps_)+' fps','DATA\LITTLE.FN2',norm,2);

{       outtextxy(0,10,15,1,1,num2str(okr1)+' '+num2str(okr2)+' '+num2str(okr3)+' '+num2str(okr4),2);
       outtextxy(0,20,15,1,1,longnum2str(memavail),2);
       outtextxy(0,30,15,1,1,num2str(myszx)+'x'+num2str(myszy),2);putpixel(myszx,myszy,4,2);
       outtextxy(0,40,15,1,1,num2str(poz1)+' '+num2str(poz2)+' '+num2str(poz3)+' '+num2str(poz4),2);  }


       movebuf2screen;delay(szybkosc);

       if show_fps then outtextxyfnt(0,0,255,6,num2str(fps_)+' fps','DATA\LITTLE.FN2',norm,2);

{       outtextxy(0,10,255,1,1,num2str(okr1)+' '+num2str(okr2)+' '+num2str(okr3)+' '+num2str(okr4),2);
       outtextxy(0,20,255,1,1,longnum2str(memavail),2);
       outtextxy(0,30,255,1,1,num2str(myszx)+'x'+num2str(myszy),2);putpixel(myszx,myszy,255,2);
       outtextxy(0,40,255,1,1,num2str(poz1)+' '+num2str(poz2)+' '+num2str(poz3)+' '+num2str(poz4),2);}

       if show_fps then FPS.NextFrame;

       bar(xx,yy,xx+15,yy+15,255,2);
       bar(xx2,yy2,xx2+15,yy2+15,255,2);
       bar(xx3,yy3,xx3+15,yy3+15,255,2);
       bar(xx4,yy4,xx4+15,yy4+15,255,2);

       if status1='jedzie' then if player1='human' then
       if not ((xx>160)and(xx<213)and(yy>123)and(yy<179)and(okr1=0)) then begin
       if keydown[scanof('z')] then k:=k-1;
       if keydown[scanof('x')] then k:=k+1;
       if k>360 then k:=7;
       if k<7 then k:=360;
       end;

       if status2='jedzie' then if player2='human' then
       if not ((xx2>160)and(xx2<213)and(yy2>123)and(yy2<179)and(okr2=0)) then begin
       if keydown[scanof(',')] then k2:=k2-1;
       if keydown[scanof('.')] then k2:=k2+1;
       if k2>360 then k2:=7;
       if k2<7 then k2:=360;
       end;


       if status3='jedzie' then if player3='human' then
       if not ((xx3>160)and(xx3<213)and(yy3>123)and(yy3<179)and(okr3=0)) then begin
       if keydown[75] then k3:=k3-1;
       if keydown[77] then k3:=k3+1;
       if k3>360 then k3:=7;
       if k3<7 then k3:=360;
       end;

       if status4='jedzie' then if player4='human' then
       if not ((xx4>160)and(xx4<213)and(yy4>123)and(yy4<179)and(okr4=0)) then begin
       if keydown[insscan] then k4:=k4-1;
       if keydown[delscan] then k4:=k4+1;
       if k4>360 then k4:=7;
       if k4<7 then k4:=360;
       end;


       (*Je¾eli wjedzie do boxu to jest wykluczony*)
       if (status1='jedzie') and((xx<=-10)or(yy>200))and(player1='human') then begin stopsound(4);
       status1:='poza torem';windows(0,0,319,199);line(0,185,79,199,9,2);line(79,185,0,199,9,2);windows(0,0,319,184);end;

       if (status2='jedzie') and((xx2<=-10)or(yy2>200))and(player2='human') then begin stopsound(5);
       status2:='poza torem';windows(0,0,319,199);line(161,185,239,199,9,2);line(161,199,239,185,9,2);windows(0,0,319,184);end;

       if (status3='jedzie') and((xx3<=-10)or(yy3>200))and(player3='human') then begin stopsound(6);
       status3:='poza torem';windows(0,0,319,199);line(81,185,159,199,9,2);line(159,185,81,199,9,2);windows(0,0,319,184);end;

       if (status4='jedzie') and((xx4<=-10)or(yy4>200))and(player4='human') then begin stopsound(7);
       status4:='poza torem';windows(0,0,319,199);line(241,185,319,199,9,2);line(319,185,241,199,9,2);windows(0,0,319,184);end;
       (**************************************************************)

       If (status1='jedzie') and (okr1=4) and ((xx<-10)or(yy>200)) then stopsound(4);
       If (status2='jedzie') and (okr2=4) and ((xx2<-10)or(yy2>200)) then stopsound(5);
       If (status3='jedzie') and (okr3=4) and ((xx3<-10)or(yy3>200)) then stopsound(6);
       If (status4='jedzie') and (okr4=4) and ((xx4<-10)or(yy4>200)) then stopsound(7);
       If (status1='jedzie') and (okr1=4) and ((xx<-10)or(yy>200)) then status1:='koniec';
       If (status2='jedzie') and (okr2=4) and ((xx2<-10)or(yy2>200)) then status2:='koniec';
       If (status3='jedzie') and (okr3=4) and ((xx3<-10)or(yy3>200)) then status3:='koniec';
       If (status4='jedzie') and (okr4=4) and ((xx4<-10)or(yy4>200)) then status4:='koniec';

       if status1<>'jedzie' then if soundplaying(4) then stopsound(4);
       if status2<>'jedzie' then if soundplaying(5) then stopsound(5);
       if status3<>'jedzie' then if soundplaying(6) then stopsound(6);
       if status4<>'jedzie' then if soundplaying(7) then stopsound(7);

       if ((okr1>=2)or(okr2>=2)or(okr3>=2)or(okr4>=2)) then
        begin
         x:=random(2)+1;
         case x of
              1:  if not soundplaying(9) then startsound(sound[9],9,true);
              2:  if not soundplaying(10) then startsound(sound[10],10,true);
              3:  if not soundplaying(11) then startsound(sound[11],11,true);
         end;
        end;

       if status1<>'jedzie' then koniec1:=true;
       if status2<>'jedzie' then koniec2:=true;
       if status3<>'jedzie' then koniec3:=true;
       if status4<>'jedzie' then koniec4:=true;

       if (okr1=4)and(player1='human') then status1:='koniec';
       if (okr2=4)and(player2='human') then status2:='koniec';
       if (okr3=4)and(player3='human') then status3:='koniec';
       if (okr4=4)and(player4='human') then status4:='koniec';

       if (okr1=4)and(player1='human') then koniec1:=true;
       if (okr2=4)and(player2='human') then koniec2:=true;
       if (okr3=4)and(player3='human') then koniec3:=true;
       if (okr4=4)and(player4='human') then koniec4:=true;

       if koniec1 and koniec2 and koniec3 and koniec4 then koniec_biegu:=true;

       if poz1=1 then
        begin
         if kolor1=1 then setcol(0,0,0,63);
         if kolor1=4 then setcol(0,63,0,0);
         if kolor1=15 then setcol(0,63,63,63);
         if kolor1=14 then setcol(0,63,63,0);
        end;
       if poz2=1 then
        begin
         if kolor2=1 then setcol(0,0,0,63);
         if kolor2=4 then setcol(0,63,0,0);
         if kolor2=15 then setcol(0,63,63,63);
         if kolor2=14 then setcol(0,63,63,0);
        end;
       if poz3=1 then
        begin
         if kolor3=1 then setcol(0,0,0,63);
         if kolor3=4 then setcol(0,63,0,0);
         if kolor3=15 then setcol(0,63,63,63);
         if kolor3=14 then setcol(0,63,63,0);
        end;
       if poz4=1 then
        begin
         if kolor4=1 then setcol(0,0,0,63);
         if kolor4=4 then setcol(0,63,0,0);
         if kolor4=15 then setcol(0,63,63,63);
         if kolor4=14 then setcol(0,63,63,0);
        end;

     until keydown[1] or koniec_biegu;

     if koniec_biegu then
      begin
       if soundplaying(1) then begin stopsound(1); end;
       if soundplaying(2) then begin stopsound(2); end;
       if soundplaying(3) then begin stopsound(3); end;
       if soundplaying(9) then begin stopsound(9); end;
       if soundplaying(10) then begin stopsound(10); end;
       if soundplaying(11) then begin stopsound(11); end;
      end;
     windows(0,0,319,199);
     if player1='cpu' then close(f1);
     if player2='cpu' then close(f2);
     if player3='cpu' then close(f3);
     if player4='cpu' then close(f4);

{     if (status1='koniec')and(okr4=4) then}
      begin
           if poz1=1 then ptk1[bieg]:=3;
           if poz1=2 then ptk1[bieg]:=2;
           if poz1=3 then ptk1[bieg]:=1;
           if poz1=4 then ptk1[bieg]:=0;
           if status1='banda' then ptk1[bieg]:=0;
      end;
{     if (status2='koniec')and(okr4=4) then  }
      begin
           if poz2=1 then ptk2[bieg]:=3;
           if poz2=2 then ptk2[bieg]:=2;
           if poz2=3 then ptk2[bieg]:=1;
           if poz2=4 then ptk2[bieg]:=0;
           if status2='banda' then ptk2[bieg]:=0;
      end;
{     if (status3='koniec')and(okr4=4) then}
      begin
           if poz3=1 then ptk3[bieg]:=3;
           if poz3=2 then ptk3[bieg]:=2;
           if poz3=3 then ptk3[bieg]:=1;
           if poz3=4 then ptk3[bieg]:=0;
           if status3='banda' then ptk3[bieg]:=0;
      end;
{     if (status4='koniec')and(okr4=4) then}
      begin
           if poz4=1 then ptk4[bieg]:=3;
           if poz4=2 then ptk4[bieg]:=2;
           if poz4=3 then ptk4[bieg]:=1;
           if poz4=4 then ptk4[bieg]:=0;
           if status4='banda' then ptk4[bieg]:=0;
      end;
end;

{KONIEC JEDNEGO BIEGU}









procedure ustawmenusy;
var
   x, y : integer;
begin
     x:=-120;
     repeat
           x:=x+2;
           openpfile(x,50,'GFX\nowagra.gfx',255,2);
           line(x,50,x+85,70,12,2);
           line(x,70,x+85,50,12,2);
           movebuf2screen;
           bar(x,50,x+100,75,255,2);
     until x=120;
     openpfile(x,50,'GFX\nowagra.gfx',255,2);
     line(x,50,x+85,70,12,2);
     line(x,70,x+85,50,12,2);
     x:=-120;
     repeat
           x:=x+2;
           openpfile(x,75,'GFX\trening.gfx',255,2);
           movebuf2screen;
           bar(x-1,75,x+100,100,255,2);
     until x=120;
     openpfile(x,75,'GFX\trening.gfx',255,2);
     x:=-120;
     repeat
           x:=x+2;
           openpfile(x,105,'GFX\autorzy.gfx',255,2);
           movebuf2screen;
           bar(x,105,x+100,130,255,2);
     until x=120;
     openpfile(x,105,'GFX\autorzy.gfx',255,2);
     x:=-120;
     repeat
           x:=x+2;
           openpfile(x,130,'GFX\quit.gfx',255,2);
           movebuf2screen;
           bar(x,130,x+100,160,255,2);
     until x=120;
     openpfile(x,130,'GFX\quit.gfx',255,2);
end;

procedure usunmenusy;
var
   x, y : integer;
begin
     x:=120;
     bar(x,50,x+100,75,255,2);
     repeat
           x:=x+2;
           openpfile(x,50,'GFX\nowagra.gfx',255,2);
           line(x,50,x+85,70,12,2);
           line(x,70,x+85,50,12,2);
           movebuf2screen;
           bar(x,50,x+100,75,255,2);
     until x>=320;
     openpfile(x,50,'GFX\nowagra.gfx',255,2);
     line(x,50,x+85,70,12,2);
     line(x,70,x+85,50,12,2);
     x:=120;
     repeat
           x:=x+2;
           openpfile(x,75,'GFX\trening.gfx',255,2);
           movebuf2screen;
           bar(x-1,75,x+100,100,255,2);
     until x>=320;
     openpfile(x,75,'GFX\trening.gfx',255,2);
     x:=120;
     repeat
           x:=x+2;
           openpfile(x,105,'GFX\autorzy.gfx',255,2);
           movebuf2screen;
           bar(x,105,x+100,130,255,2);
     until x>=320;
     openpfile(x,105,'GFX\autorzy.gfx',255,2);
     x:=120;
     repeat
           x:=x+2;
           openpfile(x,130,'GFX\quit.gfx',255,2);
           movebuf2screen;
           bar(x,130,x+100,160,255,2);
     until x>=320;
     openpfile(x,130,'GFX\quit.gfx',255,2);
end;

Procedure Autorzy;
var i:integer;
begin
     startsound(sound[13],13,false);
     UsuNMenusy;
     opengfxfile('GFX\menu.gfx',255,1);
     for i:=-100 to 40 do
      begin
           openpfile(60,i,'GFX\g2.gfx',255,2);
           waitforretrace;movebuf2screen;
           bar(60,i,60+200,i+100,255,2);
      end;
     openpfile(60,i,'GFX\g2.gfx',255,2);
     movebuf2screen;
     for i:=-250 to 35 do
      begin
           openpfile(i,160,'GFX\gg.gfx',255,2);
           waitforretrace;movebuf2screen;
           bar(i,160,i+250,200,255,2);
      end;
     openpfile(i,160,'GFX\gg.gfx',255,2);
     movebuf2screen;
     delay(500);
     repeat until keydown[entscan] or (button<>0);

     opengfxfile('GFX\menu.gfx',255,1);
     for i:=40 downto -100 do
      begin
           openpfile(60,i,'GFX\g2.gfx',255,2);
           waitforretrace;movebuf2screen;
           bar(60,i,60+200,i+100,255,2);
      end;
     openpfile(60,i,'GFX\g2.gfx',255,2);
     movebuf2screen;
     for i:=35 downto -250 do
      begin
           openpfile(i,160,'GFX\gg.gfx',255,2);
           waitforretrace;movebuf2screen;
           bar(i,160,i+250,200,255,2);
      end;
     openpfile(i,160,'GFX\gg.gfx',255,2);

     filllayer(0,1);
     filllayer(255,2);
     opengfxfile('GFX\menu.gfx',0,1);
     openpfile(85,0,'GFX\spedlogo.gfx',255,1);
     ustawmenusy;
     openpfile(3,187,'GFX\www.gfx',255,1);
     openpfile(210,185,'GFX\email.gfx',255,1);
end;


Procedure Trening;
var i:integer;
procedure usunmenutre;
var i:integer;
begin
     for i:=117 to 320 do
      begin
       openpfile(i,40-20,'GFX\POZYCJA.GFX',255,2);
       movebuf2screen;
       bar(i,40-20,i+85,52-20,255,2);
     end;
     openpfile(i,40-20,'GFX\POZYCJA.GFX',255,2);
     for i:=150 to 320 do
      begin
       openpfile(i,60-10,'GFX\1.GFX',255,2);
       movebuf2screen;
       bar(i,60-10,i+20,90-10,255,2);
     end;
     openpfile(i,60-10,'GFX\1.GFX',255,2);
     for i:=150 to 320 do
      begin
       openpfile(i,100-10,'GFX\2.GFX',255,2);
       movebuf2screen;
       bar(i,100-10,i+20,130-10,255,2);
     end;
     openpfile(i,100-10,'GFX\2.GFX',255,2);
     for i:=150 to 320 do
      begin
       openpfile(i,140-10,'GFX\3.GFX',255,2);
       movebuf2screen;
       bar(i,140-10,i+20,170-10,255,2);
     end;
     openpfile(i,140-10,'GFX\3.GFX',255,2);
     for i:=150 to 320 do
      begin
       openpfile(i,180-10,'GFX\4.GFX',255,2);
       movebuf2screen;
       bar(i,180-10,i+20,210-10,255,2);
     end;
     openpfile(i,180-10,'GFX\4.GFX',255,2);
end;
begin
     usunmenusy;
     filllayer(255,2);
     opengfxfile('GFX\menu.gfx',255,1);
     for i:=-85 to 117 do
      begin
       openpfile(i,40-20,'GFX\POZYCJA.GFX',255,2);
       movebuf2screen;
       bar(i,40-20,i+85,52-20,255,2);
     end;
     openpfile(i,40-20,'GFX\POZYCJA.GFX',255,2);
     for i:=-20 to 150 do
      begin
       openpfile(i,60-10,'GFX\1.GFX',255,2);
       movebuf2screen;
       bar(i,60-10,i+20,90-10,255,2);
     end;
     openpfile(i,60-10,'GFX\1.GFX',255,2);
     for i:=-20 to 150 do
      begin
       openpfile(i,100-10,'GFX\2.GFX',255,2);
       movebuf2screen;
       bar(i,100-10,i+20,130-10,255,2);
     end;
     openpfile(i,100-10,'GFX\2.GFX',255,2);
     for i:=-20 to 150 do
      begin
       openpfile(i,140-10,'GFX\3.GFX',255,2);
       movebuf2screen;
       bar(i,140-10,i+20,170-10,255,2);
     end;
     openpfile(i,140-10,'GFX\3.GFX',255,2);
     for i:=-20 to 150 do
      begin
       openpfile(i,180-10,'GFX\4.GFX',255,2);
       movebuf2screen;
       bar(i,180-10,i+20,210-10,255,2);
     end;
     openpfile(i,180-10,'GFX\4.GFX',255,2);


     show_fps:=false;
     animacje_kol:=true;
     player1:='human';
     kolor1:=1;
     kolor2:=4;
     kolor3:=15;
     kolor4:=14;


     repeat
           mx:=mousex;my:=mousey;
           tmouse:=getpixel(mousex,mousey,2);
           putpixel(mx,my,12,2);
           movebuf2screen;
           putpixel(mx,my,tmouse,2);

           if (mousein(150,50,170,80)) and (button=1) then
           begin startsound(sound[13],13,false);pozycjay:=1;usunmenutre; BiegTreningowy;setcol(0,0,0,0); end;

           if (mousein(150,90,170,115)) and (button=1) then
           begin startsound(sound[13],13,false);pozycjay:=2;usunmenutre;BiegTreningowy;setcol(0,0,0,0); end;

           if (mousein(150,130,170,157)) and (button=1) then
           begin startsound(sound[13],13,false);pozycjay:=3;usunmenutre;BiegTreningowy;setcol(0,0,0,0); end;

           if (mousein(150,167,170,195)) and (button=1) then
           begin startsound(sound[13],13,false);pozycjay:=4;usunmenutre;BiegTreningowy;setcol(0,0,0,0); end;

     until keydown[1];
     usunmenutre;
     delay(200);
     filllayer(0,1);
     filllayer(255,2);
     opengfxfile('GFX\menu.gfx',0,1);
     openpfile(85,0,'GFX\spedlogo.gfx',255,1);
     ustawmenusy;
     openpfile(3,187,'GFX\www.gfx',255,1);
     openpfile(210,185,'GFX\email.gfx',255,1);
end;

procedure tabelka;
var
   i : integer;
begin
     line(0,15,320,15,15,1);
     line(80,0,80,200,15,1);
     for i:= 0 to 15 do
     begin
          line(80+i*14,0,80+i*14,200,15,1);
          if i<15 then
          outtextxyfntshadow(82+i*14,5,25,6,num2str(i+1),'DATA\little.fn2',norm,1);
     end;
     outtextxyfntshadow(294,5,56,6,'suma','DATA\little.fn2',norm,1);
     outtextxyfnt(21,5,14,6,'GRACZ','DATA\little.fn2',norm,1);
     outtextxyfnt(15,36,kolor1,6,gracz1,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,82,kolor2,6,gracz2,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,128,kolor3,6,gracz3,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,175,kolor4,6,gracz4,'DATA\little.fn2',norm,1);
     suma1:=0;suma2:=0;suma3:=0;suma4:=0;
     for i:= 0 to 14 do
     begin
          outtextxyfnt(82+i*14,36,12,6,num2str(ptk1[i+1]),'DATA\little.fn2',norm,1);
          outtextxyfnt(82+i*14,82,12,6,num2str(ptk2[i+1]),'DATA\little.fn2',norm,1);
          outtextxyfnt(82+i*14,128,12,6,num2str(ptk3[i+1]),'DATA\little.fn2',norm,1);
          outtextxyfnt(82+i*14,175,12,6,num2str(ptk4[i+1]),'DATA\little.fn2',norm,1);
          suma1:=suma1+ptk1[i+1];
          suma2:=suma2+ptk2[i+1];
          suma3:=suma3+ptk3[i+1];
          suma4:=suma4+ptk4[i+1];
     end;
     outtextxyfnt(300,36,14,6,num2str(suma1),'DATA\little.fn2',norm,1);
     outtextxyfnt(300,82,14,6,num2str(suma2),'DATA\little.fn2',norm,1);
     outtextxyfnt(300,128,14,6,num2str(suma3),'DATA\little.fn2',norm,1);
     outtextxyfnt(300,175,14,6,num2str(suma4),'DATA\little.fn2',norm,1);
     line(0,61,320,61,15,1);
     line(0,107,320,107,15,1);
     line(0,153,320,153,15,1);
end;



begin
     ekranstartowy;
     wgrajdoxms;
     ObliczanieSinCos;
     initsounds;
     startsound(sound[12],12,true);
     initfgraph;
     newlayer;
     wstep;
     initnewkeyint;
     opengfxfile('GFX\menu.gfx',0,1);
     openpfile(10,10,'GFX\demo.gfx',255,1);
     openpfile(85,0,'GFX\spedlogo.gfx',255,1);
     ustawmenusy;
     openpfile(3,187,'GFX\www.gfx',255,1);
     openpfile(210,185,'GFX\email.gfx',255,1);
{     rectangle(120,50,205,70,15,1);
     rectangle(120,75,205,98,15,1);
     rectangle(120,105,205,127,15,1);}
     putmouse(160,100);
     getpal(p);
     repeat

           mx:=mousex;my:=mousey;
           tmouse:=getpixel(mousex,mousey,2);
           putpixel(mx,my,12,2);
           movebuf2screen;
           putpixel(mx,my,tmouse,2);

           if mousein(120,130,205,153) and (button=1) then
           begin
                startsound(sound[13],13,false);
                usunmenusy;
                fadeout(p,30);
                setoldKeyInt;
                closefgraph;
                wywalzxms;
                freesounds;
                textcolor(12);
                writeln('       SPEEDWAY 2001');
                textcolor(15);
                writeln('   PENA WERSJA DOST¨PNA');
                writeln('  NA STRONIE INTERNETOWEJ');
                textcolor(14);
                writeln('     GRUPY GOLDEN GATE');
                textcolor(15);
                writeln('    W  DZIALE PRODUKCJE');
                textcolor(11);
                writeln('  WWW: GGATE.REPUBLIKA.PL');
                writeln('EMAIL: GGATE@POCZTA.ONET.PL');
                textcolor(7);
                halt;
           end;

           If (mousein(120,104,205,126)) and (button=1) then Autorzy;
           If (mousein(120,75,205,98))and(button=1) then Trening;


     until true=false;
     setoldKeyInt;
     closefgraph;
     wywalzxms;
     freesounds;
end.