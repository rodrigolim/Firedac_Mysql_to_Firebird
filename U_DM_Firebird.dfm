object DM_Firebird: TDM_Firebird
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 165
  Width = 204
  object Con: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'Server=localhost'
      'User_Name=sysdba'
      'Password=masterkey'
      'OSAuthent=No'
      'Database=D:\Rodrigo\part\Escola\trunk\Database\BASE\M3ESCOLA.fdb')
    LoginPrompt = False
    Left = 40
    Top = 32
  end
  object QryAux: TFDQuery
    Connection = Con
    Left = 112
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 80
    Top = 96
  end
end
