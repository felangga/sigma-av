object frmSplash: TfrmSplash
  Left = 210
  Top = 89
  BorderStyle = bsNone
  Caption = 'frmSplash'
  ClientHeight = 194
  ClientWidth = 306
  Color = clBtnText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 16
    Width = 177
    Height = 41
    AutoSize = False
    Caption = 'SigmaAV'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = 'Kristen ITC'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    WordWrap = True
  end
  object txtver: TLabel
    Left = 192
    Top = 32
    Width = 73
    Height = 21
    AutoSize = False
    Caption = 'V.0.0.0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    Transparent = True
  end
end
