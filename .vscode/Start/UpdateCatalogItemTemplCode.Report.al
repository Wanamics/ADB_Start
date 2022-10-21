report 59926 "wan Update Catalog Item Templ."
{
    ProcessingOnly = true;
    Caption = 'Update Catalog Item Templ.';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(NonstockItem; "Nonstock Item")
        {
            RequestFilterFields = "Entry No.";
            DataItemTableView = where("Item Templ. Code" = const(''));

            trigger OnPreDataItem()

            begin
                AlkorSetup.Get();
                AlkorSetup.TestField("Vendor No.");
                AlkorSetup.TestField("Def. Item Templ. Code");
                SetRange("Vendor No.", AlkorSetup."Vendor No.");
                if Confirm('Set "%3" to ''%4'' for %1 "%2"?', false, Count, TableCaption, FieldCaption("Item Templ. Code"), AlkorSetup."Def. Item Templ. Code") then begin
                    StartTime := CurrentDateTime;
                    ModifyAll("Item Templ. Code", AlkorSetup."Def. Item Templ. Code");
                    Message('Done in %1', CurrentDateTime - StartTime);
                end;
            end;

            trigger OnPostDataItem()
            begin
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
        AlkorSetup: Record "wan Alkor Setup";
        StartTime: DateTime;

}

