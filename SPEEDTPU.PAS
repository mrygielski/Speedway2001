Unit SpeedTPU;

INTERFACE

Type TCar = Array[1..60,1..15,1..15] of byte;

Var SBVersion : string[10];
   suma1, suma2, suma3, suma4 : byte;
   ptk1, ptk2, ptk3, ptk4 : array[0..15] of byte;

Procedure OpenGFXFile(plik:string;tlo,l:byte);
Procedure OpenPFile(x1,y1:integer; plik:string;tlo,l:byte);
PROCEDURE SBver(var Maj, Min : BYTE);
procedure setvolume(vol : word);
procedure siatka;
procedure wstep;



IMPLEMENTATION

Uses Dos, FGraphB;

Procedure OpenGFXFile(plik:string;tlo,l:byte);
var f:file;
    b:array[0..319] of Byte;
    x,y:integer;
begin
     assign(f,plik);
     reset(F,1);
     for x:=0 to 199 do
      begin
       blockread(f,b,320);
       for y:=0 to 319 do if b[y]<>tlo then putpixel(y,x,b[y],l);
      end;
     close(F);
end;
Procedure OpenPFile(x1,y1:integer; plik:string;tlo,l:byte);
var f:File;
    b,rx,ry:Byte;
    xx,yy:integer;
    buf:array[1..321] of byte;
    w,d:Word;
begin
     assign(f,plik);
     reset(F,1);
     blockread(f,buf,2,w);
     rx:=buf[1];ry:=buf[2];
     for yy:=1 to ry do
      begin
        blockread(f,buf,rx,w);
        for xx:=1 to rx do if buf[xx]<>tlo then putpixel(xx+x1,yy+y1,buf[xx],l);
      end;
     close(F);
end;

PROCEDURE SBver (var Maj, Min : BYTE);        { FROM SWAG LIBRARY   }
  VAR bev : STRING[32];                       { environment string  }
      j,k : WORD;                             { scratch variables   }
  BEGIN
    Maj := 0;  Min := 0;                      { initialize          }
    bev := GetEnv('BLASTER');                 { look in environment }
    IF bev[0] = #0 THEN EXIT;                 { no sign of Blaster  }
    j := Pos('A',bev);                        { search for i/o port }
    IF j = 0 THEN EXIT ELSE INC(j);           { none?               }
    Val( '$'+Copy(bev,j,3), j, k );           { base port number    }
    IF k <> 0 THEN EXIT;                      { if bad port value   }
    INC(j,$C);                                { command port        }
    Port[j] := $E1;                           { command             }
    DEC(j,2);                                 { input port          }
    Delay(20);                                { wait for response   }
    Maj := Port[j];                           { version major part  }
    Delay(20);                                { wait for response   }
    Min := Port[j];                           { version minor part  }
  END {SBver};

procedure setvolume(vol : word);
begin
    Port[$224] := 4;     { register 04h - VOC volume }
    Port[$225] := vol;
end;
procedure siatka;
var
   x, y : integer;
begin
     for x:= 0 to 160 do
     for y:= 0 to 100 do
     begin
          putpixel(x*2,y*2,20,1);
          putpixel(1+x*2,1+y*2,20,1);
     end;
end;

procedure wstep;
var
   x : integer;
Procedure OpenGfxFile(plik:string;a,l:integer);
var f:file;
    b:array[0..319] of Byte;
    x,y:integer;
begin
     assign(f,plik);
     reset(F,1);
     for x:=0 to 199 do
      begin
       blockread(f,b,320);
       for y:=0 to 319 do putpixel(y+a,x,b[y],l);
      end;
     close(F);
end;
var a:boolean;
begin
     x:=-280;
     a:=false;
     repeat
           x:=x+3;
           opengfxfile('GFX\gglogo.gfx',x,1);
           waitforretrace;movebuf2screen;
           filllayer(0,1);
           if keypressed then a:=true;
     until a or(x>=-6);
     if a then else delay(1000);
     repeat
           x:=x+3;
           opengfxfile('GFX\gglogo.gfx',x,1);
           waitforretrace;movebuf2screen;
           filllayer(0,1);
           if keypressed then a:=true;
     until a or(x=320);
end;





var a,b:byte;
begin
     sbver(a,b);
     SBVersion:=num2str(a)+'.'+num2str(b);
end.