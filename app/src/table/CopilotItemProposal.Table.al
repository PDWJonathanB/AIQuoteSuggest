/// <summary>
/// Table Copilot Item Proposal (ID 50100).
/// </summary>
table 50100 "Copilot Item Proposal"
{
    Caption = 'Copilot Item Proposal';
    TableType = Temporary;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
            trigger OnValidate()
            var
                Item: Record item;
            begin
                if Item.Get("No.") then
                    Validate(Description, Item.Description);
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(20; Explanation; Text[2048])
        {
            Caption = 'Explanation';
            Editable = false;
        }
        field(21; "Full Explanation"; Blob)
        {
            Caption = 'Full Explanation';
        }
        field(22; Select; Boolean)
        {
            Caption = 'Select';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}
