# GitHub Copilot Instructions for AL Development

You are an AI assistant specialized in AL (Application Language) development for Microsoft Dynamics 365 Business Central. Specically Per Tenant Extensions for Commerce 365 for Magento (a Business central extension that integrates Business central with Magento). Follow these guidelines when generating AL code.

## General Coding Standards

### Object Naming and Length
- Maximum object name length is 30 characters 
- Use descriptive but concise names
- Ignore object ID assignments - don't attempt to resolve ID conflicts as these can be manually adjusted later
- Objects should be placed in the src folder and a folder with the entity name.
    Example: src\Customer\CustomerList.Page.al

### Procedure Syntax
- Always include brackets in procedure calls, even when no parameters are passed
- Example: `MyProcedure()` not `MyProcedure`

### Event Handling
- Write subscriber event signatures without quotes around event names
- Example: `[EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsert, '', false, false)]`
- Note: Since a recent Business Central release, event names should be specified without quotes

### Variable Definitions
- Follow consistent variable definition order:
    1. Objects: Record, Report, Codeunit, XmlPort, Page, Query, Notification
    2. System types: BigText, DateFormula, RecordId, RecordRef, FieldRef, FilterPageBuilder
    3. Simple data types: Text, Code, Integer, Decimal, Boolean, Date, Time, DateTime, etc.
    4. Complex types: JsonObject, JsonArray, JsonToken, TempBlob, etc.
    5. Collections: Arrays, Lists, Dictionary

## AL-Specific Guidelines

### Record Operations
- Always use explicit parameters with record operations (Insert, Modify, Delete) 
- Write `Insert(false)`, not `Insert()`, when validation should be skipped
- Write `Modify(false)`, not `Modify()`, when trigger execution should be bypassed
- This explicit approach improves code clarity and documents the intention to skip validation

### JSON Handling
- Leverage AL's built-in JSON handling capabilities
- Use JsonObject, JsonArray, JsonToken for JSON operations
- Use the specialized Get methods for direct type conversion:
    - `GetText()`, `GetInteger()`, `GetBoolean()`, etc. instead of generic `Get()` with conversion
    - Example: `MyJsonObject.GetText("propertyName")` instead of `MyJsonObject.Get("propertyName", MyToken); MyText := MyToken.AsValue().AsText()`
- Prefer structured JSON handling over text manipulation
- Add the suffixes JToken, JObject, JArray to variable names for clarity:
    - Example: `MyDataJObject`, `ItemsJArray`, `ItemJToken`

### TempBlob Usage
- Use the return value from `TempBlob.CreateOutStream()` directly in method calls instead of creating separate OutStream variables
- Similarly, use `TempBlob.CreateInStream()` return values directly when possible
- Handle streams with appropriate encoding parameters

### Text and Multiline Content
- Use AL's native multiline text syntax with the @ symbol:
    ```al
    Text := @'line one
    line two
    line three';
    ```
- This syntax preserves line breaks without manual concatenation

### Conditional Statements
- AL doesn't support "else if" syntax as a single construct
- Instead, format conditions as separate `else` and `if` statements:
    ```al
    if Condition1 then
            DoSomething()
    else
            if Condition2 then
                    DoSomethingElse();
    ```
- For multiple conditions, prefer CASE statements for better readability:
    ```al
    case true of
            Condition1:
                    DoSomething();
            Condition2:
                    DoSomethingElse();
            Condition3:
                    DoAnotherThing();
    end;
    ```

## User Interface Guidelines

### Tooltips
- Apply tooltips at the table field level, not on page controls
- Keep tooltips concise and user-friendly
- Use Magento terminology where applicable

### Application Areas
- Set ApplicationArea only at object level (Page, Table, Report, etc.)
- Exception: Use field-level ApplicationArea for PageExtension and TableExtension objects

### Predefined Mappings in Commerce 365 for Magento
- Predefined mappings exist for product attributes and customer attributes.
- Predefined mappings are codeunits that implement the interface `NC365 Predefined Mapping V2` for product attributes and `NC365 Predef. Customer Mapping` for customer attributes.
- Example of a predefined product attribute implementation:
    ```al
    codeunit 11260835 "NC365 Vendor Name Impl." implements "NC365 Predefined Mapping V2"
    {
        procedure GetMappedTableNo(): Integer
        begin
            exit(Database::Vendor);
        end;

        procedure GetMappedFieldNo(): Integer
        begin
            exit(2);
        end;

        procedure GetDescription(): Text[250]
        begin
            exit('Maps to the ''Name'' field of the ''Vendor'' table in the Microsoft Base Application extension.');
        end;

        procedure GetAllowedDataTypes(): List of [Enum "NC365 Attribute Data Type"]
        var
            AllowedDataTypes: List of [Enum "NC365 Attribute Data Type"];
        begin
            AllowedDataTypes.Add(Enum::"NC365 Attribute Data Type"::Text);
            AllowedDataTypes.Add(Enum::"NC365 Attribute Data Type"::"Text Area");
            AllowedDataTypes.Add(Enum::"NC365 Attribute Data Type"::"Text Editor");
            AllowedDataTypes.Add(Enum::"NC365 Attribute Data Type"::Dropdown);
            exit(AllowedDataTypes);
        end;

        procedure GetAvailableParameterCodes(): Dictionary of [Code[50], Boolean]
        begin

        end;

        procedure GetValue(ItemNo: Code[20]; VariantCode: Code[20]; Parameters: Dictionary of [Code[50], Text]): Variant
        var
            Item: Record Item;
            Vendor: Record Vendor;
        begin
            if not Item.Get(ItemNo) then
                exit;

            if not Vendor.Get(Item."Vendor No.") then
                exit;

            exit(Vendor.Name);
        end;
    }
    ```
- Example of a predefined customer attribute implementation:
    ```al
    codeunit 11260829 "NC365 Payment Method Impl." implements "NC365 Predef. Customer Mapping"
    {
        procedure GetMappedTableNo(): Integer
        begin
            exit(Database::"Payment Method");
        end;

        procedure GetMappedFieldNo(): Integer
        begin
            exit(2);
        end;

        procedure GetDescription(): Text[250]
        begin
            exit('Maps to the ''Description'' field of the ''Payment Method'' table in the Microsoft Base Application extension.');
        end;

        procedure GetAllowedDataTypes(): List of [Enum "NC365 Customer Attribute Data Type"]
        var
            AllowedDataTypes: List of [Enum "NC365 Customer Attribute Data Type"];
        begin
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::None);
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::Date);
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::Decimal);
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::Price);
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::Text);
            AllowedDataTypes.Add(Enum::"NC365 Customer Attribute Data Type"::"Yes/No");

            exit(AllowedDataTypes);
        end;

        procedure GetAvailableParameterCodes(): Dictionary of [Code[50], Boolean]
        begin

        end;

        procedure GetValue(CustomerNo: Code[20]; ContactNo: Code[20]; Parameters: Dictionary of [Code[50], Text]): Variant
        var
            Customer: Record "Customer";
            PaymentMethod: Record "Payment Method";
        begin
            if not Customer.Get(CustomerNo) then
                exit;

            if PaymentMethod.Get(Customer."Payment Method Code") then
                exit(PaymentMethod.Description);
        end;
    }
    ```

### Inventory calculation methods in Commerce 365 for Magento
- Inventory calculation methods are codeunits that implement the interface `NC365 Inventory Calc. Provider`.
- Example of an inventory calculation method implementation:
    ```al
    codeunit 11260808 "NC365 Calc. Inv. Wo. Reserv." implements "NC365 Inventory Calc. Provider"
    {
        Access = Internal;

        internal procedure Calculate(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
        var
            Item: Record Item;
            ItemUnitofMeasure: Record "Item Unit of Measure";
            NC365Item: Record "NC365 Item";
            NC365Location: Record "NC365 Location";
            Setup: Record "NC365 Setup";
            InventoryHelper: Codeunit "NC365 Inventory Helper";
            Factor: Decimal;
            Inventory: Decimal;
        begin
            if not Setup.Get() then
                exit;

            if not Item.Get(ItemNo) then
                exit;

            Factor := 1;
            if Item."Base Unit of Measure" <> Item."Sales Unit of Measure" then begin
                ItemUnitofMeasure.SetRange("Item No.", Item."No.");
                ItemUnitofMeasure.SetRange(Code, Item."Sales Unit of Measure");
                if ItemUnitofMeasure.FindFirst() and (ItemUnitofMeasure."Qty. per Unit of Measure" > 0) then
                    Factor := ItemUnitofMeasure."Qty. per Unit of Measure";
            end;

            //Should we set a location filter
            if LocationCode <> '' then begin
                //If the location does not exist, the exit
                NC365Location.SetRange("Code", LocationCode);
                if NC365Location.IsEmpty() then
                    exit;
                //Otherwise set a filter on the current location
                Item.SetFilter("Location Filter", LocationCode);
            end else begin
                //In case we are calculating for '', but locations are being used
                Clear(NC365Location);
                NC365Location.SetRange(Enabled, true);
                NC365Location.SetRange(Released, true);
                if not NC365Location.IsEmpty() then
                    //Then explicitly set the filter on '' 
                    Item.SetFilter("Location Filter", '%1', '')
                else begin
                    //Otherwise the setup still might have filtering defined
                    Setup.Get();
                    if Setup."Inventory Location Filter" <> '' then
                        Item.SetFilter("Location Filter", Setup."Inventory Location Filter");
                end;
            end;

            if VariantCode <> '' then
                Item.SetFilter("Variant Filter", VariantCode);

            Item.CalcFields(Inventory, "Qty. on Sales Order");
            Inventory := ((Item.Inventory - Item."Qty. on Sales Order") + InventoryHelper.GetBOMInventory(Item, false)) / Factor;

            NC365Item.SetRange("No.", ItemNo);
            NC365Item.SetRange("Store Code", 'GLOBAL');
            NC365Item.SetRange("Qty Uses Decimals", true);
            if not NC365Item.IsEmpty() then
                exit(Inventory)
            else
                exit(Round(Inventory, 1, '<'));
        end;
    }
    ```

### Order header attributes in Commerce 365 for Magento
- Order attributes are key-value pairs associated with staging order headers and lines in Commerce 365 for Magento.
- All staging order header attributes can be read using procedure GetStagingOrderAttributes(NC365StagingOrderHeader) in Codeunit "NC365 Sales Order API". The procedure returns a DDictionary of [Text, Text] containing the attributes. Where the key is the attribute code and the value is the attribute value.
- A specific order header attribute can be read using procedure GetStagingOrderAttributeValue(NC365StagingOrderHeader, AttributeCode) in Codeunit "NC365 Sales Order API". The procedure returns a Text value containing the attribute value.
- All staging order line attributes can be read using procedure GetStagingOrderLineAttributes(NC365StagingOrderLine) in Codeunit "NC365 Sales Order API". The procedure returns a DDictionary of [Text, Text] containing the attributes. Where the key is the attribute code and the value is the attribute value.
- A specific order line attribute can be read using procedure GetStagingOrderLineAttributeValue(NC365StagingOrderLine, AttributeCode) in Codeunit "NC365 Sales Order API". The procedure returns a Text value containing the attribute value.
- Example of processing staging order header attributes after sales document creation:
    ```al
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NC365 Staging Order Events", OnAfterCreateSalesDocument, '', false, false)]
    local procedure NC365StagingOrderEvents_OnAfterCreateSalesDocument(var StagingOrderHeader: Record "NC365 Staging Order Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(StagingOrderHeader."Created Doc. Type", StagingOrderHeader."Created Document No.") then
            exit;

        ProcessAttributes(StagingOrderHeader, SalesHeader);
    end;

    local procedure ProcessAttributes(StagingOrderHeader: Record "NC365 Staging Order Header"; var SalesHeader: Record "Sales Header")
    var
        SalesOrderAPI: Codeunit "NC365 Sales Order API";
        OrderAttributes: Dictionary of [Text, Text];
        AttributeCode, AttributeValue : Text;
    begin
        OrderAttributes := SalesOrderAPI.GetStagingOrderAttributes(StagingOrderHeader);
        if OrderAttributes.Count() = 0 then
            exit;

        foreach AttributeCode in OrderAttributes.Keys() do
            if OrderAttributes.Get(AttributeCode, AttributeValue) then
                ProcessAttribute(SalesHeader, AttributeCode, AttributeValue);

        SalesHeader.Modify(true);
    end;

    local procedure ProcessAttribute(var SalesHeader: Record "Sales Header"; AttributeCode: Text; AttributeValue: Text)
    var
        DateValue: Date;
        DecimalValue: Decimal;
    begin
        case AttributeCode of
            'FREE_DELIVERY':
                if AttributeValue = '1' then
                    SalesHeader.Validate("Shipment Method Code", 'VLG ORDER');

            'PICKUP_TRUCK':
                if AttributeValue = '1' then
                    SalesHeader.Validate("Shipment Method Code", 'KOOIAAP');

            'ORDER_COMMENT':
                CreateCommentLine(SalesHeader, 0, CopyStr(AttributeValue, 1, 80));

            'PICKUP_TRUCK_FEE':
                begin
                    if not Evaluate(DecimalValue, AttributeValue) then
                        exit;

                    if DecimalValue = 0 then
                        exit;

                    CreateHandlingCostSalesLine(SalesHeader, 'KOOIAAP', DecimalValue);
                end;

            'DELIVERY_DATE':
                begin
                    if AttributeValue.Contains(' ') then
                        AttributeValue := CopyStr(AttributeValue.Split(' ').Get(1), 1, 10);

                    if Evaluate(DateValue, AttributeValue) then
                        SalesHeader.Validate("Requested Delivery Date", DateValue);
                end;
        end;
    end;

    local procedure CreateCommentLine(SalesHeader: Record "Sales Header"; DocumentLineNo: Integer; Comment: Text[80])
    var
        SalesCommentLine: Record "Sales Comment Line";
        LineNo: Integer;
    begin
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", SalesHeader."No.");
        SalesCommentLine.SetRange("Document Line No.", DocumentLineNo);
        if SalesCommentLine.FindLast() then
            LineNo := SalesCommentLine."Line No." + 10000
        else
            LineNo := 10000;

        SalesCommentLine.Init();
        SalesCommentLine.Validate("Document Type", SalesHeader."Document Type");
        SalesCommentLine.Validate("No.", SalesHeader."No.");
        SalesCommentLine.Validate("Document Line No.", DocumentLineNo);
        SalesCommentLine.Validate("Line No.", LineNo);
        SalesCommentLine.Validate(Date, WorkDate());
        SalesCommentLine.Validate(Comment, Comment);
        SalesCommentLine.Validate("ACAT Shipment Ref.", SalesCommentLine."ACAT Shipment Ref."::"Shipment Reference");
        SalesCommentLine.Insert(true);
    end;   
    ```
- Example of processing staging order line attributes after sales document line creation:
    ```al
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NC365 Staging Order Events", OnAfterCreateSalesLine, '', false, false)]
    local procedure StagingOrderEvents_OnAfterCreateSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var StagingOrderLine: Record "NC365 Staging Order Line")
    begin
        ProcessAttributes(StagingOrderLine, SalesHeader, SalesLine);
    end;

    local procedure ProcessAttributes(StagingOrderLine: Record "NC365 Staging Order Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SalesOrderAPI: Codeunit "NC365 Sales Order API";
        OrderLineAttributes: Dictionary of [Text, Text];
        AttributeCode, AttributeValue : Text;
    begin
        OrderLineAttributes := SalesOrderAPI.GetStagingOrderLineAttributes(StagingOrderLine);
        if OrderLineAttributes.Count() = 0 then
            exit;

        foreach AttributeCode in OrderLineAttributes.Keys() do
            if OrderLineAttributes.Get(AttributeCode, AttributeValue) then
                ProcessAttribute(SalesHeader, SalesLine, AttributeCode, AttributeValue);

        SalesLine.Modify(true);
    end;

    local procedure ProcessAttribute(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; AttributeCode: Text; AttributeValue: Text)
    var
        DateValue: Date;
        DecimalValue: Decimal;
    begin
        case AttributeCode of
            'NOTE':
                SalesLine.Validate(Note, CopyStr(AttributeValue, 1, MaxStrLen(SalesLine.Note)));

            'PICKUP_TRUCK':
                if AttributeValue = '1' then
                    SalesLine.Validate("Pickup Truck", 'KOOIAAP');

            'COMMENT':
                CreateCommentSalesLine(SalesHeader, AttributeValue);

            'PICKUP_TRUCK_FEE':
                begin
                    if not Evaluate(DecimalValue, AttributeValue) then
                        exit;

                    if DecimalValue = 0 then
                        exit;

                    SalesLine."Line Amount" += DecimalValue;
                end;

            'DELIVERY_DATE':
                begin
                    if AttributeValue.Contains(' ') then
                        AttributeValue := CopyStr(AttributeValue.Split(' ').Get(1), 1, 10);

                    if Evaluate(DateValue, AttributeValue) then
                        SalesLine.Validate("Requested Delivery Date", DateValue);
                end;
        end;
    end;

    local procedure CreateCommentSalesLine(SalesHeader: Record "Sales Header"; Description: Text)
    var
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No." + 10000
        else
            LineNo := 10000;

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", LineNo);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        SalesLine.Validate(Description, CopyStr(Description, 1, MaxStrLen(SalesLine.Description)));
        SalesLine.Insert(true);
    end;
    ```
---

Remember to prioritize code readability, maintainability, and Business Central best practices in all suggestions.