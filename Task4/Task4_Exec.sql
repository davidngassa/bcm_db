VAR rc refcursor;
EXECUTE Get_Orders_Summary(:rc);
PRINT rc;