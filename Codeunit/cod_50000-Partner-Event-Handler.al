codeunit 50000 "Partner-Event-Handler"
{
    //see code below to add a custom macro to be used in mappings (example macro [SPECIALNAME])
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"The-Therefore-Functions", 'OnAfterGetMacroValue', '', true, true)]
    local procedure
    OnAfterGetMacroValue(parMakro: Text[250]; recCategoryInput: Record "The-Category-Input"; refRec: RecordRef; var strReturn: Text[250])
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
    local procedure
    OnAfterShowDocumentTypeInMapping(iTableID: Integer; var bShow: Boolean)
    begin
        //if ((iTableID = 36) or (iTableID = 38)) then
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
    local procedure C52101146_ThereforeFunctions_OnBeforeUpdateSourceTable(var Rec: Record "The-Therefore-Documents" temporary; var RecFilter: Record "The-Therefore-Documents" temporary; isHandled: Boolean);
    var
        recThereforeDocuments: Record "The-Therefore-Documents";
        recContactBusinessRelation: Record "Contact Business Relation";
        recContact: Record Contact;
        cuThereforeFunctions: Codeunit "The-Therefore-Functions";
        cCompanyNo: Code[20];
        iTableID: Integer;
    begin
        IF (NOT EVALUATE(iTableID, RecFilter.GETFILTER("Table ID"))) THEN;

        IF DELCHR(RecFilter.GETFILTER("Document No."), '=', '''') = '' THEN
            EXIT;

        // Build Tmp Table
        CASE iTableID OF
            5050:
                BEGIN
                    recContact.GET(RecFilter.GETFILTER("Document No."));
                    cCompanyNo := recContact."Company No.";

                    // Get Customer
                    recContactBusinessRelation.RESET();
                    recContactBusinessRelation.SETRANGE("Contact No.", cCompanyNo);
                    recContactBusinessRelation.SETRANGE("Link to Table", recContactBusinessRelation."Link to Table"::Customer);
                    IF (recContactBusinessRelation.FINDFIRST()) THEN BEGIN
                        recThereforeDocuments.RESET();
                        recThereforeDocuments.SETRANGE("Document No.", recContactBusinessRelation."No.");
                        cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                    END;

                    // Get Contacts from Customer
                    recContact.RESET();
                    recContact.SETRANGE("Company No.", cCompanyNo);
                    IF (recContact.FINDSET()) THEN BEGIN
                        REPEAT
                            recThereforeDocuments.RESET();
                            recThereforeDocuments.SETRANGE("Document No.", recContact."No.");
                            cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                        UNTIL recContact.NEXT() = 0;
                    END;

                    isHandled := TRUE;
                END;
            18:
                BEGIN
                    // Get Customer
                    recThereforeDocuments.RESET();
                    recThereforeDocuments.SETRANGE("Document No.", RecFilter.GETFILTER("Document No."));
                    cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);

                    // Get Contacts from Customer
                    recContactBusinessRelation.RESET();
                    recContactBusinessRelation.SETRANGE("No.", RecFilter.GETFILTER("Document No."));
                    recContactBusinessRelation.SETRANGE("Link to Table", recContactBusinessRelation."Link to Table"::Customer);
                    IF (recContactBusinessRelation.FINDFIRST()) THEN BEGIN
                        recContact.RESET();
                        recContact.SETRANGE("Company No.", recContactBusinessRelation."Contact No.");
                        IF (recContact.FINDSET()) THEN BEGIN
                            REPEAT
                                recThereforeDocuments.RESET();
                                recThereforeDocuments.SETRANGE("Document No.", recContact."No.");
                                cuThereforeFunctions.AddFilter2TempTable(recThereforeDocuments, Rec);
                            UNTIL recContact.NEXT() = 0;
                        END;
                    END;

                    isHandled := TRUE;
                END;
        END
    end;
}
