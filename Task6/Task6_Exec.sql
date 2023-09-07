VAR rc refcursor;
EXEC Get_Supplier_Summary_Between_Dates ('01-JAN-2022', '01-AUG-2022', :rc);
PRINT rc;