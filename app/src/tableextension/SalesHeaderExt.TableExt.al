/// <summary>
/// TableExtension SalesHeaderExt (ID 50102) extends Record Sales Header.
/// </summary>
tableextension 50102 SalesHeaderExt extends "Sales Header"
{
    fields
    {
        field(50100; ContainsCopilotGeneratedLines; Boolean)
        {
            FieldClass = Flowfield;
            CalcFormula = exist("Sales Line" where("Document Type" = Field("Document Type"),
                                                    "Document No." = Field("No."),
                                                    GeneratedFromCopilot = const(true)));
            Caption = 'Contains Copilot Generated Lines';
        }
    }
}
