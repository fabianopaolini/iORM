inherited BOMItemVM: TBOMItemVM
  OldCreateOrder = True
  object MPBOMItem: TioModelPresenter
    Async = True
    AutoLoadData = True
    AutoPersist = True
    AutoRefreshOnNotification = arEnabledNoReload
    TypeName = 'IBOMItem'
    ViewDataType = dtList
    WhereDetailsFromDetailAdapters = False
    Left = 136
    Top = 16
  end
  object MPBOMArticle: TioModelPresenter
    Async = True
    AutoLoadData = True
    AutoPersist = True
    AutoRefreshOnNotification = arEnabledNoReload
    MasterPresenter = MPBOMItem
    MasterPropertyName = 'Article'
    TypeName = 'IBase'
    ViewDataType = dtList
    WhereDetailsFromDetailAdapters = False
    Left = 136
    Top = 72
  end
end
