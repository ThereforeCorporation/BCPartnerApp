pageextension 50000 "Partner-Contact-Card" extends "Contact Card" // Page 5050
{
    layout
    {
        addfirst(factboxes)
        {
            part("The-Drag-Drop-Documents"; "The-Drag-Drop-Documents-ListPa")
            {
                Caption = 'Drag & Drop Documents';
                ApplicationArea = All;
                SubPageLink = "Document No." = Field("No."), "Table ID" = const(5050);
                Visible = bShow;
            }
        }
    }

    var
        bShow: Boolean;
        cuThereforeFunctions: Codeunit "The-Therefore-Functions";
        cuWebServiceFunctions: Codeunit "The-Webservice-Functions";

    trigger OnOpenPage()
    begin
        bShow := (cuThereforeFunctions.GetMappingNo(cuThereforeFunctions.GetTableID(Rec.TableName), 0, false) > 0);
    end;
}
