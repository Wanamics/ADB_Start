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
                validate("Combine Shipments", not "Print Statements"); // "Print Statement" = Client web
                if "Print Statements" then
                    validate("Application Method", "Application Method"::"Apply to Oldest");
                Validate("Shipping Advice", Customer."Shipping Advice"::Complete);
                validate("Responsibility Center", 'ADB');
                */
                ValidateSalespersonCode();
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

    /*
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
    */
    local procedure ValidateSalespersonCode()
    var
        User: Record User;
        UsetSetup: Record "User Setup";
    begin
        if Customer."Salesperson Code" = '' then begin
            User.Get(Customer.SystemCreatedBy);
            UsetSetup.Get(User."User Name");
            UsetSetup.TestField("Salespers./Purch. Code");
            Customer."Salesperson Code" := UsetSetup."Salespers./Purch. Code";
        end;
        Customer.Validate("Salesperson Code"); // Inherit Global Dimensions
        Customer.Modify(false);
        UpdateSalesHeader();
    end;

    local procedure UpdateSalesHeader()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SuspendStatusCheck(true);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.SetCurrentKey("Sell-to Customer No.");
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesHeader.SetFilter("Shortcut Dimension 1 Code", '');
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."Salesperson Code" = '' then
                    SalesHeader.Validate("Salesperson Code", Customer."Salesperson Code")
                else
                    SalesHeader.Validate("Shortcut Dimension 1 Code", Customer."Global Dimension 1 Code");
                SalesHeader.Modify(false);
            until SalesHeader.Next() = 0;
    end;
    /*
    local procedure UpdateSalesLine(var pSalesHeader : Record "Sales Header")
    var
        SalesLine : Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
        SalesLine.SetRange("Document No.",pSalesHeader."No.");
        SalesLine.SetFilter("Shortcut Dimension 1 Code", '<>%1', pSalesHeader."Shortcut Dimension 1 Code");
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Shortcut Dimension 1 Code", pSalesHeader."Shortcut Dimension 1 Code");
                SalesLine.Modify(false);
            until SalesLine.Next() = 0;
    end;
    */
}