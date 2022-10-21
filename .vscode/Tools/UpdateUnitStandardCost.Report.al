report 59924 "Update Unit Standard Cost"
{
    ApplicationArea = All;
    Caption = 'Update Unit Standard Cost';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 113 = m, tabledata 115 = m;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", Type, "Replenishment System";
            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to update "Unit Standard Cost" on update "Sales Line", "Sales Invoice Line" and "Sales Cr.Memo Lines" for %1 Item(s)?';
            begin
                SetLoadFields("No.", "Standard Cost");
                if not Confirm(tConfirm, false, count) then
                    CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax('', Count);
            end;

            trigger OnAfterGetRecord()
            var
                PriceListLine: Record "Price List Line";
            begin
                ProgressDialog.UpdateCopyCount();

                PriceListLine.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date");
                PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                PriceListLine.SetRange("Asset No.", "No.");
                PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"All Vendors");
                PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Purchase);
                PriceListLine.SetRange("Price List Code", '2021');
                if not PriceListLine.FindFirst() then
                    PriceListLine."Unit Cost" := Item."Standard Cost";

                UpdateSalesLines(Item, 2021, PriceListLine."Unit Cost");
                UpdateSalesInvoiceLines(Item, 2021, PriceListLine."Unit Cost");
                UpdateSalesCrMemoLines(Item, 2021, PriceListLine."Unit Cost");
            end;
        }
    }
    var
        ProgressDialog: Codeunit "Progress Dialog";

    local procedure UpdateSalesLines(pItem: Record Item; pYear: Integer; pUnitCost: Decimal)
    var
        Rec: Record "Sales Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetLoadFields(Type, "No.", "Unit Standard Cost");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        Rec.SetRange("Unit Standard Cost", 0);
        if Rec.FindSet() then
            repeat
                if Rec."Shipment Date" = 0D then
                    Rec."Unit Standard Cost" := pItem."Standard Cost"
                else
                    if Date2DMY(Rec."Shipment Date", 3) = pYear then
                        Rec."Unit Standard Cost" := pUnitCost
                    else
                        Rec."Unit Standard Cost" := pItem."Standard Cost";
                if Rec."Unit Standard Cost" <> 0 then
                    Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesInvoiceLines(pItem: Record Item; pYear: Integer; pUnitCost: Decimal)
    var
        Rec: Record "Sales Invoice Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetLoadFields(Type, "No.", "Unit Standard Cost");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        Rec.SetRange("Unit Standard Cost", 0);
        if Rec.FindSet() then
            repeat
                if Rec."Shipment Date" = 0D then
                    Rec."Unit Standard Cost" := pItem."Standard Cost"
                else
                    if Date2DMY(Rec."Posting Date", 3) = pYear then
                        Rec."Unit Standard Cost" := pUnitCost
                    else
                        Rec."Unit Standard Cost" := pItem."Standard Cost";
                if Rec."Unit Standard Cost" <> 0 then
                    Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesCrMemoLines(pItem: Record Item; pYear: Integer; pUnitCost: Decimal)
    var
        Rec: Record "Sales Cr.Memo Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetLoadFields(Type, "No.", "Unit Standard Cost");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        Rec.SetRange("Unit Standard Cost", 0);
        if Rec.FindSet() then
            repeat
                if Rec."Shipment Date" = 0D then
                    Rec."Unit Standard Cost" := pItem."Standard Cost"
                else
                    if Date2DMY(Rec."Posting Date", 3) = pYear then
                        Rec."Unit Standard Cost" := pUnitCost
                    else
                        Rec."Unit Standard Cost" := pItem."Standard Cost";
                if Rec."Unit Standard Cost" <> 0 then
                    Rec.Modify();
            until Rec.Next() = 0;
    end;
}
