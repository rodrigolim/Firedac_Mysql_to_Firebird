object frm_main: Tfrm_main
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Conversor'
  ClientHeight = 329
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PrintScale = poNone
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 200
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Iniciar'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Log: TMemo
    Left = 0
    Top = 96
    Width = 504
    Height = 233
    Align = alBottom
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 102
  end
  object Panel1: TPanel
    Left = 0
    Top = 76
    Width = 504
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 75
    object Label1: TLabel
      Left = 24
      Top = 5
      Width = 17
      Height = 13
      Caption = 'Log'
    end
  end
end
