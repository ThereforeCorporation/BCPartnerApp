pageextension 50003 "Partner Sales Credit Memo" extends "Sales Credit Memo" // Page 44
{
    actions
    {
        addlast(Processing)
        {
            action("Print Confirmation")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print and Archive Confirmation';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Print and Archive a sales credit memo confirmation.';

                trigger OnAction()
                var
                    CreditMemoConfirmation: Report "Credit Memo Confirmation";
                    SalesHeader: Record "Sales Header";
                    cTFPostFunctions: Codeunit "The-Post-Functions";
                begin
                    // 1. print indiv report 
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", Rec."Document Type");
                    SalesHeader.SetRange("No.", Rec."No.");

                    Clear(CreditMemoConfirmation);
                    CreditMemoConfirmation.SetTableView(SalesHeader);
                    CreditMemoConfirmation.RunModal();

                    // 2. archive to therefore
                    cTFPostFunctions.AddDocumentToQueue(
                        cTFPostFunctions.GetTableID(SalesHeader.TableName()),   // Tablename
                        Rec."No.",                                              // Document No.
                        0D,                                                     // Posting Date
                        0,                                                      // Entry No.
                        Rec."Document Type".AsInteger(),                        // Document Type
                        '',                                                     // Identification ID
                        Rec."The-Business-Case"                                 // Business Case
                        );
                end;
            }
        }
    }
}
