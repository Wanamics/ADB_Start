report 59900 "wan Update Item"
{
    // Attention : la "Feuille création emplacement" doit être validée après ce traitement le cas échant

    ProcessingOnly = true;
    Caption = 'Update Item';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", Type, "Replenishment System";

            trigger OnAfterGetRecord()
            var
                IAVM: Record "Item Attribute Value Mapping";
                NonstockItem: Record "Nonstock Item";
            begin
                ProgressDialog.UpdateCopyCount();
                /*
                VALIDATE("Unit Cost","Last Direct Cost");
                InsertItemUnitOfMeasure(Item);
                IF "Sales Unit of Measure" = '' THEN
                  VALIDATE("Sales Unit of Measure","Base Unit of Measure");
                IF "Purch. Unit of Measure" = '' THEN
                  VALIDATE("Purch. Unit of Measure","Base Unit of Measure");
                IF "Shelf No." <> '' THEN BEGIN
                  SetDefaultBin(Item,'01',DELCHR("Shelf No."));
                  VALIDATE("Shelf No.",'');
                END;
                IF Type = Type::Inventory THEN
                  InsertItemJournalLine(Item,'01',01102020D,1000);
                Item."VAT Bus. Posting Gr. (Price)" := 'FR_DEB';
                Item.Validate("Price Includes VAT", true);
                if Item."VAT Prod. Posting Group" <> '200' then
                    Item.validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group" + '.' + Item."VAT Prod. Posting Group");
                //Item.Validate("Costing Method", Item."Costing Method"::Standard);
                */
                if "Replenishment System" = "Replenishment System"::Assembly then begin
                    /*    
                    "Reordering Policy" := "Reordering Policy"::"Lot-for-Lot";
                    CreateBOM(Item);
                    "Block Reason" := '';
                    Blocked := true;
                    InsertProductionForecast('MIN',Item."No.","Base Unit of Measure",WORKDATE,'01',"Reorder Point");
                    "Reorder Point" := 0;
                    InsertProductionForecast('MAX',Item."No.","Base Unit of Measure",WORKDATE,'01',"Maximum Inventory");
                    "Maximum Inventory" := 0;
                    IF "Gen. Prod. Posting Group" = '' THEN
                    "Gen. Prod. Posting Group" := '6071';
                    IF "Inventory Posting Group" = '' THEN
                    "Inventory Posting Group" := '3710';
                    InsertBinContent((Item,'01','PREP');
                    SetDefaultBin(Item, '01', 'PREP');
                    "Reordering Policy" := "Reordering Policy"::"Lot-for-Lot";
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"No Relationship");
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Profit=Price-Cost"); // Set "Profit %"
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Price=Cost+Profit");
                    //??Modify; // Before "Prices Includes VAT"
                    Item."No. Series" := 'ITEM_ASS';
                    if Item."No."[1] = 'L' then
                        Item."Blocked" := false; // suite pb copie coommandes-cadres
                    Item."Shelf No." := '';
                    Item."Reorder Point" := 0;
                    Item."Maximum Inventory" := 0;
                    Item.Modify(true);
                    */
                end else begin
                    /*
                    if "Vendor Item No." <> '' then
                        Validate("Vendor No.", 'F00001');
                    Item."Vendor Item No." := Item."No.";
                    IAVM.SetRange("Table ID", Database::"Item");
                    IAVM.SetRange("No.", Item."No.");
                    if IAVM.IsEmpty then begin
                        wanCatalogItemToItem.CopyAttributes(Item);
                        Item.Modify();
                    end;
                    if NonStockItemExists(Item) then begin
                        Item."Created From Nonstock Item" := true;
                        Item.Modify();
                    end;
                    if Item."Gross Weight" <> 0 then begin
                        Item."Net Weight" := Item."Gross Weight";
                        Item."Gross Weight" := 0;
                    end else
                        Item."Net Weight" *= 1000;
                    ChangeSKULocation(Item, '01', '99');
                    "Statistics Group" := 0; // something is modified
                    Item."Shelf No." := '';
                    Item."Reorder Point" := 0;
                    Item."Maximum Inventory" := 0;
                    */
                    if "Unit Price" <> 0 then // Trigger webhook to update Weight
                        Item.Modify(true);
                    SetStockKeepingUnit(Item, '01');
                    SetDefaultDimension(Item, 'SITE', 'ZZZ')
                end;
                /*
                Validate("Purch. Unit of Measure", "Base Unit of Measure");
                */
                //Modify;
                /*
                if ("Replenishment System" = "Replenishment System"::Purchase) and (Type = Type::Inventory) then
                    SetStockKeepingUnit(Item, '01');
                */

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
        BinCreationWorksheetLine: Record "Bin Creation Worksheet Line";
        ItemJournalLine: Record "Item Journal Line";
        ProductionForecastEntry: Record "Production Forecast Entry";
        ProgressDialog: Codeunit "Progress Dialog";
    //wanCatalogItemToItem: Codeunit "wan Catalog Item to Item";

    local procedure InsertItemUnitOfMeasure(pItem: Record Item)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.Validate("Item No.", pItem."No.");
        ItemUnitofMeasure.Validate(Code, pItem."Base Unit of Measure");
        ItemUnitofMeasure.Validate("Qty. per Unit of Measure", 1);
        ItemUnitofMeasure.Insert(true);
    end;

    local procedure InsertItemJournalLine(pItem: Record Item; pLocationCode: Code[10]; pPostingDate: Date; pQuantity: Decimal)
    begin
        ItemJournalLine."Journal Template Name" := 'ARTICLE';
        ItemJournalLine."Journal Batch Name" := 'DEFAUT';
        ItemJournalLine."Line No." += 1;
        ItemJournalLine.Validate("Item No.", pItem."No.");
        ItemJournalLine.Validate("Posting Date", pPostingDate);
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", '0');
        ItemJournalLine.Validate("Location Code", pLocationCode);
        ItemJournalLine.Validate(Quantity, pQuantity);
        ItemJournalLine.Insert(true);
    end;

    local procedure SetDefaultBin(pItem: Record Item; pLocationCode: Code[10]; pBinCode: Code[20])
    var
        Bin: Record Bin;
    begin
        if not Bin.Get(pLocationCode, pBinCode) then begin
            Bin.Validate("Location Code", pLocationCode);
            Bin.Validate(Code, pBinCode);
            Bin.Insert;
        end;
        BinCreationWorksheetLine.Validate("Worksheet Template Name", 'CONT EMPL');
        BinCreationWorksheetLine.Validate(Name, 'DEFAUT');
        BinCreationWorksheetLine.Validate(Type, BinCreationWorksheetLine.Type::"Bin Content");
        BinCreationWorksheetLine.Validate("Location Code", pLocationCode);
        BinCreationWorksheetLine."Line No." += 1;
        BinCreationWorksheetLine.Validate("Item No.", pItem."No.");
        BinCreationWorksheetLine.Validate("Bin Code", pBinCode);
        BinCreationWorksheetLine.Validate(Fixed, true);
        BinCreationWorksheetLine.Validate(Default, true);
        BinCreationWorksheetLine.Insert(true);
    end;

    local procedure CreateBOM(Item: Record Item)
    var
        BOMComponent: Record "BOM Component";
        lItem: Record Item;
    begin
        BOMComponent.SetRange("Parent Item No.", Item."No.");
        if not BOMComponent.IsEmpty then
            exit;

        BOMComponent."Parent Item No." := Item."No.";
        BOMComponent.Type := BOMComponent.Type::Item;
        while GetNextComponent(Item."Block Reason", BOMComponent."No.", BOMComponent."Quantity per") do begin
            BOMComponent."Line No." += 10000;
            if lItem.Get(BOMComponent."No.") then
                BOMComponent.Validate("No.")
            else
                BOMComponent.Description := '!!!! Article inexistant !!!!';
            BOMComponent.Validate("Quantity per");
            BOMComponent.Insert(true);
        end;
    end;

    local procedure GetNextComponent(var pBOM: Text; var pNo: Code[20]; var pQuantity: Decimal): Boolean
    var
        Pos: Integer;
    begin
        if pBOM = '' then
            exit(false);
        pNo := '';
        Pos := StrPos(pBOM, '\');
        if Pos = 0 then
            exit(false)
        else begin
            pNo := CopyStr(pBOM, 1, Pos - 1);
            pBOM := CopyStr(pBOM, Pos + 1);
        end;

        pQuantity := 0;
        Pos := StrPos(pBOM, '\');
        if pBOM = '' then
            exit(false)
        else
            if Pos = 0 then
                Evaluate(pQuantity, pBOM)
            else begin
                Evaluate(pQuantity, CopyStr(pBOM, 1, Pos - 1));
                pBOM := CopyStr(pBOM, Pos + 1);
            end;
        exit(true);
    end;

    local procedure InsertProductionForecast(pProductionForecastName: Code[10]; pItemNo: Code[20]; pBaseUnitOfMeasure: Code[10]; pDate: Date; pLocationCode: Code[10]; pQuantity: Decimal)
    begin
        ProductionForecastEntry."Entry No." += 1;
        ProductionForecastEntry."Production Forecast Name" := pProductionForecastName;
        ProductionForecastEntry."Item No." := pItemNo;
        ProductionForecastEntry."Forecast Date" := WorkDate;
        ProductionForecastEntry."Unit of Measure Code" := pBaseUnitOfMeasure;
        ProductionForecastEntry."Qty. per Unit of Measure" := 1;
        ProductionForecastEntry."Location Code" := pLocationCode;
        ProductionForecastEntry.Validate("Forecast Quantity", pQuantity);
        ProductionForecastEntry.Insert;
    end;

    local procedure SetStockKeepingUnit(var pItem: Record Item; pLocationCode: Code[10])
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if StockkeepingUnit.Get(pLocationCode, pItem."No.", '') then
            exit;

        StockkeepingUnit.Validate("Item No.", pItem."No.");
        StockkeepingUnit."Location Code" := pLocationCode;
        StockkeepingUnit.validate("Reordering Policy", StockkeepingUnit."Reordering Policy"::"Lot-for-Lot");
        evaluate(StockkeepingUnit."Lot Accumulation Period", '<1W>');
        StockkeepingUnit.Validate("Lot Accumulation Period");
        StockkeepingUnit."Vendor No." := Item."Vendor No.";
        StockkeepingUnit."Vendor Item No." := Item."Vendor Item No.";
        StockkeepingUnit.Insert(true);
    end;

    local procedure NonStockItemExists(pItem: Record Item): Boolean;
    var
        NonstockItem: Record "Nonstock Item";
    begin
        NonStockItem.SetCurrentKey("Vendor Item No.");
        NonstockItem.SetRange("Vendor Item No.", pItem."Vendor Item No.");
        NonstockItem.SetRange("Vendor No.", pItem."Vendor No.");
        exit(NonstockItem.FindFirst());
    end;

    local procedure ChangeSKULocation(var pItem: Record item; pFrom: Code[10]; pTo: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if not SKU.Get(pFrom, Item."No.") then
            exit;
        pItem."Reordering Policy" := SKU."Reordering Policy";
        pItem."Maximum Inventory" := 0;
        pItem."Reorder Point" := 0;
        SKU.Delete(true);
        SKU."Location Code" := pTo;
        SKU.Insert();
    end;

    local procedure SetDefaultDimension(var pItem: Record Item; pDimensionCode: Code[20]; pDimensionValueCode: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.Get(Database::Item, pItem."No.", pDimensionCode) then
            exit;
        DefaultDimension."Table ID" := Database::Item;
        DefaultDimension."No." := pItem."No.";
        DefaultDimension."Dimension Code" := pDimensionCode;
        DefaultDimension."Dimension Value Code" := pDimensionValueCode;
        DefaultDimension.Insert(true);
    end;
}