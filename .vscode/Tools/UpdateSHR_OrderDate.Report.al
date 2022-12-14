report 59910 "wan Update SHR Order Date"
{
    ProcessingOnly = true;
    Caption = 'Update SHR Order Date';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SHR; "wan Sales Header Release")
        {
            DataItemTableView = Where("Document Type" = Const("Order"));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                IsFirst: Boolean;
            begin
                ProgressDialog.UpdateCopyCount();
                IsFirst :=
                    ("Document Type" <> xSHR."Document Type") or
                    ("No." <> xSHR."No.") or
                    ("Doc. No. Occurrence" <> xSHR."Doc. No. Occurrence");
                if IsFirst and (xSHR."No." <> '') then
                    UpdateLastOne();
                "Work Date" := "Order Date";
                if not IsFirst then
                    "Order Date" := xSHR."Order Date";
                Disabled := true;
                Modify(false);
                xSHR := SHR;
            end;

            trigger OnPreDataItem()
            begin
                if not Confirm('Update %1 %2 OK?', false, Count, TableCaption) then
                    exit;
                ProgressDialog.OpenCopyCountMax('', Count);
                SetCurrentKey("Document Type", "No.", "Doc. No. Occurrence");
            end;

            trigger OnPostDataItem()
            begin
                UpdateLastOne();
            end;
        }
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";
        xSHR: Record "wan Sales Header Release";
        SHRMgt: Codeunit "wan Sales Header Release Mgt.";

    local procedure UpdateLastOne()
    begin
        SHRMgt.Run(xSHR);
        xSHR.Disabled := false;
        xSHR.Modify(false);
    end;
}

