CREATE PROCEDURE Migrate_Data
AS
BEGIN

    -- POPULATE SUPPLIER TABLE
    INSERT INTO BCM_SUPPLIER
    (
        SUPPLIER_NAME,
        SUPPLIER_CONTACT_NAME,
        SUPPLIER_ADDRESS,
        SUPPLIER_FIRST_CONTACT_NUMBER,
        SUPPLIER_SECOND_CONTACT_NUMBER,
        SUPPLIER_EMAIL
    )
    SELECT 
        SUPPLIER_NAME,
        SUPP_CONTACT_NAME,
        SUPP_ADDRESS,
        CASE
            WHEN
                REGEXP_LIKE(
                    SUBSTR(
                        REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', '')
                        , 0
                        , INSTR(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''), ',', 1) - 1
                        ),
                    '^[[:digit:]]+$'
                )
            THEN SUBSTR(
                        REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', '')
                        , 0
                        , INSTR(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''), ',', 1) - 1
                        )
            ELSE NULL
        END,
        CASE
            WHEN
                REGEXP_LIKE(
                    SUBSTR(
                        REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', '')
                        , INSTR(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''), ',', 1) + 1
                        , LENGTH(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''))
                    ),
                    '^[[:digit:]]+$'
                )
            THEN SUBSTR(
                        REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', '')
                        , INSTR(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''), ',', 1) + 1
                        , LENGTH(REPLACE(REPLACE(MIN(SUPP_CONTACT_NUMBER), ' ', ''), '.', ''))
                    )
            ELSE NULL
        END,
        SUPP_EMAIL
    FROM XXBCM_ORDER_MGT
    GROUP BY SUPPLIER_NAME, SUPP_CONTACT_NAME, SUPP_EMAIL, SUPP_ADDRESS
    ORDER BY SUPPLIER_NAME;

    -- MAKE SURE IF ONLY ONE NUMBER, STORE AS FIRST 
    UPDATE BCM_SUPPLIER
    SET
        SUPPLIER_FIRST_CONTACT_NUMBER = SUPPLIER_SECOND_CONTACT_NUMBER,
        SUPPLIER_SECOND_CONTACT_NUMBER = NULL
    WHERE SUPPLIER_FIRST_CONTACT_NUMBER IS NULL AND SUPPLIER_SECOND_CONTACT_NUMBER IS NOT NULL;

    -- POPULATE ORDER TABLE
    INSERT INTO BCM_ORDER
    (
        ORDER_REF,
        ORDER_DATE,
        ORDER_DESCRIPTION,
        ORDER_TOTAL_AMOUNT,
        ORDER_STATUS,
        SUPPLIER_ID
    )
    SELECT
        ORDER_REF,
        CASE
            WHEN VALIDATE_CONVERSION(ORDER_DATE AS DATE) = 1
            THEN TO_DATE(ORDER_DATE, 'DD-MON-YYYY')
            ELSE TO_DATE(ORDER_DATE, 'DD-MM-YYYY')
        END,
        ORDER_DESCRIPTION,
        CASE
            WHEN REGEXP_LIKE(REPLACE(ORDER_TOTAL_AMOUNT, ',', ''), '^[[:digit:]]+$')
            THEN REPLACE(ORDER_TOTAL_AMOUNT, ',', '')
            ELSE NULL 
        END,
        ORDER_STATUS,
        sp.SUPPLIER_ID
    FROM XXBCM_ORDER_MGT mgt
        INNER JOIN BCM_SUPPLIER sp
        ON mgt.SUPPLIER_NAME = sp.SUPPLIER_NAME
    WHERE ORDER_LINE_AMOUNT IS NULL;

    -- POPULATE INVOICE TABLE
    INSERT INTO BCM_INVOICE
    (
        INVOICE_REFERENCE,
        INVOICE_DESCRIPTION,
        INVOICE_DATE,
        INVOICE_AMOUNT,
        INVOICE_STATUS,
        INVOICE_HOLD_REASON,
        ORDER_ID
    )
    SELECT
        INVOICE_REFERENCE,
        INVOICE_DESCRIPTION,
        CASE
            WHEN VALIDATE_CONVERSION(INVOICE_DATE AS DATE) = 1
            THEN TO_DATE(INVOICE_DATE, 'DD-MON-YYYY')
            ELSE TO_DATE(INVOICE_DATE, 'DD-MM-YYYY')
        END,
        CASE
            WHEN REGEXP_LIKE(REPLACE(INVOICE_AMOUNT, ',', ''), '^[[:digit:]]+$')
            THEN REPLACE(INVOICE_AMOUNT, ',', '')
            ELSE NULL 
        END,
        INVOICE_STATUS,
        INVOICE_HOLD_REASON,
        od.ORDER_ID
    FROM XXBCM_ORDER_MGT mgt
        INNER JOIN BCM_ORDER od
        ON SUBSTR(mgt.ORDER_REF, 0, INSTR(mgt.ORDER_REF,'-',1) - 1) = od.ORDER_REF
    WHERE ORDER_LINE_AMOUNT IS NOT NULL
    AND INVOICE_REFERENCE IS NOT NULL;

END;
