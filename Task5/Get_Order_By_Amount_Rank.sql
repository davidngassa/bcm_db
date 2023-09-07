CREATE PROCEDURE Get_Order_By_Amount_Rank
(
    order_rank NUMBER,
    result out sys_refcursor
)
AS
BEGIN

    OPEN result FOR
    SELECT
        TO_NUMBER(REPLACE(od.ORDER_REF, 'PO', ''))              "Order Reference",
        TO_CHAR(MAX(od.ORDER_DATE),'Month dd, yyyy')            "Order Date",
        UPPER(MAX(sup.SUPPLIER_NAME))                           "Supplier Name",
        TO_CHAR(MAX(od.ORDER_TOTAL_AMOUNT), 'fm999g999g990d00') "Order Total Amount",
        MAX(od.ORDER_STATUS)                                    "Order Status",
        LISTAGG(inv.INVOICE_REFERENCE, '|') WITHIN GROUP (ORDER BY inv.INVOICE_REFERENCE)    "Invoice References"
    FROM (
        SELECT
                ORDER_ID,
                ORDER_REF,
                ORDER_DATE,
                SUPPLIER_ID,
                ORDER_TOTAL_AMOUNT,
                ORDER_STATUS,
                ROW_NUMBER() OVER (ORDER BY ORDER_TOTAL_AMOUNT DESC) AS row_num
        FROM bcm_order
    ) od
    LEFT JOIN bcm_invoice inv
        ON od.ORDER_ID = inv.ORDER_ID
    INNER JOIN bcm_supplier sup
        ON od.SUPPLIER_ID = sup.SUPPLIER_ID
    WHERE row_num = order_rank
    GROUP BY od.ORDER_REF;
    
END;
