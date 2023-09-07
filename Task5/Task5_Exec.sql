VAR rc refcursor;
EXECUTE Get_Order_By_Amount_Rank(2, :rc);
PRINT rc;