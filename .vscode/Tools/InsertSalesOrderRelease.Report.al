report 59923 "_Insert Sales Order Release"
{
    ApplicationArea = All;
    Caption = '_Insert Sales Order Release from Sales Invoice Line';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number);

            trigger OnPreDataItem()
            begin
                if not Confirm('Process %1 ?', false, CurrReport.ObjectId(true)) then
                    exit;
                ProgressDialog.OpenCopyCount('');
                StartDateTime := CurrentDateTime;
                if OrderNoFilter <> '' then
                    DistinctOrder.SetFilter(orderNo, OrderNoFilter);
                DistinctOrder.Open();
            end;

            trigger OnAfterGetRecord()
            var
                SHR: Record "wan Sales Header Release";
                SalesInvoiceHeader: Record "Sales Invoice Header";
                SalesInvoiceLine: Record "Sales Invoice Line";
            begin
                ProgressDialog.UpdateCopyCount();
                if not DistinctOrder.Read() then
                    CurrReport.Break()
                else begin
                    SHR.SetCurrentKey("Document Type", "No.", "Doc. No. Occurrence");
                    SHR.SetRange("Document Type", SHR."Document Type"::Order);
                    SHR.SetRange("No.", DistinctOrder.OrderNo);
                    //SalesHeaderRelease.SetRange("Doc. No. Occurrence", 1);
                    //SalesHeaderRelease.SetRange(Disabled, false);
                    if not SHR.FindFirst() then begin
                        SalesInvoiceLine.SetCurrentKey("Order No.");
                        SalesInvoiceLine.SetRange("Order No.", DistinctOrder.OrderNo);
                        SalesInvoiceLine.FindLast();
                        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                        //SalesInvoiceHeader.SetCurrentKey("Order No.");
                        //SalesInvoiceHeader.SetRange("Order No.", DistinctOrder.OrderNo);
                        //if SalesInvoiceHeader.FindFirst() then begin
                        SHR.TransferFields(SalesInvoiceHeader);
                        SHR."Document Type" := SHR."Document Type"::Order;
                        SHR."No." := DistinctOrder.OrderNo;
                        SHR."Doc. No. Occurrence" := 1;
                        SHR."Work Date" := SalesInvoiceHeader."Order Date";
                        SumLines(SHR);
                        //SHR."Shipping Cost (LCY)" := ShippingCost.GetShippingCost(SHR."Shipment Method Code", SHR."Net Weight");
                        SHR."Entry No." := 0;
                        SHR.Insert();
                        //end;
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
        layout
        {
            area(Content)
            {
                field(OrderNoFilter; OrderNoFilter)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        ProgressDialog: Codeunit "Progress Dialog";
        StartDateTime: DateTime;
        OrderNoFilter: Text;
        OrderNo: Code[20];
        DistinctOrder: Query "_Insert Sales Order Release";
    //ShippingCost: Record "wan Shipping Cost";

    local procedure SumLines(var pRec: Record "wan Sales Header Release")
    var
        Line: Record "Sales Invoice Line";
        Item: Record Item;
    begin
        Line.SetCurrentKey("Order No.");
        Line.SetLoadFields("Order No.", Quantity, "Gross Weight", "Net Weight", "Unit Volume", "Amount", "Amount Including VAT", "Unit Cost (LCY)");
        Line.SetRange("Order No.", pRec."No.");
        Line.SetFilter(Quantity, '<>0');
        if Line.FindSet() then begin
            pRec.Amount := 0;
            pRec."Amount Including VAT" := 0;
            pRec."Gross Weight" := 0;
            pRec."Net Weight" := 0;
            pRec.Volume := 0;
            pRec."Item Amount" := 0;
            pRec."Item Cost (LCY)" := 0;
            repeat
                pRec.Amount += Line.Amount;
                pRec."Amount Including VAT" += Line."Amount Including VAT";
                if Line.Type = Line.Type::Item then begin
                    pRec."Gross Weight" += Line."Gross Weight" * Line.Quantity;
                    pRec."Net Weight" += Line."Net Weight" * Line.Quantity;
                    if Item.Get(Line."No.") and (Item."Replenishment System" = Item."Replenishment System"::Assembly) then
                        pRec.Volume += Line."Unit Volume" * Line.Quantity
                    else
                        pRec.Volume += Line."Unit Volume";
                    pRec."Item Amount" += Line."Amount";
                    pRec."Item Cost (LCY)" += Line."Unit Cost (LCY)" * Line.Quantity;
                end
            until Line.Next() = 0;
        end;
    end;
}