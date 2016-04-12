
uses fgraphb, speedtpu;

var
   gracz1, gracz2, gracz3, gracz4 : string;
   suma1, suma2, suma3, suma4 : byte;
   ptk1, ptk2, ptk3, ptk4 : array[1..15] of byte;

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
     outtextxyfnt(15,36,14,6,gracz1,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,82,14,6,gracz2,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,128,14,6,gracz3,'DATA\little.fn2',norm,1);
     outtextxyfnt(15,175,14,6,gracz4,'DATA\little.fn2',norm,1);
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
     initfgraph;
     opengfxfile('start2.gfx',255,1);
     siatka;
     gracz1:='gracz1';
     gracz2:='gracz2';
     gracz3:='gracz3';
     gracz4:='gracz4';
     tabelka;
     movebuf2screen;
     repeat
     until keypressed;
     closefgraph;
end.