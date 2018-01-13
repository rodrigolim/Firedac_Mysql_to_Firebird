unit U_DM_Firebird;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FMTBcd, SqlExpr, Vcl.Forms,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, Datasnap.Provider,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.FB, FireDAC.Phys.FBDef;

type
  TDM_Firebird = class(TDataModule)
    Con: TFDConnection;
    QryAux: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    FInicializar: boolean;
  protected
    function ConnectDB: Boolean;
  public
    function GetData(ASQL: string; Parameters: array of Variant): OleVariant;
    function OpenSQL(ASQL: string; Parameters: array of Variant): Variant;
    procedure ExecuteSQL(ASQL: string; Parameters: array of Variant);

    property Inicializar: boolean read FInicializar;
  end;

var
  DM_Firebird: TDM_Firebird;

implementation

uses Windows, Variants, DBClient, IniFiles, Dialogs;

{$R *.dfm}

{ TDM }

function TDM_Firebird.ConnectDB: Boolean;
var
  CfgServer, CfgUser, CfgPassword, CfgOSAuthent, CfgDatadase : string;
begin
  with TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Config.ini') do
  try
      CfgServer    :=  ReadString('FIREBIRD', 'Server', 'ERROR');
      CfgUser      :=  ReadString('FIREBIRD', 'User_Name', 'Estoque');
      CfgPassword  :=  ReadString('FIREBIRD', 'Password', '15');
      CfgOSAuthent :=  ReadString('FIREBIRD', 'OSAuthent', '15');
      CfgDatadase  :=  ReadString('FIREBIRD', 'Database', 'ERROR');

      Con.Params.Clear;
      Con.Params.Add('DriverID=FB');
      Con.Params.Add('Server='+CfgServer);
      Con.Params.Add('User_Name='+CfgUser);
      Con.Params.Add('Password='+CfgPassword);
      Con.Params.Add('OSAuthent='+CfgOSAuthent);
      Con.Params.Add('Database='+CfgDatadase);

      try
        con.Open;
        Result := con.Connected;

        if not Con.Connected then Exit;
      except
        Result := False;
        Exit;
      end
  finally
    Free;
  end;
end;

procedure TDM_Firebird.DataModuleCreate(Sender: TObject);
begin
  if not ConnectDB then
    raise Exception.Create(
      '            NÃO FOI POSSÍVEL CONECTAR A BASE DO FIREBIRD!'^m+
      ''^m+
      'Possíveis problemas que podem impedir a conexão:'^m+
      '1- Confira se o Firebird está instalado e funcionando corretamente nos '#13#10 +
      'processos do windows.'#13#10 +
      '2- Confira se o arquivo "Config.ini" está configurado '#13#10 +
      'corretamente.'#13#10 +
      '3- Confira através do IBEXPERT se é possível acessar a base de DSADOS.'
    );
end;

procedure TDM_Firebird.DataModuleDestroy(Sender: TObject);
begin
  Con.Close;
end;

procedure TDM_Firebird.ExecuteSQL(ASQL: string; Parameters: array of Variant);
var
  QRY: TFDQuery;
  i: integer;
begin
  QRY := TFDQuery.Create(Self);

  try
    QRY.Connection  := Con;
    QRY.SQL.Text    := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        QRY.Params[i].AsString := '';
        QRY.Params[i].Clear;
      end else
        QRY.Params[i].Value := Parameters[i];
      //
    try
      QRY.ExecSQL();
    except
      on E: Exception do
        raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    QRY.Free;
  end;
end;

function TDM_Firebird.GetData(ASQL: string; Parameters: array of Variant): OleVariant;
var
  QRY: TFDQuery;
  DSP: TDataSetProvider;
  CDS: TClientDataSet;
  i: integer;
begin
  QRY := TFDQuery.Create(Self);
  DSP := TDataSetProvider.Create(Self);
  CDS := TClientDataSet.Create(Self);

  try
    QRY.Connection    := Con;
    DSP.Options       := [poAllowCommandText, poRetainServerOrder];
    DSP.Name          := '_DSP';
    DSP.DataSet       := QRY;
    CDS.ProviderName  := '_DSP';
    CDS.CommandText   := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        CDS.Params[i].AsString := '';
        CDS.Params[i].Clear;
      end else
        CDS.Params[i].Value := Parameters[i];
      //
    try
      CDS.Open;
      Result := CDS.Data;
      CDS.Close;
    except
      on E: Exception do raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    DSP.Name := '';
    CDS.Free;
    DSP.Free;
    QRY.Free;
  end;
end;

function TDM_Firebird.OpenSQL(ASQL: string; Parameters: array of Variant): Variant;
var
  QRY: TFDQuery;
  i: integer;
begin
  Result := Null;

  QRY := TFDQuery.Create(nil);

  try
    QRY.Connection := Con;
    QRY.SQL.Text   := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        QRY.Params[i].AsString := '';
        QRY.Params[i].Clear;
      end else
        QRY.Params[i].Value := Parameters[i];
      //
    try
      QRY.Open;
      if not QRY.IsEmpty then Result := QRY.Fields[0].Value;
      QRY.Close;
    except
      on E: Exception do
        raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    QRY.Free;
  end;
end;

initialization
  if not Assigned(DM_Firebird) then
    DM_Firebird := TDM_Firebird.Create(nil);

end.
