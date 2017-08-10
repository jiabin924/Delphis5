object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 206
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 86
    Top = 67
    Width = 28
    Height = 13
    Caption = #29992#25143':'
  end
  object Label2: TLabel
    Left = 86
    Top = 95
    Width = 28
    Height = 13
    Caption = #23494#30721':'
  end
  object Label3: TLabel
    Left = 86
    Top = 122
    Width = 28
    Height = 13
    Caption = #31471#21475':'
  end
  object taoshi: TLabel
    Left = 8
    Top = 149
    Width = 29
    Height = 13
    Caption = 'taoshi'
  end
  object EUser: TEdit
    Left = 120
    Top = 68
    Width = 121
    Height = 21
    ImeName = #24494#36719#25340#38899#36755#20837#27861' 2007'
    TabOrder = 0
  end
  object Epass: TEdit
    Left = 120
    Top = 95
    Width = 121
    Height = 21
    ImeName = #24494#36719#25340#38899#36755#20837#27861' 2007'
    PasswordChar = '*'
    TabOrder = 1
  end
  object EPort: TEdit
    Left = 120
    Top = 122
    Width = 121
    Height = 21
    HelpType = htKeyword
    ImeName = #24494#36719#25340#38899#36755#20837#27861' 2007'
    TabOrder = 2
    Text = '5555'
    OnKeyPress = EPortKeyPress
  end
  object Button1: TButton
    Left = 272
    Top = 95
    Width = 75
    Height = 20
    Caption = 'run'
    TabOrder = 3
    OnClick = Button1Click
  end
end
