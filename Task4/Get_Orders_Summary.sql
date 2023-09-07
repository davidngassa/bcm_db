CREATE PROCEDURE Get_Orders_Summary
(
    summary_result out sys_refcursor
)
AS
BEGIN

    open summary_result for
    SELECT
        TO_NUMBER(REPLACE(max(od.ORDER_REF), 'PO', ''))  "Order Reference",
        TO_CHAR(max(od.ORDER_DATE),'MON-yyyy')  "Order Period",
        MAX(sup.SUPPLIER_NAME)   "Supplier Name",
        TO_CHAR(max(od.ORDER_TOTAL_AMOUNT), 'fm999g999g990d00') "Order Total Amount",
        MAX(od.ORDER_STATUS) "Order Status",
        SUBSTR(inv.INVOICE_REFERENCE, 0 , INSTR(inv.INVOICE_REFERENCE, '.', 1) - 1) "Invoice Reference",
        TO_CHAR(SUM(inv.INVOICE_AMOUNT), 'fm999g999g990d00') "Invoice Total Amount"
    FROM bcm_order od
        INNER JOIN bcm_supplier sup
            ON od.SUPPLIER_ID = sup.SUPPLIER_ID
        INNER JOIN bcm_invoice inv
            ON inv.ORDER_ID = od.ORDER_ID
    GROUP BY SUBSTR(inv.INVOICE_REFERENCE, 0 , INSTR(inv.INVOICE_REFERENCE, '.', 1) - 1)
    ORDER BY MAX(od.order_date) DESC; 

END;
