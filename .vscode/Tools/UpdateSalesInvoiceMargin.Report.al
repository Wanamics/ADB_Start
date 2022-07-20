report 59913 "_Update Sales Inv. Lines Marg."
{
    ApplicationArea = All;
    Caption = '_Update Sales Invoice Margin';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata "Sales Invoice Line" = M;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";
            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLinkReference = Header;
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = where(Type = Const(Item), "Unit Cost (LCY)" = const(0));

                trigger OnAfterGetRecord()
                var
                    PriceListLine: Record "Price List Line";
                begin
                    PriceListLine.SetRange("Price List Code", '2021');
                    PriceListLine.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                    PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                    PriceListLine.SetRange("Asset No.", Line."No.");
                    PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Purchase);
                    PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"All Vendors");
                    PriceListLine.SetFilter("Currency Code", '%1|%2', '', Header."Currency Code");
                    PriceListLine.SetFilter("Unit of Measure Code", '%1|%2', '', Line."Unit of Measure Code");
                    if PriceListLine.FindFirst() then begin
                        if PriceListLine."Direct Unit Cost" = 0 then
                            Line."Unit Cost" := PriceListLine."Unit Price"
                        else
                            Line."Unit Cost" := PriceListLine."Direct Unit Cost";
                        Line."Unit Cost (LCY)" := Line."Unit Cost";
                        Line.Modify();
                    end;
                end;
            }
        }
    }
    requestpage
    {
        SaveValues = true;
    }
}
