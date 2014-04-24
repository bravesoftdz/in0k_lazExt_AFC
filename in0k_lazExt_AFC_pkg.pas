{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit in0k_lazExt_AFC_pkg;

interface

uses
  in0k_lazExt_AFC_reg, in0k_lazExt_AFC, in0k_lazExt_AFC_wndCFG, 
  in0k_lazExt_AFC_synEdit, in0k_lazExt_HFC_core, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('in0k_lazExt_AFC_reg', @in0k_lazExt_AFC_reg.Register);
end;

initialization
  RegisterPackage('in0k_lazExt_AFC_pkg', @Register);
end.
