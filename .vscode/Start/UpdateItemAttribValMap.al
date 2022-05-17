report 59910 "wan Update Item AVM"
{
    ApplicationArea = All;
    Caption = 'Update Item Attribute Value Mapping';
    UsageCategory = Administration;
    ProcessingOnly = true;
    dataset
    {
        dataitem(NonstockItem; "Nonstock Item")
        {
            RequestFilterFields = "Item No.";
            DataItemTableView = where("Item No." = filter('<>'''''));
            dataitem(IAVM; "Item Attribute Value Mapping")
            {
                DataItemLinkReference = NonstockItem;
                DataItemTableView = where("Table ID" = const(5718)); // database::"Nonstock Item"
                DataItemLink = "No." = field("Entry No.");
                trigger OnAfterGetRecord()
                begin
                    CatalogItemToItem.SetItemAttribute(IAVM, NonstockItem."Item No.");
                end;
            }
            trigger OnPreDataItem()
            begin
                if not Confirm('Do you want to update %1 item(s)?', false, count) then
                    CurrReport.Quit();
            end;
        }
    }
    var
        CatalogItemToItem: Codeunit "wan Catalog Item to Item";
}
