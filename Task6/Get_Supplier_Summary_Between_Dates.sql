CREATE PROCEDURE Get_Supplier_Summary_Between_Dates
(
    startDate DATE,
    endDate DATE,
    result out sys_refcursor
)
AS
BEGIN

    OPEN result FOR
    SELECT
        MAX(SUPPLIER_NAME)  "Supplier Name",
        MAX(SUPPLIER_CONTACT_NAME)  "Supplier Contact Name",
        CASE
            WHEN LENGTH(MAX(SUPPLIER_FIRST_CONTACT_NUMBER)) = 7
            THEN SUBSTR(MAX(SUPPLIER_FIRST_CONTACT_NUMBER), 1, 3) || '-' || SUBSTR(MAX(SUPPLIER_FIRST_CONTACT_NUMBER), 4, 7)
            ELSE SUBSTR(MAX(SUPPLIER_FIRST_CONTACT_NUMBER), 1, 4) || '-' || SUBSTR(MAX(SUPPLIER_FIRST_CONTACT_NUMBER), 5, 8)
            END
        AS "Supplier Contact No.1",
        CASE
            WHEN LENGTH(MAX(SUPPLIER_SECOND_CONTACT_NUMBER)) = 7
            THEN SUBSTR(MAX(SUPPLIER_SECOND_CONTACT_NUMBER), 1, 3) || '-' || SUBSTR(MAX(SUPPLIER_SECOND_CONTACT_NUMBER), 4, 7)
            ELSE SUBSTR(MAX(SUPPLIER_SECOND_CONTACT_NUMBER), 1, 4) || '-' || SUBSTR(MAX(SUPPLIER_SECOND_CONTACT_NUMBER), 5, 8)
            END
        AS "Supplier Contact No.2",
        COUNT(od.supplier_id) "Total Orders",
        TO_CHAR(SUM(od.ORDER_TOTAL_AMOUNT), 'fm999g999g990d00') "Order Total Amount"
    FROM bcm_supplier sup
        LEFT JOIN bcm_order od
            ON sup.SUPPLIER_ID = od.SUPPLIER_ID
    WHERE od.ORDER_DATE BETWEEN startDate AND endDate    
    GROUP BY od.SUPPLIER_ID;

END;

