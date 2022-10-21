report 59922 "wan Update SHR Shipping Cost"
{
    ProcessingOnly = true;
    Caption = 'Update Shipping Cost';
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata "Sales Invoice Header" = m;

    dataset
    {
        dataitem(SHR; "wan Sales Header Release")
        {
            DataItemTableView = where("Document Type" = const("Order"), Disabled = const(false), "Net Weight" = filter('<> 0'));
            RequestFilterFields = "No.", "Order Date", "Shipment Method Code";

            trigger OnPreDataItem()
            begin
                if not Confirm('Update %1 %2 OK?', false, Count, TableCaption) then
                    exit;
                ProgressDialog.OpenCopyCountMax('', Count);
                SetCurrentKey("Document Type", "No.", "Doc. No. Occurrence");
                StartDateTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord()
            var
                SalesHeader: Record "Sales Header";
                SalesInvoiceHeader: Record "Sales Invoice Header";
            begin
                ProgressDialog.UpdateCopyCount();
                "Shipping Cost (LCY)" := ShippingCost.GetShippingCost("Shipment Method Code", "Net Weight");
                if "Shipping Cost (LCY)" <> 0 then begin
                    Modify();
                    if SalesHeader.Get("Document Type", "No.") then begin
                        SalesHeader."wan Shipping Cost (LCY)" := "Shipping Cost (LCY)";
                        SalesHeader.Modify();
                    end;
                    SalesInvoiceHeader.SetCurrentKey("Order No.");
                    SalesInvoiceHeader.SetRange("Order No.", "No.");
                    if SalesInvoiceHeader.FindLast() then begin
                        SalesInvoiceHeader."wan Shipping Cost (LCY)" := "Shipping Cost (LCY)";
                        SalesInvoiceHeader.Modify();
                    end;
                end;
            end;

            trigger OnPostDataItem()
            begin
                message('Done in %1', CurrentDateTime - StartDateTime);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";
        StartDateTime: DateTime;
        ShippingCost: Record "wan Shipping Cost";

}

