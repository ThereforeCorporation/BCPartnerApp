codeunit 50000 "Partner-Event-Handler"
{
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
