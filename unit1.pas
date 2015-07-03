unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Process, Inifiles, Windows, Menus,
  jwaTlHelp32, Unit2, Unit3, glass, {bassmidi ,bass ,} JwaWinBase; //JwaWinBase for OpenThread()

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Button4: TBitBtn;
    Button3: TBitBtn;
    Button2: TBitBtn;
    Button1: TBitBtn;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Timer1: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem26Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure ModifySF(sf: string);
    procedure language2chs;
    procedure language2eng;
    procedure Panel1Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure play;
    procedure stop;
    procedure saveSf2List;
    procedure saveSf2FormCfg;
    procedure LoadSf2FormIni;
    procedure delay(msecs: integer);
    procedure Timer1Timer(Sender: TObject);
    procedure updateInit;
    function playFormPath(path:string):Boolean;
    function convFormPath(path:string):Boolean;
    procedure ClearCusSf2List;
    procedure ReflashListFormCfg;
    function RefreshList: boolean;
    Function ResumeProcess(ProcessID: DWORD): Boolean;
    function SuspendProcess(PID:DWORD):Boolean;
    function FileList(Path,FileExt:string):TStringList ;
    {function MidiTotalTime(MidiFilePath:string):Double;   //time length }
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  pdf, aaa, adv, useAero, haveInifile, chs, PLPanel: boolean;   //pdf : drag and drop file
  filename: string;
  hw: hwnd;
  onPlay : integer;
  CnfFile: Tinifile;
  cxLeftWidth,cxRightWidth,cyBottomHeight,cyTopHeight:integer;
  min,sec,stopv:integer;              //Play Timer
  sf2count,sf2countlog:integer; //soundfont file in timidity.cfg count and history count
  haveCusSf2,loadHistorySf2:integer;//if cfg are using MSGS or TimiGS then load history cus sf2

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.RefreshList: boolean;
var
  ProcessName: string;
  //ProcessID: integer;
  //Pubstr: string;
  ContinueLoop: boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while ContinueLoop do
  begin
    ProcessName := FProcessEntry32.szExeFile;
    //ProcessID := FProcessEntry32.th32ProcessID;
    //Listbox1.Items.add(''+ProcessName +''+ inttostr(ProcessID));
    if ProcessName = 'timidity.exe' then
      exit(True);
    //pubstr:=ProcessName+makespace(20-length(ProcessName))+inttostr(ProcessID);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  exit(False);
end;

procedure TForm1.ClearCusSf2List;
var i:integer;
begin
  MenuItem11.Caption := 'Custom SoundFonts';
  if menuitem11.Count>=1 then begin
   for i := menuitem11.Count downto 1 do
     menuitem11.items[i-1].destroy;
  end;
end;

procedure TForm1.Delay(msecs: integer);
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

procedure TForm1.Timer1Timer(Sender: TObject);
var
  s_sec,s_min:string;
begin
  if sec<60 then
    sec:=sec+1
  else begin
    min:=min+1;
    sec:=0;
  end;
  if sec<10 then s_sec:='0'+inttostr(sec) else s_sec:=inttostr(sec);
  if min<10 then s_min:='0'+inttostr(min) else s_min:=inttostr(min);
  StaticText2.Caption:=s_min+':'+s_sec;
end;

procedure TForm1.updateInit;
begin
  CnfFile := Tinifile.Create('.\playerConfig.ini');
  //init
  CnfFile.WriteBool('Config','autoPlayDrop',pdf);
  CnfFile.WriteBool('Config','autoRepeat',aaa);
  CnfFile.WriteBool('Config','useAero',useAero);
  CnfFile.WriteBool('Config','languageCHS',chs);
  if loadHistorySf2=0 then begin
    CnfFile.WriteString('Advanced','sf2count',inttostr(sf2count));
    sf2countlog:=sf2count;
  end;
end;

procedure TForm1.play;
var
  proc: TProcess;
  pth: string;
  p: PChar;
begin
  //Timer part
  sec:=0; min:=0;
  Timer1.Enabled:=true;
  //Main part
  pth := ExtractFilePath(ParamStr(0));
  p := PChar(pth + 'timidity.exe "' + filename + '" -Od');
  //p := PChar(pth + 'timidity.exe "' + filename); 其实这个和上面那个没区别= =
  proc := TProcess.Create(nil);
  proc.CommandLine := p;
  proc.Options := proc.Options + [poNoConsole, poUsePipes];
  proc.Execute;
  delay(500);
  Memo1.Lines.LoadFromStream(proc.Output);
  while RefreshList do
  begin
    delay(100);
  end;
  proc.Free;
  Timer1.Enabled:= false;
  Button4.Enabled:= false;
end;

procedure TForm1.stop;
var
  proc: TProcess;
  p: PChar;
begin
  //Timer part
  sec:=0; min:=0;
  Timer1.Enabled:=false;
  //Main Part
  p := PChar('taskkill.exe /f /im timidity.exe');
  proc := TProcess.Create(nil);
  proc.CommandLine := p;
  proc.Options := [poNoConsole];
  proc.Execute;
  proc.Free;
  if MenuItem17.Checked then
  begin
    MenuItem17.Checked := False;
  end;
end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of string);
begin
  //PlayTimerStuff
  StaticText2.Caption:='00:00';
  //mian stuff
  filename := utf8toansi(FileNames[0]);
  if ExtractFileExt(ansitoutf8(filename)) <> '.mid' then exit;
  Label1.Caption := 'Path: '+ExtractFilePath(ansitoutf8(filename));
  Label1.Hint := ansitoutf8(filename);
  StaticText1.Caption := ExtractFileName(ansitoutf8(filename));
  StaticText1.Hint := ExtractFileName(ansitoutf8(filename));
  Button1.Enabled := True;
  Button4.Enabled := False;
  Button2.Enabled := False;
  Button3.Enabled := True;
  MenuItem12.Enabled := True;
  if not pdf then
    exit;
  if RefreshList then
  begin
    stop;
    delay(500);
  end;
  onPlay:=1;
  Button2.Enabled := True;
  Button4.Enabled := True;
  Button1.Enabled := False;
  play;
  Button1.Enabled := True;
  Button2.Enabled := False;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (ssLeft in Shift) then begin
  ReleaseCapture;
  SendMessage(Form1.Handle,WM_SYSCOMMAND,SC_MOVE+1,0);
  end;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  MenuItem11.Checked := True;
  MenuItem8.Checked := False;
  MenuItem9.Checked := False;
  if haveCusSf2=0 then begin LoadSf2FormIni; haveCusSf2:=1; end
  else begin saveSf2List; ClearCusSf2List; LoadSf2FormIni; ReflashListFormCfg  end ;
  if sf2countlog>1 then
    MenuItem11.Caption := 'Custom SoundFonts'
    else MenuItem11.Caption := 'Custom SoundFont: '+MenuItem11.items[sf2count-1].Caption;
end;

procedure TForm1.Label4Click(Sender: TObject);
var i:integer;
begin
  listbox1.Clear;
  for i:=0 to ListBox2.Items.Count-1 do
  {ListBox1.Items[i] := ExtractFileName(ListBox2.Items[i])}showmessage(ExtractFileName(ListBox2.Items[i]));
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word);
var
  s:string;
  i:integer;
begin
  if Key = VK_DELETE then begin
     ListBox2.Items.Delete(ListBox1.ItemIndex);
     ListBox1.Items.Delete(ListBox1.ItemIndex);
  end;
  if Key = VK_INSERT then begin
     OpenDialog1.Execute;
     s := OpenDialog1.FileName;
     ListBox2.Items.Add(S);
     for i:=0 to ListBox2.Items.Count-1 do
     listbox1.Items.add(ExtractFileName(ListBox2.Items[i]));
  end;
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
var
  sfn, ts: string;
begin
  OpenDialog2.Execute;
  sfn := OpenDialog2.FileName;
  ts := copy(sfn, length(sfn) - 3, 4);
  if ((ts <> '.sf2') and (ts <> '.SF2')) then
    exit;
  ModifySF(sfn);
  MenuItem8.Checked := False;
  MenuItem9.Checked := False;
  MenuItem11.Checked := True;
  MenuItem11.Enabled := True;
  MenuItem18.Checked := False;
  ReflashListFormCfg;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  //don't care here is nothing
  if adv then begin
  ClearCusSf2List;
  if (loadHistorySf2=0) or (menuitem11.count=0) then
  ReflashListFormCfg;
  adv := not adv;
  end;
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
var
  pth: string;
  p: PChar;
  proc: TProcess;
begin
  Button3.Enabled := False;
  Button3.Caption := 'Converting...';
  MenuItem12.Enabled := False;
  pth := ExtractFilePath(ParamStr(0));
  p := PChar(pth + 'timidity.exe "' + filename + '" -Ow');
  proc := TProcess.Create(nil);
  proc.CommandLine := p;
  proc.Options := [poNoConsole, poUsePipes];
  proc.Execute;
  delay(500);
  Memo1.Lines.LoadFromStream(proc.Output);
  proc.Free;
  while RefreshList do
    delay(100);
  Button3.Caption := 'Convert to Wav';
  Button3.Enabled := True;
  MenuItem12.Enabled := True;
end;

procedure TForm1.MenuItem14Click(Sender: TObject);
var
  hc: ansistring;
begin
  if chs then begin
  hc := 'BLumia''s Timidity Shell使用帮助' + #10;
  hc := hc + '你可以通过拖放文件到本程序框体或通过点击“文件”>“打开”来打开一个midi文件'
    + #10;
  hc := hc + '之后您就可以通过本程序来播放此文件或将文件转换为wav格式的文件了。' + #10;
  hc := hc + '若要转换wav格式，输出的文件将与源文件所在目录相同' +
    #10 + #10;
  hc := hc + '本播放器支持使用音源（SoundFont）并提供了一套较为方便的音源配置方案' + #10;
  hc := hc + '你可以“音源”菜单来方便的配置本播放器所使用的音源。'
    + #10+ #10;
  hc := hc + '本播放器支持播放列表功能，你可以通过文件夹的方式方便的导入你的mid文件'+ #10;
  hc := hc + '您也能通过这个方式批量转换mid到wav格式。你可以通过Insert和Delete键调整列表。'
    + #10 + #10;
  hc := hc + '访问blog.blumia.cn获取软件更新以及更多同同开发者应用。';
  end else begin
  hc := 'BLumia''s Timidity Shell Help' + #10;
  hc := hc + 'You can open a file by dropping a file into this application or use File-Open'
    + #10;
  hc := hc + 'Then you can play it or convert to a wave file' + #10;
  hc := hc + 'The wave file output folder is the same as the source file folder' +
    #10 + #10;
  hc := hc + 'This player supports SoundFont Technology' + #10;
  hc := hc + 'You can change the SoundFont used by the player by using the SoundFont Menu'
    + #10+ #10;
  hc := hc + 'This Player support PlayList function. You can use this function to manager your midi files'
    + #10+ #10;
  hc := hc + 'Visit blog.blumia.cn to focus update or other interesting stuff. XD';
  end;
  Application.MessageBox(PChar(hc), 'BLumia''s Timidity Help', 0);
end;

procedure TForm1.MenuItem15Click(Sender: TObject);
begin
  Form3.Show;
end;

procedure TForm1.MenuItem16Click(Sender: TObject);
var
  i: longint;
begin
  if not MenuItem16.Checked then
  begin
    MenuItem16.Checked := True;
    i := 155;
    while i <= 430 do
    begin
      Form1.Height := i;
      Inc(i, 5);
      delay(1);
    end;
  end
  else
  begin
    MenuItem16.Checked := False;
    i := 430;
    while i >= 155 do
    begin
      Form1.Height := i;
      Dec(i, 5);
      delay(1);
    end;
  end;
end;

procedure TForm1.MenuItem17Click(Sender: TObject);
begin
  MenuItem17.Checked := not MenuItem17.Checked;
  aaa := not aaa;
  updateInit;
end;

procedure TForm1.MenuItem18Click(Sender: TObject);
begin
  adv:=True;
  MenuItem8.Checked := False;
  MenuItem9.Checked := False;
  MenuItem11.Checked := False;
  Form2.Visible := True;
end;

procedure TForm1.MenuItem20Click(Sender: TObject);
begin
  if FileExists('.\playerConfig.ini') then begin
     DeleteFile('.\playerConfig.ini');
     showmessage('playerConfig.ini cleared successful!'+ #10+'Restart this program to apply changes.')
  end else
     showmessage('Player config file not found.')  ;
end;

procedure TForm1.MenuItem21Click(Sender: TObject);
begin
  Form1.Color:=clDefault; //clWhite
  StaticText1.Color:=clDefault;
  StaticText1.Font.Color:=clDefault;
  StaticText2.Color:=clDefault;
  StaticText2.Font.Color:=clDefault;
  Label1.Font.Color:=clDefault;
  Label2.Font.Color:=clDefault;
  Button1.Color:=clDefault;
  Button2.Color:=clDefault;
  Button3.Color:=clDefault;
  Button4.Color:=clDefault;
end;

procedure TForm1.MenuItem23Click(Sender: TObject);
begin
  if chs then begin
  language2eng;
  chs:=False;
  updateInit;
  end;
end;

procedure TForm1.MenuItem24Click(Sender: TObject);
begin
  if not chs then begin
  language2chs;
  chs:=True;
  updateInit;
  end;
end;

procedure TForm1.MenuItem26Click(Sender: TObject);
begin
  MenuItem26.Checked := not MenuItem26.Checked;
  useAero := not useAero;
  updateInit;
  showmessage('Done.'+ #10+'Restart this program to apply changes.')
end;

procedure TForm1.MenuItem27Click(Sender: TObject);
begin
  Form1.Color:=clBlack; //clWhite
  StaticText1.Color:=clBlack;
  StaticText1.Font.Color:=clWhite;
  StaticText2.Color:=clBlack;
  StaticText2.Font.Color:=clWhite;
  Label1.Font.Color:=clWhite;
  Label2.Font.Color:=clWhite;
  Button1.Color:=clBlack;
  Button2.Color:=clBlack;
  Button3.Color:=clBlack;
  Button4.Color:=clBlack;
end;

procedure TForm1.MenuItem28Click(Sender: TObject);
var
  i :integer;
begin
  if Form1.Width<600 then begin
  i := 509;
  while i <= 778 do
  begin
    Form1.Width := i;
    Inc(i, 5);
    delay(1);
  end;
  Form1.Width := 778;
  end else begin
    i := 778;
    while i >= 509 do
    begin
      Form1.Width := i;
      Dec(i, 5);
      delay(1);
    end;
    Form1.Width := 509;
  end;
end;

procedure TForm1.MenuItem29Click(Sender: TObject);
begin
Form1.Color:=clWindow; //clWhite
StaticText1.Color:=clWindow;
StaticText1.Font.Color:=clDefault;
StaticText2.Color:=clWindow;
StaticText2.Font.Color:=clDefault;
Label1.Font.Color:=clDefault;
Label2.Font.Color:=clDefault;
Button1.Color:=clDefault;
Button2.Color:=clDefault;
Button3.Color:=clDefault;
Button4.Color:=clDefault;
end;

procedure TForm1.ModifySF(sf: string);
var
  ttext: Text;
begin
  if haveInifile then saveSf2List;//saveSf2FormCfg
  assignfile(ttext, 'timidity.cfg');
  rewrite(ttext);
  writeln(ttext, 'dir .');
  writeln(ttext, 'dir .');
  writeln(ttext);
  writeln(ttext, 'soundfont ', sf);
  writeln(ttext);
  closefile(ttext);
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  ts: string;
begin
  //PlayTimerStuff
  StaticText2.Caption:='00:00';
  //mian stuff
  OpenDialog1.Execute;
  filename := utf8toansi(OpenDialog1.FileName);
  ts := copy(filename, length(filename) - 3, 4);
  if ((ts <> '.mid') and (ts <> '.MID')) then
    exit;
  Label1.Caption := 'Path: '+ExtractFilePath(ansitoutf8(filename));
  Label1.Hint := ansitoutf8(filename);
  StaticText1.Caption := ExtractFileName(ansitoutf8(filename));
  StaticText1.Hint := ExtractFileName(ansitoutf8(filename));
  Button1.Enabled := True;
  Button4.Enabled := True;
  Button3.Enabled := True;
  MenuItem12.Enabled := True;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  if RefreshList then
  begin
    stop;
    delay(500);
  end;
  Button2.Enabled := True;
  MenuItem4.Enabled := True;
  Button1.Enabled := False;
  MenuItem3.Enabled := False;
  play;
  while MenuItem17.Checked do
    play;
  Button1.Enabled := True;
  MenuItem3.Enabled := True;
  Button2.Enabled := False;
  MenuItem4.Enabled := False;
  if aaa then
    MenuItem17.Checked := True;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  Button1.Enabled := True;
  MenuItem3.Enabled := True;
  Button2.Enabled := False;
  MenuItem4.Enabled := False;
  stop;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  if MenuItem5.Checked then
  begin
    pdf := False;
    MenuItem5.Checked := False;
    updateInit;
  end
  else
  begin
    pdf := True;
    MenuItem5.Checked := True;
    updateInit;
  end;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  stopv:=1;
  stop;
  showmessage('szO Yousei Cirno Orz');
  close;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  if haveInifile then saveSf2List;//saveSf2FormCfg
  loadHistorySf2:=1;
  ModifySF('MicrosoftGS.sf2');
  MenuItem8.Checked := True;
  MenuItem9.Checked := False;
  MenuItem11.Checked := False;
  Label2.Caption:='MSGS';
  MenuItem18.Checked := False;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  if haveInifile then saveSf2List;//saveSf2FormCfg
  loadHistorySf2:=1;
  ModifySF('TimGM6mb.sf2');
  MenuItem8.Checked := False;
  MenuItem9.Checked := True;
  MenuItem11.Checked := False;
  Label2.Caption:='TimGM';
  MenuItem18.Checked := False;
end;

procedure TForm1.saveSf2List;
var i:integer;
begin
  for i := 1 to Menuitem11.Count do
    CnfFile.WriteString('Sf2History',inttostr(i),MenuItem11.items[i-1].caption);
end;

procedure TForm1.ReflashListFormCfg;
var
    MenuItem:TMenuItem;   //temp soundfont menu item
    i:integer;
    ttext: Text;
    ts: string;
begin
  if haveInifile then begin
  i := 0;
  ClearCusSf2List;
  assignfile(ttext, 'timidity.cfg');
  reset(ttext);
  while not EOF(ttext) do
  begin
    readln(ttext, ts);
    if (copy(ts, 1, 9) = 'soundfont') then
    begin
      Delete(ts, 1, 10);
      //------
      MenuItem:=TMenuItem.Create(self);
      MenuItem.Caption:=ts;
      MenuItem.OnClick:=Label3.OnClick;
      MenuItem11.Add(MenuItem);
      //------
      Label2.Caption:=ExtractFileName(ts);
      inc(i);
    end;
  end;
  CnfFile.WriteString('Advanced','sf2count',inttostr(i));
  sf2countlog:=i;
  closefile(ttext);
  if (i > 1) then
     begin
        MenuItem11.Enabled:=True;
        Label2.Caption:=ExtractFileName(ts)+'[M]';
     end;
  end;
end;

procedure TForm1.saveSf2FormCfg;
var
    i:integer;
    ttext: Text;
    ts: string;
begin
  if haveInifile then begin
  i := 0;
  assignfile(ttext, 'timidity.cfg');
  reset(ttext);
  while not EOF(ttext) do
  begin
    readln(ttext, ts);
    if (copy(ts, 1, 9) = 'soundfont') then
    begin
      Delete(ts, 1, 10);
      CnfFile.WriteString('Sf2History',inttostr(i),ts);
      inc(i);
    end;
  end;
  CnfFile.WriteString('Advanced','sf2count',inttostr(i));
  sf2countlog:=i;
  closefile(ttext);
  end;
end;

procedure TForm1.LoadSf2FormIni;
var
  i : integer;
  ttext: Text;
begin
  assignfile(ttext, 'timidity.cfg');
  rewrite(ttext);
  writeln(ttext, 'dir .');
  writeln(ttext, 'dir .');
  writeln(ttext);
  for i := 1 to sf2countlog do begin
    writeln(ttext, 'soundfont ', cnffile.readstring('Sf2History',inttostr(i),'MicrosoftGS.sf2') );
    Label2.Caption:=ExtractFileName(cnffile.readstring('Sf2History',inttostr(i),'MSGS'));
  end;
  if sf2countlog>1 then Label2.Caption:=Label2.Caption+'[M]';
  writeln(ttext);
  closefile(ttext);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i : integer;
  ttext: Text;
  ts: string;
  tmpMargins: TMargins; //aero
  MenuItem:TMenuItem;   //temp soundfont menu item
  ZAppName: array[0..127] of char;   //禁止多开所用
  Hold: String;                      //禁止多开所用
  Found: HWND;                       //禁止多开所用
  isDebug:boolean;       //...
begin

  //make sure something..
  setCurrentDirectory(PChar(ExtractFilePath(Application.EXEName)));
  isDebug:=False;        //True or False
  if not isDebug then begin
     Hold := Application.Title;         //禁止多开所用
     Application.Title := 'OnlyOne' + IntToStr(HInstance);
     StrPCopy(ZAppName, Hold);
     Found := FindWindow(nil, ZAppName);
     Application.Title := Hold;
     if Found<>0 then
     begin
        ShowWindow(Found, SW_RESTORE);
        Application.Terminate;
     end;

     MenuItem28.Visible:=False;
  end else showmessage('Debug Version!!');
  //init part by blumia
  stopv:= 0;//这是一个用于播放列表的变量，使在播放列表过程中可以通过按下Stop来停止播放
  pdf := False;
  aaa := False;
  adv := False;
  chs := True;
  useAero:=False;
  Timer1.Enabled:= false;
  StaticText2.Caption:='00:00';
  PLPanel:= false;
  panel2.Top:=388;
  panel2.Height:=23;
  sf2count:=0;
  sf2countlog:=0;
  haveCusSf2:=0;
  loadHistorySf2:=0;
  haveInifile:=False;
  onPlay:=0;
  Form1.Width:=509;
  Form1.Height:=155;

  if FileExists(pchar('.\playerConfig.ini')) then
  begin
    haveInifile:=True;
     CnfFile := Tinifile.Create('.\playerConfig.ini');
     if (cnffile.readstring('Config','autoPlayDrop','1')='1') then
     begin
        pdf := True;
        MenuItem5.Checked := True;
     end else begin
       pdf := False;
       MenuItem5.Checked := False;
     end;
     if (cnffile.readstring('Config','autoRepeat','1')='1') then
     begin
        aaa := True;
        MenuItem17.Checked := True;
     end else begin
       aaa := False;
       MenuItem17.Checked := False;
     end;
     if (cnffile.readstring('Config','useAero','1')='1') then
     begin
       useAero := True;
       MenuItem26.Checked := True;
     end else begin
       useAero := False;
       MenuItem26.Checked := False;
     end;
     sf2countlog:= cnffile.readinteger('Advanced','sf2count',0);
     chs:= cnffile.readbool('Config','languageCHS',False);
     haveCusSf2:= cnffile.readinteger('Advanced','haveCusSf2',0);
     loadHistorySf2:= cnffile.readinteger('Advanced','loadHistorySf2',0);
  end;

  if not FileExists('.\timidity.exe') then begin
     showmessage('timidity.exe not found,this program will be closed!');
     halt;
  end;
  assignfile(ttext, 'timidity.cfg');
  if not FileExists('.\timidity.cfg') then begin
    if MessageDlg('timidity.cfg not found. Create a new one?',mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
       ModifySF('MicrosoftGS.sf2');
       reset(ttext);
    end
    else begin
    showmessage('This program cannot be execused without timidity.cfg.Program will be closed!');
    halt;
    end;
  end
  else reset(ttext);

  //timidity.cfg reading part--------

  while not EOF(ttext) do
  begin
    readln(ttext, ts);
    //showmessage('reading text:'+ts);            <-- debug line
    if (copy(ts, 1, 9) = 'soundfont') then
    begin
      inc(sf2count);
      //showmessage('sf2 count:'+inttostr(sf2count)); debug line
      Delete(ts, 1, 10);
      if (sf2count=1) then begin
          case ExtractFileName(ts) of
            'MicrosoftGS.sf2':
            begin
              MenuItem8.Checked := True;
              MenuItem9.Checked := False;
              MenuItem11.Checked := False;
              MenuItem11.Enabled := False;
              MenuItem18.Checked := False;
              loadHistorySf2 := 1;
              Label2.Caption:='MSGS';
            end;
            'TimGM6mb.sf2':
            begin
              MenuItem8.Checked := False;
              MenuItem9.Checked := True;
              MenuItem11.Checked := False;
              MenuItem11.Enabled := False;
              MenuItem18.Checked := False;
              loadHistorySf2 := 1;
              Label2.Caption:='TimGM';
            end;
            else
            begin
              MenuItem8.Checked := False;
              MenuItem9.Checked := False;
              MenuItem11.Checked := True;
              MenuItem11.Enabled := True;
              MenuItem18.Checked := False;
              MenuItem11.Caption := 'Custom SoundFont: ' + ExtractFileName(ts);
              loadHistorySf2 := 0;
              haveCusSf2:=1;
              Label2.Caption:=ExtractFileName(ts);
            end;
          end;
      end else begin
            MenuItem8.Checked := False;
            MenuItem9.Checked := False;
            MenuItem11.Checked := True;
            MenuItem11.Enabled := True;
            MenuItem18.Checked := True;
            MenuItem11.Caption := 'Custom SoundFonts';
            loadHistorySf2 := 0;
            haveCusSf2:=1;
            Label2.Caption:=ExtractFileName(ts)+'[M]';
      end;
      //------
      MenuItem:=TMenuItem.Create(self);
      MenuItem.Caption:=ts;
      MenuItem.OnClick:=Label3.OnClick;
      MenuItem11.Add(MenuItem);
      //------
    end;
  end;
  UpdateInit;
  //showmessage(inttostr(sf2count)+'--'+inttostr(loadHistorySf2));
  //---------------------------------

  closefile(ttext);

  if haveInifile then begin
    if (haveCusSf2=1) then saveSf2List;
    if loadHistorySf2=1 then
    begin
      ClearCusSf2List;
      for i := 1 to sf2countlog do begin
      MenuItem11.Enabled := True;
      //------ get list form ini file
      MenuItem:=TMenuItem.Create(self);
      MenuItem.Caption:=cnffile.readstring('Sf2History',inttostr(i),'MicrosoftGS.sf2');
      MenuItem.OnClick:=Label3.OnClick;
      MenuItem11.Add(MenuItem);
      //------
      end;
    end
  end;

  // fun stuff -- aero glass
  if useAero then begin
    cxLeftWidth    := cnffile.readinteger('Aero','cxLeftWidth',-1);
    cxRightWidth   := cnffile.readinteger('Aero','cxRightWidth',-1);
    cyBottomHeight := cnffile.readinteger('Aero','cyBottomHeight',-1);
    cyTopHeight    := cnffile.readinteger('Aero','cyTopHeight',-1);
    // If all margins are -1 the whole form will be aero glass
    tmpMargins.cxLeftWidth    := cxLeftWidth;
    tmpMargins.cxRightWidth   := cxRightWidth;
    tmpMargins.cyBottomHeight := cyBottomHeight;
    tmpMargins.cyTopHeight    := cyTopHeight;
    { FormName ; Margins ; TransparentColor }
    GlassForm(Form1, tmpMargins, clFuchsia);
  end;

  if chs then language2chs ;
  if chs then begin
    StaticText1.Caption:='没有文件被加载.';
    Label1.Caption:='没有文件被加载.';
  end else begin
    //don't care if here are nothing..
  end;
  SendMessage(Listbox2.Handle, LB_SetHorizontalExtent, 1000, Longint(0));

  //参数检测
  if paramcount>0 then begin
  //showmessage(pchar(ansitoutf8(paramstr(1))));
     if FileExists(pchar(paramstr(1))) then begin
        if ExtractFileExt(paramstr(1))='.mid' then begin
          filename := utf8toansi(ansitoutf8(paramstr(1)));
          //showmessage(filename);诶。。我说Lazarus啊。。这看上去一坨屎的ansi字符串您照样用诶。。
          Label1.Caption := 'Path: '+ExtractFilePath(ansitoutf8(filename));
          Label1.Hint := ansitoutf8(filename);
          StaticText1.Caption := ansitoutf8(filename);
          StaticText1.Hint := ansitoutf8(filename);
          Button1.Enabled := True;
          Button2.Enabled := False;
          Button3.Enabled := True;
          MenuItem12.Enabled := True;
          if not pdf then
            exit;
          if RefreshList then
          begin
            stop;
            delay(500);
          end;
          Button2.Enabled := True;
          Button1.Enabled := False;
          play;
          Button1.Enabled := True;
          Button2.Enabled := False;
        end else begin
          showmessage('This file is NOT a midi file') ;
        end
     end else begin
        showmessage('File not found');
     end
  end else begin
     //showmessage('command paramstr not found');
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  //PlayTimerStuff
  StaticText2.Caption:='00:00';
  //mian stuff
  ReflashListFormCfg;
  if RefreshList then
  begin
    stopv:=1;
    stop;
    delay(500);
  end;
  onPlay:=1;
  Button2.Enabled := True;
  Button4.Enabled := True;
  MenuItem4.Enabled := True;
  Button1.Enabled := False;
  MenuItem3.Enabled := False;
  play;
  while MenuItem17.Checked do
    play;
  Button1.Enabled := True;
  MenuItem3.Enabled := True;
  Button2.Enabled := False;
  MenuItem4.Enabled := False;
  if aaa then
    MenuItem17.Checked := True;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i: longint;
begin
  if not MenuItem16.Checked then
  begin
    MenuItem16.Checked := True;
    i := 155;
    while i <= 430 do
    begin
      Form1.Height := i;
      Inc(i, 5);
      delay(1);
    end;
  end else begin
    MenuItem16.Checked := False;
    i := 430;
    while i >= 155 do
    begin
      Form1.Height := i;
      Dec(i, 5);
      delay(1);
    end;
  end;
  i := Panel2.Height;
  if i < 60 then begin
    while i <= 256 do
    begin
      Panel2.Top := Panel2.Top - 5;
      Panel2.Height := Panel2.Height + 5;
      Panel1.Height := Panel1.Height - 5;
      Inc(i, 5);
      delay(1);
    end;
    Panel2.Height := 256;
    Panel1.Height := 23;
    Panel2.Top := 156;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Button1.Enabled := True;
  MenuItem3.Enabled := True;
  Button2.Enabled := False;
  Button4.Enabled := False;
  MenuItem4.Enabled := False;
  stopv:=1;
  stop;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  pth: string;
  p: PChar;
  proc: TProcess;
begin
  Button3.Enabled := False;
  if chs then Button3.Caption := '转换中...'
  else Button3.Caption := 'Converting...';
  MenuItem12.Enabled := False;
  pth := ExtractFilePath(ParamStr(0));
  p := PChar(pth + 'timidity.exe "' + filename + '" -Ow');
  proc := TProcess.Create(nil);
  proc.CommandLine := p;
  proc.Options := [poNoConsole];
  proc.Execute;
  proc.Free;
  while RefreshList do
    delay(100);
  if chs then Button3.Caption := '转换为wav格式'
  else Button3.Caption := 'Convert to Wav';
  Button3.Enabled := True;
  MenuItem12.Enabled := True;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  ProcessName: string;
  ProcessID: integer;
  ContinueLoop: boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while ContinueLoop do
  begin
    ProcessName := FProcessEntry32.szExeFile;
    ProcessID := FProcessEntry32.th32ProcessID;
    //Listbox1.Items.add(''+ProcessName +''+ inttostr(ProcessID));
    if ProcessName = 'timidity.exe' then begin
      if onPlay=1 then begin
        SuspendProcess(ProcessID);
        Timer1.Enabled:= false;
        if chs then Button4.caption:='恢复' else
          Button4.caption:='Resume';
        onPlay:=0;
      end
      else begin
        ResumeProcess(ProcessID);
        Timer1.Enabled:= True;
        if chs then Button4.caption:='暂停' else
          Button4.caption:='Pause';
        onPlay:=1;
      end;
      exit;
    end;
    //pubstr:=ProcessName+makespace(20-length(ProcessName))+inttostr(ProcessID);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i : integer;
  path : string;
begin
  Button5.Enabled:=false;
  Button6.Enabled:=false;
  Button7.Enabled:=false;
  Button8.Enabled:=false;
  Button9.Enabled:=false;
  listbox1.Clear;
  if SelectDirectory('Please Select the Directory Where Your Midis Are.','',path) then
    path:=path else begin
    Button5.Enabled:=true;
    Button6.Enabled:=true;
    Button7.Enabled:=true;
    Button8.Enabled:=true;
    Button9.Enabled:=true;
    exit; end;      //千万不能ansi2utf8= =
  listbox2.Items:= FileList(path,'.mid');//注意这个函数返回的是一个Tstrings
  for i:=0 to ListBox2.Items.Count-1 do
  listbox1.Items.add(ExtractFileName(ListBox2.Items[i]));
  Button5.Enabled:=true;
  Button6.Enabled:=true;
  Button7.Enabled:=true;
  Button8.Enabled:=true;
  Button9.Enabled:=true;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  s:string;
begin
  //PlayTimerStuff
  StaticText2.Caption:='00:00';
  //mian stuff
  if RefreshList then
  begin
    stopv:=1;
    stop;
    delay(500);
  end;
  onPlay:=1;
  stopv:=0;//确保在非列表模式下按下Stop使stopv的改变不影响列表播放
  if ListBox2.Items.Count=0 then exit;
  if ListBox1.ItemIndex = -1 then
     ListBox1.Selected[0]:=True;
  ListBox2.Selected[ListBox1.ItemIndex]:=True;
  s:=listbox2.Items[listbox2.itemindex];
  while (ListBox1.ItemIndex <> (ListBox2.Items.Count-1)) and (stopv=0) do begin
  if playFormPath(s) then begin
    ListBox1.Selected[ListBox1.ItemIndex+1]:=True;
    ListBox2.Selected[ListBox1.ItemIndex]:=True;
    s:=listbox2.Items[listbox2.itemindex];
  end;
  end;
  if stopv = 0 then begin
    if playFormPath(s) then exit;
  end else begin
    ListBox1.Selected[ListBox1.ItemIndex-1]:=True;
    ListBox2.Selected[ListBox1.ItemIndex]:=True;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  s:string;
begin
  if ListBox2.Items.Count=0 then exit;
  if ListBox1.ItemIndex = -1 then
     ListBox1.Selected[0]:=True
   else begin
     if chs then showmessage('将批量转换从您当前选中的项到最后一项')
     else showmessage('this program will convert the files from the one you selected to the end one');
   end;
  ListBox2.Selected[ListBox1.ItemIndex]:=True;
  s:=listbox2.Items[listbox2.itemindex];
  while (ListBox1.ItemIndex <> (ListBox2.Items.Count-1)) and (stopv=0) do begin
  if convFormPath(s) then begin
    ListBox1.Selected[ListBox1.ItemIndex+1]:=True;
    ListBox2.Selected[ListBox1.ItemIndex]:=True;
    s:=listbox2.Items[listbox2.itemindex];
  end;
  end;
  if stopv = 0 then begin
    if convFormPath(s) then exit;
  end else begin
    ListBox1.Selected[ListBox1.ItemIndex-1]:=True;
    ListBox2.Selected[ListBox1.ItemIndex]:=True;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  ListBox2.Items.SaveToFile(ansitoutf8(ExtractFilePath(Application.ExeName))+'PlayList.btsl');
  showmessage(ansitoutf8(ExtractFilePath(Application.ExeName)));
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  i:integer;
begin
  ListBox2.Clear;     { TODO : PlayList file exist and... Load Form File Dlg }
  ListBox2.Items.LoadFromFile(ansitoutf8(ExtractFilePath(Application.ExeName))+'PlayList.btsl');
  for i:=0 to ListBox2.Items.Count-1 do
  listbox1.Items.add(ExtractFileName(ListBox2.Items[i]));
end;

procedure TForm1.FormClose(Sender: TObject);
begin
  stopv:=1;
  stop;
end;

Function TForm1.ResumeProcess(ProcessID: DWORD): Boolean;
var
  Snapshot,cThr: DWORD;
  ThrHandle: THandle;
  Thread:TThreadEntry32;
begin
  Result := False;
  cThr := GetCurrentThreadId;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if Snapshot <> INVALID_HANDLE_VALUE then
   begin
    Thread.dwSize := SizeOf(TThreadEntry32);
    if Thread32First(Snapshot, Thread) then
     repeat
      if (Thread.th32ThreadID <> cThr) and (Thread.th32OwnerProcessID = ProcessID) then
       begin
        ThrHandle := OpenThread(THREAD_ALL_ACCESS, false, Thread.th32ThreadID);
        if ThrHandle = 0 then Exit;
        ResumeThread(ThrHandle);
        CloseHandle(ThrHandle);
       end;
     until not Thread32Next(Snapshot, Thread);
     Result := CloseHandle(Snapshot);
    end;
end;

{
function TForm1.MidiTotalTime(MidiFilePath:string):Double;
var
  stream:HSTREAM;
  len:QWORD;
  time:double;
begin
  stream := BASS_MIDI_StreamCreateFile(FALSE, @MidiFilePath, 0, 0, 0, 44100);
  len:=BASS_ChannelGetLength(stream, BASS_POS_BYTE); // length in bytes
  time:=BASS_ChannelBytes2Seconds(stream, len); // the time length
end;
}

function TForm1.SuspendProcess(PID:DWORD):Boolean;
var
hSnap:  THandle;
THR32:  THREADENTRY32;
hOpen:  THandle;
begin
  Result := FALSE;
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if hSnap <> INVALID_HANDLE_VALUE then
  begin
    THR32.dwSize := SizeOf(THR32);
    Thread32First(hSnap, THR32);
    repeat
      if THR32.th32OwnerProcessID = PID then
      begin
        hOpen := OpenThread($0002, FALSE, THR32.th32ThreadID);
        if hOpen <> INVALID_HANDLE_VALUE then
        begin
          Result := TRUE;
          SuspendThread(hOpen);
          CloseHandle(hOpen);
        end;
      end;
    until Thread32Next(hSnap, THR32) = FALSE;
    CloseHandle(hSnap);
  end;
end;

procedure TForm1.language2chs;
begin
  button1.Caption:='播放';
  button4.Caption:='暂停';
  button5.Caption:='从路径加载';
  button6.Caption:='播放本列表';
  button7.Caption:='批量格式转换';
  button8.Caption:='保存列表';
  button9.Caption:='载入列表';
  button2.Caption:='停止';
  button3.Caption:='转换成wav格式';
  MenuItem1.Caption:='文件(&F)';
    MenuItem2.Caption:='打开';
    MenuItem3.Caption:='播放';
    MenuItem4.Caption:='停止';
    MenuItem12.Caption:='转换为wav格式';
    MenuItem5.Caption:='自动播放拖放的文件';
    MenuItem17.Caption:='单曲循环';
    MenuItem16.Caption:='显示控制台';
    MenuItem6.Caption:='退出';
  MenuItem7.Caption:='音源(&S)';
    MenuItem10.Caption:='选择SoundFont...';
    MenuItem18.Caption:='高级...';
  MenuItem19.Caption:='选项(&O)';
    MenuItem20.Caption:='重置播放器配置文件';
  MenuItem13.Caption:='帮助(&H)';
    MenuItem14.Caption:='帮助';
    MenuItem15.Caption:='关于';
end;

procedure TForm1.language2eng;
begin
  button1.Caption:='Play';
  button4.Caption:='Pause';
  button5.Caption:='Load from Directory';
  button6.Caption:='Play this List';
  button7.Caption:='Convert this List';
  button8.Caption:='Save List';
  button9.Caption:='Load List';
  button2.Caption:='Stop';
  button3.Caption:='Convert to Wav';
  MenuItem1.Caption:='&File';
    MenuItem2.Caption:='Open';
    MenuItem3.Caption:='Play';
    MenuItem4.Caption:='Stop';
    MenuItem12.Caption:='Convert to Wav';
    MenuItem5.Caption:='Auto Play Droped Files';
    MenuItem17.Caption:='Repeat';
    MenuItem16.Caption:='Show Console';
    MenuItem6.Caption:='Exit';
  MenuItem7.Caption:='&SoundFont';
    MenuItem10.Caption:='Select SoundFont...';
    MenuItem18.Caption:='Advanced...';
  MenuItem19.Caption:='&Options';
    MenuItem20.Caption:='Reset playerConfig File';
  MenuItem13.Caption:='&Help';
    MenuItem14.Caption:='Help';
    MenuItem15.Caption:='About';
end;

procedure TForm1.Panel1Click(Sender: TObject);
var
  i :integer;
begin
  i := Panel2.Height;
  if not i < 60 then begin
    while i >= 23 do
    begin
      Panel2.Top := Panel2.Top + 5;
      Panel2.Height := Panel2.Height - 5;
      Panel1.Height := Panel1.Height + 5;
      Dec(i, 5);
      delay(1);
    end;
    Panel2.Height := 23;
    Panel1.Height := 256;
    Panel2.Top := 388;
  end;
end;

procedure TForm1.Panel2Click(Sender: TObject);
var
  i :integer;
begin
  i := Panel2.Height;
  if i < 60 then begin
    while i <= 256 do
    begin
      Panel2.Top := Panel2.Top - 5;
      Panel2.Height := Panel2.Height + 5;
      Panel1.Height := Panel1.Height - 5;
      Inc(i, 5);
      delay(1);
    end;
    Panel2.Height := 256;
    Panel1.Height := 23;
    Panel2.Top := 156;
  end;
end;

function TForm1.FileList(Path,FileExt:string):TStringList ;
var
sch:TSearchrec;
begin
Path:=utf8toansi(Path);
Result:=TStringlist.Create;
if rightStr(trim(Path), 1) <> '\' then
    Path := trim(Path) + '\'
else
    Path := trim(Path);
if not DirectoryExists(Path) then
begin
    Result.Clear;
    exit;
end;
if FindFirst(Path + '*', faAnyfile, sch) = 0 then
begin
    repeat
       Application.ProcessMessages;
       if ((sch.Name = '.') or (sch.Name = '..')) then Continue;
       if DirectoryExists(Path+sch.Name) then //这地方加个判断，可区别子文件夹和当前文件夹的操作
       begin
         Result.AddStrings(FileList(ansitoutf8(Path+sch.Name),FileExt));
       end
       else
       begin
         if (UpperCase(extractfileext(Path+sch.Name)) = UpperCase(FileExt)) or (FileExt='.*') then
         Result.Add(ansitoutf8(Path+sch.Name));
       end;
    until FindNext(sch) <> 0;
    SysUtils.FindClose(sch);
end;
end;

function TForm1.playFormPath(path:string):Boolean;
begin
//PlayTimerStuff
StaticText2.Caption:='00:00';
//mian stuff
filename := utf8toansi(path);
if ExtractFileExt(ansitoutf8(filename)) <> '.mid' then exit;
Label1.Caption := 'Path: '+ExtractFilePath(ansitoutf8(filename));
Label1.Hint := ansitoutf8(filename);
StaticText1.Caption := ExtractFileName(ansitoutf8(filename));
StaticText1.Hint := ExtractFileName(ansitoutf8(filename));
Button1.Enabled := True;
Button4.Enabled := False;
Button2.Enabled := False;
Button3.Enabled := True;
MenuItem12.Enabled := True;
if RefreshList then
begin
  stop;
  delay(500);
end;
onPlay:=1;
Button2.Enabled := True;
Button4.Enabled := True;
Button1.Enabled := False;
play;
Button1.Enabled := True;
Button2.Enabled := False;
exit(True)
end;

function TForm1.convFormPath(path:string):Boolean;
var
  pth: string;
  p: PChar;
  proc: TProcess;
begin
  Button3.Enabled := False;
  Button7.Enabled := False;
  if chs then begin
  Button3.Caption := '转换中...';
  Button7.Caption := '转换中...';
  end else begin
  Button3.Caption := 'Converting...';
  Button7.Caption := 'Converting...';
  end;
  MenuItem12.Enabled := False;
  pth := ExtractFilePath(ParamStr(0));
  p := PChar(pth + 'timidity.exe "' + utf8toansi(path) + '" -Ow');
  proc := TProcess.Create(nil);
  proc.CommandLine := p;
  proc.Options := [poNoConsole];
  proc.Execute;
  proc.Free;
  while RefreshList do
    delay(100);
  if chs then begin
  Button3.Caption := '转换为wav格式';
  Button7.Caption := '批量格式转换';
  end else begin
  Button3.Caption := 'Convert to Wav';
  Button7.Caption := 'Convert this List';
  end;
  Button3.Enabled := True;
  Button7.Enabled := True;
  MenuItem12.Enabled := True;
  exit(True)
end;

end.

