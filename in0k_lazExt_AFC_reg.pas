unit in0k_lazExt_AFC_reg;

{$mode delphi}{$H+}

interface

uses Forms, MenuIntf,
   in0k_lazExt_AFC, in0k_lazExt_AFC_wndCFG;

procedure Register;

implementation

procedure UiWND_in0k_lazExt_AFC_CFG_SHOW; register;
begin
    if not Assigned(uiWND_in0k_lazExt_AFC_CFG) then begin
        uiWND_in0k_lazExt_AFC_CFG:=TuiWND_in0k_lazExt_AFC_CFG.Create(Application);
    end;
    uiWND_in0k_lazExt_AFC_CFG.Show;
end;

procedure Register;
begin
    In0k_lazExt_AFC__CREATE;
    RegisterIDEMenuCommand(itmCustomTools,
                           cIn0k_lazExt_AFC_Name,
                           cUiWND_in0k_lazExt_AFC_CFG_Caption+' ...',
                           nil,@UiWND_in0k_lazExt_AFC_CFG_SHOW);
end;




end.

