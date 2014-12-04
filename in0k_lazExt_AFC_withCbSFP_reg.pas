unit in0k_lazExt_AFC_withCbSFP_reg;

{$mode delphi}{$H+}

interface

uses AFC_Config_Editor, AFC_Config_Handle,
    CbSFP__Intf;

procedure Register;

implementation

procedure Register;
begin
    CbSFP_SubScriber__REGISTER(tAFC_Config_Handle,tAFC_Config_Editor);
end;

end.

