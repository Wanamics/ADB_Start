report 59901 "wan Update Customer"
{
    ProcessingOnly = true;
    Caption = 'Update Customer';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                /*
                ??Validate("Shipping Advice", "Shipping Advice"::Complete);
                Validate("Location Code", '01');
                if "VAT Bus. Posting Group" = 'FR_ENC' then
                    "VAT Bus. Posting Group" := 'FR_DEB';
                validate("Prices Including VAT", true);
                UpdateItems(Customer);
                */
                validate("Combine Shipments", not "Print Statements"); // "Print Statement" = Client web
                if "Print Statements" then
                    validate("Application Method", "Application Method"::"Apply to Oldest");
                /*
                Validate("Shipping Advice", Customer."Shipping Advice"::Complete);
                */
                Modify;
            end;

            trigger OnPreDataItem()
            begin
                if not Confirm('Voulez-vous mettre à jour %1 "%2"', false, Count, TableCaption) then
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

    local procedure UpdateItems(pCustomer: Record Customer)
    var
        Item: Record Item;
        CalcStdCost: Codeunit "Calculate Standard Cost";
    begin
        Item.SetRange("No. 2", pCustomer."No.");
        if Item.FindSet() then
            repeat
                if pCustomer."Print Statements" then begin
                    CalcStdCost.CalcAssemblyItemPrice(Item."No.");
                    Item.Get(Item."No.");
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"No Relationship");
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Profit=Price-Cost"); // Set "Profit %"
                end else begin
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"No Relationship");
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Profit=Price-Cost"); // Set "Profit %"
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Price=Cost+Profit");
                end;
                Item.Validate("Item Disc. Group", '1');
                Item.Modify();
            until Item.Next() = 0;
    end;
}

