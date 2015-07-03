unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure Delay(msecs: integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form3: TForm3;
  Running:boolean;
implementation

{$R *.lfm}

{ TForm3 }
procedure TForm3.Delay(msecs: integer);
var
  Tick: DWord;
  Event: THandle;
begin
  Event := CreateEvent(nil, False, False, nil);
  try
    Tick := GetTickCount + DWord(msecs);
    while (msecs > 0) and (MsgWaitForMultipleObjects(1, Event, False,
        msecs, QS_ALLINPUT) <> WAIT_TIMEOUT) do
    begin
      Application.ProcessMessages;
      msecs := Tick - GetTickCount;
    end;
  finally
    CloseHandle(Event);
  end;
end;

procedure TForm3.StaticText1Click(Sender: TObject);
var i:longint;
begin
  if Running then exit;
  if Form3.Height=275 then exit;
  if Edit1.Text='orz' then
    begin
      i:=211;
      while i<274 do
        begin
          i+=1;
          Form3.Height:=i;
          delay(1);
        end;
      Form3.Height:=275;
      Running:=true;
    end
  else
    exit;
  i:=275;
  while i>1 do
    begin
      dec(i);
      StaticText3.Top:=i;
      delay(33);
    end;
  StaticText3.Top:=0;
  delay(50);
  i:=275;
  while i>211 do
    begin
      i-=1;
      Form3.Height:=i;
      delay(1);
    end;
  Form3.Height:=211;
  Running:=false;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  Form3.Hide;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Edit1.Text:='';
  Form3.Height:=203;
  StaticText3.Top:=275;
  Running:=false;
  Button1.SetFocus;
end;

end.

