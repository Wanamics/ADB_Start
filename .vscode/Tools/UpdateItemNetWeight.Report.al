report 59915 "Update Item Net Weight"
{
    Caption = 'Update Item Net Weight';
    ProcessingOnly = true;
    Permissions = tabledata 113 = m, tabledata 115 = m;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Net Weight", Type, "Replenishment System";
            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to update %1 on %2 Item(s) then update "Sales Line", "Sales Invoice Line" and "Sales Cr.Memo Lines"?';
            begin
                SetLoadFields("No.", "Net Weight");
                if not Confirm(tConfirm, false, Item.FieldCaption("Net Weight"), Count) then
                    CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax('', Count);
            end;

            trigger OnAfterGetRecord()
            var
                xNetWeight: Decimal;
            begin
                ProgressDialog.UpdateCopyCount();
                xNetWeight := Item."Net Weight";
                CalcBOMNetWeight(Item);
                if Item."Net Weight" <> xNetWeight then begin
                    Modify(false);
                    UpdateSalesLines(Item);
                    UpdateSalesInvoiceLines(Item);
                    UpdateSalesCrMemoLines(Item);
                end;
            end;
        }
    }
    var
        ProgressDialog: Codeunit "Progress Dialog";

    local procedure CalcBOMNetWeight(var pItem: Record Item)
    var
        BOMComponent: Record "BOM Component";
        lItem: Record Item;
    begin
        pItem."Net Weight" := 0;
        BOMComponent.SetRange("Parent Item No.", pItem."No.");
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        BOMComponent.SetFilter("No.", '<>%1', '');
        lItem.SetLoadFields("Net Weight");
        if BOMComponent.FindSet() then
            Repeat
                lItem.Get(BOMComponent."No.");
                pItem."Net Weight" += BOMComponent."Quantity per" * lItem."Net Weight";
            until BOMComponent.Next() = 0;
    end;

    local procedure UpdateSalesLines(pItem: Record Item)
    var
        Rec: Record "Sales Line";
    begin
        Rec.SetLoadFields("Net Weight");
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.FindSet() then
            repeat
                if Rec."Net Weight" <> pItem."Net Weight" then begin
                    Rec."Net Weight" := pItem."Net Weight";
                    Rec.Modify(false);
                end;
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesInvoiceLines(pItem: Record Item)
    var
        Rec: Record "Sales Invoice Line";
    begin
        Rec.SetLoadFields("Net Weight");
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.FindSet() then
            repeat
                if Rec."Net Weight" <> pItem."Net Weight" then begin
                    Rec."Net Weight" := pItem."Net Weight";
                    Rec.Modify(false);
                end;
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesCrMemoLines(pItem: Record Item)
    var
        Rec: Record "Sales Cr.Memo Line";
    begin
        Rec.SetLoadFields("Net Weight");
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.FindSet() then
            repeat
                if Rec."Net Weight" <> pItem."Net Weight" then begin
                    Rec."Net Weight" := pItem."Net Weight";
                    Rec.Modify(false);
                end;
            until Rec.Next() = 0;
    end;
}
