/// <summary>
/// TableExtension CustomerExt (ID 50100) extends Record Customer.
/// </summary>
tableextension 50100 CustomerExt extends Customer
{
    fields
    {
        field(50100; HistoricalDataStartDate; Date)
        {
            Caption = 'Historical Data Start Date';
            DataClassification = ToBeClassified;
        }
    }
}
