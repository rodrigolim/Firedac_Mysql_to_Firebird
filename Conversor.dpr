program Conversor;

uses
  Vcl.Forms,
  U_Main in 'U_Main.pas' {frm_main},
  U_DM_Firebird in 'U_DM_Firebird.pas',
  U_DM_MySQL in 'U_DM_MySQL.pas',
  U_Func in 'U_Func.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfrm_main, frm_main);
  Application.Run;
end.
