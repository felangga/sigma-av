object MainForm: TMainForm
  Left = 192
  Top = 107
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'KSpoold Disinfector'
  ClientHeight = 193
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 145
    Caption = 'Header Samples'
    TabOrder = 0
    object ListBox1: TListBox
      Left = 8
      Top = 16
      Width = 153
      Height = 121
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBox1Click
    end
    object Button1: TButton
      Left = 168
      Top = 16
      Width = 89
      Height = 23
      Caption = 'New Sample...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 168
      Top = 48
      Width = 89
      Height = 23
      Caption = 'Delete'
      Enabled = False
      TabOrder = 2
      OnClick = Button2Click
    end
  end
  object Button3: TButton
    Left = 8
    Top = 160
    Width = 113
    Height = 23
    Caption = 'Disinfect File...'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 205
    Top = 160
    Width = 75
    Height = 23
    Caption = 'About...'
    TabOrder = 2
    OnClick = Button4Click
  end
end
