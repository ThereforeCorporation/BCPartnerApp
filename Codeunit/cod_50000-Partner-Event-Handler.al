codeunit 50000 "Partner-Event-Handler"
{
    //see code below to add a custom macro to be used in mappings (example macro [SPECIALNAME])
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"The-Therefore-Functions", 'OnAfterGetMacroValue', '', true, true)]
    local procedure TheThereforeFunctions_OnAfterGetMacroValue(parMakro: Text[250]; recCategoryInput: Record "The-Category-Input"; refRec: RecordRef; var strReturn: Text[250])
    var
        refField: FieldRef;
    begin
        case parMakro of
            '[TEST]':
                strReturn := 'TEST';
            '[SPECIALNAME]':
                begin
                    strReturn := recCategoryInput.Value; // Needed for AdHoc

                    case refRec.NUMBER of
                        Database::"Customer":
                            begin // Customer
                                refField := refRec.FIELD(1);
                                strReturn := FORMAT(refField.VALUE());
                                refField := refRec.FIELD(2);
                                strReturn := strReturn + ' ' + FORMAT(refField.VALUE());
                            end;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"The-Therefore-Functions", 'OnAfterShowDocumentTypeInMapping', '', true, true)]
    local procedure TheThereforeFunctions_OnAfterShowDocumentTypeInMapping(iTableID: Integer; var bShow: Boolean)
    begin
        //if((iTableID = 36) or (iTableID = 38)) then
        //    bShow := true;
    end;

    //example code to overwrite the default content of the drop zone linked documents list
    //this can be used to add additional documents to the list which have not been assigned on this page
    //in the example below all documents saved to a contact of a customer are also loaded/displayed when the only customer page is opened and vice-versa
    //To Do:
    //       *) Decide if you want to customize for this table - if not just return with isHandled:= false
    //       *) Clear the current filter
    //       *) Collect the required data and build a filter for rows/documents/data to be added and call AddFilter2TempTable
    //       *) Do this for as many rows/documents/data you want to display on that specific table
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"The-Therefore-Functions", 'OnBeforeUpdateSourceTable', '', true, true)]
    local procedure TheThereforeFunctions_OnBeforeUpdateSourceTable(var Rec: Record "The-Therefore-Documents" temporary; var RecFilter: Record "The-Therefore-Documents" temporary; isHandled: Boolean);
    var
        recThereforeDocuments: Record "The-Therefore-Documents";
        recContactBusinessRelation: Record "Contact Business Relation";
        recContact: Record Contact;
        cuThereforeFunctions: Codeunit "The-Therefore-Functions";
        cCompanyNo: Code[20];
        iTableID: Integer;
    begin
        if (not Evaluate(iTableID, RecFilter.GetFilter("Table ID"))) then;

        if (DELCHR(RecFilter.GetFilter("Document No."), '=', '''') = '') then
            exit;

        // Build Tmp Table
        case iTableID of
            5050:
                begin
                    recContact.Get(RecFilter.GetFilter("Document No."));
                    cCompanyNo := recContact."Company No.";

                    // Get Customer
                    recContactBusinessRelation.Reset();
                    recContactBusinessRelation.SetRange("Contact No.", cCompanyNo);
                    recContactBusinessRelation.SetRange("Link to Table", recContactBusinessRelation."Link to Table"::Customer);
                    if (recContactBusinessRelation.FindFirst()) then begin
                        recThereforeDocuments.Reset();
                        recThereforeDocuments.SetRange("Document No.", recContactBusinessRelation."No.");
                        cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                    end;

                    // Get Contacts from Customer
                    recContact.Reset();
                    recContact.SetRange("Company No.", cCompanyNo);
                    if (recContact.FindSet()) then begin
                        repeat
                            recThereforeDocuments.Reset();
                            recThereforeDocuments.SetRange("Document No.", recContact."No.");
                            cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                        until recContact.Next() = 0;
                    end;

                    isHandled := true;
                end;
            18:
                begin
                    // Get Customer
                    recThereforeDocuments.Reset();
                    recThereforeDocuments.SetRange("Document No.", RecFilter.GetFilter("Document No."));
                    cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);

                    // Get Contacts from Customer
                    recContactBusinessRelation.Reset();
                    recContactBusinessRelation.SetRange("No.", RecFilter.GetFilter("Document No."));
                    recContactBusinessRelation.SetRange("Link to Table", recContactBusinessRelation."Link to Table"::Customer);
                    if (recContactBusinessRelation.FindFirst()) then begin
                        recContact.Reset();
                        recContact.SetRange("Company No.", recContactBusinessRelation."Contact No.");
                        if (recContact.FindSet()) then begin
                            repeat
                                recThereforeDocuments.Reset();
                                recThereforeDocuments.SetRange("Document No.", recContact."No.");
                                cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                            until recContact.Next() = 0;
                        end;
                    end;

                    isHandled := true;
                end;
        end;
    end;

    // Transfer Dokuments from Quote zu Order
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order (Yes/No)", 'OnAfterSalesQuoteToOrderRun', '', true, true)]
    local procedure OnAfterSalesQuoteToOrderRun(var SalesHeader2: Record "Sales Header"; var SalesHeader: Record "Sales Header")
    var
        cuThePostFunctions: Codeunit "The-Post-Functions";
    begin
        TransferDocuments(
            SalesHeader."No.", SalesHeader."Document Type".AsInteger(), SalesHeader2."No.", SalesHeader2."Document Type".AsInteger(), cuThePostFunctions.GetTableID(SalesHeader2.TableName())
        );
    end;

    procedure TransferDocuments(cSourceDocumentNo: Code[20]; iSourceDocumentType: Integer; cDestDocumentNo: Code[20]; iDestDocumentType: Integer; iDestTableID: Integer)
    var
        recSourceTFDocuments: Record "The-Therefore-Documents";
        recDestTFDocuments: Record "The-Therefore-Documents";
        recMapping: Record "The-Mapping-Header";
    begin
        // Mapping vorhanden
        recMapping.Reset();
        //recMapping.SetRange( Active, TRUE );
        recMapping.SetRange("NAV Table", iDestTableID);
        recMapping.SetRange("Document Type", 0);
        if (recMapping.IsEmpty()) then
            exit;

        recSourceTFDocuments.Reset();
        recSourceTFDocuments.SetRange("Document No.", cSourceDocumentNo);
        recSourceTFDocuments.SetRange("Document Type", iSourceDocumentType);
        if (recSourceTFDocuments.FindSet()) then begin
            repeat
                recDestTFDocuments.Reset();
                recDestTFDocuments.SetRange("Document No.", cDestDocumentNo);
                recDestTFDocuments.SetRange("Table ID", iDestTableID);
                recDestTFDocuments.SetRange("Therefore Document No.", recSourceTFDocuments."Therefore Document No.");
                if (not recDestTFDocuments.FindFirst()) then begin
                    recDestTFDocuments.Init();
                    recDestTFDocuments.TransferFields(recSourceTFDocuments);
                    recDestTFDocuments."Link ID" := 0;
                    recDestTFDocuments."Document No." := cDestDocumentNo;
                    recDestTFDocuments."Document Type" := iDestDocumentType;
                    recDestTFDocuments."Table ID" := iDestTableID;
                    recDestTFDocuments.Insert(true);
                end;
            until recSourceTFDocuments.Next() = 0;
        end;
    end;
}
