unit in0k_lazExt_AFC_withCbSFP_reg;

{$mode delphi}{$H+}

interface

uses
     AFC_Config_Editor,
     AFC_Config_Handle,
     in0k_lazExt_AFC,
     CbSFP__Intf;

procedure Register;

implementation

procedure Register;
begin
    //CbSFP_SubScriber__REGISTER(tAFC_Config_Handle,tAFC_Config_Editor);
    In0k_lazExt_AFC__CREATE;
end;

end.

