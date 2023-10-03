tableextension 50000 GenJournalLine extends "Gen. Journal Line"
{
    fields
    {
        field(50000; ThereforeKey; Code[250])
        {
            Caption = 'ThereforeKey';
            DataClassification = ToBeClassified;
        }
        field(50001; ThereforeKeyInt; Integer)
        {
            Caption = 'ThereforeKey';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    begin
        SetIndivKey();
    end;

    trigger OnModify()
    begin
        SetIndivKey();
    end;

    trigger OnDelete()
    var
        ThereforeDocuments: Record "The-Therefore-Documents";
    begin
        // if you want delete the assigned stored therefore documents
        ThereforeDocuments.Reset();
        ThereforeDocuments.SetRange("Table ID", 81);
        ThereforeDocuments.SetRange("Entry No.", Rec.ThereforeKeyInt);
        //ThereforeDocuments.DeleteAll(false);
    end;

    // Das Feld ThereforeKeyInt ist immer der höchste Wert der Tabelle
    // Wenn Sie den höchsten Datensatz löschen, kann der Wert des Feldes erneut vergeben werden, es entstehen keine Lücken wie in einem "echten" AutoIncrement Feld
    // Sie können auch den vergeben Wert durch eine Nummernserie bestimmen oder ihn in eine Setup Tabelle zwischenspeichern und jedesmal neu laden
    procedure SetIndivKey()
    var
        r: Record "Gen. Journal Line";
    begin
        Rec.ThereforeKey := Rec."Journal Template Name" + Rec."Journal Batch Name" + FORMAT(Rec."Line No.");

        r.Reset();
        if (r.FindLast()) then
            Rec.ThereforeKeyInt := r.ThereforeKeyInt + 1
        else
            Rec.ThereforeKeyInt := 1;
    end;
}
