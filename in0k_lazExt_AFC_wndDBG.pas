unit in0k_lazExt_AFC_wndDBG;

{$mode objfpc}{$H+}

interface

uses Classes, Forms, StdCtrls;

const
 cUiWND_in0k_lazExt_AFC_DBG_Caption='DEBUGin "Auto Fold Comments" tool';

type

  TuiWND_in0k_lazExt_AFC_DBG = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    procedure onCreate_setTexts;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

procedure _dbgLOG_SHOW;
procedure _dbgLOG_(const dbgText:string; const textStartEnD:boolean=false);

implementation

{$R *.lfm}

const
  cUiWND_in0k_lazExt_AFC_DBG__B01_CPT='clear log';

constructor TuiWND_in0k_lazExt_AFC_DBG.Create(TheOwner: TComponent);
begin
    inherited;
    onCreate_setTexts;
end;

procedure TuiWND_in0k_lazExt_AFC_DBG.onCreate_setTexts;
begin
    self.Caption:=cUiWND_in0k_lazExt_AFC_DBG_Caption;
    Button1.Caption:=cUiWND_in0k_lazExt_AFC_DBG__B01_CPT;
    Memo1.Clear;
end;

procedure TuiWND_in0k_lazExt_AFC_DBG.Button1Click(Sender: TObject);
begin
    memo1.Clear;
end;

//==============================================================================
//==============================================================================
//==============================================================================

var _uiWND_AFC_DBG_:TuiWND_in0k_lazExt_AFC_DBG;

procedure _dbgLOG_SHOW;
begin
    if not Assigned(_uiWND_AFC_DBG_) then begin
        _uiWND_AFC_DBG_:=TuiWND_in0k_lazExt_AFC_DBG.Create(Application);
    end;
   _uiWND_AFC_DBG_.Show;
end;

{
    ~prm textStartEnD проверять ли галочку (это НЕДОРАБОТКА архитерктуры)
}
procedure _dbgLOG_(const dbgText:string; const textStartEnD:boolean=false);
begin
    if Assigned(_uiWND_AFC_DBG_)
        and
       Assigned(_uiWND_AFC_DBG_.Memo1)
    then begin
        with _uiWND_AFC_DBG_.Memo1 do begin
            Lines.Add(dbgText);
            SelStart := GetTextLen;
            SelLength:=0;
            ScrollBy (0, Lines.Count);
            Refresh;
        end;
    end;
end;

initialization
_uiWND_AFC_DBG_:=nil;
end.

