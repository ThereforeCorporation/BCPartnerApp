pageextension 50002 "Partner-The-Add-File-Dialog" extends "The-Add-File-Dialog-Card"
{
    layout
    {
        modify(strAdditionalInfo)
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                CustomerList: Page "Customer List";
                Customer: Record Customer;
            begin
                Clear(CustomerList);
                CustomerList.LookupMode(true);
                if (CustomerList.RunModal() = Action::LookupOK) then begin
                    CustomerList.GetRecord(Customer);
                    Text := Customer."No.";

                    exit(true);
                end;

                exit(false);
            end;
        }
    }
}

