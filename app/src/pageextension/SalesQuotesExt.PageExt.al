/// <summary>
/// PageExtension SalesQuotesExt (ID 50103) extends Record Sales Quotes.
/// </summary>
pageextension 50103 SalesQuotesExt extends "Sales Quotes"
{
    layout
    {
        addlast(Control1)
        {
            field(ContainsCopilotGeneratedLines; Rec.ContainsCopilotGeneratedLines)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this document contains lines generated from Copilot';
            }
        }
    }
}
