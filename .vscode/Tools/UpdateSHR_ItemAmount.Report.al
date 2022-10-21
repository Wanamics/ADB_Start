report 59925 "wan Update SHR Item Amount"
{
    ProcessingOnly = true;
    Caption = 'Update SHR Item Amount';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SHR; "wan Sales Header Release")
        {
            DataItemTableView =
                sorting("Document Type", "No.", "Doc. No. Occurrence")
                where("Document Type" = Const("Order"), Disabled = Const(false), "Item Amount" = const(0));
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if not Confirm('Update %1 for %2 %3?', false, FieldCaption("Item Amount"), Count, TableCaption) then
                    exit;
                ProgressDialog.OpenCopyCountMax('', Count);
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord()
            var
                SIL: Record "Sales Invoice Line";
            begin
                ProgressDialog.UpdateCopyCount();
                SIL.SetLoadFields(Quantity, "Unit Cost (LCY)");
                SIL.SetCurrentKey("Order No.");
                SIL.SetRange("Order No.", "No.");
                SIL.SetRange(Type, SIL.Type::Item);
                if SIL.FindSet() then begin
                    repeat
                        SHR."Item Amount" += SIL.Amount;
                    until SIL.Next() = 0;
                    SHR.Modify(false);
                end;
            end;

            trigger OnPostDataItem()
            begin
                message('Done in %1', CurrentDateTime - StartTime);
            end;
        }
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";
        StartTime: DateTime;
}