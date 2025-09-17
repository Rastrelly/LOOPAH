unit uloopah;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, LCLType, LCLIntf, Menus, Windows;

type

  { TLOOPAH }

  TLOOPAH = class(TForm)
    BtnInit: TButton;
    Button1: TButton;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListBox1:TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Quit: TMenuItem;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SEH: TSpinEdit;
    SEW: TSpinEdit;
    SETop: TSpinEdit;
    SELeft: TSpinEdit;
    Timer1: TTimer;
    procedure BtnInitClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CallEnumWindows;
    procedure ForceReinit(mode:integer);
  private

  public

  end;

var
  LOOPAH: TLOOPAH;
  ScreenDC:HDC;
  sx,sy,sw,sh:integer;
  devsize,currentCursorPos:TPoint;
  run:boolean=false;
  trackCursor:boolean=false;
  hwndArr:array of HWND;
  captureWindow:HWND;

implementation

{$R *.lfm}

{ TLOOPAH }

function EnumWindowsProc(wHandle: HWND; lp:LPARAM): Bool; stdcall;
var
  Title, ClassName: array[0..255] of char;
begin
  GetWindowText(wHandle, Title, 255);
  GetClassName(wHandle, ClassName, 255);
  if IsWindowVisible(wHandle) then
  begin
     LOOPAH.ListBox1.Items.Add(string(Title) + '-' + string(ClassName));
     setlength(hwndArr,Length(hwndArr)+1);
     hwndArr[High(hwndArr)]:=wHandle;
  end;
  Result := True;
end;

procedure TLOOPAH.CallEnumWindows;
begin
  LOOPAH.ListBox1.Items.Clear;
  setlength(hwndArr,0);
  EnumWindows(@EnumWindowsProc, LPARAM(0));
end;

procedure TLOOPAH.ForceReinit(mode:integer);
begin
  if (mode=0) then
  begin
     RadioButton1.Checked:=true;
     RadioButton2.Checked:=false;
  end
  else
  begin
    RadioButton1.Checked:=false;
    RadioButton2.Checked:=true;
  end;
  BtnInit.Click;
end;

procedure TakeScreenShot(var mypic:TImage; x,y,w,h:integer);
var tmpbmp:Graphics.TBitmap;
    propw,proph,mpw,mph:real;
begin
  tmpbmp:=Graphics.TBitmap.Create;
  mypic.picture.bitmap.Width:=mypic.Width;
  mypic.picture.bitmap.Height:=mypic.Height;
  tmpbmp.Width:=devsize.X;
  tmpbmp.Height:=devsize.Y;
  mypic.Canvas.Brush.Color := clWhite;
  mypic.Canvas.FillRect(0, 0, mypic.Width, mypic.Height);
  BitBlt(tmpbmp.Canvas.Handle, 0, 0, devsize.X, devsize.X, ScreenDC, 0, 0, SRCCOPY);
  if (not LOOPAH.CheckBox1.Checked) then
     mypic.Canvas.CopyRect(Classes.Rect(0,0,mypic.Width,mypic.Height),tmpbmp.Canvas,Classes.Rect(x,y,x+w,y+h))
  else
  begin
     proph:=1; propw:=1;
     mpw:=1; mph:=1;
     if (w>h) then proph:=h/w;
     if (w<=h) then propw:=w/h;
     if (w>h) then
     begin
       mph:=mypic.Height/mypic.Width;
       mypic.Canvas.CopyRect(Classes.Rect(0,0,round(mypic.Width*propw),round(mypic.Width*proph)),tmpbmp.Canvas,Classes.Rect(x,y,x+w,y+h));
     end;
     if (w<=h) then
     begin
       mpw:=mypic.Width/mypic.Height;
       mypic.Canvas.CopyRect(Classes.Rect(0,0,round(mypic.Height*propw),round(mypic.Height*proph)),tmpbmp.Canvas,Classes.Rect(x,y,x+w,y+h));
     end;

  end;
  FreeAndNil(tmpbmp);
end;

procedure TLOOPAH.BtnInitClick(Sender: TObject);
var useHWND:HWND;
begin
  if (RadioButton1.Checked) then useHWND:=GetDesktopWindow;
  if (RadioButton2.Checked) then useHWND:=captureWindow;
  ScreenDC:=GetDC(useHWND);
  GetWindowSize(useHWND,devsize.X,devsize.Y);
  run:=true;
end;

procedure TLOOPAH.Button1Click(Sender: TObject);
begin
  CallEnumWindows;
end;

procedure TLOOPAH.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ReleaseDC(GetDesktopWindow,ScreenDC);
end;

procedure TLOOPAH.FormCreate(Sender: TObject);
begin

end;

procedure TLOOPAH.ListBox1Click(Sender: TObject);
begin
  if ((ListBox1.ItemIndex<>-1) and (ListBox1.ItemIndex<Length(hwndArr))) then
  begin
     captureWindow:=hwndArr[ListBox1.ItemIndex];
     ForceReinit(1);
  end;
end;

procedure TLOOPAH.ListBox1SelectionChange(Sender: TObject; User: boolean);
begin
  ListBox1.Click;
end;

procedure TLOOPAH.MenuItem2Click(Sender: TObject);
begin
  BtnInit.Click;
end;

procedure TLOOPAH.MenuItem3Click(Sender: TObject);
begin
  if (not trackCursor) then
    trackCursor:=true
  else
    trackCursor:=false;
end;

procedure TLOOPAH.MenuItem4Click(Sender: TObject);
begin
  if Panel1.Visible then
  begin
    Panel1.Visible:=false;
    ListBox1.Visible:=false;
  end
  else
  begin
    Panel1.Visible:=true;
    ListBox1.Visible:=true;
  end;
end;

procedure TLOOPAH.MenuItem5Click(Sender: TObject);
var pt:POINT;
begin
  pt.X:=currentCursorPos.X;
  pt.Y:=currentCursorPos.Y;
  captureWindow := WindowFromPoint(pt);
end;

procedure TLOOPAH.QuitClick(Sender: TObject);
begin
  Close;
end;

procedure TLOOPAH.Timer1Timer(Sender: TObject);
begin
  currentCursorPos:=Mouse.CursorPos;
  if (run) then
  begin
    sx:=SELeft.Value;
    sy:=SETop.Value;
    sw:=SEW.Value;
    sh:=SEH.Value;
    TakeScreenShot(Image1,sx,sy,sw,sh);
  end;
  if (trackCursor) then
  begin
    SELeft.Value:=currentCursorPos.x;
    SETop.Value:=currentCursorPos.y;
  end;
end;

end.

