report 59905 "wan Update Purchase Order"
{
    ProcessingOnly = true;
    Caption = 'Update Purchase Order';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableView = Where("Document Type" = Const("Order"));
            RequestFilterFields = "No.";
            dataitem(PurchaseLine; "Purchase Line")
            {
                DataItemLinkReference = PurchaseHeader;
                DataItemTableView = where("Outstanding Quantity" = filter(<> 0));
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");

                trigger OnPreDataitem()
                begin
                    SuspendStatusCheck(true);
                end;

                trigger OnAfterGetRecord()
                begin
                    validate("Qty. to Receive", "Outstanding Quantity");
                    Modify(true);
                end;
            }


            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                SuspendStatusCheck(true);
                SetHideValidationDialog(true);
                //modify(true);
            end;

            trigger OnPreDataItem()
            begin
                if not Confirm('Update %1 %2 OK?', false, Count, TableCaption) then
                    exit;
                ProgressDialog.OpenCopyCountMax('', Count);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";

}

