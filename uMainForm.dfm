object mainForm: TmainForm
  Left = 0
  Top = 0
  Caption = 'ComicMatch'
  ClientHeight = 664
  ClientWidth = 590
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  DesignSize = (
    590
    664)
  PixelsPerInch = 96
  TextHeight = 13
  object imgTemplate: TImage
    Left = 8
    Top = 56
    Width = 233
    Height = 111
    Proportional = True
    Stretch = True
  end
  object imgPreview: TImage
    Left = 8
    Top = 192
    Width = 326
    Height = 447
    Anchors = [akLeft, akTop, akRight, akBottom]
    Proportional = True
    Stretch = True
    ExplicitHeight = 430
  end
  object lblSearchDir: TLabel
    Left = 8
    Top = 173
    Width = 14
    Height = 13
    Caption = 'In:'
  end
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 96
    Height = 13
    Caption = 'Look for (template):'
  end
  object btnLoadTempl: TButton
    Left = 8
    Top = 8
    Width = 97
    Height = 25
    Caption = '1. Load template'
    TabOrder = 0
    OnClick = btnLoadTemplClick
  end
  object btnSetSearchDir: TButton
    Left = 111
    Top = 8
    Width = 130
    Height = 25
    Caption = '2. Set search directory'
    TabOrder = 1
    OnClick = btnSetSearchDirClick
  end
  object btnStartMatch: TButton
    Left = 248
    Top = 8
    Width = 105
    Height = 25
    Caption = '3. Start looking...'
    TabOrder = 2
    OnClick = btnStartMatchClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 645
    Width = 590
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object fileList: TListBox
    Left = 340
    Top = 192
    Width = 242
    Height = 447
    Style = lbVirtual
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 4
    OnClick = fileListClick
    OnData = fileListData
  end
  object fileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 280
    Top = 80
  end
end
