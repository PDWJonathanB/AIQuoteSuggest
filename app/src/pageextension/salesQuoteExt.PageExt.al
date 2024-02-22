/// <summary>
/// PageExtension salesQuoteExt (ID 50102) extends Record Sales Quote.
/// </summary>
pageextension 50102 salesQuoteExt extends "Sales Quote"
{
    layout
    {
        addlast(General)
        {
            field(ContainsCopilotGeneratedLines; Rec.ContainsCopilotGeneratedLines)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this document contains lines generated from Copilot';
            }
        }
    }
}
