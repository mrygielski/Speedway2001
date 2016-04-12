Uses Fgraphb;

const plikin  = 'stadium2.gfx';
      plikout = 'const.pas';
      ResX    = 319;
      ResY    = 199;


var
   F    : text;
   s    : String;
   X, Y : integer;
   l: byte;

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
       for y:=0 to 319 do putpixel(y,x,b[y],l);
      end;
     close(F);
end;

begin
     initfgraph;
{     loadpaintfile(0,0,plikin,1);}
     opengfxfile(plikin,0,1);
     movebuf2screen;
{     readln;}
     Assign(f,plikout);
     Rewrite(f);
     s:='const Rysunek: array[1..'+longnum2str((resx+1)*(resy+1))+'] of byte=('#13#10;
     Write(f,s);
     l:=1;
     For y:=0 to ResY do
     for x:=0 to ResX do
     begin
          s:=num2str(getpixel(x+1,y,1));
          if resx*resy<>x*y then s:=s+',';
          l:=l+1;
          if l=20 then begin s:=s+#13#10; l:=1; end;
          write(f,s);
     end;
     s:=');';
     write(f,s);
     close(F);
     closefgraph;
end.