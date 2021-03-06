unit glass;
 
{$mode delphi}
//{$mode objfpc}{$H+}
 
interface
 
uses
  Windows, Forms, Graphics;
 
type
  _MARGINS = packed record
    cxLeftWidth    : Integer;
    cxRightWidth   : Integer;
    cyTopHeight    : Integer;
    cyBottomHeight : Integer;
  end;
 
  PMargins = ^_MARGINS;
  TMargins = _MARGINS;
 
  DwmIsCompositionEnabledFunc      = function(pfEnabled: PBoolean): HRESULT; stdcall;
  DwmExtendFrameIntoClientAreaFunc = function(destWnd: HWND; const pMarInset: PMargins): HRESULT; stdcall;
  SetLayeredWindowAttributesFunc   = function(destWnd: HWND; cKey: TColor; bAlpha: Byte; dwFlags: DWord): BOOL; stdcall;
 
const
  WS_EX_LAYERED = $80000;
  LWA_COLORKEY  = 1;
 
procedure GlassForm(frm: TForm; tmpMargins: TMargins; cBlurColorKey: TColor = clFuchsia);
function WindowsAeroGlassCompatible: Boolean;
 
implementation
 
function WindowsAeroGlassCompatible: Boolean;
var
  osVinfo: TOSVERSIONINFO;
begin
  ZeroMemory(@osVinfo, SizeOf(osVinfo));
  OsVinfo.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFO);
  if (
  (GetVersionEx(osVInfo)   = True) and
  (osVinfo.dwPlatformId    = VER_PLATFORM_WIN32_NT) and
  (osVinfo.dwMajorVersion >= 6)
  )
  then Result:=True
  else Result:=False;
end;
 
procedure GlassForm(frm: TForm; tmpMargins: TMargins; cBlurColorKey: TColor = clFuchsia);
var
  hDwmDLL: Cardinal;
  fDwmIsCompositionEnabled: DwmIsCompositionEnabledFunc;
  fDwmExtendFrameIntoClientArea: DwmExtendFrameIntoClientAreaFunc;
  fSetLayeredWindowAttributesFunc: SetLayeredWindowAttributesFunc;
  bCmpEnable: Boolean;
  mgn: TMargins;
begin
  { Continue if Windows version is compatible }
  if WindowsAeroGlassCompatible then begin
    { Continue if 'dwmapi' library is loaded }
    hDwmDLL := LoadLibrary('dwmapi.dll');
    if hDwmDLL <> 0 then begin
      { Get values }
      @fDwmIsCompositionEnabled        := GetProcAddress(hDwmDLL, 'DwmIsCompositionEnabled');
      @fDwmExtendFrameIntoClientArea   := GetProcAddress(hDwmDLL, 'DwmExtendFrameIntoClientArea');
      @fSetLayeredWindowAttributesFunc := GetProcAddress(GetModulehandle(user32), 'SetLayeredWindowAttributes');
      { Continue if values are <> nil }
      if (
      (@fDwmIsCompositionEnabled <> nil) and
      (@fDwmExtendFrameIntoClientArea <> nil) and
      (@fSetLayeredWindowAttributesFunc <> nil)
      )
      then begin
        { Continue if composition is enabled }
        fDwmIsCompositionEnabled(@bCmpEnable);
        if bCmpEnable = True then begin
          { Set Form Color same as cBlurColorKey }
          frm.Color := cBlurColorKey;
          { ... }
          SetWindowLong(frm.Handle, GWL_EXSTYLE, GetWindowLong(frm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
          { ... }
          fSetLayeredWindowAttributesFunc(frm.Handle, cBlurColorKey, 0, LWA_COLORKEY);
          { Set margins }
          ZeroMemory(@mgn, SizeOf(mgn));
          mgn.cxLeftWidth    := tmpMargins.cxLeftWidth;
          mgn.cxRightWidth   := tmpMargins.cxRightWidth;
          mgn.cyTopHeight    := tmpMargins.cyTopHeight;
          mgn.cyBottomHeight := tmpMargins.cyBottomHeight;
          { Extend Form }
          fDwmExtendFrameIntoClientArea(frm.Handle,@mgn);
        end;
      end;
      { Free loaded 'dwmapi' library }
      FreeLibrary(hDWMDLL);
    end;
  end;
end;
 
end.