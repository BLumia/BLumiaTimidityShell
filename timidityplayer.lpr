program timidityplayer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2, Unit3, RunOnce_PostIt
  { you can add units after this };

{$R *.res}

begin
  RunOnce(ParamStr(1)); // file assoc, pass arg1 to old instance.
  Application.Title:='BLumia''s Timidity Shell';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

