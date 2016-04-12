uses crt,gif;
type tablica=array[0..319,0..199] of byte;

var c:byte;
 x,y:word;
 bufor1:^tablica;

procedure putpix(x,y,k:integeR);
begin
     mem[$a000:320*y+x]:=k;
end;
function getpix(x,y:integeR):byte;
begin
     getpix:=mem[$a000:320*y+x];
end;

begin
     new(bufor1);
       for x:=0 to 319 do
       for y:=0 to 199 do bufor1^[x,y]:=0;

     asm mov ax,13h; int 10h; end;
     loadgif('stadium3.gif');
       for x:=0 to 319 do
       for y:=0 to 199 do bufor1^[x,y]:=getpix(x,y);
 repeat
       for x:=0 to 319 do
       for y:=0 to 199 do
       begin
            c:=bufor1^[x,y];
            if (x<317) and (y<199) and(x>0) then
            bufor1^[x+random(2),y+random(2)]:=c else
            bufor1^[x+random(2),y+random(2)]:=0;
            putpix(x,y,bufor1^[x,y]);
       end;
       delay(10);
 until keypressed;
     asm mov ax,3h; int 10h; end;
  dispose(bufor1);
end.