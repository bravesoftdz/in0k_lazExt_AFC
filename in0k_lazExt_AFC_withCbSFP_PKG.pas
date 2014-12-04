{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit in0k_lazExt_AFC_withCbSFP_PKG;

interface

uses
  in0k_lazExt_AFC_withCbSFP_reg, in0k_lazExt_AFC, in0k_lazExt_AFC_synEdit, 
  in0k_lazExt_HFC_core, in0k_lazExt_AFC_wndDBG, AFC_Config_Editor, AFC_Config, 
  AFC_Config_Handle, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('in0k_lazExt_AFC_withCbSFP_reg', 
    @in0k_lazExt_AFC_withCbSFP_reg.Register);
end;

initialization
  RegisterPackage('in0k_lazExt_AFC_withCbSFP_PKG', @Register);
end.
