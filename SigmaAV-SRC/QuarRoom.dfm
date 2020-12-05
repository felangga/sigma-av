object QRoom: TQRoom
  Left = 192
  Top = 115
  BorderStyle = bsToolWindow
  Caption = 'Quarantine Room'
  ClientHeight = 400
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object ListQuar: TListView
    Left = 8
    Top = 8
    Width = 393
    Height = 345
    Columns = <
      item
        AutoSize = True
        Caption = 'File Name'
      end
      item
        AutoSize = True
        Caption = 'Original Path'
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object cmdRestore: TButton
    Left = 8
    Top = 360
    Width = 75
    Height = 25
    Caption = '&Restore'
    TabOrder = 1
  end
  object cmdRestoreTo: TButton
    Left = 112
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Restore &To'
    TabOrder = 2
  end
  object cmdDelete: TButton
    Left = 216
    Top = 360
    Width = 75
    Height = 25
    Caption = '&Delete'
    TabOrder = 3
  end
  object cmdClose: TButton
    Left = 328
    Top = 360
    Width = 75
    Height = 25
    Caption = '&Close'
    TabOrder = 4
    OnClick = cmdCloseClick
  end
end
