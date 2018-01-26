unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function CheckFileExt(FileName, FileExt: string): Boolean;

implementation

function CheckFileExt(FileName, FileExt: string): Boolean;
begin
  // please do text encoding convert manually
  Result := false;
  FileExt := LowerCase(FileExt);
  FileName := LowerCase(ExtractFileExt(FileName));
  if (FileName = FileExt) then
    Result := true;
end;

end.

