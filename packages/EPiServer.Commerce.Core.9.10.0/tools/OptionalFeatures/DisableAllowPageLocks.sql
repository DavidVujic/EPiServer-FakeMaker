PRINT N'Updating ALLOW_PAGE_LOCKS = OFF for indexes to avoid deadlocks on LineItem/Shipment/Order tables...';
GO
-- alter indexes of LineItem
ALTER INDEX [IX_LineItem_OrderFormId] ON [dbo].[LineItem] SET (ALLOW_PAGE_LOCKS = OFF)
GO
ALTER INDEX [IX_LineItem_OrderGroupId] ON [dbo].[LineItem] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of LineItemDiscount
ALTER INDEX [IX_LineItem_OrderGroupId] ON [dbo].[LineItemDiscount] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of OrderForm
ALTER INDEX [IX_OrderForm_OrderGroupId] ON [dbo].[OrderForm] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of OrderFormDiscount
ALTER INDEX [IX_OrderFormDiscount_OrderGroupId] ON [dbo].[OrderFormDiscount] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of OrderFormPayment
ALTER INDEX [IX_OrderFormPayment_OrderFormId] ON [dbo].[OrderFormPayment] SET (ALLOW_PAGE_LOCKS = OFF)
GO
ALTER INDEX [IX_OrderFormPayment_OrderGroupId] ON [dbo].[OrderFormPayment] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of OrderGroupAddress
ALTER INDEX [IX_OrderGroupAddress_OrderGroupId] ON [dbo].[OrderGroupAddress] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of OrderSearchResults
ALTER INDEX [IX_OrderSearchResults_SearchSetId] ON [dbo].[OrderSearchResults] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of Shipment
ALTER INDEX [IX_Shipment_OrderFormId] ON [dbo].[Shipment] SET (ALLOW_PAGE_LOCKS = OFF)
GO
ALTER INDEX [IX_Shipment_OrderGroupId] ON [dbo].[Shipment] SET (ALLOW_PAGE_LOCKS = OFF)
GO
-- alter indexes of ShipmentDiscount
ALTER INDEX [IX_ShipmentDiscountOrderGroupId] ON [dbo].[ShipmentDiscount] SET (ALLOW_PAGE_LOCKS = OFF)
GO
