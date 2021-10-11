object frmCobwebDemo: TfrmCobwebDemo
  Left = 0
  Top = 0
  Caption = 'Cobweb Demo'
  ClientHeight = 584
  ClientWidth = 642
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 380
    Width = 642
    Height = 185
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object gbPoints: TGroupBox
      Left = 0
      Top = 0
      Width = 457
      Height = 185
      Align = alLeft
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Points'
      TabOrder = 0
      object lvPoints: TListView
        Left = 2
        Top = 15
        Width = 453
        Height = 168
        Align = alClient
        Columns = <
          item
            Caption = 'ID'
          end
          item
            Caption = 'X position'
            Width = 75
          end
          item
            Caption = 'Y position'
            Width = 75
          end
          item
            Caption = 'Routes Count'
            Width = 90
          end>
        ReadOnly = True
        RowSelect = True
        PopupMenu = PopupMenu2
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object gbRoutes: TGroupBox
      Left = 457
      Top = 0
      Width = 185
      Height = 185
      Align = alClient
      Caption = 'Routes'
      TabOrder = 1
      object lvRoutes: TListView
        Left = 2
        Top = 15
        Width = 181
        Height = 168
        Align = alClient
        Columns = <
          item
            Caption = 'Primari ID'
            Width = 75
          end
          item
            Caption = 'Slave ID'
            Width = 75
          end>
        ReadOnly = True
        RowSelect = True
        PopupMenu = PopupMenu2
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 565
    Width = 642
    Height = 19
    Panels = <
      item
        Text = 'Total points count: 0'
        Width = 150
      end
      item
        Text = 'Total routes count: 0'
        Width = 150
      end>
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 32
    Top = 16
    object Addpoint1: TMenuItem
      Caption = 'Add point'
      OnClick = Addpoint1Click
    end
    object MakeRoute1: TMenuItem
      Caption = 'Make Route'
      OnClick = MakeRoute1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
  end
  object MainMenu1: TMainMenu
    Top = 16
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
      object Saveasdefault1: TMenuItem
        Caption = 'Save as default'
        OnClick = Saveasdefault1Click
      end
      object Save1: TMenuItem
        Caption = 'Save as ...'
        OnClick = Save1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Addpoint2: TMenuItem
        Caption = 'Add point'
        OnClick = Addpoint1Click
      end
      object MakeRoute2: TMenuItem
        Caption = 'Make Route'
        OnClick = MakeRoute1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Clear2: TMenuItem
        Caption = 'Clear'
        OnClick = Clear1Click
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.cbw'
    Filter = 'Cobweb files (*.cbw)|*.cbw|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 64
    Top = 16
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.cbw'
    Filter = 'Cobweb files (*.cbw)|*.cbw|All files (*.*)|*.*'
    Left = 96
    Top = 16
  end
  object PopupMenu2: TPopupMenu
    Left = 128
    Top = 16
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
end
