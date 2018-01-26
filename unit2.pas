unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Unit4;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Label1: TLabel;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Refreshlist;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  sfs: array[1..50] of string;
  cnt: longint;

implementation

{$R *.lfm}


{ TForm2 }

procedure TForm2.Refreshlist;
var i:longint;
begin
  Listbox1.Clear;
  for i := cnt downto 1 do
    Listbox1.Items.Add(sfs[i]);
end;

procedure TForm2.FormShow(Sender: TObject);
var
  ttext: Text;
  ts: string;
begin
  cnt := 0;
  assignfile(ttext, 'timidity.cfg');
  reset(ttext);
  while not EOF(ttext) do
  begin
    readln(ttext, ts);
    if copy(ts, 1, 9) = 'soundfont' then
    begin
      Inc(cnt);
      Delete(ts, 1, 10);
      sfs[cnt] := ts;
    end;
  end;
  Refreshlist;
  closefile(ttext);
end;

procedure TForm2.Button1Click(Sender: TObject);
var ts,sfn:string;
begin
  OpenDialog1.Execute;
  sfn := OpenDialog1.FileName;
  ts := copy(sfn, length(sfn) - 3, 4);
  if not CheckFileExt(sfn, '.sf2') then exit;
  if ((ts <> '.sf2') and (ts <> '.SF2')) then
    exit;
  inc(cnt);
  sfs[cnt]:=sfn;
  Refreshlist;
end;

procedure TForm2.Button2Click(Sender: TObject);
var i,t:longint;
begin
  for i:=1 to cnt do
    if ListBox1.Selected[i-1] then break;
  t:=cnt-i+1;
  for i:=t+1 to cnt do
    begin
      sfs[i-1]:=sfs[i];
    end;
  dec(cnt);
  Refreshlist;
end;

procedure TForm2.Button3Click(Sender: TObject);
var ts:string;
    i:longint;
begin
  for i:=1 to cnt do
    if ListBox1.Selected[i-1] then break;
  i:=cnt-i+1;
  if i=1 then exit;
  ts:=sfs[i];
  sfs[i]:=sfs[i+1];
  sfs[i+1]:=ts;
  Refreshlist;
end;

procedure TForm2.Button4Click(Sender: TObject);
var ts:string;
    i:longint;
begin
  for i:=1 to cnt do
    if ListBox1.Selected[i-1] then break;
  i:=cnt-i;
  if i=cnt then exit;
  ts:=sfs[i];
  sfs[i]:=sfs[i+1];
  sfs[i+1]:=ts;
  Refreshlist;
end;

procedure TForm2.Button6Click(Sender: TObject);
var
  ttext: Text;i:longint;
begin
  assignfile(ttext, 'timidity.cfg');
  rewrite(ttext);
  writeln(ttext, 'dir .');
  writeln(ttext, 'dir .');
  writeln(ttext);
  for i:=1 to cnt do
  writeln(ttext, 'soundfont ', sfs[i]);
  writeln(ttext);
  closefile(ttext);
  Form2.Hide;
end;

procedure TForm2.Button7Click(Sender: TObject);
begin
  Form2.Hide;
end;

end.
